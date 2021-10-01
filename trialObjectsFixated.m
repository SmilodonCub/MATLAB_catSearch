function [ trialObjectsFixated_Info ] = trialObjectsFixated( BHV, ETparams, eventmarkerAlignData )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
        %--------------------------------------------------------------------------
        % Evaluate Fixation Positions (did they land on a TaskObject?)
        %--------------------------------------------------------------------------
        
        FixON_eventmarker = 2; %these eventmarkers are used by functions that handle eyeLink & spike alignments to behavioral eventmarkers
        ArrayON_eventmarker = 21;
        TargetCORRECT = 14;
        correct_idx = find( BHV.TrialError == 0 );
        correctTrial = 0;
        searchSaccade = zeros( size( ETparams.saccadeInfo,2 ),size( ETparams.saccadeInfo,3 ) );
        trialObjectsFixated_Info = struct( [ ] );
        
        %create a new struct that will hold info taskObjects that were the
        %destination/location of saccades/fixations.
        
        %for each trial
        for trial = 1:size(BHV.AnalogData,2)
            %trial
            %get information about the task array to compare with eye position
            %data
            %get position of each array member plus tabutton
            
            if BHV.TrialError( trial ) == 0  %if correct: do these things
                %disp( trial )
                correctTrial = correctTrial + 1;
                taskObjectPos = zeros( [ 5,4 ] );
                taskObjectNames = cell( [ 5,1 ] );
                %parse taskObject #4 for CatSearchPHYSIOL this is target absent
                %button
                Object = regexp( BHV.TaskObject{BHV.ConditionNumber(trial), 4 }, '[(,)]', 'split');
                %targetAbsentButton X,Y position coordinate to the
                %1st row; 1:2 columns of tashObjectPos
                taskObjectPos( 1, 1 ) = str2double(char(Object(5)));
                taskObjectPos( 1, 2 ) = str2double(char(Object(6)));
                taskObjectNames{ 1,1 } = 'Sqr'; %target absent button
                %for each taskObject in the search array (4)
                for collectPos = 2: (size( taskObjectPos,1 ) )
                    %parse & pass the position X,Y values to taskObjectPos
                    Object = regexp( BHV.TaskObject{BHV.ConditionNumber(trial), collectPos + 3 }, '[(,)]', 'split');
                    taskObjectPos( collectPos, 1 ) = str2double(char(Object(3)));
                    taskObjectPos( collectPos, 2 ) = str2double(char(Object(4)));
                    taskObjectNames( collectPos, 1 ) = Object(2);
                end
                
                [ taskObjectPos(:,3), taskObjectPos(:,4) ] = cart2pol( taskObjectPos(:,1), taskObjectPos(:,2) );
                taskObjectPos(:,3) = round(rad2deg(taskObjectPos(:,3)),1 );
                taskObjectPos(:,4) = round(taskObjectPos(:,4),1 );
                
                trialObjectsFixated_Info( correctTrial ).taskObjectPos = taskObjectPos;
                trialObjectsFixated_Info( correctTrial ).taskObjectNames = taskObjectNames;
                
             %end
         %end
                
                
                
                %get the time relative to the BHV file when FixON (event2)
                fixON_idx = find( BHV.CodeNumbers{ correct_idx( correctTrial ) } == FixON_eventmarker );
                fixON_time_ms = BHV.CodeTimes{ correct_idx( correctTrial ) }( fixON_idx );
                
                %find the BHV relative time when the target has been properly held
                trialCorrect_idx = find( BHV.CodeNumbers{ correct_idx( correctTrial ) } == TargetCORRECT );
                trialCorrect_time_ms = BHV.CodeTimes{ correct_idx( correctTrial ) }( trialCorrect_idx );
                
                %get the time relative to the BHV file when StimON
                targetON_idx = find( BHV.CodeNumbers{ correct_idx( correctTrial ) } == ArrayON_eventmarker );
                targetON_time_ms = BHV.CodeTimes{ correct_idx( correctTrial ) }( targetON_idx );
                
                %evaluate the position & objects fixated for each saccade made
                %during this trial
                
                for saccadeSTEP = 1:size( ETparams.saccadeInfo,3 ) %for each saccade
                    
                    %get the 'Sth' saccade from the ETparams struct
                    currentSaccade = round( ETparams.saccadeInfo( 1, correctTrial, saccadeSTEP ).start*1000 );
                    
                    
                    %is the saccade after the targetON time
                    %i subtract fixON_time_ms here because the eye trace data had been clipped starting at fixON_time_ms
                    if  ( targetON_time_ms - fixON_time_ms ) <= currentSaccade
                        %if  ( targetON_time_ms ) < currentSaccade
                        %targetON_time_ms - fixON_time_ms
                        %is the saccade before the trialCorrect time
                        %it should, because the eye trace data is clipped by this
                        %event marker, but I do this to catch errors
                        %i subtract fixON_time_ms here because the eye trace data had been clipped starting at fixON_time_ms
                        if currentSaccade < ( trialCorrect_time_ms - fixON_time_ms )
                            
                            searchSaccade( correctTrial, saccadeSTEP ) = 1;
                            %what are the X,Y coordinates of the saccade endpoint?
                            
                            saccadeSTARTTIME = round( ( ETparams.saccadeInfo( 1, correctTrial, saccadeSTEP ).start *1000 ) + fixON_time_ms );
                            saccadeENDTIME = round( ( ETparams.saccadeInfo( 1, correctTrial, saccadeSTEP ).end *1000 ) + fixON_time_ms ); 
                            EyeLink_X = eventmarkerAlignData( correctTrial ).EyeX;
                            EyeLink_Y = eventmarkerAlignData( correctTrial ).EyeY;
                            eyeXPosEndSaccade = EyeLink_X( saccadeENDTIME );
                            eyeYPosEndSaccade = EyeLink_Y( saccadeENDTIME );
                            trialObjectsFixated_Info( correctTrial ).eyeXPosEndSaccade( saccadeSTEP ) = eyeXPosEndSaccade;
                            trialObjectsFixated_Info( correctTrial ).eyeYPosEndSaccade( saccadeSTEP ) = eyeYPosEndSaccade;
                            trialObjectsFixated_Info( correctTrial ).saccadeSTARTTIME( saccadeSTEP ) = saccadeSTARTTIME;
                            trialObjectsFixated_Info( correctTrial ).saccadeENDTIME( saccadeSTEP ) = saccadeENDTIME;
                            try
                                fixationDURATION = round( ( ETparams.fixationInfo( 1, correctTrial, saccadeSTEP ).duration *1000 ) );
                                if fixationDURATION
                                    trialObjectsFixated_Info( correctTrial ).fixationDURATION( saccadeSTEP ) = fixationDURATION;
                                end
                            catch ME
                                disp( [ 'ERROR trial#' num2str( trial ) ] )
                                disp( ME.identifier )
                                disp( ME.message )
                            end
                            
                            
                            
                            %find the taskobject that has the minimum
                            %distance to the saccade endpoint
                            [ SaccadeDistance2ClosestTO, TOidx ] = min( round( sqrt( (taskObjectPos( :,1 ) - eyeXPosEndSaccade).^2 + (taskObjectPos( :,2 ) - eyeYPosEndSaccade).^2 ) ) );
                            %is the saccade endpoint within the target
                            %window of the closest object?
                            
                            targetVariableName_str = 'target_window';
                            fixVariableName_str = 'fix_window';
                            targetWindowRadius = BHV_VariableValue( BHV, trial, targetVariableName_str );
                            fixWindowRadius = BHV_VariableValue( BHV, trial, fixVariableName_str );
                            
                            if SaccadeDistance2ClosestTO <= targetWindowRadius
                                %
                                %check if this fixation was within the
                                %targetwindowradius 
                                taskObjectFixated = taskObjectNames( TOidx );
                                trialObjectsFixated_Info( correctTrial ).taskObjectsFixated( saccadeSTEP ) = taskObjectFixated;
                                
                            elseif round( sqrt( (0 - eyeXPosEndSaccade).^2 + (0 - eyeYPosEndSaccade).^2 ) ) <= fixWindowRadius
                                %
                                %check if this fixation was still at
                                %central fixation
                                trialObjectsFixated_Info( correctTrial ).taskObjectsFixated( saccadeSTEP ) = { 'Fixation' };
                            else%if SaccadeDistance2ClosestTO > targetWindowRadius
                                %
                                %if the fixation was not within an
                                %taskobject window or within the cantral
                                %fixation window then it must have been to
                                %somerandom spot on the screen. need to
                                %filter these saccades out.
                                trialObjectsFixated_Info( correctTrial ).taskObjectsFixated( saccadeSTEP ) = { 'NONfix,NONarray' };
                                
                            end
                            
                            %troubleshooting
                            %trialCorrect_time_ms - fixON_time_ms
                            %saccadeSTEP
                            %currentSaccade
                            %length( eyeXPosEndSaccade )
                            %disp( 'This saccade is made during Target search' )
                            %                         saccadeSTEP
                            %                         trialCorrect_time_ms - fixON_time_ms
                            %                         targetON_time_ms - fixON_time_ms
                            %                         currentSaccade
                            
                            %elseif currentSaccade > ( trialCorrect_time_ms - fixON_time_ms )
                            %continue
                            
                            %troubleshooting
                            %disp( 'This saccade is made after target Search' )
                            %                         saccadeSTEP
                            %                         currentSaccade
                        end
                        %is the saccade before the targetON time
                        %i subtract fixON_time_ms here because the eye trace data had been clipped starting at fixON_time_ms
                     elseif targetON_time_ms - fixON_time_ms > currentSaccade
                        trialObjectsFixated_Info( correctTrial ).taskObjectsFixated( saccadeSTEP ) = { 'preTargetON' };
                        
                        %troubleshooting
                        %disp( 'This saccade is made before Target Search' )
                        %                     saccadeSTEP
                        %                     currentSaccade
                        
                    end
                    
                    
                end
            end
            
            %sum( searchSaccade,2 ) %can check to see if this is the same
            %value that AlignSpikesBehav_StimON_SaccON comes up with
            


        end
        %taskObjectPos
        %searchSaccade
end


function [ catSearchPHYSIOL_Data ] = catSearchPHYSIOL_DataEXTRACT( BHV, trialObjectsFixated_Info, Catergory, RFangle )
%catSearchPHYSIOL_DataEXTRACT this function is a step to condition
%this experiments data so that it conditions are ssorted for final analysis
%and plotting. It's task specific & intended for the analysis that I'd like
%to see for the SfN 2017 poster 


catSearchPHYSIOL_Data = struct([]);
% TP_unsure = 0; %debugging
% TA_unsure = 0;
correct_idx = find( BHV.TrialError == 0 );
num_correct = length(correct_idx);   
%RF_angle = str2num( BHV.InfoByCond{1}.ArOr );
firstTaskObjectNum = 5;


for ii = 1:num_correct;                   %if the current trial is correct, do all these things
    %ii
    %num_correct
    
    haztarget = BHV.InfoByCond{BHV.ConditionNumber( correct_idx( ii ) ) }.ifTarget;
    catSearchPHYSIOL_Data( ii ).haztarget = haztarget;
    
    
    if haztarget == '1'
        numTaskObjectsFixated = 0;
        numPossibleSaccades = size( trialObjectsFixated_Info( ii ).saccadeSTARTTIME,2 );
        for iii = 1:numPossibleSaccades
            %iii
            thisTaskObject = trialObjectsFixated_Info( ii ).taskObjectsFixated{ iii };
            if strcmpi( thisTaskObject, 'preTargetON')
                %disp('preTargetON')
                continue
            elseif strfind( thisTaskObject, [ 'D' Catergory ] )
                
                try
                    previousTaskObjViewed = trialObjectsFixated_Info( ii ).taskObjectsFixated{ iii-1 };
                    if strcmp( previousTaskObjViewed, thisTaskObject )
                        %disp('this distractor was viewed in the previous fixation')
                    elseif ~strcmp( previousTaskObjViewed, thisTaskObject )
                        if numTaskObjectsFixated == 0;
                            catSearchPHYSIOL_Data( ii ).firstSearchSaccade  = trialObjectsFixated_Info( ii ).saccadeSTARTTIME( iii );
                            numTaskObjectsFixated = numTaskObjectsFixated + 1;
                        elseif numTaskObjectsFixated ~= 0;
                            numTaskObjectsFixated = numTaskObjectsFixated + 1;
                        end
                    end
                catch ME
                    disp( ME.identifier )
                end
                %disp('distractor')
                %numTaskObjectsFixated
            elseif strfind( thisTaskObject, [ 'T' Catergory ] )
                %disp('Target')
                try
                    previousTaskObjViewed = trialObjectsFixated_Info( ii ).taskObjectsFixated{ iii-1 };
                    if strcmp( previousTaskObjViewed, thisTaskObject )
                        %disp('The Target was viewed in the previous fixation')
                    elseif ~strcmp( previousTaskObjViewed, thisTaskObject )
                        if numTaskObjectsFixated == 0;
                            %Target present Immediate saccade REATION TIME (was
                            %catSearchPHYSIOL_Info(:,1))
                            catSearchPHYSIOL_Data( ii ).tP_ImmediateSaccade = trialObjectsFixated_Info( ii ).saccadeSTARTTIME( iii );
                            catSearchPHYSIOL_Data( ii ).firstSearchSaccade = trialObjectsFixated_Info( ii ).saccadeSTARTTIME( iii );
                            numTaskObjectsFixated = numTaskObjectsFixated + 1;
                            %numTaskObjectsFixated
                        elseif numTaskObjectsFixated ~= 0;
                            %Target present multiple saccade to target REACTION TIME (was
                            %catSearchPHYSIOL_Info(:,2))
                            catSearchPHYSIOL_Data( ii ).tP_MultipleSaccades = trialObjectsFixated_Info( ii ).saccadeSTARTTIME( iii );
                            numTaskObjectsFixated = numTaskObjectsFixated + 1;
                            %numTaskObjectsFixated
                        end
                    end
                catch ME
                    disp( ME.identifier )
                end

%             else
%                 disp('TP: not sure what happened here')
%                 TP_unsure = TP_unsure + 1;
                
            end
            
            catSearchPHYSIOL_Data( ii ).numSearchSaccades = iii;
            
        end
        %Target present number of saccades to target (was
        %catSearchPHYSIOL_Info(:,3))
        catSearchPHYSIOL_Data( ii ).numTaskObjectsFixated = numTaskObjectsFixated;
        
    elseif haztarget == '0'
        
        numTaskObjectsFixated = 0;
        numPossibleSaccades = size( trialObjectsFixated_Info( ii ).saccadeSTARTTIME,2 );
        for iii = 1: numPossibleSaccades
            %iii
            thisTaskObject = trialObjectsFixated_Info( ii ).taskObjectsFixated{ iii };
            if strcmpi( thisTaskObject, 'preTargetON')
                %disp('preTargetON')
                continue
            elseif strfind( thisTaskObject, [ 'D' Catergory ] )
                %disp('distractor')
                %if there is a previous taskobject viewed, check that it
                %isn't the same as the current one
                try
                    previousTaskObjViewed = trialObjectsFixated_Info( ii ).taskObjectsFixated{ iii-1 };
                    if strcmp( previousTaskObjViewed, thisTaskObject )
                        %disp('this distractor was viewed in the previous fixation')
                    elseif ~strcmp( previousTaskObjViewed, thisTaskObject )
                        if numTaskObjectsFixated == 0;
                            catSearchPHYSIOL_Data( ii ).firstSearchSaccade  = trialObjectsFixated_Info( ii ).saccadeSTARTTIME( iii );
                            numTaskObjectsFixated = numTaskObjectsFixated + 1;
                        elseif numTaskObjectsFixated ~= 0;
                            numTaskObjectsFixated = numTaskObjectsFixated + 1;
                        end
                    end
                catch ME
                    disp( ME.identifier )
                end
                %numTaskObjectsFixated
            elseif strfind( thisTaskObject, 'Sqr' )
                %disp('TAButton')
                try
                    previousTaskObjViewed = trialObjectsFixated_Info( ii ).taskObjectsFixated{ iii-1 };
                    if strcmp( previousTaskObjViewed, thisTaskObject )
                        %disp('this TargetAbsent Button was viewed in the previous fixation')
                    elseif ~strcmp( previousTaskObjViewed, thisTaskObject )
                        if numTaskObjectsFixated == 0;
                            %Target absent Immediate saccade REATION TIME (was
                            %catSearchPHYSIOL_Info(:,4))
                            catSearchPHYSIOL_Data( ii ).tABS_ImmediateSaccade = trialObjectsFixated_Info( ii ).saccadeSTARTTIME( iii );
                            catSearchPHYSIOL_Data( ii ).firstSearchSaccade = trialObjectsFixated_Info( ii ).saccadeSTARTTIME( iii );
                            numTaskObjectsFixated = numTaskObjectsFixated + 1;
                            %numTaskObjectsFixated
                        elseif numTaskObjectsFixated ~= 0;
                            %Target absent multiple saccade to target REACTION TIME (was
                            %catSearchPHYSIOL_Info(:,5))
                            catSearchPHYSIOL_Data( ii ).tABS_MultipleSaccades = trialObjectsFixated_Info( ii ).saccadeSTARTTIME( iii );
                            numTaskObjectsFixated = numTaskObjectsFixated + 1;
                            %numTaskObjectsFixated
                        end
                    end
                catch ME
                    disp( ME.identifier )
                end
                %numTaskObjectsFixated

%             else
%                 disp('TA: not sure what happened here')
%                 TA_unsure = TA_unsure + 1;
                
            end
            
            catSearchPHYSIOL_Data( ii ).numSearchSaccades = iii;
            
        end
        %Target absent number of saccades to targetAbsent button (was
        %catSearchPHYSIOL_Info(:,6))
        catSearchPHYSIOL_Data( ii ).numTaskObjectsFixated = numTaskObjectsFixated;
        
    end
    
    trialArraySize = 0;                                                     %we need to get the number of TrialObjects for this trial
    for hh = 1:length(BHV.TaskObject(BHV.ConditionNumber( correct_idx( ii ) ),...
            firstTaskObjectNum:end))                                    %from BHV.TaskObject(5:whatever the end is(it's variable from one .txt
        %file to the next))
        %don't need all TaskObjects 2xBzz of fixation Sqr & TAbutton
        if ~isempty(BHV.TaskObject{BHV.ConditionNumber( ii ),...
                hh+(firstTaskObjectNum-1)})                             %if the field in the BHV struct is NOT empty...
            trialArraySize = trialArraySize + 1;                            %increment trialArraySize by 1   
        end
    end
    
    %taskObjectInRF
    for jj = 1:trialArraySize                                               %for each TaskObject in this trial
        %regexp the TaskObject string to get the TaskObject position and
        %the image string delimted by ( and ,
        split = regexp( BHV.TaskObject{BHV.ConditionNumber( correct_idx( ii ) ),...
            (jj + (firstTaskObjectNum-1))}, '[(,)]', 'split');
        %collet the index for the images used as TargetObjects so that they
        %can be plotted in subplot 1. this is just for phun but also helps
        %to make sure things are being indexed properly
        %havent implemented; rather use simple circles in visualization
        %ta_im_idx(j) = find(arrayfun(@(x) strcmpi(BHV.Stimuli.PIC(x).Name, split(2)), 1:numel(BHV.Stimuli.PIC)));
        
        
        if split{1}(1) == 'p'                                                % pic & Sqr have X,Y coordinates in different fields
            posX = str2double(split(3));                                %X pos
            posY = str2double(split(4));                                %Y pos
            %get the polar location coordinates. does theta ==
            %RFLocationTheta. make this a new field in catSearchPHYSIOL_Info
            [ targetObjectTheta,~ ] = cart2pol( posX,posY );
            if ( RFangle - 0.01 ) < targetObjectTheta && targetObjectTheta < ( RFangle + 0.01 )
                taskObjectInRF = BHV.TaskObject{BHV.ConditionNumber( correct_idx( ii ) ),...
                    (jj + (firstTaskObjectNum-1))};
                catSearchPHYSIOL_Data( ii ).taskObjectInRF = taskObjectInRF;
            end
            
        end
        
        
    end
end
end


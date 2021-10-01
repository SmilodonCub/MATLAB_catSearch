function [ BHVNEX_infoByTrial, innSacLocANDObject,innSacLocANDObject_Counts ,arrayPos ] = catSearchPHYSIOL_analysisSpikesHIST( BHV, Catergory, trialObjectsFixated_Info, catSearchPHYSIOL_Data, eventmarkerAlignData, RFangle )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

%%INIT
%                    _           _       _____       _ _              _   _ _     _   
%                   | |         (_)     /  ___|     (_) |            | | | (_)   | |  
%   __ _ _ __   __ _| |_   _ ___ _ ___  \ `--. _ __  _| | _____  ___ | |_| |_ ___| |_ 
%  / _` | '_ \ / _` | | | | / __| / __|  `--. \ '_ \| | |/ / _ \/ __||  _  | / __| __|
% | (_| | | | | (_| | | |_| \__ \ \__ \ /\__/ / |_) | |   <  __/\__ \| | | | \__ \ |_ 
%  \__,_|_| |_|\__,_|_|\__, |___/_|___/ \____/| .__/|_|_|\_\___||___/\_| |_/_|___/\__|
%                       __/ |       ______    | |                                     
%                      |___/       |______|   |_|                                     
%                      
%   __              __  __     __          
%  / _| ___  _ __  / _\/ _| /\ \ \   
% | |_ / _ \| '__| \ \| |_ /  \/ /  
% |  _| (_) | |    _\ \  _/ /\  /  
% |_|  \___/|_|    \__/_| \_\ \/   
%                                                                         

correct_idx = find( BHV.TrialError == 0 );
num_correct = size( correct_idx, 1 );

% ArOSacbyRF = cell( [ 10,1 ] );
% ArOSacbyRF{ 5,1 } = zeros( [ 5, 1 ] );
% ArOSacbyRF{ 10,1 } = cell( [ 5, 1 ] );


%immediate saccade to the target location
imm2TargetLoc = cell( [ 10,1 ] );
imm2TargetLoc{ 5,1 } = zeros( [ 5, 1 ] );
imm2TargetLoc{ 10,1 } = cell( [ 5, 1 ] );

%immediate saccade to the target location
imm2TAButtonLoc = cell( [ 10,1 ] );
imm2TAButtonLoc{ 5,1 } = zeros( [ 5, 1 ] );
imm2TAButtonLoc{ 10,1 } = cell( [ 5, 1 ] );

% %innitial saccade by array location
% innSaccadebyLoc = cell( [ 12,1 ] );
% innSaccadebyLoc{ 6,1 } = zeros( [ 5, 1 ] );
% innSaccadebyLoc{ 12,1 } = cell( [ 5, 1 ] );

%innitital saccade organized by both location & TaskObject
innSacLocANDObject = cell( [ 10 5 ] );
%innSacLocANDObject_RXNtimes = cell( 5 );
innSacLocANDObject_Counts = zeros( 5 );

BHVNEX_infoByTrial = struct;


%target similarity if
preStimON = -1000;
postStimON = 1000;
pre1stSaccade = -1000;
post1stSaccade = 1000;


arrayPos = mod( RFangle:90:(RFangle+270), 360 );




%% sort data
SOMETHINGELSE = 0;
firstSaccNONObject = 0;
for buildHists = 1 : num_correct %for each correct trial
    %disp( buildHists ); 
    %disp( correct_idx( buildHists ) );
    BHV.TaskObject{BHV.ConditionNumber(correct_idx( buildHists )),5:end};
    BHVNEX_infoByTrial( buildHists ).ConditionNumber = BHV.ConditionNumber(correct_idx( buildHists ));
    BHVNEX_infoByTrial( buildHists ).targetPresentTRUE = BHV.InfoByCond{ BHV.ConditionNumber( correct_idx( buildHists ) ) };
%                              _      
%                             | |     
%  ___  __ _  ___ ___ __ _  __| | ___ 
% / __|/ _` |/ __/ __/ _` |/ _` |/ _ \
% \__ \ (_| | (_| (_| (_| | (_| |  __/
% |___/\__,_|\___\___\__,_|\__,_|\___|
%                                     
%
%   __ _ _ __ _ __ __ _ _   _    ___  _ __  
%  / _` | '__| '__/ _` | | | |  / _ \| '_ \ 
% | (_| | |  | | | (_| | |_| | | (_) | | | |
%  \__,_|_|  |_|  \__,_|\__, |  \___/|_| |_|
%                        __/ |              
%                       |___/               

    %was there a taskObject that was the target of the first saccade? what is it?
    %here I pull this from the trialObjectsFixated structure byt getting
    %the first field in the trialObjectsFixated( buildHists
    %).trialObjectsFixated that is a task object. some trials may be
    %dropped if the first saccade following 'preTargetON' saccades was not
    %to an array object (fixation or empty) The number of dropped trials is
    %small & usually just some weird behavior when the subject is tired or
    %shaking.
    %get taskObject of first saccade
    
    
    inclusion_numD = 50;
    [ targetsimilarity, targetsimilarity_targetID, fix_rgb, target_index_ids] = targetSimilarity( Catergory );
    [ ~, I] = sort( cell2mat( targetsimilarity( :,3:end ) ) ); %'ascending'
    targetSIM = targetsimilarity( I( end-(inclusion_numD -1):end, : ), 1 ); %#inclusion_numD most simlar for each target
    targetSIM = reshape( targetSIM, [ inclusion_numD, 10 ] );
    targetDIS = targetsimilarity( I( 1:inclusion_numD, : ), 1 ); %#inclusion_numD least similar for each target
    targetDIS = reshape( targetDIS, [ inclusion_numD, 10 ] );
    
    
    try        
    fisrtArrayObjectFixated_IDX = find( ~strcmp( trialObjectsFixated_Info( buildHists ).taskObjectsFixated, 'preTargetON' ) & ~strcmp( trialObjectsFixated_Info( buildHists ).taskObjectsFixated, 'NONfix,NONarray' )  & ~strcmp( trialObjectsFixated_Info( buildHists ).taskObjectsFixated, 'Fixation' ), 1, 'first' );
    fisrtArrayObjectFixated_TAG = trialObjectsFixated_Info( buildHists ).taskObjectsFixated{ fisrtArrayObjectFixated_IDX };
    BHVNEX_infoByTrial( buildHists ).fisrtArrayObjectFixated_Name = fisrtArrayObjectFixated_TAG;
    fisrtArrayObjectFixated_getinfoIDX = find( strcmpi(trialObjectsFixated_Info( buildHists ).taskObjectNames, fisrtArrayObjectFixated_TAG) );
    XPos = trialObjectsFixated_Info( buildHists ).taskObjectPos( fisrtArrayObjectFixated_getinfoIDX( 1 ),1 );
    YPos = trialObjectsFixated_Info( buildHists ).taskObjectPos( fisrtArrayObjectFixated_getinfoIDX( 1 ),2 );
    catch ME
        disp( ME.identifier )
    end
    
    %SEPERATE BY WHAT THE FIRST SACCADE WAS TO
    if ~strcmp( fisrtArrayObjectFixated_TAG,'NONfix,NONarray' ); %if the first Fixation was to a taskObject (and not some random spot on the screen)
        taskObjectTYPE = 0; %initialize the taskObjectType as zero 
        split = regexp( fisrtArrayObjectFixated_TAG, '[(,)]', 'split');
        if fisrtArrayObjectFixated_TAG( 1 ) == 'S'
            % IF THE 1ST SACCADE WAS TO THE TARGET ABSENT BUTTON
            disp( 'fixated Sqr object' )
            BHVNEX_infoByTrial( buildHists ).fisrtArrayObjectFixated = 5;
            %disp( buildHists )
            
            %[ targetTheta,targetRho ] = cart2pol( str2double( split( 5 ) ),str2double( split( 6 ) ) );
            taskObjectTYPE = 5;
            positionIDX = 5;
            
            % GET THE SPIKE INDECES FOR STIM & SACC ALIGNMENTS
            idxAO = find( eventmarkerAlignData( buildHists ).stimONSET_alignedSpikes >= preStimON & ...
                eventmarkerAlignData( buildHists ).stimONSET_alignedSpikes <= postStimON );
            idxS = find( eventmarkerAlignData( buildHists ).saccadeONSET_alignedSpikes >= pre1stSaccade & ...
                eventmarkerAlignData( buildHists ).saccadeONSET_alignedSpikes <= post1stSaccade);
            
            % UP THE COUNT FOR 1ST SACCADES TO ta BUTTON
%             innSacLocANDObject_Counts( positionIDX,taskObjectTYPE )...
%                 = innSacLocANDObject_Counts( positionIDX,taskObjectTYPE ) + 1;
%             % CONCATENATE THE SPIKES INTO THE 1ST SACCADE TO TA BUTTON
%             % SORTED BY LOCATION
%             innSacLocANDObject{ positionIDX,taskObjectTYPE }...
%                 = cat( 1, innSacLocANDObject{ positionIDX,taskObjectTYPE },...
%                 eventmarkerAlignData( buildHists ).stimONSET_alignedSpikes(idxAO) );
%             innSacLocANDObject{ positionIDX+5,taskObjectTYPE }...
%                 = cat( 1, innSacLocANDObject{ positionIDX+5,taskObjectTYPE },...
%                 eventmarkerAlignData( buildHists ).saccadeONSET_alignedSpikes( idxS ) );
            BHVNEX_infoByTrial( buildHists ).stimONSET_alignedSpikes = eventmarkerAlignData( buildHists ).stimONSET_alignedSpikes(idxAO);
            BHVNEX_infoByTrial( buildHists ).saccadeONSET_alignedSpikes = eventmarkerAlignData( buildHists ).saccadeONSET_alignedSpikes( idxS );
            
%             % UP THE COUNT FOR SACCADES TO TA BUTTON
%             ArOSacbyRF{ 5 }( 5 ) =  ArOSacbyRF{ 5 }( 5 ) + 1;
            
            if ~isempty( catSearchPHYSIOL_Data(buildHists).tABS_ImmediateSaccade )
                imm2TAButtonLoc{ positionIDX,1 }...
                    = cat( 1, imm2TAButtonLoc{ positionIDX,1 } , eventmarkerAlignData( buildHists ).stimONSET_alignedSpikes( idxAO ) );
                imm2TAButtonLoc{ positionIDX+5,1 }...
                    = cat( 1, imm2TAButtonLoc{ positionIDX+5,1 } , eventmarkerAlignData( buildHists ).saccadeONSET_alignedSpikes( idxS ) );
                %imm2TAButtonLoc{ 10,1 }{ positionIDX } = cat( 2, imm2TAButtonLoc{ 10,1 }{ positionIDX }, catSearchPHYSIOL_Data( buildHists ).firstSearchSaccade );
            end
            
            
        elseif fisrtArrayObjectFixated_TAG( 1 ) == 'T'
            % IF THE 1ST SACCADE WAS TO THE TARGET
            taskObjectTYPE = 1;
            BHVNEX_infoByTrial( buildHists ).fisrtArrayObjectFixated = 1;
            [ targetTheta,~ ] = cart2pol( XPos,YPos ); 
            targetDeg = mod( round( rad2deg( targetTheta ) ), 360 );
            %GET THE POSITION WITHIN THE ARRAY THAT TARGET WAS PRESENTED
            positionIDX = find( round( arrayPos,2 ) == targetDeg );
           
            % GET THE SPIKE INDECES FOR STIM & SACC ALIGNMENTS
            idxAO = find( eventmarkerAlignData( buildHists ).stimONSET_alignedSpikes >= preStimON & ...
                eventmarkerAlignData( buildHists ).stimONSET_alignedSpikes <= postStimON);
            idxS = find( eventmarkerAlignData( buildHists ).saccadeONSET_alignedSpikes >= pre1stSaccade & ...
                eventmarkerAlignData( buildHists ).saccadeONSET_alignedSpikes <= post1stSaccade);
            
            % UP THE COUNT FOR 1ST SACCADES TO A TARGET IMAGE SORTED BY
            % POSITION
%             innSacLocANDObject_Counts( positionIDX,taskObjectTYPE )...
%                 = innSacLocANDObject_Counts( positionIDX,taskObjectTYPE ) + 1; 
%             % CONCATENATE THE SPIKES BY 1ST SACCADE TO A TARGET BY POSITION
%             innSacLocANDObject{ positionIDX,taskObjectTYPE }...
%                 = cat( 1, innSacLocANDObject{ positionIDX,taskObjectTYPE },...
%                 eventmarkerAlignData( buildHists ).stimONSET_alignedSpikes( idxAO ) );
%             innSacLocANDObject{ positionIDX+5,taskObjectTYPE }...
%                 = cat( 1, innSacLocANDObject{ positionIDX+5,taskObjectTYPE },...
%                 eventmarkerAlignData( buildHists ).saccadeONSET_alignedSpikes( idxS ) );
            BHVNEX_infoByTrial( buildHists ).stimONSET_alignedSpikes = eventmarkerAlignData( buildHists ).stimONSET_alignedSpikes(idxAO);
            BHVNEX_infoByTrial( buildHists ).saccadeONSET_alignedSpikes = eventmarkerAlignData( buildHists ).saccadeONSET_alignedSpikes( idxS );            
            
            % IF THIS IS AN IMMEDIATE SACCADE TO TARGET TRIAL, CONCATENATE
            % SPIKES BY POSITION
            try
            if ~isempty( catSearchPHYSIOL_Data(buildHists).tP_ImmediateSaccade )
                imm2TargetLoc{ positionIDX,1 }...
                    = cat( 1, imm2TargetLoc{ positionIDX,1 } , eventmarkerAlignData( buildHists ).stimONSET_alignedSpikes( idxAO ) );
                imm2TargetLoc{ positionIDX+5,1 }...
                    = cat( 1, imm2TargetLoc{ positionIDX+5,1 } , eventmarkerAlignData( buildHists ).saccadeONSET_alignedSpikes( idxS ) );
                imm2TargetLoc{ 10,1 }{ positionIDX } = cat( 2, imm2TargetLoc{ 10,1 }{ positionIDX }, catSearchPHYSIOL_Data( buildHists ).firstSearchSaccade );
            end
            catch ME
                disp( 'no immediate saccades to Target this experiment')
                disp( ME.identifier )
            end
           

            
        elseif sum( sum( cellfun(@(str) any(cellfun(@(pat) any(strfind(str,pat)),{ fisrtArrayObjectFixated_TAG } )),targetSIM), 2 ), 1 ) >= 1
            % IF THE FIRST SACCADE WAS TO A 'MOST' SIMILAR D
            taskObjectTYPE = 2;
            BHVNEX_infoByTrial( buildHists ).fisrtArrayObjectFixated = 2;
            % GET THE SPIKE INDECES FOR STIM & SACC ALIGNMENTS
            idxAO = find( eventmarkerAlignData( buildHists ).stimONSET_alignedSpikes >= preStimON & ...
                eventmarkerAlignData( buildHists ).stimONSET_alignedSpikes <= postStimON);
            idxS = find( eventmarkerAlignData( buildHists ).saccadeONSET_alignedSpikes >= pre1stSaccade & ...
                eventmarkerAlignData( buildHists ).saccadeONSET_alignedSpikes <= post1stSaccade);
            [ targetTheta,~ ] = cart2pol( XPos,YPos );
            targetDeg = mod( round( rad2deg( targetTheta ) ), 360 );
            %GET THE POSITION WITHIN THE ARRAY THAT THE 'MOST' WAS PRESENTED
            positionIDX = find( round( arrayPos,2 ) == targetDeg );
            
            % CONCATENATE THE SPIKES BY 1ST SACCADE TO A 'MOST' BY POSITION
%             innSacLocANDObject_Counts( positionIDX,taskObjectTYPE )...
%                 = innSacLocANDObject_Counts( positionIDX,taskObjectTYPE ) + 1;           
%             innSacLocANDObject{ positionIDX,taskObjectTYPE }...
%                 = cat( 1, innSacLocANDObject{ positionIDX,taskObjectTYPE },...
%                 eventmarkerAlignData( buildHists ).stimONSET_alignedSpikes( idxAO ) );
%             innSacLocANDObject{ positionIDX+5,taskObjectTYPE }...
%                 = cat( 1, innSacLocANDObject{ positionIDX+5,taskObjectTYPE },...
%                 eventmarkerAlignData( buildHists ).saccadeONSET_alignedSpikes( idxS ) );
            BHVNEX_infoByTrial( buildHists ).stimONSET_alignedSpikes = eventmarkerAlignData( buildHists ).stimONSET_alignedSpikes(idxAO);
            BHVNEX_infoByTrial( buildHists ).saccadeONSET_alignedSpikes = eventmarkerAlignData( buildHists ).saccadeONSET_alignedSpikes( idxS );           
            
            
        elseif sum( sum( cellfun(@(str) any(cellfun(@(pat) any(strfind(str,pat)),{ fisrtArrayObjectFixated_TAG })),targetDIS), 2 ), 1 ) >= 1
            % IF THE 1ST SACCADE WAS TO A 'LEAST' SIMILAR D
            taskObjectTYPE = 3;
            BHVNEX_infoByTrial( buildHists ).fisrtArrayObjectFixated = 3;
            % GET THE SPIKE INDECES FOR STIM & SACC ALIGNMENTS
            idxAO = find( eventmarkerAlignData( buildHists ).stimONSET_alignedSpikes >= preStimON & ...
                eventmarkerAlignData( buildHists ).stimONSET_alignedSpikes <= postStimON);
            idxS = find( eventmarkerAlignData( buildHists ).saccadeONSET_alignedSpikes >= pre1stSaccade & ...
                eventmarkerAlignData( buildHists ).saccadeONSET_alignedSpikes <= post1stSaccade);
            [ targetTheta,~ ] = cart2pol( XPos,YPos );
             targetDeg = mod( round( rad2deg( targetTheta ) ), 360 );
             %GET THE POSITION WITHIN THE ARRAY THAT THE 'LEAST' WAS PRESENTED
             positionIDX = find( round( arrayPos,2 ) == targetDeg );
            
            % CONCATENATE THE SPIKES BY 1ST SACCADE TO A LEAST BY POSITION 
%             innSacLocANDObject_Counts( positionIDX,taskObjectTYPE )...
%                 = innSacLocANDObject_Counts( positionIDX,taskObjectTYPE ) + 1; 
%             innSacLocANDObject{ positionIDX,taskObjectTYPE }...
%                 = cat( 1, innSacLocANDObject{ positionIDX,taskObjectTYPE },...
%                 eventmarkerAlignData( buildHists ).stimONSET_alignedSpikes( idxAO ) );
%             innSacLocANDObject{ positionIDX+5,taskObjectTYPE }...
%                 = cat( 1, innSacLocANDObject{ positionIDX+5,taskObjectTYPE },...
%                 eventmarkerAlignData( buildHists ).saccadeONSET_alignedSpikes( idxS ) );
            BHVNEX_infoByTrial( buildHists ).stimONSET_alignedSpikes = eventmarkerAlignData( buildHists ).stimONSET_alignedSpikes(idxAO);
            BHVNEX_infoByTrial( buildHists ).saccadeONSET_alignedSpikes = eventmarkerAlignData( buildHists ).saccadeONSET_alignedSpikes( idxS );            
            
                    
        elseif fisrtArrayObjectFixated_TAG( 1 ) == 'D'
            % IF THE 1ST SACCADE WAS TO AN UNRANKED D
            taskObjectTYPE = 4;
            BHVNEX_infoByTrial( buildHists ).fisrtArrayObjectFixated = 4;
            % GET THE SPIKE INDECES FOR STIM & SACC ALIGNMENTS
            idxAO = find( eventmarkerAlignData( buildHists ).stimONSET_alignedSpikes >= preStimON & ...
                eventmarkerAlignData( buildHists ).stimONSET_alignedSpikes <= postStimON);
            idxS = find( eventmarkerAlignData( buildHists ).saccadeONSET_alignedSpikes >= pre1stSaccade & ...
                eventmarkerAlignData( buildHists ).saccadeONSET_alignedSpikes <= post1stSaccade);
            [ targetTheta,~ ] = cart2pol( XPos,YPos );
            targetDeg = mod( round( rad2deg( targetTheta ) ), 360 );
            %GET THE POSITION WITHIN THE ARRAY THAT THE MID-SIMILAR WAS PRESENTED
            positionIDX = find( round( arrayPos,2 ) == targetDeg );
     
            
            % CONCATENATE THE SPIKES BY 1ST SACCADE TO A MIDDLE D BY POSITION
%             innSacLocANDObject_Counts( positionIDX,taskObjectTYPE )...
%                 = innSacLocANDObject_Counts( positionIDX,taskObjectTYPE ) + 1;
%             innSacLocANDObject{ positionIDX,taskObjectTYPE }...
%                 = cat( 1, innSacLocANDObject{ positionIDX,taskObjectTYPE },...
%                 eventmarkerAlignData( buildHists ).stimONSET_alignedSpikes( idxAO ) );
%             innSacLocANDObject{ positionIDX+5,taskObjectTYPE }...
%                 = cat( 1, innSacLocANDObject{ positionIDX+5,taskObjectTYPE },...
%                 eventmarkerAlignData( buildHists ).saccadeONSET_alignedSpikes( idxS ) );
            BHVNEX_infoByTrial( buildHists ).stimONSET_alignedSpikes = eventmarkerAlignData( buildHists ).stimONSET_alignedSpikes(idxAO);
            BHVNEX_infoByTrial( buildHists ).saccadeONSET_alignedSpikes = eventmarkerAlignData( buildHists ).saccadeONSET_alignedSpikes( idxS );            
            
            
        elseif strcmp( fisrtArrayObjectFixated_TAG,'NONfix,NONarray' )
            disp('first fixation was niether to an array object nor to fixation')
            SOMETHINGELSE = SOMETHINGELSE + 1;
            disp( buildHists )
        else
            disp('SOMETHING ELSE')
            SOMETHINGELSE = SOMETHINGELSE + 1;
            disp( buildHists )
                   
        end
        
        
        %what was the object in the RF?
        for arrayTO = 1:size( BHV.TaskObject( 2 ,5:end), 2 )
            split = regexp( BHV.TaskObject{ BHV.ConditionNumber( correct_idx( buildHists ) ), ( arrayTO + 4 ) }, '[(,)]', 'split');
            [ thistheta,thisrho ] = cart2pol( str2double( split{ 3 } ),str2double( split{ 4 } ) );
            %thistheta
            Angle_TA = mod( round( rad2deg( thistheta ) ), 360 );
            %RFangle
            if Angle_TA == RFangle
                %disp('found the object in the RF')
                BHVNEX_infoByTrial( buildHists ).arrayObjectInRF = split{ 2 };
                if split{ 2 }( 1 ) == 'T'
                    BHVNEX_infoByTrial( buildHists ).arrayObjectInRF_Type = 1;
                    BHVNEX_infoByTrial( buildHists ).arrayObjectInRF_TypeName = 'Target';
                elseif split{ 2 }( 1 ) == 'D'
                    if sum( sum( cellfun(@(str) any(cellfun(@(pat) any(strfind(str,pat)),{ split{ 2 } } )),targetSIM), 2 ), 1 ) >= 1
                        %most
                        BHVNEX_infoByTrial( buildHists ).arrayObjectInRF_Type = 2;
                        BHVNEX_infoByTrial( buildHists ).arrayObjectInRF_TypeName = 'Most';
                    elseif sum( sum( cellfun(@(str) any(cellfun(@(pat) any(strfind(str,pat)),{ split{ 2 } } ) ),targetDIS), 2 ), 1 ) >= 1
                        %least
                        BHVNEX_infoByTrial( buildHists ).arrayObjectInRF_Type = 3;
                        BHVNEX_infoByTrial( buildHists ).arrayObjectInRF_TypeName = 'Least';
                    else
                        %D
                        BHVNEX_infoByTrial( buildHists ).arrayObjectInRF_Type = 4;
                        BHVNEX_infoByTrial( buildHists ).arrayObjectInRF_TypeName = 'Ave D';
                    end
                end
                BHVNEX_infoByTrial( buildHists ).RFangle = RFangle;
                
            end
        end
        
        
        
        
    end

   
    

                                                           
   
end


end


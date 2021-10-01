function [ firstSaccadeSituations ] = catSearchPHYSIOL_trialXtrial( BHV, Category, trialObjectsFixated_Info, catSearchPHYSIOL_Data, eventmarkerAlignData, BHVNEX_infoByTrial, RFangle )
%catSearchPHYSIOL_trialXtrial is a function that plots the individual trial 
%displays along with several other interesting aspects of the data.


%section2 Trial by trial data inspection                                                               %this correct counter for EyeMMV plotting
saccade_present = 0;
fig_ecc_limit = 30;
TAbutton_TaskObjectNum = 4;
targetWindowRadius = 4;
rxn_time_haztarget = NaN(size(BHV.AnalogData,2),2);
rxn_time_TOfixated = NaN(size(BHV.AnalogData,2),4);
correct_idx = find( BHV.TrialError == 0 );
num_correct = size( correct_idx, 1 );

incorrect = 0; 
correct = 0; 
fignum = 10;

global ETparams

findRF_XY_idx = find( mod( trialObjectsFixated_Info( 1 ).taskObjectPos( :,3 ), 360 ) == RFangle );
RF_XY = trialObjectsFixated_Info( 1 ).taskObjectPos( findRF_XY_idx, [ 1 2 ] );

firstSaccadeSituations = zeros( [ 4,2 ] );

for ii = 1:size(BHV.AnalogData,2)%num_trials

    %--------------------------------------------------------------------------
    % Visualize Trial
    %--------------------------------------------------------------------------
    if BHV.TrialError( ii ) == 0                                              %if the current trial is correct, do all these things

        correct = correct + 1;                                              %this is vestigial debugging.
        
                                                                            %was there a target bear present in this trial?
                                                                            %have to index InfoByCond by ConditionNumber or it all goes to hell
        haztarget = catSearchPHYSIOL_Data( correct ).haztarget;
        TObject_pos = trialObjectsFixated_Info( correct ).taskObjectPos;
        TObject_names = trialObjectsFixated_Info( correct ).taskObjectNames;
        
        
                                                                            %find the timestamp for the eventmarkers that truncate the analog
                                                                            %data from the end of fixation aquisition to the end of target hold
                                                                            %time. have to do this again cause looping over all trials not jsut correct
        fix_ON_time = BHV.CodeTimes{ii}(BHV.CodeNumbers{ii}==6);          %end initial fixation
        target_aqrd_time = BHV.CodeTimes{ii}(BHV.CodeNumbers{ii}==14);      %end target aquired time
       
        
                                                                            %format for EyeMMV package fixation detection
        data = cat(1, BHV.AnalogData{ii}.EyeSignal(fix_ON_time:target_aqrd_time,1:2)', ...
            1:size(BHV.AnalogData{ii}.EyeSignal(fix_ON_time:target_aqrd_time,1:2)',2));
                                                                            %EyeMMV
                                                                            %Krassanakis, V., Filippakopoulou, V., & Nakos, B. (2014). 
                                                                            %EyeMMV toolbox: An eye movement post-analysis tool based on a two-step 
                                                                            %spatial dispersion threshold for fixation identification. 
                                                                            %Journal of Eye Movement Research, 7(1): 1, 1-10.
        [ A, B ] =  fixation_detection_BHV(data', 2.5,2.4,50,14,14);         %EyeMMV fixation detection
        BHV.Fixations{ii} = { A B };                                        %add a field to BHV that holds the fixations
        num_fix = num2str(size(A,1));                                       %this is just to display on figure to help debug
        
        for checkCondition = 1:4
            if BHVNEX_infoByTrial( correct ).arrayObjectInRF_Type == checkCondition &&...
                    BHVNEX_infoByTrial( correct ).fisrtArrayObjectFixated == checkCondition
                firstSaccadeSituations( checkCondition, 1 ) = firstSaccadeSituations( checkCondition, 1 ) + 1;
                %disp( 'Most was in RF and Saccade was made to Most' )
            elseif BHVNEX_infoByTrial( correct ).arrayObjectInRF_Type == checkCondition &&...
                    BHVNEX_infoByTrial( correct ).fisrtArrayObjectFixated ~= checkCondition
                firstSaccadeSituations( checkCondition, 2 ) = firstSaccadeSituations( checkCondition, 2 ) + 1;
                %disp( 'Most was in RF and Saccade was made elsewhere' )
            end
            try
                if BHVNEX_infoByTrial( correct ).fisrtArrayObjectFixated == checkCondition
                    rxn_time_TOfixated( ii,checkCondition ) = eventmarkerAlignData( correct ).firstSaccadeSearchTIME;
                end
            catch ME
                disp( [ 'ERROR correct trial #' num2str( correct ) ] )
                disp( eventmarkerAlignData( correct ).firstSaccadeSearchTIME )
                disp( ME.identifier )
                disp( ME.message )
            end
        end
        %firstSaccadeSituations
        
                                                         
        fig = figure(9);                                                    %figure
        set(fig, 'Position', [50 50 1200 800])                              %figure position
        
        fixfig = subplot(3,2,[1 3]);                                        %fixation subplot == fixfig
        %TAG = regexp( BHV.TaskObject{1,6}, '[(,]', 'split')
        %find(arrayfun(@(x) strcmpi(BHV.Stimuli.PIC(x).Name, 'B_63R'), 1:numel(BHV.Stimuli.PIC)))
        set(fixfig, 'Position', [ 0.05 0.35 0.45 0.6])                      %fixfig position w/in fig     
        plot(BHV.AnalogData{ii}.EyeSignal(fix_ON_time:target_aqrd_time,1)',...
            BHV.AnalogData{ii}.EyeSignal(fix_ON_time:target_aqrd_time,2)','co')
                                                                            %plot Eyesignal data
        hold on
        %plot( eventmarkerAlignData( correct ).EyeX-1, eventmarkerAlignData( correct ).EyeY, 'mo' )
        plot( RF_XY( 1 ), RF_XY( 2 ),'o',...
            'LineStyle', 'none', 'MarkerEdgeColor',[ 0.95 0.95 0.95 ],...
            'MarkerFaceColor',[ 0.95 0.95 0.95 ],'MarkerSize',50)                    
        axis([-fig_ecc_limit fig_ecc_limit -fig_ecc_limit fig_ecc_limit])   %set fixfig limits
        title([ 'Trial: ', num2str(ii), '  BHV: ', ...
            num2str(BHV.TrialNumber(ii)) , '  Correct', num2str(correct)],...
             'FontSize', 25 )
        plot(A(:,1),A(:,2),'r+')                                            %plot the fixations
        plot(TObject_pos( 1,1 ),TObject_pos( 1,2 ),'s','LineStyle', 'none', ...
            'MarkerEdgeColor',[0.5 0.5 0.5],...
            'MarkerFaceColor',[0.5 0.5 0.5],'MarkerSize',15)                %plot the TAbutton
        plot( TObject_pos(3:end,1), TObject_pos(3:end,2),'o',...
            'LineStyle', 'none', 'MarkerEdgeColor',[1 0 0],...
            'MarkerFaceColor',[1 0 0],'MarkerSize',20)                      %plot array additional distractors
        for rr = 1:length( TObject_pos(3:end,2) )
            text( TObject_pos(2+rr,1),TObject_pos(2+rr,2),TObject_names( 2 + rr ),...
                'HorizontalAlignment','Right','VerticalAlignment','Top',...
                'FontSize',12,'Color','k')
        end
        
        
        if haztarget == '1'
            %catSearchPHYSIOL_Info(ii,7) = 1;                           %'1' for hazbear(?) and place in multi_saccade_rxn_time
            plot(TObject_pos( 2,1 ),TObject_pos( 2,2 ),'o','LineStyle', 'none', 'MarkerEdgeColor',[0 1 0],...
                'MarkerFaceColor',[0 1 0],'MarkerSize',20)                  %plot Target (Bear target is present)
            text( TObject_pos(2,1),TObject_pos(2,2),TObject_names(2),...
                'HorizontalAlignment','Right','VerticalAlignment','Top',...
                'FontSize',12,'Color','k')
            text(A(:,1),A(:,2),num2str(A(:,7)),'HorizontalAlignment',...
                'Left','VerticalAlignment','Bottom','FontSize',12,'Color','b')
            text(B(:,1),B(:,2),num2str((1:(size(B,1)))'),'HorizontalAlignment',...
                'Right','VerticalAlignment','Top','FontSize',12,'Color','m')
            text( 16, 16, [ '#fix: ' num_fix ] ,'FontSize',15,'Color','k')
            try
                rxn_time_haztarget( ii, 1 ) = eventmarkerAlignData( correct ).firstSaccadeSearchTIME;
            catch ME
                disp( 'ERROR w/ rxn_time' )
                disp( ME.identifier )
                disp( ME.message )
                if strcmp( ME.identifier, 'MATLAB:subsassigndimmismatch' )
                    rxn_time_haztarget( ii,1 ) = NaN;
                end
            end
            %text(B(:,1),B(:,2)
            %text( 3, 0, 'BEAR','FontSize',20,'Color','r')                  %put some text on the plot that tells how long fixations were,
                                                                            %how many fixations, and if there is a Bear Present. 4 debugging.

%             if size(A,1) <= 2                                               %is there were only 2 fixations & the trial was a correct one 
%                                                                             %& w/a target then the subject made a direct saccade to the target
%                 catSearchPHYSIOL_Info(ii,1) = rxn_time(ii,1);            %place this trials reaction time in immediate_saccade_rxn_time
%                 catSearchPHYSIOL_Info(ii,3) = size(A,1);
%             elseif size(A,1) > 2                                            %if there were more than 2 fixations,
%                 catSearchPHYSIOL_Info(ii,2) = rxn_time(ii,1);              %get the reaction time...
%                 catSearchPHYSIOL_Info(ii,3) = size(A,1);                   %get the number of fixations...
%             end
        elseif haztarget == '0'
            %catSearchPHYSIOL_Info(ii,7) = 0;
            plot(TObject_pos( 2,1 ),TObject_pos( 2,2 ),'o','LineStyle', 'none', 'MarkerEdgeColor',[1 0 0],...
                'MarkerFaceColor',[1 0 0],'MarkerSize',20)                  %plot Distractor (No Bear Present this trial)
            text( TObject_pos(2,1),TObject_pos(2,2),TObject_names(2),...
                'HorizontalAlignment','Right','VerticalAlignment','Top',...
                'FontSize',12,'Color','k')
            text(A(:,1),A(:,2),num2str(A(:,7)),'HorizontalAlignment',...
                'Left','VerticalAlignment','Bottom','FontSize',12,'Color','b')
            text(B(:,1),B(:,2),num2str((1:(size(B,1)))'),'HorizontalAlignment',...
                'Right','VerticalAlignment','Top','FontSize',12,'Color','b')
            %text( 3, 0, 'NO BEAR','FontSize',20,'Color','b')
            text( 16, 16, [ '#fix: ' num_fix ] ,'FontSize',15,'Color','k')
            try
                rxn_time_haztarget( ii, 2 ) = eventmarkerAlignData( correct ).firstSaccadeSearchTIME;
            catch ME
                disp( 'ERROR w/ rxn_time' )
                disp( ME.identifier )
                disp( ME.message )
                if strcmp( ME.identifier, 'MATLAB:subsassigndimmismatch' )
                    rxn_time_haztarget( ii,2 ) = NaN;
                end
            end
%             if size(A,1) <= 2
%                 catSearchPHYSIOL_Info(ii,4) = rxn_time(ii,2);
%                 catSearchPHYSIOL_Info(ii,6) = size(A,1);
%             elseif size(A,1) > 2 
%                 catSearchPHYSIOL_Info(ii,5) = rxn_time(ii,2);
%                 catSearchPHYSIOL_Info(ii,6) = size(A,1);
%             end

        end
        
        sacfig = subplot( 3,2,5);                                            %draw & position the axis for sacfig
        set(sacfig, 'Position', [0.05 0.05 0.45 0.2])
        try
        plot( eventmarkerAlignData( correct ).saccadeONSET, eventmarkerAlignData( correct ).EyeX, 'r' )
        hold on
        plot( eventmarkerAlignData( correct ).saccadeONSET, eventmarkerAlignData( correct ).EyeY, 'b' )
        %plot( eventmarkerAlignData( correct ).saccadeONSET_alignedSpikes, ( hist( eventmarkerAlignData( correct ).saccadeONSET, eventmarkerAlignData( correct ).saccadeONSET_alignedSpikes ) ), 'g' )
        plot( eventmarkerAlignData( correct ).saccadeONSET, 10*( hist( eventmarkerAlignData( correct ).saccadeONSET_alignedSpikes, eventmarkerAlignData( correct ).saccadeONSET ) ), 'g' )
        line( [ 0 0 ], [ -30 30 ], 'Color', [ 0.5 0.5 0.5 ], 'LineStyle', '--', 'LineWidth', 2 )
        stimON_X = 0 - eventmarkerAlignData( correct ).firstSaccadeSearchTIME;
        if ~isempty( stimON_X )
            line( [ stimON_X stimON_X ], [ -30 30 ], 'Color', [ 0.5 0.5 0.5 ], 'LineStyle', '--', 'LineWidth', 2 )
        else
            text( -400, 30, 'ERROR with saccade parsing' )
        end
        if length( eventmarkerAlignData( correct ).saccadeInitiationTIMES ) > 1
            for addline = 2:( length( eventmarkerAlignData( correct ).saccadeInitiationTIMES ) )
                addline_X = eventmarkerAlignData( correct ).saccadeInitiationTIMES( addline ) - eventmarkerAlignData( correct ).saccadeInitiationTIMES( 1 );
                line( [ addline_X addline_X ], [ -30 30 ], 'Color', [ 0.5 0.5 0.5 ], 'LineStyle', '--', 'LineWidth', 2 )
            end
        end
        xlim( [ -500 1500 ] )
        ylim( [ -30 30 ] )
        catch ME
            disp( ME.identifier )
            disp( ME.message )
        end
        
        
        trialInfofig = subplot( 3,2, 2 );
        title( 'some info on this trial' )
        xlim( [ 0 1 ] )
        ylim( [ 0 1 ] )
        text( 0.1, 0.9, [ '1st Task Object fixated: ' BHVNEX_infoByTrial( correct ).fisrtArrayObjectFixated_Name ] )
        text( 0.1, 0.8, [ 'Task Object in RF: ' BHVNEX_infoByTrial( correct ).arrayObjectInRF ] ) 
        text( 0.1, 0.7, [ 'Reaction time (1st saccade): ' num2str( eventmarkerAlignData( correct ).firstSaccadeSearchTIME ) ] )
        text( 0.5, 0.4, { [ 'TargetInRF Saccade2RF: ' num2str( firstSaccadeSituations( 1,1 ) ) ],...
            [ 'MostInRF Saccade2RF: ' num2str( firstSaccadeSituations( 2,1 ) ) ],...
            [ 'LeastSimInRF Saccade2RF: ' num2str( firstSaccadeSituations( 3,1 ) ) ],...
            [ 'AverageInRF Saccade2RF: ' num2str( firstSaccadeSituations( 4,1 ) ) ] },...
            'HorizontalAlignment', 'right' )
        text( 1, 0.4, { [ 'TargetInRF SaccadeOut: ' num2str( firstSaccadeSituations( 1,2 ) ) ],...
            [ 'MostInRF SaccadeOut: ' num2str( firstSaccadeSituations( 2,2 ) ) ],...
            [ 'LeastInRF SaccadeOut: ' num2str( firstSaccadeSituations( 3,2 ) ) ],...
            [ 'AverageInRF SaccadeOut: ' num2str( firstSaccadeSituations( 4,2 ) ) ] },...
            'HorizontalAlignment', 'right' ) 
        text( 0.1, 0.1, [ 'Total number of Trials: ' num2str( sum( sum( firstSaccadeSituations ) ) ) ],...
            'HorizontalAlignment', 'left' )
        axis off
        box off
        
        
        rxnfig_TOfixation = subplot( 3,2,4 );
        %set(rxnfig_TOfixation, 'Position', [0.55 0.05 0.4 0.2])
        histogram( rxn_time_TOfixated( :,1 ), 0:10:BHV.VariableChanges.max_reaction_time.Value );
        hold on
        histogram( rxn_time_TOfixated( :,2 ), 0:10:BHV.VariableChanges.max_reaction_time.Value );
        histogram( rxn_time_TOfixated( :,3 ), 0:10:BHV.VariableChanges.max_reaction_time.Value );
        histogram( rxn_time_TOfixated( :,4 ), 0:10:BHV.VariableChanges.max_reaction_time.Value );
%         [ n2, x2 ] = hist(rxn_time( :,2 ), 0:5:BHV.VariableChanges.max_reaction_time.Value,...
%             'stacked', 'barwidth', 20 );
%         bh1 = bar( x1, n1, 'facecolor', 'r' );
%         bh2 = bar( x2, n2, 'facecolor', 'b' );
        title({'Reaction Times (Correct Trials Only)','first task object fixated'})
        legend('Target', 'Most Sim', 'Least Sim', 'Average')
        xlim([0 700])
        ylim( [ 0 30 ] )
        
        
        rxnfig_haztarget = subplot(3,2,6);
        set(rxnfig_haztarget, 'Position', [0.55 0.05 0.4 0.2])
        histogram( rxn_time_haztarget( :,1 ), 0:5:BHV.VariableChanges.max_reaction_time.Value );
        hold on
        histogram( rxn_time_haztarget( :,2 ), 0:5:BHV.VariableChanges.max_reaction_time.Value );
%         [ n2, x2 ] = hist(rxn_time( :,2 ), 0:5:BHV.VariableChanges.max_reaction_time.Value,...
%             'stacked', 'barwidth', 20 );
%         bh1 = bar( x1, n1, 'facecolor', 'r' );
%         bh2 = bar( x2, n2, 'facecolor', 'b' );
        title( {'Reaction Times (Correct Trials Only)','Target Present/Absent'})
        legend('Target', 'No Target')
        xlim([0 700])
        ylim( [ 0 30 ] )
        
        
        pause( 0.1 )
        
        if correct < num_correct
            cla( trialInfofig )
        end
        
        
    end
    

end
        
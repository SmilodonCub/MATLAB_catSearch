function [ cellType, visuoMovement_Index] = delayedSaccadePLOT_BatchData( unitName, thisTrialInterval, BHV_DS,eachTrackBool )
%delayedSaccadePLOT this function will take in the trialInterval structure
%and .bhv struct to make a raster/histogram plot of the delayedSaccade 
%trials for cell classification. Additionally, the variable
%StimON_windowsize and Saccade_windowsize set the size (ms) of the windows
%to find the max response after the stimulus onset or before the saccade
%innitiation. Typically 100ms for StimON and 50ms for Saccade. The input
%argument 'eachTrackBool' can be '1' if you'd like see the eyetrace alignments 
%for all trails overlaid uncomment code to see each saccade profile 
%individually plotted with the spike train alignment (useful for
%debugging)

clear ETparams
clear ETdata

%% init & Adaptive Event Detection

trialInterval = thisTrialInterval.trialInterval;
%trialInterval
%BHV_DS = thisBHV_DS_file;
global ETparams  
%how many correct trials were in this .bhv
correct_idx = find( BHV_DS.TrialError == 0 );                                               
num_correct = length(correct_idx);
%these eventmarkers are used by functions that handle eyeLink & spike 
%alignments to behavioral eventmarkers for the delayed saccade task
fixation_EventMarker = 2;
delay_EventMarker = 46;
stimON_EventMarker = 555;


%% 1 ADAPTIVE EVENT DETECTION
% used to get saccade detection info

%--------------------------------------------------------------------------
% Condition BHV Eye Signal Data
%--------------------------------------------------------------------------
%truncate analog data from the end of fixation hold time 
 %to the end of target hold time and
 %hold values in ETdata struct. 
for ii= 1:num_correct
 %find the time of the eventmarker(6) -> successful fixation
 %hold timeaquired
    fix_ON_time = BHV_DS.CodeTimes{correct_idx(ii)}(BHV_DS.CodeNumbers{correct_idx(ii)}==2);
 %find time of successful target hold time
    target_aqrd_time = BHV_DS.CodeTimes{correct_idx(ii)}(BHV_DS.CodeNumbers{correct_idx(ii)}==13);
 %ETdata is a struct that will hold analog X Y coordinates
 %of Eye position data truncated from the successful fixation 
 %hold to the end of target hold
    ETdata(ii).X = BHV_DS.AnalogData{correct_idx(ii)}.EyeSignal(fix_ON_time:target_aqrd_time,1)';
    ETdata(ii).Y = BHV_DS.AnalogData{correct_idx(ii)}.EyeSignal(fix_ON_time:target_aqrd_time,2)';
    ETdata(ii).fixTime = fix_ON_time;
    ETdata(ii).targetTime = target_aqrd_time;
end
%  

%--------------------------------------------------------------------------
% Init Event Detection parameters
%--------------------------------------------------------------------------


ETparams.data = ETdata;                                                     %pass on the truncated eye movement data
ETparams.screenSz = [BHV_DS.ScreenXresolution BHV_DS.ScreenYresolution];    %from BHV file, pass Screen resolution
ETparams.screenDim = [0.4064 0.3048];                                       %have no idea why this isn't in the BHV file
                                                                            %these are screen dimensions of the in use Dell screen 
                                                                            %in 1701. [ width height ] in m.
ETparams.viewingDist = BHV_DS.ViewingDistance;                              %pass on from BHV file
ETparams.samplingFreq = BHV_DS.AnalogInputFrequency;                        %pass on from BHV file
ETparams.blinkVelocityThreshold = 1000;                                     %if vel > 1000 degrees/s, it is noise or blinks
ETparams.blinkAccThreshold = 100000;                                        %if acc > 100000 degrees/s^2, it is noise or blinks
ETparams.peakDetectionThreshold = 0.12;                                     %Initial value of the peak detection threshold. 
ETparams.minFixDur = 0.03;                                                  %in seconds
ETparams.minSaccadeDur = 0.010;                                             %in seconds


%--------------------------------------------------------------------------
% RUN Adaptive_Event_Detection
%--------------------------------------------------------------------------
 %event detection algorithm accompanying the article
 %Nyström, M. & Holmqvist, K. (in press), 
 %"An adaptive algorithm for fixation, saccade, 
 %and glissade detection in eye-tracking data". 
 %Behavior Research Methods

eventDetection; %run event detection



preStimOn = -1000;
postStimOn = 1000;
StimOnStep = 1;
preSaccadeOnset = -1000;
postSaccadeOnset = 1000;
SaccadeStep = 1;
preDelay = -1000;
postDelay = 1000;
DelayStep = 1;
fs = 1000;
sigma = 2;
numTrials = size( trialInterval.trialSpikesTimes_StimOnDS,2 );
binsStimOn = preStimOn:StimOnStep:postStimOn;
binsSaccadeOnset = preSaccadeOnset:SaccadeStep:postSaccadeOnset;
binsDelay = preDelay:DelayStep:postDelay;


%% spike alignments

%get indexes for the correct trials in delayedSacadeBHV     length( find( delayedSacadeBHV.TrialError == 0 ) )
correctDS_idx = find( BHV_DS.TrialError == 0 );
numDStrials = size(  trialInterval.trialSpikesTimes_DS,2 );
SaccadeONSETS = zeros( numDStrials,1 );
SaccadeONSETs_eyedata = cell( 3,numDStrials ); %this is just to plot the saccade onset aligned eyedata to visualize & make sure that alignment is OKay
StimONSETs_eyedata = cell( 4,numDStrials );
SaccadeONSET_spikes = [];
StimONSET_spikes = [];
DelayEND_spikes = [];


for m = 1:numTrials
    %m = 1;
    BHV_DS.CodeNumbers{ correctDS_idx( m ) };
    %get the time relative to the BHV file when FixON (event2)
    fixON_idx = find( BHV_DS.CodeNumbers{ correctDS_idx( m ) } == fixation_EventMarker );
    fixON_time_ms = BHV_DS.CodeTimes{ correctDS_idx( m ) }( fixON_idx );
    
    %find the BHV relative time of this trials event46 This is when the
    %fixation extinguishes as the cue to make a saccade to the target
    delayEND_idx = find( BHV_DS.CodeNumbers{ correctDS_idx( m ) } == delay_EventMarker );
    delayEND_time_ms = BHV_DS.CodeTimes{ correctDS_idx( m ) }( delayEND_idx );
    
    %get the time relative to the BHV file when StimON (event555)
    targetON_idx = find( BHV_DS.CodeNumbers{ correctDS_idx( m ) } == stimON_EventMarker );
    targetON_time_ms = BHV_DS.CodeTimes{ correctDS_idx( m ) }( targetON_idx );
    
    %FIND THE ONSET OF THE 1ST SACCADE AFTER THE TARGET GOES ON.
    found1saccadeYET = 0;
    %while we haven't found the first saccade that occured after the
    %targetON_time_ms

    for saccadeSTEP = 1:size( ETparams.saccadeInfo, 3 )
        %saccadeSTEP
         if found1saccadeYET == 0;
         %saccadeSTEP;
         sacstart = ( ETparams.saccadeInfo( 1, m, saccadeSTEP ).start )*1000;
         dif = targetON_time_ms - fixON_time_ms;
    %go through the saccades: for each saccade, find the saccade start time relative to ETparams
            %if the saccade time is > ( targetON_time - fixON ) this equals the saccade onset
            if  sacstart > dif
                %i subtract fixON_time_ms here because the eye trace data had been clipped starting at fixON_time_ms
                saccadeSTART_time_ms = ( ETparams.saccadeInfo( 1, m, saccadeSTEP ).start )*1000 + fixON_time_ms;
                SaccadeONSETS( m ) = saccadeSTART_time_ms;
                EyeData_t = 1:length( BHV_DS.AnalogData{ correctDS_idx( m ) }.EyeSignal );
                EyeData_saccadeONSET = EyeData_t - saccadeSTART_time_ms;
                found1saccadeYET = 1;
                %found1saccadeYET
            end
        end
    end
    
    
    %EyeData_t = 1:length( delayedSacadeBHV.AnalogData{ correctDS_idx( m ) }.EyeSignal );
    %EyeData_talign13 = EyeData_t - align13_time_ms;
    
    %FIND THE INTERVAL OF SPIKE DATA THAT WE NEED
    
    %if there are spikes for this correct trial
    %find the index for the first Strobed timestamp that is greater than the value of the first spike timestamp of this trial minus a 1.5sec buffer
    %find the index for the last Strobed timestamp that is less than the
    %value of the last spike timestamp of this trial plus a 1.5 sec buffer
    try
        spike1_idx = find( trialInterval.Strobed( :,1 ) > trialInterval.trialSpikesTimes_DS{ m }( 1 )-1.5 , 1, 'first'  ); %-1.5 is added as a buffer for sparse motor cells
        thisstart = trialInterval.trialSpikesTimes_DS{ m }( 1 )-1.5;
        spikeLAST_idx = find( trialInterval.Strobed( :,1 ) < trialInterval.trialSpikesTimes_DS{ m }( end ) + 1.5 , 1, 'last' ); %1.5 is added as a buffer for sparse visual cells
        thisend = trialInterval.trialSpikesTimes_DS{ m }( end ) + 1.5;
        thisave = ( thisstart + thisend )/2;
        %trialInterval.Strobed( spike1_idx:spikeLAST_idx,2 ); %output the eventmarkers in the interval spike1_idx:spikeLAST_idx
        %stimON555 = find the time (sec) for this trial's '555' event where 555 ==
        %Stim ON. +spike1_idx-1 to give the overall index
        stimON555 = trialInterval.Strobed( find( trialInterval.Strobed( spike1_idx:spikeLAST_idx,2 ) == 555 ) + spike1_idx - 1 , 1);
        if length( stimON555 ) ~= 1
            %everyonce in a while the window that is used to find the
            %stimulus Onset event marker comes back with 2 strobed events.
            %this can happen when the previous trial was aborted after the
            %stimulus flashed. I use the window average to find the correct
            %disp( length( stimON555 ) )
            %stimON555
            %thisave
            [ closest, cIDX ] = min( abs( stimON555 - thisave ) );
            %cIDX
            stimON555 = stimON555( cIDX );
            warningMessage =  [ 'Two Stim ON event selected trial#' num2str( m )  ' using trial time ave to parse correct one' ];
            warning( warningMessage )
        end
        %now subtract the stimON555 time from the SpikeTimes_DS for this trial
        %& *1000 to give the Stimulus Onset adjusted spike times in msec
        %trialInterval.trialSpikesTimes_DS{ m }
        SPIKES_stimONAlign = ( trialInterval.trialSpikesTimes_DS{ m } - stimON555 ).*1000;
        %find the difference between the eyelink555 and the saccadeOnset then
        %use this amount to adjust the spike alignment
        Stim2SaccONSET_interval = saccadeSTART_time_ms - ( targetON_time_ms );
        SPIKES_saccadeONAlign = SPIKES_stimONAlign - Stim2SaccONSET_interval;
        SaccadeONSETs_eyedata( 1,m ) = { EyeData_saccadeONSET }; %Again, this is just to visualize if the saccade alignment is working
        SaccadeONSETs_eyedata( 2,m ) = { BHV_DS.AnalogData{ correctDS_idx( m ) }.EyeSignal( :, 1 ) };
        SaccadeONSETs_eyedata( 3,m ) = { BHV_DS.AnalogData{ correctDS_idx( m ) }.EyeSignal( :, 2 ) };
        SaccadeONSETs_eyedata( 4,m ) = { SPIKES_saccadeONAlign };
        SaccadeONSET_spikes = cat( 1,SaccadeONSET_spikes, SPIKES_saccadeONAlign );
        
        stimON_time_ms = targetON_time_ms + fixON_time_ms;
        EyeData_stimONSET = EyeData_t - stimON_time_ms;
        StimONSETs_eyedata( 1,m ) = { EyeData_stimONSET }; %Again, this is just to visualize if the saccade alignment is working
        StimONSETs_eyedata( 2,m ) = { BHV_DS.AnalogData{ correctDS_idx( m ) }.EyeSignal( :, 1 ) };
        StimONSETs_eyedata( 3,m ) = { BHV_DS.AnalogData{ correctDS_idx( m ) }.EyeSignal( :, 2 ) };
        StimONSETs_eyedata( 4,m ) = { SPIKES_stimONAlign };
        StimONSET_spikes = cat( 1, StimONSET_spikes, SPIKES_stimONAlign );
        
        %find the difference between the delay end period and the StimulusON &
        %use this amount to adjust the StimON spike alignment
        Stim2DellayEND_interval = delayEND_time_ms - ( targetON_time_ms );
        SPIKES_delayEND = SPIKES_stimONAlign - Stim2DellayEND_interval;
        DelayEND_eyedata( 1,m ) = { SPIKES_delayEND };
        DelayEND_spikes = cat( 1, DelayEND_spikes, SPIKES_delayEND );
    catch ME
        if strcmp( ME.identifier, 'MATLAB:UndefinedFunction' )
            warningMessage = ['Saccade was not parsed for trial#' num2str( m ) ];
            warning( warningMessage )
        end
        disp( ME.identifier )
        disp( ME.message )
    end
    
end

% %PLOT THE X,Y EYEDATA ALIGNED BY EACH TRIALS SACCADE ONSET
%%

if eachTrackBool
    % %PLOT THE X,Y EYEDATA ALIGNED BY EACH TRIALS STIMULUS ONSET
%     for align_plot = 1:numDStrials
%         figure
%         
%         subplot( 1,2,1 )
%         plot( StimONSETs_eyedata{ 1, align_plot }, StimONSETs_eyedata{ 2,align_plot } );
%         hold on
%         plot( StimONSETs_eyedata{ 1, align_plot }, StimONSETs_eyedata{ 3,align_plot } );
%         %plot( StimONSETs_eyedata{ 1, align_plot }, 10*StimONSETs_eyedata{ 4, align_plot }, 'g' )
%         plot( StimONSETs_eyedata{ 1, align_plot }, 10*( hist( StimONSETs_eyedata{ 4,align_plot },StimONSETs_eyedata{ 1,align_plot } ) ), 'g' )
%         line( [ 0 0 ], [ -10 10 ] )
%         hold off
%         
%         subplot( 1,2,2 )
%         plot( SaccadeONSETs_eyedata{ 1, align_plot }, SaccadeONSETs_eyedata{ 2,align_plot } );
%         hold on
%         plot( SaccadeONSETs_eyedata{ 1, align_plot }, SaccadeONSETs_eyedata{ 3,align_plot } );
%         plot( SaccadeONSETs_eyedata{ 1, align_plot }, 10*( hist( SaccadeONSETs_eyedata{ 4,align_plot },SaccadeONSETs_eyedata{ 1,align_plot } ) ), 'g' )
%         line( [ 0 0 ], [ -10 10 ] )
%         hold off
%         
%     end
    
    figure;
    plot( StimONSETs_eyedata{ 1, 1 }, StimONSETs_eyedata{ 2,1 }, 'r' );
    hold on
    plot( StimONSETs_eyedata{ 1, 1 }, StimONSETs_eyedata{ 3,1 }, 'magenta' );
    for stimalignFigIDX = 2:numDStrials
        plot( StimONSETs_eyedata{ 1, stimalignFigIDX }, StimONSETs_eyedata{ 2,stimalignFigIDX }, 'r' );
        plot( StimONSETs_eyedata{ 1, stimalignFigIDX }, StimONSETs_eyedata{ 3,stimalignFigIDX }, 'magenta' );
    end
    line( [ 0 0 ], [ -30 30 ], 'LineStyle', ':', 'Color', 'r' )
    xlim( [ -500 1500 ] );
    xlabel( 'time (ms)' );
    ylim( [ -30 30 ] );
    ylabel( 'Eyetrace (dva)' )
    title( 'Stimulus Onset' )
    text( -400, 28, 'X eye', 'Color', 'r' )
    text( -400, 26, 'Y eye', 'Color', 'magenta' )    
    hold off
    
    figure;
    plot( SaccadeONSETs_eyedata{ 1, 1 }, SaccadeONSETs_eyedata{ 2,1 }, 'b' );
    hold on
    plot( SaccadeONSETs_eyedata{ 1, 1 }, SaccadeONSETs_eyedata{ 3,1 }, 'cyan' );
    for saccalignFigIDX = 2:numDStrials
        plot( SaccadeONSETs_eyedata{ 1, saccalignFigIDX }, SaccadeONSETs_eyedata{ 2,saccalignFigIDX }, 'b' );
        plot( SaccadeONSETs_eyedata{ 1, saccalignFigIDX }, SaccadeONSETs_eyedata{ 3,saccalignFigIDX }, 'cyan' );
    end
    line( [ 0 0 ], [ -30 30 ], 'LineStyle', ':', 'Color', 'b'  )
    xlim( [ -500 1500 ] );
    xlabel( 'time (ms)' );
    ylim( [ -30 30 ] );
    title( 'Initial Saccade Start' )
    text( -400, 28, 'X eye', 'Color', 'b' )
    text( -400, 26, 'Y eye', 'Color', 'cyan' )    
    hold off
   
end


%% pull out the important stuff



windowStimOnset = find( preStimOn < StimONSET_spikes & StimONSET_spikes < postStimOn );
histStimONSET = histc( StimONSET_spikes( windowStimOnset ), binsStimOn );
windowSaccadeOnset = find( preSaccadeOnset < SaccadeONSET_spikes & SaccadeONSET_spikes < postSaccadeOnset );
histSaccadeONSET = histc( SaccadeONSET_spikes( windowSaccadeOnset ), binsSaccadeOnset );
windowDelayEND = find( preDelay < DelayEND_spikes & DelayEND_spikes < postDelay );
histDelayEND = histc( DelayEND_spikes( windowDelayEND ), binsDelay );
StimOnSmoothed = gauss( sigma, 1000, histStimONSET/numDStrials/StimOnStep/1000*fs );
SaccadeSmoothed = gauss( sigma, 1000, histSaccadeONSET/numDStrials/SaccadeStep/1000*fs );
DelayENDSmoothed = gauss( sigma, 1000, histDelayEND/numDStrials/DelayStep/1000*fs );


maxmaxg = max( [ max( StimOnSmoothed ) max( SaccadeSmoothed ) max( DelayENDSmoothed ) ] );


%meanFixation = the mean discharge rate during the 300 ms epoch w/in the
%fixation periodand 500-200ms before the target presentation
meanFix_IDX_start = find( binsStimOn == -500 );
meanFix_IDX_end = find( binsStimOn == -200 );
meanFix_window = StimOnSmoothed( meanFix_IDX_start:meanFix_IDX_end );
meanFixation = mean( meanFix_window );

%meanStimulusOnset = the mean discharge rate during the 50 - 150 ms
%interval after stimulus onset
meanStimON_IDX_start = find( binsStimOn == 50 );
meanStimON_IDX_end = find( binsStimOn == 150 );
meanStimON_window = StimOnSmoothed( meanStimON_IDX_start:meanStimON_IDX_end );
meanStimON = mean( meanStimON_window );
%peakVisual = max discharge rate during the meanStimulusOnset interval
maxStimON = max( meanStimON_window );
maxStimONX = binsStimOn( StimOnSmoothed == maxStimON );

%meanDelayActivity = mean dischrage rate during the last 300ms of the delay
%period's end
meanDelayAct_IDX_start = find( binsDelay == -300 );
meanDelayAct_IDX_end = find( binsDelay == 0 );
meanDelayAct_window = DelayENDSmoothed( meanDelayAct_IDX_start:meanDelayAct_IDX_end );
meanDelayAct = mean( meanDelayAct_window );

%meanPreSaccade = the mean discharge rate during the last 100ms before
%saccade onset
saccade_windowIDX_start = find( binsSaccadeOnset == -100 );
saccade_windowIDX_end = find( binsSaccadeOnset == 0 );
PreSaccade_window = SaccadeSmoothed( saccade_windowIDX_start:saccade_windowIDX_end );
maxSaccade = max( PreSaccade_window );
maxSaccadeX = binsSaccadeOnset(  SaccadeSmoothed == maxSaccade  );
meanSaccade = mean(  PreSaccade_window );


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%characterize this cell
disp( 'Cell Characterization ' )
%Is the StimON mean significantly different from the Fixation mean? P<0.05
%Wilcoxon signed rank test
RandommeanFix_window = meanFix_window( randi( size( meanFix_window,1 ), size( meanStimON_window ) ) );
[ visres_p, visres_h ] = ranksum( RandommeanFix_window, meanStimON_window, 'tail', 'left' );
if visres_h
    disp( visres_p )
    disp('Significant Visual Response')
elseif ~visres_h
    disp( visres_p )
    disp('No Sig Visual')
end

%Is the Presaccade Activity Significantly greater than the delay activity?
%P<0.05 Wilcoxon rank sum test?
RandommeanDelayAct = meanDelayAct_window( randi( size( meanDelayAct_window,1 ), size( PreSaccade_window ) ) );
[ motres_p, motres_h ] = ranksum( RandommeanDelayAct, PreSaccade_window, 'tail', 'left'  );
if motres_h
    disp( motres_p )
    disp('Significant Motor Response')
elseif ~motres_h
    disp( motres_p )
    disp('No Sig Motor')
end

%Is the Delay activity significantly different than the fixation/baseline
%activity? P<0.05 Wilcoxon rank sum test?
[ delayres_p, delayres_h ] = signrank( meanFix_window, meanDelayAct_window, 'tail', 'left'  );
if delayres_h
    disp( delayres_p )
    disp('Significant Delay Response')
elseif ~delayres_h
    disp( delayres_p )
    disp('No Sig Delay')    
end

disp( ' ' )

if visres_h && motres_h && delayres_h
    cellType_str = 'This is a Visuo-Movement Prelude Neuron';
    cellType = 'Visuo-Movement Prelude Neuron';
elseif visres_h && motres_h && ~delayres_h
    cellType_str = 'This is a Visuo-Movement Burst Neuron';
    cellType = 'Visuo-Movement Burst Neuron';
elseif visres_h && ~motres_h && delayres_h
    cellType_str = 'This is a Tonic Visual Neuron';
    cellType = 'Tonic Visual Neuron';
elseif visres_h && ~motres_h && ~delayres_h
    cellType_str = 'This is a Phasic Visual Neuron';
    cellType = 'Phasic Visual Neuron';
elseif ~visres_h && motres_h && ~delayres_h
    cellType_str = 'This is a Movement Neuron';
    cellType = 'Movement Neuron';
end

%VisuoMovement Index = (vis - mov )/(vis + mov)
%this is an index to quantify the relative magnitude of visual & movement
%activity where vis == the peak activity during the Stimulus Onset interval
%and mov == the peak activity during the preSaccadic interval.

visuoMovement_Index = ( maxStimON - maxSaccade )/( maxStimON + maxSaccade );
%
%%
%plot plot plot

labelFontSize = 13;
numTrials = 10;

fig = figure;
set(gcf,'color','w');
set(fig, 'Position', [50 50 1200 800])
subplot( 2,3,1 )
patch( [ binsStimOn( meanStimON_IDX_start )+5, binsStimOn( meanStimON_IDX_start )+5, binsStimOn( meanStimON_IDX_end ), binsStimOn( meanStimON_IDX_end ) ],...
    [ numTrials, 0, 0, numTrials ], [ 0.9 0.9 0.9 ], 'EdgeColor', [ 0.9 0.9 0.9 ] );
hold on
patch( [ binsStimOn( meanFix_IDX_start )+5, binsStimOn( meanFix_IDX_start )+5, binsStimOn( meanFix_IDX_end ), binsStimOn( meanFix_IDX_end ) ],...
    [ numTrials, 0, 0, numTrials ], [ 0.9 0.9 0.9 ], 'EdgeColor', [ 0.9 0.9 0.9 ] );
plot( StimONSETs_eyedata{ 4,1 }, ones( size( StimONSETs_eyedata{ 4,1 },1 ),1 ),'.',...
    'MarkerSize',5, 'MarkerEdgeColor',[ 0.5 0.5 0.5 ] , 'MarkerFaceColor', 'none' ) 
for m = 2:numTrials
    plot( StimONSETs_eyedata{ 4,m }, m.*ones( size( StimONSETs_eyedata{ 4,m },1 ),1 ),'.', ...
    'MarkerSize',5, 'MarkerEdgeColor',[ 0.5 0.5 0.5 ] , 'MarkerFaceColor', 'none' )
end
line( [ 0 0 ], [ 0 numTrials ],'Color','red','LineStyle','--','LineWidth',2 )
line( [ -500 -500 ], [ 0 12 ], 'Color', 'k' )
text( 0, 20, 'Stimulus Onset', 'FontSize', 15, 'FontWeight', 'bold', 'HorizontalAlignment', 'center' )
ylim( [ 0 40 ] )
xlim( [ -500 500 ] )
%title( 'Stimulus Onset' )
xlabel( 'time ( s )' )
% yll =ylabel( 'trial num' );
% set( yll, 'position', [ -622.3958  4 ] );
text( -550, 1, 'Trial num', 'Rotation', 90, 'HorizontalAlignment', 'left', 'VerticalAlignment', 'bottom', 'FontSize', labelFontSize )
%text( -525, 5, '5', 'HorizontalAlignment', 'right' )
%text( -525, 10, '10', 'HorizontalAlignment', 'right' )
box off
axis off

subplot( 2,3,2 )
patch( [ binsDelay( meanDelayAct_IDX_start )+5, binsDelay( meanDelayAct_IDX_start )+5, binsDelay( meanDelayAct_IDX_end ), binsDelay( meanDelayAct_IDX_end ) ],...
    [ numTrials, 0, 0, numTrials ], [ 0.9 0.9 0.9 ], 'EdgeColor', [ 0.9 0.9 0.9 ] );
hold on
plot( DelayEND_eyedata{ 1,1 }, ones( size( DelayEND_eyedata{ 1,1 },1 ),1 ),'.',...
    'MarkerSize',5, 'MarkerEdgeColor',[ 0.5 0.5 0.5 ] , 'MarkerFaceColor', 'none' ) 
for m = 2:numTrials
    plot( DelayEND_eyedata{ 1,m }, m.*ones( size( DelayEND_eyedata{ 1,m },1 ),1 ),'.', ...
    'MarkerSize',5, 'MarkerEdgeColor',[ 0.5 0.5 0.5 ] , 'MarkerFaceColor', 'none' )
end
line( [ 0 0 ], [ 0 numTrials ],'Color','red','LineStyle','--','LineWidth',2 )
text( 0, 20, 'Delay Period (end)', 'FontSize', 15, 'FontWeight', 'bold', 'HorizontalAlignment', 'center' )
ylim( [ 0 40 ] )
xlim( [ -500 500 ] )
%title( 'Delay Period (~Sacc)' )
xlabel( 'time ( s )' )
ylabel( 'trial num' )
box off
axis off


subplot( 2,3,3 )
patch( [ binsSaccadeOnset( saccade_windowIDX_start )+5, binsSaccadeOnset( saccade_windowIDX_start )+5, binsSaccadeOnset( saccade_windowIDX_end ), binsSaccadeOnset( saccade_windowIDX_end ) ],...
    [ numTrials, 0, 0, numTrials ], [ 0.9 0.9 0.9 ], 'EdgeColor', [ 0.9 0.9 0.9 ] );
hold on
plot( SaccadeONSETs_eyedata{ 4,1 }, ones( size( SaccadeONSETs_eyedata{ 4,1 },1 ),1 ),'.',...
    'MarkerSize',5, 'MarkerEdgeColor',[ 0.5 0.5 0.5 ] , 'MarkerFaceColor', 'none' ) 
for m = 2:numTrials
    plot( SaccadeONSETs_eyedata{ 4,m }, m.*ones( size( SaccadeONSETs_eyedata{ 4,m },1 ),1 ),'.', ...
    'MarkerSize',5, 'MarkerEdgeColor',[ 0.5 0.5 0.5 ] , 'MarkerFaceColor', 'none' )
end
line( [ 0 0 ], [ 0 numTrials ],'Color','red','LineStyle','--','LineWidth',2 )
text( 0, 20, 'Saccade Innitiation', 'FontSize', 15, 'FontWeight', 'bold', 'HorizontalAlignment', 'center' )
ylim( [ 0 40 ] )
xlim( [ -500 500 ] )
%title( 'Target Acquired (~Sacc)' )
xlabel( 'time ( s )' )
ylabel( 'trial num' )
box off
axis off


subplot( 2,3,4 )
patch( [ binsStimOn( meanFix_IDX_start )+5, binsStimOn( meanFix_IDX_start )+5, binsStimOn( meanFix_IDX_end ), binsStimOn( meanFix_IDX_end ) ],...
    [ maxmaxg, 5, 5, maxmaxg ], [ 0.9 0.9 0.9 ], 'EdgeColor', [ 0.9 0.9 0.9 ] );
hold on
patch( [ binsStimOn( meanStimON_IDX_start ), binsStimOn( meanStimON_IDX_start ), binsStimOn( meanStimON_IDX_end ), binsStimOn( meanStimON_IDX_end ) ],...
    [ maxmaxg, 5, 5, maxmaxg ], [ 0.9 0.9 0.9 ], 'EdgeColor', [ 0.9 0.9 0.9 ] );
line( [ 0 0 ], [ 0 maxmaxg ], 'Color','red','LineStyle','--','LineWidth',2 )
plot( binsStimOn,StimOnSmoothed,'Color','red','LineStyle','-', 'LineWidth', 2 )
plot( maxStimONX, maxStimON, 'bo','MarkerSize',4,'MarkerEdgeColor','k','MarkerFaceColor','k' )
%text( binsStimOn( stimON_windowIDX_start ) , ( maxStimON + 40 ), [ 'StimON Max = ' num2str( round( maxStimON ) ) ] )
text( binsStimOn( meanStimON_IDX_end ) ,  maxStimON, { 'StimON', 'Max' }, 'VerticalAlignment', 'middle', 'FontSize', labelFontSize )
line( [ binsStimOn( meanFix_IDX_start ) binsStimOn( meanFix_IDX_end ) ] , [ meanFixation meanFixation ], 'Color',[ 0.5 0.5 0.5 ] ,'LineStyle',':','LineWidth',2  )
%text( binsStimOn( meanFix_IDX_start ) , ( meanFixation+ 40 ), [ 'Fix Mean = ' num2str( round( meanFixation ) ) ] )
text( ( binsStimOn( meanFix_IDX_start ) + binsStimOn( meanFix_IDX_end ) )/2 , ( 100 ), 'Fix Mean', 'HorizontalAlignment', 'center', 'FontSize', labelFontSize )
line( [ binsStimOn( meanStimON_IDX_start ) binsStimOn( meanStimON_IDX_end ) ] , [ meanStimON meanStimON ], 'Color',[ 0.5 0.5 0.5 ],'LineStyle',':','LineWidth',2  )
%text( binsStimOn( meanStimON_IDX_start ) , ( meanStimON+ 40 ), [ 'StimON Mean = ' num2str( round( meanStimON ) ) ] )
text( ( binsStimOn( meanStimON_IDX_start ) -20 ), ( meanStimON ), { 'StimON', 'Mean' },'HorizontalAlignment', 'right', 'VerticalAlignment', 'middle' , 'FontSize', labelFontSize )
text( ( binsStimOn( meanStimON_IDX_start ) + binsStimOn( meanStimON_IDX_end ) )/2 , ( maxmaxg + 100 ), { 'Stim Onset', 'Interval' }, 'Color', 'r', 'HorizontalAlignment', 'center' , 'FontSize', labelFontSize )
text( ( binsStimOn( meanFix_IDX_start ) + binsStimOn( meanFix_IDX_end ) )/2 , ( maxmaxg + 100 ), { 'Fixation', 'Interval' }, 'Color', 'r', 'HorizontalAlignment', 'center', 'FontSize', labelFontSize )
ylim( [ 0 ( maxmaxg + 50 ) ] )
xlim( [ -500 500 ] )
ax = gca;
ax.XTick = [ -500 -300 0 150 500 ];
ax.XTickLabel =  { '-500', '-300', '0', '150', '500' } ;
%title( 'Stimulus Onset' )
xlabel( 'time ( s )' )
%yl = ylabel( 'spike rate (impulse/sec)' );
text( -625, maxmaxg/2, 'Spike Rate', 'Rotation', 90, 'HorizontalAlignment', 'left', 'VerticalAlignment', 'bottom', 'FontSize', labelFontSize )
%set(gca,'YTickLabel',[]);
box off


subplot( 2,3,5 )
patch( [ binsDelay( meanDelayAct_IDX_start ), binsDelay( meanDelayAct_IDX_start ), binsDelay( meanDelayAct_IDX_end ), binsDelay(meanDelayAct_IDX_end ) ],...
    [ maxmaxg, 5, 5, maxmaxg ], [ 0.9 0.9 0.9 ], 'EdgeColor', [ 0.9 0.9 0.9 ] );
hold on
line( [ 0 0 ], [ 0 maxmaxg ],'Color','red','LineStyle','--','LineWidth',2 )
plot( binsDelay, DelayENDSmoothed,'Color','red','LineStyle','-', 'LineWidth', 2 )
line( [ binsDelay( meanDelayAct_IDX_start ) binsDelay( meanDelayAct_IDX_end ) ] , [ meanDelayAct meanDelayAct ], 'Color',[ 0.5 0.5 0.5 ],'LineStyle',':','LineWidth',2 )
%text( binsDelay( meanDelayAct_IDX_start ) , ( meanDelayAct + 40 ), [ 'Delay Mean = ' num2str( round( meanDelayAct ) ) ] )
text( ( binsDelay( meanDelayAct_IDX_start ) + binsDelay( meanDelayAct_IDX_end ) )/2 , ( maxmaxg + 100 ), { 'Delay Period', 'Interval' }, 'Color', 'r', 'HorizontalAlignment', 'center', 'FontSize', labelFontSize )
text( ( binsDelay( meanDelayAct_IDX_start ) + binsDelay( meanDelayAct_IDX_end ) )/2, ( meanDelayAct + 60 ), 'Delay Mean', 'HorizontalAlignment', 'center', 'FontSize', labelFontSize )
ylim( [ 0 ( maxmaxg + 50 ) ] )
xlim( [ -500 500 ] )
%title( 'Delay Period End' )
xlabel( 'time ( s )' )
ylabel( 'imp/sec' )
box off
ax1 = gca;                   % gca = get current axis
ax1.YAxis.Visible = 'off';   % remove y-axis
ax1.XTick = [ -500 -300 0 500 ];
ax1.XTickLabel =  { '-500', '-300', '0', '500' } ;



subplot( 2,3,6 )
patch( [ binsSaccadeOnset( saccade_windowIDX_start ), binsSaccadeOnset( saccade_windowIDX_start ), binsSaccadeOnset( saccade_windowIDX_end ), binsSaccadeOnset( saccade_windowIDX_end ) ],...
    [ maxmaxg, 5, 5, maxmaxg ], [ 0.9 0.9 0.9 ], 'EdgeColor', [ 0.9 0.9 0.9 ] );
hold on
line( [ 0 0 ], [ 0 maxmaxg ],'Color','red','LineStyle','--','LineWidth',2 )
plot( binsSaccadeOnset, SaccadeSmoothed,'Color','red','LineStyle','-', 'LineWidth', 2 )
plot( maxSaccadeX( 1 ), maxSaccade, 'bo','MarkerSize',4,'MarkerEdgeColor','k','MarkerFaceColor','k' )
%text( binsSaccadeOnset( saccade_windowIDX_start ) , ( maxSaccade + 40 ), [ 'PreSaccade Max = ' num2str( round( maxSaccade ) ) ] )
text( maxSaccadeX( 1 ) + 50 , maxSaccade, { 'PreSaccade', 'Max' }, 'HorizontalAlignment', 'left', 'VerticalAlignment', 'middle' , 'FontSize', labelFontSize )
line( [ binsSaccadeOnset( saccade_windowIDX_start ) binsSaccadeOnset( saccade_windowIDX_end ) ] , [ meanSaccade meanSaccade ], 'Color',[ 0.5 0.5 0.5 ],'LineStyle',':','LineWidth',2  )
%text( binsSaccadeOnset( saccade_windowIDX_start ) , ( meanSaccade + 40 ), [ 'PreSaccade Mean = ' num2str( round( meanSaccade ) ) ] )
text( ( binsSaccadeOnset( saccade_windowIDX_start ) + binsSaccadeOnset( saccade_windowIDX_end ) )/2 , ( maxmaxg + 100 ), { 'PreSaccadic', 'Interval' }, 'Color', 'r', 'HorizontalAlignment', 'center', 'FontSize', labelFontSize )
text( binsSaccadeOnset( saccade_windowIDX_start ) , meanSaccade, { 'PreSaccadic', 'Mean' }, 'HorizontalAlignment', 'right', 'VerticalAlignment', 'middle' , 'FontSize', labelFontSize )
ylim( [ 0 ( maxmaxg + 50 ) ] )
xlim( [ -500 500 ] )
%title( 'Saccade Onset' )
xlabel( 'time ( s )' )
ylabel( 'spike rate (impulse/sec)' )
box off
ax1 = gca;                   % gca = get current axis
ax1.YAxis.Visible = 'off';   % remove y-axis
ax1.XTick = [ -500 -100 0 500 ];
ax1.XTickLabel =  { '-500', '-100', '0', '500' } ;


suptitle( { [ unitName ' delayed saccade task' ], cellType_str , [ 'Visuo-Movement Index = ' num2str( visuoMovement_Index ) ] } )








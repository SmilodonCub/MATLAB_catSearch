%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%                                            
%       _____    ____   ____  ____      ____ 
%  ___|\     \  |    | |    ||    |    |    |
% |    |\     \ |    | |    ||    |    |    |
% |    | |     ||    |_|    ||    |    |    |
% |    | /_ _ / |    .-.    ||    |    |    |
% |    |\    \  |    | |    ||    |    |    |
% |    | |    | |    | |    ||\    \  /    /|
% |____|/____/| |____| |____|| \ ___\/___ / |
% |    /     || |    | |    | \ |   ||   | / 
% |____|_____|/ |____| |____|  \|___||___|/  
%   \(    )/      \(     )/      \(    )/    
%    '    '        '     '        '    '     
%  
%                                      
%                                                    
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%bonnie cooper

%BHV view of data & plot simple for SfN2017
%%
clc
clearvars
close all


%% 0 INIT


global ETparams                                                             

%would like to set up for batch processing, but the .bhv files are too
%variable, so running cell by cell for now
ThisCell =10;

%this is a  little script that coordinates behavioral files for a given
%given recording (Cell), so both the recorded delayed saccade and categorical
%search .bhv & trialInterval are loaded for analysis. it also calls the
%function 'delayedSaccadePLOT_BatchData' to show the RF mapping delayed 
%saccade alignments for eyetrace/behavioral events/neural data & the results 
%of a very basic cell characterization. both should be fairly well commented.
file_stem = 'C:\Users\McPeekLab\Desktop\SfN_catSearchPHYSIOL\';
catSearchPHYSIOL_BatchData                                              
RFangle = mod( SfN17_SUA( ThisCell ).RFangle{ 1 }, 360 );

%these eventmarkers are used by functions that handle eyeLink & spike 
%alignments to behavioral eventmarkers
FixON_eventmarker = 2;                                                     
ArrayON_eventmarker = 21;
TargetCORRECT = 14;


%% 1 event detection: saccades

%this function conditions the eyetrace data pulled from the .bhv file to be
%compatible with Adaptive Event Detection functions (the toolbox I use for
%detecting saccades etc. described in the following paper:
%Nyström, M. & Holmqvist, K., "An adaptive algorithm for fixation, saccade, 
%and glissade detection in eye-tracking data". %Behavior Research Methods
ETdata = eventDETECTION_saccades( thisBHV_CSP_file,FixON_eventmarker,TargetCORRECT );
%C:\Users\McPeekLab\Documents\MATLAB\Adaptive_Event_Detection\eventDetection.m
eventDetection

%% 2 alignments: Stimulus On & Saccade Onset
%make alignments of neural data and eye data by BHV event markers


eventmarkerAlignData = AlignSpikesBehav_StimON_SaccON( thisBHV_CSP_file, thisTrialInterval, ETparams, ArrayON_eventmarker, FixON_eventmarker );

%% 3 objects fixated for each trial

%trialObjectsFixated generates a structure with rather naive info on the
%taskObjects that were fixated for each correct trial:
%1) taskObjectPos ( Xpos, Ypos, angle(deg), eccentricity )
%2) taskObjectNames ( e.g. {'DBear_catbuck3' } )
%3) taskObjectsFixated in order. 'PretargetON' is before stim onset (small
%saccades within the fixation window)
%4/5) X/Ypos end of saccade
%6/7) saccade start/end time
%8) Fixation duration
[ trialObjectsFixated_Info ] = trialObjectsFixated( thisBHV_CSP_file, ETparams, eventmarkerAlignData );

%% 4 Bear or Butterfly or both?

Category = catergoryReturn_catSearchPHYSIOL( thisBHV_CSP_file );


%% 5 DATA formatting catSearchPHYSIOL_Data.
% Trial by trial data organization by target present/absent, was the
% saccade to target immediate or were there multiple saccades, what was in
% the RF, what was the innitial saccade to, what is the reaction time of
% first saccade, what is the reaction time to get the trial correctSfN17_trialInterval
catSearchPHYSIOL_Data = catSearchPHYSIOL_DataEXTRACT( thisBHV_CSP_file, trialObjectsFixated_Info, Category, RFangle );
[ BHVNEX_infoByTrial, innSacLocANDObject,innSacLocANDObject_Counts,arrayPos ]  = ...
    catSearchPHYSIOL_analysisSpikesHIST( thisBHV_CSP_file, Category, trialObjectsFixated_Info, catSearchPHYSIOL_Data, eventmarkerAlignData, RFangle );

%%
firstSaccadeSituations = catSearchPHYSIOL_trialXtrial( thisBHV_CSP_file, Category, trialObjectsFixated_Info, catSearchPHYSIOL_Data, eventmarkerAlignData, BHVNEX_infoByTrial, RFangle );


%% plot conditions
preStimON = -1000;
postStimON = 1000;
pre1stSaccade = -1000;
post1stSaccade = 1000;

binsize = 1;
fs = 1000;
sigma = 2;
binsStimON = preStimON:binsize:postStimON;
bins1stSaccade = pre1stSaccade:binsize:post1stSaccade;
ArrayOnAlignX = preStimON:binsize:postStimON;
saccadeAlignX = pre1stSaccade:binsize:post1stSaccade;

ObjectsLabel = { 'Target', 'Most', 'Least', 'Unranked' };
LocationsLabel = num2str( round( arrayPos ) );

linewidth = 1;
saccrxnbins = 120:1:300;

%%

% ArrayON_byTaskObject_M = zeros(  length( binsStimON ),4,4 );
% 
% for loop = 1:4
%     Loc1_g = gauss( sigma, 1000, hist( innSacLocANDObject{ 1,loop },binsStimON )/innSacLocANDObject_Counts( 1,loop )/binsize*fs );
%     Loc2_g = gauss( sigma, 1000,hist( innSacLocANDObject{ 2,loop },binsStimON )/innSacLocANDObject_Counts( 2,loop )/binsize*fs );
%     Loc3_g = gauss( sigma, 1000, hist( innSacLocANDObject{ 3,loop },binsStimON )/innSacLocANDObject_Counts( 3,loop )/binsize*fs );
%     Loc4_g = gauss( sigma,1000, hist( innSacLocANDObject{ 4,loop },binsStimON )/innSacLocANDObject_Counts( 4,loop )/binsize*fs );
%     ArrayON_byTaskObject_M( :,1,loop ) = Loc1_g;
%     ArrayON_byTaskObject_M( :,2,loop ) = Loc2_g;
%     ArrayON_byTaskObject_M( :,3,loop ) = Loc3_g;
%     ArrayON_byTaskObject_M( :,4,loop ) = Loc4_g;
% end
% 
% fig5 = figure;
% set(fig5, 'Position', [50 50 1200 800])
% for TaskObject = 1:4;
%     subplot( 2,2,TaskObject )
%     %surf( 1:4, ArrayOnAlignX, ArrayON_byTaskObject_M( :,:,TaskObject ) )
%     plot( ArrayOnAlignX, ArrayON_byTaskObject_M( :,1,TaskObject ), 'k' )
%     hold on
%     plot( ArrayOnAlignX, ArrayON_byTaskObject_M( :,2,TaskObject ), 'r' )
%     plot( ArrayOnAlignX, ArrayON_byTaskObject_M( :,3,TaskObject ), 'Color', [0 0.75 0] )
%     plot( ArrayOnAlignX, ArrayON_byTaskObject_M( :,4,TaskObject ), '--b' )    
%     ylabel( 'Spikes/ms' )
%     xlabel( 'Time (ms)' )
%     legend( LocationsLabel )
%     xlim( [ 50 300 ] )
%     %xlabel( 'Array Location' )
%     %ax = gca;
%    %ax.XTickLabel = LocationsLabel;
%     title( ObjectsLabel( TaskObject ) )
% end
% suptitle( 'Array Onset: sorted by TaskObject for all Locations' )
% 
% Saccade_byTaskObject_M = zeros(  length( saccadeAlignX ),4,4 );
% for loop = 1:4
%     Loc1_g = gauss( sigma, 1000, hist( innSacLocANDObject{ 6,loop },bins1stSaccade )/innSacLocANDObject_Counts( 1,loop )/binsize*fs );
%     Loc2_g = gauss( sigma, 1000,hist( innSacLocANDObject{ 7,loop },bins1stSaccade )/innSacLocANDObject_Counts( 2,loop )/binsize*fs );
%     Loc3_g = gauss( sigma, 1000, hist( innSacLocANDObject{ 8,loop },bins1stSaccade )/innSacLocANDObject_Counts( 3,loop )/binsize*fs );
%     Loc4_g = gauss( sigma,1000, hist( innSacLocANDObject{ 9,loop },bins1stSaccade )/innSacLocANDObject_Counts( 4,loop )/binsize*fs );
%     Saccade_byTaskObject_M( :,1,loop ) = Loc1_g;
%     Saccade_byTaskObject_M( :,2,loop ) = Loc2_g;
%     Saccade_byTaskObject_M( :,3,loop ) = Loc3_g;
%     Saccade_byTaskObject_M( :,4,loop ) = Loc4_g;
% end
% %Loc5_g = gauss( sigma,1000, hist( innSaccadebyLoc{ 9,thisTaskObject },bins )/innSaccadebyLoc{ 6 }( 5 )/binsize*fs );
% 
% fig6 = figure;
% set(fig6, 'Position', [50 50 1200 800])
% for TaskObject = 1:4;
%     subplot( 2,2,TaskObject )
%     %surf(  1:4, saccadeAlignX,Saccade_byTaskObject_M( :,:,TaskObject ) )
%     plot( saccadeAlignX, Saccade_byTaskObject_M( :,1,TaskObject ), 'k' )
%     hold on
%     plot( saccadeAlignX, Saccade_byTaskObject_M( :,2,TaskObject ), 'r' )
%     plot( saccadeAlignX, Saccade_byTaskObject_M( :,3,TaskObject ), 'Color', [0 0.75 0] )
%     plot( saccadeAlignX, Saccade_byTaskObject_M( :,4,TaskObject ), '--b' )     
%     ylabel( 'Spikes/ms' )
%     xlabel( 'Time (ms)' )
%     legend( LocationsLabel )
%     xlim( [ -150 150 ] )
%     %xlabel( 'Array Location' )
%     %ax = gca;
%    %ax.XTickLabel = LocationsLabel;
%     title( ObjectsLabel( TaskObject ) )
% end
% suptitle( 'Saccade: sorted by TaskObject for all Locations' )
% 
% fig7 = figure;
% set(fig7, 'Position', [50 50 1200 800])
% for TaskLocation = 1:4;
%     subplot( 2,2,TaskLocation )
%     plot( ArrayOnAlignX, ArrayON_byTaskObject_M( :,TaskLocation,1 ), 'k' )
%     hold on
%     plot( ArrayOnAlignX, ArrayON_byTaskObject_M( :,TaskLocation,2 ), 'r' )
%     plot( ArrayOnAlignX, ArrayON_byTaskObject_M( :,TaskLocation,3 ), 'Color', [0 0.75 0] )
%     plot( ArrayOnAlignX, ArrayON_byTaskObject_M( :,TaskLocation,4 ), '--b' )
%     ylabel( 'Spikes/ms' )
%     xlabel( 'Time (ms)' )
%     legend( [ ObjectsLabel{ 1 } ' n = ' num2str( innSacLocANDObject_Counts( TaskLocation, 1 ) )],...
%         [ ObjectsLabel{ 2 } ' n = ' num2str( innSacLocANDObject_Counts( TaskLocation, 2 ) )],...
%         [ ObjectsLabel{ 3 } ' n = ' num2str( innSacLocANDObject_Counts( TaskLocation, 3 ) )],...
%         [ ObjectsLabel{ 4 } ' n = ' num2str( innSacLocANDObject_Counts( TaskLocation, 4 ) )])
%     %xlabel( 'Array Location' )
%     %ax = gca;
%     %ax.XTickLabel = LocationsLabel;
%     xlim( [ 50 300 ] )
%     %title( LocationsLabel( TaskLocation,: ) )
%     %     loc = ArrayON_byLocation_M( :,:,TaskLocation );
%     %     %surf(  1:4, ArrayOnAlignX,loc' )
% %     zlabel( 'Spikes/ms' )
% %     ylabel( 'Time (ms)' )
% %     xlabel( 'Array Object' )
% %     ax = gca;
% %     ax.XTickLabel = ObjectsLabel;
% %     title( LocationsLabel( TaskLocation,: ) )
% end
% suptitle( 'Array Onset: sorted by Locations for all TaskObjects' )
% 
% 
% %Saccade_byLocation_M = shiftdim( Saccade_byTaskObject_M, 2 ) ;
% 
% fig8 = figure;
% set(fig8, 'Position', [50 50 1200 800])
% for TaskLocation = 1:4;
%     subplot( 2,2,TaskLocation )
%     plot( saccadeAlignX, Saccade_byTaskObject_M( :,TaskLocation,1 ), 'k' )
%     hold on
%     plot( saccadeAlignX, Saccade_byTaskObject_M( :,TaskLocation,2 ), 'r' )
%     plot( saccadeAlignX, Saccade_byTaskObject_M( :,TaskLocation,3 ), 'Color', [0 0.75 0] )
%     plot( saccadeAlignX, Saccade_byTaskObject_M( :,TaskLocation,4 ), '--b' )    
%     ylabel( 'Spikes/ms' )
%     xlabel( 'Time (ms)' )
%     legend( [ ObjectsLabel{ 1 } ' n = ' num2str( innSacLocANDObject_Counts( TaskLocation, 1 ) )],...
%         [ ObjectsLabel{ 2 } ' n = ' num2str( innSacLocANDObject_Counts( TaskLocation, 2 ) )],...
%         [ ObjectsLabel{ 3 } ' n = ' num2str( innSacLocANDObject_Counts( TaskLocation, 3 ) )],...
%         [ ObjectsLabel{ 4 } ' n = ' num2str( innSacLocANDObject_Counts( TaskLocation, 4 ) )])
%     %xlabel( 'Array Location' )
%     %ax = gca;
%    %ax.XTickLabel = LocationsLabel;
%    xlim( [ -150 150 ] )
%    %title( LocationsLabel( TaskLocation,: ) )    
% %     loc = ArrayON_byLocation_M( :,:,TaskLocation );
% %     %surf(  1:4, ArrayOnAlignX,loc' )
% %     zlabel( 'Spikes/ms' )
% %     ylabel( 'Time (ms)' )
% %     xlabel( 'Array Object' )
% %     ax = gca;
% %     ax.XTickLabel = ObjectsLabel;
% %     title( LocationsLabel( TaskLocation,: ) )
% end
% suptitle( 'Saccade: sorted by Locations for all TaskObjects' )

%%
% %SfN fig
% 
% SfNfigure1 = figure;
% set(SfNfigure1, 'Position', [50 50 1400 600])
% TaskLocation = 1;
% subplot( 1,2,1 )
% plot( ArrayOnAlignX, ArrayON_byTaskObject_M( :,TaskLocation,1 ), 'k' )
% hold on
% plot( ArrayOnAlignX, ArrayON_byTaskObject_M( :,TaskLocation,2 ), 'r' )
% plot( ArrayOnAlignX, ArrayON_byTaskObject_M( :,TaskLocation,3 ), 'Color', [0 0.75 0] )
% plot( ArrayOnAlignX, ArrayON_byTaskObject_M( :,TaskLocation,4 ), '--b' )
% ylabel( 'Spikes/ms' )
% xlabel( 'Time (ms)' )
% legend( [ ObjectsLabel{ 1 } ' n = ' num2str( innSacLocANDObject_Counts( TaskLocation, 1 ) )],...
%     [ ObjectsLabel{ 2 } ' n = ' num2str( innSacLocANDObject_Counts( TaskLocation, 2 ) )],...
%     [ ObjectsLabel{ 3 } ' n = ' num2str( innSacLocANDObject_Counts( TaskLocation, 3 ) )],...
%     [ ObjectsLabel{ 4 } ' n = ' num2str( innSacLocANDObject_Counts( TaskLocation, 4 ) )])
% xlim( [ 50 300 ] )
% title( 'Array Onset: sorted by Locations for all TaskObjects' )
% 
% subplot( 1,2,2 )
% plot( saccadeAlignX, Saccade_byTaskObject_M( :,TaskLocation,1 ), 'k' )
% hold on
% plot( saccadeAlignX, Saccade_byTaskObject_M( :,TaskLocation,2 ), 'r' )
% plot( saccadeAlignX, Saccade_byTaskObject_M( :,TaskLocation,3 ), 'Color', [0 0.75 0] )
% plot( saccadeAlignX, Saccade_byTaskObject_M( :,TaskLocation,4 ), '--b' )
% ylabel( 'Spikes/ms' )
% xlabel( 'Time (ms)' )
% legend( [ ObjectsLabel{ 1 } ' n = ' num2str( innSacLocANDObject_Counts( TaskLocation, 1 ) )],...
%     [ ObjectsLabel{ 2 } ' n = ' num2str( innSacLocANDObject_Counts( TaskLocation, 2 ) )],...
%     [ ObjectsLabel{ 3 } ' n = ' num2str( innSacLocANDObject_Counts( TaskLocation, 3 ) )],...
%     [ ObjectsLabel{ 4 } ' n = ' num2str( innSacLocANDObject_Counts( TaskLocation, 4 ) )])
% 
% xlim( [ -150 150 ] )
% title( 'Saccade: sorted by Locations for all TaskObjects' )

%%
%new plot
WutsInRF = cell( [ 6, 2 ] );
frequencyCondition = zeros( [ 6, 1 ] );
WutsInRF_Expand = cell( [ 6,2 ] );

for newplot = 1:size( BHVNEX_infoByTrial, 2 )
    %newplot
    %BHVNEX_infoByTrial( newplot ).arrayObjectInRF_Type
    %BHVNEX_infoByTrial( newplot ).fisrtArrayObjectFixated
    %was there a target in the response field?
    if BHVNEX_infoByTrial( newplot ).arrayObjectInRF_Type == 1
        %was the saccade into the RF to the target?
        if BHVNEX_infoByTrial( newplot ).fisrtArrayObjectFixated == 1
%             %get the alignments concatenated
%             WutsInRF{ 1,1 } = cat( 1, WutsInRF{ 1,1 }, BHVNEX_infoByTrial( newplot ).stimONSET_alignedSpikes );
%             WutsInRF{ 1,2 } = cat( 1, WutsInRF{ 1,2 }, BHVNEX_infoByTrial( newplot ).saccadeONSET_alignedSpikes );
            WutsInRF_Expand{ 1,1 } = cat( 1, WutsInRF_Expand{ 1,1 }, gauss( sigma, 1000, hist( BHVNEX_infoByTrial( newplot ).stimONSET_alignedSpikes,binsStimON )/1/binsize/1000*fs )' );
            WutsInRF_Expand{ 1,2 } = cat( 1, WutsInRF_Expand{ 1,2 }, gauss( sigma, 1000, hist( BHVNEX_infoByTrial( newplot ).saccadeONSET_alignedSpikes,binsStimON )/1/binsize/1000*fs )' );
            %up the count
            frequencyCondition( 1,1 ) = frequencyCondition( 1,1 ) + 1;
        %was the saccade out of the RF to something else?
        elseif BHVNEX_infoByTrial( newplot ).fisrtArrayObjectFixated ~= 1
%             %get the alignments concatenated
%             WutsInRF{ 2,1 } = cat( 1, WutsInRF{ 2,1 }, BHVNEX_infoByTrial( newplot ).stimONSET_alignedSpikes );
%             WutsInRF{ 2,2 } = cat( 1, WutsInRF{ 2,2 }, BHVNEX_infoByTrial( newplot ).saccadeONSET_alignedSpikes );
            WutsInRF_Expand{ 2,1 } = cat( 1, WutsInRF_Expand{ 2,1 }, gauss( sigma, 1000, hist( BHVNEX_infoByTrial( newplot ).stimONSET_alignedSpikes,binsStimON )/1/binsize/1000*fs )' );
            WutsInRF_Expand{ 2,2 } = cat( 1, WutsInRF_Expand{ 2,2 }, gauss( sigma, 1000, hist( BHVNEX_infoByTrial( newplot ).saccadeONSET_alignedSpikes,binsStimON )/1/binsize/1000*fs )' );
            %up the count
            frequencyCondition( 2,1 ) = frequencyCondition( 2,1 ) + 1;
        end
    end
        
    %was there a MostD in the response field?
    if BHVNEX_infoByTrial( newplot ).arrayObjectInRF_Type == 2
        %was the saccade into the RF to the MostD?
        if BHVNEX_infoByTrial( newplot ).fisrtArrayObjectFixated == 2
            WutsInRF_Expand{ 3,1 } = cat( 1, WutsInRF_Expand{ 3,1 }, gauss( sigma, 1000, hist( BHVNEX_infoByTrial( newplot ).stimONSET_alignedSpikes,binsStimON )/1/binsize/1000*fs )' );
            WutsInRF_Expand{ 3,2 } = cat( 1, WutsInRF_Expand{ 3,2 }, gauss( sigma, 1000, hist( BHVNEX_infoByTrial( newplot ).saccadeONSET_alignedSpikes,binsStimON )/1/binsize/1000*fs )' );
            %up the count
            frequencyCondition( 3,1 ) = frequencyCondition( 3,1 ) + 1;
        %was the saccade out of the RF to something else?
        elseif BHVNEX_infoByTrial( newplot ).fisrtArrayObjectFixated ~= 2
            WutsInRF_Expand{ 4,1 } = cat( 1, WutsInRF_Expand{ 4,1 }, gauss( sigma, 1000, hist( BHVNEX_infoByTrial( newplot ).stimONSET_alignedSpikes,binsStimON )/1/binsize/1000*fs )' );
            WutsInRF_Expand{ 4,2 } = cat( 1, WutsInRF_Expand{ 4,2 }, gauss( sigma, 1000, hist( BHVNEX_infoByTrial( newplot ).saccadeONSET_alignedSpikes,binsStimON )/1/binsize/1000*fs )' );
            %up the count
            frequencyCondition( 4,1 ) = frequencyCondition( 4,1 ) + 1;
        end
    end
        
    %was there a LeastD in the respinse field?
    if BHVNEX_infoByTrial( newplot ).arrayObjectInRF_Type == 3
        %was the saccade into the RF to the Most D?
        if BHVNEX_infoByTrial( newplot ).fisrtArrayObjectFixated == 3
            WutsInRF_Expand{ 5,1 } = cat( 1, WutsInRF_Expand{ 5,1 }, gauss( sigma, 1000, hist( BHVNEX_infoByTrial( newplot ).stimONSET_alignedSpikes,binsStimON )/1/binsize/1000*fs )' );
            WutsInRF_Expand{ 5,2 } = cat( 1, WutsInRF_Expand{ 5,2 }, gauss( sigma, 1000, hist( BHVNEX_infoByTrial( newplot ).saccadeONSET_alignedSpikes,binsStimON )/1/binsize/1000*fs )' );
            %up the count
            frequencyCondition( 5,1 ) = frequencyCondition( 5,1 ) + 1;
        %was the saccade out of the RF to something else?
        elseif BHVNEX_infoByTrial( newplot ).fisrtArrayObjectFixated ~= 3
            WutsInRF_Expand{ 6,1 } = cat( 1, WutsInRF_Expand{ 6,1 }, gauss( sigma, 1000, hist( BHVNEX_infoByTrial( newplot ).stimONSET_alignedSpikes,binsStimON )/1/binsize/1000*fs )' );
            WutsInRF_Expand{ 6,2 } = cat( 1, WutsInRF_Expand{ 6,2 }, gauss( sigma, 1000, hist( BHVNEX_infoByTrial( newplot ).saccadeONSET_alignedSpikes,binsStimON )/1/binsize/1000*fs )' );
            %up the count
            frequencyCondition( 6,1 ) = frequencyCondition( 6,1 ) + 1;
        end
    end
    
end


WutsInRF_Expand_STD = cellfun( @std, WutsInRF_Expand,'UniformOutput',false);
WutsInRF_Expand_mean = cellfun( @mean, WutsInRF_Expand,'UniformOutput',false);
maxes = max( max( cell2mat( cellfun( @max, WutsInRF_Expand_mean,'UniformOutput',false ) ) ) );
% 




%%
StimON_IDX_patchstart = 50;
StimON_IDX_patchend = 150;
Saccade_IDX_patchstart = -100;
Saccade_IDX_patchend = 0;
patchColor = [ 0.98 0.98 0.98 ];
lineColor = [ 0.85 0.85 0.85 ];
darklineColor = [ 0.5 0.5 0.5 ];
saccoutColor = [ 0.5 0.5 0.5 ];
axizFontSize = 15;
legendFontSize = 10;
redShade = [ 1 0.75 0.75 ];
greenShade = [ 0.75 1 0.75 ];
blueShade = [0.75 0.75 1 ];
transparency = 0.25;

%jbfill(xpoints,upper,lower,color,edge,add,transparency)
SfNfig3  = figure;
set(gcf,'color','w');
set(SfNfig3, 'Position', [50 50 1500 550])
subplot( 1,2,1 )
inbetween = [ WutsInRF_Expand_STD{ 1,1 }./sqrt( frequencyCondition ( 1,1 ) ) ];
%shadedErrorBar(x,y,{@mean,@std},'lineprops','-r','transparent',1);
H1 = shadedErrorBar( ArrayOnAlignX, WutsInRF_Expand_mean{ 1,1 }, inbetween,'lineprops','r' );
hold on
inbetween3 = [  WutsInRF_Expand_STD{ 3,1 }./sqrt( frequencyCondition ( 3,1 ) )];
H3 = shadedErrorBar( ArrayOnAlignX, WutsInRF_Expand_mean{ 3,1 }, inbetween3,'lineprops','g' );
inbetween5 = [ WutsInRF_Expand_STD{ 5,1 }./sqrt( frequencyCondition ( 5,1 ) ) ];
H5 = shadedErrorBar( ArrayOnAlignX, WutsInRF_Expand_mean{ 5,1 }, inbetween5,'lineprops','b' );
line( [ StimON_IDX_patchend StimON_IDX_patchend ], [ 0 ( maxes + 0.1*maxes ) ], 'LineStyle', '--', 'Color', darklineColor )
xlim( [ 0 200 ] )
ylim( [ 0 ( maxes + 0.1*maxes ) ] )
ylabel( 'imp/sec','FontSize',axizFontSize )
xlabel( 'time (ms)','FontSize',axizFontSize )
title( { 'Target Object in RF is Object of saccade', 'Aligned on Stimulus Onset' } )
text( 55,  maxes ,[ 'Target, #trials: ' num2str( firstSaccadeSituations( 1,1 ) ) ], 'Color', 'r','FontSize',legendFontSize )
text( 55,  maxes -25, [ 'Similar Distractor, #trials: ' num2str( firstSaccadeSituations( 2,1 ) ) ], 'Color', 'g','FontSize',legendFontSize )
text( 55,  maxes -50,[ 'Disimilar Distractor, #trials: ' num2str( firstSaccadeSituations( 3,1 ) ) ], 'Color', 'b','FontSize',legendFontSize )

% subplot( 2,2,3 )
% hold on
 inbetween2 = [ WutsInRF_Expand_STD{ 2,1 }./sqrt( frequencyCondition ( 2,1 ) ) ];
%H2 = shadedErrorBar( ArrayOnAlignX, WutsInRF_Expand_mean{ 2,1 }, inbetween2,'lineprops','r' );
% hold on
 inbetween4 = [ WutsInRF_Expand_STD{ 4,1 }./sqrt( frequencyCondition ( 4,1 ) ) ];
% H4 = shadedErrorBar( ArrayOnAlignX, WutsInRF_Expand_mean{ 4,1 }, inbetween4,'lineprops','g' );
 inbetween6 = [ WutsInRF_Expand_STD{ 6,1 }./sqrt( frequencyCondition ( 6,1 ) ) ];
% H6 = shadedErrorBar( ArrayOnAlignX, WutsInRF_Expand_mean{ 6,1 }, inbetween6,'lineprops','b' );
% xlim( [ 50 300 ] )
% ylim( [ 0 ( maxes + 0.1*maxes ) ] )
% title( { 'Target Object in RF is NOT the Object of saccade', 'Aligned on Stimulus Onset' } )

subplot( 1,2,2 )
inbetween12 = [ WutsInRF_Expand_STD{ 1,2 }./sqrt( frequencyCondition ( 1,1 ) ) ];
H12 = shadedErrorBar( ArrayOnAlignX, WutsInRF_Expand_mean{ 1,2 }, inbetween12,'lineprops','r' );
hold on
inbetween32 = [ WutsInRF_Expand_STD{ 3,2 }./sqrt( frequencyCondition ( 3,1 ) ) ];
H32 = shadedErrorBar( ArrayOnAlignX, WutsInRF_Expand_mean{ 3,2 }, inbetween32,'lineprops','g' );
inbetween52 = [ WutsInRF_Expand_STD{ 5,2 }./sqrt( frequencyCondition ( 5,1 ) ) ];
H52 = shadedErrorBar( ArrayOnAlignX, WutsInRF_Expand_mean{ 5,2 }, inbetween52,'lineprops','b' );
line( [ Saccade_IDX_patchend Saccade_IDX_patchend ], [ 0 ( maxes + 0.1*maxes ) ], 'LineStyle', '--', 'Color', darklineColor )
line( [ Saccade_IDX_patchstart Saccade_IDX_patchstart ], [ 0 ( maxes + 0.1*maxes ) ], 'LineStyle', '--', 'Color', darklineColor )
xlim( [ -100 50 ] )
ylim( [ 0 ( maxes + 0.1*maxes ) ] )
xlabel( 'time (ms)','FontSize',axizFontSize )
title( { 'Target Object in RF is Object of saccade', 'Aligned on Saccade Initiation' } )
text( -95,  maxes ,[ 'Target' num2str( firstSaccadeSituations( 1,1 ) ) ] , 'Color', 'r','FontSize',legendFontSize )
text( -95,  maxes -25, [ 'Target Similar Distractor' num2str( firstSaccadeSituations( 2,1 ) ) ], 'Color', 'g','FontSize',legendFontSize )
text( -95,  maxes -50, [ 'Target Disimilar Distractor' num2str( firstSaccadeSituations( 3,1 ) ) ], 'Color', 'b','FontSize',legendFontSize )

% subplot( 2,2,4 )
 inbetween22 = [ WutsInRF_Expand_STD{ 2,2 }./sqrt( frequencyCondition ( 2,1 ) ) ];
% H22 = shadedErrorBar( ArrayOnAlignX, WutsInRF_Expand_mean{ 2,2 }, inbetween,'lineprops','r' );
% hold on
 inbetween42 = [ WutsInRF_Expand_STD{ 4,2 }./sqrt( frequencyCondition ( 4,1 ) ) ];
% %H42 = shadedErrorBar( ArrayOnAlignX, WutsInRF_Expand_mean{ 4,2 }, inbetween,'lineprops','g' );
 inbetween62 = [ WutsInRF_Expand_STD{ 6,2 }./sqrt( frequencyCondition ( 6,1 ) ) ];
% H62 = shadedErrorBar( ArrayOnAlignX, WutsInRF_Expand_mean{ 6,2 }, inbetween,'lineprops','b' );
% xlim( [ -150 150 ] )
% ylim( [ 0 ( maxes + 0.1*maxes ) ] )
% title( { 'Target Object in RF is NOT the Object of saccade', 'Aligned on Saccade Innitiation' } )




%%

SfNfig2  = figure;
set(gcf,'color','w');
set(SfNfig2, 'Position', [50 50 1200 800])
subplot( 3,2,1 )
patch( [ StimON_IDX_patchstart+2, StimON_IDX_patchstart+2, StimON_IDX_patchend, StimON_IDX_patchend ],...
    [ ( maxes + 0.1*maxes ), 2, 2, ( maxes + 0.1*maxes ) ], patchColor, 'EdgeColor', patchColor );
hold on
H1 = shadedErrorBar( ArrayOnAlignX, WutsInRF_Expand_mean{ 1,1 }, inbetween,'lineprops','r' );
try
H2 = shadedErrorBar( ArrayOnAlignX, WutsInRF_Expand_mean{ 2,1 }, inbetween2,'lineprops', {'-','color',saccoutColor } );
catch ME
    disp( ME.identifier )
    disp( ME.message )
end
set(gca,'TickLength',[0.001, 0.0001]);
line( [ StimON_IDX_patchend StimON_IDX_patchend ], [ 0 ( maxes + 0.1*maxes ) ], 'LineStyle', '--', 'Color', lineColor )
line( [ 0 300 ], [ -10 -10 ],'Color','k','LineWidth',2 )
xlim( [ 0 300 ] )
ylim( [ 0 ( maxes + 0.2*maxes ) ] )
ylabel( 'imp/sec','FontSize',axizFontSize )
title( {'Stimulus Onset Alignment', '','Target in RF'} )

subplot( 3,2,3 )
patch( [ StimON_IDX_patchstart+2, StimON_IDX_patchstart+2, StimON_IDX_patchend, StimON_IDX_patchend ],...
    [ ( maxes + 0.1*maxes ), 8, 8, ( maxes + 0.1*maxes ) ], patchColor, 'EdgeColor', patchColor );
hold on
H3 = shadedErrorBar( ArrayOnAlignX, WutsInRF_Expand_mean{ 3,1 }, inbetween3,'lineprops','g' );
H4 = shadedErrorBar( ArrayOnAlignX, WutsInRF_Expand_mean{ 4,1 }, inbetween4,'lineprops', {'-','color',saccoutColor } );
line( [ StimON_IDX_patchend StimON_IDX_patchend ], [ 0 ( maxes + 0.1*maxes ) ], 'LineStyle', '--', 'Color', lineColor )
set(gca,'TickLength',[0.001, 0.0001]);
line( [ 0 300 ], [ -2 -2 ],'LineWidth',2 )
xlim( [ 0 300 ] )
ylim( [ 0 ( maxes + 0.2*maxes ) ] )
ylabel( 'imp/sec','FontSize',axizFontSize )
title( 'Target Similar Distractor in RF' )

subplot( 3,2,5 )
patch( [ StimON_IDX_patchstart+2, StimON_IDX_patchstart+2, StimON_IDX_patchend, StimON_IDX_patchend ],...
    [ ( maxes + 0.1*maxes ), 8, 8, ( maxes + 0.1*maxes ) ], patchColor, 'EdgeColor', patchColor );
hold on
H5 = shadedErrorBar( ArrayOnAlignX, WutsInRF_Expand_mean{ 5,1 }, inbetween5,'lineprops','b' );
H6 = shadedErrorBar( ArrayOnAlignX, WutsInRF_Expand_mean{ 6,1 }, inbetween6,'lineprops', {'-','color',saccoutColor }  );
line( [ StimON_IDX_patchend StimON_IDX_patchend ], [ 0 ( maxes + 0.1*maxes ) ], 'LineStyle', '--', 'Color', lineColor )
set(gca,'TickLength',[0.001, 0.0001]);
line( [ 0 300 ], [ -2 -2 ],'LineWidth',2 )
xlim( [ 0 300 ] )
ylim( [ 0 ( maxes + 0.2*maxes ) ] )
xlabel( 'time (ms)','FontSize',axizFontSize )
ylabel( 'imp/sec','FontSize',axizFontSize )
title( 'Target Disimilar Distractor in RF' )

subplot( 3,2,2 )
patch( [ Saccade_IDX_patchstart, Saccade_IDX_patchstart, Saccade_IDX_patchend, Saccade_IDX_patchend ],...
    [ ( maxes + 0.1*maxes ), 2, 2, ( maxes + 0.1*maxes ) ], patchColor, 'EdgeColor', patchColor );
hold on
H12 = shadedErrorBar( ArrayOnAlignX, WutsInRF_Expand_mean{ 1,2 }, inbetween12,'lineprops','r' );
try
H22 = shadedErrorBar( ArrayOnAlignX, WutsInRF_Expand_mean{ 2,2 }, inbetween22,'lineprops', {'-','color',saccoutColor }  );
catch ME
    disp( ME.identifier )
    disp( ME.message )
end
set(gca,'TickLength',[0.001, 0.0001]);
line( [ Saccade_IDX_patchstart Saccade_IDX_patchstart ], [ 0 ( maxes + 0.1*maxes ) ], 'LineStyle', '--', 'Color', lineColor )
line( [ Saccade_IDX_patchend Saccade_IDX_patchend ], [ 0 ( maxes + 0.1*maxes ) ], 'LineStyle', '--', 'Color', lineColor )
line( [ 0 300 ], [ -2 -2 ],'LineWidth',2 )
xlim( [ -150 150 ] )
ylim( [ 0 ( maxes + 0.2*maxes ) ] )
text( 150, maxes + 0.1*maxes, [ 'Target In RF, Saccade In RF, #trials: ' num2str( firstSaccadeSituations( 1,1 ) ) ],'Color','r', 'HorizontalAlignment','right' )
text( 150, maxes + 0.1*maxes-50, [ 'Target In RF, Saccade Out RF, #trials: ' num2str( firstSaccadeSituations( 1,2 ) ) ],'Color',saccoutColor, 'HorizontalAlignment','right'  )
title( {'Saccade Innitiation Alignment', '','Target in RF'} )

subplot( 3,2,4 )
patch( [ Saccade_IDX_patchstart, Saccade_IDX_patchstart, Saccade_IDX_patchend, Saccade_IDX_patchend ],...
    [ ( maxes + 0.1*maxes ), 2, 2, ( maxes + 0.1*maxes ) ], patchColor, 'EdgeColor', patchColor );
hold on
H32 = shadedErrorBar( ArrayOnAlignX, WutsInRF_Expand_mean{ 3,2 }, inbetween32,'lineprops','g' );
H42 = shadedErrorBar( ArrayOnAlignX, WutsInRF_Expand_mean{ 4,2 }, inbetween42,'lineprops', {'-','color',saccoutColor }  );
set(gca,'TickLength',[0.001, 0.0001]);
line( [ 50 300 ], [ 0 0 ],'LineWidth',2 )
line( [ Saccade_IDX_patchstart Saccade_IDX_patchstart ], [ 0 ( maxes + 0.1*maxes ) ], 'LineStyle', '--', 'Color', lineColor )
line( [ Saccade_IDX_patchend Saccade_IDX_patchend ], [ 0 ( maxes + 0.1*maxes ) ], 'LineStyle', '--', 'Color', lineColor )
xlim( [ -150 150 ] )
ylim( [ 0 ( maxes + 0.2*maxes ) ] )
text( 150, maxes + 0.1*maxes, [ 'Similar In RF, Saccade In RF, #trials: ' num2str( firstSaccadeSituations( 2,1 ) ) ],'Color','g', 'HorizontalAlignment','right' )
text( 150, maxes + 0.1*maxes-50, [ 'Similar In RF, Saccade Out RF, #trials: ' num2str( firstSaccadeSituations( 2,2 ) ) ],'Color',saccoutColor, 'HorizontalAlignment','right'  )
title( ' Target Similar Distractor in RF ' )

subplot( 3,2,6 )
patch( [ Saccade_IDX_patchstart, Saccade_IDX_patchstart, Saccade_IDX_patchend, Saccade_IDX_patchend ],...
    [ ( maxes + 0.1*maxes ), 8, 8, ( maxes + 0.1*maxes ) ], patchColor, 'EdgeColor', patchColor );
hold on
H52 = shadedErrorBar( ArrayOnAlignX, WutsInRF_Expand_mean{ 5,2 }, inbetween52,'lineprops','b' );
H62 = shadedErrorBar( ArrayOnAlignX, WutsInRF_Expand_mean{ 6,2 }, inbetween62,'lineprops', {'-','color',saccoutColor }  );
set(gca,'TickLength',[0.001, 0.0001]);
line( [ 50 300 ], [ 0 0 ],'LineWidth',2 )
line( [ Saccade_IDX_patchstart Saccade_IDX_patchstart ], [ 0 ( maxes + 0.1*maxes ) ], 'LineStyle', '--', 'Color', lineColor )
line( [ Saccade_IDX_patchend Saccade_IDX_patchend ], [ 0 ( maxes + 0.1*maxes ) ], 'LineStyle', '--', 'Color', lineColor )
xlim( [ -150 150 ] )
ylim( [ 0 ( maxes + 0.2*maxes ) ] )
xlabel( 'time (ms)','FontSize',axizFontSize )
text( 150, maxes + 0.1*maxes, [ 'Disimilar In RF, Saccade In RF, #trials: ' num2str( firstSaccadeSituations( 3,1 ) ) ],'Color','b', 'HorizontalAlignment','right' )
text( 150, maxes + 0.1*maxes-50, [ 'Disimilar In RF, Saccade Out RF, #trials: ' num2str( firstSaccadeSituations( 3,2 ) ) ],'Color',saccoutColor, 'HorizontalAlignment','right'  )
title( 'Target Disimilar Distractor in RF' )



%%
% figure
% subplot( 3,2,1 )
% plot( ArrayOnAlignX, TarINSaccIN_StimONg, 'k' )
% hold on
% plot( ArrayOnAlignX, TarINSaccOUT_StimONg, 'Color', [ 0.5 0.5 0.5 ] )
% xlim( [ 50 300 ] )
% 
% subplot( 3,2,3 )
% plot( ArrayOnAlignX, MostINSaccIN_StimONg, 'r' )
% hold on
% plot( ArrayOnAlignX, MostINSaccOUT_StimONg, 'Color', [ 0.5 0 0 ] )
% xlim( [ 50 300 ] )
% 
% subplot( 3,2,5 )
% plot( ArrayOnAlignX, LeastINSaccIN_StimONg, 'b' )
% hold on
% plot( ArrayOnAlignX, LeastINSaccOUT_StimONg, 'Color', [ 0 0 0.5 ] )
% xlim( [ 50 300 ] )
% 
% subplot( 3,2,2 )
% plot( ArrayOnAlignX, TarINSaccIN_SaccGOg, 'k' )
% hold on
% plot( ArrayOnAlignX, TarINSaccOUT_SaccGOg, 'Color', [ 0.5 0.5 0.5 ] )
% xlim( [ -150 150 ] )
% 
% subplot( 3,2,4 )
% plot( ArrayOnAlignX, MostINSaccIN_SaccGOg, 'r' )
% hold on
% plot( ArrayOnAlignX, MostINSaccOUT_SaccGOg, 'Color', [ 1 0.5 0.5 ] )
% xlim( [ -150 150 ] )
% 
% subplot( 3,2,6 )
% plot( ArrayOnAlignX, LeastINSaccIN_SaccGOg, 'b' )
% hold on
% plot( ArrayOnAlignX, LeastINSaccOUT_SaccGOg, 'Color', [ 0.5 0.5 1 ] )
% xlim( [ -150 150 ] )
% 
% 
% figure
% subplot( 2,2,1 )
% plot( ArrayOnAlignX, TarINSaccIN_StimONg, 'r' )
% hold on
% plot( ArrayOnAlignX, MostINSaccIN_StimONg, 'g' )
% plot( ArrayOnAlignX, LeastINSaccIN_StimONg, 'b' )
% xlim( [ 50 300 ] )
% 
% subplot( 2,2,3 )
% plot( ArrayOnAlignX, TarINSaccOUT_StimONg, 'r' )
% hold on
% plot( ArrayOnAlignX, MostINSaccOUT_StimONg, 'g' )
% plot( ArrayOnAlignX, LeastINSaccOUT_StimONg, 'b' )
% xlim( [ 50 300 ] )
% 
% subplot( 2,2,2 )
% plot( ArrayOnAlignX, TarINSaccIN_SaccGOg, 'r' )
% hold on
% plot( ArrayOnAlignX, MostINSaccIN_SaccGOg, 'g' )
% plot( ArrayOnAlignX, LeastINSaccIN_SaccGOg, 'b' )
% xlim( [ -150 150 ] )
% 
% subplot( 2,2,4 )
% plot( ArrayOnAlignX, TarINSaccOUT_SaccGOg, 'r' )
% hold on
% plot( ArrayOnAlignX, MostINSaccOUT_SaccGOg, 'g' )
% plot( ArrayOnAlignX, LeastINSaccOUT_SaccGOg, 'b' )
% xlim( [ -150 150 ] )
% 
% 
% 
% 
% 

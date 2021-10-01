%a short little script to coordinate the loading of appropriate behavioral
%files (.bhv from MonkeyLogic) and the neural data (tiralIntervals structs
%these are made from imported intervals from a data imported to Matlab from
%NeuroExplorer. If you need more info on this, look for PlexNexSort.m and a
%plx2nex2mat_dataExtraction.nsc on the PC used for online NeuroExplorer. It
%should be on github too....

%this is a struct that points to all the appropriate files for a given
%recording (i'm calling it ThisCell but i don't really know why. the name
%just stuck)
SfN17tIBHV = load( 'SfN17tIBHV' );

%well,.....so eventually I would like to batch process the cells & that
%was where I was originally headed with this 'SfN17_SUA' struct. still
%working towards that. For now I'm just going cell by cell.....
SfN17_SUA = struct;
SfN_names = SfN17tIBHV.SfN17tIBHV;

b = ThisCell;

SfN17_SUA( b ).name = SfN_names( b,1 );
SfN17_SUA( b ).nametrialInterval = SfN_names( b,2 );
SfN17_SUA( b ).nameBHV_catSearchPHYSIOL = SfN_names( b,3 );
SfN17_SUA( b ).nameBHV_delayedSaccade = SfN_names( b,4 );
SfN17_SUA( b ).RFangle = SfN_names( b,5 );

% check that the number of intervals are same for
thisTrialInterval = load( SfN17_SUA( b ).nametrialInterval{ 1 } );
thisBHV_DS_str = SfN17_SUA( b ).nameBHV_delayedSaccade{ 1 };
disp( thisBHV_DS_str )
%thisBHV_DS_stem = 'C:\monkeylogic\Experiments\saccade_task\';
thisBHV_DS = [ file_stem thisBHV_DS_str '.bhv' ];
thisBHV_DS_file = bhv_read( thisBHV_DS );
thisBHV_CSP_str = SfN17_SUA( b ).nameBHV_catSearchPHYSIOL{ 1 };
disp( thisBHV_CSP_str )
%thisBHV_CSP_stem = 'C:\monkeylogic\Experiments\categorical_search\categorical_search_PHYSIOL\';
thisBHV_CSP = [ file_stem thisBHV_CSP_str '.bhv' ];
thisBHV_CSP_file = bhv_read( thisBHV_CSP );
SfN17_SUA( b ).trialInterval = thisTrialInterval.trialInterval;
name_str = SfN17_SUA( b ).name{ 1 };
nums = [ name_str ' ' ...
    num2str( size( SfN17_SUA( b ).trialInterval.trialSpikesTimes_DS,2 ) ) '  ' ...
    num2str( size( find( thisBHV_DS_file.TrialError == 0 ),1 ) ) ' ' ...
    num2str( size( SfN17_SUA( b ).trialInterval.trialSpikesTimes_CSP,2 ) ) ' ' ...
    num2str( size( find( thisBHV_CSP_file.TrialError == 0 ),1 ) )];
disp( nums )

try
    [ cellType, visuoMovement_Index ] = delayedSaccadePLOT_BatchData( SfN_names{ b,1 }, thisTrialInterval, thisBHV_DS_file, 1 );
    %SfN17_SUA( b -1 ).cellType = cellType;
catch ME
    disp( ME.identifier )
    disp( ME.message )
    disp( ME.cause )
end



    %pause()
    


%%

% for b = 2: ( size( SfN17tIBHV.SfN17tIBHV, 1 ) )
%     %b
%     SfN17_SUA( b -1 ).name = SfN_names( b,1 );
%     SfN17_SUA( b -1 ).nametrialInterval = SfN_names( b,2 );
%     SfN17_SUA( b -1 ).nameBHV_catSearchPHYSIOL = SfN_names( b,3 );
%     SfN17_SUA( b -1 ).nameBHV_delayedSaccade = SfN_names( b,4 );
%     
%     % check that the number of intervals are same for 
%     thisTrialInterval = load( SfN17_SUA( b -1 ).nametrialInterval{ 1 } );
%     thisBHV_DS_str = SfN17_SUA( b -1 ).nameBHV_delayedSaccade{ 1 };
%     thisBHV_DS_stem = 'C:\monkeylogic\Experiments\saccade_task\';
%     thisBHV_DS = [ thisBHV_DS_stem thisBHV_DS_str '.bhv' ];
%     thisBHV_DS_file = bhv_read( thisBHV_DS );
%     thisBHV_CSP_str = SfN17_SUA( b -1 ).nameBHV_catSearchPHYSIOL{ 1 };
%     thisBHV_CSP_stem = 'C:\monkeylogic\Experiments\categorical_search\categorical_search_PHYSIOL\';
%     thisBHV_CSP = [ thisBHV_CSP_stem thisBHV_CSP_str '.bhv' ];
%     thisBHV_CSP_file = bhv_read( thisBHV_CSP );
%     SfN17_SUA( b -1 ).trialInterval = thisTrialInterval.trialInterval;
%     name_str = SfN17_SUA( b -1 ).name{ 1 };
%     nums = [ name_str ' ' ...
%         num2str( size( SfN17_SUA( b -1 ).trialInterval.trialSpikesTimes_DS,2 ) ) '  ' ...
%         num2str( size( find( thisBHV_DS_file.TrialError == 0 ),1 ) ) ' ' ...
%         num2str( size( SfN17_SUA( b -1 ).trialInterval.trialSpikesTimes_CSP,2 ) ) ' ' ...
%         num2str( size( find( thisBHV_CSP_file.TrialError == 0 ),1 ) )];
%     disp( nums )
%     
%     try
%         [ cellType, visuoMovement_Index ] = delayedSaccadePLOT_BatchData( SfN_names{ b,1 }, thisTrialInterval, thisBHV_DS_file, 0 );
%         SfN17_SUA( b -1 ).cellType = cellType;
%     catch ME
%         disp( ME.identifier )
%         disp( ME.message )
%         disp( ME.cause )
%     end
%     
%     
%     
%     %pause()
%     
% end
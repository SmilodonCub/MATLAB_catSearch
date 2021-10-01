function [ ETdata ] = eventDETECTION_saccades( aBHV, fixON_eventmarker, Tacquired_eventmarker )
%AdaptiveEVENTDETECTION uses an event detection algorithm to detect
%saccades. but first it conditions the BHV eye-signal data & initiallizes
%all the event detection parameters. Most parameters are input from the BHV
%file itself, but some are set here: 
%
% ETparams.blinkVelocityThreshold = 1000;                                     %if vel > 1000 degrees/s, it is noise or blinks
% ETparams.blinkAccThreshold = 100000;                                        %if acc > 100000 degrees/s^2, it is noise or blinks
% ETparams.peakDetectionThreshold = 0.12;                                      %Initial value of the peak detection threshold. 
% ETparams.minFixDur = 0.03;                                                  %in seconds
% ETparams.minSaccadeDur = 0.010;                                             %in seconds
%
%This Matlab set of functions is described in the following paper:
%Nyström, M. & Holmqvist, K., "An adaptive algorithm for fixation, saccade, 
%and glissade detection in eye-tracking data". %Behavior Research Methods

global ETparams   
correct_idx = find( aBHV.TrialError == 0 );
num_correct = length(correct_idx);


%--------------------------------------------------------------------------
% Condition BHV Eye Signal Data
%--------------------------------------------------------------------------
                                                                            %truncate analog data from the end of fixation hold time 
                                                                            %to the end of target hold time and
                                                                            %hold values in ETdata struct. 
for ii= 1:num_correct
                                                                            %find the time of the eventmarker(6) -> successful fixation
                                                                            %hold timeaquired
    fix_ON_time = aBHV.CodeTimes{correct_idx(ii)}(aBHV.CodeNumbers{correct_idx(ii)}==fixON_eventmarker);
                                                                            %find time of successful target hold time
    target_aqrd_time = aBHV.CodeTimes{correct_idx(ii)}(aBHV.CodeNumbers{correct_idx(ii)}==Tacquired_eventmarker);
                                                                            %ETdata is a struct that will hold analog X Y coordinates
                                                                            %of Eye position data truncated from the successful fixation 
                                                                            %hold to the end of target hold
    ETdata(ii).X = aBHV.AnalogData{correct_idx(ii)}.EyeSignal(fix_ON_time:target_aqrd_time,1)';
    ETdata(ii).Y = aBHV.AnalogData{correct_idx(ii)}.EyeSignal(fix_ON_time:target_aqrd_time,2)';
    ETdata(ii).fixTime = fix_ON_time;
    ETdata(ii).targetTime = target_aqrd_time;
end
%  

%--------------------------------------------------------------------------
% Init Event Detection parameters
%--------------------------------------------------------------------------


ETparams.data = ETdata;                                                     %pass on the truncated eye movement data
ETparams.screenSz = [aBHV.ScreenXresolution aBHV.ScreenYresolution];          %from BHV file, pass Screen resolution
ETparams.screenDim = [0.4064 0.3048];                                       %have no idea why this isn't in the BHV file
                                                                            %these are screen dimensions of the in use Dell screen 
                                                                            %in 1701. [ width height ] in m.
ETparams.viewingDist = aBHV.ViewingDistance;                                 %pass on from BHV file
ETparams.samplingFreq = aBHV.AnalogInputFrequency;                           %pass on from BHV file
ETparams.blinkVelocityThreshold = 1000;                                     %if vel > 1000 degrees/s, it is noise or blinks
ETparams.blinkAccThreshold = 100000;                                        %if acc > 100000 degrees/s^2, it is noise or blinks
ETparams.peakDetectionThreshold = 0.12;                                      %Initial value of the peak detection threshold. 
ETparams.minFixDur = 0.03;                                                  %in seconds
ETparams.minSaccadeDur = 0.010;                                             %in seconds


%--------------------------------------------------------------------------
% Adaptive_Event_Detection
%--------------------------------------------------------------------------
                                                                            %event detection algorithm accompanying the article
                                                                            %Nyström, M. & Holmqvist, K. (in press), 
                                                                            %"An adaptive algorithm for fixation, saccade, 
                                                                            %and glissade detection in eye-tracking data". 
                                                                            %Behavior Research Methods

%eventDetection                                                              %run event detection

end


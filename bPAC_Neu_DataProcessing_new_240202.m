
%% Corresponding Neuron-processing to AC-activity


%{
ENTER: 
- Stimulation TimeZones
    - AirPuffs
    - 1P-stim
    - LED-stim
- Total Time
- Number of frames
%}

%% OPTION 1: Taken directly from Fall.mat files

rtdir = 'D:\bPAC Prairie1\240201 bPAC AP';

ExpRounds = dir(rtdir);
ExpRounds = ExpRounds(3:end);

% Start with round 4:
% OBS: Where FaceCam is added (!)

% Manually:
ExpDir = fullfile(ExpRounds(4).folder,ExpRounds(4).name);
% alt: use uiggetdir

[file, path] = uigetfile('*.mat','Select the s2p output file:','Fall.mat');
load(fullfile(path,file))

%% Visualize the and mark/label the individual ROIs and traces





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

%% PatternMatrixGeneration outside Agnos-structure

% input voltage-recordings

[file_v1,path_v1] = uigetfile('*.csv','Select file with voltage recordings');

%{
INSPIRATION FROM RH_Agnos_Strcut_Init_v3:

if ~ip.Results.SliceData
    % import .csv file from voltage recordings
    [file_v1,path_v1] = uigetfile('*.csv','Select file with voltage recordings');
    opts = detectImportOptions(fullfile(path_v1,file_v1));    
    tbl = readtable(fullfile(path_v1,file_v1),opts);
    VarNames = tbl.Properties.VariableNames;

    for g = 1:numel(VarNames)
        TempVar = tbl.(VarNames{g});
        if round(Agnos.FullTime*1000)<numel(TempVar)
            TempVar = TempVar(1:round(Agnos.FullTime*1000));
        end
        Agnos.Ptn.(VarNames{g}) = TempVar;
    end
end

% Construct Pattern-Matrix from VoltageRecording
Agnos = RH_Pattern_Matrix_Generation(Agnos);
%}

%% Make "FAKE" voltage-recording file (PatMat), as we are lacking

% Frq = 11.015 cycles/sec
% 1xbPAC = 100sec from start => 1101.5 cycles, idx = [1:1101]
% AIRPUFFs = 10sec from start, 4 trains, 100msec, each sec => ~5sec total
% 5min wait(?) => idx = [10s, 11s, 12s, 13s, 313s, 314s, 315s, 31s6]
% [110.15	121.165	132.18	143.195	3447.695	3458.71	3469.725	3480.74]
AP_vec = round([110.15	121.165	132.18	143.195	3447.695	3458.71	3469.725	3480.74]);
AP_ext = 2;
% TOTAL TIME for 1xbPAC_2xAP = 4626 cycles / 11.015c/s = 420sec (7min)
temp = zeros(1,size(spks,2));
bPAC_idc = temp;
bPAC_idc(1:1101) = 1;
AP_idc = temp;
for t = 1:length(AP_vec)
    AP_idc(AP_vec(t):AP_vec(t)+2) = 1;
end
AP_bPAC = temp;
AP_bPAC(110:210) = 1;
AP_alone = temp;
AP_alone(3448:3548) = 1;

%% Visualize the and mark/label the individual ROIs and traces

% OBS: Only include "iscell(:,1)"-indexed

FOV = ops.meanImgE;
figure('Position',[122.6000 303.4000 1.3288e+03 420.0000]),
set(gcf,'Color','w')
idxIsC = find(iscell(:,1));
for t = 1:length(idxIsC)
    subplot(3,6,[1:2 7:8 13:14])
    imagesc(FOV)
    % ROI
    xpix = (double(stat{idxIsC(t)}.xpix)+1);
    ypix = (double(stat{idxIsC(t)}.ypix)+1);
    BO = boundary(transpose(xpix),transpose(ypix));
    % FOVvalues
    FOVidc = sub2ind(size(FOV),ypix,xpix); % OBS: notice swap
    FOVvals = FOV(FOVidc);
    %
    hold on
    if mean(FOVvals)>150
        plot(xpix(BO),ypix(BO),'k-')
    elseif mean(FOVvals)<150
        plot(xpix(BO),ypix(BO),'r-')
    end
    hold off
    title(['ROI# ' num2str(idxIsC(t))...
        ' - Avr-val = ' num2str(mean(FOVvals))])

    % Plot RawFluor
    subplot(3,6,3:6)
    Fbgs = F(idxIsC(t),:)-min(F(idxIsC(t),:));
    plot(Fbgs,'k')
    hold on
    % bPAC
    rectangle('Position',[1 min(Fbgs) 1101 max(Fbgs)-min(Fbgs)],...
        'EdgeColor','r','FaceColor',[0.5 0.5 0.5 0.5])
    % APs
    for r = 1:length(AP_vec)
        rectangle('Position',...
            [AP_vec(r) min(Fbgs) 2 max(Fbgs)-min(Fbgs)],...
            'FaceColor',[0.9290 0.6940 0.1250 0.5], 'EdgeColor', [0.9290 0.6940 0.1250 0.5]);
    end
    hold off
    % RATIOS:
    % APs (W/WO): 80sec after first stim = 880 cycles
    % bPAC (W/WO): first 100sec after induction = 1:1101
    
    F_APwwo = sum(Fbgs(AP_vec(1):AP_vec(1)+880))/sum(Fbgs(AP_vec(5):AP_vec(5)+880));
    F_bPACwwo = mean(Fbgs(1:1101))/mean(Fbgs(1102:end));
    title(['Raw-fluorescence, AP-ratio = ' num2str(F_APwwo) ', bPAC-ratio = ' num2str(F_bPACwwo)])
    % plotting Neuropil
    subplot(3,6,9:12)
    Fneubgs = Fneu(idxIsC(t),:)-min(Fneu(idxIsC(t),:));
    plot(Fneubgs,'r')
    hold on
    % bPAC
    rectangle('Position',[1 min(Fneubgs) 1101 max(Fneubgs)-min(Fneubgs)],...
        'EdgeColor','r','FaceColor',[0.5 0.5 0.5 0.5])
    % APs
    for r = 1:length(AP_vec)
        rectangle('Position',...
            [AP_vec(r) min(Fneubgs) 2 max(Fneubgs)-min(Fneubgs)],...
            'FaceColor',[0.9290 0.6940 0.1250 0.5], 'EdgeColor', [0.9290 0.6940 0.1250 0.5]);
    end
    hold off
    % RATIOS
    Fneu_APwwo = sum(Fneubgs(AP_vec(1):AP_vec(1)+880))/sum(Fneubgs(AP_vec(5):AP_vec(5)+880));
    Fneu_bPACwwo = mean(Fneubgs(1:1101))/mean(Fneubgs(1102:end));
    title(['Neuropil-fluorescence, AP-ratio = ' num2str(Fneu_APwwo) ', bPAC-ratio = ' num2str(Fneu_bPACwwo)])
    % plotting spikes
    subplot(3,6,15:18)
    plot(spks(idxIsC(t),:),'k')
    hold on
    % bPAC
    rectangle('Position',[1 min(spks(idxIsC(t),:)) 1101 max(spks(idxIsC(t),:))-min(spks(idxIsC(t),:))],...
        'EdgeColor','r','FaceColor',[0.5 0.5 0.5 0.5])
    % APs
    for r = 1:length(AP_vec)
        rectangle('Position',...
            [AP_vec(r) min(spks(idxIsC(t),:)) 2 max(spks(idxIsC(t),:))-min(spks(idxIsC(t),:))],...
            'FaceColor',[0.9290 0.6940 0.1250 0.5], 'EdgeColor', [0.9290 0.6940 0.1250 0.5]);
    end
    hold off
    % Ratios:
    Spks_APwwo = sum(spks(idxIsC(t),AP_vec(1):AP_vec(1)+880))/sum(spks(idxIsC(t),AP_vec(5):AP_vec(5)+880));
    Spks_bPACwwo = mean(spks(idxIsC(t),1:1101))/mean(spks(idxIsC(t),1102:end));
    title(['Inferred Spikes, AP-ratio = ' num2str(Spks_APwwo) ', bPAC-ratio = ' num2str(Spks_bPACwwo)])

    pause
end

%%  COLLECTING DATA

% ROIs + Avr-Values + Size
% RATIOS - APs + bPACs
% Traces: Fcorr, Fneucorr, Spks

FOV = ops.meanImgE;
idxIsC = find(iscell(:,1));
for t = 1:length(idxIsC)
    % ROI
    xpix = (double(stat{idxIsC(t)}.xpix)+1);
    ypix = (double(stat{idxIsC(t)}.ypix)+1);
    BO = boundary(transpose(xpix),transpose(ypix));
    % FOVvalues
    FOVidc = sub2ind(size(FOV),ypix,xpix); % OBS: notice swap
    FOVvals = FOV(FOVidc);
    R004.pl1.Overview(t).index = idxIsC(t);
    R004.pl1.Overview(t).xpix = xpix;
    R004.pl1.Overview(t).ypix = ypix;
    R004.pl1.Overview(t).BO = BO;
    R004.pl1.Overview(t).FOVval = mean(FOVvals);
    % Raw Fluorescence, Background-corrected
    Fbgs = F(idxIsC(t),:)-min(F(idxIsC(t),:));
    R004.pl1.Overview(t).Fbgs = Fbgs;
    R004.pl1.Overview(t).F_APwwo = sum(Fbgs(AP_vec(1):AP_vec(1)+880))/sum(Fbgs(AP_vec(5):AP_vec(5)+880));
    R004.pl1.Overview(t).F_bPACwwo = mean(Fbgs(1:1101))/mean(Fbgs(1102:end));  
    % Neuropil, Background-corrected
    Fneubgs = Fneu(idxIsC(t),:)-min(Fneu(idxIsC(t),:));
    R004.pl1.Overview(t).Fneubgs = Fneubgs;
    R004.pl1.Overview(t).Fneu_APwwo = sum(Fneubgs(AP_vec(1):AP_vec(1)+880))/sum(Fneubgs(AP_vec(5):AP_vec(5)+880));
    R004.pl1.Overview(t).Fneu_bPACwwo = mean(Fneubgs(1:1101))/mean(Fneubgs(1102:end));
    % Inferred Spikes, background-corrected
    R004.pl1.Overview(t).Spks = spks(idxIsC(t),:);
    R004.pl1.Overview(t).Spks_APwwo = sum(spks(idxIsC(t),AP_vec(1):AP_vec(1)+880))/sum(spks(idxIsC(t),AP_vec(5):AP_vec(5)+880));
    R004.pl1.Overview(t).Spks_bPACwwo = mean(spks(idxIsC(t),1:1101))/mean(spks(idxIsC(t),1102:end));
end

%% GRAPHS

% start with histogram or cdf (later maybe beeswarm for graphics)

figure,
subplot(2,1,1)
h = histogram([R004.pl1.Overview.Spks_APwwo],30);
hold on
plot([1 1],[0 1.2*max(h.Values)],'r--')
hold off
title('Ratio: Spikes after AirPuffs (with bPAC/wo bPAC)')
subplot(2,1,2)
h = histogram([R004.pl1.Overview.Spks_bPACwwo],30);
hold on
plot([1 1],[0 1.2*max(h.Values)],'r--')
hold off
xlim([0.3 1.7])
title('Ratio: Spikes with bPAC/wo bPAC)')
set(gcf,'Color','w')


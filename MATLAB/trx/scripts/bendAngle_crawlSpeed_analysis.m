%%
%%%%%%%%%%%%%%%%%%%%%%%
%%%%    Analysis raw from trx files


% Various control data
dir_cantons = '/Volumes/TOSHIBA/t2/CantonS@CantonS';
[dS_cantons, velo_cantons, len_cantons] = histBendSpeed(dir_cantons);

dir_cantons_Ab40 = '/Volumes/TOSHIBA/t2/CantonS@UAS_Abeta40_116';
[dS_cantons_Ab40, velo_cantons_Ab40, len_cantons_Ab40] = histBendSpeed(dir_cantons_Ab40);

dir_cantons_Ab42 = '/Volumes/TOSHIBA/t2/CantonS@UAS_Abeta42_117';
[dS_cantons_Ab42, velo_cantons_Ab42, len_cantons_Ab42] = histBendSpeed(dir_cantons_Ab42);

dir_csmh = '/Volumes/TOSHIBA/t2/CS@CS';
[dS_csmh, velo_csmh, len_csmh] = histBendSpeed(dir_csmh);

dir_csmh_Ab40 = '/Volumes/TOSHIBA/t2/CS@UAS_Abeta40_116';
[dS_csmh_Ab40, velo_csmh_Ab40, len_csmh_Ab40] = histBendSpeed(dir_csmh_Ab40);

dir_csmh_Ab42 = '/Volumes/TOSHIBA/t2/CS@UAS_Abeta42_117';
[dS_csmh_Ab42, velo_csmh_Ab42, len_csmh_Ab42] = histBendSpeed(dir_csmh_Ab42);

dir_Ab42_Ab42 = '/Volumes/TOSHIBA/t2/UAS_Abeta42_117@UAS_Abeta42_117';
[dS_Ab42_Ab42, velo_Ab42_Ab42, len_Ab42_Ab42] = histBendSpeed(dir_Ab42_Ab42);

dir_Ab40_Ab40 = '/Volumes/TOSHIBA/t2/UAS_Abeta40_116@UAS_Abeta40_116';
[dS_Ab40_Ab40, velo_Ab40_Ab40, len_Ab40_Ab40] = histBendSpeed(dir_Ab40_Ab40);

% Janelia data control attP2>TNT
dir_attP2_tnt = '/Volumes/TOSHIBA/TIHANA_JANELIA_DATA/FCF_attP2@TNT_2';
[dS_attP2_tnt, velo_attP2_tnt, len_attP2_tnt] = histBendSpeed(dir_attP2_tnt);

% control attP2
dir_attP2_Ab40 = '/Volumes/TOSHIBA/t2/FCF_attP2@UAS_Abeta40_116';
[dS_attP2_Ab40, velo_attP2_Ab40, len_attP2_Ab40] = histBendSpeed(dir_attP2_Ab40);

dir_attP2_Ab42 = '/Volumes/TOSHIBA/t2/FCF_attP2@UAS_Abeta42_117';
[dS_attP2_Ab42, velo_attP2_Ab42, len_attP2_Ab42] = histBendSpeed(dir_attP2_Ab42);

% Cho
dir_R61D08_Ab40 ='/Volumes/TOSHIBA/t2/GMR_61D08@UAS_Abeta40_116';
[dS_R61D08_Ab40, velo_R61D08_Ab40, len_R61D08_Ab40] = histBendSpeed(dir_R61D08_Ab40);

dir_R61D08_Ab42 ='/Volumes/TOSHIBA/t2/GMR_61D08@UAS_Abeta42_117';
[dS_R61D08_Ab42, velo_R61D08_Ab42, len_R61D08_Ab42] = histBendSpeed(dir_R61D08_Ab42);

% Basin-1
dir_R20B01_Ab40 = '/Volumes/TOSHIBA/t2/GMR_20B01@UAS_Abeta40_116';
[dS_R20B01_Ab40, velo_R20B01_Ab40, len_R20B01_Ab40] = histBendSpeed(dir_R20B01_Ab40);

dir_R20B01_Ab42 = '/Volumes/TOSHIBA/t2/GMR_20B01@UAS_Abeta42_117';
[dS_R20B01_Ab42, velo_R20B01_Ab42, len_R20B01_Ab42] = histBendSpeed(dir_R20B01_Ab42);

% pan-neuronal
dir_R57C10_Ab40 = '/Volumes/TOSHIBA/t2/GMR_57C10@UAS_Abeta40_116';
[dS_R57C10_Ab40, velo_R57C10_Ab40, len_R57C10_Ab40] = histBendSpeed(dir_R57C10_Ab40);

dir_R57C10_Ab42 = '/Volumes/TOSHIBA/t2/GMR_57C10@UAS_Abeta42_117';
[dS_R57C10_Ab42, velo_R57C10_Ab42, len_R57C10_Ab42] = histBendSpeed(dir_R57C10_Ab42);

% control split gal-4 attP2-40
dir_attP2_40_Ab40 = '/Volumes/TOSHIBA/t2/FCF_attP2-40@UAS_Abeta40_116/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n';
[dS_attP2_40_Ab40, velo_attP2_40_Ab40, len_attP2_40_Ab40] = histBendSpeed(dir_attP2_40_Ab40);

dir_attP2_40_Ab42 = '/Volumes/TOSHIBA/t2/FCF_attP2-40@UAS_Abeta42_117/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n';
[dS_attP2_40_Ab42, velo_attP2_40_Ab42, len_attP2_40_Ab42] = histBendSpeed(dir_attP2_40_Ab42);

% basin-2
dir_SS00739_Ab40 = '/Volumes/TOSHIBA/t2/GMR_SS00739@UAS_Abeta40_116/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n'
[dS_SS00739_Ab40, velo_SS00739_Ab40, len_SS00739_Ab40] = histBendSpeed(dir_SS00739_Ab40);

dir_SS00739_Ab42 = '/Volumes/TOSHIBA/t2/GMR_SS00739@UAS_Abeta42_117/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n';
[dS_SS00739_Ab42, velo_SS00739_Ab42, len_SS00739_Ab42] = histBendSpeed(dir_SS00739_Ab42);

% handle-b (Hb, LNb)
dir_SS00888_Ab40 = '/Volumes/TOSHIBA/t2/GMR_SS00888@UAS_Abeta40_116/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n';
[dS_SS00888_Ab40, velo_SS00888_Ab40, len_SS00888_Ab40] = histBendSpeed(dir_SS00888_Ab40);

dir_SS00888_Ab42 = '/Volumes/TOSHIBA/t2/GMR_SS00888@UAS_Abeta42_117/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n';
[dS_SS00888_Ab42, velo_SS00888_Ab42, len_SS00888_Ab42] = histBendSpeed(dir_SS00888_Ab42);

% griddle-2 (G2, LNa)
dir_SS00918_Ab40 = '/Volumes/TOSHIBA/t2/GMR_SS00918@UAS_Abeta40_116/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n';
[dS_SS00918_Ab40, velo_SS00918_Ab40, len_SS00918_Ab40] = histBendSpeed(dir_SS00918_Ab40);

dir_SS00918_Ab42 = '/Volumes/TOSHIBA/t2/GMR_SS00918@UAS_Abeta42_117/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n';
[dS_SS00918_Ab42, velo_SS00918_Ab42, len_SS00918_Ab42] = histBendSpeed(dir_SS00918_Ab42);

% clean up workspace and remove directory links
clear dir*

%% exploratory analysis on larval bending dynamics
S = {dS_attP2_tnt(:,3),dS_attP2_Ab40(:,3),dS_attP2_40_Ab40(:,3),dS_cantons(:,3),dS_cantons_Ab40(:,3),...
    dS_csmh(:,3),dS_csmh_Ab40(:,3),dS_Ab40_Ab40(:,3),dS_Ab42_Ab42(:,3)};
grpS = cell2mat(arrayfun(@(i){i*ones(numel(S{i}),1)},(1:numel(S))')); 
V = {velo_attP2_tnt(:,3),velo_attP2_Ab40(:,3),velo_attP2_40_Ab40(:,3),velo_cantons(:,3),...
    velo_cantons_Ab40(:,3),velo_csmh(:,3),velo_csmh_Ab40(:,3),velo_Ab40_Ab40(:,3),velo_Ab42_Ab42(:,3)};
grpV = cell2mat(arrayfun(@(i){i*ones(numel(V{i}),1)},(1:numel(V))')); 

figure(1)
subplot(1,2,1)
plotSpread(S,'categoryIdx',grpS,'xNames',{'attP2xTNT','attP2xAb40','attP2-40xAb40','CantonS','CantonSxAb40',...
    'CSMH','CSMHxAb40','Ab40xAb40','Ab42xAb42'},'showMM',4)
ylabel('dS when bending')
xtickangle(90)
ylim([-0.2 0.2])
subplot(1,2,2)
plotSpread(V,'categoryIdx',grpV,'xNames',{'attP2xTNT','attP2xAb40','attP2-40xAb40','CantonS','CantonSxAb40',...
    'CSMH','CSMHxAb40','Ab40xAb40','Ab42xAb42'},'showMM',4)
ylabel('Velocity when crawling')
xtickangle(90)
ylim([0 0.05])

%% %% Figure 1: attP2 x Ab40 group
Ab40_S1 = {dS_attP2_Ab40(:,1),dS_R57C10_Ab40(:,1),dS_R61D08_Ab40(:,1),dS_R20B01_Ab40(:,1)};
Ab40_S2 = {dS_attP2_Ab40(:,2),dS_R57C10_Ab40(:,2),dS_R61D08_Ab40(:,2),dS_R20B01_Ab40(:,2)};
Ab40_S3 = {dS_attP2_Ab40(:,3),dS_R57C10_Ab40(:,3),dS_R61D08_Ab40(:,2),dS_R20B01_Ab40(:,3)};    
grpS = cell2mat(arrayfun(@(i){i*ones(numel(Ab40_S1{i}),1)},(1:numel(Ab40_S1))')); 

Ab40_V1 = {velo_attP2_Ab40(:,1),velo_R57C10_Ab40(:,1),velo_R61D08_Ab40(:,1),velo_R20B01_Ab40(:,1)};
Ab40_V2 = {velo_attP2_Ab40(:,2),velo_R57C10_Ab40(:,2),velo_R61D08_Ab40(:,2),velo_R20B01_Ab40(:,2)};
Ab40_V3 = {velo_attP2_Ab40(:,3),velo_R57C10_Ab40(:,3),velo_R61D08_Ab40(:,3),velo_R20B01_Ab40(:,3)};
grpV = cell2mat(arrayfun(@(i){i*ones(numel(Ab40_V1{i}),1)},(1:numel(Ab40_V1))')); 

Ab40_L = {len_attP2_Ab40(:),len_R57C10_Ab40(:),len_R61D08_Ab40(:),len_R20B01_Ab40(:)};
grpL = cell2mat(arrayfun(@(i){i*ones(numel(Ab40_L{i}),1)},(1:numel(Ab40_L))')); 

figure(1)
subplot(2,3,1)
plotSpread(Ab40_S1,'categoryIdx',grpS,'categoryColors',[0,0,0; 0.8,0,0.2; 0.3,0.7,0.2 ; 0.3,0.6,1],'showMM',4)
title('Before Initial Stimulus')
ylabel('dS when bending')
ylim([-0.2 0.2])
subplot(2,3,2)
plotSpread(Ab40_S2,'categoryIdx',grpS,'categoryColors',[0,0,0; 0.8,0,0.2; 0.3,0.7,0.2 ; 0.3,0.6,1],'showMM',4)
title('During Initial Stimulus')
ylabel('dS when bending')
ylim([-0.2 0.2])
subplot(2,3,3)
plotSpread(Ab40_S3,'categoryIdx',grpS,'categoryColors',[0,0,0; 0.8,0,0.2; 0.3,0.7,0.2 ; 0.3,0.6,1],'showMM',4)
title('After Initial Stimulus')
ylabel('dS when bending')
ylim([-0.2 0.2])
subplot(2,3,4)
plotSpread(Ab40_V1,'categoryIdx',grpV,'categoryColors',[0,0,0; 0.8,0,0.2; 0.3,0.7,0.2 ; 0.3,0.6,1],'showMM',4)
ylabel('Velosdty when crawling')
ylim([0 0.05])
subplot(2,3,5)
plotSpread(Ab40_V2,'categoryIdx',grpV,'categoryColors',[0,0,0; 0.8,0,0.2; 0.3,0.7,0.2 ; 0.3,0.6,1],'showMM',4)
ylabel('Velosdty when crawling')
ylim([0 0.05])
subplot(2,3,6)
plotSpread(Ab40_V3,'categoryIdx',grpV,'categoryColors',[0,0,0; 0.8,0,0.2; 0.3,0.7,0.2 ; 0.3,0.6,1],'showMM',4)
ylabel('Velosdty when crawling')
ylim([0 0.05])

%% Figure 2: attP2 x Ab42 group
Ab42_S1 = {dS_attP2_Ab42(:,1),dS_R57C10_Ab42(:,1),dS_R61D08_Ab42(:,1),dS_R20B01_Ab42(:,1)};
Ab42_S2 = {dS_attP2_Ab42(:,2),dS_R57C10_Ab42(:,2),dS_R61D08_Ab42(:,2),dS_R20B01_Ab42(:,2)};
Ab42_S3 = {dS_attP2_Ab42(:,3),dS_R57C10_Ab42(:,3),dS_R61D08_Ab42(:,2),dS_R20B01_Ab42(:,3)};    
grpS = cell2mat(arrayfun(@(i){i*ones(numel(Ab42_S1{i}),1)},(1:numel(Ab42_S1))')); 

Ab42_V1 = {velo_attP2_Ab42(:,1),velo_R57C10_Ab42(:,1),velo_R61D08_Ab42(:,1),velo_R20B01_Ab42(:,1)};
Ab42_V2 = {velo_attP2_Ab42(:,2),velo_R57C10_Ab42(:,2),velo_R61D08_Ab42(:,2),velo_R20B01_Ab42(:,2)};
Ab42_V3 = {velo_attP2_Ab42(:,3),velo_R57C10_Ab42(:,3),velo_R61D08_Ab42(:,3),velo_R20B01_Ab42(:,3)};
grpV = cell2mat(arrayfun(@(i){i*ones(numel(Ab42_V1{i}),1)},(1:numel(Ab42_V1))')); 

Ab42_L = {len_attP2_Ab42(:),len_R57C10_Ab42(:),len_R61D08_Ab42(:),len_R20B01_Ab42(:)};
grpL = cell2mat(arrayfun(@(i){i*ones(numel(Ab42_L{i}),1)},(1:numel(Ab42_L))')); 

figure(2)
subplot(2,3,1)
plotSpread(Ab42_S1,'categoryIdx',grpS,'categoryColors',[0,0,0; 0.8,0,0.2; 0.3,0.7,0.2 ; 0.3,0.6,1],'showMM',4)
title('Before Initial Stimulus')
ylabel('dS when bending')
ylim([-0.2 0.2])
subplot(2,3,2)
plotSpread(Ab42_S2,'categoryIdx',grpS,'categoryColors',[0,0,0; 0.8,0,0.2; 0.3,0.7,0.2 ; 0.3,0.6,1],'showMM',4)
title('During Initial Stimulus')
ylabel('dS when bending')
ylim([-0.2 0.2])
subplot(2,3,3)
plotSpread(Ab42_S3,'categoryIdx',grpS,'categoryColors',[0,0,0; 0.8,0,0.2; 0.3,0.7,0.2 ; 0.3,0.6,1],'showMM',4)
title('After Initial Stimulus')
ylabel('dS when bending')
ylim([-0.2 0.2])
subplot(2,3,4)
plotSpread(Ab42_V1,'categoryIdx',grpV,'categoryColors',[0,0,0; 0.8,0,0.2; 0.3,0.7,0.2 ; 0.3,0.6,1],'showMM',4)
ylabel('Velosdty when crawling')
ylim([0 0.05])
subplot(2,3,5)
plotSpread(Ab42_V2,'categoryIdx',grpV,'categoryColors',[0,0,0; 0.8,0,0.2; 0.3,0.7,0.2 ; 0.3,0.6,1],'showMM',4)
ylabel('Velosdty when crawling')
ylim([0 0.05])
subplot(2,3,6)
plotSpread(Ab42_V3,'categoryIdx',grpV,'categoryColors',[0,0,0; 0.8,0,0.2; 0.3,0.7,0.2 ; 0.3,0.6,1],'showMM',4)
ylabel('Velosdty when crawling')
ylim([0 0.05])

%% figure 3: attP2-40 x Ab42 group
Ab42_S1 = {dS_attP2_40_Ab42(:,1),dS_SS00739_Ab42(:,1),dS_SS00888_Ab42(:,1),dS_SS00918_Ab42(:,1)};
Ab42_S2 = {dS_attP2_40_Ab42(:,2),dS_SS00739_Ab42(:,2),dS_SS00888_Ab42(:,2),dS_SS00918_Ab42(:,2)};
Ab42_S3 = {dS_attP2_40_Ab42(:,3),dS_SS00739_Ab42(:,3),dS_SS00888_Ab42(:,2),dS_SS00918_Ab42(:,3)};    
grpS = cell2mat(arrayfun(@(i){i*ones(numel(Ab42_S1{i}),1)},(1:numel(Ab42_S1))')); 

Ab42_V1 = {velo_attP2_40_Ab42(:,1),velo_SS00739_Ab42(:,1),velo_SS00888_Ab42(:,1),velo_SS00918_Ab42(:,1)};
Ab42_V2 = {velo_attP2_40_Ab42(:,2),velo_SS00739_Ab42(:,2),velo_SS00888_Ab42(:,2),velo_SS00918_Ab42(:,2)};
Ab42_V3 = {velo_attP2_40_Ab42(:,3),velo_SS00739_Ab42(:,3),velo_SS00888_Ab42(:,3),velo_SS00918_Ab42(:,3)};
grpV = cell2mat(arrayfun(@(i){i*ones(numel(Ab42_V1{i}),1)},(1:numel(Ab42_V1))')); 

Ab42_L = {len_attP2_40_Ab42(:),len_SS00739_Ab42(:),len_SS00888_Ab42(:),len_SS00918_Ab42(:)};
grpL = cell2mat(arrayfun(@(i){i*ones(numel(Ab42_L{i}),1)},(1:numel(Ab42_L))')); 

figure(3)
subplot(2,3,1)
plotSpread(Ab42_S1,'categoryIdx',grpS,'categoryColors',[0,0,0; 0,0.4,1; 0.9,0.2,0.5; 0.9,0.5,0],'showMM',4)
title('Before Initial Stimulus')
ylabel('dS when bending')
ylim([-0.2 0.2])
subplot(2,3,2)
plotSpread(Ab42_S2,'categoryIdx',grpS,'categoryColors',[0,0,0; 0,0.4,1; 0.9,0.2,0.5; 0.9,0.5,0],'showMM',4)
title('During Initial Stimulus')
ylabel('dS when bending')
ylim([-0.2 0.2])
subplot(2,3,3)
plotSpread(Ab42_S3,'categoryIdx',grpS,'categoryColors',[0,0,0; 0,0.4,1; 0.9,0.2,0.5; 0.9,0.5,0],'showMM',4)
title('After Initial Stimulus')
ylabel('dS when bending')
ylim([-0.2 0.2])
subplot(2,3,4)
plotSpread(Ab42_V1,'categoryIdx',grpV,'categoryColors',[0,0,0; 0,0.4,1; 0.9,0.2,0.5; 0.9,0.5,0],'showMM',4)
ylabel('Velosdty when crawling')
ylim([0 0.05])
subplot(2,3,5)
plotSpread(Ab42_V2,'categoryIdx',grpV,'categoryColors',[0,0,0; 0,0.4,1; 0.9,0.2,0.5; 0.9,0.5,0],'showMM',4)
ylabel('Velosdty when crawling')
ylim([0 0.05])
subplot(2,3,6)
plotSpread(Ab42_V3,'categoryIdx',grpV,'categoryColors',[0,0,0; 0,0.4,1; 0.9,0.2,0.5; 0.9,0.5,0],'showMM',4)
ylabel('Velosdty when crawling')
ylim([0 0.05])


%% Figure 4: attP2-40 x Ab40 group
Ab40_S1 = {dS_attP2_40_Ab40(:,1),dS_SS00739_Ab40(:,1),dS_SS00888_Ab40(:,1),dS_SS00918_Ab40(:,1)};
Ab40_S2 = {dS_attP2_40_Ab40(:,2),dS_SS00739_Ab40(:,2),dS_SS00888_Ab40(:,2),dS_SS00918_Ab40(:,2)};
Ab40_S3 = {dS_attP2_40_Ab40(:,3),dS_SS00739_Ab40(:,3),dS_SS00888_Ab40(:,2),dS_SS00918_Ab40(:,3)};    
grpS = cell2mat(arrayfun(@(i){i*ones(numel(Ab40_S1{i}),1)},(1:numel(Ab40_S1))')); 

Ab40_V1 = {velo_attP2_40_Ab40(:,1),velo_SS00739_Ab40(:,1),velo_SS00888_Ab40(:,1),velo_SS00918_Ab40(:,1)};
Ab40_V2 = {velo_attP2_40_Ab40(:,2),velo_SS00739_Ab40(:,2),velo_SS00888_Ab40(:,2),velo_SS00918_Ab40(:,2)};
Ab40_V3 = {velo_attP2_40_Ab40(:,3),velo_SS00739_Ab40(:,3),velo_SS00888_Ab40(:,3),velo_SS00918_Ab40(:,3)};
grpV = cell2mat(arrayfun(@(i){i*ones(numel(Ab40_V1{i}),1)},(1:numel(Ab40_V1))')); 

Ab40_L = {len_attP2_40_Ab40(:),len_SS00739_Ab40(:),len_SS00888_Ab40(:),len_SS00918_Ab40(:)};
grpL = cell2mat(arrayfun(@(i){i*ones(numel(Ab40_L{i}),1)},(1:numel(Ab40_L))')); 

figure(4)
subplot(2,3,1)
plotSpread(Ab40_S1,'categoryIdx',grpS,'categoryColors',[0,0,0; 0,0.4,1; 0.9,0.2,0.5; 0.9,0.5,0],'showMM',4)
title('Before Initial Stimulus')
ylabel('dS when bending')
ylim([-0.2 0.2])
subplot(2,3,2)
plotSpread(Ab40_S2,'categoryIdx',grpS,'categoryColors',[0,0,0; 0,0.4,1; 0.9,0.2,0.5; 0.9,0.5,0],'showMM',4)
title('During Initial Stimulus')
ylabel('dS when bending')
ylim([-0.2 0.2])
subplot(2,3,3)
plotSpread(Ab40_S3,'categoryIdx',grpS,'categoryColors',[0,0,0; 0,0.4,1; 0.9,0.2,0.5; 0.9,0.5,0],'showMM',4)
title('After Initial Stimulus')
ylabel('dS when bending')
ylim([-0.2 0.2])
subplot(2,3,4)
plotSpread(Ab40_V1,'categoryIdx',grpV,'categoryColors',[0,0,0; 0,0.4,1; 0.9,0.2,0.5; 0.9,0.5,0],'showMM',4)
ylabel('Velosdty when crawling')
ylim([0 0.05])
subplot(2,3,5)
plotSpread(Ab40_V2,'categoryIdx',grpV,'categoryColors',[0,0,0; 0,0.4,1; 0.9,0.2,0.5; 0.9,0.5,0],'showMM',4)
ylabel('Velosdty when crawling')
ylim([0 0.05])
subplot(2,3,6)
plotSpread(Ab40_V3,'categoryIdx',grpV,'categoryColors',[0,0,0; 0,0.4,1; 0.9,0.2,0.5; 0.9,0.5,0],'showMM',4)
ylabel('Velosdty when crawling')
ylim([0 0.05])

%% Figure 5
Ab40_L = {len_attP2_40_Ab40(:),len_SS00739_Ab40(:),len_SS00888_Ab40(:),len_SS00918_Ab40(:)};
grpL1 = cell2mat(arrayfun(@(i){i*ones(numel(Ab40_L{i}),1)},(1:numel(Ab40_L))'));

Ab42_L = {len_attP2_40_Ab42(:),len_SS00739_Ab42(:),len_SS00888_Ab42(:),len_SS00918_Ab42(:)};
grpL2 = cell2mat(arrayfun(@(i){i*ones(numel(Ab42_L{i}),1)},(1:numel(Ab42_L))')); 

figure(5)
subplot(1,2,1)
plotSpread(Ab40_L,'categoryIdx',grpL1,'categoryColors',[0,0,0; 0,0.4,1; 0.9,0.2,0.5; 0.9,0.5,0],...
'xNames',{'attP2-40xAb40','SS00739xAb40','SS00888xAb40','SS00918xAb40'},'showMM',4)
ylabel('Length when hunching')
subplot(1,2,2)
plotSpread(Ab42_L,'categoryIdx',grpL2,'categoryColors',[0,0,0; 0,0.4,1; 0.9,0.2,0.5; 0.9,0.5,0],...
'xNames',{'attP2-40xAb40','SS00739xAb40','SS00888xAb40','SS00918xAb40'},'showMM',4)
ylabel('Length when hunching')

%%

Ab40_L = {len_attP2_Ab40(:),len_R57C10_Ab40(:),len_R61D08_Ab40(:),len_R20B01_Ab40(:)};
grpL1 = cell2mat(arrayfun(@(i){i*ones(numel(Ab40_L{i}),1)},(1:numel(Ab40_L))'));

Ab42_L = {len_attP2_Ab42(:),len_R57C10_Ab42(:),len_R61D08_Ab42(:),len_R20B01_Ab42(:)};
grpL2 = cell2mat(arrayfun(@(i){i*ones(numel(Ab42_L{i}),1)},(1:numel(Ab42_L))')); 
figure(6)
subplot(1,2,1)
plotSpread(Ab40_L,'categoryIdx',grpL1,'categoryColors',[0,0,0; 0.8,0,0.2; 0.3,0.7,0.2 ; 0.3,0.6,1],...
'xNames',{'attP2xAb40','R57C10xAb40','R61D08xAb40','R20B01xAb40'},'showMM',4)
ylabel('Length when hunching')
subplot(1,2,2)
plotSpread(Ab42_L,'categoryIdx',grpL2,'categoryColors',[0,0,0; 0.8,0,0.2; 0.3,0.7,0.2 ; 0.3,0.6,1],...
'xNames',{'attP2xAb40','R57C10xAb40','R61D08xAb40','R20B01xAb40'},'showMM',4)
ylabel('Length when hunching')

%% check if the default parameters are in similiar percentile of data
limit_dS=0.25; % dS threshold for considering head cast VS bend
limit_velo=0.01; % minimum velocity to classify as head cast

% compute percentile information for all control genotypes with Ab40
nless = sum(dS_attP2_tnt < limit_dS);
nequal = sum(dS_attP2_tnt == limit_dS);
centile_dS_attP2_tnt = 100 * (nless + 0.5*nequal) / length(dS_attP2_tnt)

nless = sum(dS_attP2_Ab40 < limit_dS);
nequal = sum(dS_attP2_Ab40 == limit_dS);
centile_dS_attP2_Ab40 = 100 * (nless + 0.5*nequal) / length(dS_attP2_Ab40)

nless = sum(dS_attP2_40_Ab40 < limit_dS);
nequal = sum(dS_attP2_40_Ab40 == limit_dS);
centile_dS_attP2_40_Ab40 = 100 * (nless + 0.5*nequal) / length(dS_attP2_40_Ab40)

nless = sum(velo_attP2_tnt < limit_velo);
nequal = sum(velo_attP2_tnt == limit_velo);
centile_velo_attP2_tnt = 100 * (nless + 0.5*nequal) / length(velo_attP2_tnt)

nless = sum(velo_attP2_Ab40 < limit_velo);
nequal = sum(velo_attP2_Ab40 == limit_velo);
centile_velo_attP2_Ab40 = 100 * (nless + 0.5*nequal) / length(velo_attP2_Ab40)

nless = sum(velo_attP2_40_Ab40 < limit_velo);
nequal = sum(velo_attP2_40_Ab40 == limit_velo);
centile_velo_attP2_40_Ab40 = 100 * (nless + 0.5*nequal) / length(velo_attP2_40_Ab40)

nless = sum(dS_cantons < limit_dS);
nequal = sum(dS_cantons == limit_dS);
centile_dS_cantons = 100 * (nless + 0.5*nequal) / length(dS_cantons)

nless = sum(velo_cantons < limit_velo);
nequal = sum(velo_cantons == limit_velo);
centile_velo_cantons = 100 * (nless + 0.5*nequal) / length(velo_cantons)

nless = sum(dS_cantons_Ab40 < limit_dS);
nequal = sum(dS_cantons_Ab40 == limit_dS);
centile_dS_cantons_Ab40 = 100 * (nless + 0.5*nequal) / length(dS_cantons_Ab40)

nless = sum(velo_cantons_Ab40 < limit_velo);
nequal = sum(velo_cantons_Ab40 == limit_velo);
centile_velo_cantons_Ab40 = 100 * (nless + 0.5*nequal) / length(velo_cantons_Ab40)

nless = sum(dS_csmh_Ab40 < limit_dS);
nequal = sum(dS_csmh_Ab40 == limit_dS);
centile_dS_csmh_Ab40 = 100 * (nless + 0.5*nequal) / length(dS_csmh_Ab40)

nless = sum(velo_csmh_Ab40 < limit_velo);
nequal = sum(velo_csmh_Ab40 == limit_velo);
centile_velo_csmh_Ab40 = 100 * (nless + 0.5*nequal) / length(velo_csmh_Ab40)

nless = sum(dS_csmh < limit_dS);
nequal = sum(dS_csmh == limit_dS);
centile_dS_csmh = 100 * (nless + 0.5*nequal) / length(dS_csmh)

nless = sum(velo_csmh < limit_velo);
nequal = sum(velo_csmh == limit_velo);
centile_velo_csmh = 100 * (nless + 0.5*nequal) / length(velo_csmh)

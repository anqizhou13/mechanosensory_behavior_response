%%%%%%%%%%%%%%%%%%%%%%%%%%%
     % section 1 instantiate all variables by reading in data
%%%%%%%%%%%%%%%%%%%%%%%%%%%

t = 100; % resolution for smoothing
ncol = 6; % number of columns from Choreography output
maxdat = 3000; % an arbitrary value that's larger than number of data points present
% so that a nan matrix can be instantiated

%%%%%%%%%%%%%%%%%% Genotype: attP2 > Abeta 1-40
rootdir = '/Volumes/TOSHIBA/t2/FCF_attP2@UAS_Abeta40_116';
filelist = dir(fullfile(rootdir, '**/*.dat')); 
rep = length(filelist);

attP2_Ab40 = NaN(rep,maxdat,ncol);

for i = 1:length(filelist)
    f = readtable(filelist(i).name);
    f = table2array(f);
    attP2_Ab40(i,1:length(f),:) = f(:,:);
    clear f;
end

attP2_Ab40_reshape = reshape(attP2_Ab40,[maxdat*length(filelist),ncol]);
attP2_Ab40_reshape = sortrows(attP2_Ab40_reshape);
[attP2_Ab40_smMean,attP2_Ab40_smSEM, attP2_Ab40_smSD] = smoothdat(attP2_Ab40_reshape,t,0);

%%%%%%%%%%%%%%%%%% Genotype: attP2 > Abeta 1-42
rootdir = '/Volumes/TOSHIBA/FCF_attP2@UAS_Abeta42_117';
filelist = dir(fullfile(rootdir, '**/*.dat')); 
rep = length(filelist);

attP2_Ab42 = NaN(rep,3000,6);

for i = 1:length(filelist)
    f = readtable(filelist(i).name);
    f = table2array(f);
    attP2_Ab42(i,1:length(f),:) = f(:,:);
    clear f;
end

attP2_Ab42_reshape = reshape(attP2_Ab42,[3000*length(filelist),6]);
attP2_Ab42_reshape = sortrows(attP2_Ab42_reshape);

[attP2_Ab42_smMean,attP2_Ab42_smSEM, attP2_Ab42_smSD] = smoothdat(attP2_Ab42_reshape,t,0);

%%%%%%%%%%%%%%%%%% Genotype: R57C10 > Abeta 1-40
rootdir = '/Volumes/TOSHIBA/GMR_57C10@UAS_Abeta40_116';
filelist = dir(fullfile(rootdir, '**/*.dat')); 
rep = length(filelist);

R57C10_Ab40 = NaN(rep,3000,6);

for i = 1:length(filelist)
    f = readtable(filelist(i).name);
    f = table2array(f);
    R57C10_Ab40(i,1:length(f),:) = f(:,:);
    clear f;
end

R57C10_Ab40_reshape = sortrows(reshape(R57C10_Ab40,[3000*length(filelist),6]));
[R57C10_Ab40_smMean, R57C10_Ab40_smSEM, R57C10_Ab40_smSD] = smoothdat(R57C10_Ab40_reshape,t,0);


%%%%%%%%%%%%%%%%%% Genotype: R57C10 > Abeta 1-42
rootdir = '/Volumes/TOSHIBA/GMR_57C10@UAS_Abeta42_117';
filelist = dir(fullfile(rootdir, '**/*.dat')); 
rep = length(filelist);

R57C10_Ab42 = NaN(rep,3000,6);

for i = 1:length(filelist)
    f = readtable(filelist(i).name);
    f = table2array(f);
    R57C10_Ab42(i,1:length(f),:) = f(:,:);
    clear f;
end

R57C10_Ab42_reshape = sortrows(reshape(R57C10_Ab42,[3000*length(filelist),6]));
[R57C10_Ab42_smMean, R57C10_Ab42_smSEM, R57C10_Ab42_smSD] = smoothdat(R57C10_Ab42_reshape,t,0);

%%%%%%%%%%%%%%%%%% Genotype: R61D08 > Abeta 1-40
rootdir = '/Volumes/TOSHIBA/GMR_61D08@UAS_Abeta40_116';
filelist = dir(fullfile(rootdir, '**/*.dat')); 
rep = length(filelist);

R61D08_Ab40 = NaN(rep,3000,6);

for i = 1:length(filelist)
    f = readtable(filelist(i).name);
    f = table2array(f);
    R61D08_Ab40(i,1:length(f),:) = f(:,:);
    clear f;
end

R61D08_Ab40_reshape = sortrows(reshape(R61D08_Ab40,[3000*length(filelist),6]));
[R61D08_Ab40_smMean, R61D08_Ab40_smSEM, R61D08_Ab40_smSD] = smoothdat(R61D08_Ab40_reshape,t,0);

%%%%%%%%%%%%%%%%%%% Genotype: 61D08 > Abeta 1-42
rootdir = '/Volumes/TOSHIBA/GMR_61D08@UAS_Abeta42_117';
filelist = dir(fullfile(rootdir, '**/*.dat')); 
rep = length(filelist);

R61D08_Ab42 = NaN(rep,3000,6);

for i = 1:length(filelist)
    f = readtable(filelist(i).name);
    f = table2array(f);
    R61D08_Ab42(i,1:length(f),:) = f(:,:);
    clear f;
end

R61D08_Ab42_reshape = sortrows(reshape(R61D08_Ab42,[3000*length(filelist),6]));
[R61D08_Ab42_smMean, R61D08_Ab42_smSEM, R61D08_Ab42_smSD] = smoothdat(R61D08_Ab42_reshape,t,0);


%%%%%%%%%%%%%%%%%% Genotype: R20B01 > Abeta 1-40
rootdir = '/Volumes/TOSHIBA/GMR_20B01@UAS_Abeta40_116';
filelist = dir(fullfile(rootdir, '**/*.dat')); 
rep = length(filelist);

R20B01_Ab40 = NaN(rep,3000,6);

for i = 1:length(filelist)
    f = readtable(filelist(i).name);
    f = table2array(f);
    R20B01_Ab40(i,1:length(f),:) = f(:,:);
    clear f;
end

R20B01_Ab40_reshape = sortrows(reshape(R20B01_Ab40,[3000*length(filelist),6]));
[R20B01_Ab40_smMean, R20B01_Ab40_smSEM, R20B01_Ab40_smSD] = smoothdat(R20B01_Ab40_reshape,t,0);

rootdir = '/Volumes/TOSHIBA/GMR_20B01@UAS_Abeta42_117';
filelist = dir(fullfile(rootdir, '**/*.dat')); 
rep = length(filelist);

R20B01_Ab42 = NaN(rep,3000,6);

for i = 1:length(filelist)
    f = readtable(filelist(i).name);
    f = table2array(f);
    R20B01_Ab42(i,1:length(f),:) = f(:,:);
    clear f;
end

R20B01_Ab42_reshape = sortrows(reshape(R20B01_Ab42,[3000*length(filelist),6]));
[R20B01_Ab42_smMean, R20B01_Ab42_smSEM, R20B01_Ab42_smSD] = smoothdat(R20B01_Ab42_reshape,t,0);

%%%%%%%%%%%%%%%%%%% Genotype: attP2-40 > Abeta 1-40
rootdir = '/Volumes/TOSHIBA/FCF_attP2-40@UAS_Abeta40_116';
filelist = dir(fullfile(rootdir, '**/*.dat')); 
rep = length(filelist);

attP240_Ab40 = NaN(rep,3000,6);

for i = 1:length(filelist)
    f = readtable(filelist(i).name);
    f = table2array(f);
    attP240_Ab40(i,1:length(f),:) = f(:,:);
    clear f;
end

attP240_Ab40_reshape = sortrows(reshape(attP240_Ab40,[size(attP240_Ab40,2)*length(filelist),6]));
[attP240_Ab40_smMean, attP240_Ab40_smSEM, attP240_Ab40_smSD] = smoothdat(attP240_Ab40_reshape,t,0);

%%%%%%%%%%%%%%%%%%% Genotype: attP2-40 > Abeta 1-42
rootdir = '/Volumes/TOSHIBA/FCF_attP2-40@UAS_Abeta42_117';
filelist = dir(fullfile(rootdir, '**/*.dat')); 
rep = length(filelist);

attP240_Ab42 = NaN(rep,3000,6);

for i = 1:length(filelist)
    f = readtable(filelist(i).name);
    f = table2array(f);
    attP240_Ab42(i,1:length(f),:) = f(:,:);
    clear f;
end

attP240_Ab42_reshape = sortrows(reshape(attP240_Ab42,[size(attP240_Ab42,2)*length(filelist),6]));
[attP240_Ab42_smMean, attP240_Ab42_smSEM, attP240_Ab42_smSD] = smoothdat(attP240_Ab42_reshape,t,0);

%%%%%%%%%%%%%%%%%%% Genotype: SS00739 > Abeta 1-40
rootdir = '/Volumes/TOSHIBA/GMR_SS00739@UAS_Abeta40_116';
filelist = dir(fullfile(rootdir, '**/*.dat')); 
rep = length(filelist);

SS00739_Ab40 = NaN(rep,3000,6);

for i = 1:length(filelist)
    f = readtable(filelist(i).name);
    f = table2array(f);
    SS00739_Ab40(i,1:length(f),:) = f(:,:);
    clear f;
end

SS00739_Ab40_reshape = sortrows(reshape(SS00739_Ab40,[size(SS00739_Ab40,2)*length(filelist),6]));
[SS00739_Ab40_smMean, SS00739_Ab40_smSEM, SS00739_Ab40_smSD] = smoothdat(SS00739_Ab40_reshape,t,0);

%%%%%%%%%%%%%%%%%%% Genotype: SS00739 > Abeta 1-42
rootdir = '/Volumes/TOSHIBA/GMR_SS00739@UAS_Abeta42_117';
filelist = dir(fullfile(rootdir, '**/*.dat')); 
rep = length(filelist);

SS00739_Ab42 = NaN(rep,3000,6);

for i = 1:length(filelist)
    f = readtable(filelist(i).name);
    f = table2array(f);
    SS00739_Ab42(i,1:length(f),:) = f(:,:);
    clear f;
end

SS00739_Ab42_reshape = sortrows(reshape(SS00739_Ab42,[size(SS00739_Ab42,2)*length(filelist),6]));
[SS00739_Ab42_smMean, SS00739_Ab42_smSEM, SS00739_Ab42_smSD] = smoothdat(SS00739_Ab42_reshape,t,0);

%%%%%%%%%%%%%%%%%%% Genotype: SS00888 > Abeta 1-40
rootdir = '/Volumes/TOSHIBA/GMR_SS00888@UAS_Abeta40_116';
filelist = dir(fullfile(rootdir, '**/*.dat')); 
rep = length(filelist);

SS00888_Ab40 = NaN(rep,3000,6);

for i = 1:length(filelist)
    f = readtable(filelist(i).name);
    f = table2array(f);
    SS00888_Ab40(i,1:length(f),:) = f(:,:);
    clear f;
end

SS00888_Ab40_reshape = sortrows(reshape(SS00888_Ab40,[size(SS00888_Ab40,2)*length(filelist),6]));
[SS00888_Ab40_smMean, SS00888_Ab40_smSEM, SS00888_Ab40_smSD] = smoothdat(SS00888_Ab40_reshape,t,0);

%%%%%%%%%%%%%%%%%%% Genotype: SS00888 > Abeta 1-42
rootdir = '/Volumes/TOSHIBA/GMR_SS00888@UAS_Abeta42_117';
filelist = dir(fullfile(rootdir, '**/*.dat')); 
rep = length(filelist);

SS00888_Ab42 = NaN(rep,3000,6);

for i = 1:length(filelist)
    f = readtable(filelist(i).name);
    f = table2array(f);
    SS00888_Ab42(i,1:length(f),:) = f(:,:);
    clear f;
end

SS00888_Ab42_reshape = sortrows(reshape(SS00888_Ab42,[size(SS00888_Ab42,2)*length(filelist),6]));
[SS00888_Ab42_smMean, SS00888_Ab42_smSEM, SS00888_Ab42_smSD] = smoothdat(SS00888_Ab42_reshape,t,0);

%%%%%%%%%%%%%%%%%%% Genotype: SS00918 > Abeta 1-40
rootdir = '/Volumes/TOSHIBA/GMR_SS00918@UAS_Abeta40_116';
filelist = dir(fullfile(rootdir, '**/*.dat')); 
rep = length(filelist);

SS00918_Ab40 = NaN(rep,3000,6);

for i = 1:length(filelist)
    f = readtable(filelist(i).name);
    f = table2array(f);
    SS00918_Ab40(i,1:length(f),:) = f(:,:);
    clear f;
end

SS00918_Ab40_reshape = sortrows(reshape(SS00918_Ab40,[size(SS00918_Ab40,2)*length(filelist),6]));
[SS00918_Ab40_smMean, SS00918_Ab40_smSEM, SS00918_Ab40_smSD] = smoothdat(SS00918_Ab40_reshape,t,0);

%%%%%%%%%%%%%%%%%%% Genotype: SS00918 > Abeta 1-42
rootdir = '/Volumes/TOSHIBA/GMR_SS00918@UAS_Abeta42_117';
filelist = dir(fullfile(rootdir, '**/*.dat')); 
rep = length(filelist);

SS00918_Ab42 = NaN(rep,3000,6);

for i = 1:length(filelist)
    f = readtable(filelist(i).name);
    f = table2array(f);
    SS00918_Ab42(i,1:length(f),:) = f(:,:);
    clear f;
end

SS00918_Ab42_reshape = sortrows(reshape(SS00918_Ab42,[size(SS00918_Ab42,2)*length(filelist),6]));
[SS00918_Ab42_smMean, SS00918_Ab42_smSEM, SS00918_Ab42_smSD] = smoothdat(SS00918_Ab42_reshape,t,0);

%%%%%%%%%%%%%%%%%%% Genotype: TH > CS
rootdir = '/Volumes/TOSHIBA/t2/TH-gal4@CS';
filelist = dir(fullfile(rootdir, '**/*.dat')); 
rep = length(filelist);

TH_CS = NaN(rep,3000,6);

for i = 1:length(filelist)
    f = readtable(filelist(i).name);
    f = table2array(f);
    TH_CS(i,1:length(f),:) = f(:,:);
    clear f;
end

TH_CS_reshape = sortrows(reshape(TH_CS,[size(TH_CS,2)*length(filelist),6]));
[TH_CS_smMean, TH_CS_smSEM, TH_CS_smSD] = smoothdat(TH_CS_reshape,t,0);

%%%%%%%%%%%%%%%%%%% Genotype: TH > TNT
rootdir = '/Volumes/TOSHIBA/t2/TH-gal4@UAS_TNT_2_0003';
filelist = dir(fullfile(rootdir, '**/*.dat')); 
rep = length(filelist);

TH_TNT = NaN(rep,3000,6);

for i = 1:length(filelist)
    f = readtable(filelist(i).name);
    f = table2array(f);
    TH_TNT(i,1:length(f),:) = f(:,:);
    clear f;
end

TH_TNT_reshape = sortrows(reshape(TH_TNT,[size(TH_TNT,2)*length(filelist),6]));
[TH_TNT_smMean, TH_TNT_smSEM, TH_TNT_smSD] = smoothdat(TH_TNT_reshape,t,0);

%%%%%%%%%%%%%%%%%%% Genotype: TH > TH-RNAi
rootdir = '/Volumes/TOSHIBA/t2/TH-gal4@TH-RNAi';
filelist = dir(fullfile(rootdir, '**/*.dat')); 
rep = length(filelist);

TH_THRNAi = NaN(rep,3000,6);

for i = 1:length(filelist)
    f = readtable(filelist(i).name);
    f = table2array(f);
    TH_THRNAi(i,1:length(f),:) = f(:,:);
    clear f;
end

TH_THRNAi_reshape = sortrows(reshape(TH_THRNAi,[size(TH_THRNAi,2)*length(filelist),6]));
[TH_THRNAi_smMean, TH_THRNAi_smSEM, TH_THRNAi_smSD] = smoothdat(TH_THRNAi_reshape,t,0);

clear i filelist rep rootdir

%% visualize data

% attP2 Ab1-40 vs attP2 Ab1-42
figure(1)
subplot(3,1,1)
% normalized velocity
p1 = plot(attP2_Ab40_smMean(:,1),attP2_Ab40_smMean(:,2)+attP2_Ab40_smSEM(:,2),'Color',[0 0.4470 0.7410])
hold on
p2 = plot(attP2_Ab40_smMean(:,1),attP2_Ab40_smMean(:,2)-attP2_Ab40_smSEM(:,2),'Color',[0 0.4470 0.7410])
hold on
p3 = plot(attP2_Ab42_smMean(:,1),attP2_Ab42_smMean(:,2)+attP2_Ab42_smSEM(:,2),'Color',[0.8500 0.3250 0.0980])
hold on
p4 = plot(attP2_Ab42_smMean(:,1),attP2_Ab42_smMean(:,2)-attP2_Ab42_smSEM(:,2),'Color',[0.8500 0.3250 0.0980])
hold on
p5 =plot(attP2_Ab40_smMean(:,1),attP2_Ab40_smMean(:,2),'Color',[0 0.4470 0.7410])
hold on
p6 = plot(attP2_Ab42_smMean(:,1),attP2_Ab42_smMean(:,2),'Color',[0.8500 0.3250 0.0980])
xlim([0 250])
p1.Color(4) = 0.1;
p2.Color(4) = 0.1;
p3.Color(4) = 0.1;
p4.Color(4) = 0.1;
legend([p5 p6],'attP2>Ab1-40','attP2>Ab1-42')
legend boxoff
ylabel('Normalized Velocity (mm/s)')

% Normalized length
subplot(3,1,2)
p1 = plot(attP2_Ab40_smMean(:,1),attP2_Ab40_smMean(:,3)+attP2_Ab40_smSEM(:,3),'Color',[0 0.4470 0.7410])
hold on
p2 = plot(attP2_Ab40_smMean(:,1),attP2_Ab40_smMean(:,3)-attP2_Ab40_smSEM(:,3),'Color',[0 0.4470 0.7410])
hold on
p3 = plot(attP2_Ab42_smMean(:,1),attP2_Ab42_smMean(:,3)+attP2_Ab42_smSEM(:,3),'Color',[0.8500 0.3250 0.0980])
hold on
p4 = plot(attP2_Ab42_smMean(:,1),attP2_Ab42_smMean(:,3)-attP2_Ab42_smSEM(:,3),'Color',[0.8500 0.3250 0.0980])
hold on
p5 =plot(attP2_Ab40_smMean(:,1),attP2_Ab40_smMean(:,3),'Color',[0 0.4470 0.7410])
hold on
p6 = plot(attP2_Ab42_smMean(:,1),attP2_Ab42_smMean(:,3),'Color',[0.8500 0.3250 0.0980])
xlim([0 250])
p1.Color(4) = 0.1;
p2.Color(4) = 0.1;
p3.Color(4) = 0.1;
p4.Color(4) = 0.1;
legend([p5 p6],'attP2>Ab1-40','attP2>Ab1-42')
legend boxoff
ylabel('Normalized Length (mm)')

% Normalized curve
subplot(3,1,3)
p1 = plot(attP2_Ab40_smMean(:,1),attP2_Ab40_smMean(:,5)+attP2_Ab40_smSEM(:,5),'Color',[0 0.4470 0.7410])
hold on
p2 = plot(attP2_Ab40_smMean(:,1),attP2_Ab40_smMean(:,5)-attP2_Ab40_smSEM(:,5),'Color',[0 0.4470 0.7410])
hold on
p3 = plot(attP2_Ab42_smMean(:,1),attP2_Ab42_smMean(:,5)+attP2_Ab42_smSEM(:,5),'Color',[0.8500 0.3250 0.0980])
hold on
p4 = plot(attP2_Ab42_smMean(:,1),attP2_Ab42_smMean(:,5)-attP2_Ab42_smSEM(:,5),'Color',[0.8500 0.3250 0.0980])
hold on
p5 =plot(attP2_Ab40_smMean(:,1),attP2_Ab40_smMean(:,5),'Color',[0 0.4470 0.7410])
hold on
p6 = plot(attP2_Ab42_smMean(:,1),attP2_Ab42_smMean(:,5),'Color',[0.8500 0.3250 0.0980])
xlim([0 250])
p1.Color(4) = 0.1;
p2.Color(4) = 0.1;
p3.Color(4) = 0.1;
p4.Color(4) = 0.1;
legend([p5 p6],'attP2>Ab1-40','attP2>Ab1-42')
legend boxoff
xlabel('Second (s)')
ylabel('Normalized Angle')

% R57C10 Ab1-40 vs R57C10 Ab1-42
figure(2)
subplot(3,1,1)
% normalized velocity
p1 = plot(R57C10_Ab40_smMean(:,1),R57C10_Ab40_smMean(:,2)+R57C10_Ab40_smSEM(:,2),'Color',[0 0.4470 0.7410])
hold on
p2 = plot(R57C10_Ab40_smMean(:,1),R57C10_Ab40_smMean(:,2)-R57C10_Ab40_smSEM(:,2),'Color',[0 0.4470 0.7410])
hold on
p3 = plot(R57C10_Ab42_smMean(:,1),R57C10_Ab42_smMean(:,2)+R57C10_Ab42_smSEM(:,2),'Color',[0.8500 0.3250 0.0980])
hold on
p4 = plot(R57C10_Ab42_smMean(:,1),R57C10_Ab42_smMean(:,2)-R57C10_Ab42_smSEM(:,2),'Color',[0.8500 0.3250 0.0980])
hold on
p5 =plot(R57C10_Ab40_smMean(:,1),R57C10_Ab40_smMean(:,2),'Color',[0 0.4470 0.7410])
hold on
p6 = plot(R57C10_Ab42_smMean(:,1),R57C10_Ab42_smMean(:,2),'Color',[0.8500 0.3250 0.0980])
xlim([0 250])
p1.Color(4) = 0.1;
p2.Color(4) = 0.1;
p3.Color(4) = 0.1;
p4.Color(4) = 0.1;
legend([p5 p6],'R57C10>Ab1-40','R57C10>Ab1-42')
legend boxoff
ylabel('Normalized Velocity (mm/s)')

% Normalized length
subplot(3,1,2)
p1 = plot(R57C10_Ab40_smMean(:,1),R57C10_Ab40_smMean(:,3)+R57C10_Ab40_smSEM(:,3),'Color',[0 0.4470 0.7410])
hold on
p2 = plot(R57C10_Ab40_smMean(:,1),R57C10_Ab40_smMean(:,3)-R57C10_Ab40_smSEM(:,3),'Color',[0 0.4470 0.7410])
hold on
p3 = plot(R57C10_Ab42_smMean(:,1),R57C10_Ab42_smMean(:,3)+R57C10_Ab42_smSEM(:,3),'Color',[0.8500 0.3250 0.0980])
hold on
p4 = plot(R57C10_Ab42_smMean(:,1),R57C10_Ab42_smMean(:,3)-R57C10_Ab42_smSEM(:,3),'Color',[0.8500 0.3250 0.0980])
hold on
p5 =plot(R57C10_Ab40_smMean(:,1),R57C10_Ab40_smMean(:,3),'Color',[0 0.4470 0.7410])
hold on
p6 = plot(R57C10_Ab42_smMean(:,1),R57C10_Ab42_smMean(:,3),'Color',[0.8500 0.3250 0.0980])
xlim([0 250])
p1.Color(4) = 0.1;
p2.Color(4) = 0.1;
p3.Color(4) = 0.1;
p4.Color(4) = 0.1;
legend([p5 p6],'R57C10>Ab1-40','R57C10>Ab1-42')
legend boxoff
ylabel('Normalized Length (mm)')

% Normalized curve
subplot(3,1,3)
p1 = plot(R57C10_Ab40_smMean(:,1),R57C10_Ab40_smMean(:,5)+R57C10_Ab40_smSEM(:,5),'Color',[0 0.4470 0.7410])
hold on
p2 = plot(R57C10_Ab40_smMean(:,1),R57C10_Ab40_smMean(:,5)-R57C10_Ab40_smSEM(:,5),'Color',[0 0.4470 0.7410])
hold on
p3 = plot(R57C10_Ab42_smMean(:,1),R57C10_Ab42_smMean(:,5)+R57C10_Ab42_smSEM(:,5),'Color',[0.8500 0.3250 0.0980])
hold on
p4 = plot(R57C10_Ab42_smMean(:,1),R57C10_Ab42_smMean(:,5)-R57C10_Ab42_smSEM(:,5),'Color',[0.8500 0.3250 0.0980])
hold on
p5 =plot(R57C10_Ab40_smMean(:,1),R57C10_Ab40_smMean(:,5),'Color',[0 0.4470 0.7410])
hold on
p6 = plot(R57C10_Ab42_smMean(:,1),R57C10_Ab42_smMean(:,5),'Color',[0.8500 0.3250 0.0980])
xlim([0 250])
p1.Color(4) = 0.1;
p2.Color(4) = 0.1;
p3.Color(4) = 0.1;
p4.Color(4) = 0.1;
legend([p5 p6],'R57C10>Ab1-40','R57C10>Ab1-42')
legend boxoff
xlabel('Second (s)')
ylabel('Normalized Angle')

% R61D08 Ab1-40 vs R61D08 Ab1-42
figure(3)
subplot(3,1,1)
% normalized velocity
p1 = plot(R61D08_Ab40_smMean(:,1),R61D08_Ab40_smMean(:,2)+R61D08_Ab40_smSEM(:,2),'Color',[0 0.4470 0.7410])
hold on
p2 = plot(R61D08_Ab40_smMean(:,1),R61D08_Ab40_smMean(:,2)-R61D08_Ab40_smSEM(:,2),'Color',[0 0.4470 0.7410])
hold on
p3 = plot(R61D08_Ab42_smMean(:,1),R61D08_Ab42_smMean(:,2)+R61D08_Ab42_smSEM(:,2),'Color',[0.8500 0.3250 0.0980])
hold on
p4 = plot(R61D08_Ab42_smMean(:,1),R61D08_Ab42_smMean(:,2)-R61D08_Ab42_smSEM(:,2),'Color',[0.8500 0.3250 0.0980])
hold on
p5 =plot(R61D08_Ab40_smMean(:,1),R61D08_Ab40_smMean(:,2),'Color',[0 0.4470 0.7410])
hold on
p6 = plot(R61D08_Ab42_smMean(:,1),R61D08_Ab42_smMean(:,2),'Color',[0.8500 0.3250 0.0980])
xlim([0 250])
p1.Color(4) = 0.1;
p2.Color(4) = 0.1;
p3.Color(4) = 0.1;
p4.Color(4) = 0.1;
legend([p5 p6],'R61D08>Ab1-40','R61D08>Ab1-42')
legend boxoff
ylabel('Normalized Velocity (mm/s)')

% Normalized length
subplot(3,1,2)
p1 = plot(R61D08_Ab40_smMean(:,1),R61D08_Ab40_smMean(:,3)+R61D08_Ab40_smSEM(:,3),'Color',[0 0.4470 0.7410])
hold on
p2 = plot(R61D08_Ab40_smMean(:,1),R61D08_Ab40_smMean(:,3)-R61D08_Ab40_smSEM(:,3),'Color',[0 0.4470 0.7410])
hold on
p3 = plot(R61D08_Ab42_smMean(:,1),R61D08_Ab42_smMean(:,3)+R61D08_Ab42_smSEM(:,3),'Color',[0.8500 0.3250 0.0980])
hold on
p4 = plot(R61D08_Ab42_smMean(:,1),R61D08_Ab42_smMean(:,3)-R61D08_Ab42_smSEM(:,3),'Color',[0.8500 0.3250 0.0980])
hold on
p5 =plot(R61D08_Ab40_smMean(:,1),R61D08_Ab40_smMean(:,3),'Color',[0 0.4470 0.7410])
hold on
p6 = plot(R61D08_Ab42_smMean(:,1),R61D08_Ab42_smMean(:,3),'Color',[0.8500 0.3250 0.0980])
xlim([0 250])
p1.Color(4) = 0.1;
p2.Color(4) = 0.1;
p3.Color(4) = 0.1;
p4.Color(4) = 0.1;
legend([p5 p6],'R61D08>Ab1-40','R61D08>Ab1-42')
legend boxoff
ylabel('Normalized Length (mm)')

% Normalized curve
subplot(3,1,3)
p1 = plot(R61D08_Ab40_smMean(:,1),R61D08_Ab40_smMean(:,5)+R61D08_Ab40_smSEM(:,5),'Color',[0 0.4470 0.7410])
hold on
p2 = plot(R61D08_Ab40_smMean(:,1),R61D08_Ab40_smMean(:,5)-R61D08_Ab40_smSEM(:,5),'Color',[0 0.4470 0.7410])
hold on
p3 = plot(R61D08_Ab42_smMean(:,1),R61D08_Ab42_smMean(:,5)+R61D08_Ab42_smSEM(:,5),'Color',[0.8500 0.3250 0.0980])
hold on
p4 = plot(R61D08_Ab42_smMean(:,1),R61D08_Ab42_smMean(:,5)-R61D08_Ab42_smSEM(:,5),'Color',[0.8500 0.3250 0.0980])
hold on
p5 =plot(R61D08_Ab40_smMean(:,1),R61D08_Ab40_smMean(:,5),'Color',[0 0.4470 0.7410])
hold on
p6 = plot(R61D08_Ab42_smMean(:,1),R61D08_Ab42_smMean(:,5),'Color',[0.8500 0.3250 0.0980])
xlim([0 250])
p1.Color(4) = 0.1;
p2.Color(4) = 0.1;
p3.Color(4) = 0.1;
p4.Color(4) = 0.1;
legend([p5 p6],'R61D08>Ab1-40','R61D08>Ab1-42')
legend boxoff
xlabel('Second (s)')
ylabel('Normalized Angle')

% R20B01 Ab1-40 vs R20B01 Ab1-42
figure(4)
subplot(3,1,1)
% normalized velocity
p1 = plot(R20B01_Ab40_smMean(:,1),R20B01_Ab40_smMean(:,2)+R20B01_Ab40_smSEM(:,2),'Color',[0 0.4470 0.7410])
hold on
p2 = plot(R20B01_Ab40_smMean(:,1),R20B01_Ab40_smMean(:,2)-R20B01_Ab40_smSEM(:,2),'Color',[0 0.4470 0.7410])
hold on
p3 = plot(R20B01_Ab42_smMean(:,1),R20B01_Ab42_smMean(:,2)+R20B01_Ab42_smSEM(:,2),'Color',[0.8500 0.3250 0.0980])
hold on
p4 = plot(R20B01_Ab42_smMean(:,1),R20B01_Ab42_smMean(:,2)-R20B01_Ab42_smSEM(:,2),'Color',[0.8500 0.3250 0.0980])
hold on
p5 =plot(R20B01_Ab40_smMean(:,1),R20B01_Ab40_smMean(:,2),'Color',[0 0.4470 0.7410])
hold on
p6 = plot(R20B01_Ab42_smMean(:,1),R20B01_Ab42_smMean(:,2),'Color',[0.8500 0.3250 0.0980])
xlim([0 250])
p1.Color(4) = 0.1;
p2.Color(4) = 0.1;
p3.Color(4) = 0.1;
p4.Color(4) = 0.1;
legend([p5 p6],'R20B01>Ab1-40','R20B01>Ab1-42')
legend boxoff
ylabel('Normalized Velocity (mm/s)')

% Normalized length
subplot(3,1,2)
p1 = plot(R20B01_Ab40_smMean(:,1),R20B01_Ab40_smMean(:,3)+R20B01_Ab40_smSEM(:,3),'Color',[0 0.4470 0.7410])
hold on
p2 = plot(R20B01_Ab40_smMean(:,1),R20B01_Ab40_smMean(:,3)-R20B01_Ab40_smSEM(:,3),'Color',[0 0.4470 0.7410])
hold on
p3 = plot(R20B01_Ab42_smMean(:,1),R20B01_Ab42_smMean(:,3)+R20B01_Ab42_smSEM(:,3),'Color',[0.8500 0.3250 0.0980])
hold on
p4 = plot(R20B01_Ab42_smMean(:,1),R20B01_Ab42_smMean(:,3)-R20B01_Ab42_smSEM(:,3),'Color',[0.8500 0.3250 0.0980])
hold on
p5 =plot(R20B01_Ab40_smMean(:,1),R20B01_Ab40_smMean(:,3),'Color',[0 0.4470 0.7410])
hold on
p6 = plot(R20B01_Ab42_smMean(:,1),R20B01_Ab42_smMean(:,3),'Color',[0.8500 0.3250 0.0980])
xlim([0 250])
p1.Color(4) = 0.1;
p2.Color(4) = 0.1;
p3.Color(4) = 0.1;
p4.Color(4) = 0.1;
legend([p5 p6],'R20B01>Ab1-40','R20B01>Ab1-42')
legend boxoff
ylabel('Normalized Length (mm)')

% Normalized curve
subplot(3,1,3)
p1 = plot(R20B01_Ab40_smMean(:,1),R20B01_Ab40_smMean(:,5)+R20B01_Ab40_smSEM(:,5),'Color',[0 0.4470 0.7410])
hold on
p2 = plot(R20B01_Ab40_smMean(:,1),R20B01_Ab40_smMean(:,5)-R20B01_Ab40_smSEM(:,5),'Color',[0 0.4470 0.7410])
hold on
p3 = plot(R20B01_Ab42_smMean(:,1),R20B01_Ab42_smMean(:,5)+R20B01_Ab42_smSEM(:,5),'Color',[0.8500 0.3250 0.0980])
hold on
p4 = plot(R20B01_Ab42_smMean(:,1),R20B01_Ab42_smMean(:,5)-R20B01_Ab42_smSEM(:,5),'Color',[0.8500 0.3250 0.0980])
hold on
p5 =plot(R20B01_Ab40_smMean(:,1),R20B01_Ab40_smMean(:,5),'Color',[0 0.4470 0.7410])
hold on
p6 = plot(R20B01_Ab42_smMean(:,1),R20B01_Ab42_smMean(:,5),'Color',[0.8500 0.3250 0.0980])
xlim([0 250])
p1.Color(4) = 0.1;
p2.Color(4) = 0.1;
p3.Color(4) = 0.1;
p4.Color(4) = 0.1;
legend([p5 p6],'R20B01>Ab1-40','R20B01>Ab1-42')
legend boxoff
xlabel('Second (s)')
ylabel('Normalized Angle')



% compare between neurons within genotypes
% Ab1-40
figure(5)
subplot(3,1,1)
% normalized velocity
p1 = plot(attP2_Ab40_smMean(:,1),attP2_Ab40_smMean(:,2)+attP2_Ab40_smSEM(:,2),'Color',[0 0.4470 0.7410])
hold on
p2 = plot(attP2_Ab40_smMean(:,1),attP2_Ab40_smMean(:,2)-attP2_Ab40_smSEM(:,2),'Color',[0 0.4470 0.7410])
hold on
p3 = plot(R57C10_Ab40_smMean(:,1),R57C10_Ab40_smMean(:,2)+R57C10_Ab40_smSEM(:,2),'Color',[0.8500 0.3250 0.0980])
hold on
p4 = plot(R57C10_Ab40_smMean(:,1),R57C10_Ab40_smMean(:,2)-R57C10_Ab40_smSEM(:,2),'Color',[0.8500 0.3250 0.0980])
hold on 
p5 = plot(R61D08_Ab40_smMean(:,1),R61D08_Ab40_smMean(:,2)+R61D08_Ab40_smSEM(:,2),'Color',[0.9290, 0.6940, 0.1250])
hold on
p6 = plot(R61D08_Ab40_smMean(:,1),R61D08_Ab40_smMean(:,2)-R61D08_Ab40_smSEM(:,2),'Color',[0.9290, 0.6940, 0.1250])
hold on
p7 = plot(R20B01_Ab40_smMean(:,1),R20B01_Ab40_smMean(:,2)+R20B01_Ab40_smSEM(:,2),'Color',[0.4660, 0.6740, 0.1880])
hold on
p8 = plot(R20B01_Ab40_smMean(:,1),R20B01_Ab40_smMean(:,2)-R20B01_Ab40_smSEM(:,2),'Color',[0.4660, 0.6740, 0.1880])
hold on
p9 = plot(attP2_Ab40_smMean(:,1),attP2_Ab40_smMean(:,2),'Color',[0 0.4470 0.7410])
hold on
p10 = plot(R57C10_Ab40_smMean(:,1),R57C10_Ab40_smMean(:,2),'Color',[0.8500 0.3250 0.0980])
hold on 
p11 = plot(R61D08_Ab40_smMean(:,1),R61D08_Ab40_smMean(:,2),'Color',[0.9290, 0.6940, 0.1250])
hold on
p12 = plot(R20B01_Ab40_smMean(:,1),R20B01_Ab40_smMean(:,2),'Color',[0.4660, 0.6740, 0.1880])
xlim([0 250])
p1.Color(4) = 0.1;
p2.Color(4) = 0.1;
p3.Color(4) = 0.1;
p4.Color(4) = 0.1;
p5.Color(4) = 0.1;
p6.Color(4) = 0.1;
p7.Color(4) = 0.1;
p8.Color(4) = 0.1;
legend([p9 p10 p11 p12],'attP2>Ab1-40','R57C10>Ab1-40','R61D08>Ab1-40','R20B01>Ab1-40','Location','southwest')
legend boxoff
ylabel('Normalized Velocity (mm/s)')

subplot(3,1,2)
% Normalized length
p1 = plot(attP2_Ab40_smMean(:,1),attP2_Ab40_smMean(:,3)+attP2_Ab40_smSEM(:,3),'Color',[0 0.4470 0.7410])
hold on
p2 = plot(attP2_Ab40_smMean(:,1),attP2_Ab40_smMean(:,3)-attP2_Ab40_smSEM(:,3),'Color',[0 0.4470 0.7410])
hold on
p3 = plot(R57C10_Ab40_smMean(:,1),R57C10_Ab40_smMean(:,3)+R57C10_Ab40_smSEM(:,3),'Color',[0.8500 0.3250 0.0980])
hold on
p4 = plot(R57C10_Ab40_smMean(:,1),R57C10_Ab40_smMean(:,3)-R57C10_Ab40_smSEM(:,3),'Color',[0.8500 0.3250 0.0980])
hold on 
p5 = plot(R61D08_Ab40_smMean(:,1),R61D08_Ab40_smMean(:,3)+R61D08_Ab40_smSEM(:,3),'Color',[0.9290, 0.6940, 0.1250])
hold on
p6 = plot(R61D08_Ab40_smMean(:,1),R61D08_Ab40_smMean(:,3)-R61D08_Ab40_smSEM(:,3),'Color',[0.9290, 0.6940, 0.1250])
hold on
p7 = plot(R20B01_Ab40_smMean(:,1),R20B01_Ab40_smMean(:,3)+R20B01_Ab40_smSEM(:,3),'Color',[0.4660, 0.6740, 0.1880])
hold on
p8 = plot(R20B01_Ab40_smMean(:,1),R20B01_Ab40_smMean(:,3)-R20B01_Ab40_smSEM(:,3),'Color',[0.4660, 0.6740, 0.1880])
hold on
p9 = plot(attP2_Ab40_smMean(:,1),attP2_Ab40_smMean(:,3),'Color',[0 0.4470 0.7410])
hold on
p10 = plot(R57C10_Ab40_smMean(:,1),R57C10_Ab40_smMean(:,3),'Color',[0.8500 0.3250 0.0980])
hold on 
p11 = plot(R61D08_Ab40_smMean(:,1),R61D08_Ab40_smMean(:,3),'Color',[0.9290, 0.6940, 0.1250])
hold on
p12 = plot(R20B01_Ab40_smMean(:,1),R20B01_Ab40_smMean(:,3),'Color',[0.4660, 0.6740, 0.1880])
xlim([0 250])
p1.Color(4) = 0.1;
p2.Color(4) = 0.1;
p3.Color(4) = 0.1;
p4.Color(4) = 0.1;
p5.Color(4) = 0.1;
p6.Color(4) = 0.1;
p7.Color(4) = 0.1;
p8.Color(4) = 0.1;
legend([p9 p10 p11 p12],'attP2>Ab1-40','R57C10>Ab1-40','R61D08>Ab1-40','R20B01>Ab1-40','Location','southwest')
legend boxoff
ylabel('Normalized Length (mm)')

% Normalized curve
subplot(3,1,3)
p1 = plot(attP2_Ab40_smMean(:,1),attP2_Ab40_smMean(:,5)+attP2_Ab40_smSEM(:,5),'Color',[0 0.4470 0.7410])
hold on
p2 = plot(attP2_Ab40_smMean(:,1),attP2_Ab40_smMean(:,5)-attP2_Ab40_smSEM(:,5),'Color',[0 0.4470 0.7410])
hold on
p3 = plot(R57C10_Ab40_smMean(:,1),R57C10_Ab40_smMean(:,5)+R57C10_Ab40_smSEM(:,5),'Color',[0.8500 0.3250 0.0980])
hold on
p4 = plot(R57C10_Ab40_smMean(:,1),R57C10_Ab40_smMean(:,5)-R57C10_Ab40_smSEM(:,5),'Color',[0.8500 0.3250 0.0980])
hold on 
p5 = plot(R61D08_Ab40_smMean(:,1),R61D08_Ab40_smMean(:,5)+R61D08_Ab40_smSEM(:,5),'Color',[0.9290, 0.6940, 0.1250])
hold on
p6 = plot(R61D08_Ab40_smMean(:,1),R61D08_Ab40_smMean(:,5)-R61D08_Ab40_smSEM(:,5),'Color',[0.9290, 0.6940, 0.1250])
hold on
p7 = plot(R20B01_Ab40_smMean(:,1),R20B01_Ab40_smMean(:,5)+R20B01_Ab40_smSEM(:,5),'Color',[0.4660, 0.6740, 0.1880])
hold on
p8 = plot(R20B01_Ab40_smMean(:,1),R20B01_Ab40_smMean(:,5)-R20B01_Ab40_smSEM(:,5),'Color',[0.4660, 0.6740, 0.1880])
hold on
p9 = plot(attP2_Ab40_smMean(:,1),attP2_Ab40_smMean(:,5),'Color',[0 0.4470 0.7410])
hold on
p10 = plot(R57C10_Ab40_smMean(:,1),R57C10_Ab40_smMean(:,5),'Color',[0.8500 0.3250 0.0980])
hold on 
p11 = plot(R61D08_Ab40_smMean(:,1),R61D08_Ab40_smMean(:,5),'Color',[0.9290, 0.6940, 0.1250])
hold on
p12 = plot(R20B01_Ab40_smMean(:,1),R20B01_Ab40_smMean(:,5),'Color',[0.4660, 0.6740, 0.1880])
xlim([0 250])
p1.Color(4) = 0.1;
p2.Color(4) = 0.1;
p3.Color(4) = 0.1;
p4.Color(4) = 0.1;
p5.Color(4) = 0.1;
p6.Color(4) = 0.1;
p7.Color(4) = 0.1;
p8.Color(4) = 0.1;
legend([p9 p10 p11 p12],'attP2>Ab1-40','R57C10>Ab1-40','R61D08>Ab1-40','R20B01>Ab1-40','Location','northwest')
legend boxoff
xlabel('Second (s)')
ylabel('Normalized Angle')


% Ab1-42
figure(6)
subplot(3,1,1)
% normalized velocity
p1 = plot(attP2_Ab42_smMean(:,1),attP2_Ab42_smMean(:,2)+attP2_Ab42_smSEM(:,2),'Color',[0 0.4470 0.7410])
hold on
p2 = plot(attP2_Ab42_smMean(:,1),attP2_Ab42_smMean(:,2)-attP2_Ab42_smSEM(:,2),'Color',[0 0.4470 0.7410])
hold on
p3 = plot(R57C10_Ab42_smMean(:,1),R57C10_Ab42_smMean(:,2)+R57C10_Ab42_smSEM(:,2),'Color',[0.8500 0.3250 0.0980])
hold on
p4 = plot(R57C10_Ab42_smMean(:,1),R57C10_Ab42_smMean(:,2)-R57C10_Ab42_smSEM(:,2),'Color',[0.8500 0.3250 0.0980])
hold on 
p5 = plot(R61D08_Ab42_smMean(:,1),R61D08_Ab42_smMean(:,2)+R61D08_Ab42_smSEM(:,2),'Color',[0.9290, 0.6940, 0.1250])
hold on
p6 = plot(R61D08_Ab42_smMean(:,1),R61D08_Ab42_smMean(:,2)-R61D08_Ab42_smSEM(:,2),'Color',[0.9290, 0.6940, 0.1250])
hold on
p7 = plot(R20B01_Ab42_smMean(:,1),R20B01_Ab42_smMean(:,2)+R20B01_Ab42_smSEM(:,2),'Color',[0.4660, 0.6740, 0.1880])
hold on
p8 = plot(R20B01_Ab42_smMean(:,1),R20B01_Ab42_smMean(:,2)-R20B01_Ab42_smSEM(:,2),'Color',[0.4660, 0.6740, 0.1880])
hold on
p9 = plot(attP2_Ab42_smMean(:,1),attP2_Ab42_smMean(:,2),'Color',[0 0.4470 0.7410])
hold on
p10 = plot(R57C10_Ab42_smMean(:,1),R57C10_Ab42_smMean(:,2),'Color',[0.8500 0.3250 0.0980])
hold on 
p11 = plot(R61D08_Ab42_smMean(:,1),R61D08_Ab42_smMean(:,2),'Color',[0.9290, 0.6940, 0.1250])
hold on
p12 = plot(R20B01_Ab42_smMean(:,1),R20B01_Ab42_smMean(:,2),'Color',[0.4660, 0.6740, 0.1880])
xlim([0 250])
p1.Color(4) = 0.1;
p2.Color(4) = 0.1;
p3.Color(4) = 0.1;
p4.Color(4) = 0.1;
p5.Color(4) = 0.1;
p6.Color(4) = 0.1;
p7.Color(4) = 0.1;
p8.Color(4) = 0.1;
legend([p9 p10 p11 p12],'attP2>Ab1-42','R57C10>Ab1-42','R61D08>Ab1-42','R20B01>Ab1-42','Location','southwest')
legend boxoff
ylabel('Normalized Velocity (mm/s)')

subplot(3,1,2)
% Normalized length
p1 = plot(attP2_Ab42_smMean(:,1),attP2_Ab42_smMean(:,3)+attP2_Ab42_smSEM(:,3),'Color',[0 0.4470 0.7410])
hold on
p2 = plot(attP2_Ab42_smMean(:,1),attP2_Ab42_smMean(:,3)-attP2_Ab42_smSEM(:,3),'Color',[0 0.4470 0.7410])
hold on
p3 = plot(R57C10_Ab42_smMean(:,1),R57C10_Ab42_smMean(:,3)+R57C10_Ab42_smSEM(:,3),'Color',[0.8500 0.3250 0.0980])
hold on
p4 = plot(R57C10_Ab42_smMean(:,1),R57C10_Ab42_smMean(:,3)-R57C10_Ab42_smSEM(:,3),'Color',[0.8500 0.3250 0.0980])
hold on 
p5 = plot(R61D08_Ab42_smMean(:,1),R61D08_Ab42_smMean(:,3)+R61D08_Ab42_smSEM(:,3),'Color',[0.9290, 0.6940, 0.1250])
hold on
p6 = plot(R61D08_Ab42_smMean(:,1),R61D08_Ab42_smMean(:,3)-R61D08_Ab42_smSEM(:,3),'Color',[0.9290, 0.6940, 0.1250])
hold on
p7 = plot(R20B01_Ab42_smMean(:,1),R20B01_Ab42_smMean(:,3)+R20B01_Ab42_smSEM(:,3),'Color',[0.4660, 0.6740, 0.1880])
hold on
p8 = plot(R20B01_Ab42_smMean(:,1),R20B01_Ab42_smMean(:,3)-R20B01_Ab42_smSEM(:,3),'Color',[0.4660, 0.6740, 0.1880])
hold on
p9 = plot(attP2_Ab42_smMean(:,1),attP2_Ab42_smMean(:,3),'Color',[0 0.4470 0.7410])
hold on
p10 = plot(R57C10_Ab42_smMean(:,1),R57C10_Ab42_smMean(:,3),'Color',[0.8500 0.3250 0.0980])
hold on 
p11 = plot(R61D08_Ab42_smMean(:,1),R61D08_Ab42_smMean(:,3),'Color',[0.9290, 0.6940, 0.1250])
hold on
p12 = plot(R20B01_Ab42_smMean(:,1),R20B01_Ab42_smMean(:,3),'Color',[0.4660, 0.6740, 0.1880])
xlim([0 250])
p1.Color(4) = 0.1;
p2.Color(4) = 0.1;
p3.Color(4) = 0.1;
p4.Color(4) = 0.1;
p5.Color(4) = 0.1;
p6.Color(4) = 0.1;
p7.Color(4) = 0.1;
p8.Color(4) = 0.1;
legend([p9 p10 p11 p12],'attP2>Ab1-42','R57C10>Ab1-42','R61D08>Ab1-42','R20B01>Ab1-42','Location','southwest')
legend boxoff
ylabel('Normalized Length (mm)')

% Normalized curve
subplot(3,1,3)
p1 = plot(attP2_Ab42_smMean(:,1),attP2_Ab42_smMean(:,5)+attP2_Ab42_smSEM(:,5),'Color',[0 0.4470 0.7410])
hold on
p2 = plot(attP2_Ab42_smMean(:,1),attP2_Ab42_smMean(:,5)-attP2_Ab42_smSEM(:,5),'Color',[0 0.4470 0.7410])
hold on
p3 = plot(R57C10_Ab42_smMean(:,1),R57C10_Ab42_smMean(:,5)+R57C10_Ab42_smSEM(:,5),'Color',[0.8500 0.3250 0.0980])
hold on
p4 = plot(R57C10_Ab42_smMean(:,1),R57C10_Ab42_smMean(:,5)-R57C10_Ab42_smSEM(:,5),'Color',[0.8500 0.3250 0.0980])
hold on 
p5 = plot(R61D08_Ab42_smMean(:,1),R61D08_Ab42_smMean(:,5)+R61D08_Ab42_smSEM(:,5),'Color',[0.9290, 0.6940, 0.1250])
hold on
p6 = plot(R61D08_Ab42_smMean(:,1),R61D08_Ab42_smMean(:,5)-R61D08_Ab42_smSEM(:,5),'Color',[0.9290, 0.6940, 0.1250])
hold on
p7 = plot(R20B01_Ab42_smMean(:,1),R20B01_Ab42_smMean(:,5)+R20B01_Ab42_smSEM(:,5),'Color',[0.4660, 0.6740, 0.1880])
hold on
p8 = plot(R20B01_Ab42_smMean(:,1),R20B01_Ab42_smMean(:,5)-R20B01_Ab42_smSEM(:,5),'Color',[0.4660, 0.6740, 0.1880])
hold on
p9 = plot(attP2_Ab42_smMean(:,1),attP2_Ab42_smMean(:,5),'Color',[0 0.4470 0.7410])
hold on
p10 = plot(R57C10_Ab42_smMean(:,1),R57C10_Ab42_smMean(:,5),'Color',[0.8500 0.3250 0.0980])
hold on 
p11 = plot(R61D08_Ab42_smMean(:,1),R61D08_Ab42_smMean(:,5),'Color',[0.9290, 0.6940, 0.1250])
hold on
p12 = plot(R20B01_Ab42_smMean(:,1),R20B01_Ab42_smMean(:,5),'Color',[0.4660, 0.6740, 0.1880])
xlim([0 250])
p1.Color(4) = 0.1;
p2.Color(4) = 0.1;
p3.Color(4) = 0.1;
p4.Color(4) = 0.1;
p5.Color(4) = 0.1;
p6.Color(4) = 0.1;
p7.Color(4) = 0.1;
p8.Color(4) = 0.1;
legend([p9 p10 p11 p12],'attP2>Ab1-42','R57C10>Ab1-42','R61D08>Ab1-42','R20B01>Ab1-42','Location','northwest')
legend boxoff
xlabel('Second (s)')
ylabel('Normalized Angle')


%%
figure(1)
subplot(3,1,1)
%  velocity
p1 = plot(TH_CS_smMean(:,1),TH_CS_smMean(:,2)+TH_CS_smSD(:,2),'Color',[0 0.4470 0.7410])
hold on
p2 = plot(TH_CS_smMean(:,1),TH_CS_smMean(:,2)-TH_CS_smSD(:,2),'Color',[0 0.4470 0.7410])
hold on
p3 = plot(TH_TNT_smMean(:,1),TH_TNT_smMean(:,2)+TH_TNT_smSD(:,2),'Color',[0.8500 0.3250 0.0980])
hold on
p4 = plot(TH_TNT_smMean(:,1),TH_TNT_smMean(:,2)-TH_TNT_smSD(:,2),'Color',[0.8500 0.3250 0.0980])
hold on
p5 =plot(TH_CS_smMean(:,1),TH_CS_smMean(:,2),'Color',[0 0.4470 0.7410])
hold on
p6 = plot(TH_TNT_smMean(:,1),TH_TNT_smMean(:,2),'Color',[0.8500 0.3250 0.0980])
xlim([0 150])
p1.Color(4) = 0.5;
p2.Color(4) = 0.5;
p3.Color(4) = 0.5;
p4.Color(4) = 0.5;
legend([p5 p6],'TH>CS','TH>TNT')
legend boxoff
ylabel('Velocity (mm/s)')

%  length
subplot(3,1,2)
p1 = plot(TH_CS_smMean(:,1),TH_CS_smMean(:,3)+TH_CS_smSD(:,3),'Color',[0 0.4470 0.7410])
hold on
p2 = plot(TH_CS_smMean(:,1),TH_CS_smMean(:,3)-TH_CS_smSD(:,3),'Color',[0 0.4470 0.7410])
hold on
p3 = plot(TH_TNT_smMean(:,1),TH_TNT_smMean(:,3)+TH_TNT_smSD(:,3),'Color',[0.8500 0.3250 0.0980])
hold on
p4 = plot(TH_TNT_smMean(:,1),TH_TNT_smMean(:,3)-TH_TNT_smSD(:,3),'Color',[0.8500 0.3250 0.0980])
hold on
p5 =plot(TH_CS_smMean(:,1),TH_CS_smMean(:,3),'Color',[0 0.4470 0.7410])
hold on
p6 = plot(TH_TNT_smMean(:,1),TH_TNT_smMean(:,3),'Color',[0.8500 0.3250 0.0980])
xlim([0 150])
p1.Color(4) = 0.5;
p2.Color(4) = 0.5;
p3.Color(4) = 0.5;
p4.Color(4) = 0.5;
legend([p5 p6],'TH>CS','TH>TNT')
legend boxoff
ylabel('Length (mm)')

%  curve
subplot(3,1,3)
p1 = plot(TH_CS_smMean(:,1),TH_CS_smMean(:,5)+TH_CS_smSD(:,5),'Color',[0 0.4470 0.7410])
hold on
p2 = plot(TH_CS_smMean(:,1),TH_CS_smMean(:,5)-TH_CS_smSD(:,5),'Color',[0 0.4470 0.7410])
hold on
p3 = plot(TH_TNT_smMean(:,1),TH_TNT_smMean(:,5)+TH_TNT_smSD(:,5),'Color',[0.8500 0.3250 0.0980])
hold on
p4 = plot(TH_TNT_smMean(:,1),TH_TNT_smMean(:,5)-TH_TNT_smSD(:,5),'Color',[0.8500 0.3250 0.0980])
hold on
p5 =plot(TH_CS_smMean(:,1),TH_CS_smMean(:,5),'Color',[0 0.4470 0.7410])
hold on
p6 = plot(TH_TNT_smMean(:,1),TH_TNT_smMean(:,5),'Color',[0.8500 0.3250 0.0980])
xlim([0 150])
p1.Color(4) = 0.5;
p2.Color(4) = 0.5;
p3.Color(4) = 0.5;
p4.Color(4) = 0.5;
legend([p5 p6],'TH>CS','TH>TNT')
legend boxoff
xlabel('Second (s)')
ylabel('Angle')



figure(2)
subplot(3,1,1)
%  velocity
p1 = plot(TH_CS_smMean(:,1),TH_CS_smMean(:,2)+TH_CS_smSD(:,2),'Color',[0 0.4470 0.7410])
hold on
p2 = plot(TH_CS_smMean(:,1),TH_CS_smMean(:,2)-TH_CS_smSD(:,2),'Color',[0 0.4470 0.7410])
hold on
p3 = plot(TH_THRNAi_smMean(:,1),TH_THRNAi_smMean(:,2)+TH_THRNAi_smSD(:,2),'Color',[0.8500 0.3250 0.0980])
hold on
p4 = plot(TH_THRNAi_smMean(:,1),TH_THRNAi_smMean(:,2)-TH_THRNAi_smSD(:,2),'Color',[0.8500 0.3250 0.0980])
hold on
p5 =plot(TH_CS_smMean(:,1),TH_CS_smMean(:,2),'Color',[0 0.4470 0.7410])
hold on
p6 = plot(TH_THRNAi_smMean(:,1),TH_THRNAi_smMean(:,2),'Color',[0.8500 0.3250 0.0980])
xlim([0 150])
p1.Color(4) = 0.5;
p2.Color(4) = 0.5;
p3.Color(4) = 0.5;
p4.Color(4) = 0.5;
legend([p5 p6],'TH>CS','TH>TH-RNAi')
legend boxoff
ylabel('Velocity (mm/s)')

%  length
subplot(3,1,2)
p1 = plot(TH_CS_smMean(:,1),TH_CS_smMean(:,3)+TH_CS_smSD(:,3),'Color',[0 0.4470 0.7410])
hold on
p2 = plot(TH_CS_smMean(:,1),TH_CS_smMean(:,3)-TH_CS_smSD(:,3),'Color',[0 0.4470 0.7410])
hold on
p3 = plot(TH_THRNAi_smMean(:,1),TH_THRNAi_smMean(:,3)+TH_THRNAi_smSD(:,3),'Color',[0.8500 0.3250 0.0980])
hold on
p4 = plot(TH_THRNAi_smMean(:,1),TH_THRNAi_smMean(:,3)-TH_THRNAi_smSD(:,3),'Color',[0.8500 0.3250 0.0980])
hold on
p5 =plot(TH_CS_smMean(:,1),TH_CS_smMean(:,3),'Color',[0 0.4470 0.7410])
hold on
p6 = plot(TH_THRNAi_smMean(:,1),TH_THRNAi_smMean(:,3),'Color',[0.8500 0.3250 0.0980])
xlim([0 150])
p1.Color(4) = 0.5;
p2.Color(4) = 0.5;
p3.Color(4) = 0.5;
p4.Color(4) = 0.5;
legend([p5 p6],'TH>CS','TH>TH-RNAi')
legend boxoff
ylabel('Length (mm)')

%  curve
subplot(3,1,3)
p1 = plot(TH_CS_smMean(:,1),TH_CS_smMean(:,5)+TH_CS_smSD(:,5),'Color',[0 0.4470 0.7410])
hold on
p2 = plot(TH_CS_smMean(:,1),TH_CS_smMean(:,5)-TH_CS_smSD(:,5),'Color',[0 0.4470 0.7410])
hold on
p3 = plot(TH_THRNAi_smMean(:,1),TH_THRNAi_smMean(:,5)+TH_THRNAi_smSD(:,5),'Color',[0.8500 0.3250 0.0980])
hold on
p4 = plot(TH_THRNAi_smMean(:,1),TH_THRNAi_smMean(:,5)-TH_THRNAi_smSD(:,5),'Color',[0.8500 0.3250 0.0980])
hold on
p5 =plot(TH_CS_smMean(:,1),TH_CS_smMean(:,5),'Color',[0 0.4470 0.7410])
hold on
p6 = plot(TH_THRNAi_smMean(:,1),TH_THRNAi_smMean(:,5),'Color',[0.8500 0.3250 0.0980])
xlim([0 150])
p1.Color(4) = 0.5;
p2.Color(4) = 0.5;
p3.Color(4) = 0.5;
p4.Color(4) = 0.5;
legend([p5 p6],'TH>CS','TH>TH-RNAi')
legend boxoff
xlabel('Second (s)')
ylabel('Angle')

%% Compare baseline velocities
a = find(attP240_Ab42_smMean(:,1)>10 & attP240_Ab42_smMean(:,1)<55);
v_exp_attP240_Ab42(1) = mean(attP240_Ab42_smMean(a(1):a(end),2));

%% visualize velocity
% for colors that are Cho, B1
color1 = [[0,0,0];[0.8,0,0.2];[0.3,0.7,0.2];[0.3,0.9,1]];
% colors: B2, G-2, and Hb
color2 = [[0,0,0];[0,0.4,1];[0.9,0.2,0.5];[0.9,0.5,0]];
figure(1),hold on
subplot(1,2,1),hold on
m = length(color1);
title('Average Velocity (10-55s)');
for k = 1:m
    h = bar(k,v_exp_attP240_Ab40(k));
    set(h,'FaceColor',color2(k,:));
end
newXticklabel = {'attP2-40>Ab1-40','SS00739>Ab1-40','SS00888>Ab1-40','SS00918>Ab1-40'};
set(gca,'XtickLabel',newXticklabel);
xlim([0.5 4.5]);
ylim([0 0.6]);
xtickangle(45);
xlabel('Genotype');
ylabel('mm/s');

subplot(1,2,2), hold on
title('Average Velocity (10-55s)');
for k = 1:m
    h = bar(k,v_exp_attP240_Ab42(k));
    set(h,'FaceColor',color2(k,:));
end
newXticklabel = {'attP2-40>Ab1-42','SS00739>Ab1-42','SS00888>Ab1-42','SS00918>Ab1-42'};
set(gca,'XtickLabel',newXticklabel);
xlim([0.5 4.5]);
ylim([0 0.6]);
xtickangle(45);
xlabel('Genotype');
ylabel('mm/s');
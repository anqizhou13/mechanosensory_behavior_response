%% Load all the probabilitites over time to graph them 

clear all

adresses = {
'/Volumes/TOSHIBA/t2/FCF_attP2-40@UAS_Abeta40_116/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/exp3/';
%'/Volumes/TOSHIBA/t2/FCF_attP2-40@UAS_Abeta42_117/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/exp3/';
'/Volumes/TOSHIBA/t2/GMR_SS00739@UAS_Abeta40_116/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/exp3/';
%'/Volumes/TOSHIBA/t2/GMR_SS00739@UAS_Abeta42_117/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/exp3/';
'/Volumes/TOSHIBA/t2/GMR_SS00888@UAS_Abeta40_116/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/exp3/';
%'/Volumes/TOSHIBA/t2/GMR_SS00888@UAS_Abeta42_117/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/exp3/';
'/Volumes/TOSHIBA/t2/GMR_SS00918@UAS_Abeta40_116/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/exp3/';
%'/Volumes/TOSHIBA/t2/GMR_SS00918@UAS_Abeta42_117/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/exp3/';
%'/Volumes/TOSHIBA/t2/GMR_SS00739@w1118/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/';
%'/Volumes/TOSHIBA/t2/GMR_SS00888@w1118/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/';
%'/Volumes/TOSHIBA/t2/GMR_SS00918@w1118/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/';
%'/Volumes/TOSHIBA/t2/FCF_attP2@UAS_Abeta40_116/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/';
%'/Volumes/TOSHIBA/t2/FCF_attP2@UAS_Abeta42_117/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/';
%'/Volumes/TOSHIBA/t2/GMR_61D08@UAS_Abeta40_116/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/';
%'/Volumes/TOSHIBA/t2/GMR_61D08@UAS_Abeta42_117/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/';
%'/Volumes/TOSHIBA/t2/GMR_20B01@UAS_Abeta40_116/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/';
%'/Volumes/TOSHIBA/t2/GMR_20B01@UAS_Abeta42_117/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/';
}

% change color palette, the first two are always colors for controls
% color = [[0,0,0];[0,0.2,0];[0,0.6,0.1];[0,0.9,0.5]]; % Cho green
% color = [[0,0,0];[0,0,0.2];[0,0.7,1];[0,0.9,1]]; % B1 blue
% color = [[0,0,0];[0,0,0.2];[0.1,0,0.7];[0.1,0.2,1]]; % B2 dark blue
% color = [[0,0,0];[0.2,0,0.1];[1,0.1,0.6];[1,0.4,0.7]]; % Hb pink
% color = [[0,0,0];[0.2,0,0.1];[1,0.5,0.1];[1,0.7,0.2]]; % G2 orange

testGeno = 'attP2_SS00739_SS00888_SS00918'; % the genotype that is being graphed against control
whichAb = 'Ab1-40';
%color = [[0,0,0];[0.3,0.7,0.2];[0.3,0.9,1]]; % colors used
color = [[0,0,0];[0.1,0,0.7];[1,0.1,0.6];[1,0.5,0.1]];

windows = [30 120
           115 225]; % windows to graph


for i = 1:length(adresses)
file = dir(fullfile(adresses{i}, 'dataFiles_bendNotSeparated/probabilitiesovertime.mat'));
L = load([file.folder '/' file.name]);
genotypes{i,:} = L.probabilities;
end

stringActions = {'Crawl','Cast','Stop','Hunch','Backup','Static Bend'};
index = [1 2 3 4 5 9]; % the action that you want to graph index in probability struct

% where to save the line plots
root_folder = '/Volumes/TOSHIBA/MATLAB/trx/prob_line_plots/';

% Line plot
for s = 1:length(windows) % for each window
figure(s)
sgtitle(whichAb)
for k = 1:length(index)
subplot(3,2,k)
for j = 1:length(genotypes)
    actions = fieldnames(genotypes{j,1});
    subset = genotypes{j,1}.(actions{index(k)});
    left = windows(s,1);
    right = windows(s,2);
    subset = subset(subset(:,1)>=left & subset(:,1)<=right,:);
    plot([left:0.1:right], subset(:,2),...
        'LineWidth',2,'Color',color(j,:))
    hold on
end
xlim(windows(s,:))
title(stringActions(k));
xlabel('Second');
ylabel('Probability');
if windows(s,1)< 60 % if graphing the first initial stimulus
xlim(subplot(3,2,4),[59 62]) %for hunch, always graph only where hunches appear
end
end
 % save the line plots
        filename = strcat(root_folder,windows(s,1),'_',windows(s,2),'s_',testGeno,'_',whichAb,'.fig');
        saveas(gcf,char(filename));
        filename = strcat(root_folder,windows(s,1),'_',windows(s,2),'s_',testGeno,'_',whichAb);
        saveas(gcf,char(filename),'epsc')
end
close all
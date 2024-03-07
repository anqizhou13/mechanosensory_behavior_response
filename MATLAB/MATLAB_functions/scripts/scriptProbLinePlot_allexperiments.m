%% Load all the probabilitites over time to graph them 
% modified from scriptProbLinePlot 
% designed to plot all experiments for a specific genotype/condition
% to visualize variance among repititions

% TO CHANGE: adresses, driver & effector name, as well as windows to graph

clear all

adresses = {
'/Volumes/TOSHIBA/t2/FCF_attP2-40@UAS_Abeta40_116/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/exp3/20210412_140914/';
'/Volumes/TOSHIBA/t2/FCF_attP2-40@UAS_Abeta40_116/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/exp3/20210420_133117/';
'/Volumes/TOSHIBA/t2/FCF_attP2-40@UAS_Abeta40_116/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/exp3/20210528_102708/';
'/Volumes/TOSHIBA/t2/FCF_attP2-40@UAS_Abeta40_116/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/exp3/20210917_101151/';
'/Volumes/TOSHIBA/t2/FCF_attP2-40@UAS_Abeta40_116/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/exp3/20210920_135038/';
'/Volumes/TOSHIBA/t2/FCF_attP2-40@UAS_Abeta40_116/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/exp3/20210921_144806/';
}


testGeno = 'attP2-40'; % the driver
whichAb = 'Ab1-40'; % the effector

% DO NOT CHANGE FROM HERE DOWN
windows = [30 120
           115 225]; % windows to graph
       
labels = char(adresses);
labels = labels(:,end-15:end-1);

for i = 1:length(adresses)
file = dir(fullfile(adresses{i}, 'dataFiles_bendNotSeparated/probabilitiesovertime.mat'));
L = load([file.folder '/' file.name]);
genotypes{i,:} = L.probabilities;
end

stringActions = {'Crawl','Cast','Stop','Hunch','Backup','Static Bend'};
index = [1 2 3 4 5 9]; % the action that you want to graph index in probability struct

% where to save the line plots
root_folder = '/Volumes/TOSHIBA/MATLAB/trx/prob_line_plots/all_exps_per_genotype/bend_NOTseparated/';

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
        'LineWidth',1)
    hold on
end
set(gcf, 'Position', [-2110,451,1811,934]);
xlim(windows(s,:))
title(stringActions(k));
xlabel('Second');
ylabel('Probability');
legend(labels);
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

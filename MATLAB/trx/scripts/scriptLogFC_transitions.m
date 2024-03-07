%% calculate Log FC of transitions compared to control genotype
%          this script compiles genotypes desired together to compute logFC
%          of transition, conduct chi-square statistical test, and to graph
%          the log2FC values as heatmaps for each genotype being compared
%          to its respective control
%   
clear all

adresses = {
%'/Volumes/TOSHIBA/t2/GMR_61D08@UAS_Abeta40_116/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/';
%'/Volumes/TOSHIBA/t2/GMR_20B01@UAS_Abeta40_116/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/';
%'/Volumes/TOSHIBA/t2/GMR_55C05@UAS_Abeta40_116/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/';
%'/Volumes/TOSHIBA/t2/FCF_attP2@UAS_Abeta42_117/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/';
%'/Volumes/TOSHIBA/t2/GMR_61D08@UAS_Abeta42_117/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/';
%'/Volumes/TOSHIBA/t2/GMR_20B01@UAS_Abeta42_117/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/';
%'/Volumes/TOSHIBA/t2/GMR_55C05@UAS_Abeta42_117/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/';
%'/Volumes/TOSHIBA/t2/FCF_attP2-40@UAS_Abeta40_116/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/';
%'/Volumes/TOSHIBA/t2/GMR_SS00739@UAS_Abeta40_116/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/';
%'/Volumes/TOSHIBA/t2/GMR_SS00888@UAS_Abeta40_116/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/';
%'/Volumes/TOSHIBA/t2/SS_TJ001_G2@UAS_Abeta40_116/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/';
'/Volumes/TOSHIBA/t2/FCF_attP2-40@UAS_Abeta42_117/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/';
'/Volumes/TOSHIBA/t2/GMR_SS00739@UAS_Abeta42_117/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/';
'/Volumes/TOSHIBA/t2/GMR_SS00888@UAS_Abeta42_117/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/';
'/Volumes/TOSHIBA/t2/SS_TJ001_G2@UAS_Abeta42_117/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/';
}

%% get colormap
map = getPyPlot_cMap('RdBu_r',[],[],'/usr/local/bin/python3');

% compile data of desired genotypes
for i = 1:length(adresses)
    adress = adresses{i};
    file = dir(fullfile(adress, 'dataFiles_larvatagger_v2/allTransitions.mat'));
    L = load([file.folder '/' file.name]);
    genotypes{i,:} = L.allTransitions;
end

% list the actions
% the actions from the raw transition matrix are in the following order
% 'Crawl','Cast','Stop','Hunch','Backup','Roll','Small Actions','Backup Sequence','Static Bend'

% to plot transition of only the relevant actions
stringActions = {'Crawl','Cast','Stop','Hunch','Backup','Static Bend'};
% designate where to save the results + plots
root_folder = '/Volumes/TOSHIBA/t2_behavior_data_abalysis/MATLAB/transition_log2FC_heatmaps/';

% transition heatmaps
%list all of the windows where transition probabilities are calculated
windows = fieldnames(genotypes{1,1}.normalized);

% start looping from the second genotype, not including control
for j = 2:length(genotypes)
    adress = adresses(j);
    splits = split(adress,"/");
    geno_label = char(splits(5));
    mkdir(root_folder, geno_label);
for s = 1:length(windows)
    mkdir([root_folder, geno_label,'/',windows{s}]);
    % use the window names as titles of plots
plotTitle = strcat('Transition probability changes:',strrep(windows(s), '_', '-'));

% first compute the log2 FC
trans_test = genotypes{j,1}.normalized.(windows{s});
trans_control = genotypes{1,1}.normalized.(windows{s});
logFC = log2(trans_test./trans_control);

% select only certain actions
logFC = logFC([1:5 9],[1:5 9]);
% make NAN values zero so that these squares are plotted as white colored
logFC(isnan(logFC)) = 0; 

% plot the heatmap
figure(s)
imagesc(logFC)
colormap(map)
caxis([-5 5])
%caxis([-1 1])
set(gca,'XTick',1:numel(stringActions), 'XTickLabel',stringActions)
set(gca,'YTick',1:numel(stringActions), 'YTickLabel',stringActions)
xtickangle(45)
colorbar()
pbaspect([1 1 1])
title(plotTitle)
set(gca,'XTickLabel',stringActions,'YTickLabel',stringActions)
set(gcf, 'PaperUnits', 'inches');
set(gcf, 'PaperSize', [3 3]);
set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperPosition', [0 0 3 3]);

filename = strcat(root_folder,geno_label,'/',windows{s},'/',char(geno_label),'_','log2FC');
saveas(gcf,char(filename),'epsc')
saveas(gcf,char(filename),'pdf')

% then do chi-square test to output signifiance values
% get the transition frequency
trans_test = genotypes{j,1}.notNormalized.(windows{s})([1:5 9],[1:5 9]);
trans_control = genotypes{1,1}.notNormalized.(windows{s})([1:5 9],[1:5 9]);

for m = 1:length(trans_test)
    for n = 1:length(trans_test)
        if m == n
            p_table(m,n) = NaN;
        else
            hits = [trans_test(m,n) trans_control(m,n)];
            total = [sum(trans_test,'all') sum(trans_control,'all')];
            [h,p,chi2stat,df] = prop_test(hits,total,false);
            p_table(m,n) = p;
            chi_stats(m,n) = chi2stat;
        end
    end
end
writematrix(p_table,strcat(root_folder,geno_label,'/',windows{s},'/',char(geno_label),'_','p_values.txt'),'Delimiter','tab')
writematrix(chi_stats,strcat(root_folder,geno_label,'/',windows{s},'/',char(geno_label),'_','chi_stats.txt'),'Delimiter','tab')
end
close all
end

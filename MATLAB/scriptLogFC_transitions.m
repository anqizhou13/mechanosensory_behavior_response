%% calculate Log FC of transitions compared to control genotype
%          this script compiles genotypes desired together to compute logFC
%          of transition, conduct chi-square statistical test, and to graph
%          the log2FC values as heatmaps for each genotype being compared
%          to its respective control
%   
clear all

adresses = {
%'/Volumes/TOSHIBA/t2/FCF_attP2@UAS_Abeta40_116/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/';
%'/Volumes/TOSHIBA/t2/GMR_55C05@UAS_Abeta40_116/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/';
%'/Volumes/TOSHIBA/t2/GMR_61D08@UAS_Abeta40_116/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/';
%'/Volumes/TOSHIBA/t2/GMR_20B01@UAS_Abeta40_116/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/';
%'/Volumes/TOSHIBA/t2/FCF_attP2@UAS_Abeta42_117/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/';
%'/Volumes/TOSHIBA/t2/GMR_55C05@UAS_Abeta42_117/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/';
%'/Volumes/TOSHIBA/t2/GMR_61D08@UAS_Abeta42_117/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/';
%'/Volumes/TOSHIBA/t2/GMR_20B01@UAS_Abeta42_117/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/';
%'/Volumes/TOSHIBA/t2/FCF_attP2-40@UAS_Abeta40_116/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/';
%'/Volumes/TOSHIBA/t2/GMR_SS00739@UAS_Abeta40_116/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/';
%'/Volumes/TOSHIBA/t2/GMR_SS00888@UAS_Abeta40_116/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/';
%'/Volumes/TOSHIBA/t2/SS_TJ001_G2@UAS_Abeta40_116/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/';
%'/Volumes/TOSHIBA/t2/GMR_SS00918@UAS_Abeta40_116/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/';
'/Volumes/TOSHIBA/t2/FCF_attP2-40@UAS_Abeta42_117/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/';
%'/Volumes/TOSHIBA/t2/GMR_SS00739@UAS_Abeta42_117/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/';
%'/Volumes/TOSHIBA/t2/GMR_SS00888@UAS_Abeta42_117/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/';
'/Volumes/TOSHIBA/t2/SS_TJ001_G2@UAS_Abeta42_117/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/';
}

%geno_labels = {'attP2_Ab1-42','55C05_Ab1-42'};
%geno_labels = {'attP2_Ab1-42','61D08_Ab1-42','20B01_Ab1-42'}
%geno_labels = {'attP2_Ab1-42','61D08_Ab1-42','20B01_Ab1-42'};
geno_labels = {'attP2-40_Ab1-42','SS_TJ001_G2_Ab1-42'};
%geno_labels = {'attP2-40_Ab1-42','SS00739_Ab1-42','SS00888_Ab1-42'};

% get colormap
map = getPyPlot_cMap('RdBu_r',128,[],'/usr/local/bin/python3');

% compile data of desired genotypes
for i = 1:length(adresses)
file = dir(fullfile(adresses{i}, 'dataFiles_larvatagger_v8/allTransitions.mat'));
L = load([file.folder '/' file.name]);
genotypes{i,:} = L.allTransitions;
end

% list the actions
% the actions from the raw transition matrix are in the following order
% 'Crawl','Cast','Stop','Hunch','Backup','Roll','Small Actions','Backup Sequence','Static Bend'

% to plot transition of only the relevant actions
stringActions = {'Crawl','Bend','Hunch'};
% designate where to save the results + plots
root_folder = '/Volumes/TOSHIBA/t2_behavior_data_abalysis/MATLAB/trx/transition_heatmaps/';

% transition heatmaps
%list all of the windows where transition probabilities are calculated
windows = fieldnames(genotypes{1,1}.normalized);

%% first plot the transition probabilities for each genotype for each window
for j = 1:length(genotypes)
for s = 3:3 % select windows
    % use the window names as titles of plots
plotTitle = strcat('Transition probabilities:',strrep(windows(s), '_', '-'));
proba = genotypes{j,1}.normalized.(windows{s});

% select only certain actions
proba = proba([1:2 4],[1:2 4]);
% make NAN values zero so that these squares are plotted as white colored
proba(isnan(proba)) = 0;


% plot the heatmap
figure(s);
x=[1:1:length(stringActions)];
y=[1:1:length(stringActions)];
h=imagesc(x,y,proba)
colormap(getPyPlot_cMap('Blues',128,[],'/usr/local/bin/python3'))
%%%%caxis([0 1])
colorbar()
pbaspect([1 1 1])
title(plotTitle)
xtickangle(90)
set(gca,'XTick',[1:1:3],'XTickLabel',stringActions,'YTickLabel',stringActions)
set(gcf,'units','points','position',[10,100,200,200])
[xTxt, yTxt] = ndgrid(h.XData, h.YData); 
labels = compose('%.2f', h.CData');
th = text(xTxt(:), yTxt(:), labels(:), 'VerticalAlignment', 'middle','HorizontalAlignment','Center');
filename = strcat(root_folder,windows(s),'_',char(geno_labels(j)),'_','transition_proba');
saveas(gcf,char(filename),'pdf')
close all

% plot also the total number of transition events
%plotTitle = strcat('Transition events:',strrep(windows(s), '_', '-'));
%proba = genotypes{j,1}.notNormalized.(windows{s});

% select only certain actions
%proba = proba([1:2 4],[1:2 4]);
% make NAN values zero so that these squares are plotted as white colored
%proba(isnan(proba)) = 0;

% plot the heatmap
%figure(s);
%x=[1:1:length(stringActions)];
%y=[1:1:length(stringActions)];
%h=imagesc(x,y,proba)
%colormap(getPyPlot_cMap('Blues',128,[],'/usr/local/bin/python3'))
%colorbar()
%pbaspect([1 1 1])
%title(plotTitle)
%xtickangle(90)
%set(gca,'XTick',[1:1:3],'XTickLabel',stringActions,'YTick',[1:1:3],'YTickLabel',stringActions)
%set(gcf,'units','points','position',[10,100,200,200])
%[xTxt, yTxt] = ndgrid(h.XData, h.YData); 
%labels = compose('%d', h.CData');
%th = text(xTxt(:), yTxt(:), labels(:), 'VerticalAlignment', 'middle','HorizontalAlignment','Center');
%filename = strcat(root_folder,windows(s),'_',char(geno_labels(j)),'_','events');
%saveas(gcf,char(filename),'pdf')
end
end

close all

%% to plot the log2 fold change
% start looping from the second genotype, not including control
for j = 2:length(genotypes)
for s = 3:3 % select windows
    % use the window names as titles of plots
plotTitle = strcat('Transition prob Log2 FC:',strrep(windows(s), '_', '-'));

% first compute the log2 FC
trans_test = genotypes{j,1}.normalized.(windows{s});
trans_control = genotypes{1,1}.normalized.(windows{s});
logFC = log2(trans_test./trans_control);

% select only certain actions
logFC = logFC([1:2 4],[1:2 4]);
% make NAN values zero so that these squares are plotted as white colored
logFC(isnan(logFC)) = 0; 

% plot the heatmap
figure(s)
imagesc(logFC)
colormap(map)
caxis([-1 1])
colorbar()
pbaspect([1 1 1])
xtickangle(90)
set(gca,'XTick',[1:1:3],'XTickLabel',stringActions,'YTick',[1:1:3],'YTickLabel',stringActions)
set(gcf,'units','points','position',[10,100,200,200])

filename = strcat(root_folder,windows(s),'_',char(geno_labels(j)),'_','proba_log2FC');
saveas(gcf,char(filename),'pdf')

%plotTitle = strcat('Transition events Log2 FC:',strrep(windows(s), '_', '-'));
% first compute the log2 FC
%trans_test = genotypes{j,1}.notNormalized.(windows{s});
%trans_control = genotypes{1,1}.notNormalized.(windows{s});
%logFC = log2(trans_test./trans_control);

% select only certain actions
%logFC = logFC([1:2 4],[1:2 4]);
% make NAN values zero so that these squares are plotted as white colored
%logFC(isnan(logFC)) = 0; 

% plot the heatmap
%figure(s)
%imagesc(logFC)
%colormap(map)
%%caxis([-1 1])
%colorbar()
%pbaspect([1 1 1])
%set(gca,'XTickLabel',stringActions,'YTickLabel',stringActions)
%xtickangle(90)
%set(gca,'XTick',[1:1:3],'XTickLabel',stringActions,'YTick',[1:1:3],'YTickLabel',stringActions)
%set(gcf,'units','points','position',[10,100,200,200])

%filename = strcat(root_folder,windows(s),'_',char(geno_labels(j)),'_','events_log2FC');
%saveas(gcf,char(filename),'pdf')


% then do chi-square test to output signifiance values
% get the transition frequency
trans_test =genotypes{j,1}.notNormalized.(windows{s});
trans_control = genotypes{1,1}.notNormalized.(windows{s});

result = struct;
for m = 1:length(trans_test)
    for n = 1:length(trans_test)
        if m == n
            p_table(m,n) = NaN;
        else
            hits = [trans_test(m,n) trans_control(m,n)];
            total = [sum(trans_test(m,:)) sum(trans_control(m,:))]; % compute row sum
            [h,p,chi2stat,df] = prop_test(hits,total,false);
            p_table(m,n) = p;
            chi_stats(m,n) = chi2stat;
        end
    end
end

p_values = table(p_table);
writetable(p_values,char(strcat(root_folder,windows(s),'_',char(geno_labels(j)),'_','p_values.txt')),'Delimiter','\t');
chi2_stats = table(chi_stats);
writetable(p_values,char(strcat(root_folder,windows(s),'_',char(geno_labels(j)),'_','chi2_stats.txt')),'Delimiter','\t');
end
close all
end

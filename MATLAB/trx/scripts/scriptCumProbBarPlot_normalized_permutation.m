%% bar plot cumulative probability, grouped per neuron with Ab 1-40 and 1-42
%          this script compiles genotypes desired together to graph
%          grouped cumulative probability bar plots as well as 
%          to perform chi-square testing for each pair of genotypes
%          to adapt to a specific genotype, recursively replace the 
%          genotypes here in this section
%          DO NOT MODIFY THE SECOND SECTION
clear all

adresses = {
'/Volumes/TOSHIBA/t2/FCF_attP2@UAS_Abeta40_116/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/';
'/Volumes/TOSHIBA/t2/FCF_attP2@UAS_Abeta42_117/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/';
'/Volumes/TOSHIBA/t2/GMR_61D08@UAS_Abeta40_116/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/';
'/Volumes/TOSHIBA/t2/GMR_61D08@UAS_Abeta42_117/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/';
}

% change color palette, the first two are always colors for controls
 color = [[0,0,0];[0,0.2,0];[0,0.6,0.1];[0,0.9,0.5]]; % Cho green
% color = [[0,0,0];[0,0,0.2];[0,0.7,1];[0,0.9,1]]; % B1 blue
%color = [[0,0,0];[0,0,0];[0,0,0.2];[0.1,0,0.7];[0.1,0.2,1]]; % B2 dark blue
%color = [[0,0,0];[0,0,0];[0.2,0,0.1];[1,0.1,0.6];[1,0.4,0.7]]; % Hb pink
%color = [[0,0,0];[0,0,0];[0.2,0,0.1];[1,0.5,0.1];[1,0.7,0.2]]; % G2 orange

newXticklabel = {'attP2>Ab1-40','attP2>Ab1-42','61D08>Ab1-40','61D08>Ab1-42'};
testGeno = 'R61D08'; % the genotype that is being graphed against control

%%
for i = 1:length(adresses)
file = dir(fullfile(adresses{i}, 'dataFiles/cumulativeProbabilities.mat'));
L = load([file.folder '/' file.name]);
genotypes{i,:} = L.cumulativeProbabilities;
end

% list the actions
stringActions = {'Crawl','Cast','Stop','Hunch','Backup','Roll',...
    'Small Actions','Backup Sequence','Static Bend'};
% designate where to save the results + plots
root_folder = '/Volumes/TOSHIBA/MATLAB/trx/bar_plots_permutation/';

%bar plot

windows = fieldnames(genotypes{1,1});
for s = 1:length(windows)
plotTitle = strcat('Normalized Cumulative Probability:',strrep(windows(s), '_', '-'));
actions = fieldnames(genotypes{1,1}.(windows{s}));
figure(s)
fullfig
sgtitle(plotTitle)

for k = 1:length(stringActions) % for each action
subplot(3,length(stringActions)/3,k),hold on % make a subplot
title(stringActions(k));
for j = 1:length(genotypes)
    % store probability and number of larvae for statistical testing
    prob(j,k) = genotypes{j,1}.(windows{s}).(actions{k}).proba;
    probcontrol(j,k) = genotypes{j,1}.(windows{s}).(actions{k}).probacontrol;
    N(j,k) = genotypes{j,1}.(windows{s}).(actions{k}).numberoflarvae;
    Ncontrol(j,k) = genotypes{j,1}.(windows{s}).(actions{k}).numberoflarvaecontrol;
    freq(j,k) = round(prob(j,k)*N(j,k));
    freqcontrol(j,k) = round(probcontrol(j,k)*Ncontrol(j,k));
    % plot
    h = bar(j,prob(j,k) - probcontrol(j,k));
    set(h,'FaceColor',color(j,:));
end
set(gca,'XtickLabel',newXticklabel);
% display it on the second monitor
% retrieving position of figure that you want
%f = figure('Units','normalized')
%f
% place it wherever you want 
%check units
%retreive location info
%pos1 = f.Position;
% use pos1 to set the figure
set(gcf, 'Position', [-0.3328,1,1.3602,1.22]);
xlim([0.5 length(genotypes)+0.5]);
%ylim([0 0.2]);
xtickangle(45);
xlabel('Genotype');
ylabel('Normalized Cumulative Probability');
box off
pbaspect([1 1 1])
end

% compute and write probabilities
pStatistics = struct;
pStatistics.window = strrep(windows(s), '_', '-');
for k = 1:length(stringActions)
            numpair = 0;
            
    for j = 1:length(genotypes)-1
        index_to_compare = j+1:1:length(genotypes);
        
        % for each comparison
        for l = index_to_compare(1):index_to_compare(end)
            result = struct;            
            [~,~, p] = pvalue_convergence_bend(freqcontrol(l,k),...
 Ncontrol(l,k), freq(l,k), N(l,k), freqcontrol(j,k), Ncontrol(j,k), freq(j,k), N(j,k));
            result.group1 = newXticklabel{j};
            result.group2 = newXticklabel{l};
            result.p = p;
            
            numpair = numpair+1;
            comparison = strcat('comparison',string(numpair));
         
            pStatistics.(actions{k}).(comparison) = result;
        end
            
    end
end
   
   % save the cumulative probability bar plots

        filename = strcat(root_folder,windows(s),'_',testGeno,'.fig');
        saveas(gcf,char(filename));
        filename = strcat(root_folder,windows(s),'_',testGeno);
        saveas(gcf,char(filename),'epsc')
        
   % save the statistical test results
        filename = strcat(root_folder,windows(s),'_',testGeno,'_','pStatistics_permutation.mat');
        save(char(filename), 'pStatistics')
close all
end



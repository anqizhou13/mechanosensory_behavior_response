%% This scripts extracts the probability, cumulative probability of actions,
% and transitions between actions
% of all larvae from the trx.mat file, during the different time windows

% Statistical test used for comparing cumulative proba (non corrected) :
% Chi2 test

% CHANGE : adresses, timewindows, couleursconditions, conditionstoplot,
% actionstoplot, couleursactions

clear all

adresses=[
          "C:\Users\edetredern\Documents\Experiences\Comportement\20200529_allANR\By_genotypes_ctrlAttp2\AttP2\";
          "C:\Users\edetredern\Documents\Experiences\Comportement\20200529_allANR\By_genotypes_ctrlAttp2\GMR20B01\";
          "C:\Users\edetredern\Documents\Experiences\Comportement\20200529_allANR\By_genotypes_ctrlAttp240\AttP240\";
          "C:\Users\edetredern\Documents\Experiences\Comportement\20200529_allANR\By_genotypes_ctrlAttp240\GMRSS00739\";
          "C:\Users\edetredern\Documents\Experiences\Comportement\20200529_allANR\By_genotypes_ctrlAttp240\GMRSS00918\";
    ];

for exp=1:length(adresses)
    
    clearvars -except adresses exp
    %% Define the parameters
    
    % !! Important: put all files in a "data" folder (with the "data" name
    % only) contained in the main folder specified by 'adress' below
    adress=char(adresses(exp));
    % adress='C:\Users\edetredern\Documents\Experiences\Comportement\20200402_trxattp240\';
    timewindows=[
        15 59 % ! time windows must not last for more than 59s
        60 62
        60 65
        60 75
        60 90
        90 120 % recovery
        ];
    tfin=250;
    numberofwindows=length(timewindows);
    actionnames=["crawl"
        "head_cast"
        "stop"
        "hunch"
        "back_up"
        "roll"
        "small_actions"
        "backup_sequence"
        "bend"
        ];
    states=["run";"cast";"stop";"hunch";"backup";"roll";"small_actions" ;
        "backup_sequence";
        "bend_static"
        ];
    
    % actions to plot separately
    actionstoplot=[1 2 3 4 5 6 9];

    couleursactions=[
        0    0    0 % crawl
        1    0    0 % head cast
        0    1    0 % stop
        0    0    1 % hunch
        0    1    1 % back-up
        1    1    0 % roll
        1    0    1 % small actions
        0    0.4470    0.7410 % backup sequences
        0.8500    0.3250    0.0980 % bend / static bend
        ];
    
couleursconditions=[
    %
    %     0    0    0
    %     1    0    0
    %     0    1    0
    %     0    0    1
    %     0    1    1
    %     1    1    0
    %     1    0    1
    %
    %
    0    0.4470    0.7410
    0.8500    0.3250    0.0980
    0.9290    0.6940    0.1250
    % % %     0.4940    0.1840    0.5560
    %     0.4660    0.6740    0.1880
    %     0.3010    0.7450    0.9330
    %     0.6350    0.0780    0.1840
    0.2422    0.1504    0.6603
    0.4 0.8 0.8
    1 0.6 1
    ];
    
    
    %% Concatenate trx for all experiments in each condition
    
    % get all folders contained in the main folder in the directory; each folder = one condition
    dossierppal=dir([adress 'data\']);
    % get all the folders identities (one folder for each condition)
    dirparcondition=find(vertcat(dossierppal.isdir));
    dossiersparconditions=dossierppal(dirparcondition);
    nombredeconditions=length(dirparcondition)-2;
    
    % scan folders to get and concatenate data for each condition and get names of conditions
    titres=[];
    TRX=struct;
    for condition=1:nombredeconditions
        titres=[titres; string(dossiersparconditions(condition+2).name)];
        conditionname=titres(condition);
        adressescan=[adress 'data\' dossiersparconditions(condition+2).name];
        TRX.(conditionname)=concatenateTrx(adressescan);
    end
    
    % conditions to plot separately
    conditionstoplot=NaN(nombredeconditions-1,2);
    combinationconditionnames=[];
    conditionstoplot(:,1)=1;
    for i=2:nombredeconditions
        conditionstoplot(i-1,2)=i;
        combinationconditionnames=[combinationconditionnames; titres(i)];
    end
    
    mkdir(adress, 'dataFiles');
    filename=[adress 'dataFiles\trx_concatenated.mat'];
%     save(filename, 'TRX'); % save concatenated trx file
    
%% Save names of all experimental folders used to analyze data
experimental_folders=[];
for condition=1:nombredeconditions
    conditionname=titres(condition);
    experimental_folders=[experimental_folders; unique({TRX.(conditionname).id}.')];
end
experimental_folders=table(experimental_folders);
filename=[adress 'dataFiles\experimental_folders.txt'];
writetable(experimental_folders, filename);


%% Reformat to include small actions

for condition=1:nombredeconditions
    conditionname=titres(condition);
    for larva=1:length(TRX.(conditionname))
        larvaname=['larva' num2str(larva)];
        TRX.(conditionname)(larva).global_state_large_state_beforesmall=TRX.(conditionname)(larva).global_state_large_state;
        TRX.(conditionname)(larva).global_state_large_state=ceil(TRX.(conditionname)(larva).global_state_small_large_state);
    end
end

mkdir(adress, 'dataFiles');
filename=[adress 'dataFiles\trx_concatenated_small_actions.mat'];
save(filename, 'TRX'); % save concatenated trx file

    %% Reformat to include bend vs head cast
    
    actionLarva=struct;
    for condition=1:nombredeconditions
        conditionname=titres(condition);
        actionLarva.(conditionname)=headVSbendFromTrx(TRX.(conditionname));
    end
    
    % Add new fields with actions that take into account head cast vs bend
    
    for condition=1:nombredeconditions
        conditionname=titres(condition);
        for larva=1:length(TRX.(conditionname))
            larvaname=['larva' num2str(larva)];
            TRX.(conditionname)(larva).global_state_large_state=actionLarva.(conditionname).(larvaname).action;
        end
    end
    
    %% Add new fields with actions over time for each action
    % write 1 if the action is performed, 0 if not
    
    for condition=1:nombredeconditions
        conditionname=titres(condition);
        for larva=1:length(TRX.(conditionname))
            larvaname=['larva' num2str(larva)];
            for action=1:length(states)
                actionname=states(action);
                indices=find(TRX.(conditionname)(larva).global_state_large_state==action);
                numberstoadd=zeros(length(TRX.(conditionname)(larva).global_state_large_state),1);
                numberstoadd(indices)=1;
                TRX.(conditionname)(larva).(actionname)=numberstoadd;
            end
        end
    end
    
    
    filename=[adress 'dataFiles\trx_withbend.mat'];
     save(filename, 'TRX', '-v7.3');
    
    %% Extract the probability of actions over time
    
    probabilities=struct;
    for condition=1:nombredeconditions % scan the different conditions
        conditionname=titres(condition);
        for action=1:length(states) % for each action (or state)
            actionname=states(action);
            probabilities.(conditionname).(actionname)=probabilityOfActionFromTrx(TRX.(conditionname),actionname,[timewindows(1,1) tfin]);
        end
    end
    
    filename=[adress 'dataFiles\probabilitiesovertime.mat'];
    save(filename, 'probabilities'); % save probabilities of action over time
    
    
    %% Plot the probabilities over time
    
    % create new folder for the figures
    mkdir(adress, 'probabilitiesOverTime');
    
    for condition=1:nombredeconditions % for the different conditions
        conditionname=titres(condition);
        fig=figure;
        hold on
        actionsplotovertime=[1 2 3 4 5 6 7 9];
        for action=actionsplotovertime % for each action except backup sequence
            actionname=states(action);
            X=probabilities.(conditionname).(actionname)(:,1);
            Y=probabilities.(conditionname).(actionname)(:,2);
            plot(X,Y,'color',couleursactions(action,:),'linewidth',1);
        end
        title(conditionname);
        yl=ylim;
%         plot([60 60],yl);
%         plot([70 70],yl);
%         plot([80 80],yl);
%         plot([90 90],yl);
%         plot([100 100],yl);
%         plot([110 110],yl);
%         plot([120 120],yl);
%         plot([130 130],yl);
%         plot([140 140],yl);
%         plot([150 150],yl);
%         plot([160 160],yl);
%         plot([170 170],yl);
%         plot([180 180],yl);
%         plot([190 190],yl);
%         plot([200 200],yl);
%         plot([210 210],yl);
%         plot([220 220],yl);
%         plot([230 230],yl);
%         plot([240 240],yl);
        le=legend(regexprep(actionnames(actionsplotovertime),'_',''));
        xlabel('Time (s)');
        ylabel('Probability of action');
        set(gca,'box','off')
        
        filename=[adress 'probabilitiesOverTime\00uncorr_' char(conditionname) '_probabilitiesovertime.fig'];
        saveas(gcf,filename);
        filename=[adress 'probabilitiesOverTime\00uncorr_' char(conditionname) '_probabilitiesovertime.png'];
        saveas(gcf,filename);
    end
    
    %% Plot the probability of each action over time in all conditions
    
    mkdir(adress, 'probabilitiesOverTime');
    
    for action=1:length(states) % for each action (or state)
        actionname=states(action);
        fig=figure;
        hold on
        for condition=1:nombredeconditions % for the different conditions
            conditionname=titres(condition);
            X=probabilities.(conditionname).(actionname)(:,1);
            Y=probabilities.(conditionname).(actionname)(:,2);
            plot(X,Y,'color',couleursconditions(condition,:),'linewidth',1);
        end
        title(actionname);
        yl=ylim;
%         plot([60 60],yl);
%         plot([70 70],yl);
%         plot([80 80],yl);
%         plot([90 90],yl);
%         plot([100 100],yl);
%         plot([110 110],yl);
%         plot([120 120],yl);
%         plot([130 130],yl);
%         plot([140 140],yl);
%         plot([150 150],yl);
%         plot([160 160],yl);
%         plot([170 170],yl);
%         plot([180 180],yl);
%         plot([190 190],yl);
%         plot([200 200],yl);
%         plot([210 210],yl);
%         plot([220 220],yl);
%         plot([230 230],yl);
%         plot([240 240],yl);
        le=legend(regexprep(titres,'_',''));
        xlabel('Time (s)');
        ylabel('Probability of action');
        set(gca,'box','off')
        
        filename=[adress 'probabilitiesOverTime\00uncorr_' char(actionname) '_probabilitiesovertime.fig'];
        saveas(gcf,filename);
        filename=[adress 'probabilitiesOverTime\00uncorr_' char(actionname) '_probabilitiesovertime.png'];
        saveas(gcf,filename);
    end
    
    %% Extract the mean probabilities for the different time windows
    
    meanProbabilities=struct;
    for timewindow=1:numberofwindows
        windowname=['window' num2str(floor(timewindows(timewindow,1))) 's_' num2str(floor(timewindows(timewindow,2))) 's'];
        windowtouse=timewindows(timewindow,:);
        for condition=1:nombredeconditions
            conditionname=titres(condition);
            for action=1:length(states)
                actionname=states(action);
                indices=find(probabilities.(conditionname).(actionname)(:,1)>=timewindows(timewindow,1)&probabilities.(conditionname).(actionname)(:,1)<timewindows(timewindow,2));
                meanProbabilities.(windowname).(conditionname).(actionname).proba=nanmean(probabilities.(conditionname).(actionname)(indices,2));
                meanProbabilities.(windowname).(conditionname).(actionname).numberoflarvae=nanmean(probabilities.(conditionname).(actionname)(indices,3));
            end
        end
    end
    
    filename=[adress 'dataFiles\meanProbabilities.mat'];
    save(filename, 'meanProbabilities');
    
    %% Calculate p-values for differences in mean probabilities
    
    if nombredeconditions>1
        pMeanProbabilities=struct;
        for windowtoplot=1:numberofwindows
            windowname=['window' num2str(floor(timewindows(windowtoplot,1))) 's_' num2str(floor(timewindows(windowtoplot,2))) 's'];
            for action=1:length(states)
                actionname=states(action);
                for condition=1:nombredeconditions-1
                    conditionname=titres(condition);
                    for condition2=condition+1:nombredeconditions
                        conditionname2=titres(condition2);
                        % 1st condition
                        p1=meanProbabilities.(windowname).(conditionname).(actionname).proba;
                        N1=round(meanProbabilities.(windowname).(conditionname).(actionname).numberoflarvae); % nearest integer for number of larvae
                        nA1=p1*N1;
                        % 2nd condition
                        p2=meanProbabilities.(windowname).(conditionname2).(actionname).proba;
                        N2=round(meanProbabilities.(windowname).(conditionname2).(actionname).numberoflarvae); % nearest integer for number of larvae
                        n2=p2*N2;
                        % test probability
                        if p1~=NaN&&p2~=NaN&&N1~=NaN&&N2~=NaN
                            pMeanProbabilities.(windowname).(conditionname).(conditionname2).(actionname)=chi2FromData(p1,p2,N1,N2);
                        else
                            pMeanProbabilities.(windowname).(conditionname).(conditionname2).(actionname)=1;
                        end
                    end
                end
            end
        end
        save([adress 'dataFiles\pMeanProbabilities.mat'], 'pMeanProbabilities');
    end
    
    %% Plot mean proba for actions specified (actionstoplot) for each pair of condition, in each time window
    
    mkdir(adress, 'meanProbabilities');
        
    for timewindow=1:numberofwindows
        windowname=['window' num2str(floor(timewindows(timewindow,1))) 's_' num2str(floor(timewindows(timewindow,2))) 's'];
        
        for combination=1:size(conditionstoplot,1)
            combinationname=combinationconditionnames(combination);
            
            % Get matrix with p-values in order to add stars
            pvaltoadd=[];
            nconditions=size(conditionstoplot,2);
            if nconditions>1
                conditionname1=titres(1); % control to which the others will be compared
                for condition=conditionstoplot(combination,2:end)
                    conditionname=titres(condition);
                    pvaltoadd=[pvaltoadd cell2mat(struct2cell(pMeanProbabilities.(windowname).(conditionname1).(conditionname)))];
                end
            end
            stars1=(pvaltoadd<=0.05&pvaltoadd>0.01);
            stars2=(pvaltoadd<=0.01&pvaltoadd>0.001);
            stars3=(pvaltoadd<=0.001);
            
            % Get data
            xcat=categorical(regexprep(actionnames(actionstoplot),'_',''));
            xcat=reordercats(xcat,regexprep(actionnames(actionstoplot),'_',''));
            datatoplot=NaN(length(actionstoplot),nconditions);
            i=1;
            for action=actionstoplot
                actionname=states(action);
                j=1;
                for condition=conditionstoplot(combination,:)
                    conditionname=titres(condition);
                    datatoplot(i,j)=meanProbabilities.(windowname).(conditionname).(actionname).proba;
                    j=j+1;
                end
                i=i+1;
            end
            % Plot figure
            fig2=figure;
            hold on
            hBar = bar(datatoplot.*100, 0.8,'FaceColor','flat');
            % Get coordinates
            clear ctr ydt i
            couleursplots=couleursconditions(conditionstoplot(combination,:)',:);
            for k1 = 1:size(datatoplot,2)
                ctr(k1,:) = bsxfun(@plus, hBar(k1).XData, hBar(k1).XOffset');       % Note: ‘XOffset’ Is An Undocumented Feature, This Selects The ‘bar’ Centres
                ydt(k1,:) = hBar(k1).YData;                                         % Individual Bar Heighth
            end
            % Add stars for significant difference
            if nconditions>1
                i=1;
                for action=actionstoplot
                    j=1;
                    for condition=2:nconditions
                        starstoadd=0;
                        if stars1(action,condition-1)==1
                            starstoadd=1;
                        end
                        if stars2(action,condition-1)==1
                            starstoadd=2;
                        end
                        if stars3(action,condition-1)==1
                            starstoadd=3;
                        end
                        if starstoadd>0
                            texttoadd=repmat('*',1,starstoadd);
                            xfortext=ctr(j,i);
                            yfortext=datatoplot(i,condition).*100;
                            % reshape graph if data are out of borders
                            yl=ylim;
                            if yl(1,2)<yfortext
                                ylim([yl(1,1) (yfortext+(max(max(ydt))-min(min(ydt)))/10)]);
                            end
                            text(xfortext+(condition-1)*0.135, yfortext+(max(max(ydt))-min(min(ydt)))/10, texttoadd, 'horizontalAlignment', 'center','FontSize',24);
                        end
                        j=j+1;
                    end
                    i=i+1;
                end
            end
            for i=1:nconditions
                t=conditionstoplot(combination,i);
                hBar(i).FaceColor=couleursconditions(t,:);
            end
            set(gca,'box','off');
            xticks(1:length(xcat));
            xticklabels(char(xcat));
            h=gca;
            h.XRuler.TickLength = [0 0];
            xtickangle(45);
            
            yl=ylim;
            maxylim=yl(1,2)+yl(1,2)/10;
            maxylim=(floor(maxylim/10)+1)*10;
            ylim([0 maxylim]);
            le=legend(regexprep(titres(conditionstoplot(combination,:)),'_',''));
            set(le,'Location','best');
            title(regexprep(windowname,'_',''));
            ylabel('Probability (%)');
            set(gca,'fontsize',24);
            set(gcf, 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
            filename=[adress 'meanProbabilities\' windowname '_meanProba_barplot_interest' char(combinationname)];
            saveas(gcf,[filename '.fig']);
            saveas(gcf,[filename '.png']);
        end
    end
    
    %% Extract the cumulative probabilities for the different time windows
    
    cumulativeProbabilities=struct;
    for timewindow=1:numberofwindows
        windowname=['window' num2str(floor(timewindows(timewindow,1))) 's_' num2str(floor(timewindows(timewindow,2))) 's'];
        windowtouse=timewindows(timewindow,:);
        for condition=1:nombredeconditions
            conditionname=titres(condition);
            for action=1:length(states)
                actionname=states(action);
                [cumulativeProbabilities.(windowname).(conditionname).(actionname).proba, cumulativeProbabilities.(windowname).(conditionname).(actionname).probacontrol, cumulativeProbabilities.(windowname).(conditionname).(actionname).numberoflarvae, cumulativeProbabilities.(windowname).(conditionname).(actionname).numberoflarvaecontrol]=cumulativeFromTrx(TRX.(conditionname),windowtouse,action);
            end
        end
    end
    
    filename=[adress 'dataFiles\cumulativeProbabilities.mat'];
    save(filename, 'cumulativeProbabilities');
    
    %% Calculate p-values for differences in cumulative probabilities
    
    if nombredeconditions>1
        pProbabilitiesCumulative=struct;
        for windowtoplot=1:numberofwindows
            windowname=['window' num2str(floor(timewindows(windowtoplot,1))) 's_' num2str(floor(timewindows(windowtoplot,2))) 's'];
            for action=1:length(states)
                actionname=states(action);
                for condition=1:nombredeconditions-1
                    conditionname=titres(condition);
                    for condition2=condition+1:nombredeconditions
                        conditionname2=titres(condition2);
                        % 1st condition
                        p1=cumulativeProbabilities.(windowname).(conditionname).(actionname).proba;
                        N1=round(cumulativeProbabilities.(windowname).(conditionname).(actionname).numberoflarvae); % nearest integer for number of larvae
                        nA1=p1*N1;
                        % 2nd condition
                        p2=cumulativeProbabilities.(windowname).(conditionname2).(actionname).proba;
                        N2=round(cumulativeProbabilities.(windowname).(conditionname2).(actionname).numberoflarvae); % nearest integer for number of larvae
                        n2=p2*N2;
                        % test probability
                        pProbabilitiesCumulative.(windowname).(conditionname).(conditionname2).(actionname)=chi2FromData(p1,p2,N1,N2);
                    end
                end
            end
        end
        save([adress 'dataFiles\pProbabilitiesCumulative.mat'], 'pProbabilitiesCumulative');
    end
    
    %% Plot cumulative proba for actions specified (actionstoplot) for each pair of condition
    
    mkdir(adress, 'cumulativeProbabilities');
    
    for timewindow=1:numberofwindows
        windowname=['window' num2str(floor(timewindows(timewindow,1))) 's_' num2str(floor(timewindows(timewindow,2))) 's'];
        
        for combination=1:size(conditionstoplot,1)
            combinationname=combinationconditionnames(combination);
            
            % Get matrix with p-values in order to add stars
            pvaltoadd=[];
            nconditions=size(conditionstoplot,2);
            if nconditions>1
                conditionname1=titres(1); % control to which the others will be compared
                for condition=conditionstoplot(combination,2:end)
                    conditionname=titres(condition);
                    pvaltoadd=[pvaltoadd cell2mat(struct2cell(pProbabilitiesCumulative.(windowname).(conditionname1).(conditionname)))];
                end
            end
            stars1=(pvaltoadd<=0.05&pvaltoadd>0.01);
            stars2=(pvaltoadd<=0.01&pvaltoadd>0.001);
            stars3=(pvaltoadd<=0.001);
            
            % Get data
            xcat=categorical(regexprep(actionnames(actionstoplot),'_',''));
            xcat=reordercats(xcat,regexprep(actionnames(actionstoplot),'_',''));
            datatoplot=NaN(length(actionstoplot),nconditions);
            i=1;
            for action=actionstoplot
                actionname=states(action);
                j=1;
                for condition=conditionstoplot(combination,:)
                    conditionname=titres(condition);
                    datatoplot(i,j)=cumulativeProbabilities.(windowname).(conditionname).(actionname).proba;
                    j=j+1;
                end
                i=i+1;
            end
            % Plot figure
            fig2=figure;
            hold on
            hBar = bar(datatoplot.*100, 0.8,'FaceColor','flat');
            % Get coordinates
            clear ctr ydt i
            couleursplots=couleursconditions(conditionstoplot(combination,:)',:);
            for k1 = 1:size(datatoplot,2)
                ctr(k1,:) = bsxfun(@plus, hBar(k1).XData, hBar(k1).XOffset');       % Note: ‘XOffset’ Is An Undocumented Feature, This Selects The ‘bar’ Centres
                ydt(k1,:) = hBar(k1).YData;                                         % Individual Bar Heighth
            end
            % Add stars for significant difference
            if nconditions>1
                i=1;
                for action=actionstoplot
                    j=1;
                    for condition=2:nconditions
                        starstoadd=0;
                        if stars1(action,condition-1)==1
                            starstoadd=1;
                        end
                        if stars2(action,condition-1)==1
                            starstoadd=2;
                        end
                        if stars3(action,condition-1)==1
                            starstoadd=3;
                        end
                        if starstoadd>0
                            texttoadd=repmat('*',1,starstoadd);
                            xfortext=ctr(j,i);
                            yfortext=datatoplot(i,condition).*100;
                            % reshape graph if data are out of borders
                            yl=ylim;
                            if yl(1,2)<yfortext
                                ylim([yl(1,1) (yfortext+(max(max(ydt))-min(min(ydt)))/10)]);
                            end
                            text(xfortext+(condition-1)*0.135, yfortext+(max(max(ydt))-min(min(ydt)))/10, texttoadd, 'horizontalAlignment', 'center','FontSize',24);
                        end
                        j=j+1;
                    end
                    i=i+1;
                end
            end
            for i=1:nconditions
                t=conditionstoplot(combination,i);
                hBar(i).FaceColor=couleursconditions(t,:);
            end
            set(gca,'box','off');
            xticks(1:length(xcat));
            xticklabels(char(xcat));
            h=gca;
            h.XRuler.TickLength = [0 0];
            xtickangle(45);
            
            yl=ylim;
            maxylim=yl(1,2)+yl(1,2)/10;
            maxylim=(floor(maxylim/10)+1)*10;
            ylim([0 maxylim]);
            le=legend(regexprep(titres(conditionstoplot(combination,:)),'_',''));
            title(regexprep(windowname,'_',''));
            set(le,'Location','best');
            ylabel('Cumulative probability (%)');
            set(gca,'fontsize',24) ;
            set(gcf, 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
            filename=[adress 'cumulativeProbabilities\' windowname '_cumulativeProba_barplot_interest' char(combinationname)];
            saveas(gcf,[filename '.fig']);
            saveas(gcf,[filename '.png']);
        end
    end
    
    %% Extraction probability of transition from one action to another
    
    allTransitions=struct;
    for timewindow=1:numberofwindows
        timestransitions=timewindows(timewindow,:);
        timestransitions(1,1)=timestransitions(1,1)-0.5; % extend time window in order to include BEFORE air puff
        windowname=['window' num2str(floor(timestransitions(1,1))) 's_' num2str(floor(timestransitions(1,2))) 's'];
        for condition=1:nombredeconditions
            conditionname=titres(condition);
            [allTransitions.notNormalized.(windowname).(conditionname), allTransitions.normalized.(windowname).(conditionname)]=transitionFromTrx(TRX.(conditionname), timestransitions);
        end
        allTransitionsForPlot=allTransitions;
    end
    
    for timewindow=1:numberofwindows
        timestransitions=timewindows(timewindow,:);
        timestransitions(1,1)=timestransitions(1,1)-0.5; % extend time window in order to include BEFORE air puff
        windowname=['window' num2str(floor(timestransitions(1,1))) 's_' num2str(floor(timestransitions(1,2))) 's'];
        for condition=1:nombredeconditions
            conditionname=titres(condition);
            categories=["notNormalized";"normalized"];
            for i=1:length(categories)
                namecat=categories(i);
                allTransitions.(namecat).(windowname).(conditionname)=array2table(allTransitions.(namecat).(windowname).(conditionname));
                for j=1:length(actionnames)
                    variablename=['Var' num2str(j)];
                    allTransitions.(namecat).(windowname).(conditionname).Properties.VariableNames{variablename} = char(actionnames(j));
                end
            end
        end
    end
    
    filename=[adress 'dataFiles\allTransitions.mat'];
    save(filename, 'allTransitions');
    
    %% Plot transition matrix as heatmap
    
    mkdir(adress, 'transitions');
    
    colormap hot;
    for timewindow=1:numberofwindows
        timestransitions=timewindows(timewindow,:);
        timestransitions(1,1)=timestransitions(1,1)-0.5; % extend time window in order to include BEFORE air puff
        windowname=['window' num2str(floor(timestransitions(1,1))) 's_' num2str(floor(timestransitions(1,2))) 's'];
        for condition=1:nombredeconditions
            conditionname=titres(condition);
            
            categories=["notNormalized";"normalized"];
            for i=1:length(categories)
                namecat=categories(i);
                datatoplot=round(allTransitionsForPlot.(namecat).(windowname).(conditionname),2);
                xcat=categorical(actionnames);
                h=figure;
                h=heatmap(xcat,xcat,datatoplot);
                if i==2
                    caxis([0 1]);
                end
                colormap hot;
                title([windowname ', ' regexprep(char(conditionname),'_','')]);
                filename=[adress 'transitions\' windowname '_' regexprep(char(conditionname),'_','') '_' char(namecat)];
                saveas(gcf,[filename '.fig']);
                saveas(gcf,[filename '.png']);
            end
        end
    end
    
end



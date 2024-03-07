%% This scripts extracts the probability, cumulative probability of actions,
% and transitions between actions
% of all larvae from the trx.mat file, during the different time windows

% Statistical test used for comparing cumulative proba (non corrected) :
% Chi2 test

% CHANGE : adresses, timewindows, couleursconditions, conditionstoplot,
% actionstoplot, couleursactions

clear all

adresses=[
'/Volumes/TOSHIBA/t2/FCF_attP2@UAS_Abeta40_116/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/'
'/Volumes/TOSHIBA/t2/FCF_attP2@UAS_Abeta42_117/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/'
'/Volumes/TOSHIBA/t2/GMR_61D08@UAS_Abeta40_116/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/'
'/Volumes/TOSHIBA/t2/GMR_61D08@UAS_Abeta42_117/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/'
'/Volumes/TOSHIBA/t2/GMR_20B01@UAS_Abeta40_116/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/'
'/Volumes/TOSHIBA/t2/GMR_20B01@UAS_Abeta42_117/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/'
    ];

for exp=1:length(adresses)
    
    clearvars -except adresses exp
    %% Define the parameters
    
    % !! Important: put all files in a "data" folder (with the "data" name
    % only) contained in the main folder specified by 'adress' below
    adress=char(adresses(exp,:));
    timewindows=[
        15 29 % ! time windows must not last for more than 59s
        45 47
        45 60
        60 61
        60 62
        45 75 % recovery
        ];
    tfin=250; % change if you have a different duration of experiment
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
    
    if exp>=1
        couleursconditions=[0.00,0.45,0.74 ... % colors that will be used for each genotype/condition, add some if more genotypes/conditions
        ; 0.85,0.33,0.10 ...
        ; 0.93,0.69,0.13
        ; 0.2 0.5 0.3];
    else
        couleursconditions=[0.00,0.45,0.74 ... % colors that will be used for each genotype/condition, add some if more genotypes/conditions
        ; 0.85,0.33,0.10 ...
        ; 0.93,0.69,0.13
        ; 0.2 0.5 0.3];
    end
    
    
    %% Concatenate trx for all experiments in each genotype
    
    TRX =concatenateTrx(adress);
    
    mkdir(adress, 'dataFiles');
    filename=[adress 'dataFiles/trx_concatenated.mat'];
    save(filename, 'TRX'); % save concatenated trx file
    
%     %% Reformat to include bend vs head cast
%     
%     actionLarva=struct;
%     for condition=1:nombredeconditions
%         conditionname=titres(condition);
%         actionLarva.(conditionname)=headVSbendFromTrx(TRX.(conditionname));
%     end
%     
%     % Add new fields with actions that take into account head cast vs bend
%     
%     for condition=1:nombredeconditions
%         conditionname=titres(condition);
%         for larva=1:length(TRX.(conditionname))
%             larvaname=['larva' num2str(larva)];
%             TRX.(conditionname)(larva).global_state_large_state=actionLarva.(conditionname).(larvaname).action;
%         end
%     end
    
    %% Add new fields with actions over time for each action
    % write 1 if the action is performed, 0 if not
    
        for larva=1:length(TRX)
            larvaname=['larva' num2str(larva)];
            for action=1:length(states)
                actionname=states(action);
                indices=find(TRX(larva).global_state_large_state==action);
                numberstoadd=zeros(length(TRX(larva).global_state_large_state),1);
                numberstoadd(indices)=1;
                TRX(larva).(actionname)=numberstoadd;
            end
        end
    
    filename=[adress 'dataFiles/trx_withbend.mat'];
    save(filename, 'TRX', '-v7.3');
    
    %% Extract the probability of actions over time
    probabilities=struct;
  
        for action=1:length(states) % for each action (or state)
            actionname=states(action);
            probabilities.(actionname)=probabilityOfActionFromTrx(TRX,actionname,[timewindows(1,1) tfin]);
        end
    
    filename=[adress 'dataFiles/probabilitiesovertime.mat'];
    save(filename, 'probabilities'); % save probabilities of action over time
    
    
    %% Plot the probabilities over time
    
    % create new folder for the figures
    mkdir(adress, 'probabilitiesOverTime');
    
   
        fig=figure;
        hold on
        actionsplotovertime=[1 2 3 4 5 6 7 9];
        for action=actionsplotovertime % for each action except backup sequence
            actionname=states(action);
            X=probabilities.(actionname)(:,1);
            Y=probabilities.(actionname)(:,2);
            plot(X,Y,'color',couleursactions(action,:),'linewidth',2);
        end
        yl=ylim;
        le=legend(regexprep(actionnames(actionsplotovertime),'_',''));
        xlabel('Time (s)');
        ylabel('Probability of action');
        set(gca,'box','off')
        
        filename=[adress 'probabilitiesOverTime/00uncorr_probabilitiesovertime.fig'];
        saveas(gcf,filename);
        filename=[adress 'probabilitiesOverTime/00uncorr_probabilitiesovertime'];
        saveas(gcf,filename,'epsc')
end

%% Extract the mean probabilities for the different time windows
    
    meanProbabilities=struct;
    for timewindow=1:numberofwindows
        num1=regexprep(num2str(timewindows(timewindow,1)),'\.','p');
        num2=regexprep(num2str(timewindows(timewindow,2)),'\.','p');
        windowname=['window' num1 's_' num2 's'];
        windowtouse=timewindows(timewindow,:);
        for condition=1:nombredeconditions
            conditionname=titres(condition);
            for action=1:length(states)
                actionname=states(action);
                indices=find(probabilities.(conditionname).(actionname)(:,1)>=timewindows(timewindow,1)&probabilities.(conditionname).(actionname)(:,1)<timewindows(timewindow,2));
                meanProbabilities.(windowname).(conditionname).(actionname).proba=nanmean(probabilities.(conditionname).(actionname)(indices,2));
                meanProbabilities.(windowname).(conditionname).(actionname).numberoflarvae=nanmean(probabilities.(conditionname).(actionname)(indices,3));
            end
            meanProbabilities.(windowname).(conditionname).staticActions.proba=meanProbabilities.(windowname).(conditionname).stop.proba+meanProbabilities.(windowname).(conditionname).hunch.proba+meanProbabilities.(windowname).(conditionname).bend_static.proba;
            meanProbabilities.(windowname).(conditionname).staticActions.numberoflarvae=meanProbabilities.(windowname).(conditionname).stop.numberoflarvae;
            meanProbabilities.(windowname).(conditionname).dynamicActions.proba=meanProbabilities.(windowname).(conditionname).run.proba+meanProbabilities.(windowname).(conditionname).cast.proba;
            meanProbabilities.(windowname).(conditionname).dynamicActions.numberoflarvae=meanProbabilities.(windowname).(conditionname).run.numberoflarvae;
        end
    end
    
    filename=[adress 'dataFiles\meanProbabilities.mat'];
    save(filename, 'meanProbabilities');
    
    %% Calculate p-values for differences in mean probabilities for actions
    
    if nombredeconditions>1
        pMeanProbabilities=struct;
        for windowtoplot=1:numberofwindows
            num1=regexprep(num2str(timewindows(windowtoplot,1)),'\.','p');
            num2=regexprep(num2str(timewindows(windowtoplot,2)),'\.','p');
            windowname=['window' num1 's_' num2 's'];
            for action=1:length(states)
                actionname=string(states(action));
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
                        if ~isnan(p1)&&~isnan(p2)&&~isnan(N1)&&~isnan(N2)
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
    
    %% Calculate p-values for differences in mean probabilities for static or dynamic actions
    
    dynamicstatic=["dynamicActions";"staticActions"];
    
    if nombredeconditions>1
        pMeanProbabilitiesDynamicStatic=struct;
        for windowtoplot=1:numberofwindows
            num1=regexprep(num2str(timewindows(windowtoplot,1)),'\.','p');
            num2=regexprep(num2str(timewindows(windowtoplot,2)),'\.','p');
            windowname=['window' num1 's_' num2 's'];
            for action=1:length(dynamicstatic)
                actionname=string(dynamicstatic(action));
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
                        if ~isnan(p1)&&~isnan(p2)&&~isnan(N1)&&~isnan(N2)
                            pMeanProbabilitiesDynamicStatic.(windowname).(conditionname).(conditionname2).(actionname)=chi2FromData(p1,p2,N1,N2);
                        else
                            pMeanProbabilitiesDynamicStatic.(windowname).(conditionname).(conditionname2).(actionname)=1;
                        end
                    end
                end
            end
        end
        save([adress 'dataFiles\pMeanProbabilitiesDynamicStatic.mat'], 'pMeanProbabilitiesDynamicStatic');
    end
    
    %% Plot in two rounds for all actions OR only specific actions
    
    for premierround=[1 2]
        
        
        if premierround==1
            % actions to plot separately
            actionstoplot=[1 2 3 4 5 6 9];
        else
            % actions to plot separately
            actionstoplot=[2 4];
        end
        
        %% Plot mean proba for actions specified (actionstoplot) for each pair of condition, in each time window
        
        mkdir(adress, 'meanProbabilities');
        
        for timewindow=1:numberofwindows
            num1=regexprep(num2str(timewindows(timewindow,1)),'\.','p');
            num2=regexprep(num2str(timewindows(timewindow,2)),'\.','p');
            windowname=['window' num1 's_' num2 's'];
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
                xcat=reordercats(xcat);
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
                maxylim=max([100 maxylim]);
                ylim([0 maxylim]);
                le=legend(regexprep(titres(conditionstoplot(combination,:)),'_',''));
                set(le,'Location','best');
                title(regexprep(windowname,'_',''));
                ylabel('Probability (%)');
                set(gca,'fontsize',24);
                set(gcf, 'Units', 'normalized', 'OuterPosition', [0 0 1 1]);
                if premierround==1
                    filename=[adress 'meanProbabilities\' windowname '_meanProba_barplot_interest' char(combinationname)];
                    saveas(gcf,[filename '.fig']);
                    saveas(gcf,[filename '.png']);
                else
                    filename=[adress 'meanProbabilities\hunchcast_' windowname '_meanProba_barplot_interest' char(combinationname)];
                    saveas(gcf,[filename '.fig']);
                    saveas(gcf,[filename '.png']);
                end
                
            end
        end
        
        %% Plot mean proba for static VS dynamic actions for each pair of condition, in each time window
        
        mkdir(adress, 'meanProbabilitiesDynamicStatic');
        dynamicstatic=["dynamicActions";"staticActions"];
        
        for timewindow=1:numberofwindows
            num1=regexprep(num2str(timewindows(timewindow,1)),'\.','p');
            num2=regexprep(num2str(timewindows(timewindow,2)),'\.','p');
            windowname=['window' num1 's_' num2 's'];
            for combination=1:size(conditionstoplot,1)
                combinationname=combinationconditionnames(combination);
                
                % Get matrix with p-values in order to add stars
                pvaltoadd=[];
                nconditions=size(conditionstoplot,2);
                if nconditions>1
                    conditionname1=titres(1); % control to which the others will be compared
                    for condition=conditionstoplot(combination,2:end)
                        conditionname=titres(condition);
                        pvaltoadd=[pvaltoadd cell2mat(struct2cell(pMeanProbabilitiesDynamicStatic.(windowname).(conditionname1).(conditionname)))];
                    end
                end
                stars1=(pvaltoadd<=0.05&pvaltoadd>0.01);
                stars2=(pvaltoadd<=0.01&pvaltoadd>0.001);
                stars3=(pvaltoadd<=0.001);
                
                % Get data
                xcat=categorical(regexprep(dynamicstatic,'_',''));
                xcat=reordercats(xcat);
                datatoplot=NaN(length(dynamicstatic),nconditions);
                i=1;
                for action=[1 2]
                    actionname=dynamicstatic(action);
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
                    for action=[1 2]
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
                maxylim=max([100 maxylim]);
                ylim([0 maxylim]);
                le=legend(regexprep(titres(conditionstoplot(combination,:)),'_',''));
                set(le,'Location','best');
                title(regexprep(windowname,'_',''));
                ylabel('Probability (%)');
                set(gca,'fontsize',24);
                set(gcf, 'Units', 'normalized', 'OuterPosition', [0 0 1 1]);
            end
        end
        
        
        
        
        %% Extract the cumulative probabilities for the different time windows
        
        cumulativeProbabilities=struct;
        for timewindow=1:numberofwindows
            num1=regexprep(num2str(timewindows(timewindow,1)),'\.','p');
            num2=regexprep(num2str(timewindows(timewindow,2)),'\.','p');
            windowname=['window' num1 's_' num2 's'];
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
                num1=regexprep(num2str(timewindows(windowtoplot,1)),'\.','p');
                num2=regexprep(num2str(timewindows(windowtoplot,2)),'\.','p');
                windowname=['window' num1 's_' num2 's'];
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
            num1=regexprep(num2str(timewindows(timewindow,1)),'\.','p');
            num2=regexprep(num2str(timewindows(timewindow,2)),'\.','p');
            windowname=['window' num1 's_' num2 's'];
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
                xcat=reordercats(xcat);
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
                maxylim=max([maxylim 100]);
                ylim([0 maxylim]);
                le=legend(regexprep(titres(conditionstoplot(combination,:)),'_',''));
                title(regexprep(windowname,'_',''));
                set(le,'Location','best');
                ylabel('Cumulative probability (%)');
                set(gca,'fontsize',24) ;
                set(gcf, 'Units', 'normalized', 'OuterPosition', [0 0 1 1]);
                
                if premierround==1
                    filename=[adress 'cumulativeProbabilities\' windowname '_cumulativeProba_barplot_interest' char(combinationname)];
                    saveas(gcf,[filename '.fig']);
                    saveas(gcf,[filename '.png']);
                else
                    filename=[adress 'cumulativeProbabilities\hunchcast_' windowname '_cumulativeProba_barplot_interest' char(combinationname)];
                    saveas(gcf,[filename '.fig']);
                    saveas(gcf,[filename '.png']);
                end
                
            end
        end
        
    end
    
    %% Extraction probability of transition from one action to another
    
    allTransitions=struct;
    for timewindow=1:numberofwindows
        timestransitions=timewindows(timewindow,:);
        timestransitions(1,1)=timestransitions(1,1)-0.5; % extend time window in order to include BEFORE air puff
        num1=regexprep(num2str(timestransitions(1,1)),'\.','p');
        num2=regexprep(num2str(timestransitions(1,2)),'\.','p');
        windowname=['window' num1 's_' num2 's'];
        for condition=1:nombredeconditions
            conditionname=titres(condition);
            [allTransitions.notNormalized.(windowname).(conditionname), allTransitions.normalized.(windowname).(conditionname), meanNumberofTransitions.(windowname).(conditionname), nb_active.(windowname).(conditionname), nb_larvae_that_transition.(windowname).(conditionname), nb_transition_perlarvae.(windowname).(conditionname), first_transition.(windowname).(conditionname)]=transitionFromTrx(TRX.(conditionname), timestransitions);
        end
        allTransitionsForPlot=allTransitions;
    end
    
    for timewindow=1:numberofwindows
        timestransitions=timewindows(timewindow,:);
        timestransitions(1,1)=timestransitions(1,1)-0.5; % extend time window in order to include BEFORE air puff
        num1=regexprep(num2str(timestransitions(1,1)),'\.','p');
        num2=regexprep(num2str(timestransitions(1,2)),'\.','p');
        windowname=['window' num1 's_' num2 's'];
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
        num1=regexprep(num2str(timestransitions(1,1)),'\.','p');
        num2=regexprep(num2str(timestransitions(1,2)),'\.','p');
        windowname=['window' num1 's_' num2 's'];
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
    
    %% Plot the table of the first transition of larvae
    
    mkdir(adress, 'first_transition');
    
    for timewindow=1:numberofwindows
        timestransitions=timewindows(timewindow,:);
        timestransitions(1,1)=timestransitions(1,1)-0.5; % extend time window in order to include BEFORE air puff
        num1=regexprep(num2str(timestransitions(1,1)),'\.','p');
        num2=regexprep(num2str(timestransitions(1,2)),'\.','p');
        windowname=['window' num1 's_' num2 's'];
        
        % calculate and plot transition matrix
        for condition=1:nombredeconditions
            conditionname=titres(condition);
            % calculate transitions
            transitions=NaN(length(states),length(states)); % lines: action at begining; columns: action after transition
            numbertransitionsfromi=NaN(length(states),1);
            numbertransitionstoj=NaN(1,length(states));
            for i=1:length(states)
                transitionsfromi=find(first_transition.(windowname).(conditionname)(:,1)==i);
                numbertransitionsfromi(i,1)=length(transitionsfromi);
                for j=1:length(states)
                    transitiontoj=find(first_transition.(windowname).(conditionname)(transitionsfromi,2)==j);
                    numbertransitionstoj(1,j)=length(transitiontoj);
                end
                transitions(i,:)=numbertransitionstoj/numbertransitionsfromi(i,1);
            end
            
            % Plot transition matrix
            xcat=categorical(actionnames);
            h=figure;
            datatoplot=round(transitions,3);
            datatoplot(datatoplot==0)=NaN;
            h=heatmap(xcat,xcat,datatoplot);
            colormap hot;
            caxis([0, 1]);
            title([windowname ', ' regexprep(char(conditionname),'_','')]);
            filename=[adress 'first_transition\' windowname '_' regexprep(char(conditionname),'_','')];
            saveas(gcf,[filename '.fig']);
            saveas(gcf,[filename '.png']);
        end
    end
    
    %% Plot the mean number of transitions per larva
    
    mkdir(adress, 'meanNumberofTransitions');
    
    for timewindow=1:numberofwindows
        timestransitions=timewindows(timewindow,:);
        timestransitions(1,1)=timestransitions(1,1)-0.5; % extend time window in order to include BEFORE air puff
        num1=regexprep(num2str(timestransitions(1,1)),'\.','p');
        num2=regexprep(num2str(timestransitions(1,2)),'\.','p');
        windowname=['window' num1 's_' num2 's'];
        Y=NaN(nombredeconditions,1);
        Ysem=NaN(nombredeconditions,1);
        for condition=1:nombredeconditions
            conditionname=titres(condition);
            Y(condition,1)=nanmean(nb_transition_perlarvae.(windowname).(conditionname));
            Ysem(condition,1)=nanstd(nb_transition_perlarvae.(windowname).(conditionname))/sqrt(nb_active.(windowname).(conditionname));
        end
        xcat=categorical(titres);
        figure
        fig2=bar(xcat,Y);
        hold on
        er = errorbar(xcat,Y,Ysem,Ysem);
        er.Color = [0 0 0];
        er.LineStyle = 'none';
        fig2.FaceColor = 'flat';
        for condition=1:length(titres)
            fig2.CData(condition,:) = couleursconditions(condition,:);
        end
        ylabel('Mean number of transition per larvae');
        title(['Mean number of transition per larvae from ' num1 ' s to ' num2 's']);
        %         set(gca,'FontSize',18)
        filename=[adress 'meanNumberofTransitions\' windowname '_meanNumberofTransitions'];
        saveas(gcf,[filename '.fig']);
        saveas(gcf,[filename '.png']);
    end
    
    %% Compare mean number of transitions for significant differences
    
    for timewindow=1:numberofwindows
        timestransitions=timewindows(timewindow,:);
        timestransitions(1,1)=timestransitions(1,1)-0.5; % extend time window in order to include BEFORE air puff
        num1=regexprep(num2str(timestransitions(1,1)),'\.','p');
        num2=regexprep(num2str(timestransitions(1,2)),'\.','p');
        windowname=['window' num1 's_' num2 's'];
        
        % Generate variables that will store the results of the test
        pval_meanNumberofTransitions.(windowname)=NaN(1,1);
        pairwise_meanNumberofTransitions.(windowname)=NaN(nombredeconditions,1);
        
        % Generate table containing data
        dataToCompare=[];
        groups=[];
        for condition=1:nombredeconditions
            conditionname=titres(condition);
            dataToCompare=[dataToCompare; nb_transition_perlarvae.(windowname).(conditionname)];
            groupToAdd=repmat(conditionname,length(nb_transition_perlarvae.(windowname).(conditionname)),1);
            groups=[groups; groupToAdd];
        end
        groups=categorical(groups);
        % Do ANOVA
        [pval_meanNumberofTransitions.(windowname),tbl,statstruct]=anova1(dataToCompare,groups,'off');
        pairwise_comp=multcompare(statstruct,'CType','bonferroni','Display', 'off');
        pairwise_meanNumberofTransitions.(windowname)=cell(nombredeconditions+1,nombredeconditions+1);
        pairwise_meanNumberofTransitions.(windowname){1,1}="Conditions";
        i=1;
        for condition=1:nombredeconditions-1
            pairwise_meanNumberofTransitions.(windowname){condition+1,condition+1}=NaN;
            if i<=nombredeconditions
                conditionname=titres(condition);
                pairwise_meanNumberofTransitions.(windowname){1,condition+1}=conditionname;
                pairwise_meanNumberofTransitions.(windowname){condition+1,1}=conditionname;
                for condition2=condition+1:nombredeconditions
                    pairwise_meanNumberofTransitions.(windowname){condition2+1,condition2+1}=NaN;
                    conditionname2=titres(condition2);
                    pairwise_meanNumberofTransitions.(windowname){condition2+1,1}=conditionname2;
                    pairwise_meanNumberofTransitions.(windowname){1,condition2+1}=conditionname2;
                    pairwise_meanNumberofTransitions.(windowname){condition+1,condition2+1}=pairwise_comp(i,6);
                    pairwise_meanNumberofTransitions.(windowname){condition2+1,condition+1}=pairwise_comp(i,6);
                    i=i+1;
                end
            end
        end
        filename=[adress 'dataFiles\pval_meanNumberofTransitions.mat']; % store p-values for ANOVA of amplitudes
        save(filename, 'pval_meanNumberofTransitions'); % one line is a time window, one column is an action
        filename=[adress 'dataFiles\pairwise_meanNumberofTransitions.mat'];
        save(filename, 'pairwise_meanNumberofTransitions'); % look at last column for p values
    end
    
    %% Plot the percentage of larvae that transition during each time window (approximate of 'response')
    
    mkdir(adress, 'percentageTransitions');
    
    for timewindow=1:numberofwindows
        timestransitions=timewindows(timewindow,:);
        timestransitions(1,1)=timestransitions(1,1)-0.5; % extend time window in order to include BEFORE air puff
        num1=regexprep(num2str(timestransitions(1,1)),'\.','p');
        num2=regexprep(num2str(timestransitions(1,2)),'\.','p');
        windowname=['window' num1 's_' num2 's'];
        Y=NaN(nombredeconditions,1);
        Ysem=NaN(nombredeconditions,1);
        for condition=1:nombredeconditions
            conditionname=titres(condition);
            Y(condition,1)=nb_larvae_that_transition.(windowname).(conditionname)/nb_active.(windowname).(conditionname);
        end
        xcat=categorical(titres);
        figure
        fig2=bar(xcat,Y);
        fig2.FaceColor = 'flat';
        for condition=1:length(titres)
            fig2.CData(condition,:) = couleursconditions(condition,:);
        end
        ylabel('Percentage of larvae transitioning (%)');
        title(['Percentage of larvae transitioning from ' num1 ' s to ' num2 's']);
        %         set(gca,'FontSize',18)
        filename=[adress 'percentageTransitions\' windowname '_percentageTransitions'];
        saveas(gcf,[filename '.fig']);
        saveas(gcf,[filename '.png']);
    end
    
    
    %% Plot the number of active larva for each time window
    
    mkdir(adress, 'numberOfLarvae');
    
    for timewindow=1:numberofwindows
        timestransitions=timewindows(timewindow,:);
        timestransitions(1,1)=timestransitions(1,1)-0.5; % extend time window in order to include BEFORE air puff
        num1=regexprep(num2str(timestransitions(1,1)),'\.','p');
        num2=regexprep(num2str(timestransitions(1,2)),'\.','p');
        windowname=['window' num1 's_' num2 's'];
        Y=NaN(nombredeconditions,1);
        Ysem=NaN(nombredeconditions,1);
        for condition=1:nombredeconditions
            conditionname=titres(condition);
            Y(condition,1)=nb_active.(windowname).(conditionname);
        end
        xcat=categorical(titres);
        figure
        fig2=bar(xcat,Y);
        fig2.FaceColor = 'flat';
        for condition=1:length(titres)
            fig2.CData(condition,:) = couleursconditions(condition,:);
        end
        ylabel('Number of larvae tracked');
        title(['Cumulative number of larvae tracked from ' num1 ' s to ' num2 's']);
        %         set(gca,'FontSize',18)
        filename=[adress 'numberOfLarvae\' windowname '_numberOfLarvae'];
        saveas(gcf,[filename '.fig']);
        saveas(gcf,[filename '.png']);
    end
    
    close all
end



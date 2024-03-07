%% This scripts extracts the action and amplitude of actions of all larvae from the trx.mat file, during the different time windows
clear all

%% Set times of interest

times_to_consider=[
    5 30;
    5 60
    ];


%% Put all addresses of data

adresses=[
    "C:\Users\edetredern\Documents\Experiences\Comportement\20201007_locomotion\CantonS@CantonS\"
    "C:\Users\edetredern\Documents\Experiences\Comportement\20201007_locomotion\FCF_attP2@UAS_TNT_2_0003\"
    "C:\Users\edetredern\Documents\Experiences\Comportement\20201007_locomotion\FCF_attP2-40@UAS_TNT_2_0003\"
    ];

for exp=1:length(adresses)
    %% Define the parameters
    % Create a main folder specified by 'adress', that contains ONLY one folder named 'data'. In this folder 'data', create one subfolder for each condition (the folder name must starte with a letter, and must not contain weird characters or spaces). In each subfolder, paste the folders containing your data for one experiment and the trx.mat file associated (only the trx.mat file is needed).
    
    % !! Important: put all files in a "data" folder (with the "data" name
    % only) contained in the main folder specified by 'adress' below
    adress=char(adresses(exp));
    t_step=0.1; % time step in s
    
    couleurs=[
        0    0.4470    0.7410
        0.8500    0.3250    0.0980
        0.9290    0.6940    0.1250
        0.4940    0.1840    0.5560
        0.4660    0.6740    0.1880
        0.3010    0.7450    0.9330
        0.6350    0.0780    0.1840
        0.3010    0.7450    0.9330
        0.2422    0.1504    0.6603
        0.2504    0.1650    0.7076
        0.2578    0.1818    0.7511
        0.2647    0.1978    0.7952
        0.2706    0.2147    0.8364
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
    
    mkdir(adress, 'dataFiles');
    filename=[adress 'dataFiles\trx_concatenated.mat'];
    % save(filename, 'TRX'); % save concatenated trx file
    
    %% Save names of all experimental folders used to analyze data
    experimental_folders=[];
    for condition=1:nombredeconditions
        conditionname=titres(condition);
        experimental_folders=[experimental_folders; unique({TRX.(conditionname).id}.')];
    end
    experimental_folders=table(experimental_folders);
    filename=[adress 'dataFiles\experimental_folders.txt'];
    writetable(experimental_folders, filename);
    
    %% Keep only relevant larvae and add names
    
    for condition=1:nombredeconditions
        conditionname=titres(condition);
        indices=NaN(length(TRX.(conditionname)),1);
        for i=1:length(TRX.(conditionname))
            time_duration_tracking=max(TRX.(conditionname)(i).t)-min(TRX.(conditionname)(i).t);
            if time_duration_tracking>20 % if the larva is tracked during more than 20 s
                indices(i,1)=1;
            else
                indices(i,1)=0;
            end
        end
        indices=logical(indices);
        TRX.(conditionname)=TRX.(conditionname)(indices);
        
        for i=1:length(TRX.(conditionname))
            id=TRX.(conditionname)(i).numero_larva_num;
            size_time=length(TRX.(conditionname)(i).t);
            TRX.(conditionname)(i).numero_larva_num=NaN(size_time,1);
            TRX.(conditionname)(i).numero_larva_num(1:size_time,1)=id;
        end
    end
    
    for timing=1:length(times_to_consider)
        
        t_ini=times_to_consider(timing,1);
        t_end=times_to_consider(timing,2);
        t_tot=t_end-t_ini;
        timingname=['window_' num2str(t_ini) 'to' num2str(t_end) 's'];
        
        mkdir(adress, timingname);
        adress=[adress timingname '\'];
        mkdir(adress, 'dataFiles');
        
        %% Get the distance traveled from t_ini to t_end
        
        distance=struct;
        distance_normbysize=struct;
        larva_length=struct;
        t_track=struct;
        mean_distances=NaN(1,nombredeconditions);
        sem_distances=NaN(1,nombredeconditions);
        for condition=1:nombredeconditions
            conditionname=titres(condition);
            for i=1:length(TRX.(conditionname))
                indices=find(TRX.(conditionname)(i).t(:,1)>=t_ini&TRX.(conditionname)(i).t<t_end);
                if isempty(indices)==0 % if the larva is tracked
                    time_tracked_loc=TRX.(conditionname)(i).t(max(indices),1)-TRX.(conditionname)(i).t(min(indices),1);
                    if time_tracked_loc>=0.95*t_tot % if it is tracked during (almost) the whole time of the time period wanted
                        x_ini=TRX.(conditionname)(i).x_center(min(indices));
                        y_ini=TRX.(conditionname)(i).y_center(min(indices));
                        x_end=TRX.(conditionname)(i).x_center(max(indices));
                        y_end=TRX.(conditionname)(i).y_center(max(indices));
                        t_track.(conditionname)(i,1)=TRX.(conditionname)(i).t(max(indices))-TRX.(conditionname)(i).t(min(indices));
                        larva_length.(conditionname)(i,1)=mean(TRX.(conditionname)(i).larva_length_smooth_5); % NB. length is calculated over the whole period of tracking
                        distance.(conditionname)(i,1)=sqrt((x_end-x_ini)^2+(y_end-y_ini)^2);
                        distance_normbysize.(conditionname)(i,1)=sqrt((x_end-x_ini)^2+(y_end-y_ini)^2)/larva_length.(conditionname)(i,1);
                        speed_normbysize.(conditionname)(i,1)=distance_normbysize.(conditionname)(i,1)/t_track.(conditionname)(i,1);
                    else
                        t_track.(conditionname)(i,1)=NaN;
                        distance.(conditionname)(i,1)=NaN;
                        distance_normbysize.(conditionname)(i,1)=NaN;
                        larva_length.(conditionname)(i,1)=NaN;
                        speed_normbysize.(conditionname)(i,1)=NaN;
                    end
                else
                    t_track.(conditionname)(i,1)=NaN;
                    distance.(conditionname)(i,1)=NaN;
                    distance_normbysize.(conditionname)(i,1)=NaN;
                    larva_length.(conditionname)(i,1)=NaN;
                    speed_normbysize.(conditionname)(i,1)=NaN;
                end
            end
            number_nan=sum(isnan(distance.(conditionname)));
            number_indiv=length(distance.(conditionname))-number_nan;
            mean_distances(1,condition)=nanmean(distance.(conditionname));
            sem_distances(1,condition)=nanstd(distance.(conditionname))/sqrt(number_indiv);
            mean_distances_norm(1,condition)=nanmean(distance_normbysize.(conditionname));
            sem_distances_norm(1,condition)=nanstd(distance_normbysize.(conditionname))/sqrt(number_indiv);
        end
        
        % Plot distance
        xcat=categorical(titres);
        figure
        fig2=bar(xcat,mean_distances);
        hold on
        er = errorbar(xcat,mean_distances,sem_distances,sem_distances);
        er.Color = [0 0 0];
        er.LineStyle = 'none';
        fig2.FaceColor = 'flat';
        for condition=1:length(titres)
            fig2.CData(condition,:) = couleurs(condition,:);
        end
        ylabel('Distance crawled (mm)');
        title(['Distance crawled from ' num2str(t_ini) ' to ' num2str(t_end) 's']);
        % set(gca,'FontSize',18)
        mkdir(adress, 'figures');
        filename=[adress 'figures\distance'];
        saveas(gcf,[filename '.fig']);
        saveas(gcf,[filename '.png']);
        
        % Plot distance normalized by the larval length
        xcat=categorical(titres);
        figure
        fig2=bar(xcat,mean_distances_norm);
        hold on
        er = errorbar(xcat,mean_distances_norm,sem_distances_norm,sem_distances_norm);
        er.Color = [0 0 0];
        er.LineStyle = 'none';
        fig2.FaceColor = 'flat';
        for condition=1:length(titres)
            fig2.CData(condition,:) = couleurs(condition,:);
        end
        ylabel('Distance crawled/larval length');
        title(['Distance crawled normalized by larval length from ' num2str(t_ini) ' to ' num2str(t_end) 's']);
        % set(gca,'FontSize',18)
        mkdir(adress, 'figures');
        filename=[adress 'figures\distance'];
        saveas(gcf,[filename '.fig']);
        saveas(gcf,[filename '.png']);
        
        %% Get number of bends (approximate of direction changes)
        
        numberofturns=struct;
        mean_turns=NaN(1,nombredeconditions);
        sem_turns=NaN(1,nombredeconditions);
        for condition=1:nombredeconditions
            conditionname=titres(condition);
            for i=1:length(TRX.(conditionname))
                indices=find(TRX.(conditionname)(i).t(:,1)>=t_ini&TRX.(conditionname)(i).t<t_end);
                if isempty(indices)==0
                    time_tracked_loc=TRX.(conditionname)(i).t(max(indices),1)-TRX.(conditionname)(i).t(min(indices),1);
                    if time_tracked_loc>=0.95*t_tot % if it is tracked during (almost) the whole time of the time period wanted
                        actionLarva_loc=TRX.(conditionname)(i).global_state_large_state(indices);
                        timesforbend=find(actionLarva_loc==2);
                        if isempty(timesforbend)==0 % if indeed the larva bend during that time window
                            if successiveNumbers(timesforbend)==0 % if several periods of bend
                                beginend = findSuccessiveNumbers(timesforbend); % table that contains one column for begining the time sequence of this action, and one column for the end
                                numberofturns.(conditionname)(i,1)=size(beginend,1);
                            else % if only one period of bend
                                numberofturns.(conditionname)(i,1)=1;
                            end
                        else
                            numberofturns.(conditionname)(i,1)=0;
                        end
                    else
                        numberofturns.(conditionname)(i,1)=NaN;
                    end
                else
                    numberofturns.(conditionname)(i,1)=NaN;
                end
            end
            number_nan=sum(isnan(numberofturns.(conditionname)));
            number_indiv=length(numberofturns.(conditionname))-number_nan;
            mean_turns(1,condition)=nanmean(numberofturns.(conditionname));
            sem_turns(1,condition)=nanstd(numberofturns.(conditionname))/sqrt(number_indiv);
        end
        
        % Plot number of turns
        xcat=categorical(titres);
        figure
        fig2=bar(xcat,mean_turns);
        hold on
        er = errorbar(xcat,mean_turns,sem_turns,sem_turns);
        er.Color = [0 0 0];
        er.LineStyle = 'none';
        fig2.FaceColor = 'flat';
        for condition=1:length(titres)
            fig2.CData(condition,:) = couleurs(condition,:);
        end
        ylabel('Number of bends');
        title(['Number of bends from ' num2str(t_ini) ' to ' num2str(t_end) 's']);
        %         set(gca,'FontSize',18)
        mkdir(adress, 'figures');
        filename=[adress 'figures\numberofbends'];
        saveas(gcf,[filename '.fig']);
        saveas(gcf,[filename '.png']);
        
        %% Get number of head sweap during each bending event
        
        numberofsweep=struct;
        mean_sweep=NaN(1,nombredeconditions);
        sem_sweep=NaN(1,nombredeconditions);
        for condition=1:nombredeconditions
            conditionname=titres(condition);
            for i=1:length(TRX.(conditionname))
                larvaname=['larva' num2str(i)];
                indices=find(TRX.(conditionname)(i).t(:,1)>=t_ini&TRX.(conditionname)(i).t<t_end);
                if isempty(indices)==0
                    time_tracked_loc=TRX.(conditionname)(i).t(max(indices),1)-TRX.(conditionname)(i).t(min(indices),1);
                    if time_tracked_loc>=0.95*t_tot % if it is tracked during (almost) the whole time of the time period wanted
                        
                        actionLarva_loc=TRX.(conditionname)(i).global_state_large_state(indices);
                        angle_loc=TRX.(conditionname)(i).angle_upper_lower_smooth_5(indices);
                        timesforbend=find(actionLarva_loc==2);
                        if isempty(timesforbend)==0 % if indeed the larva bend during that time window
                            if successiveNumbers(timesforbend)==0 % if several periods of bend
                                beginend = findSuccessiveNumbers(timesforbend); % table that contains one column for begining the time sequence of this action, and one column for the end
                            else % if only one period of bend
                                beginend=[min(timesforbend) max(timesforbend)];
                            end
                            numberofbend=size(beginend,1);
                            for bending=1:numberofbend
                                bendname=['bending' num2str(bending)];
                                indicesbend=beginend(bending,:);
                                numberofsteps=indicesbend(1,2)-indicesbend(1,1)+1;
                                if numberofsteps>2
                                    angle_loc2=angle_loc(indicesbend(1,1):indicesbend(1,2));
                                    headsweep=1;
                                    check=0; % we add a check variable to get rid of artifacts of changes of direction of the head (that do not maitain for more than 1 image)
                                    angle1=angle_loc2(2,1);
                                    for step=2:numberofsteps-1
                                        if angle1>=0
                                            signe1=1; % positive
                                        else
                                            signe1=0; % negative
                                        end
                                        angle2=angle_loc2(step,1);
                                        if angle2>=0
                                            signe2=1; % positive
                                        else
                                            signe2=0; % negative
                                        end
                                        if signe1==signe2
                                            % we add a condition : angle has to be of the other sign for more than one image to count
                                            if check==1 % if it was already of the other sign during one image before, we count it, then put back the counter to 0
                                                headsweep=headsweep+1;
                                                check=0;
                                            end
                                        else % if change direction of head (angle has the other sign)
                                            check=1;
                                        end
                                        angle1=angle2;
                                    end
                                else
                                    headsweep=1;
                                end
                                sweepbylarva.(conditionname).(larvaname)(bending,1)=headsweep;
                            end
                            numberofsweep.(conditionname)(i,1)=mean(sweepbylarva.(conditionname).(larvaname));
                        else
                            numberofsweep.(conditionname)(i,1)=NaN;
                        end
                    else
                        numberofsweep.(conditionname)(i,1)=NaN;
                    end
                else
                    numberofsweep.(conditionname)(i,1)=NaN;
                end
            end
            number_nan=sum(isnan(numberofsweep.(conditionname)));
            number_indiv=length(numberofsweep.(conditionname))-number_nan;
            mean_sweep(1,condition)=nanmean(numberofsweep.(conditionname));
            sem_sweep(1,condition)=nanstd(numberofsweep.(conditionname))/sqrt(number_indiv);
        end
        
        % Plot number of sweep
        xcat=categorical(titres);
        figure
        fig2=bar(xcat,mean_sweep);
        hold on
        er = errorbar(xcat,mean_sweep,sem_sweep,sem_sweep);
        er.Color = [0 0 0];
        er.LineStyle = 'none';
        fig2.FaceColor = 'flat';
        for condition=1:length(titres)
            fig2.CData(condition,:) = couleurs(condition,:);
        end
        ylabel('Mean number of head sweeps');
        title(['Mean number of head sweeps during a bending period from ' num2str(t_ini) ' to ' num2str(t_end) 's']);
        % set(gca,'FontSize',18)
        mkdir(adress, 'figures');
        filename=[adress 'figures\numberofsweeps'];
        saveas(gcf,[filename '.fig']);
        saveas(gcf,[filename '.png']);
        
        %% Get time during which each crawling bout lasts, number of crawling bouts, speed of crawls, effective speed during crawls (distance from initial to final location over duration of crawl), and maximum duration of crawl
        
        numberofruns=struct;
        maxdurationruns=struct;
        speed_during_run=struct;
        effective_speed_during_run=struct;
        effective_speed_during_run_norm=struct;
        totaltimerun=struct;
        meantimerun=struct;
        larvalength=struct;
        mean_timerun=NaN(1,nombredeconditions);
        sem_timerun=NaN(1,nombredeconditions);
        mean_totaltimerun=NaN(1,nombredeconditions);
        sem_totaltimerun=NaN(1,nombredeconditions);
        mean_numberofrun=NaN(1,nombredeconditions);
        sem_numberofrun=NaN(1,nombredeconditions);
        mean_maxdurationofrun=NaN(1,nombredeconditions);
        sem_maxdurationofrun=NaN(1,nombredeconditions);
        mean_effective_speed_during_run=NaN(1,nombredeconditions);
        sem_effective_speed_during_run=NaN(1,nombredeconditions);
        mean_effective_speed_during_run_norm=NaN(1,nombredeconditions);
        sem_effective_speed_during_run_norm=NaN(1,nombredeconditions);
        for condition=1:nombredeconditions
            conditionname=titres(condition);
            for i=1:length(TRX.(conditionname)) % for each larva
                indices=find(TRX.(conditionname)(i).t(:,1)>=t_ini&TRX.(conditionname)(i).t<t_end);
                if length(indices)>=2 % if the larva was tracked during more than 2 images
                    time_tracked_loc=TRX.(conditionname)(i).t(max(indices),1)-TRX.(conditionname)(i).t(min(indices),1);
                    if time_tracked_loc<=0.95*t_tot % if it is tracked during (almost) the whole time of the time period wanted
                        actionLarva_loc=TRX.(conditionname)(i).global_state_large_state(indices);
                        timeLarva_loc=TRX.(conditionname)(i).t(indices);
                        xlarva_loc=TRX.(conditionname)(i).x_center(indices);
                        ylarva_loc=TRX.(conditionname)(i).y_center(indices);
                        timesforrun=find(actionLarva_loc==1);
                        larva_length_loc=mean(TRX.(conditionname)(i).larva_length_smooth_5(indices));
                        if isempty(timesforrun)==0 % if indeed the larva run during that time window
                            
                            if successiveNumbers(timesforrun)==0 % if several periods of run
                                beginend = findSuccessiveNumbers(timesforrun); % table that contains one column for begining the time sequence of this action, and one column for the end
                                numberofruns.(conditionname)(i,1)=size(beginend,1);
                                % calculate total time running
                                timeruni=0;
                                timerunmax=0;
                                for irun=1:size(beginend,1) % for each session of run
                                    irunduration=timeLarva_loc(beginend(irun,2))-timeLarva_loc(beginend(irun,1));
                                    timeruni=timeruni+irunduration;
                                    timerunmax=max(timerunmax,irunduration);
                                end
                                totaltimerun.(conditionname)(i,1)=timeruni;
                                % calculate run speed
                                effective_speed_during_run_i=NaN(size(beginend,1),1);
                                effective_speed_during_run_norm_i=NaN(size(beginend,1),1);
                                for irun=1:size(beginend,1) % for each session of run
                                    stepsrun=[beginend(irun,1) beginend(irun,2)];
                                    dx=xlarva_loc(stepsrun(1,2))-xlarva_loc(stepsrun(1,1));
                                    dy=ylarva_loc(stepsrun(1,2))-ylarva_loc(stepsrun(1,1));
                                    dt=timeLarva_loc(stepsrun(1,2))-timeLarva_loc(stepsrun(1,1));
                                    effective_speed_during_run_i(irun,1)=sqrt(dx^2+dy^2)/dt;
                                    effective_speed_during_run_norm_i(irun,1)=effective_speed_during_run_i(irun,1)/larva_length_loc;
                                    speedrun=[];
                                    if stepsrun(1,2)-stepsrun(1,1)>1 % if number of steps more than 2
                                        k=1;
                                        for step=stepsrun(1,1):stepsrun(1,2)-1
                                            dx=xlarva_loc(step+1)-xlarva_loc(step);
                                            dy=ylarva_loc(step+1)-ylarva_loc(step);
                                            dt=timeLarva_loc(step+1)-timeLarva_loc(step);
                                            speedrun(k,1)=sqrt(dx^2+dy^2)/dt;
                                            k=k+1;
                                        end
                                        speedrun_meanbyevent(irun,1)=mean(speedrun);
                                    else
                                        speedrun_meanbyevent(irun,1)=NaN;
                                        effective_speed_during_run_i(irun,1)=NaN;
                                        effective_speed_during_run_norm_i(irun,1)=NaN;
                                    end
                                end
                            else % if only one period of run
                                beginend = [min(timesforrun) max(timesforrun)];
                                effective_speed_during_run_i=NaN(size(beginend,1),1);
                                effective_speed_during_run_norm_i=NaN(size(beginend,1),1);
                                numberofruns.(conditionname)(i,1)=1;
                                totaltimerun.(conditionname)(i,1)=max(timeLarva_loc(timesforrun))-min(timeLarva_loc(timesforrun));
                                timerunmax=max(timeLarva_loc(timesforrun))-min(timeLarva_loc(timesforrun));
                                % calculate speed
                                stepsrun=beginend;
                                dx=xlarva_loc(stepsrun(1,2))-xlarva_loc(stepsrun(1,1));
                                dy=ylarva_loc(stepsrun(1,2))-ylarva_loc(stepsrun(1,1));
                                dt=timeLarva_loc(stepsrun(1,2))-timeLarva_loc(stepsrun(1,1));
                                effective_speed_during_run_i(1,1)=sqrt(dx^2+dy^2)/dt;
                                effective_speed_during_run_norm_i(1,1)=effective_speed_during_run_i(1,1)/larva_length_loc;
                                speedrun=[];
                                if stepsrun(1,2)-stepsrun(1,1)>=2
                                    k=1;
                                    for step=stepsrun(1,1):stepsrun(1,2)-1
                                        dx=xlarva_loc(step+1)-xlarva_loc(step);
                                        dy=ylarva_loc(step+1)-ylarva_loc(step);
                                        dt=timeLarva_loc(step+1)-timeLarva_loc(step);
                                        speedrun(k,1)=sqrt(dx^2+dy^2)/dt;
                                        k=k+1;
                                    end
                                    speedrun_meanbyevent=mean(speedrun);
                                else
                                    speedrun_meanbyevent=NaN;
                                end
                            end
                            speed_during_run.(conditionname)(i,1)=mean(speedrun);
                            meantimerun.(conditionname)(i,1)=totaltimerun.(conditionname)(i,1)/numberofruns.(conditionname)(i,1);
                            maxdurationruns.(conditionname)(i,1)=timerunmax;
                            effective_speed_during_run.(conditionname)(i,1)=nanmean(effective_speed_during_run_i);
                            effective_speed_during_run_norm.(conditionname)(i,1)=nanmean(effective_speed_during_run_norm_i);
                            
                        else
                            numberofruns.(conditionname)(i,1)=0;
                            totaltimerun.(conditionname)(i,1)=0;
                            meantimerun.(conditionname)(i,1)=0;
                            maxdurationruns.(conditionname)(i,1)=NaN;
                            speed_during_run.(conditionname)(i,1)=NaN;
                            effective_speed_during_run.(conditionname)(i,1)=NaN;
                            effective_speed_during_run_norm.(conditionname)(i,1)=NaN;
                        end
                    else
                        numberofruns.(conditionname)(i,1)=NaN;
                        totaltimerun.(conditionname)(i,1)=NaN;
                        meantimerun.(conditionname)(i,1)=NaN;
                        maxdurationruns.(conditionname)(i,1)=NaN;
                        speed_during_run.(conditionname)(i,1)=NaN;
                        effective_speed_during_run.(conditionname)(i,1)=NaN;
                        effective_speed_during_run_norm.(conditionname)(i,1)=NaN;
                    end
                else
                    numberofruns.(conditionname)(i,1)=NaN;
                    totaltimerun.(conditionname)(i,1)=NaN;
                    meantimerun.(conditionname)(i,1)=NaN;
                    maxdurationruns.(conditionname)(i,1)=NaN;
                    speed_during_run.(conditionname)(i,1)=NaN;
                    effective_speed_during_run.(conditionname)(i,1)=NaN;
                    effective_speed_during_run_norm.(conditionname)(i,1)=NaN;
                end
            end
            number_nan=sum(isnan(meantimerun.(conditionname)));
            number_indiv=length(meantimerun.(conditionname))-number_nan;
            number_nan_speed=sum(isnan(speed_during_run.(conditionname)));
            number_indiv_speed=length(speed_during_run.(conditionname))-number_nan_speed;
            number_nan_effective_speed=sum(isnan(effective_speed_during_run.(conditionname)));
            number_indiv_effective_speed=length(effective_speed_during_run.(conditionname))-number_nan_effective_speed;
            mean_timerun(1,condition)=nanmean(meantimerun.(conditionname));
            sem_timerun(1,condition)=nanstd(meantimerun.(conditionname))/sqrt(number_indiv);
            mean_numberofrun(1,condition)=nanmean(numberofruns.(conditionname));
            sem_numberofrun(1,condition)=nanstd(numberofruns.(conditionname))/sqrt(number_indiv);
            mean_totaltimerofrun(1,condition)=nanmean(totaltimerun.(conditionname));
            sem_totaltimerofrun(1,condition)=nanstd(totaltimerun.(conditionname))/sqrt(number_indiv);
            mean_maxdurationofrun(1,condition)=nanmean(maxdurationruns.(conditionname));
            sem_maxdurationofrun(1,condition)=nanstd(maxdurationruns.(conditionname))/sqrt(number_indiv);
            mean_speed_during_run(1,condition)=nanmean(speed_during_run.(conditionname));
            sem_speed_during_run(1,condition)=nanstd(speed_during_run.(conditionname))/sqrt(number_indiv_speed);
            mean_effective_speed_during_run(1,condition)=nanmean(effective_speed_during_run.(conditionname));
            sem_effective_speed_during_run(1,condition)=nanstd(effective_speed_during_run.(conditionname))/sqrt(number_indiv_speed);
            mean_effective_speed_during_run_norm(1,condition)=nanmean(effective_speed_during_run_norm.(conditionname));
            sem_effective_speed_during_run_norm(1,condition)=nanstd(effective_speed_during_run_norm.(conditionname))/sqrt(number_indiv_effective_speed);
        end
        
        % Plot number of runs
        xcat=categorical(titres);
        figure
        fig2=bar(xcat,mean_numberofrun);
        hold on
        er = errorbar(xcat,mean_numberofrun,sem_numberofrun,sem_numberofrun);
        er.Color = [0 0 0];
        er.LineStyle = 'none';
        fig2.FaceColor = 'flat';
        for condition=1:length(titres)
            fig2.CData(condition,:) = couleurs(condition,:);
        end
        ylabel('Number of runs');
        title(['Number of runs from ' num2str(t_ini) ' to ' num2str(t_end) 's']);
        % set(gca,'FontSize',18)
        mkdir(adress, 'figures');
        filename=[adress 'figures\numberofruns'];
        saveas(gcf,[filename '.fig']);
        saveas(gcf,[filename '.png']);
        
        % Plot duration of runs
        xcat=categorical(titres);
        figure
        fig2=bar(xcat,mean_timerun);
        hold on
        er = errorbar(xcat,mean_timerun,sem_timerun,sem_timerun);
        er.Color = [0 0 0];
        er.LineStyle = 'none';
        fig2.FaceColor = 'flat';
        for condition=1:length(titres)
            fig2.CData(condition,:) = couleurs(condition,:);
        end
        ylabel('Mean duration of runs (s)');
        title(['Mean duration of runs from ' num2str(t_ini) ' to ' num2str(t_end) 's']);
        % set(gca,'FontSize',18)
        mkdir(adress, 'figures');
        filename=[adress 'figures\meandurationofruns'];
        saveas(gcf,[filename '.fig']);
        saveas(gcf,[filename '.png']);
        
        % Plot total duration of runs
        xcat=categorical(titres);
        figure
        fig2=bar(xcat,mean_totaltimerofrun);
        hold on
        er = errorbar(xcat,mean_totaltimerofrun,sem_totaltimerofrun,sem_totaltimerofrun);
        er.Color = [0 0 0];
        er.LineStyle = 'none';
        fig2.FaceColor = 'flat';
        for condition=1:length(titres)
            fig2.CData(condition,:) = couleurs(condition,:);
        end
        ylabel('Total duration of runs (s)');
        title(['Total duration of runs from ' num2str(t_ini) ' to ' num2str(t_end) 's']);
        % set(gca,'FontSize',18)
        mkdir(adress, 'figures');
        filename=[adress 'figures\totaldurationofruns'];
        saveas(gcf,[filename '.fig']);
        saveas(gcf,[filename '.png']);
        
        % Plot maximum duration of runs
        xcat=categorical(titres);
        figure
        fig2=bar(xcat,mean_maxdurationofrun);
        hold on
        er = errorbar(xcat,mean_maxdurationofrun,sem_maxdurationofrun,sem_maxdurationofrun);
        er.Color = [0 0 0];
        er.LineStyle = 'none';
        fig2.FaceColor = 'flat';
        for condition=1:length(titres)
            fig2.CData(condition,:) = couleurs(condition,:);
        end
        ylabel('Maximum duration of runs (s)');
        title(['Maximum duration of runs from ' num2str(t_ini) ' to ' num2str(t_end) 's']);
        % set(gca,'FontSize',18)
        mkdir(adress, 'figures');
        filename=[adress 'figures\maximumdurationofruns'];
        saveas(gcf,[filename '.fig']);
        saveas(gcf,[filename '.png']);
        
        % Plot mean speed during runs
        xcat=categorical(titres);
        figure
        fig2=bar(xcat,mean_speed_during_run);
        hold on
        er = errorbar(xcat,mean_speed_during_run,sem_speed_during_run,sem_speed_during_run);
        er.Color = [0 0 0];
        er.LineStyle = 'none';
        fig2.FaceColor = 'flat';
        for condition=1:length(titres)
            fig2.CData(condition,:) = couleurs(condition,:);
        end
        ylabel('Mean speed during runs (mm/s)');
        title(['Mean speed during runs from ' num2str(t_ini) ' to ' num2str(t_end) 's']);
        % set(gca,'FontSize',18)
        mkdir(adress, 'figures');
        filename=[adress 'figures\speeduringruns'];
        saveas(gcf,[filename '.fig']);
        saveas(gcf,[filename '.png']);
        
        % Plot mean effective speed of runs
        xcat=categorical(titres);
        figure
        fig2=bar(xcat,mean_effective_speed_during_run);
        hold on
        er = errorbar(xcat,mean_effective_speed_during_run,sem_effective_speed_during_run,sem_effective_speed_during_run);
        er.Color = [0 0 0];
        er.LineStyle = 'none';
        fig2.FaceColor = 'flat';
        for condition=1:length(titres)
            fig2.CData(condition,:) = couleurs(condition,:);
        end
        ylabel('Effective speed during runs (mm/s)');
        title(['Effective speed during runs from ' num2str(t_ini) ' to ' num2str(t_end) 's']);
        % set(gca,'FontSize',18)
        mkdir(adress, 'figures');
        filename=[adress 'figures\effectivespeeduringruns'];
        saveas(gcf,[filename '.fig']);
        saveas(gcf,[filename '.png']);
        
        % Plot mean effective speed of runs normalized by the size of each
        % larva
        xcat=categorical(titres);
        figure
        fig2=bar(xcat,mean_effective_speed_during_run_norm);
        hold on
        er = errorbar(xcat,mean_effective_speed_during_run_norm,sem_effective_speed_during_run_norm,sem_effective_speed_during_run_norm);
        er.Color = [0 0 0];
        er.LineStyle = 'none';
        fig2.FaceColor = 'flat';
        for condition=1:length(titres)
            fig2.CData(condition,:) = couleurs(condition,:);
        end
        ylabel('Effective speed during runs normalized by larval size (/s)');
        title(['Effective speed during runs normalized by larval size from ' num2str(t_ini) ' to ' num2str(t_end) 's']);
        % set(gca,'FontSize',18)
        mkdir(adress, 'figures');
        filename=[adress 'figures\effectivespeeduringruns_normalizedbysize'];
        saveas(gcf,[filename '.fig']);
        saveas(gcf,[filename '.png']);
        
        %% Plot average speed for all larvae over total time of runs
        
        speedovertimerun=struct;
        for condition=1:nombredeconditions
            conditionname=titres(condition);
            for i=1:length(TRX.(conditionname))
                if totaltimerun.(conditionname)(i,1)==0
                    speedovertimerun.(conditionname)(i,1)=0;
                elseif totaltimerun.(conditionname)(i,1)==NaN
                    speedovertimerun.(conditionname)(i,1)=NaN;
                else
                    speedovertimerun.(conditionname)(i,1)=distance.(conditionname)(i,1)/totaltimerun.(conditionname)(i,1);
                end
            end
            number_nan=sum(isnan(speedovertimerun.(conditionname)));
            number_indiv=length(speedovertimerun.(conditionname))-number_nan;
            mean_speedovertimerun(1,condition)=nanmean(speedovertimerun.(conditionname));
            sem_speedovertimerun(1,condition)=nanstd(speedovertimerun.(conditionname))/sqrt(number_indiv);
        end
        
        % Plot average speedovertimerun
        xcat=categorical(titres);
        figure
        fig2=bar(xcat,mean_speedovertimerun);
        hold on
        er = errorbar(xcat,mean_speedovertimerun,sem_speedovertimerun,sem_speedovertimerun);
        er.Color = [0 0 0];
        er.LineStyle = 'none';
        fig2.FaceColor = 'flat';
        for condition=1:length(titres)
            fig2.CData(condition,:) = couleurs(condition,:);
        end
        ylabel('Average speed over time running (/s)');
        title(['Average distance over time running from ' num2str(t_ini) ' to ' num2str(t_end) 's']);
        %         set(gca,'FontSize',18)
        mkdir(adress, 'figures');
        filename=[adress 'figures\speedovertimerunoftotalruns_alllarvae'];
        saveas(gcf,[filename '.fig']);
        saveas(gcf,[filename '.png']);
        
        %% Plot average speed for all larva during the whole experiment
        
        speedbylarva=struct;
        speed=struct;
        for condition=1:nombredeconditions
            conditionname=titres(condition);
            for i=1:length(TRX.(conditionname))
                larvaname=['larva' num2str(i)];
                indices=find(TRX.(conditionname)(i).t(:,1)>=t_ini&TRX.(conditionname)(i).t<t_end);
                if length(indices)>=2 % if the larva was tracked during more than 2 images
                    xLarva_loc=TRX.(conditionname)(i).x_center(indices);
                    yLarva_loc=TRX.(conditionname)(i).y_center(indices);
                    timeLarva=TRX.(conditionname)(i).t(indices);
                    for timetrack=1:length(timeLarva)-1 % calculate speed of the center of the larva
                        dx=xLarva_loc(timetrack+1)-xLarva_loc(timetrack);
                        dy=yLarva_loc(timetrack+1)-yLarva_loc(timetrack);
                        dt=timeLarva(timetrack+1)-timeLarva(timetrack);
                        speedbylarva.(conditionname).(larvaname)(timetrack,1)=sqrt(dx^2+dy^2)/dt;
                    end
                    speed.(conditionname)(i,1)=mean(speedbylarva.(conditionname).(larvaname)(:,1));
                else
                    speed.(conditionname)(i,1)=NaN;
                end
            end
            number_nan=sum(isnan(speed.(conditionname)));
            number_indiv=length(speed.(conditionname))-number_nan;
            mean_speed(1,condition)=nanmean(speed.(conditionname));
            sem_speed(1,condition)=nanstd(speed.(conditionname))/sqrt(number_indiv);
        end
        
        % Plot average speed
        xcat=categorical(titres);
        figure
        fig2=bar(xcat,mean_speed);
        hold on
        er = errorbar(xcat,mean_speed,sem_speed,sem_speed);
        er.Color = [0 0 0];
        er.LineStyle = 'none';
        fig2.FaceColor = 'flat';
        for condition=1:length(titres)
            fig2.CData(condition,:) = couleurs(condition,:);
        end
        ylabel('Average speed (mm/s)');
        title(['Average speed from ' num2str(t_ini) ' to ' num2str(t_end) 's']);
        %         set(gca,'FontSize',18)
        mkdir(adress, 'figures');
        filename=[adress 'figures\speed_alllarvae'];
        saveas(gcf,[filename '.fig']);
        saveas(gcf,[filename '.png']);
        
        %% Plot average speed for each larva during running episodes
        
        speed_duringruns=struct;
        speed_duringrunsbylarva=struct;
        for condition=1:nombredeconditions
            conditionname=titres(condition);
            for i=1:length(TRX.(conditionname))
                larvaname=['larva' num2str(i)];
                indices=find(TRX.(conditionname)(i).t(:,1)>=t_ini&TRX.(conditionname)(i).t<t_end);
                if length(indices)>=2 % if the larva was tracked during more than 2 images
                    actionLarva_loc=TRX.(conditionname)(i).global_state_large_state(indices);
                    timeLarva=TRX.(conditionname)(i).t(indices);
                    xLarva_loc=TRX.(conditionname)(i).x_center(indices);
                    yLarva_loc=TRX.(conditionname)(i).y_center(indices);
                    indexforrun=find(actionLarva_loc==1);
                    if isempty(indexforrun)==0 % if indeed the larva run during that time window
                        if successiveNumbers(indexforrun)==0 % if several periods of run
                            beginend = findSuccessiveNumbers(indexforrun); % table that contains one column for begining the time sequence of this action, and one column for the end
                        else % if only one period of run
                            beginend = [min(indexforrun) max(indexforrun)];
                        end
                        meansspeed=NaN(size(beginend,1),1);
                        for run_session=1:size(beginend,1)
                            sessionname=['session' num2str(run_session)];
                            indicedebut=beginend(run_session,1);
                            indicefin=beginend(run_session,2);
                            steps=indicefin-indicedebut+1;
                            timeLarva2=timeLarva(indicedebut:indicefin);
                            xLarva_loc2=xLarva_loc(indicedebut:indicefin);
                            yLarva_loc2=yLarva_loc(indicedebut:indicefin);
                            if steps>1
                                k=1;
                                for timetrack=1:steps-1 % calculate speed_duringruns of the center of the larva
                                    dx=xLarva_loc2(timetrack+1)-xLarva_loc2(timetrack);
                                    dy=yLarva_loc2(timetrack+1)-yLarva_loc2(timetrack);
                                    dt=timeLarva2(timetrack+1)-timeLarva2(timetrack);
                                    speed_duringrunsbylarva.(conditionname).(larvaname).(sessionname)(k,1)=sqrt(dx^2+dy^2)/dt;
                                    k=k+1;
                                end
                                meansspeed(run_session,1)=mean(speed_duringrunsbylarva.(conditionname).(larvaname).(sessionname)(:,1));
                            else
                                speed_duringrunsbylarva.(conditionname).(sessionname).(larvaname)=NaN;
                                meansspeed(run_session,1)=NaN;
                            end
                        end
                        speed_duringruns.(conditionname)(i,1)=nanmean(meansspeed);
                    else
                        speed_duringruns.(conditionname)(i,1)=NaN;
                    end
                else % if the larva was not tracked during more than 2 images
                    speed_duringruns.(conditionname)(i,1)=NaN;
                end
            end
            number_nan=sum(isnan(speed_duringruns.(conditionname)));
            number_indiv=length(speed_duringruns.(conditionname))-number_nan;
            mean_speed_duringruns(1,condition)=nanmean(speed_duringruns.(conditionname));
            sem_speed_duringruns(1,condition)=nanstd(speed_duringruns.(conditionname))/sqrt(number_indiv);
        end
        
        % Plot average speed_duringruns
        xcat=categorical(titres);
        figure
        fig2=bar(xcat,mean_speed_duringruns);
        hold on
        er = errorbar(xcat,mean_speed_duringruns,sem_speed_duringruns,sem_speed_duringruns);
        er.Color = [0 0 0];
        er.LineStyle = 'none';
        fig2.FaceColor = 'flat';
        for condition=1:length(titres)
            fig2.CData(condition,:) = couleurs(condition,:);
        end
        ylabel('Average speed during runs (mm/s)');
        title(['Average speed during runs from ' num2str(t_ini) ' to ' num2str(t_end) 's']);
        %         set(gca,'FontSize',18)
        mkdir(adress, 'figures');
        filename=[adress 'figures\speedduringruns_alllarvae'];
        saveas(gcf,[filename '.fig']);
        saveas(gcf,[filename '.png']);
        
        %% Compare distance data for significant differences
        
        % Generate variables that will store the results of the test
        pval_distance=NaN(1,1);
        pairwise_distance=NaN(nombredeconditions,1);
        
        % Generate table containing data
        dataToCompare=[];
        groups=[];
        for condition=1:nombredeconditions
            conditionname=titres(condition);
            dataToCompare=[dataToCompare; distance.(conditionname)];
            groupToAdd=repmat(conditionname,length(distance.(conditionname)),1);
            groups=[groups; groupToAdd];
        end
        groups=categorical(groups);
        % Do ANOVA
        [pval_distance,tbl,statstruct]=anova1(dataToCompare,groups,'off');
        pairwise_comp=multcompare(statstruct,'CType','bonferroni','Display', 'off');
        pairwise_distance=cell(nombredeconditions+1,nombredeconditions+1);
        pairwise_distance{1,1}="Conditions";
        i=1;
        for condition=1:nombredeconditions-1
            pairwise_distance{condition+1,condition+1}=NaN;
            if i<=nombredeconditions
                conditionname=titres(condition);
                pairwise_distance{1,condition+1}=conditionname;
                pairwise_distance{condition+1,1}=conditionname;
                for condition2=condition+1:nombredeconditions
                    pairwise_distance{condition2+1,condition2+1}=NaN;
                    conditionname2=titres(condition2);
                    pairwise_distance{condition2+1,1}=conditionname2;
                    pairwise_distance{1,condition2+1}=conditionname2;
                    pairwise_distance{condition+1,condition2+1}=pairwise_comp(i,6);
                    pairwise_distance{condition2+1,condition+1}=pairwise_comp(i,6);
                    i=i+1;
                end
            end
        end
        filename=[adress 'dataFiles\pval_distance.mat']; % store p-values for ANOVA of amplitudes
        save(filename, 'pval_distance'); % one line is a time window, one column is an action
        filename=[adress 'dataFiles\pairwise_distance.mat'];
        save(filename, 'pairwise_distance'); % look at last column for p values
        
        
        %% Compare distance_norm data for significant differences
        
        % Generate variables that will store the results of the test
        pval_distance_norm=NaN(1,1);
        pairwise_distance_norm=NaN(nombredeconditions,1);
        
        % Generate table containing data
        dataToCompare=[];
        groups=[];
        for condition=1:nombredeconditions
            conditionname=titres(condition);
            dataToCompare=[dataToCompare; distance_normbysize.(conditionname)];
            groupToAdd=repmat(conditionname,length(distance_normbysize.(conditionname)),1);
            groups=[groups; groupToAdd];
        end
        groups=categorical(groups);
        % Do ANOVA
        [pval_distance_norm,tbl,statstruct]=anova1(dataToCompare,groups,'off');
        pairwise_comp=multcompare(statstruct,'CType','bonferroni','Display', 'off');
        pairwise_distance_norm=cell(nombredeconditions+1,nombredeconditions+1);
        pairwise_distance_norm{1,1}="Conditions";
        i=1;
        for condition=1:nombredeconditions-1
            pairwise_distance_norm{condition+1,condition+1}=NaN;
            if i<=nombredeconditions
                conditionname=titres(condition);
                pairwise_distance_norm{1,condition+1}=conditionname;
                pairwise_distance_norm{condition+1,1}=conditionname;
                for condition2=condition+1:nombredeconditions
                    pairwise_distance_norm{condition2+1,condition2+1}=NaN;
                    conditionname2=titres(condition2);
                    pairwise_distance_norm{condition2+1,1}=conditionname2;
                    pairwise_distance_norm{1,condition2+1}=conditionname2;
                    pairwise_distance_norm{condition+1,condition2+1}=pairwise_comp(i,6);
                    pairwise_distance_norm{condition2+1,condition+1}=pairwise_comp(i,6);
                    i=i+1;
                end
            end
        end
        filename=[adress 'dataFiles\pval_distance_norm.mat']; % store p-values for ANOVA of amplitudes
        save(filename, 'pval_distance_norm'); % one line is a time window, one column is an action
        filename=[adress 'dataFiles\pairwise_distance_norm.mat'];
        save(filename, 'pairwise_distance_norm'); % look at last column for p values
        
        %% Compare speedovertimerun data for significant differences
        
        % Generate variables that will store the results of the test
        pval_speedovertimerun=NaN(1,1);
        pairwise_speedovertimerun=NaN(nombredeconditions,1);
        
        % Generate table containing data
        dataToCompare=[];
        groups=[];
        for condition=1:nombredeconditions
            conditionname=titres(condition);
            dataToCompare=[dataToCompare; speedovertimerun.(conditionname)];
            groupToAdd=repmat(conditionname,length(speedovertimerun.(conditionname)),1);
            groups=[groups; groupToAdd];
        end
        groups=categorical(groups);
        % Do ANOVA
        [pval_speedovertimerun,tbl,statstruct]=anova1(dataToCompare,groups,'off');
        pairwise_comp=multcompare(statstruct,'CType','bonferroni','Display', 'off');
        pairwise_speedovertimerun=cell(nombredeconditions+1,nombredeconditions+1);
        pairwise_speedovertimerun{1,1}="Conditions";
        i=1;
        for condition=1:nombredeconditions-1
            pairwise_speedovertimerun{condition+1,condition+1}=NaN;
            if i<=nombredeconditions
                conditionname=titres(condition);
                pairwise_speedovertimerun{1,condition+1}=conditionname;
                pairwise_speedovertimerun{condition+1,1}=conditionname;
                for condition2=condition+1:nombredeconditions
                    pairwise_speedovertimerun{condition2+1,condition2+1}=NaN;
                    conditionname2=titres(condition2);
                    pairwise_speedovertimerun{condition2+1,1}=conditionname2;
                    pairwise_speedovertimerun{1,condition2+1}=conditionname2;
                    pairwise_speedovertimerun{condition+1,condition2+1}=pairwise_comp(i,6);
                    pairwise_speedovertimerun{condition2+1,condition+1}=pairwise_comp(i,6);
                    i=i+1;
                end
            end
        end
        filename=[adress 'dataFiles\pval_speedovertimerun.mat']; % store p-values for ANOVA of amplitudes
        save(filename, 'pval_speedovertimerun'); % one line is a time window, one column is an action
        filename=[adress 'dataFiles\pairwise_speedovertimerun.mat'];
        save(filename, 'pairwise_speedovertimerun'); % look at last column for p values
        
        %% Compare speed_duringruns data for significant differences
        
        % Generate variables that will store the results of the test
        pval_speed_duringruns=NaN(1,1);
        pairwise_speed_duringruns=NaN(nombredeconditions,1);
        
        % Generate table containing data
        dataToCompare=[];
        groups=[];
        for condition=1:nombredeconditions
            conditionname=titres(condition);
            dataToCompare=[dataToCompare; speed_duringruns.(conditionname)];
            groupToAdd=repmat(conditionname,length(speed_duringruns.(conditionname)),1);
            groups=[groups; groupToAdd];
        end
        groups=categorical(groups);
        % Do ANOVA
        [pval_speed_duringruns,tbl,statstruct]=anova1(dataToCompare,groups,'off');
        pairwise_comp=multcompare(statstruct,'CType','bonferroni','Display', 'off');
        pairwise_speed_duringruns=cell(nombredeconditions+1,nombredeconditions+1);
        pairwise_speed_duringruns{1,1}="Conditions";
        i=1;
        for condition=1:nombredeconditions-1
            pairwise_speed_duringruns{condition+1,condition+1}=NaN;
            if i<=nombredeconditions
                conditionname=titres(condition);
                pairwise_speed_duringruns{1,condition+1}=conditionname;
                pairwise_speed_duringruns{condition+1,1}=conditionname;
                for condition2=condition+1:nombredeconditions
                    pairwise_speed_duringruns{condition2+1,condition2+1}=NaN;
                    conditionname2=titres(condition2);
                    pairwise_speed_duringruns{condition2+1,1}=conditionname2;
                    pairwise_speed_duringruns{1,condition2+1}=conditionname2;
                    pairwise_speed_duringruns{condition+1,condition2+1}=pairwise_comp(i,6);
                    pairwise_speed_duringruns{condition2+1,condition+1}=pairwise_comp(i,6);
                    i=i+1;
                end
            end
        end
        filename=[adress 'dataFiles\pval_speed_duringruns.mat']; % store p-values for ANOVA of amplitudes
        save(filename, 'pval_speed_duringruns'); % one line is a time window, one column is an action
        filename=[adress 'dataFiles\pairwise_speed_duringruns.mat'];
        save(filename, 'pairwise_speed_duringruns'); % look at last column for p values
        
        %% Compare numberofruns data for significant differences
        
        % Generate variables that will store the results of the test
        pval_numberofruns=NaN(1,1);
        pairwise_numberofruns=NaN(nombredeconditions,1);
        
        % Generate table containing data
        dataToCompare=[];
        groups=[];
        for condition=1:nombredeconditions
            conditionname=titres(condition);
            dataToCompare=[dataToCompare; numberofruns.(conditionname)];
            groupToAdd=repmat(conditionname,length(numberofruns.(conditionname)),1);
            groups=[groups; groupToAdd];
        end
        groups=categorical(groups);
        % Do ANOVA
        [pval_numberofruns,tbl,statstruct]=anova1(dataToCompare,groups,'off');
        pairwise_comp=multcompare(statstruct,'CType','bonferroni','Display', 'off');
        pairwise_numberofruns=cell(nombredeconditions+1,nombredeconditions+1);
        pairwise_numberofruns{1,1}="Conditions";
        i=1;
        for condition=1:nombredeconditions-1
            pairwise_numberofruns{condition+1,condition+1}=NaN;
            if i<=nombredeconditions
                conditionname=titres(condition);
                pairwise_numberofruns{1,condition+1}=conditionname;
                pairwise_numberofruns{condition+1,1}=conditionname;
                for condition2=condition+1:nombredeconditions
                    pairwise_numberofruns{condition2+1,condition2+1}=NaN;
                    conditionname2=titres(condition2);
                    pairwise_numberofruns{condition2+1,1}=conditionname2;
                    pairwise_numberofruns{1,condition2+1}=conditionname2;
                    pairwise_numberofruns{condition+1,condition2+1}=pairwise_comp(i,6);
                    pairwise_numberofruns{condition2+1,condition+1}=pairwise_comp(i,6);
                    i=i+1;
                end
            end
        end
        filename=[adress 'dataFiles\pval_numberofruns.mat']; % store p-values for ANOVA of amplitudes
        save(filename, 'pval_numberofruns'); % one line is a time window, one column is an action
        filename=[adress 'dataFiles\pairwise_numberofruns.mat'];
        save(filename, 'pairwise_numberofruns'); % look at last column for p values
        
        %% Compare totaltimerun data for significant differences
        
        % Generate variables that will store the results of the test
        pval_totaltimerun=NaN(1,1);
        pairwise_totaltimerun=NaN(nombredeconditions,1);
        
        % Generate table containing data
        dataToCompare=[];
        groups=[];
        for condition=1:nombredeconditions
            conditionname=titres(condition);
            dataToCompare=[dataToCompare; totaltimerun.(conditionname)];
            groupToAdd=repmat(conditionname,length(totaltimerun.(conditionname)),1);
            groups=[groups; groupToAdd];
        end
        groups=categorical(groups);
        % Do ANOVA
        [pval_totaltimerun,tbl,statstruct]=anova1(dataToCompare,groups,'off');
        pairwise_comp=multcompare(statstruct,'CType','bonferroni','Display', 'off');
        pairwise_totaltimerun=cell(nombredeconditions+1,nombredeconditions+1);
        pairwise_totaltimerun{1,1}="Conditions";
        i=1;
        for condition=1:nombredeconditions-1
            pairwise_totaltimerun{condition+1,condition+1}=NaN;
            if i<=nombredeconditions
                conditionname=titres(condition);
                pairwise_totaltimerun{1,condition+1}=conditionname;
                pairwise_totaltimerun{condition+1,1}=conditionname;
                for condition2=condition+1:nombredeconditions
                    pairwise_totaltimerun{condition2+1,condition2+1}=NaN;
                    conditionname2=titres(condition2);
                    pairwise_totaltimerun{condition2+1,1}=conditionname2;
                    pairwise_totaltimerun{1,condition2+1}=conditionname2;
                    pairwise_totaltimerun{condition+1,condition2+1}=pairwise_comp(i,6);
                    pairwise_totaltimerun{condition2+1,condition+1}=pairwise_comp(i,6);
                    i=i+1;
                end
            end
        end
        filename=[adress 'dataFiles\pval_totaltimerun.mat']; % store p-values for ANOVA of amplitudes
        save(filename, 'pval_totaltimerun'); % one line is a time window, one column is an action
        filename=[adress 'dataFiles\pairwise_totaltimerun.mat'];
        save(filename, 'pairwise_totaltimerun'); % look at last column for p values
        
        %% Compare meantimerun data for significant differences
        
        % Generate variables that will store the results of the test
        pval_meantimerun=NaN(1,1);
        pairwise_meantimerun=NaN(nombredeconditions,1);
        
        % Generate table containing data
        dataToCompare=[];
        groups=[];
        for condition=1:nombredeconditions
            conditionname=titres(condition);
            dataToCompare=[dataToCompare; meantimerun.(conditionname)];
            groupToAdd=repmat(conditionname,length(meantimerun.(conditionname)),1);
            groups=[groups; groupToAdd];
        end
        groups=categorical(groups);
        % Do ANOVA
        [pval_meantimerun,tbl,statstruct]=anova1(dataToCompare,groups,'off');
        pairwise_comp=multcompare(statstruct,'CType','bonferroni','Display', 'off');
        pairwise_meantimerun=cell(nombredeconditions+1,nombredeconditions+1);
        pairwise_meantimerun{1,1}="Conditions";
        i=1;
        for condition=1:nombredeconditions-1
            pairwise_meantimerun{condition+1,condition+1}=NaN;
            if i<=nombredeconditions
                conditionname=titres(condition);
                pairwise_meantimerun{1,condition+1}=conditionname;
                pairwise_meantimerun{condition+1,1}=conditionname;
                for condition2=condition+1:nombredeconditions
                    pairwise_meantimerun{condition2+1,condition2+1}=NaN;
                    conditionname2=titres(condition2);
                    pairwise_meantimerun{condition2+1,1}=conditionname2;
                    pairwise_meantimerun{1,condition2+1}=conditionname2;
                    pairwise_meantimerun{condition+1,condition2+1}=pairwise_comp(i,6);
                    pairwise_meantimerun{condition2+1,condition+1}=pairwise_comp(i,6);
                    i=i+1;
                end
            end
        end
        filename=[adress 'dataFiles\pval_meantimerun.mat']; % store p-values for ANOVA of amplitudes
        save(filename, 'pval_meantimerun'); % one line is a time window, one column is an action
        filename=[adress 'dataFiles\pairwise_meantimerun.mat'];
        save(filename, 'pairwise_meantimerun'); % look at last column for p values
        
        
        %% Compare maxdurationruns data for significant differences
        
        % Generate variables that will store the results of the test
        pval_maxdurationruns=NaN(1,1);
        pairwise_maxdurationruns=NaN(nombredeconditions,1);
        
        % Generate table containing data
        dataToCompare=[];
        groups=[];
        for condition=1:nombredeconditions
            conditionname=titres(condition);
            dataToCompare=[dataToCompare; maxdurationruns.(conditionname)];
            groupToAdd=repmat(conditionname,length(maxdurationruns.(conditionname)),1);
            groups=[groups; groupToAdd];
        end
        groups=categorical(groups);
        % Do ANOVA
        [pval_maxdurationruns,tbl,statstruct]=anova1(dataToCompare,groups,'off');
        pairwise_comp=multcompare(statstruct,'CType','bonferroni','Display', 'off');
        pairwise_maxdurationruns=cell(nombredeconditions+1,nombredeconditions+1);
        pairwise_maxdurationruns{1,1}="Conditions";
        i=1;
        for condition=1:nombredeconditions-1
            pairwise_maxdurationruns{condition+1,condition+1}=NaN;
            if i<=nombredeconditions
                conditionname=titres(condition);
                pairwise_maxdurationruns{1,condition+1}=conditionname;
                pairwise_maxdurationruns{condition+1,1}=conditionname;
                for condition2=condition+1:nombredeconditions
                    pairwise_maxdurationruns{condition2+1,condition2+1}=NaN;
                    conditionname2=titres(condition2);
                    pairwise_maxdurationruns{condition2+1,1}=conditionname2;
                    pairwise_maxdurationruns{1,condition2+1}=conditionname2;
                    pairwise_maxdurationruns{condition+1,condition2+1}=pairwise_comp(i,6);
                    pairwise_maxdurationruns{condition2+1,condition+1}=pairwise_comp(i,6);
                    i=i+1;
                end
            end
        end
        filename=[adress 'dataFiles\pval_maxdurationruns.mat']; % store p-values for ANOVA of amplitudes
        save(filename, 'pval_maxdurationruns'); % one line is a time window, one column is an action
        filename=[adress 'dataFiles\pairwise_maxdurationruns.mat'];
        save(filename, 'pairwise_maxdurationruns'); % look at last column for p values
        
        
        %% Compare numberofturns data for significant differences
        
        % Generate variables that will store the results of the test
        pval_numberofturns=NaN(1,1);
        pairwise_numberofturns=NaN(nombredeconditions,1);
        
        % Generate table containing data
        dataToCompare=[];
        groups=[];
        for condition=1:nombredeconditions
            conditionname=titres(condition);
            dataToCompare=[dataToCompare; numberofturns.(conditionname)];
            groupToAdd=repmat(conditionname,length(numberofturns.(conditionname)),1);
            groups=[groups; groupToAdd];
        end
        groups=categorical(groups);
        % Do ANOVA
        [pval_numberofturns,tbl,statstruct]=anova1(dataToCompare,groups,'off');
        pairwise_comp=multcompare(statstruct,'CType','bonferroni','Display', 'off');
        pairwise_numberofturns=cell(nombredeconditions+1,nombredeconditions+1);
        pairwise_numberofturns{1,1}="Conditions";
        i=1;
        for condition=1:nombredeconditions-1
            pairwise_numberofturns{condition+1,condition+1}=NaN;
            if i<=nombredeconditions
                conditionname=titres(condition);
                pairwise_numberofturns{1,condition+1}=conditionname;
                pairwise_numberofturns{condition+1,1}=conditionname;
                for condition2=condition+1:nombredeconditions
                    pairwise_numberofturns{condition2+1,condition2+1}=NaN;
                    conditionname2=titres(condition2);
                    pairwise_numberofturns{condition2+1,1}=conditionname2;
                    pairwise_numberofturns{1,condition2+1}=conditionname2;
                    pairwise_numberofturns{condition+1,condition2+1}=pairwise_comp(i,6);
                    pairwise_numberofturns{condition2+1,condition+1}=pairwise_comp(i,6);
                    i=i+1;
                end
            end
        end
        filename=[adress 'dataFiles\pval_numberofturns.mat']; % store p-values for ANOVA of amplitudes
        save(filename, 'pval_numberofturns'); % one line is a time window, one column is an action
        filename=[adress 'dataFiles\pairwise_numberofturns.mat'];
        save(filename, 'pairwise_numberofturns'); % look at last column for p values
        
        %% Compare numberofsweep data for significant differences
        
        % Generate variables that will store the results of the test
        pval_numberofsweep=NaN(1,1);
        pairwise_numberofsweep=NaN(nombredeconditions,1);
        
        % Generate table containing data
        dataToCompare=[];
        groups=[];
        for condition=1:nombredeconditions
            conditionname=titres(condition);
            dataToCompare=[dataToCompare; numberofsweep.(conditionname)];
            groupToAdd=repmat(conditionname,length(numberofsweep.(conditionname)),1);
            groups=[groups; groupToAdd];
        end
        groups=categorical(groups);
        % Do ANOVA
        [pval_numberofsweep,tbl,statstruct]=anova1(dataToCompare,groups,'off');
        pairwise_comp=multcompare(statstruct,'CType','bonferroni','Display', 'off');
        pairwise_numberofsweep=cell(nombredeconditions+1,nombredeconditions+1);
        pairwise_numberofsweep{1,1}="Conditions";
        i=1;
        for condition=1:nombredeconditions-1
            pairwise_numberofsweep{condition+1,condition+1}=NaN;
            if i<=nombredeconditions
                conditionname=titres(condition);
                pairwise_numberofsweep{1,condition+1}=conditionname;
                pairwise_numberofsweep{condition+1,1}=conditionname;
                for condition2=condition+1:nombredeconditions
                    pairwise_numberofsweep{condition2+1,condition2+1}=NaN;
                    conditionname2=titres(condition2);
                    pairwise_numberofsweep{condition2+1,1}=conditionname2;
                    pairwise_numberofsweep{1,condition2+1}=conditionname2;
                    pairwise_numberofsweep{condition+1,condition2+1}=pairwise_comp(i,6);
                    pairwise_numberofsweep{condition2+1,condition+1}=pairwise_comp(i,6);
                    i=i+1;
                end
            end
        end
        filename=[adress 'dataFiles\pval_numberofsweep.mat']; % store p-values for ANOVA of amplitudes
        save(filename, 'pval_numberofsweep'); % one line is a time window, one column is an action
        filename=[adress 'dataFiles\pairwise_numberofsweep.mat'];
        save(filename, 'pairwise_numberofsweep'); % look at last column for p values
        
        
        %% Compare effective speed during crawling data for significant differences
        
        % Generate variables that will store the results of the test
        pval_effective_speed_during_run=NaN(1,1);
        pairwise_effective_speed_during_run=NaN(nombredeconditions,1);
        
        % Generate table containing data
        dataToCompare=[];
        groups=[];
        for condition=1:nombredeconditions
            conditionname=titres(condition);
            dataToCompare=[dataToCompare; effective_speed_during_run.(conditionname)];
            groupToAdd=repmat(conditionname,length(effective_speed_during_run.(conditionname)),1);
            groups=[groups; groupToAdd];
        end
        groups=categorical(groups);
        % Do ANOVA
        [pval_effective_speed_during_run,tbl,statstruct]=anova1(dataToCompare,groups,'off');
        pairwise_comp=multcompare(statstruct,'CType','bonferroni','Display', 'off');
        pairwise_effective_speed_during_run=cell(nombredeconditions+1,nombredeconditions+1);
        pairwise_effective_speed_during_run{1,1}="Conditions";
        i=1;
        for condition=1:nombredeconditions-1
            pairwise_effective_speed_during_run{condition+1,condition+1}=NaN;
            if i<=nombredeconditions
                conditionname=titres(condition);
                pairwise_effective_speed_during_run{1,condition+1}=conditionname;
                pairwise_effective_speed_during_run{condition+1,1}=conditionname;
                for condition2=condition+1:nombredeconditions
                    pairwise_effective_speed_during_run{condition2+1,condition2+1}=NaN;
                    conditionname2=titres(condition2);
                    pairwise_effective_speed_during_run{condition2+1,1}=conditionname2;
                    pairwise_effective_speed_during_run{1,condition2+1}=conditionname2;
                    pairwise_effective_speed_during_run{condition+1,condition2+1}=pairwise_comp(i,6);
                    pairwise_effective_speed_during_run{condition2+1,condition+1}=pairwise_comp(i,6);
                    i=i+1;
                end
            end
        end
        filename=[adress 'dataFiles\pval_effective_speed_during_run.mat']; % store p-values for ANOVA of amplitudes
        save(filename, 'pval_effective_speed_during_run'); % one line is a time window, one column is an action
        filename=[adress 'dataFiles\pairwise_effective_speed_during_run.mat'];
        save(filename, 'pairwise_effective_speed_during_run'); % look at last column for p values
        
        %% Compare effective speed during crawling data for significant differences
        
        % Generate variables that will store the results of the test
        pval_effective_speed_during_run_norm=NaN(1,1);
        pairwise_effective_speed_during_run_norm=NaN(nombredeconditions,1);
        
        % Generate table containing data
        dataToCompare=[];
        groups=[];
        for condition=1:nombredeconditions
            conditionname=titres(condition);
            dataToCompare=[dataToCompare; effective_speed_during_run_norm.(conditionname)];
            groupToAdd=repmat(conditionname,length(effective_speed_during_run_norm.(conditionname)),1);
            groups=[groups; groupToAdd];
        end
        groups=categorical(groups);
        % Do ANOVA
        [pval_effective_speed_during_run_norm,tbl,statstruct]=anova1(dataToCompare,groups,'off');
        pairwise_comp=multcompare(statstruct,'CType','bonferroni','Display', 'off');
        pairwise_effective_speed_during_run_norm=cell(nombredeconditions+1,nombredeconditions+1);
        pairwise_effective_speed_during_run_norm{1,1}="Conditions";
        i=1;
        for condition=1:nombredeconditions-1
            pairwise_effective_speed_during_run_norm{condition+1,condition+1}=NaN;
            if i<=nombredeconditions
                conditionname=titres(condition);
                pairwise_effective_speed_during_run_norm{1,condition+1}=conditionname;
                pairwise_effective_speed_during_run_norm{condition+1,1}=conditionname;
                for condition2=condition+1:nombredeconditions
                    pairwise_effective_speed_during_run_norm{condition2+1,condition2+1}=NaN;
                    conditionname2=titres(condition2);
                    pairwise_effective_speed_during_run_norm{condition2+1,1}=conditionname2;
                    pairwise_effective_speed_during_run_norm{1,condition2+1}=conditionname2;
                    pairwise_effective_speed_during_run_norm{condition+1,condition2+1}=pairwise_comp(i,6);
                    pairwise_effective_speed_during_run_norm{condition2+1,condition+1}=pairwise_comp(i,6);
                    i=i+1;
                end
            end
        end
        filename=[adress 'dataFiles\pval_effective_speed_during_run_norm.mat']; % store p-values for ANOVA of amplitudes
        save(filename, 'pval_effective_speed_during_run_norm'); % one line is a time window, one column is an action
        filename=[adress 'dataFiles\pairwise_effective_speed_during_run_norm.mat'];
        save(filename, 'pairwise_effective_speed_during_run_norm'); % look at last column for p values
        
        %% Close and go back
        
        close all
        adress=char(adresses(exp));
    end
end
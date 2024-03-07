function [pooled_frequency, pooled_prob,n] = autotrx(directory, smooth, separate)

%%%%%%%%%%%%
       % This is a function that takes in path of a directory
       % containing experiments of a specific genotype and
       % protocol, and outputs behavioral probabilities for 
       % all six actions learned by JBM's pipeline via the trx
       % files outputted from the first part of pipeline
       
% last modified 4/12/20

% list all trx files
filelist = dir(fullfile(directory, '**/trx.mat')); 
% instantiate number of larvae
n = 0;
% resolution of counting in s
dt = 0.1;
% total time of experiment in s
t = 250;
% number of action considered
% crawl, cast, stop, hunch, backup, roll, sbend
if separate == 1
    action = 7; 
else
    action = 6;
end
%%%%%%%%%%%%
     % parameters for separating headcasting from static bend
%%%%%%%%%%%%

limit_t=0.5; % time threshold in second to consider it as a bend
limit_ratio=0.2; % ratio of the event defined as static bend (multiplied by time spent), then consider whole action as static bend
limit_ratiomax=0.8; % maximum ratio accepted to classify as static bend


% instantiate empty matrix to store action frequency
pooled_frequency = zeros(t/(2*dt),action+1);
pooled_frequency(:,1) = 2*dt:2*dt:t;
% instantiate empty matrix to store action probability
pooled_prob = zeros(t/(2*dt),action+1);
pooled_prob(:,1) = pooled_frequency(:,1);
n_active = zeros(t/(2*dt),1);

%%%%%%%%%%%%
   % start looping over each trx file
%%%%%%%%%%%%
for f = 1:length(filelist)
% load the raw trx file
filepath = strcat(filelist(f).folder,'/',filelist(f).name);
L = load(filepath);
% note the number of n for each experiment

nlimit = 20/dt;
for s = 1:length(L.trx)
    if length(L.trx(s).t) > nlimit
        n = n + 1;
    else
        n = n;
    end
end


%%%%%%%%%%%%
   % start looping over each larva
%%%%%%%%%%%%
for j = 1:length(L.trx)
    dS = L.trx(j).S_deriv_smooth_5; % rate of bending
    velo = L.trx(j).motion_velocity_norm_smooth_5; % velovity
    state = L.trx(j).global_state_large_state; % action performed
    
    sbend = zeros(length(L.trx(j).t),1); % create a new column of action for static bend
    
    limit_dS=prctile(dS,85); % dS threshold for considering head cast VS bend
    limit_velocity=prctile(velo,50); % minimum velocity to classify as head cast
    
    %%%%%%%%%%%%
          % sepatate casting from static bend
    %%%%%%%%%%%%
if separate == 1
    bend = find(state == 2); % find bending events
    if isempty(bend)==0 % if there are bends
        % find different bending events
        if successiveNumbers(bend)==0
            beginend = findSuccessiveNumbers(bend);
        else % if only one period of bend
            beginend=[bend(1) bend(end)];
        end
        repetitionofbend=size(beginend,1);
        
        % redefine the static bend VS head casting
        for repetition=1:repetitionofbend
            for indice=beginend(repetition,1):beginend(repetition,2)
                if abs(dS(indice))<limit_dS
                    state(indice) = 9; % static bend
                end
            end
            
            % reclassify depending on other thresholds
            timeduration = L.trx(j).t(beginend(repetition,2)) - L.trx(j).t(beginend(repetition,1));
            % if event long enough and if static bend in the middle, consider static bend
            if timeduration>=limit_t
                indextolookat=find(state(beginend(repetition,1):beginend(repetition,2))==2);
                indextolookat2=find(state(beginend(repetition,1):beginend(repetition,2))==9);
                if length(indextolookat2)/length(indextolookat)>min(limit_ratio*timeduration,limit_ratiomax)
                    state(beginend(repetition,1):beginend(repetition,2))=9; % static bend
                end
            end
            
            % if event with non null velocity, consider head cast
            mean_velocity=mean(velo(beginend(repetition,1):beginend(repetition,2)));
            if mean_velocity>=limit_velocity
                state(beginend(repetition,1):beginend(repetition,2))=2; % head cast
            end
        end
    end 

ind = find(state == 9);
L.trx(j).cast(ind) = -1;
sbend(ind) = 1;
% retrieve states of behavior for the larva and store in temp
temp = [L.trx(j).t; L.trx(j).run; L.trx(j).cast; L.trx(j).stop; L.trx(j).hunch;...
    L.trx(j).back; L.trx(j).roll; sbend];
else
    temp = [L.trx(j).t; L.trx(j).run; L.trx(j).cast; L.trx(j).stop; L.trx(j).hunch;...
    L.trx(j).back; L.trx(j).roll];
end

% reshape vector into t x action matrix
temp = reshape(temp,[length(L.trx(j).t),length(temp)/length(L.trx(j).t)]);

% instantiate a new matrix for action frequncy for one larva
frequency = zeros(t/(2*dt),action+1);
for i = 1:length(pooled_frequency)
    timestamp = pooled_frequency(i,1);
    [minValue,closestIndex] = min(abs(timestamp-temp(:,1)'));
    % if larva is tracked at that time
    if minValue < dt
    frequency(i,2:action+1) = temp(closestIndex,2:action+1);
    n_active(i) = n_active(i) + 1;
    else
    frequency(i,2:action+1) = 0;
    n_active(i) = n_active(i);
    end
end
frequency(frequency<0)=0;
% update total number of larvae
pooled_frequency = pooled_frequency + frequency;

clear frequency temp j i minValue closestIndex timestamp
end
end
pooled_prob(:,2:action+1) = pooled_frequency(:,2:action+1)./n_active;

if smooth == 1
pooled_prob = smoothdata(pooled_prob,'gaussian',5);
end
clearvars -except pooled_prob pooled_prob_smooth pooled_frequency n n_active
end

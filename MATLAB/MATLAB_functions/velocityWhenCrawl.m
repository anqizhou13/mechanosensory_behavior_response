function [v_mean] = velocityWhenCrawl(directory)

%%%%%%%%%%%%
       % This is a function that takes in path of a directory
       % containing experiments of a specific genotype and
       % protocol, extract the raw trx files, and outputs 
       % two vectors (mean + sd) of larval velocity when the
       % larva is identified as crawling
       
% last modified 3/3/21

% list all trx files
filelist = dir(fullfile(directory, '**/trx.mat')); 
% resolution of counting in s
dt = 0.1;
% total time of experiment in s
t_exp = 250;
% instantiate variables
v_mean = zeros(1,t_exp/(2*dt));
v_std = zeros(1,t_exp/(2*dt));
t_running = 2*dt:2*dt:t_exp;
n_active = zeros(1,t_exp/(2*dt));


%%%%%%%%%%%%
   % start looping over each trx file
%%%%%%%%%%%%
for f = 1:length(filelist)
% load the raw trx file
filepath = strcat(filelist(f).folder,'/',filelist(f).name);
L = load(filepath);

%%%%%%%%%%%%
   % start looping over each larva
%%%%%%%%%%%%
for j = 1:length(L.trx)
    t = L.trx(j).t; % time
    v = L.trx(j).motion_velocity_norm_smooth_5; % velocity
    state = L.trx(j).global_state_large_state; % action performed
    
    % want to extract only the time when certain action is performed
    t = t(find(state == 1)); % find the indices during which larva is crawling
    v = v(find(state == 1));
    
    for i = 1:length(t_running)
    timestamp = t_running(i);
    [minValue,closestIndex] = min(abs(timestamp-t'));
    % if larva is tracked at that time
    if minValue < (dt*2)
        v_temp(i) = v(closestIndex);
        n_active(i) = n_active(i) + 1;
    else
        v_temp(i) = 0;
        n_active(i) = n_active(i);
    end
    end
    
    v_mean = v_mean + v_temp;
    clear v_temp
end 
end
% smooth the data
v_mean = smoothdata(v_mean./n_active,'gaussian',40);
% compute baseline speed and normalize
norm = mean(v_mean(60:250));
%v_mean = v_mean./norm;
end

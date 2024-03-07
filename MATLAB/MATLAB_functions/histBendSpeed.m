function [dS_final, velo_final, asp_final] = histBendSpeed(directory)

%%%%%%%%%%%%
       % This is a function that takes in path of a directory
       % containing experiments of a specific genotype and
       % protocol, and outputs a histogram of bending angles 
       % for visualizing bending dynamics
       
% last modified 4/12/20

% list all TRX files
filelist = dir(fullfile(directory, '**/trx_concatenated.mat')); 
% instantiate number of larvae

%%%%%%%%%%%%
   % start looping over each TRX file
%%%%%%%%%%%%
for f = 1:length(filelist)
% load the raw TRX file
filepath = strcat(filelist(f).folder,'/',filelist(f).name);
L = load(filepath);
% note the number of n for each experiment
dS_all = {};
velo_all = {};
hunch_all = [];

%%%%%%%%%%%%
   % start looping over each larva
%%%%%%%%%%%%
for j = 1:length(L.TRX)
    t = L.TRX(j).t; % time
    dS_temp = L.TRX(j).S_deriv_smooth_5; % rate of bending
    velo_temp = L.TRX(j).motion_velocity_norm_smooth_5; % velocity
    state = L.TRX(j).global_state_large_state; % action performed
    aspect = L.TRX(j).larva_length_deriv_smooth_5; % rate of hunching
    
    % want to extract only the time when certain action is performed
    crawl = t(find(state == 1)); % find the indices during which larva is crawling
    bend = t(find(state == 2)); % same for bending
    hunch = t(find(state == 5)); % same for hunching
    
    % compute average statistics according to stimulus
    dS(j,1) = mean(dS_temp(find(bend<58))); % before initial stimulus
    dS(j,2) = mean(dS_temp(find(bend>60 & bend<90))); % during
    dS(j,3) = mean(dS_temp(find(bend>90 & bend<120))); % after
    
    velo(j,1) = mean(velo_temp(find(crawl<58)));
    velo(j,2) = mean(velo_temp(find(crawl>60 & crawl<90)));
    velo(j,3) = mean(velo_temp(find(crawl>90 & crawl<120)));
    
    hunch_all(j) = mean(aspect(find(t>59 & t<62)));
end
dS_all{f} = dS;
velo_all{f} = velo;
end
dS_final = vertcat(dS_all{:});
velo_final = vertcat(velo_all{:});
asp_final = hunch_all;
end

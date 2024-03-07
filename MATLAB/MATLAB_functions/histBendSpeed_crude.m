function [dS_final, velo_final] = histBendSpeed_crude(directory)

%%%%%%%%%%%%
       % This is a function that takes in path of a directory
       % containing experiments of a specific genotype and
       % protocol, and outputs a histogram of bending angles 
       % for visualizing bending dynamics
       
% last modified 4/12/20

% list all trx files
filelist = dir(fullfile(directory, '**/trx.mat')); 
% instantiate number of larvae

%%%%%%%%%%%%
   % start looping over each trx file
%%%%%%%%%%%%
for f = 1:length(filelist)
% load the raw trx file
filepath = strcat(filelist(f).folder,'/',filelist(f).name);
L = load(filepath);
% note the number of n for each experiment
dS_all = {};
velo_all = {};
hunch_all = [];

%%%%%%%%%%%%
   % start looping over each larva
%%%%%%%%%%%%
for j = 1:length(L.trx)
    t = L.trx(j).t; % time
    dS_temp = L.trx(j).S_deriv_smooth_5; % rate of bending
    velo_temp = L.trx(j).motion_velocity_norm_smooth_5; % velocity
    dS_all{f} = dS_temp;
    velo_all{f} = velo_temp;
end
end
dS_final = vertcat(dS_all{:});
velo_final = vertcat(velo_all{:});
end

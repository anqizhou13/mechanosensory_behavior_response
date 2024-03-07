function [transition_prob] = transMax(directory,win)

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
% time window for counting actions
win = [0,250];
% number of action considered
action = 6;
% instantiate matrix
transition_prob = zeros(action, action);

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
% retrieve states of behavior for the larva and store in temp
temp = [L.trx(j).t; L.trx(j).run; L.trx(j).cast; L.trx(j).stop; L.trx(j).hunch;...
    L.trx(j).back; L.trx(j).roll];
% reshape vector into t x action matrix
temp = reshape(temp,[length(L.trx(j).t),length(temp)/length(L.trx(j).t)]);




clear frequency temp j i minValue closestIndex timestamp
end
end
pooled_prob(:,2:action+1) = pooled_frequency(:,2:action+1)./n;
clearvars -except pooled_prob pooled_frequency n
end

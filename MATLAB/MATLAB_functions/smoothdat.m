function [smoothMean, smoothSEM, smoothSD] = smoothdat(data,t,normalize)

% last modified: 7/11/2020
% this is a function that smooths choreography data by a designated window
% by computing moving average along the window 
% and normalizing by baseline values

% t stands for the # of cells that would be the length on
% either side of the centering point

[row,col] = size(data);
if normalize == 1
% use 25-55s as the range for normalizing values
range = find(data(:,1)>25 & data(:,1)<55);
norm = data(range(1):range(end),:);
% compute normalization factors for each output of choreograph
weights = nanmean(norm,1);

% normalize by baseline values
for j = 2:col
    data(:,j) = data(:,j)./weights(j);
end

clear j
end

for i = 1:row % for each timestamp
    for j = 1:col
    if i < t+1
        smoothMean(i,j) = nanmean(data(1:t+i,j),1);
        smoothSEM(i,j) = std(data(1:t+i,j),1)/sqrt(t+1);
        smoothSD(i,j) = std(data(1:t+i,j),1);
    elseif i > row-t-1
        smoothMean(i,j) = nanmean(data(i-t:end,j),1);
        smoothSEM(i,j) = std(data(i-t:end,j),1)/sqrt(row-i-t);
        smoothSD(i,j) = std(data(i-t:end,j),1);
    else
        smoothMean(i,j) = nanmean(data(i-t:i+t,j),1);
        smoothSEM(i,j) = std(data(i-t:i+t,j),1)/sqrt(2*t+1);
        smoothSD(i,j) = std(data(i-t:i+t,j),1);
    end
end
end

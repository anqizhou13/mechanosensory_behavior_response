function [] = trans_heatmap(directory,control)
% transition analysis
% first open the transition data
% file 'transitions.mat' contains a struct with all the transition matrices
% file 'transitions_data.mat' cpntains metadata for the experiments

map = getPyPlot_cMap('RdBu_r',128);

file = dir(fullfile(directory, '**/transitions.mat'));
file_ctrl = dir(fullfile(control, '**/transitions.mat'));
filepath = strcat(file.folder,'/',file.name);
filepath_ctrl = strcat(file_ctrl.folder,'/',file_ctrl.name);
F = load(filepath);
control = load(filepath_ctrl);

names = fieldnames(F.transitions);
transition = struct2cell(F.transitions);
control = struct2cell(control.transitions);
action = {'Crawl','Bend','Stop','Hunch','Back'};

for i = 1:6
    A = cell2mat(transition(i));
    ctrl = cell2mat(control(i));
    % limit to the first five actions
    A = A(1:5,1:5);
    ctrl = ctrl(1:5,1:5);
    
    % make diagonals of the matrices NaN and exclude from computation
    for z = 1:5
        A(z,z) = 1;
        ctrl(z,z) = 1;
    end
    
    if bitget(i,1) % if the index is odd
        % retrieve total number of transition events
        total = [sum(A,'all','omitnan') sum(ctrl,'all','omitnan')];
        p_table = zeros(5,5);
        % use chi-square to test significance of transition
        for nrow = 1:5
            for ncol = 1:5
                if nrow == ncol
                    p_table(nrow,ncol) = NaN;
                else
                    success = [A(nrow,ncol) ctrl(nrow,ncol)];
                    [h,p] = prop_test(success,total,false);
                    p_table(nrow,ncol) = p;
                end
            end
        end
    dlmwrite(sprintf('transition_pTable_%d.txt',i),p_table)
        
    else % if the index is even
    ratio = log(A./ctrl); % compute ratio of transition probability
    h = figure
    imagesc(ratio)
    colormap(map)
    caxis([-5 5])
    colorbar()
    pbaspect([1 1 1])
    title(""+char(names(i)))
    set(gca,'xtick',1:5,'ytick',1:5,'XTickLabel',action,'YTickLabel',action)
    saveas(h,sprintf('transition_%d.pdf',i))
    clear h figure
    end
end
end


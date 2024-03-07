function actionLarva=backupSequence(adresse)
% backupSequence recognizes backup sequences and right again a different
% action file for each larva.

%% Load data and define variables
dirtrx=[adresse '\trx*.mat'];
load('-mat', dirtrx);
numberoflarvae=length(trx);
actionLarva=struct; % to store the action of the larva over time
stimulus=[60 90]; % time of the stimulation in seconds

% limit fixed between two backup events to consider that it is a whole backup sequence
limite=5; % seconds

couleurs=[
    0    0    0
    1    0    0
    0    1    0
    0    0    1
    0    1    1
    1    1    0
    1    0    1
    0    0.4470    0.7410 % last color to show backup sequences
    ];

%% Scan actions for each larva
for numberlarva=1:numberoflarvae
    larvaname=['larva' num2str(numberlarva)]; % larva number during scan
    actionLarva.(larvaname).name=trx(numberlarva).numero_larva; % larva name in choreography
    actionLarva.(larvaname).t=trx(numberlarva).t; % time course
    actionLarva.(larvaname).action=trx(numberlarva).global_state_large_state; % actions performed
end
% clear trx file that is heavy
clear trx

%% Detect and change backup sequences for each larva, during the stimulus
for numberlarva=1:numberoflarvae
    larvaname=['larva' num2str(numberlarva)]; % larva number during scan
    backup=find(actionLarva.(larvaname).action==5); % find backup events
    if isempty(backup)==0
        
        % find different backup events
        if successiveNumbers(backup)==0
            beginend = findSuccessiveNumbers(backup);
        else % if only one period of backup
            beginend=[backup(1) backup(end)];
        end
        repetitionofbackup=size(beginend,1);
        
        % redefine the backup sequence by combining the different
        % backup events
        for repetition=1:repetitionofbackup-1
            if actionLarva.(larvaname).t(beginend(repetition+1,1))-actionLarva.(larvaname).t(beginend(repetition,2))<=limite
                actionLarva.(larvaname).action(beginend(repetition,2):beginend(repetition+1,1))=8;
            end
        end
        
    end
end

% %% Plot all actions in an ethogram
% 
% figures=figure;
% hold on
% for numberlarva=1:numberoflarvae
%     larvaname=['larva' num2str(numberlarva)]; % larva number during scan
%     y=numberlarva;
%     for timestep=1:length(actionLarva.(larvaname).t)-1
%         i=actionLarva.(larvaname).action(timestep);
%         plot([actionLarva.(larvaname).t(timestep) actionLarva.(larvaname).t(timestep+1)],[y y],'linewidth',70,'color',couleurs(i,:));
%     end
% end
% 
% filename=[adresse '\ethogram'];
% saveas(gcf,[filename '.fig']);
% saveas(gcf,[filename '.png']);
end
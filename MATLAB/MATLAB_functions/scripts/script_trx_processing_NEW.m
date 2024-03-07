%% This scripts extracts the probability, cumulative probability of actions,
% and transitions between actions
% of all larvae from the trx.mat file, during the different time windows

% Statistical test used for comparing cumulative proba (non corrected) :
% Chi2 test

% CHANGE : adresses, timewindows, couleursconditions, conditionstoplot,
% actionstoplot, couleursactions

adresses={
    '/Volumes/eq-NCB/t2/RAL_32@RAL_32/p_5_60s1x30s0s#p_5_120s10x2s8s#n#n/';
    '/Volumes/eq-NCB/t2/RAL_41@RAL_41/p_5_60s1x30s0s#p_5_120s10x2s8s#n#n/';
    '/Volumes/eq-NCB/t2/RAL_93@RAL_93/p_5_60s1x30s0s#p_5_120s10x2s8s#n#n/';
    '/Volumes/eq-NCB/t2/RAL_100@RAL_100/p_5_60s1x30s0s#p_5_120s10x2s8s#n#n/';
    '/Volumes/eq-NCB/t2/RAL_105@RAL_105/p_5_60s1x30s0s#p_5_120s10x2s8s#n#n/';
    '/Volumes/eq-NCB/t2/RAL_109@RAL_109/p_5_60s1x30s0s#p_5_120s10x2s8s#n#n/';
    '/Volumes/eq-NCB/t2/RAL_229@RAL_229/p_5_60s1x30s0s#p_5_120s10x2s8s#n#n/';
    '/Volumes/eq-NCB/t2/RAL_280@RAL_280/p_5_60s1x30s0s#p_5_120s10x2s8s#n#n/';
    '/Volumes/eq-NCB/t2/RAL_303@RAL_303/p_5_60s1x30s0s#p_5_120s10x2s8s#n#n/';
    '/Volumes/eq-NCB/t2/RAL_310@RAL_310/p_5_60s1x30s0s#p_5_120s10x2s8s#n#n/';
    '/Volumes/eq-NCB/t2/RAL_318@RAL_318/p_5_60s1x30s0s#p_5_120s10x2s8s#n#n/';
    '/Volumes/eq-NCB/t2/RAL_320@RAL_320/p_5_60s1x30s0s#p_5_120s10x2s8s#n#n/';
    };

for exp=1:length(adresses)
    
    clearvars -except adresses exp
    % Define the parameters
    
    % !! Important: put all files in a "data" folder (with the "data" name
    % only) contained in the main folder specified by 'adress' below
    adress=char(adresses(exp,:));
    timewindows=[
        15 55
        60 61
        60 62
        60 70 
        60 80
        60 90
        ];
    tfin=150; % change if you have a different duration of experiment
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
    states=["run";"cast";"stop";"hunch";"backup";"roll";"small_actions";
        "backup_sequence";
        "bend_static"
        ];
    
 %% Concatenate trx for all experiments in each genotype
    
    TRX =concatenateTrx(adress);
    
    mkdir(adress, 'dataFiles');
    filename=[adress 'dataFiles/trx_concatenated.mat'];
    save(filename, 'TRX'); % save concatenated trx file
    
 %% Reformat to include bend vs head cast
     
     actionLarva=struct;
   
         actionLarva=headVSbendFromTrx(TRX);
     
     % Add new fields with actions that take into account head cast vs bend
         for larva=1:length(TRX)
             larvaname=['larva' num2str(larva)];
             TRX(larva).global_state_large_state=actionLarva.(larvaname).action;
         end
    
    % Add new fields with actions over time for each action
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
   
       
   %% Extract the cumulative probabilities for the different time windows
       
       cumulativeProbabilities=struct;
       for timewindow=1:numberofwindows
           num1=regexprep(num2str(timewindows(timewindow,1)),'\.','p');
           num2=regexprep(num2str(timewindows(timewindow,2)),'\.','p');
           windowname=['window' num1 's_' num2 's'];
           windowtouse=timewindows(timewindow,:);
               for action=1:length(states)
                   actionname=states(action);
                   [cumulativeProbabilities.(windowname).(actionname).proba, cumulativeProbabilities.(windowname).(actionname).probacontrol, cumulativeProbabilities.(windowname).(actionname).numberoflarvae, cumulativeProbabilities.(windowname).(actionname).numberoflarvaecontrol]=cumulativeFromTrx(TRX,windowtouse,action);
               end
       end
       
       filename=[adress 'dataFiles/cumulativeProbabilities.mat'];
       save(filename, 'cumulativeProbabilities');

       %% Extract amplitudes of action
               allAmplitudes=struct;
       for timewindow = 1:numberofwindows
           allAmplitudes.(windowname)=extractAmplitudesFromTrx(TRX, timewindows);
       end

       filename=[adress 'dataFiles/amplitudes.mat'];
       save(filename, 'allAmplitudes');
              
close all % close all of the figures for better memory performance
end
    
    
    
    
   
function actionLarva=headcastVSbendFromTrx(trx)

numberoflarvae=length(trx);
actionLarva=struct; % to store the action of the larva over time
% limit fixed between two backup events to consider that it is a whole backup sequence
%limit_velocity=0.005; % minimlum velocity to classify as head cast, attP2-40 dataset
limit_velocity=0.006; % minimlum velocity to classify as head cast
limit_hvelocity=0.05; % minimlum head velocity to classify as head cast
limit_t=1; % time threshold in second to consider it as a bend
%limit_ratio=0.4; % ratio of the event defined as static bend (multiplied by time spent), then consider whole action as static bend
%limit_ratiomax=0.6; % maximum ratio accepted to classify as static bend

%% Scan actions for each larva

for numberlarva=1:numberoflarvae
    larvaname=['larva' num2str(numberlarva)]; % larva number during scan
    actionLarva.(larvaname).name=trx(numberlarva).numero_larva_num; % larva name in choreography
    actionLarva.(larvaname).t=trx(numberlarva).t; % time course
    actionLarva.(larvaname).dS=trx(numberlarva).S_deriv_smooth_5; % time course
    actionLarva.(larvaname).action=trx(numberlarva).global_state_large_state; % actions performed
    actionLarva.(larvaname).velocity=trx(numberlarva).motion_velocity_norm_smooth_5; % velocity
    actionLarva.(larvaname).hvelocity=trx(numberlarva).head_velocity_norm_smooth_5; % velocity
end

%% Detect and classify head cast and bend

for numberlarva=1:numberoflarvae
    larvaname=['larva' num2str(numberlarva)]; % larva number during scan
    bend=find(actionLarva.(larvaname).action==2); % find bending events
    
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
            % reclassify depending on other thresholds
            timeduration=actionLarva.(larvaname).t(beginend(repetition,2))-actionLarva.(larvaname).t(beginend(repetition,1));
            % if event long enough and if velocity is small
            if timeduration>=limit_t
                mean_velocity=mean(actionLarva.(larvaname).velocity(beginend(repetition,1):beginend(repetition,2)));
                mean_hvelocity=mean(actionLarva.(larvaname).hvelocity(beginend(repetition,1):beginend(repetition,2)));
                if (mean_velocity<=limit_velocity) && (mean_hvelocity<=limit_hvelocity)
                    actionLarva.(larvaname).action(beginend(repetition,1):beginend(repetition,2))=9; % static bend
                end
                %indextolookat=find(actionLarva.(larvaname).action(beginend(repetition,1):beginend(repetition,2))==2);
                %indextolookat2=find(actionLarva.(larvaname).action(beginend(repetition,1):beginend(repetition,2))==9);
                %if length(indextolookat2)/length(indextolookat)>min(limit_ratio*timeduration,limit_ratiomax)
                    %actionLarva.(larvaname).action(beginend(repetition,1):beginend(repetition,2))=9; % static bend
                %end
            end
            
            % if event with non null velocity, consider head cast
            
            % if event begins and ends with head cast, still consider
%             % static bend
%             if
%             end
        end
    end
end


function actionLarva=headVSbendFromTrx(trx)

%%%%%%%%%%%%
%     a version of separation that focuses on static bend to correct
%     misclassified casts
%%%%%%%%%%%%

numberoflarvae=length(trx);
actionLarva=struct; % to store the action of the larva over time
% limit fixed between two backup events to consider that it is a whole backup sequence
limit_velocity=0.01; % minimlum velocity to classify as head cast, attP2-40 dataset
limit_hvelocity=0.05; % minimlum head velocity to classify as head cast
limit_t=1.5; % time threshold in second to consider it as a bend
%limit_ratio=0.2; % ratio of the event defined as static bend (multiplied by time spent), then consider whole action as static bend
%limit_ratiomax=0.4; % maximum ratio accepted to classify as static bend

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
    bend=find(actionLarva.(larvaname).action==6); % find static bending events
    cast=find(actionLarva.(larvaname).action==2); % find cast events

    %%%%%%%
    %     first correct cast vs run during baseline 
    %%%%%%%
    if isempty(cast)==0 % if there are casts
        % find different casting events
        if successiveNumbers(cast)==0
            beginend = findSuccessiveNumbers(cast);
        else % if only one period of cast
            beginend=[cast(1) cast(end)];
        end
        repetitionofcast=size(beginend,1);
        
        % redefine the cast vs run 
        for repetition=1:repetitionofcast
            % reclassify depending on other thresholds
            timeStart=actionLarva.(larvaname).t(beginend(repetition,1));
            % if cast occurs at the baseline
            if timeStart<=60 
                mean_hvelocity=mean(actionLarva.(larvaname).hvelocity(beginend(repetition,1):beginend(repetition,2)));
                mean_velocity=mean(actionLarva.(larvaname).velocity(beginend(repetition,1):beginend(repetition,2)));
                % if larva center of mass is moving above threshold and if
                % head speed is not high
                if (mean_velocity>=limit_velocity) && (mean_hvelocity<=limit_hvelocity)
                actionLarva.(larvaname).action(beginend(repetition,1):beginend(repetition,2))=1; % correct to run
                end
            end
        end
    end
           
    %%%%%%%
    %     correct cast vs static bend during stimulus 
    %%%%%%%
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
            % if event is short enough and if velocity is small
            if (timeduration<=limit_t ) && (mean_hvelocity>=0.05)
            %if (timeduration<=limit_t )
                actionLarva.(larvaname).action(beginend(repetition,1):beginend(repetition,2))=2; % correct to cast
                %mean_velocity=mean(actionLarva.(larvaname).velocity(beginend(repetition,1):beginend(repetition,2)));
                %mean_hvelocity=mean(actionLarva.(larvaname).hvelocity(beginend(repetition,1):beginend(repetition,2)));
                %if (mean_velocity<=limit_velocity) && (mean_hvelocity<=limit_hvelocity)
                    %actionLarva.(larvaname).action(beginend(repetition,1):beginend(repetition,2))=9; % static bend
                %end
                %indextolookat=find(actionLarva.(larvaname).action(beginend(repetition,1):beginend(repetition,2))==2);
                %indextolookat2=find(actionLarva.(larvaname).action(beginend(repetition,1):beginend(repetition,2))==6);
                %if length(indextolookat2)/length(indextolookat)>min(limit_ratio*timeduration,limit_ratiomax)
                    %actionLarva.(larvaname).action(beginend(repetition,1):beginend(repetition,2))=2; % cast
                %end
            end
           
            % if event with non null velocity, consider head cast
        %mean_velocity=mean(actionLarva.(larvaname).velocity(beginend(repetition,1):beginend(repetition,2)));
                %mean_hvelocity=mean(actionLarva.(larvaname).hvelocity(beginend(repetition,1):beginend(repetition,2)));
                %if (mean_velocity<=limit_velocity) && (mean_hvelocity<=limit_hvelocity)
                    %actionLarva.(larvaname).action(beginend(repetition,1):beginend(repetition,2))=9; % static bend
                %end
            % if event begins and ends with head cast, still consider
%             % static bend
%             if
%             end
        end
    end
end


function [transition_globale, transition_globale_norm, meanNumberOfTransition_per_larva, nb_active, nb_larvae_that_transition, nb_transition_perlarvae, first_transition]=transitionFromTrx(trx, times)

t_init=times(1,1);
t_end=times(1,2);
states=["run";"cast";"stop";"hunch";"back";"roll";"small_actions";"backup_sequence";"bend_static"];

n_trx=length(trx);
n_behaviour=length(states);
transition_globale=zeros(n_behaviour,n_behaviour); % will count the number of transitions from one action to the other
dt_theo=t_end-t_init; % -dt?? % time duration of the window of interest

nb_active=0; % we will increment this number with the active larvae
nb_transition=zeros(n_behaviour,1); % again, we will increment these numbers with the larvae performing the actions
nb_larvae_that_transition=0;
nb_transition_perlarvae=NaN(n_trx,1);
first_transition=NaN(n_trx,2);

for larva=1:n_trx % scan all larvae in trx file
    t_loc=trx(larva).t; % extract the time during which larva is tracked
    % scan if this larva is tracked
    timestracked=find((t_loc>=t_init)&(t_loc<=t_end)); % take all times during which the larva is tracked in the time window
    timestracked_loc=t_loc(timestracked);
    states_loc=trx(larva).global_state_large_state(timestracked);
    if  isempty(states_loc)==0 % if this larva is behaving during the time window defined
        first_transition(larva,1)=states_loc(1,1);
        nb_active=nb_active+1;
        % find the periods of transitions between actions
        transitionstootheraction=find(diff(states_loc)~=0);
        nb_transition_perlarvae(larva,1)=length(transitionstootheraction);
        if isempty(transitionstootheraction)==0 % if there are transitions to other actions
            nb_larvae_that_transition=nb_larvae_that_transition+1;
            transition_globale_loc=zeros(n_behaviour,n_behaviour); % set a matrix that will count the number of transitions
            first_transition(larva,2)=states_loc(transitionstootheraction(1)+1);
            for j=1:length(transitionstootheraction) % for each transition
                action_start=states_loc(transitionstootheraction(j));
                action_end=states_loc(transitionstootheraction(j)+1);
                nb_transition(action_start)=nb_transition(action_start)+1; % increment number of transitions from that action
                transition_globale_loc(action_start,action_end) = transition_globale_loc(action_start, action_end)+1;
            end
            transition_globale=transition_globale+transition_globale_loc;
        else
            first_transition(larva,2)=NaN;
        end
        clear global_state II JJ wi k_start k_end transition_globale_loc;
    else
        nb_transition_perlarvae(larva,1)=NaN;
        first_transition(larva,1)=NaN;
        first_transition(larva,2)=NaN;
    end
end
transition_globale_norm=transition_globale./nb_transition;
meanNumberOfTransition_per_larva=sum(nb_transition)/nb_active;
end
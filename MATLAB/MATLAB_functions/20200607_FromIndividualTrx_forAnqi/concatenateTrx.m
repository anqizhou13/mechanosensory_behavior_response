function trx_concatenated=concatenateTrx(adresse)
% concatenateTrx gets all trx*.mat files contained in subfolders from the
% folder in the 'adresse' field, and concatenates them together.

files   = subdir(fullfile(adresse,'updated_trx_v8*.mat')); % gets address of all trx files
n_files = length(files); % gets number of trx files
timeforkeeping=20; % time threshold for keeping larvae in seconds

for j = 1 : n_files % scan all trx files
    load(files(j).name); % get trx file
    fields = fieldnames(trx);
    % get fieldnames
    ToKeep = {'id';                            
    'numero_larva_num';              
    't';                                               
    'global_state';                  
    'S';                            
    'S_smooth_5';                    
    'S_deriv_smooth_5';              
    'head_velocity_norm_smooth_5';   
    'motion_velocity_norm_smooth_5'; 
    'larva_length_smooth_5';         
    'larva_length_deriv_smooth_5';   
    'global_state_large_state';      
    'global_state_small_large_state'}; % field names to keep
    ToDelete = setxor(fields,ToKeep); % select the fields that are not used
    trx=fRMField(trx, ToDelete); % remove the fields
    
    numberoflarvae=length(trx);
    indicestokeep=[];
    for i=1:numberoflarvae
        if trx(i).t(end)-trx(i).t(1)>=timeforkeeping || trx(i).t(2)-trx(i).t(1)<=0.1
            indicestokeep=[indicestokeep i];
        end
    end
    
    if j==1
        trx_concatenated=trx(indicestokeep); % if first file, create trx_out as a structure that will contain all informations
    else
        trx_concatenated = [trx_concatenated; trx(indicestokeep)]; % if after, concatenate trx files
    end

clear trx
end

%smooth = 0.35; % remove noise by adjusting sampling rate
%fields = fieldnames(trx_concatenated);
%for i=1:length(trx_concatenated)
    %sampling_rate = trx_concatenated(i).t(2)-trx_concatenated(i).t(1);
    %if sampling_rate<=smooth
        %skip = round(smooth/sampling_rate);
        %for j = 1:length(fields)
            % skip vector depending on smoothing factor and sampling rate
            %trx_concatenated(i).(char(fields(j)))=trx_concatenated(i).(char(fields(j)))(1:skip:end,:);
        %end
    %end
%end

end
function run_update_trx_with_labels(varargin)
help_requested = (nargin==0) || ismember(varargin{1}, {'-h', '--help', '-?'});
if help_requested || (nargin<3)
    if ~help_requested
        disp('ERROR: too few input arguments.')
        disp(' ')
    end
    disp('Update trx.mat file with labels from json label file.')
    disp(' ')
    disp('Usage: run_update_trx_with_labels input_trxmat_file input_label_file output_trxmat_file')
    disp('       run_update_trx_with_labels ... --labels comma_separated_list_of_labels_or_label_pairs')
    disp(' ')
    disp('Notes:')
    disp('       The present Matlab function is designed to be compiled with the mcc compiler and used')
    disp('       as a command (e.g. in a shell).')
    disp('       The LD_LIBRARY_PATH environment variable should be defined so that it lists the local')
    disp('       bin and runtime locations for the appropriate Matlab version and system architecture.')
    disp(' ')
    disp('Example:')
    disp('       ./run_update_trx_with_labels path/to/trx.mat path/to/json.label updated_trx.mat \')
    disp("             --labels='crawl=>run,bend=>cast,back-up=>back,small action=>small_motion,stop,hunch'")
else
    args = {};
    k = 4;
    while k<=nargin
        if strcmp(varargin{k}, '--labels')
            k = k + 1;
            labels = strsplit(varargin{k}, ',');
            for i = 1:length(labels)
                label = strsplit(labels{i}, '=>');
                if ~isscalar(label)
                    labels{i} = label;
                end
            end
            args = [args {'labels', labels}];
        elseif strcmp(varargin{k}, '--removetags') || strcmp(varargin{k}, '--remove-tags')
            args = [args {'removetags', 1}];
        else
            error("unsupported argument: " + varargin{k})
        end
        k = k + 1;
    end
    update_trx_with_labels(varargin{1}, varargin{2}, 'outputfile', varargin{3}, args{:});
end
end

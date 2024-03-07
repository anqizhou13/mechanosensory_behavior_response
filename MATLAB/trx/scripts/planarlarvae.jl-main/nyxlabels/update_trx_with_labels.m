function [updated_trx] = update_trx_with_labels(trx, labels_file, varargin)
% UPDATE_TRX_WITH_LABELS  Update trx structure array with json labels.
%
%   TRX = UPDATE_TRX_WITH_LABELS(TRX, LABELS_FILE) loads json-encoded
%     labels from file LABELS_FILE, and add corresponding fields in
%     structure array TRX.
%
%   TRX = UPDATE_TRX_WITH_LABELS(TRX_FILE, LABELS_FILE) loads TRX from file
%     TRX_FILE.
%
%   TRX = UPDATE_TRX_WITH_LABELS(..., "outputfile", OUTPUT_TRX_FILE) saves
%     the updated TRX to file OUTPUT_TRX_FILE.
%
%   TRX = UPDATE_TRX_WITH_LABELS(..., "removetags", 1) removes all known
%     tags from TRX prior to adding tags from LABELS_FILE.
%
%   See also REMOVE_BEHAVIOR_TAGS.

if ~isa(trx, "struct")
    load(trx, "trx");
end

args = struct();
if 2<nargin
    for n = 3:2:nargin
        args.(varargin{n-2}) = varargin{n-1};
    end
end

if isfield(args, "removetags")
    if args.removetags
        trx = remove_behavior_tags(trx);
    end
end

data = jsondecode(fileread(labels_file));
labelnames = data.labels.names;

updated_trx = struct([]);
% backward indexing trick to preallocate the updated_trx array
for k = length(trx):-1:1
    for f = fieldnames(trx)'
        f = f{1};
        updated_trx(k,1).(f) = trx(k).(f);
    end
    tag = -ones(size(trx(k).t));
    for label = labelnames'
        label = label{1};
        updated_trx(k,1).(label) = tag;
    end
end

data = data.data;
for larva = 1:length(data)
    labels = data(larva).labels;
    larvaid = data(larva).id;
    larva = find([trx.numero_larva_num]==str2num(larvaid));
    if isempty(larva)
        disp("skipping larva " + larvaid);
    else
    for label = unique(labels)'
        labelname = labelnames{label};
        field = updated_trx(larva).(labelname);
        field(labels==label) = 1;
        updated_trx(larva).(labelname) = field;
    end
    end
end

if isfield(args, "outputfile")
    trx = updated_trx;
    save(args.outputfile, "trx");
end

end
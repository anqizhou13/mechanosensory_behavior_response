function [trx] = remove_behavior_tags(trx, varargin)
% REMOVE_BEHAVIOR_TAGS  Remove fields from trx structure array known to be
%                       behavior tags.
%
%   TRX = REMOVE_BEHAVIOR_TAGS(TRX) removes tags such as "run", "run_large"
%     etc.
%
%   TRX = REMOVE_BEHAVIOR_TAGS(TRX, TAG1, TAG2, ...) additionally removes
%     trailing TAG1, TAG2, ...

std_tags = [ ...
    "back" "back_large" "back_strong" "back_weak" ...
    "cast" "cast_large" "cast_strong" "cast_weak" ...
    "hunch" "hunch_large" "hunch_strong" "hunch_weak" ...
    "roll" "roll_large" "roll_strong" "roll_weak" ...
    "run" "run_large" "run_strong" "run_weak" ...
    "small_motion" ...
    "stop" "stop_large" "stop_strong" "stop_weak" ...
    ];

for tag = std_tags
    if isfield(trx, tag)
        trx = rmfield(trx, tag);
    end
end

for tag = varargin
    tag = tag{1};
    trx = rmfield(trx, tag);
end

end
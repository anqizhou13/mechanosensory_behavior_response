function [trx] = reset_behavior_tags(trx, varargin)
% RESET_BEHAVIOR_TAGS  RESET behavioral indicators in trx structure array.
%
%   TRX = RESET_BEHAVIOR_TAGS(TRX) resets tags such as "run", "run_large"
%     etc. The corresponding indicators are set to zero.
%
%   TRX = RESET_BEHAVIOR_TAGS(TRX, TAG1, TAG2, ...) additionally resets
%     trailing TAG1, TAG2, ...

std_tags = [ ...
    "back" "back_large" "back_strong" "back_weak" ...
    "cast" "cast_large" "cast_strong" "cast_weak" ...
    "hunch" "hunch_large" "hunch_strong" "hunch_weak" ...
    "roll" "roll_large" "roll_strong" "roll_weak" ...
    "run" "run_large" "run_strong" "run_weak" ...
    "small_motion" ...
    "stop_large" "stop_strong" "stop_weak" ...
    ];

for tag = std_tags
    if isfield(trx, tag)
        for k = 1:numel(trx)
            trx(k).(tag)(:) = 0;
        end
    end
end

for tag = varargin
    tag = tag{1};
    for k = 1:numel(trx)
        trx(k).(tag)(:) = 0;
    end
end

end

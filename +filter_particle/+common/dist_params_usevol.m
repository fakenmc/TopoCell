function params = dist_params_usevol(args)
%DIST_PARAMS_USEVOL Parse useVol parameter for distance filters
%   args - string containing useVol (0 or 1)
% params - parsed 0 or 1

result = textscan(args, '%d');

params = struct('useVol', result{1});

% Check if useVol is 0 or 1
if ((params.useVol ~= 0) && (params.useVol ~= 1))
    error(['Error parsing useVol parameter, must be 0 or 1, "' params.useVol '" given.']);
end;

end % function
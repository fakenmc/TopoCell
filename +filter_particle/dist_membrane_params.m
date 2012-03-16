function params = dist_membrane_params(args)
%DIST_MEMBRANE_PARAMS Parse extra parameters for dist_membrane function
%     args - extra arguments to be parsed
%   params - structure containing parsed arguments

% Only useVol parameter is necessary, use common function to parse it.
params = filter_particle.common.dist_params_usevol(args);

end % function

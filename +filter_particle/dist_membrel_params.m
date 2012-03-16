function params = dist_membrel_params(args)
%DIST_MEMBREL_PARAMS Parse extra parameters for dist_membranerel function
%     args - extra arguments to be parsed
%   params - structure containing parsed arguments

% Only useVol parameter is necessary, use common function to parse it.
params = filter_particle.common.dist_params_usevol(args);

end % function
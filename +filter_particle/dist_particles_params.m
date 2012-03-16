function params = dist_particles_params(args)
%DIST_PARTICLES_PARAMS Parse extra parameters for dist_particles function
%     args - extra arguments to be parsed
%   params - structure containing parsed arguments

% Only useVol parameter is necessary, use common function to parse it.
params = filter_particle.common.dist_params_usevol(args);

end % function
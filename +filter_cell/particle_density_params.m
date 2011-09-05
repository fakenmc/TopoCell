function params = particle_density_params(args)

[particleType, intensDep] = strread(args, '%s %f');

params = struct('particleType', particleType, 'intensDep', intensDep);

% Check if intensDep is 0 or 1
if ((params.intensDep ~= 0) && (params.intensDep ~= 1))
    error(['Error particle_density function parameters: intensDep parameter must be 0 or 1, "' params.intensDep '" given.']);
end;


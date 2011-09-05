function rating = particle_density(dataIn, params)

% Determine maximum intensity
maxIntens = 2^params.bits - 1;

% Determine number of cells
numCells = numel(dataIn.cells);

% Create rating matrix
rating = zeros(numCells, 1);

% Get index of particle being analyzed
particleIndex = -1;
numParticleTypes = numel(dataIn.particleMap);
for idx=1:numParticleTypes
    if strcmp(params.specificParams.particleType, dataIn.particleMap(idx).id)
        particleIndex = idx;
        break;
    end;
end;
if (particleIndex == -1)
    error(['Error in "' params.hvName '" hyper-variable, particle_density function: Unknown particle type "' params.specificParams.particleType '"']);
end;

% Rate cells according to specified particle density
if (params.specificParams.intensDep)
    % Take intensity into account
    for idx=1:numCells
        rating(idx) = (dataIn.cells(idx).P_totint(particleIndex) ...
            / maxIntens) / dataIn.cells(idx).vol;
    end;
else
    % Don't take intensity into account
    for idx=1:numCells
        rating(idx) = dataIn.cells(idx).P_vol(particleIndex) ...
            / dataIn.cells(idx).vol;
    end;
end;





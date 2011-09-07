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

% Cycle through all the cells
for idx=1:numCells
    % Get particle intensity...
    if (particleIndex > 0)
        % ...if specified particle exists in cell
        intensity = dataIn.cells(idx).P_totint(particleIndex);
    else
        % ...otherwise, intensity is zero
        intensity = 0;
    end;
    % Take intensity into account?
    if (params.specificParams.intensDep)
        % Yep, take intensity into account!
        rating(idx) = (intensity / maxIntens) / dataIn.cells(idx).vol;
    else
        % Nop, don't take intensity into account
        rating(idx) = intensity / dataIn.cells(idx).vol;
    end;
end;





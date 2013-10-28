%
% This file is part of TopoCell.
% 
% TopoCell is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by 
% the Free Software Foundation, either version 3 of the License, or 
% (at your option) any later version.
% 
% TopoCell is distributed in the hope that it will be useful, 
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License 
% along with TopoCell. If not, see <http://www.gnu.org/licenses/>.
%

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
        particlesVol = dataIn.cells(idx).P_vol(particleIndex);
        particlesTotInt = dataIn.cells(idx).P_totint(particleIndex);
    else
        % ...otherwise, its volume is zero
        particlesVol = 0;
        particlesTotInt = 0;
    end;
    % Take intensity into account?
    if (params.specificParams.intensDep)
        % Yep, take intensity into account!
        rating(idx) = (particlesTotInt / maxIntens) / dataIn.cells(idx).vol;
    else
        % Nop, don't take intensity into account
        rating(idx) = particlesVol / dataIn.cells(idx).vol;
    end;
end;





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

function rating = dist_particles(dataIn, toFilterIndexes, params)

% Check if exactly two types of particles are selected to filter
if numel(params.filterParticles) ~= 2

    error(['Error in "' params.hvName '" hyper-variable, "dist_particles" function: you must select exactly 2 types of particles to filter (' numel(params.filterParticles) ' types of particles were selected).']);
end;

% Determine number of particles to filter
numParticles = numel(toFilterIndexes);

% Init everything to inf, we'll keep the smaller distance between particles
rating = Inf * ones(numParticles, 1);

% Determine ratings
for i=1:numParticles
    % Use first particle type as reference
    if strcmp(dataIn.particles(toFilterIndexes(i)).type, params.filterParticles{1})
        % For remaining particles ...
        for idx=1:numParticles
            % Check if particle is of second type
            if strcmp(dataIn.particles(toFilterIndexes(idx)).type, params.filterParticles{2})
                % If so, determine distance between particles
                if params.dims == 2 % 2d case
                    vect = [ ...
                        (dataIn.particles(toFilterIndexes(i)).geoC_x - dataIn.particles(toFilterIndexes(idx)).geoC_x) ...
                        (dataIn.particles(toFilterIndexes(i)).geoC_y - dataIn.particles(toFilterIndexes(idx)).geoC_y) ...
                    ];
                elseif params.dims == 3 % 3d case
                    vect = [ ...
                        (dataIn.particles(toFilterIndexes(i)).geoC_x - dataIn.particles(toFilterIndexes(idx)).geoC_x) ...
                        (dataIn.particles(toFilterIndexes(i)).geoC_y - dataIn.particles(toFilterIndexes(idx)).geoC_y) ...
                        (dataIn.particles(toFilterIndexes(i)).geoC_z - dataIn.particles(toFilterIndexes(idx)).geoC_z) ...
                    ];
                end;
                pDist = norm(vect);
                
                % If requested, consider particle volume
                if params.specificParams.useVol == 1
                    iRadius = filter_particle.common.getradius( ...
                        dataIn.particles(toFilterIndexes(i)).vol, ...
                        params.dims ...
                    );
                    idxRadius = filter_particle.common.getradius( ...
                        dataIn.particles(toFilterIndexes(idx)).vol, ...
                        params.dims ...
                    );
                    pDist = pDist - iRadius - idxRadius;
                end;
          
                % Check if distance is smaller than currently set distance
                if pDist < rating(i)
                    rating(i) = pDist;
                end;
                if pDist < rating(idx)
                    rating(idx) = pDist;
                end;
            end;
        end;
    end;
end;
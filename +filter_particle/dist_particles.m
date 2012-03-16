function rating = dist_particles(dataIn, toFilterIndexes, params)

% Check if exactly two types of particles are selected to filter
if numel(params.filterParticles) ~= 2

    error(['Error in "' params.hvName '" hyper-variable, "dist_particles" function: you must select exactly 2 types of particles to filter (' numel(params.filterParticles) ' types of particles were selected).']);
end;

% Determine number of particles to filter
numParticles = numel(toFilterIndexes);

% Create rating matrix
if params.orderCol == 1
    % Smaller distances are privileged, so init everything to inf
    rating = Inf * ones(numParticles, 1);
else
    % Larger distances are previleged, so init everything to zero
    rating = zeros(numParticles, 1);
end;

% Determine ratings
for i=1:numParticles
    % Use first particle type as reference
    if strcmp(dataIn.particles(toFilterIndexes(i)).type, params.filterParticles{1})
        % For remaining particles ...
        for idx=1:numParticles
            % Check if particle is of second type
            if strcmp(dataIn.particles(toFilterIndexes(idx)).type, params.filterParticles{2})
                % If so, determine distance between particles
                vect = [ ...
                    (dataIn.particles(toFilterIndexes(i)).geoC_x - dataIn.particles(toFilterIndexes(idx)).geoC_x) ...
                    (dataIn.particles(toFilterIndexes(i)).geoC_y - dataIn.particles(toFilterIndexes(idx)).geoC_y) ...
                    (dataIn.particles(toFilterIndexes(i)).geoC_z - dataIn.particles(toFilterIndexes(idx)).geoC_z) ...
                ];
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
                
                
                % Check if distance is smaller or bigger than currently
                % set distance
                if params.orderCol == 1
                    % Privilege smaller distances
                    if pDist < rating(i)
                        rating(i) = pDist;
                    end;
                    if pDist < rating(idx)
                        rating(idx) = pDist;
                    end;
                else
                    % Privilege larger distances
                    if pDist > rating(i)
                        rating(i) = pDist;
                    end;
                    if pDist > rating(idx)
                        rating(idx) = pDist;
                    end;
                end;
            end;
        end;
    end;
end;
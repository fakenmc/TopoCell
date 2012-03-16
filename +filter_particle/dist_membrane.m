function rating = dist_membrane(dataIn, toFilterIndexes, params)

% Get particles distance to membrane
rating = cell2mat({dataIn.particles(toFilterIndexes).dist_geoCP_memb})';

% If requested, consider particle volume
if params.specificParams.useVol == 1
    % Ajust distances
    rating = rating - ... 
        filter_particle.common.getradius( ...
            cell2mat({dataIn.particles(toFilterIndexes).vol})', ...
            params.dims ...
        );
end;

end % function
function rating = dist_cc(dataIn, toFilterIndexes, params)

rating = cell2mat({dataIn.particles(toFilterIndexes).dist_geoCP_geoCC})';

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
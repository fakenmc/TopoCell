function rating = dist_membrel(dataIn, toFilterIndexes, params)

distMemb = cell2mat({dataIn.particles(toFilterIndexes).dist_geoCP_memb});
distCC = cell2mat({dataIn.particles(toFilterIndexes).dist_geoCP_geoCC});

% If requested, consider particle volume
if params.specificParams.useVol == 1
    % Get particles radius
    pRadius = filter_particle.common.getradius( ...
        cell2mat({dataIn.particles(toFilterIndexes).vol})', ...
        params.dims ...
    );
    % Ajust distances
    distMemb = distMemb - pRadius;
    distCC = distCC - pRadius;
end;


rating = (distCC ./ (distMemb + distCC))';


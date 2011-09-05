function rating = dist_membrel(dataIn, toFilterIndexes, params)

distMemb = cell2mat({dataIn.particles(toFilterIndexes).dist_geoCP_memb});
distCC = cell2mat({dataIn.particles(toFilterIndexes).dist_geoCP_geoCC});

rating = (distCC ./ (distMemb + distCC))';

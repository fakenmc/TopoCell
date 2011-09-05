function rating = dist_cc(dataIn, toFilterIndexes, params)

rating = cell2mat({dataIn.particles(toFilterIndexes).dist_geoCP_geoCC})';

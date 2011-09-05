function rating = dist_membrane(dataIn, toFilterIndexes, params)

rating = cell2mat({dataIn.particles(toFilterIndexes).dist_geoCP_memb})';
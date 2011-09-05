function rating = volume(dataIn, toFilterIndexes, params)

rating = cell2mat({dataIn.particles(toFilterIndexes).vol})';
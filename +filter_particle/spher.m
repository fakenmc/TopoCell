function rating = spher(dataIn, toFilterIndexes, params)

rating = cell2mat({dataIn.particles(toFilterIndexes).spher})';
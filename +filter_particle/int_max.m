function rating = int_max(dataIn, toFilterIndexes, params)

rating = cell2mat({dataIn.particles(toFilterIndexes).int_max})';
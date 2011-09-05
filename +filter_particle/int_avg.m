function rating = int_avg(dataIn, toFilterIndexes, params)

rating = cell2mat({dataIn.particles(toFilterIndexes).int_avg})';
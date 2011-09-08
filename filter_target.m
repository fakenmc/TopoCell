function dataOut = filter_target( ...
    bits, ...        % Number of intensity bits
    dataIn, ...      % Filtered data
    dataInOrig, ...  % Original data
    target, ...      % Filter target (particle or cell)
    args, ...        % Target function arguments
    hvName ...       % Name of HV
    )

% Get filter function name, and determine respective handler
[filterName, args] = strtok(args);
filterHandler = str2func(['filter_' target '.' filterName]);

% Get selection type and test it
[selectType, args] = strtok(args);
if (~strcmp(selectType, 'tf') && ...
    ~strcmp(selectType, 'to') && ...
    ~strcmp(selectType, 'pf') && ...
    ~strcmp(selectType, 'po'))
    error(['Error in "' hvName '" hyper-variable, "' filterName '" function: selection type must be "tf", "to", "pf" or "po"']);
end;

% Get threshold or percentile reference parameter and test it
[tpRefParam, args] = strtok(args);
refParam = str2double(tpRefParam);
if (isnan(refParam))
   error(['Error in "' hvName '" hyper-variable, "' filterName '" function: reference parameter must be a number, "' tpRefParam '" given.']); 
end;
if strcmp(selectType, 'pf') || strcmp(selectType, 'po')
    if ((refParam > 1) || (refParam < 0))
        error(['Error in "' hvName '" hyper-variable, "' filterName '" function: for "p" (percentile) selection types, reference parameter must be between 0 and 1']);
    end;
end;

% Get order/comparison type and test it
[orderCompare, args] = strtok(args);
if strcmp(selectType, 'tf') || strcmp(selectType, 'to')
    if (~strcmp(orderCompare, 'gt') && ~strcmp(orderCompare, 'lt'))
        error(['Error in "' hvName '" hyper-variable, "' filterName '" function: comparison operators with "t" (threshold) selection types must be "gt" (greater than) or "lt" (less than)']);
    end;
else
    if (~strcmp(orderCompare, 'sup') && ~strcmp(orderCompare, 'inf'))
        error(['Error in "' hvName '" hyper-variable, "' filterName '" function: ordering operators with "p" (percentile) selection types must be "sup" (sort asceding) or "inf" (sort descending)']);
    end;
end;
if strcmp(orderCompare, 'lt') || strcmp(orderCompare, 'inf')
    orderCol = 1;
else
    orderCol = -1;
end;



% Parameters specific for particle filters
if strcmp(target, 'particle')
    % Apply filters to specific particles
    [toFilter, args] = strtok(args);
    filterIdx = 1;
    while true
        [aParticle, toFilter] = strtok(toFilter, ',');
        if isempty(aParticle),  break;  end;
        filterParticles{filterIdx} = aParticle;
        filterIdx = filterIdx + 1;
    end;    
    % Types of particles to filter out
    [excludes, args] = strtok(args);
    excludeIdx = 1;
    while true
        [aParticle, excludes] = strtok(excludes, ',');
        if isempty(aParticle),  break;  end;
        excludeParticles{excludeIdx} = aParticle;
        excludeIdx = excludeIdx + 1;
    end;
else
    filterParticles = [];
    excludeParticles = [];
end;

% Parse remaining specific filter function parameters if specific parser exists
filterParamsHandlerStr = ['filter_' target '.' filterName '_params'];
if exist(['+filter_' target filesep filterName '_params.m']) == 2 
    filterParamsHandler = str2func(filterParamsHandlerStr);    
    params = filterParamsHandler(args);
else
    params = [];
end;

% Create all parameters structure
allParams = struct( ...
    'selectType', selectType, ...
    'refParam', refParam, ...
    'orderCol', orderCol, ...
    'filterParticles', {filterParticles}, ...
    'excludeParticles', {excludeParticles}, ...
    'specificParams', params, ...
    'bits', bits, ...
    'hvName', hvName ...
);

% Create dataOut structure (empty)
dataOut = subjectsData();

% Cycle through all subjects
numSubs = size(dataIn, 2);
for i=1:numSubs
    
    % Copy dataIn headers to dataOut
    dataOut(i).group = dataIn(i).group;
    dataOut(i).subject = dataIn(i).subject;
    dataOut(i).particleMap = dataIn(i).particleMap;
    
    % In case target selection is CELL
    if strcmp(target, 'cell')
        % Select cells to keep according to select type
        if strcmp(selectType, 'tf')
            % Select cells by threshold applied to currently filtered cells
            % For current subject, create table with cell rating 
            ratings = filterHandler(dataIn(i), allParams);
            % Select cells by threshold
            numCells = size(ratings, 1);
            for idx=1:numCells
                % Check if rating is favourably compared against given threshold
                if (comparison(orderCompare, ratings(idx), refParam))
                    % Yep, include cell
                    idxOut = size(dataOut(i).cells, 2) + 1;
                    dataOut(i).cells(idxOut) = dataIn(i).cells(idx);
                end;
            end;
        elseif strcmp(selectType, 'to')
            % Select cells by threshold applied to original data
            % For current subject, create table with cell rating 
            ratings = filterHandler(dataInOrig(i), allParams);
            % Get list of cell IDs in filtered data
            if ~isempty(dataIn(i).cells)
                cellIDs = cell2mat({dataIn(i).cells.id});
            else
                cellIDs = [];
            end;
            % Select cells by threshold IF they exist in filtered data
            numCells = size(ratings, 1);
            for idx=1:numCells
                % Get cell ID
                cellID = dataInOrig(i).cells(idx).id;
                % Check if cell ID exists in filtered data
                if ~isempty(find(cellIDs == cellID))
                    % Yep, perform inclusion test
                    if (comparison(orderCompare, ratings(idx), refParam))
                        % Yep, include cell
                        idxOut = size(dataOut(i).cells, 2) + 1;
                        dataOut(i).cells(idxOut) = dataInOrig(i).cells(idx);
                    end;
                end;
            end;
        elseif strcmp(selectType, 'pf')
            % Select cells by percentile applied to currently filtered cells
            % For current subject, create table with cell rating 
            ratings = filterHandler(dataIn(i), allParams);
            % Add cell index to ratings table
            numCells = size(ratings, 1);
            ratings(:, 2) = (1:numCells)';
            % Sort ratings table according to rating
            ratings = sortrows(ratings, orderCol);
            % How many cells correspond to the given percentile
            numCellsToSelect = floor(refParam * size(ratings, 1));
            % Get indexes of cells within the given percentile
            indexes = ratings(1:numCellsToSelect, 2);
            % Add selected cells to dataout
            for idx=1:numCellsToSelect
                % Include cell
                dataOut(i).cells(idx) = dataIn(i).cells(indexes(idx));
            end;
        elseif strcmp(selectType, 'po')
            % Select cells by percentile applied to original data
            % For current subject, create table with cell rating 
            ratings = filterHandler(dataInOrig(i), allParams);
            % Add cell index to ratings table
            numCells = size(ratings, 1);
            ratings(:, 2) = (1:numCells)';
            % Sort ratings table according to rating
            ratings = sortrows(ratings, orderCol);
            % How many cells correspond to the given percentile
            numCellsToSelect = floor(refParam * size(ratings, 1));
            % Get indexes of cells within the given percentile
            indexes = ratings(1:numCellsToSelect, 2);
            % Get list of cell IDs in filtered data
            if ~isempty(dataIn(i).cells)
                cellIDs = cell2mat({dataIn(i).cells.id});
            else
                cellIDs = [];
            end;
            % Add selected cells to dataout IF they exist in the filtered data
            for idx=1:numCellsToSelect
                % Get cell ID
                cellID = dataInOrig(i).cells(indexes(idx)).id;
                % Check if cell ID exists in filtered data
                if ~isempty(find(cellIDs == cellID))
                    % Yep, include cell
                    idxOut = size(dataOut(i).cells, 2) + 1;
                    dataOut(i).cells(idxOut) = dataInOrig(i).cells(indexes(idx));
                end;
            end;
        end;
    elseif strcmp(target, 'particle')
        % Cycle trough all cells in order to select particles
        numCells = size(dataIn(i).cells, 2);
        for idx=1:numCells
            % Copy cell headers
            dataOut(i).cells(idx).id = dataIn(i).cells(idx).id;
            dataOut(i).cells(idx).vol = dataIn(i).cells(idx).vol;
            dataOut(i).cells(idx).geoC_x = dataIn(i).cells(idx).geoC_x;
            dataOut(i).cells(idx).geoC_y = dataIn(i).cells(idx).geoC_y;
            dataOut(i).cells(idx).geoC_z = dataIn(i).cells(idx).geoC_z;
            dataOut(i).cells(idx).P_totint = dataIn(i).cells(idx).P_totint;
            dataOut(i).cells(idx).P_vol = dataIn(i).cells(idx).P_vol;
            dataOut(i).cells(idx).particles = particlesData();
            % For current cell, select particles to keep according to 
            % select type
            if strcmp(selectType, 'tf')
                % Select cells by threshold applied to currently filtered
                % particles
                numParticles = numel(dataIn(i).cells(idx).particles);
                toFilterIndexes = [];
                % Select particles to rate, exclude specified exclusion
                % particles and auto-include non-mentioned particles
                for index=1:numParticles
                    % Check if particle is to be filtered
                    if ~isempty(find(strcmp(filterParticles, dataIn(i).cells(idx).particles(index).type)))
                        % Yep, this particle is to be filtered
                        toFilterIndexesIdx = numel(toFilterIndexes) + 1;
                        toFilterIndexes(toFilterIndexesIdx, 1) = index;
                    % Check if particle is not to be excluded
                    elseif isempty(find(strcmp(excludeParticles, dataIn(i).cells(idx).particles(index).type)))
                        % Yep, particle is not to be excluded, as such,
                        % include it!
                        idxOut = numel(dataOut(i).cells(idx).particles) + 1;
                        dataOut(i).cells(idx).particles(idxOut) = dataIn(i).cells(idx).particles(index);
                    end;
                end;
                % Create table with particle rating (only for particles to
                % be filtered)
                ratings = filterHandler(dataIn(i).cells(idx), toFilterIndexes, allParams); 
                % Select particles by threshold
                numParticlesToFilter = numel(toFilterIndexes);
                for index=1:numParticlesToFilter
                    % Check if rating is favourably compared against given threshold
                    if comparison(orderCompare, ratings(index), refParam)
                        % Yep, include particle
                        idxOut = numel(dataOut(i).cells(idx).particles) + 1;
                        dataOut(i).cells(idx).particles(idxOut) = dataIn(i).cells(idx).particles(toFilterIndexes(index));
                    end;
                end;
            elseif (strcmp(selectType, 'to'))
                % Select cells by threshold applied to original data
                % Find index of current cell in original data
                origDataCellIndex = find(cell2mat({dataInOrig(i).cells.id}) == dataIn(i).cells(idx).id);
                if isempty(origDataCellIndex)
                    error(['Cell with ID=' dataIn(i).cells(idx).id ' not found in original data of subject "' dataIn(i).subject '"!']);
                end;
                numParticles = numel(dataInOrig(i).cells(origDataCellIndex).particles);
                toFilterIndexes = [];
                 % Get list of particle IDs in filtered data
                if ~isempty(dataIn(i).cells(idx).particles)
                    particleIDs = cell2mat({dataIn(i).cells(idx).particles.id});
                else
                    particleIDs = [];
                end;
                % Select particles to rate, exclude specified exclusion
                % particles and auto-include non-mentioned particles
                for index=1:numParticles
                    % Check if particle is to be filtered
                    if ~isempty(find(strcmp(filterParticles, dataInOrig(i).cells(origDataCellIndex).particles(index).type)))
                        % Yep, this particle is to be filtered
                        toFilterIndexesIdx = numel(toFilterIndexes) + 1;
                        toFilterIndexes(toFilterIndexesIdx, 1) = index;
                    % Check if particle is not to be excluded
                    elseif isempty(find(strcmp(excludeParticles, dataInOrig(i).cells(origDataCellIndex).particles(index).type)))
                        % Yep, particle is not to be excluded, as such, include it if it exists in filtered data!
                        % Get particle ID
                        particleID = dataInOrig(i).cells(origDataCellIndex).particles(index).id;
                        % Check if particle ID exists in filtered data
                        if ~isempty(find(particleIDs == particleID))
                            % Yep, include particle
                            idxOut = numel(dataOut(i).cells(idx).particles) + 1;
                            dataOut(i).cells(idx).particles(idxOut) = dataInOrig(i).cells(origDataCellIndex).particles(index);
                        end;
                    end;
                end;
                % Create table with particle rating (only for particles to
                % be filtered)
                ratings = filterHandler(dataInOrig(i).cells(origDataCellIndex), toFilterIndexes, allParams); 
                % Select particles by threshold
                numParticlesToFilter = numel(toFilterIndexes);
                for index=1:numParticlesToFilter
                    % Check if rating is favourably compared against given threshold
                    if comparison(orderCompare, ratings(index), refParam)
                        % Yep, include particle if it exists in filtered data
                        % Get particle ID
                        particleID = dataInOrig(i).cells(origDataCellIndex).particles(toFilterIndexes(index)).id;
                        % Check if particle ID exists in filtered data
                        if ~isempty(find(particleIDs == particleID))
                            % Yep, include particle
                            idxOut = numel(dataOut(i).cells(idx).particles) + 1;
                            dataOut(i).cells(idx).particles(idxOut) = dataInOrig(i).cells(origDataCellIndex).particles(toFilterIndexes(index));
                        end;
                    end;
                end;
            elseif (strcmp(selectType, 'pf'))
                % Select particles by percentile applied to currently filtered particles
                numParticles = numel(dataIn(i).cells(idx).particles);
                toFilterIndexes = [];
                % Select particles to rate, exclude specified exclusion
                % particles and auto-include non-mentioned particles
                for index=1:numParticles
                    % Check if particle is to be filtered
                    if ~isempty(find(strcmp(filterParticles, dataIn(i).cells(idx).particles(index).type)))
                        % Yep, this particle is to be filtered
                        toFilterIndexesIdx = numel(toFilterIndexes) + 1;
                        toFilterIndexes(toFilterIndexesIdx, 1) = index;
                    % Check if particle is not to be excluded
                    elseif isempty(find(strcmp(excludeParticles, dataIn(i).cells(idx).particles(index).type)))
                        % Yep, particle is not to be excluded, as such,
                        % include it!
                        idxOut = numel(dataOut(i).cells(idx).particles) + 1;
                        dataOut(i).cells(idx).particles(idxOut) = dataIn(i).cells(idx).particles(index);
                    end;
                end;
                % Check if there are particles to rate, if so rate them and
                % possibly add them to data out
                if ~isempty(toFilterIndexes)
                    % Create table with particle rating (only for particles to be filtered)
                    ratings = filterHandler(dataIn(i).cells(idx), toFilterIndexes, allParams); 
                    % Add particle indexes to ratings table
                    ratings(:, 2) = toFilterIndexes;
                    % Sort ratings table according to rating
                    ratings = sortrows(ratings, orderCol);
                    % How many particles correspond to the given percentile
                    numParticlesToSelect = floor(refParam * numel(ratings(:, 1)));
                    % Get indexes of particles within the given percentile
                    indexes = ratings(1:numParticlesToSelect, 2);
                    % Add selected particles to dataout
                    for index=1:numParticlesToSelect
                        % Include particle
                        idxOut = numel(dataOut(i).cells(idx).particles) + 1;
                        dataOut(i).cells(idx).particles(idxOut) = dataIn(i).cells(idx).particles(indexes(index));
                    end;
                end;
            elseif (strcmp(selectType, 'po'))
                % Select particles by percentile applied to original data
                % Find index of current cell in original data
                origDataCellIndex = find(cell2mat({dataInOrig(i).cells.id}) == dataIn(i).cells(idx).id);
                if isempty(origDataCellIndex)
                    error(['Cell with ID=' dataIn(i).cells(idx).id ' not found in original data of subject "' dataIn(i).subject '"!']);
                end;
                numParticles = numel(dataInOrig(i).cells(origDataCellIndex).particles);
                toFilterIndexes = [];
                 % Get list of particle IDs in filtered data
                if ~isempty(dataIn(i).cells(idx).particles)
                    particleIDs = cell2mat({dataIn(i).cells(idx).particles.id});
                else
                    particleIDs = [];
                end;
                % Select particles to rate, exclude specified exclusion
                % particles and auto-include non-mentioned particles
                for index=1:numParticles
                    % Check if particle is to be filtered
                    if ~isempty(find(strcmp(filterParticles, dataInOrig(i).cells(origDataCellIndex).particles(index).type)))
                        % Yep, this particle is to be filtered
                        toFilterIndexesIdx = numel(toFilterIndexes) + 1;
                        toFilterIndexes(toFilterIndexesIdx, 1) = index;
                    % Check if particle is not to be excluded
                    elseif isempty(find(strcmp(excludeParticles, dataInOrig(i).cells(origDataCellIndex).particles(index).type)))
                        % Yep, particle is not to be excluded, as such, include it if it exists in filtered data!
                        % Get particle ID
                        particleID = dataInOrig(i).cells(origDataCellIndex).particles(index).id;
                        % Check if particle ID exists in filtered data
                        if ~isempty(find(particleIDs == particleID))
                            % Yep, include particle
                            idxOut = numel(dataOut(i).cells(idx).particles) + 1;
                            dataOut(i).cells(idx).particles(idxOut) = dataInOrig(i).cells(origDataCellIndex).particles(index);
                        end;
                    end;
                end;
                % Check if there are particles to rate, if so rate them and
                % possibly add them to data out
                if ~isempty(toFilterIndexes)
                    % Create table with particle rating (only for particles to
                    % be filtered)
                    ratings = filterHandler(dataInOrig(i).cells(origDataCellIndex), toFilterIndexes, allParams); 
                    % Add particle index to ratings table
                    ratings(:, 2) = toFilterIndexes;
                    % Sort ratings table according to rating
                    ratings = sortrows(ratings, orderCol);
                    % How many particles correspond to the given percentile
                    numParticlesToSelect = floor(refParam * numel(ratings(:, 1)));
                    % Get indexes of particles within the given percentile
                    indexes = ratings(1:numParticlesToSelect, 2);
                    % Add selected particles to dataout IF they exist in the filtered data
                    for index=1:numParticlesToSelect
                        % Get particle ID
                        particleID = dataInOrig(i).cells(origDataCellIndex).particles(indexes(index)).id;
                        % Check if particle ID exists in filtered data
                        if ~isempty(find(particleIDs == particleID))
                            % Yep, include particle
                            idxOut = numel(dataOut(i).cells(idx).particles) + 1;
                            dataOut(i).cells(idx).particles(idxOut) = dataInOrig(i).cells(origDataCellIndex).particles(indexes(index));
                        end;
                    end;
                end;
            end;
        end;
    else
        error('Filter target must be "cell" or "particle".');
    end;
end;
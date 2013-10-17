%%%%%% Description %%%%%%
%
% This function obtains statistics about a group of specified supervariables
% gathered from a given set of hypervariables.
%
%%%%%% Parameters %%%%%%%
%
% hvs - hypervariables; if a string is given, its considered a filename
% and the hypervariables are loaded from that file; otherwise, hvs is
% directly considered the hypervariables.
% tostat - filename of file containing sv's and respective stats to obtain
%
%%%%% Returns %%%%%%%%%%%
%
% stats - SV relative to particle, cell, subject or group, and respective
% statistics.
%
%%%%%%%%%%%%%%%%%%%%%%%%%
function stats = getstats(hvs, tostat)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Open files                                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Check if hvs is a directory, in which case load hypervariables into a
% proper var.
if ischar(hvs)
    hvdirs = dir(hvs);
    curr_hv = 0;
    % Scan through all dirs (i.e. hypervariables)
    for i=1:numel(hvdirs)
        if hvdirs(i).isdir && (hvdirs(i).name(1) ~= '.')
            % Load subjects
            curr_hv = curr_hv + 1;
            sub_files = dir([hvs filesep hvdirs(i).name filesep '*.mat']);
            for idx=1:numel(sub_files)
                aux = load([hvs filesep hvdirs(i).name filesep sub_files(idx).name]);
                subjectsData(idx) = aux.currentSubject;
            end;
            hvs_tmp{curr_hv} = struct('name', hvdirs(i).name, 'data', subjectsData);
        end;
    end;
    hvs = hvs_tmp;
end;

% Check if tostats file exists
if exist(tostat, 'file') ~= 2
    % File does not exist, throw error and stop execution
    error(['File "' tostat '" not found!']);
end;

% Load tostats info
fileId = fopen(tostat);
% Read file contents, line-by-line
statDefs = struct('hvname', {}, 'svholder', {}, 'svname', {}, 'depth', {}, 'sources', {});
while true
    % Get next line
    tline = fgetl(fileId);
    % If end of file is reached, get out of this loop
    if ~ischar(tline), break, end;
    % If line is a comment, go to next line
    if strncmp('%', strtrim(tline), 1), continue, end;
    % Get hv name
    [hvname, remain] = strtok(tline);
    % If line is empty, get to next line
    if ~numel(hvname), break, end;
    % Get sv holder
    [svholder, remain] = strtok(remain);
    if ~strcmp(svholder, 'cell') && ~strcmp(svholder, 'particle')
        % Invalid container/holder
        error(['Invalid supervariable container "' svholder '". Must be "cell" or "particle".']);
    end;
    % Get sv name
    [svname, remain] = strtok(remain);
    % Get depth
    [depth, remain] = strtok(remain);
    if strcmp(depth, 'particle') && strcmp(svholder, 'cell')
        % Invalid depth to given holder
        error('Invalid depth "particle" to given holder "cell"');
    end;
    if ~strcmp(depth, 'particle') && ~strcmp(depth, 'cell') && ~strcmp(depth, 'subject') && ~strcmp(depth, 'group')
        % Invalid depth
        error(['Invalid depth "' depth '". Depth should be "particle", "cell", "subject" or "group."']);
    end;
    % Get sources
    sources = {};
    while true
        % Get next source
        [source, remain] = strtok(remain);
        if ~numel(source), break, end;
        index = numel(sources) + 1;
        sources{index} = source;
    end;
    % Keep information in a structure
    idx = numel(statDefs) + 1;
    statDefs(idx).hvname = hvname;
    statDefs(idx).svholder = svholder;
    statDefs(idx).svname = svname;
    statDefs(idx).depth = depth;
    statDefs(idx).sources = sources;
end;
% Close file
fclose(fileId);

% Get supervariables and adjust them to given depth (particle, cell,
% subject or group)
numSVs = idx;
numHVs = numel(hvs);
for i=1:numSVs
    %%% Get supervariable
    % Get corresponding hypervariable
    hvFound = 0;
    for idx=1:numHVs
        if strcmp(hvs{idx}.name, statDefs(i).hvname)
            hvFound = 1;
            break;
        end;
    end;
    if ~hvFound
        error(['Hypervariable "' statDefs(i).hvname '" not found!']);
    end;
    hvIndex = idx;
    %%% Gather supervariable
    numSources = numel(statDefs(i).sources);
    rawSV = {};
    groups = {};
    for idx=1:numSources
        [context, ctxValue] = strtok(statDefs(i).sources(idx), ':');
        ctxValue = strtok(ctxValue, ':');
        % Check if source context is group or subject
        if ~strcmp(context, 'g') && ~strcmp(context, 's')
            error(['Invalid context in source "' statDefs(i).sources(idx) '". Must be "g" (group) or "s" (subject).']);
        end;
        % Search for matching source and gather respective supervariable
        totalSubs = numel(hvs{hvIndex}.data);
        for subIndex=1:totalSubs
            if (strcmp(context, 'g') && strcmp(ctxValue, hvs{hvIndex}.data(subIndex).group)) ...
                    || ...
                    (strcmp(context, 's') && strcmp(ctxValue, hvs{hvIndex}.data(subIndex).subject))
                % Subject match (either by group or subject name), gather
                % supervariable
                svIndex = numel(rawSV) + 1;
                rawSV{svIndex} = getRawSV(statDefs(i), hvs{hvIndex}.data(subIndex));
                % Keep group info for current subject
                groups{numel(groups) + 1} = hvs{hvIndex}.data(subIndex).group;
            end;
        end;
    end;
    %%% Adjust supervariable to given depth and get statistics
    sizeSV = numel(rawSV);
    svVector = [];
    if strcmp(statDefs(i).depth, 'particle')
        % particle depth
        for idx=1:sizeSV
            numCells = numel(rawSV{idx});
            for index=1:numCells
                svVector = [svVector rawSV{idx}{index}];
            end;
        end;
    elseif strcmp(statDefs(i).depth, 'cell')
        % cell depth
        for idx=1:sizeSV
            if strcmp(statDefs(i).svholder, 'particle')
                % Particle holder, get means
                numCells = numel(rawSV{idx});
                for index=1:numCells
                    newMean = mean(rawSV{idx}{index});
                    if ~isnan(newMean)
                        svVector = [svVector newMean];
                    end;
                end;
            else
                % Cell holder, direct
                svVector = [svVector rawSV{idx}];
            end;
        end;
    elseif strcmp(statDefs(i).depth, 'subject')
        % Subject depth
        for idx=1:sizeSV
            auxVector = [];
            if strcmp(statDefs(i).svholder, 'particle')
                % Particle holder, get means
                numCells = numel(rawSV{idx});
                for index=1:numCells
                    vectorToAdd = rawSV{idx}{index};
                    if numel(vectorToAdd)
                        auxVector = [auxVector vectorToAdd];
                    end;
                end;
            else
                % Cell holder, direct
                auxVector = rawSV{idx};
            end;
            newMean = mean(auxVector);
            if ~isnan(newMean)
                svVector = [svVector newMean];
            end;
        end;
    elseif strcmp(statDefs(i).depth, 'group')
        % Group depth
        subsVector = [];
        for idx=1:sizeSV
            auxVector = [];
            if strcmp(statDefs(i).svholder, 'particle')
                % Particle holder, get means
                numCells = numel(rawSV{idx});
                for index=1:numCells
                    vectorToAdd = rawSV{idx}{index};
                    if numel(vectorToAdd)
                        auxVector = [auxVector vectorToAdd];
                    end;
                end;
            else
                % Cell holder, direct
                auxVector = rawSV{idx};
            end;
            newMean = mean(auxVector);
            if ~isnan(newMean)
                subsVector = [subsVector mean(auxVector)];
            end;
        end;
        % TODO This
        error('"group"-wise statistics are not yet implemented... sorry!');
    end;
    % Remove NaNs
    svVector = svVector(~isnan(svVector));
    % Create stats data structure
    stats{i} = struct( ...
        'data', svVector, ...
        'numel', numel(svVector), ...
        'mean', mean(svVector), ...
        'median', median(svVector), ...
        'std', std(svVector, 1), ...
        'var', var(svVector, 1), ...
        'stderr', std(svVector, 1) / sqrt(numel(svVector)) ...
    );
end;

fprintf('-----------------------------------------------------------------------------\n');
fprintf('|  Id  |    n   |    Mean   |   Median  | St. dev.  | Variance  | St. err.  |\n');
        %|    1 |      2 | 5.715e+04 | 5.715e+04 | 2.415e+04 | 5.833e+08 | 4.344e+02
fprintf('-----------------------------------------------------------------------------\n');
for i=1:numSVs
    fprintf('| %4d | %6d | %1.3e | %1.3e | %1.3e | %1.3e | %1.3e |\n', i, stats{i}.numel, stats{i}.mean, stats{i}.median, stats{i}.std, stats{i}.var, stats{i}.stderr);
end;
fprintf('-----------------------------------------------------------------------------\n');

function rawSV = getRawSV(statDefs, hvs_data)

if strcmp(statDefs.svholder, 'cell')
    % It's a cell supervariable
    if strncmp(statDefs.svname, 'P_totint', 8) || strncmp(statDefs.svname, 'P_vol', 5)
        % Complex SV with sub-fields
        % Get the svname (without index)
        tmpSvName =  statDefs.svname(1:strfind(statDefs.svname, '(')-1);
        % Get index
        tmpSvNameIdx = statDefs.svname(strfind(statDefs.svname, '(')+1:strfind(statDefs.svname, ')')-1);
        % Determine number of particle types
        tmpRawSV = eval(['hvs_data.cells.' tmpSvName]);
        tmpRawSVSize = size(tmpRawSV, 2);
        % Get data and put it in matrix form
        tmpRawSV = cell2mat(eval(['{hvs_data.cells.' tmpSvName '}']));
        tmpRawSV = vec2mat(tmpRawSV, tmpRawSVSize);
        % Get data for the specified particle types only
        tmpRawSV = eval(['tmpRawSV(:, ' tmpSvNameIdx ')']);
        rawSV = reshape(tmpRawSV, numel(tmpRawSV), 1);
    else
        % Simple SV
        rawSV = cell2mat(eval(['{hvs_data.cells.' statDefs.svname '}']));
    end;
else
    % It's a particle supervariable
    numCells = numel(hvs_data.cells);
    cells = {};
    for cellIndex=1:numCells
        cells{cellIndex} = ...
            cell2mat(eval(['{hvs_data.cells(cellIndex).particles.' statDefs.svname '}']));
    end;
    rawSV = cells;
end;




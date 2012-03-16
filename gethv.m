%%%%%% Description %%%%%%
%
% This function extracts/determines hypervariables from cell/particle     
% information for a given subject/subjects, and saves this information    
% in % a specified directory.
%
%%%%%% Parameters %%%%%%%
%
% bits - Number of bits per channel in image
% dims - Number of dimensions to analyze (2 or 3)
% tsvFolder - Contains cell/particle information files
% hvFolder - Contains hv definitions files
% resultFolder - Where the result files will be outputted
%
%%%%% Returns %%%%%%%%%%%
%
% hv - Vector containing the requested hypervariables
%
%%%%%%%%%%%%%%%%%%%%%%%%%
function hv = gethv(bits, dims, tsvFolder, hvFolder, resultFolder)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Open TSV folder and load cell information %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Define the tab character
tab = char(9);

% Check if TSV folder exists
if ~isdir(tsvFolder)
    % Folder does not exist, throw error and stop execution
    error(['TSV folder "' tsvFolder '" not found!']);
end;

% Get TSV files
tsvFiles = dir([tsvFolder filesep '*.tsv']);

% Count number of subjects
numSubs = size(tsvFiles, 1);

% Initialize individuals structure, containing cells, containing particles
subsData = subjectsData();

% For each subject, get cells and particles data
for i = 1:numSubs
    % Open next TSV file
    fileId = fopen([tsvFolder filesep tsvFiles(i).name]);
    % Get group information
    tline = fgetl(fileId);
    [groupKey, groupName] = strtok(tline, tab);
    if (~strcmp(groupKey, 'Group'))
        error(['Error in "' tsvFiles(i).name '": "Group" keyword not found in 1st line (found "' groupKey '" instead).']);
    end;
    subsData(i).group = strtrim(groupName);
    % Get subject information
    tline = fgetl(fileId);
    [subKey, subName] = strtok(tline, tab);
    if (~strcmp(subKey, 'Subject'))
        error(['Error in "' tsvFiles(i).name '": "Subject" keyword not found in 2nd line.']);
    end;
    subsData(i).subject = strtrim(subName);
    % Get particle map
    tline = fgetl(fileId);
    [pMapKey, pMapRemain] = strtok(tline, tab);
    if (~strcmp(pMapKey, 'ParticleMap'))
        error(['Error in "' tsvFiles(i).name '": "ParticleMap" keyword not found in 3rd line.']);
    end;
    while true
        [pMapId, pMapRemain] = strtok(pMapRemain, tab);
        if isempty(pMapId),  break;  end;
        [pMapName, pMapRemain] = strtok(pMapRemain, tab);
        if isempty(pMapName)
            error(['Error in "' tsvFiles(i).name '": particle map must have an even number of elements!']);  
        end;
        idx = size(subsData(i).particleMap, 2) + 1;
        subsData(i).particleMap(idx).id = pMapId;
        subsData(i).particleMap(idx).name = pMapName;
    end;
    % Import cells and respective particles
    % Get next line, which will have cell information
    tline = fgetl(fileId);
    while true
        % Net cell index
        idx = size(subsData(i).cells, 2) + 1;
        % Get cell Id
        [cellData cellRemain] = strtok(tline, tab);
        subsData(i).cells(idx).id = str2double(cellData(1, 2:size(cellData, 2)));
        % Get cell volume
        [cellData cellRemain] = strtok(cellRemain, tab);
        subsData(i).cells(idx).vol = str2double(cellData);
        % Get cell geometric center x
        [cellData cellRemain] = strtok(cellRemain, tab);
        subsData(i).cells(idx).geoC_x = str2double(cellData);
        % Get cell geometric center y
        [cellData cellRemain] = strtok(cellRemain, tab);
        subsData(i).cells(idx).geoC_y = str2double(cellData);
        % Get cell geometric center z
        [cellData cellRemain] = strtok(cellRemain, tab);
        subsData(i).cells(idx).geoC_z = str2double(cellData);
        % Get particles total intensity and total volume
        idxP = 0;
        while (~isempty(cellRemain))
            idxP = idxP + 1;
            % Get total particle intensity
            [cellData cellRemain] = strtok(cellRemain, tab);
            subsData(i).cells(idx).P_totint(idxP) = str2double(cellData);
            % Get total particle volume
            [cellData cellRemain] = strtok(cellRemain, tab);
            subsData(i).cells(idx).P_vol(idxP) = str2double(cellData);
        end;
        % Get particles
        idxP = 0;
        tline = fgetl(fileId);
        while (ischar(tline) && (~strcmp(tline(1,1), '#')))
            idxP = idxP + 1;
            % Get particle ID
            [partData partRemain] = strtok(tline, tab);
            subsData(i).cells(idx).particles(idxP).id = str2double(partData);
            % Get particle type
            [partData partRemain] = strtok(partRemain, tab);
            subsData(i).cells(idx).particles(idxP).type = partData;
            % Get particle geometric center x
            [partData partRemain] = strtok(partRemain, tab);
            subsData(i).cells(idx).particles(idxP).geoC_x = str2double(partData);
            % Get particle geometric center y
            [partData partRemain] = strtok(partRemain, tab);
            subsData(i).cells(idx).particles(idxP).geoC_y = str2double(partData);
            % Get particle geometric center z
            [partData partRemain] = strtok(partRemain, tab);
            subsData(i).cells(idx).particles(idxP).geoC_z = str2double(partData);
            % Get distance from particle geo. center to cell geo. center
            [partData partRemain] = strtok(partRemain, tab);
            subsData(i).cells(idx).particles(idxP).dist_geoCP_geoCC = str2double(partData);
             % Get distance from particle geo. center to membrane
            [partData partRemain] = strtok(partRemain, tab);
            subsData(i).cells(idx).particles(idxP).dist_geoCP_memb = str2double(partData);
             % Get particle volume
            [partData partRemain] = strtok(partRemain, tab);
            subsData(i).cells(idx).particles(idxP).vol = str2double(partData);
             % Get particle average intensity
            [partData partRemain] = strtok(partRemain, tab);
            subsData(i).cells(idx).particles(idxP).int_avg = str2double(partData);
             % Get particle maximum intensity
            [partData partRemain] = strtok(partRemain, tab);
            subsData(i).cells(idx).particles(idxP).int_max = str2double(partData);
              % Get particle sphericity
            [partData partRemain] = strtok(partRemain, tab);
            subsData(i).cells(idx).particles(idxP).spher = str2double(partData);
            % Get next line
            tline = fgetl(fileId);
        end;
        % If this is the end, bail out
        if (~ischar(tline)), break; end;
    end;
    % Close file
    fclose(fileId);
end;

%hv = subsData;
%return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Open HV definitions folder and load HV definitions %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Check if hypervariable folder exists
if ~isdir(hvFolder)
    % Folder does not exist, throw error and stop execution
    error(['Hyper-variables folder "' hvFolder '" not found!']);
end;

% Get HV files
hvFiles = dir([hvFolder filesep '*.hv.txt']);

% Count number of HV's
numHVs = size(hvFiles, 1);

% Initialize HV definitions structure
hvDefs = struct('name', {}, 'defs', {});
% For each HV file/definition, get target function and remaining arguments
for i = 1:numHVs
    % Initialize current HV definition
    currentHvDef = struct('target', {}, 'args', {});
    % Open next HV file
    fileId = fopen([hvFolder filesep hvFiles(i).name]);
    % Read file contents, line-by-line
    while true
        % Get next line
        tline = fgetl(fileId);
        % If end of file is reached, get out of this loop
        if ~ischar(tline), break, end;
        % If line is a comment, go to next line
        if strncmp('%', strtrim(tline), 1), continue, end;
        % Process line: get function type, function name, selection type and respective parameters
        [target, args] = strtok(tline);
        if ~numel(target), break, end;
        % Keep information in a structure
        idx = size(currentHvDef, 2) + 1;
        currentHvDef(idx).target = target;
        currentHvDef(idx).args = args;
    end;
    % Close file
    fclose(fileId);
    % Save current HV definition in definition structure
    hvDefs(i).name = strtok(hvFiles(i).name, '.');
    hvDefs(i).defs = currentHvDef;
end;

%%%%%%%%%%%%%%%
% Obtain HV's %
%%%%%%%%%%%%%%%

% Main cycle, one loop for each HV to obtain
for i = 1:numHVs
    % Get initial data
    subsDataHV = subsData;
    % Apply functions for this HV
    numOps = size(hvDefs(i).defs, 2);
    for idx = 1:numOps
        % Get target function
        target = hvDefs(i).defs(idx).target;
        % Get target function arguments
        args = hvDefs(i).defs(idx).args;
        % Call target handler function, which will apply the filter
        % function 
        subsDataHV = filter_target( ...
            bits, ...          % Number of intensity bits
            dims, ...          % Number of dimensions (2 or 3)
            subsDataHV, ...    % Filtered data
            subsData, ...      % Original data
            target, ...        % Cell or particle
            args, ...          % Target function arguments
            hvDefs(i).name ... % Name of HV
        );
    end;
    % Keep hypervariable in vector
    hv{i} = struct('name', hvDefs(i).name, 'data', subsDataHV);
end;

%%%%%%%%%%%%%%%%
% Save Results %
%%%%%%%%%%%%%%%%

% Create result directory if it does not exist
if ~isdir(resultFolder)
    mkdir(resultFolder);
end;

% Go through each hv and save it
for i=1:numHVs
    % Create sub-directory for current HV
    if ~isdir([resultFolder filesep hvDefs(i).name])
        mkdir([resultFolder filesep hvDefs(i).name]);
    end;
    % Go through each subject and save it
    numSubjects = size(hv{1}, 2);
    for idx=1:numSubjects
        filename = [resultFolder filesep hvDefs(i).name filesep hv{i}.data(idx).subject '.mat'];
        currentSubject = hv{i}.data(idx);
        save(filename, 'currentSubject');
    end;
end;
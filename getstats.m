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
    % Get sv name
    [svname, remain] = strtok(remain);
    % Get depth
    [depth, remain] = strtok(remain);
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
stats = statDefs;
return;
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
    %%% Gather supervariables
    numSources = numel(statDefs(i).sources);
    rawSV = struct('group', {}, 'subjects', {});
    for idx=1:numSources
        [context, ctxValue] = strtok(statDefs(i).sources(idx), ':');
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
               if strcmp(statDefs(i).svholder, 'cell')
                   % It's a cell supervariable
                   
               elseif strcmp(statDefs(i).svholder, 'particle')
                   % It's a particle supervariable
                    
               else
                   % Invalid container/holder
                   error(['Invalid supervariable container "' statDefs(i).svholder '". Must be "cell" or "particle".']);
               end;
            end;
        end;
    end;
    %%% Adjust them to given depth
    
end;
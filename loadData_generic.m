function dataStruct = loadData_generic(filepath, template)
% Generic loader that interprets a template describing:
% - field aliases
% - fallbacks
% - scaling rules
% - special extract/segment/redo logic
% MA

% here load
S = load(filepath);
dataStruct = struct();

%% ------------------------------------------------------------
% MULTI-CONTRACT (TRAP_multi)
%% ------------------------------------------------------------
if isfield(template.special, 'segment')
    dataStruct = template.special.segment(S);
    return
end

%% ------------------------------------------------------------
% MULTI-CHANNEL (TRAP multi-channel)
%% ------------------------------------------------------------
if isfield(template.special, 'extract')
    dataStruct = template.special.extract(S);
end

%% ------------------------------------------------------------
% STANDARD FIELD RESOLUTION
%% ------------------------------------------------------------
fieldNames = fieldnames(template.fields);

for ii = 1:numel(fieldNames)
    key = fieldNames{ii};
    aliases = template.fields.(key);

    % Skip if special extractor already populated this field
    if isfield(dataStruct, key)
        continue
    end

    % Find matching alias in S
    match = find(isfield(S, aliases), 1);

    if ~isempty(match)
        dataStruct.(key) = S.(aliases{match});
    else
        % Use fallback
        if isfield(template.fallbacks, key)
            dataStruct.(key) = template.fallbacks.(key)(S);
        else
            dataStruct.(key) = [];
        end
    end
end

%% ------------------------------------------------------------
% SAMPLING FREQUENCY
%% ------------------------------------------------------------
if isfield(S,'SamplingFrequency')
    dataStruct.fs = S.SamplingFrequency;
elseif isfield(S,'fsamp')
    dataStruct.fs = S.fsamp;
elseif isfield(template.fallbacks,'fs')
    dataStruct.fs = template.fallbacks.fs(S);
else
    dataStruct.fs = 2000;
end

%% ------------------------------------------------------------
% TIME 
%% ------------------------------------------------------------
if isfield(S,'Time')
    if iscell(S.Time)
        dataStruct.Time = S.Time{1};
    else
        dataStruct.Time = S.Time;
    end
elseif isfield(template.fallbacks,'Time')
    dataStruct.Time = template.fallbacks.Time(S);
else
    dataStruct.Time = [];
end

%% ------------------------------------------------------------
% DESCRIPTION
%% ------------------------------------------------------------
if isfield(S,'Description')
    dataStruct.Description = S.Description;
end

%% ------------------------------------------------------------
% SCALING 
%% ------------------------------------------------------------
scaleNames = fieldnames(template.scaling);

for ii = 1:numel(scaleNames)
    key = scaleNames{ii};

    if isfield(dataStruct, key) && ~isempty(dataStruct.(key))
        dataStruct.(key) = template.scaling.(key)( ...
            dataStruct.(key), ...
            dataStruct.Force ...
            );
    end
end

%% ------------------------------------------------------------
% SPECIAL: RAW FORCE (Derby)
%% ------------------------------------------------------------
if isfield(template.special,'RawForce') && template.special.RawForce
    dataStruct.RawForce = dataStruct.Force;
end

end

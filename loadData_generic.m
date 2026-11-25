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
A = forceAliases();
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
% This bit is really key
% Based on the template, it unpacks the file 
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
        val = S.(aliases{match});
        if strcmp(key,'Force') && isnumeric(val) && min(size(val)) > 1
            error('Force is a %dx%d matrix. For multi-channel files set Mode = Multi Channel.', size(val,1), size(val,2));
        end
        % make sure data is vectorized
        if isnumeric(val) || islogical(val)
            val = val(:);
        end
        dataStruct.(key) = val;
        %dataStruct.(key) = S.(aliases{match});
    else
        if isfield(template.fallbacks, key)
            val = template.fallbacks.(key)(S);
            if isnumeric(val) || islogical(val)
                val = val(:);
            end
            dataStruct.(key) = val;
        else
            dataStruct.(key) = [];
        end
    end
end

if isfield(dataStruct,'Force') && isempty(dataStruct.Force)
    error('No force variable found. Looked for: %s', strjoin(A.Force, ', '));
end

%% ------------------------------------------------------------
% SAMPLING FREQUENCY
%% ------------------------------------------------------------

fsk = find(isfield(S, A.fs), 1);
if isfield(dataStruct,'fs') && ~isempty(dataStruct.fs)
    % already set by special.extract
elseif ~isempty(fsk)
    dataStruct.fs = S.(A.fs{fsk});
elseif isfield(template.fallbacks,'fs')
    dataStruct.fs = template.fallbacks.fs(S);
else
    dataStruct.fs = 2000;
end

% 
% if isfield(dataStruct,'fs') && ~isempty(dataStruct.fs)
%     % already set by special.extract — leave it alone
% elseif isfield(S,'SamplingFrequency')
%     dataStruct.fs = S.SamplingFrequency;
% elseif isfield(S,'fsamp')
%     dataStruct.fs = S.fsamp;
% elseif isfield(template.fallbacks,'fs')
%     dataStruct.fs = template.fallbacks.fs(S);
% else
%     dataStruct.fs = 2000;
% end

%% ------------------------------------------------------------
% TIME 
%% ------------------------------------------------------------
if isfield(dataStruct,'Time') && ~isempty(dataStruct.Time)
    % already set by special.extract — leave it alone
elseif isfield(S,'Time')
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

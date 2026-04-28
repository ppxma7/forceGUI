function template = template_single()

template.type = "single";

% Only use aliases for simple cases
template.fields = struct( ...
    'Force',  {{'Force','Torque','F','ref_signal','FORCE'}}, ...
    'Acq',    {{'Acq','Acquisition'}}, ...
    'Perf',   {{'Perf','Performance'}}, ...
    'Target', {{'Target','requested','Desired'}} ...
    );

template.fallbacks = struct( ...
    'Force',  @(S) [], ...
    'Acq',    @(S) [], ...
    'Perf',   @(S) [], ...
    'Target', @(S) [], ...
    'fs',     @(S) [], ...
    'Time',   @(S) [] ...
    );

template.scaling = struct( ...
    'Target', @(t,f) scaleTarget(t,f) ...
    );

% NEW: special extractor for MCON / legacy TRAP
template.special = struct( ...
    'extract', @extractSingle ...
    );

end

function dataStruct = extractSingle(S)

% --- CASE 1: S.Data exists (MCON or legacy TRAP) ---
if isfield(S,'Data')

    likelyForce  = 65;
    likelyAcq    = 66;
    likelyPerf   = 67;
    likelyTarget = 68;

    if iscell(S.Data)
        block = S.Data{1};
        dataStruct.Force  = block(:,1);
        if size(block,2) >= 2, dataStruct.Acq    = block(:,2); end
        if size(block,2) >= 3, dataStruct.Perf   = block(:,3); end
        if size(block,2) >= 4, dataStruct.Target = block(:,4); end

    else
        dataStruct.Force  = S.Data(:,likelyForce);
        dataStruct.Acq    = S.Data(:,likelyAcq);
        dataStruct.Perf   = S.Data(:,likelyPerf);
        dataStruct.Target = S.Data(:,likelyTarget);
    end

    % --- CASE 2: Newer files with named fields ---
elseif ~isfield(S,'Data')
    dataStruct = struct();
    return


% else % last ditch backup
% 
%     dataStruct = struct();
% 
%     if isfield(S,'Force'),  dataStruct.Force  = S.Force;  end
%     if isfield(S,'Acq'),    dataStruct.Acq    = S.Acq;    end
%     if isfield(S,'Perf'),   dataStruct.Perf   = S.Perf;   end
%     if isfield(S,'Target'), dataStruct.Target = S.Target; end
end

% --- Scaling ---
if isfield(dataStruct,'Target') && ~isempty(dataStruct.Target)
    dataStruct.Target = scaleTarget(dataStruct.Target, dataStruct.Force);
end

% --- Time ---
if isfield(S,'Time')
    if iscell(S.Time)
        dataStruct.Time = S.Time{1};
    else
        dataStruct.Time = S.Time;
    end
else
    dataStruct.Time = [];
end

% --- Sampling frequency ---
if isfield(S,'SamplingFrequency')
    dataStruct.fs = S.SamplingFrequency;
else
    dataStruct.fs = 2000;
end

% --- Description ---
if isfield(S,'Description')
    dataStruct.Description = S.Description;
end
end





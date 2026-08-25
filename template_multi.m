function template = template_multi()

template.type = "multi";

% Only Data is needed; everything else is handled in extractMulti
template.fields = struct( ...
    'Data', {{'Data'}} ...
    );

% template.fallbacks = struct( ...
%     'Data', @(S) error('Multi-channel file missing Data') ...
%     );

template.fallbacks = struct( ...
    'Data', @(S) [] ...   % new files won't have Data; extractMulti handles it
    );

template.scaling = struct();   % scaling handled inside extractMulti

template.special = struct( ...
    'extract', @extractMulti ...
    );

end


%%
function dataStruct = extractMulti(S)

% --- Resolve Data block ---

if isfield(S, 'Force')
    % New format: Force directly in S (7×60000)
    forceData = S.Force';          % transpose to 60000×7
    targetVec = [];
    if isfield(S, 'Target')
        targetVec = S.Target(:);
    end
elseif isfield(S, 'Data')

    if iscell(S.Data)
        forceData  = S.Data{1};
    elseif isstruct(S.Data)
        forceData  = S.Data;
    else
        error('Unexpected format for S.Data');
    end
    targetVec = [];
else
    error('extractMulti: Cannot resolve force data from file');
end


% if iscell(S.Data)
%     test = S.Data{1};
% elseif isstruct(S.Data)
%     test = S.Data;
% else
%     error('Unexpected format for S.Data');
% end

figure('Position',[100 0 1200 600])
%tiledlayout(4,3)
tiledlayout('flow')
nCols = size(forceData, 2);
for ii = 1:nCols
    nexttile
    plot(forceData(:,ii))
    title(sprintf('Ch %d', ii))
end

%% --- Extract channels ---
if isfield(S, 'Force')
    % New 7-channel format (raw only, cols 1-3)
    dataStruct.ForceL  = forceData(:,1);
    dataStruct.ForceR  = forceData(:,2);
    dataStruct.ForceBi = forceData(:,3);
    % cols 4-6 are MVC-normalised — skip 
    
    % Target: column 7 or separate Target variable
    if ~isempty(targetVec)
        dataStruct.Target = targetVec;
    elseif nCols >= 7
        dataStruct.Target = forceData(:,7);
    else
        error('No target found');
    end
    
    % MVC scaling for target
    if isfield(S, 'mvc_value') && ~isempty(S.mvc_value)
        mvc = S.mvc_value;
        dataStruct.TargetL  = dataStruct.Target * mvc;   
        dataStruct.TargetR  = dataStruct.Target * mvc;
        dataStruct.TargetBi = dataStruct.Target * mvc;
    else
        keyboard % dont think we need this
        dataStruct.TargetL  = scaleTarget(dataStruct.Target, dataStruct.ForceL);
        dataStruct.TargetR  = scaleTarget(dataStruct.Target, dataStruct.ForceR);
        dataStruct.TargetBi = scaleTarget(dataStruct.Target, dataStruct.ForceBi);
    end

    % Acq/Perf not present in new format — leave empty
    dataStruct.AcqL = []; dataStruct.AcqR = []; dataStruct.AcqBi = [];
    dataStruct.PerfL = []; dataStruct.PerfR = []; dataStruct.PerfBi = [];

else

    % --- Extract channels ---
    dataStruct.ForceL  = forceData(:,1);
    dataStruct.ForceR  = forceData(:,2);
    dataStruct.ForceBi = forceData(:,3);
    dataStruct.AcqL    = forceData(:,4);
    dataStruct.AcqR    = forceData(:,7);
    dataStruct.AcqBi   = forceData(:,10);
    dataStruct.PerfL   = forceData(:,5);
    dataStruct.PerfR   = forceData(:,8);
    dataStruct.PerfBi  = forceData(:,11);



    % --- Target detection ---
    targCols = find(contains(S.Description, 'requested'));
    if isempty(targCols)
        disp('No target columns found... continuing...');
    else
        candidateTargets = forceData(:, targCols);
        %colHasData = any(candidateTargets ~= 0, 1);
        colHasData = logical(std(candidateTargets)); % do this instead - looks for variation in signal, not just if its zero
        correctIdx = targCols(find(colHasData, 1));

        if isempty(correctIdx)
            disp('No valid target column found... continuing...');
        else
            dataStruct.Target  = forceData(:, correctIdx);
            dataStruct.TargetL  = scaleTarget(dataStruct.Target, dataStruct.ForceL);
            dataStruct.TargetR  = scaleTarget(dataStruct.Target, dataStruct.ForceR);
            dataStruct.TargetBi = scaleTarget(dataStruct.Target, dataStruct.ForceBi);
        end
    end

end
% --- Time vector ---
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
elseif isfield(S,'signal') && isfield(S.signal,'fsamp')
    dataStruct.fs = S.signal.fsamp;
else
    dataStruct.fs = 2000;
end

% --- Description ---
if isfield(S,'Description')
    dataStruct.Description = S.Description;
end
end


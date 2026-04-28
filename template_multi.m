function template = template_multi()

template.type = "multi";

% Only Data is needed; everything else is handled in extractMulti
template.fields = struct( ...
    'Data', {{'Data'}} ...
    );

template.fallbacks = struct( ...
    'Data', @(S) error('Multi-channel file missing Data') ...
    );

template.scaling = struct();   % scaling handled inside extractMulti

template.special = struct( ...
    'extract', @extractMulti ...
    );

end


%%
function dataStruct = extractMulti(S)

% --- Resolve Data block ---
if iscell(S.Data)
    test = S.Data{1};
elseif isstruct(S.Data)
    test = S.Data;
else
    error('Unexpected format for S.Data');
end

figure('Position',[100 0 1200 600])
tiledlayout(4,3)
for ii = 1:size(test,2)
    nexttile
    plot(test(:,ii))
end

% --- Extract channels ---
dataStruct.ForceL  = test(:,1);
dataStruct.ForceR  = test(:,2);
dataStruct.ForceBi = test(:,3);

dataStruct.AcqL = test(:,4);
dataStruct.AcqR = test(:,7);
dataStruct.AcqBi = test(:,10);

dataStruct.PerfL = test(:,5);
dataStruct.PerfR = test(:,8);
dataStruct.PerfBi = test(:,11);

% --- Target detection ---
targCols = find(contains(S.Description, 'requested'));
candidateTargets = test(:, targCols);
colHasData = any(candidateTargets ~= 0, 1);
correctIdx = targCols(find(colHasData, 1));

if isempty(correctIdx)
    error('No valid target column found.');
end

dataStruct.Target = test(:, correctIdx);

% --- Target scaling ---
dataStruct.TargetL  = scaleTarget(dataStruct.Target, dataStruct.ForceL);
dataStruct.TargetR  = scaleTarget(dataStruct.Target, dataStruct.ForceR);
dataStruct.TargetBi = scaleTarget(dataStruct.Target, dataStruct.ForceBi);

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
else
    dataStruct.fs = 2000;
end

% --- Description ---
if isfield(S,'Description')
    dataStruct.Description = S.Description;
end
end


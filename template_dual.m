function template = template_dual()
% For Nikki canapi data that is multi channel but only two channels (L and
% R)

template.type = "dual";
template.fields = struct('Data', {{'Data'}});
template.fallbacks = struct('Data', @(S) error('Dual-channel file missing Data'));
template.scaling = struct();
template.special = struct('extract', @extractDual);
end

%%
function dataStruct = extractDual(S)
% --- Resolve Data block ---
if iscell(S.Data)
    test = S.Data{1};
elseif isstruct(S.Data)
    test = S.Data;
else
    error('Unexpected format for S.Data');
end

% --- Extract channels ---
dataStruct.ForceL = test(:,1);
dataStruct.ForceR = test(:,2);


% --- Target detection ---
% targCols = find(contains(S.Description, 'requested'));
% candidateTargets = test(:, targCols);
% colHasData = any(candidateTargets ~= 0, 1);
% correctIdx = targCols(find(colHasData, 1));
% if isempty(correctIdx)
%     disp('No valid target found.');
%     % will be empty
%     dataStruct.Target = test(:, correctIdx);
% else
%     % --- Target scaling ---
%     dataStruct.TargetL = scaleTarget(dataStruct.Target, dataStruct.ForceL);
%     dataStruct.TargetR = scaleTarget(dataStruct.Target, dataStruct.ForceR);
%     dataStruct.Target = test(:, correctIdx);
% 
% end


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
if isfield(S, 'Description')
    dataStruct.Description = S.Description;
end
end
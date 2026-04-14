function Data = loadData_multiContract(filepath)

% Load file
S = load(filepath);

if isfield(S,'Data')
    dataStruct.Force  = S.Data{1}(:,1);
    dataStruct.Acq    = S.Data{1}(:,2);
    dataStruct.Perf   = S.Data{1}(:,3);
    dataStruct.Target = S.Data{1}(:,4);
    dataStruct.fs = S.SamplingFrequency; 
    dataStruct.Description = S.Description;

 
    
    % temporary
    force = dataStruct.Force;
    fs = dataStruct.fs;

    target = dataStruct.Target;


elseif ~isfield(S,'Data')
    % Find the force channel automatically
    fn = fieldnames(S);
    ch = fn{contains(fn, 'Ch1')};   % or refine if needed
    F = S.(ch);
    % Extract raw force
    force = F.values;
    fs = 1 / F.interval;
else
    error('woah, cant find the force in the struct')
end

% check for negative signal
if all(force <= 0)
    force = force - min(force);
end

% chek for target
hasTarget = isfield(S,'Data') && size(S.Data{1},2) >= 4;
if hasTarget
    target = target - min(target);
    target = scaleTarget(target, force);
end


% Filter
forceFilt = lpbutter(force, 20, fs);

% 1. Detect plateau
thresh = 0.2 * max(forceFilt);
above = forceFilt > thresh;

minDuration = round(5.0 * fs);
plateauMask = bwareaopen(above, minDuration);
regions = bwconncomp(plateauMask);

baseline = 0.1 * max(forceFilt); % if this is too low, then it might fail to cut properly! 
padding  = round(0.5 * fs);   % 0.5 seconds of extra tail

figure
hold on
for ii = 1:regions.NumObjects
    idx = regions.PixelIdxList{ii};
    plateauStart = min(idx);
    plateauEnd   = max(idx);
    % Expand left
    startIdx = plateauStart;
    while startIdx > 1 && forceFilt(startIdx) > baseline
        startIdx = startIdx - 1;
    end
    % Expand right
    endIdx = plateauEnd;
    while endIdx < length(forceFilt) && forceFilt(endIdx) > baseline
        endIdx = endIdx + 1;
    end

    % --- Add padding on both sides ---
    startIdx = max(1, startIdx - padding);
    endIdx   = min(length(forceFilt), endIdx + padding);

    % Store
    Data(ii).Start = startIdx;
    Data(ii).PlateauStart = plateauStart;
    Data(ii).PlateauEnd = plateauEnd;
    Data(ii).End = endIdx;

    Data(ii).Force     = force(startIdx:endIdx);
    Data(ii).ForceFilt = forceFilt(startIdx:endIdx);
    Data(ii).Time      = (0:(endIdx-startIdx))' / fs;
    Data(ii).fs        = fs;

    if hasTarget
        Data(ii).Target = target(startIdx:endIdx);
    end

    plot(Data(ii).Force)
    legend


end

figure, plot(forceFilt)

end
function template = template_multiContract()

template.type = "multiContract";

template.fields = struct( ...
    'Data', {{'Data'}} ...
    );

template.fallbacks = struct( ...
    'Data', @(S) [], ...
    'fs',   @(S) getfield(S,'SamplingFrequency',[]), ...
    'Time', @(S) [] ...
    );

template.scaling = struct( ...
    'Target', @(t,f) scaleTarget(t,f) ...
    );

template.special = struct( ...
    'segment', @segmentMultiContract ...
    );

end

function Data = segmentMultiContract(S)

% This is your full segmentation logic from loadData_multiContract
% (unchanged, just wrapped)
% I will paste it exactly as-is:

if isfield(S,'Data')
    force  = S.Data{1}(:,1);
    target = S.Data{1}(:,4);
    fs = S.SamplingFrequency;
else
    fn = fieldnames(S);
    ch = fn{contains(fn, 'Ch1')};
    F = S.(ch);
    force = F.values;
    fs = 1 / F.interval;
    target = [];
end

if all(force <= 0)
    force = force - min(force);
end

hasTarget = ~isempty(target);

if hasTarget
    target = target - min(target);
    target = scaleTarget(target, force);
end

forceFilt = lpbutter(force, 20, fs);

thresh = 0.2 * max(forceFilt);
above = forceFilt > thresh;

minDuration = round(5.0 * fs);
plateauMask = bwareaopen(above, minDuration);
regions = bwconncomp(plateauMask);

baseline = 0.1 * max(forceFilt);
padding  = round(0.5 * fs);


figure
hold on

for ii = 1:regions.NumObjects
    idx = regions.PixelIdxList{ii};
    plateauStart = min(idx);
    plateauEnd   = max(idx);

    startIdx = plateauStart;
    while startIdx > 1 && forceFilt(startIdx) > baseline
        startIdx = startIdx - 1;
    end

    endIdx = plateauEnd;
    while endIdx < length(forceFilt) && forceFilt(endIdx) > baseline
        endIdx = endIdx + 1;
    end

    startIdx = max(1, startIdx - padding);
    endIdx   = min(length(forceFilt), endIdx + padding);

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

function dataStruct = loadData(filepath)
    S = load(filepath);

    % need some checks in case
    % dont like this
    likelyForce = 65;
    likelyAcq = 66;
    likelyPerf = 67;
    likelyTarget = 68;

    if iscell(S.Data)
        dataStruct.Force  = S.Data{1}(:,1);
        dataStruct.Acq    = S.Data{1}(:,2);
        dataStruct.Perf   = S.Data{1}(:,3);
        dataStruct.Target = S.Data{1}(:,4);
    elseif ~iscell(S.Data)
        dataStruct.Force  = S.Data(:,likelyForce);
        dataStruct.Acq    = S.Data(:,likelyAcq);
        dataStruct.Perf   = S.Data(:,likelyPerf);
        dataStruct.Target = S.Data(:,likelyTarget);
    end

    dataStruct.Target = scaleTarget(dataStruct.Target, dataStruct.Force);

    
    if ~iscell(S.Time)
        dataStruct.Time   = S.Time;
    else
        dataStruct.Time   = S.Time{1};
    end

    if isfield(S,'SamplingFrequency')
        dataStruct.fs = S.SamplingFrequency;
    else
        dataStruct.fs = 2000; % or read from file if available
    end
    dataStruct.Description = S.Description;
end
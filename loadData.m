function dataStruct = loadData(filepath)
    S = load(filepath);

    dataStruct.Force  = S.Data{1}(:,1);
    dataStruct.Acq    = S.Data{1}(:,2);
    dataStruct.Perf   = S.Data{1}(:,3);
    dataStruct.Target = S.Data{1}(:,4);

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
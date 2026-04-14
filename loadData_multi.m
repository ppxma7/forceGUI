function dataStruct = loadData_multi(filepath)
    S = load(filepath);

    %% sanity check
    %test = S.Data{1};

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
        title([num2str(ii) '-' S.Description{ii}])
    end
    %%

    
    dataStruct.ForceL   = S.Data{1}(:,1);
    dataStruct.ForceR   = S.Data{1}(:,2);
    dataStruct.ForceBi  = S.Data{1}(:,3);

    dataStruct.AcqL     = S.Data{1}(:,4);
    dataStruct.AcqR     = S.Data{1}(:,7);
    dataStruct.AcqBi    = S.Data{1}(:,10);

    dataStruct.PerfL    = S.Data{1}(:,5);
    dataStruct.PerfR    = S.Data{1}(:,8);
    dataStruct.PerfBi   = S.Data{1}(:,11);
    
    % need to be defensive here cause sometimes it's not 12

    targCols = find(contains(S.Description, 'requested'));
    candidateTargets = S.Data{1}(:, targCols);
    colHasData = any(candidateTargets ~= 0, 1);
    correctIdx = targCols(find(colHasData, 1));
    if isempty(correctIdx)
        error('No valid target column found.');
    end
    dataStruct.Target = S.Data{1}(:, correctIdx);

    % cant i scale it here?
    dataStruct.TargetL = scaleTarget(dataStruct.Target, dataStruct.ForceL);
    dataStruct.TargetR = scaleTarget(dataStruct.Target, dataStruct.ForceR);
    dataStruct.TargetBi = scaleTarget(dataStruct.Target, dataStruct.ForceBi);

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
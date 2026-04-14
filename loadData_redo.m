function dataStruct = loadData_redo(filepath)
    S = load(filepath);   % <-- return EVERYTHING
    S.alreadyProcessed = true;

    % we need a check for older analysed data that hasnt been
    % analysed using my app

    if isfield(S,'startMax')
        dataStruct.Segments.Ramp1 = [S.startMin S.stopMin];
        dataStruct.Segments.Ramp2 = [S.startMax S.stopMax];
        dataStruct.Segments.Plateau = [S.stopMin+1 S.startMax-1];

        if isfield(S,'force_trace_filtered')
            dataStruct.PerfFilt = S.force_trace_filtered;
            dataStruct.Data.Force = S.force_trace_unfiltered;
        else
            error('cant find correct force variable')
        end


        dataStruct.forcewave = dataStruct.PerfFilt(dataStruct.Segments.Plateau(1):dataStruct.Segments.Plateau(2));



        if isfield(S,'fs')
            dataStruct.Data.fs = S.fs;
        else
            dataStruct.Data.fs = 2048;
            disp('just using 2048')
        end

    else
        % load everything
        dataStruct = S;

    end


end

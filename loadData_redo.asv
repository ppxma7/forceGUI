function dataStruct = loadData_redo(filepath)
    S = load(filepath);
    S.alreadyProcessed = true;

    % --- Alias lists (add new variable names here) ---
    forceFilteredAliases = {'force_trace_filtered', 'ForceFiltered', 'ForceFilt', 'PerfFilt'};
    forceRawAliases      = {'force_trace_unfiltered', 'Force', 'Torque', 'Perf'};

    if isfield(S,'startMax')
        dataStruct.Segments.Ramp1   = [S.startMin S.stopMin];
        dataStruct.Segments.Ramp2   = [S.startMax S.stopMax];
        dataStruct.Segments.Plateau = [S.stopMin+1 S.startMax-1];

        % --- Legacy exact-match first (preserves original behaviour) ---
        if isfield(S,'force_trace_filtered')
            dataStruct.PerfFilt   = S.force_trace_filtered;
            dataStruct.Data.Force = S.force_trace_unfiltered;

        elseif isfield(S,'PerfFilt')  % MCON
            dataStruct.PerfFilt       = S.PerfFilt;
            dataStruct.Data.Force     = S.Perf;
            dataStruct.Data.Target    = S.Target;
            dataStruct.TargetFilt     = S.TargetFilt;
            dataStruct.targetwave     = dataStruct.TargetFilt( ...
                dataStruct.Segments.Plateau(1):dataStruct.Segments.Plateau(2));

        else
            % --- Flexible alias fallback for new data ---
            filtMatch = find(isfield(S, forceFilteredAliases), 1);
            rawMatch  = find(isfield(S, forceRawAliases), 1);

            if ~isempty(filtMatch)
                dataStruct.PerfFilt = S.(forceFilteredAliases{filtMatch});
            else
                error('Cannot find filtered force variable');
            end

            if ~isempty(rawMatch)
                dataStruct.Data.Force = S.(forceRawAliases{rawMatch});
            else
                error('Cannot find raw force variable');
            end

            % --- Target (optional) ---
            if isfield(S,'Target')
                dataStruct.Data.Target = S.Target;
                dataStruct.TargetFilt  = S.TargetFilt;
                dataStruct.targetwave  = dataStruct.TargetFilt( ...
                    dataStruct.Segments.Plateau(1):dataStruct.Segments.Plateau(2));
            end
        end

        dataStruct.forcewave = dataStruct.PerfFilt( ...
            dataStruct.Segments.Plateau(1):dataStruct.Segments.Plateau(2));

        % --- fs ---
        if isfield(S,'fs')
            dataStruct.Data.fs = S.fs;
        else
            dataStruct.Data.fs = 2048;
            disp('just using 2048')
        end

    else
        dataStruct = S;
    end
end
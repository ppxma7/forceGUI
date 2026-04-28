function template = template_redo()

template.type = "redo";

template.fields = struct();  % redo files are arbitrary

template.fallbacks = struct( ...
    'fs', @(S) [], ...
    'Time', @(S) [] ...
    );

template.scaling = struct();

template.special = struct( ...
    'redo', @redoExtractor ...
    );

end

function dataStruct = redoExtractor(S)

if isfield(S,'startMax')
    dataStruct.Segments.Ramp1 = [S.startMin S.stopMin];
    dataStruct.Segments.Ramp2 = [S.startMax S.stopMax];
    dataStruct.Segments.Plateau = [S.stopMin+1 S.startMax-1];

    if isfield(S,'force_trace_filtered')
        dataStruct.PerfFilt = S.force_trace_filtered;
        dataStruct.Data.Force = S.force_trace_unfiltered;

    elseif isfield(S,'PerfFilt')
        dataStruct.PerfFilt = S.PerfFilt;
        dataStruct.Data.Force = S.Perf;
        dataStruct.Data.Target = S.Target;
        dataStruct.TargetFilt = S.TargetFilt;
        dataStruct.targetwave = dataStruct.TargetFilt(dataStruct.Segments.Plateau(1):dataStruct.Segments.Plateau(2));

    else
        error('Cannot find correct force variable');
    end

    dataStruct.forcewave = dataStruct.PerfFilt(dataStruct.Segments.Plateau(1):dataStruct.Segments.Plateau(2));

    if isfield(S,'fs')
        dataStruct.Data.fs = S.fs;
    else
        dataStruct.Data.fs = 2048;
    end

else
    dataStruct = S;
end
end

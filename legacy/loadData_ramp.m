function dataStruct = loadData_ramp(filepath)

S = load(filepath);

dataStruct.Force  = S.ref_signal(:);
dataStruct.Target = [];
dataStruct.fs = S.fsamp;
dataStruct.Description = S.description;


end
function dataStruct = loadData_derby(filepath)

    S = load(filepath);

    % FORCE is a single vector
    force = S.FORCE(:);   % ensure column

    dataStruct.Force   = force;   % treat as performance trace
    dataStruct.Target = [];      % no target
    dataStruct.fs     = 2048;    % fixed sampling rate

    % Store raw for calibration
    dataStruct.RawForce = force;
end
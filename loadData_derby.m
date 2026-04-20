function dataStruct = loadData_derby(filepath)

    S = load(filepath);

    if isfield(S,'Data')
        test = S.Data{1};
        force = test(:,66); % very bad magic numbering, consequence of export from OTLab. Will likely break

    else
        force = S.FORCE(:);  
    end
    % elseif isstruct(S.Data)
    %     test = S.Data;
    % else
    %     error('Unexpected format for S.Data');
    % end

    % FORCE is a single vector
    %force = S.FORCE(:);   % ensure column

    dataStruct.Force   = force;   % treat as performance trace
    dataStruct.Target = [];      % no target
    dataStruct.fs     = 2048;    % fixed sampling rate

    % Store raw for calibration
    dataStruct.RawForce = force;
end
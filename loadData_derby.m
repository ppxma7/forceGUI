function dataStruct = loadData_derby(filepath)

S = load(filepath);

likelyChannel = 66;

if isfield(S,'Data')
    if iscell(S.Data)
        test = S.Data{1};
        force = test(:,likelyChannel);
    else
        force = S.Data(:,likelyChannel);
    end
else
    force = S.FORCE(:);
end

dataStruct.Force   = force;   % treat as performance trace
dataStruct.Target = [];      % no target
dataStruct.fs     = 2048;    % fixed sampling rate

% Store raw for calibration
dataStruct.RawForce = force;
end
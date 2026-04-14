function [perfCal, targetCal] = calibrateDerby(perfRaw, targetRaw, analysisMode, Calib)
    % Derby Chair uses fixed scaling

    scale = Calib.derby.scale;

    %scale = 0.1823;

    perfCal = perfRaw * scale;

    if strcmp(analysisMode, 'MCON')
        targetCal = targetRaw * scale;
    else
        % TRAP Derby Chair has no target
        targetCal = [];
    end
end
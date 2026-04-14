function [forceN, targetN] = calibrateTRAP(raw, rig, channel, targetRaw, Calib)

    rig     = lower(rig);
    channel = lower(channel);

    % --- ANKLE: linear regression (M + b) ---
    if strcmp(rig, 'ankle')

        % Extract calibration values from table
        M = Calib.ankle.(capitalize(channel)).M;
        b = Calib.ankle.(capitalize(channel)).b;

        switch channel
            case 'left'
                forceN  = ((raw - b) / M) * 9.81;
                targetN = ((targetRaw - b) / M) * 9.81;

            case 'right'
                forceN  = ((raw - b) / M) * 9.81;
                targetN = ((targetRaw - b) / M) * 9.81;

            case 'bilateral'
                % Left
                ML = Calib.ankle.Left.M;
                bL = Calib.ankle.Left.b;
                forceL  = ((raw(:,1) - bL) / ML) * 9.81;
                targetL = ((targetRaw - bL) / ML) * 9.81;

                % Right
                MR = Calib.ankle.Right.M;
                bR = Calib.ankle.Right.b;
                forceR  = ((raw(:,2) - bR) / MR) * 9.81;
                targetR = ((targetRaw - bR) / MR) * 9.81;

                forceN  = forceL + forceR;
                targetN = targetL + targetR;
        end

        return
    end

    % --- OTHER RIGS: simple scale factor ---
    scaleL = Calib.(rig).Left.scale;
    scaleR = Calib.(rig).Right.scale;

    switch channel
        case 'left'
            forceN  = raw * scaleL * 9.81;
            targetN = targetRaw * scaleL * 9.81;

        case 'right'
            forceN  = raw * scaleR * 9.81;
            targetN = targetRaw * scaleR * 9.81;

        case 'bilateral'
            forceN  = (raw(:,1) * scaleL + raw(:,2) * scaleR) * 9.81;
            targetN = (targetRaw * scaleL + targetRaw * scaleR) * 9.81;
    end
end

% Helper to capitalise field names
function s = capitalize(str)
    s = lower(str);
    s(1) = upper(s(1));
end
function [forceN, targetN] = calibrateTRAP(raw, rig, channel, targetRaw)

    rig = lower(rig);
    channel = lower(channel);

    switch rig
        case 'ankle'
            leftM  = 0.0938;    leftb  = 0.0206;
            rightM = 0.1282;    rightb = 0.027019;

            switch channel
                case 'left'
                    forceN  = ((raw - leftb) / leftM) * 9.81;
                    targetN = ((targetRaw - leftb) / leftM) * 9.81;

                case 'right'
                    forceN  = ((raw - rightb) / rightM) * 9.81;
                    targetN = ((targetRaw - rightb) / rightM) * 9.81;

                case 'bilateral'
                    % raw is [L R]
                    forceL  = ((raw(:,1) - leftb)  / leftM)  * 9.81;
                    forceR  = ((raw(:,2) - rightb) / rightM) * 9.81;
                    forceN  = forceL + forceR;

                    % targetRaw is a single vector → apply BOTH calibrations then sum
                    targetL = ((targetRaw - leftb)  / leftM)  * 9.81;
                    targetR = ((targetRaw - rightb) / rightM) * 9.81;
                    targetN = targetL + targetR;
            end

        case 'hand'
            scaleL = 1.070;
            scaleR = 1.070;

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

        case 'knee'
            scaleL = 11;
            scaleR = 19.6;

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

        case 'arm'
            scaleL = 21.2;
            scaleR = 10.7;

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

        otherwise
            error('Unknown TRAP rig type.');
    end
end
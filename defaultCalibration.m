function Calib = defaultCalibration()
% DEFAULTCALIBRATION
% Users can edit this file to update calibration values for their rig.
% Do not change the structure names.

    % --- ANKLE (linear regression: M and b) ---
    Calib.ankle.Left.M  = 0.0938;
    Calib.ankle.Left.b  = 0.0206;

    Calib.ankle.Right.M = 0.1282;
    Calib.ankle.Right.b = 0.027019;

    % --- HAND (simple scale factor) ---
    Calib.hand.Left.scale  = 1.070;
    Calib.hand.Right.scale = 1.070;

    % --- KNEE ---
    Calib.knee.Left.scale  = 11;
    Calib.knee.Right.scale = 19.6;

    % --- ARM ---
    Calib.arm.Left.scale   = 21.2;
    Calib.arm.Right.scale  = 10.7;

     % --- DERBY CHAIR ---
    % Single scale factor for both TRAP and MCON
    %Calib.derby.scale = 0.1823;
    Calib.derby.scale = 208;

end
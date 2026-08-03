function [mvcBi, mvcL, mvcR, idx] = computeBilateralMVC(tmpAppData, rig, Calib, cutoff)
% Computes MVC_Bilat, MVC_L, MVC_R using the bilat peak index for L/R

ForceL = tmpAppData.ForceL;
ForceR = tmpAppData.ForceR;

% need to filter here otherwise get different numbers
forceL_filt   = lpbutter(ForceL, cutoff, tmpAppData.fs);
forceR_filt   = lpbutter(ForceR, cutoff, tmpAppData.fs);

% Calibrate each channel independently
[forceL_cal, ~] = calibrateTRAP(forceL_filt, rig, 'left', [], Calib);
[forceR_cal, ~] = calibrateTRAP(forceR_filt, rig, 'right', [], Calib);
[forceBi_cal, ~] = calibrateTRAP([forceL_filt, forceR_filt], rig, 'bilateral', [], Calib);

% Bilat peak + its index
[mvcBi, idx] = max(forceBi_cal);

% L and R at that SAME index (not their own peaks)
mvcL = forceL_cal(idx);
mvcR = forceR_cal(idx);

% debugging:
fprintf('L peak: %.4f, R peak: %.4f, L MVC from Bi MVC index: %.4f, L MVC from Bi MVC index: %.4f\n',max(forceL_cal), max(forceR_cal), mvcL, mvcR)

end
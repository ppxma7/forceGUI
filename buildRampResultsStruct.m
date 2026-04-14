function S = buildRampResultsStruct(code, M)
% code = app.Code
% M    = metrics from computeRampStuff

S = struct();

% Identifier
S.Code = code;

% --- Up ramp metrics ---
S.Up_SD = M.up.sd;
S.Up_RMSE = M.up.rmse;
S.Up_RMSE_Norm = M.up.rmse_norm;

% --- Down ramp metrics ---
S.Down_SD = M.down.sd;
S.Down_RMSE = M.down.rmse;
S.Down_RMSE_Norm = M.down.rmse_norm;

% Printout (mirrors TRAP style)
fprintf('\nRamp Metrics:\n');

fprintf('  Up Ramp SD:        %.4f\n',   S.Up_SD);
fprintf('  Up Ramp RMSE:      %.4f\n',   S.Up_RMSE);
fprintf('  Up Ramp RMSE normalized:      %.4f\n', S.Up_RMSE_Norm);

fprintf('  Down Ramp SD:        %.4f\n', S.Down_SD);
fprintf('  Down Ramp RMSE:      %.4f\n', S.Down_RMSE);
fprintf('  Down Ramp RMSE normalized:        %.4f\n', S.Down_RMSE_Norm);

end
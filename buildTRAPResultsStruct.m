function S = buildTRAPResultsStruct(code, M)
% code = app.Code
% M    = metrics from computeTRAP

S = struct();

% Identifier
S.Code = code;

% Steady-state metrics
S.SteadyMean = M.steady_mean;
S.SteadySTD  = M.steady_std;
S.SteadyCoV  = M.steady_CoV;

% Lowest CoV windows
S.CoV5s = M.CoV_5s;
S.CoV2s = M.CoV_2s;

% Min–max scaled CoV
S.ScaledCoV = M.ScaledCoV;

% CoV minus first 1 second
S.CoVminus1 = M.CoV_minus1;

% Yank metrics
S.MeanYank = M.mean_yank;
S.RMSYank  = M.RMS_yank;

% Complexity metrics
S.ApEn   = M.ApEn;
S.SampEn = M.SampEn;
S.DFA57  = M.DFA57_alpha;

% Force range
S.MinForce = M.minForce;
S.MaxForce = M.maxForce;

fprintf('\nTRAP Metrics:\n');
fprintf('  SteadyMean: %.3f\n', M.steady_mean);
fprintf('  SteadySTD:  %.3f\n', M.steady_std);
fprintf('  SteadyCoV:  %.3f %%\n', M.steady_CoV);
fprintf('  CoV5s:      %.3f %%\n', M.CoV_5s);
fprintf('  CoV2s:      %.3f %%\n', M.CoV_2s);
fprintf('  ScaledCoV:  %.3f %%\n', M.ScaledCoV);
fprintf('  CoVminus1:  %.3f %%\n', M.CoV_minus1);
fprintf('  MeanYank:   %.3f\n', M.mean_yank);
fprintf('  RMSYank:    %.3f\n', M.RMS_yank);
fprintf('  ApEn:       %.3f\n', M.ApEn);
fprintf('  SampEn:     %.3f\n', M.SampEn);
fprintf('  DFA57:      %.3f\n', M.DFA57_alpha);
fprintf('  MinForce:   %.3f N\n', M.minForce);
fprintf('  MaxForce:   %.3f N\n', M.maxForce);


end
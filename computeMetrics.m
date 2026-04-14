function metrics = computeMetrics(forcewave, targetwave, extra)

if nargin<3
    extra = [];
end

% Cross-correlation lag
[cross_corr, lags] = xcorr(targetwave, forcewave);
[~, max_index] = max(abs(cross_corr));
metrics.lag = lags(max_index);

% Correlation coefficient
metrics.corr = corr(targetwave(:), forcewave(:));

% Absolute error
err = abs(forcewave - targetwave);

% AUC
metrics.AUC = trapz(err);

% Normalised AUC
metrics.normAUC = metrics.AUC / length(targetwave);

% Store error signal too (useful for plotting)
metrics.errorSignal = err;

if ~isempty(extra)
    % Extract plateau indices
    idx1 = extra.segment(1);
    idx2 = extra.segment(2);

    % Extract raw L/R
    L = extra.LeftRaw(idx1:idx2);
    R = extra.RightRaw(idx1:idx2);

    % Filter them (same cutoff as GUI)
    cutoff = extra.cutoff;
    fs     = extra.fs;

    Lf = lpbutter(L, cutoff, fs);
    Rf = lpbutter(R, cutoff, fs);

    % Cross-correlation
    [xc, lags] = xcorr(Lf, Rf);
    [~, iMax]  = max(abs(xc));

    metrics.LRlag  = lags(iMax);
    metrics.LRcorr = corr(Lf(:), Rf(:));
end


end
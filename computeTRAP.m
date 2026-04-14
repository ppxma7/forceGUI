function metrics = computeTRAP(forceFilt, fs)
% forceFilt = filtered force segment (app.forcewave)
% fs        = sampling frequency

    % ----------------------------
    % Remove first 1 second
    % ----------------------------
    samples_to_remove = fs * 1;
    if length(forceFilt) > samples_to_remove
        full_minus_1s = forceFilt(samples_to_remove+1:end);
    else
        full_minus_1s = forceFilt;
    end

    % ----------------------------
    % Lowest CoV windows (5s and 2s)
    % ----------------------------
    window_times = [5, 2];
    window_sizes = window_times * fs;

    lowest_cov_data = cell(1, numel(window_sizes));

    for w = 1:numel(window_sizes)
        window_size = window_sizes(w);

        if length(forceFilt) < window_size
            lowest_cov_data{w} = [];
            continue;
        end

        num_segments = length(forceFilt) - window_size + 1;
        cov_values = zeros(1, num_segments);

        for j = 1:num_segments
            window_data = forceFilt(j:j+window_size-1);
            cov_values(j) = std(window_data) / mean(window_data) * 100;
        end

        [~, min_index] = min(cov_values);
        lowest_cov_data{w} = forceFilt(min_index:min_index+window_size-1);
    end

    % ----------------------------
    % Min–max scaled CoV
    % ----------------------------
    minForce = min(forceFilt);
    maxForce = max(forceFilt);

    if maxForce > minForce
        scaledForce = (forceFilt - minForce) / (maxForce - minForce);
        scaledCoV = (std(scaledForce) / mean(scaledForce)) * 100;
    else
        scaledCoV = NaN;
    end

    metrics.ScaledCoV = scaledCoV;
    metrics.minForce  = minForce;
    metrics.maxForce  = maxForce;

    % ----------------------------
    % CoV minus first 1 second
    % ----------------------------
    if length(full_minus_1s) > 2
        mean_minus1 = mean(full_minus_1s);
        std_minus1  = std(full_minus_1s);
        CoV_minus1  = (std_minus1 / mean_minus1) * 100;
    else
        mean_minus1 = NaN;
        std_minus1  = NaN;
        CoV_minus1  = NaN;
    end

    metrics.mean_minus1 = mean_minus1;
    metrics.std_minus1  = std_minus1;
    metrics.CoV_minus1  = CoV_minus1;

    % ----------------------------
    % Steady-state stats
    % ----------------------------
    metrics.steady_mean = mean(forceFilt);
    metrics.steady_std  = std(forceFilt);
    metrics.steady_CoV  = (metrics.steady_std / metrics.steady_mean) * 100;

    % 5s window
    if ~isempty(lowest_cov_data{1})
        metrics.mean_5s = mean(lowest_cov_data{1});
        metrics.std_5s  = std(lowest_cov_data{1});
        metrics.CoV_5s  = metrics.std_5s / metrics.mean_5s * 100;
    else
        metrics.mean_5s = NaN;
        metrics.std_5s  = NaN;
        metrics.CoV_5s  = NaN;
    end

    % 2s window
    if ~isempty(lowest_cov_data{2})
        metrics.mean_2s = mean(lowest_cov_data{2});
        metrics.std_2s  = std(lowest_cov_data{2});
        metrics.CoV_2s  = metrics.std_2s / metrics.mean_2s * 100;
    else
        metrics.mean_2s = NaN;
        metrics.std_2s  = NaN;
        metrics.CoV_2s  = NaN;
    end

    % ----------------------------
    % Yank (derivative)
    % ----------------------------
    dt = 1/fs;
    Yank = diff(forceFilt) / dt;
    Yank = [Yank(1); Yank];

    metrics.mean_yank = mean(abs(Yank));
    metrics.RMS_yank  = sqrt(mean(Yank.^2));

    % ----------------------------
    % Entropy & DFA (downsampled)
    % ----------------------------
    ds_factor = 20;
    force_ds = downsample(forceFilt, ds_factor);

    m = 2; r = 0.1;
    [ApEn, SampEn] = calc_entropy(force_ds, m, r);

    metrics.ApEn   = ApEn;
    metrics.SampEn = SampEn;

    min_scale  = 4;
    max_scale  = round(length(force_ds)/4);
    num_scales = 20;

    [~, ~, ~, alpha57, ~, ~] = DFA(force_ds, min_scale, max_scale, num_scales);
    metrics.DFA57_alpha = alpha57;
end
function [alpha, F, n_vals, alpha57, F57, n_vals57] = DFA(signal, min_scale, max_scale, num_scales)

    % Detrended Fluctuation Analysis (DFA) scaling exponent
    % Includes no specified box size (DFA), and specified as 57 (DFA57) as
    % per previous pubs

    % Inputs:
    %   signal - Input time series (1D vector)
    %   min_scale - Minimum window size for DFA (e.g., 4)
    %   max_scale - Maximum window size for DFA (e.g., length(signal)/4)
    %   num_scales - Number of scales to analyze (e.g., 20)
    %
    % Outputs:
    %   alpha - DFA scaling exponent using user-defined num_scales
    %   F - Fluctuation function values for num_scales
    %   n_vals - Window sizes used for num_scales
    %   alpha57 - DFA scaling exponent using exactly 57 log-spaced box sizes
    %   F57 - Fluctuation function values for 57 box sizes
    %   n_vals57 - Window sizes used for DFA57

    % Ensure signal is a column vector
    signal = signal(:);
    N = length(signal);

    % Step 1: Compute Integrated Profile
    mean_signal = mean(signal);
    profile = cumsum(signal - mean_signal);

    %% **DFA Using User-Defined num_scales**
    % Define log-spaced window sizes
    n_vals = logspace(log10(min_scale), log10(max_scale), num_scales);
    n_vals = unique(round(n_vals)); % Ensure unique integer values
    F = compute_F(profile, n_vals, N);

    % Compute DFA exponent (alpha)
    alpha = compute_alpha(n_vals, F);

    %% **DFA57: Using Exactly 57 Box Sizes**
   % Compute DFA57 using exactly 57 log-spaced box sizes
n_vals57 = logspace(log10(4), log10(max_scale), 57);
n_vals57 = unique(round(n_vals57)); % Ensure integer box sizes

F57 = compute_F(profile, n_vals57, N);
alpha57 = compute_alpha(n_vals57, F57);


    %% **Plot DFA Results**
    figure;
    subplot(2,1,1);
    loglog(n_vals, F, 'o-', 'LineWidth', 2);
    xlabel('Window Size (n)');
    ylabel('Fluctuation Function F(n)');
    title(['DFA (User-defined scales): \alpha = ', num2str(alpha)]);
    grid on;

    subplot(2,1,2);
    loglog(n_vals57, F57, 'o-', 'LineWidth', 2);
    xlabel('Window Size (n)');
    ylabel('Fluctuation Function F(n)');
    title(['DFA57 (57 box sizes): \alpha = ', num2str(alpha57)]);
    grid on;
end

%% **Helper Function: Compute Fluctuation Function F(n)**
function F = compute_F(profile, n_vals, N)
    F = zeros(length(n_vals), 1);

    for i = 1:length(n_vals)
        n = n_vals(i);
        num_segments = floor(N / n);
        rms_values = zeros(num_segments, 1);

        for j = 1:num_segments
            segment_idx = (j-1)*n+1 : j*n;
            segment = profile(segment_idx);
            x = (1:n)';
            p = polyfit(x, segment, 1); % Linear detrend
            trend = polyval(p, x);
            detrended = segment - trend;
            rms_values(j) = sqrt(mean(detrended.^2)); % Compute RMS
        end

        F(i) = mean(rms_values); % Average RMS across all segments
    end
end

%% **Helper Function: Compute DFA Scaling Exponent Alpha**
function alpha = compute_alpha(n_vals, F)
    log_n = log(n_vals);
    log_F = log(F);
    p = polyfit(log_n, log_F, 1); % Fit linear model in log-log space
    alpha = p(1); % DFA Scaling Exponent
end

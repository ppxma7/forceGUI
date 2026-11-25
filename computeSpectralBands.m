function bands = computeSpectralBands(forceTrace, fs)
% COMPUTESPECTRALBANDS Low-pass filters force trace at 35 Hz (3rd-order Butterworth),
% computes Welch's PSD for Low (1–5 Hz), Mid (5–15 Hz) and High (15–30 Hz), and generates
% high-resolution STFT data for Time-Frequency-Signal (TFS) plotting.
%
% Notes
% Signal Energy: The total area under the squared signal curve across time
% Signal Power: The average energy per unit of time (equivalent to the variance of force trace).

% Default output structure (Gamma removed)
bands = struct(...
    'Low', NaN, ...
    'Mid', NaN, ...
    'High',  NaN, ...
    'Total', NaN, ...
    't',     [],  ... % Time vector for force trace
    'filtF', [],  ... % Low-pass filtered force trace
    'S_t',   [],  ... % High-res TFS time vector
    'S_f',   [],  ... % High-res TFS frequency vector
    'S_PdB', [],   ... % High-res TFS Power matrix in dB
    'S_Lin', []   ... % High-res TFS Power matrix in absolute power
    );

if isempty(forceTrace) || nargin < 2 || isnan(fs) || fs <= 0
    return;
end

% Ensure forceTrace is a column vector
forceTrace = forceTrace(:);
N = length(forceTrace);
t = (0:N-1) / fs;

% 1. Low-pass filter at 35 Hz (Delta through Beta)
cutoff = min(35, (fs / 2) * 0.99);
[b, a] = butter(3, cutoff / (fs / 2), 'low');
filtForce = filtfilt(b, a, forceTrace);

bands.t = t;
bands.filtF = filtForce;

% 2. Welch's PSD for average band metrics
windowLength = round(fs);
win = hanning(windowLength);
%noverlap = 1948;  %from cabral 2024
noverlap = round(windowLength * 0.5);

if noverlap >= windowLength
    noverlap = max(0, windowLength - 1);
end
% Computes the average Power Spectral Density (PSD) across the entire signal
% chops force trace into overlapping chunks,
% run an FFT on every chunk,
% averages all the FFTs togethe
%
% use Hanning window vector (1s) that tapers the edges of each slice to prevent spectral leakage.
[pxx, f] = pwelch(filtForce, win, noverlap, [], fs);

% 3. Frequency Step Size & Band Indices
df = f(2) - f(1); % Frequency step resolution (Hz)

% band indices:
lowIdx  = (f >= 1)  & (f < 5);
midIdx  = (f >= 5)  & (f < 15);
highIdx = (f >= 15) & (f <= 30);

% Total Power across the analyzed range (N^2)
totalPower = sum(pxx) * df;

% --- Absolute Integrated Band Power (N^2) ---
% Instead of taking the average power density,  sum up all the Power Spectral Density 
% (PSD) values within that band and multiply by the frequency resolution step
% absolute power (three lines instead of four):
if any(lowIdx),  bands.Low  = sum(pxx(lowIdx))  * df; else, bands.Low  = 0; end
if any(midIdx),  bands.Mid  = sum(pxx(midIdx))  * df; else, bands.Mid  = 0; end
if any(highIdx), bands.High = sum(pxx(highIdx)) * df; else, bands.High = 0; end

bands.Total = totalPower;

% --- Relative Band Power (%) ---
% proportional share that a single frequency band contributes to the total force spectrum across all frequencies.
if totalPower > 0
    bands.Low_Rel  = (bands.Low  / totalPower) * 100;
    bands.Mid_Rel  = (bands.Mid  / totalPower) * 100;
    bands.High_Rel = (bands.High / totalPower) * 100;
else
    bands.Low_Rel = 0; bands.Mid_Rel = 0; bands.High_Rel = 0;
end

% 4. High-Resolution TFS Spectrogram

% --- Resolution Tweaks ---
stftWinLen = round(fs * 1.0); % 1-second window for sharp frequency definition
if stftWinLen < 32, stftWinLen = 32; end
stftOverlap = round(stftWinLen * 0.95); % 95% overlap for dense time steps

% High NFFT zero-padding interpolates fine frequency bins (e.g. 4096 points)
nfft = max(4096, 2^nextpow2(stftWinLen * 4));

%  % Computes a 2D Time-Frequency map showing how frequency content changes moment-by-moment.
% similar to Welch but does with sliding window and doesnt average.

[S, F_spec, T_spec] = spectrogram(filtForce, hanning(stftWinLen), stftOverlap, nfft, fs);

% use decibels better - transform to log
% spectral density here is N^2/Hz or W/Hz
% Measures how many Newtons of variance are packed into a 1Hz frequency slice.
% then convert to dB/Hz
P_dB = 10 * log10(abs(S).^2 + eps);

% Absolute Power Density (Always >= 0)
% but will be hard to see any high frequency
P_linear = abs(S).^2 / (fs * sum(hanning(stftWinLen).^2));

% Restrict frequency output range up to 35 Hz
freqMask = F_spec <= cutoff;

bands.S_f = F_spec(freqMask);
bands.S_t = T_spec;
bands.S_PdB = P_dB(freqMask, :);
bands.S_Lin = P_linear(freqMask, :);
end
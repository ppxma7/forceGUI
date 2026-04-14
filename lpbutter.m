function x = lpbutter (x, cutoff_frequency,fsamp)
% INPUTS:
%   x - signal to be filtered
%   cutoff_frequency - cutoff frequency (in Hz)
%   fsamp - sampling frequency (in Hz)
% OUTPUTS:
%   x - filtered signal
if cutoff_frequency >= fsamp/2
    x = x;
elseif cutoff_frequency <= 0
    x = 0*x;
else
    [b,a] = butter(5,cutoff_frequency/fsamp*2,'low');
    x = filtfilt(b,a,double(x));
end

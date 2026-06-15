function x = getTimeAxis(s, n)
% adding this in to plot the x axis in times, not just in default samples 
    tnames = {'Time','time','t','TimeVector'};
    fnames = {'fs','fsamp','Fs','SamplingFrequency','SampleRate'};
    % ^ check if these guys exist
    tpresent = tnames(isfield(s, tnames));
    fpresent = fnames(isfield(s, fnames));
    % ^ indexing
    if ~isempty(tpresent) && ~isempty(s.(tpresent{1})) % make sure the variable exists, and that it's not empty
        x = s.(tpresent{1});
        x = x(1:n);
    elseif ~isempty(fpresent) && ~isempty(s.(fpresent{1})) % if no time, divide by sampling rate
        x = (0:n-1)/s.(fpresent{1});
    else
        x = 1:n; % just plot samples
    end
end
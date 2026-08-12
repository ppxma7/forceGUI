function x = getTimeAxis(s, n)
% GETTIMEAXIS Generates time vector safely for single structs or struct arrays.
% Works with single signals or multi-contraction arrays (app.Data).

    % If s is a multi-element struct array (e.g. app.Data with 1x7 contractions),
    % pick the active element or first element safely.
    if numel(s) > 1
        % Check if a 'CurrentContraction' field exists or default to element 1
        if isfield(s, 'CurrentContraction') && ~isempty(s(1).CurrentContraction)
            idx = s(1).CurrentContraction;
        else
            idx = 1;
        end
        sTarget = s(idx);
    else
        sTarget = s;
    end

    tnames = {'Time','time','t','TimeVector'};
    fnames = {'fs','fsamp','Fs','SamplingFrequency','SampleRate'};

    % Check fields on single isolated struct element
    tpresent = tnames(isfield(sTarget, tnames));
    fpresent = fnames(isfield(sTarget, fnames));

    % 1. Try to extract existing Time vector
    if ~isempty(tpresent)
        tVec = sTarget.(tpresent{1});
        if ~isempty(tVec)
            tVec = tVec(:)'; % Force 1D row vector
            if length(tVec) >= n
                x = tVec(1:n);
            else
                % If n requested is longer than stored time vector, expand using fs
                if ~isempty(fpresent) && ~isempty(sTarget.(fpresent{1}))
                    fs = sTarget.(fpresent{1});
                    dt = 1 / fs;
                    x = [tVec, tVec(end) + (1:(n - length(tVec))) * dt];
                else
                    x = 1:n; % Fallback
                end
            end
            return;
        end
    end

    % 2. If no time vector, compute from sampling frequency
    if ~isempty(fpresent) && ~isempty(sTarget.(fpresent{1}))
        fs = sTarget.(fpresent{1});
        x = (0:n-1) / fs;
        return;
    end

    % 3. Fallback: return sample indices
    x = 1:n;
end
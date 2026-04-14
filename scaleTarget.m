function targetScaled = scaleTarget(target, raw)

    % Ensure column vectors
    target = target(:);
    raw    = raw(:);

    % If lengths differ, resample target
    if length(target) ~= length(raw)
        target = resample(target, length(raw), length(target));
    end

    tmin = min(target);
    tmax = max(target);

    if tmax == tmin
        % Flat target → map to midpoint of raw
        targetScaled = ones(size(raw)) * mean(raw);
        return;
    end

    rmin = min(raw);
    rmax = max(raw);

    targetScaled = (target - tmin) / (tmax - tmin) * (rmax - rmin) + rmin;
end
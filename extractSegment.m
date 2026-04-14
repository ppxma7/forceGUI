function segment = extractSegment(signal, idx1, idx2)
    idx1 = max(1, round(idx1));
    idx2 = min(length(signal), round(idx2));
    segment = signal(idx1:idx2);
end
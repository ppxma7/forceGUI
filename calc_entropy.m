

function [ApEn_value, SampEn_value] = calc_entropy(U, m, r)
    % Computes Approximate Entropy (ApEn) and Sample Entropy (SampEn) for a
    % single dataset. If we only include one eg filtered or unfletered
    % Calls 2 functions below
    ApEn_value = FastApEn(U, m, r);
    SampEn_value = FastSampEn(U, m, r);
end




function [ApEn1, SampEn1, ApEn2, SampEn2] = calc_entropy_multiple(U1, U2, m, r)
    % Computes Approximate Entropy (ApEn) and Sample Entropy (SampEn) for
    % two datasets; filtered and unfiltered
    % Inputs:
    %   U1: First dataset (unfiltered data, 'selected force')
    %   U2: Second dataset (filtered data, selected_segment{1,3})
    %   m: Embedding dimension
    %   r: Tolerance (0.1 as per Pethick and maugher. They do not pre filter data?)
    % Outputs:
    %   ApEn1, SampEn1: Entropy values for U1
    %   ApEn2, SampEn2: Entropy values for U2

    % Compute entropy for dataset 1
    % Calls 2 functions below
    ApEn1 = FastApEn(U1, m, r);
    SampEn1 = FastSampEn(U1, m, r);

    % Compute entropy for dataset 2
    % Calls 2 functions below
    ApEn2 = FastApEn(U2, m, r);
    SampEn2 = FastSampEn(U2, m, r);
end
function SampEn_value = FastSampEn(U, m, r)
    % Fast Sample Entropy (SampEn) using vectorized operations. Seems most 
    U = U(:); % Ensure U is a column vector
    N = length(U);
    r = r * std(U); % Scale r by standard deviation

    % Construct embedded matrices for patterns of length m and m+1
    Xm = zeros(N-m, m);
    Xm1 = zeros(N-m-1, m+1);
    
    for i = 1:N-m
        Xm(i, :) = U(i:i+m-1)';  
    end
    for i = 1:N-m-1
        Xm1(i, :) = U(i:i+m)';   
    end

    % Compute pairwise distances
    Dm = pdist2(Xm, Xm, 'chebychev');
    Dm1 = pdist2(Xm1, Xm1, 'chebychev');

    % Count matches (excluding self-matches)
    B = sum(Dm <= r, 2) - 1;   
    A = sum(Dm1 <= r, 2) - 1;  

    % Compute probabilities
    B_prob = sum(B) / ((N - m) * (N - m - 1));
    A_prob = sum(A) / ((N - m - 1) * (N - m - 2));

    % Compute SampEn
    if B_prob == 0
        SampEn_value = NaN; % Avoid log(0)
    else
        SampEn_value = -log(A_prob / B_prob);
    end
end

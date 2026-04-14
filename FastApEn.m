function ApEn_value = FastApEn(U, m, r)
    % Fast Approximate Entropy (ApEn) using vectorized operations
    U = U(:); % Ensure U is a column vector
    N = length(U);
    r = r * std(U); % Scale r by standard deviation

    % Precompute m and m+1 matrices
    Xm = zeros(N-m, m);
    Xm1 = zeros(N-m-1, m+1);

    for i = 1:N-m
        Xm(i, :) = U(i:i+m-1)';   
    end
    for i = 1:N-m-1
        Xm1(i, :) = U(i:i+m)';    
    end

    % Compute distances efficiently
    Cm = sum(pdist2(Xm, Xm, 'chebychev') <= r, 2) / (N - m);
    Cm1 = sum(pdist2(Xm1, Xm1, 'chebychev') <= r, 2) / (N - m - 1);

    % Compute ApEn
    ApEn_value = mean(log(max(Cm, 1e-10))) - mean(log(max(Cm1, 1e-10)));
end
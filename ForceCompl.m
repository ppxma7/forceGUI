
%% Compute Approximate Entropy (ApEn) and Sample Entropy (SampEn)
addpath('C:\Users\mszmjp1\OneDrive - The University of Nottingham\Documents\MATLAB\ForForce'); % Add file path to functions
% 4 seperate functions required

m = 2;  % Embedding dimension
r = 0.1; % Tolerance (0.1 * std of signal as per Pethick and Mauger)

% Compute entropy for filtered and unfilterd data
[ApEn_selected, SampEn_selected, ApEn_filtered, SampEn_filtered] = calc_entropy_multiple(selected_force, selected_segments{1,3}, m, r);

% Display results - this may take a while 
% Eventually build into normal outputs
disp(['Approximate Entropy (UNfiltered): ', num2str(ApEn_selected)]);
disp(['Sample Entropy (UNfiltered): ', num2str(SampEn_selected)]);
disp(['Approximate Entropy (filtered): ', num2str(ApEn_filtered)]);
disp(['Sample Entropy (filtered): ', num2str(SampEn_filtered)]);



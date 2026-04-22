% Script to combine Results from all .mat files in a folder, 
% output from forceGUI
%
% MA 
clear variables
close all
clc
thisMode = 'TRAP'; % 'MCON', 'TRAP', 'RAMP'

%% cols
modeCols = struct();
modeCols.MCON = {'Code','Lag','Corr','AUC','NormAUC','LRlag','LRcorr',...
    'Up_SD','Up_RMSE','Up_RMSE_Norm','Down_SD','Down_RMSE','Down_RMSE_Norm'};
modeCols.TRAP = {'Code','SteadyMean','SteadySTD','SteadyCoV','CoV5s','CoV2s',...
    'ScaledCoV','CoVminus1','MeanYank','RMSYank','ApEn','SampEn','DFA57',...
    'MinForce','MaxForce','Up_SD','Up_RMSE','Up_RMSE_Norm','Down_SD','Down_RMSE','Down_RMSE_Norm'};
modeCols.RAMP = {'Code','Up_SD','Up_RMSE','Up_RMSE_Norm','Down_SD','Down_RMSE','Down_RMSE_Norm'};

expectoCols = modeCols.(thisMode);

%% folder
dataFolder = uigetdir(pwd, 'Select folder containing CSV files');
if dataFolder == 0
    error('No folder selected. Exiting.');
end

csvFiles = dir(fullfile(dataFolder, '*_forceresults*.csv'));
if isempty(csvFiles)
    error('No *_forceresults.csv files found in %s', dataFolder);
end
fprintf('Found %d CSV files.\n', numel(csvFiles));

%% now comboine
allTables = cell(numel(csvFiles), 1);
skipped = {};

for ii = 1:numel(csvFiles)
    % read the file
    fpath = fullfile(dataFolder, csvFiles(ii).name);
    try
        T = readtable(fpath, 'TextType', 'string');
        
        % Check columns match expected
        fileCols = T.Properties.VariableNames;
        % setdiff checks for missing values between two variables
        missing = setdiff(expectoCols, fileCols);
        if ~isempty(missing)
            % so if the fileCols from the table we read doesnt match the
            % cols we set when we set our mode, then it will skip this csv
            % file
            warning('Skipping %s — missing columns: %s', csvFiles(ii).name, strjoin(missing, ', '));
            skipped{end+1} = csvFiles(ii).name;
            continue
        end
        
        % Keep only expected columns in correct order
        allTables{ii} = T(:, expectoCols);
        
    catch ME
        warning('Could not read %s: %s', csvFiles(ii).name, ME.message);
        skipped{end+1} = csvFiles(ii).name;
    end
end

% Remove empty cells (skipped files)
% condensed - apply isempty to each cell, give a logical array, then flip
% it, then do allTables(logical array) to only keep the non empty ones
allTables = allTables(~cellfun(@isempty, allTables));

if isempty(allTables)
    error('No valid files could be combined for mode: %s', thisMode);
end

% this will fail if there are empty cells
combined = vertcat(allTables{:});
fprintf('Combined %d files, %d rows total.\n', numel(allTables), height(combined));

%% now save
timestamp = datetime('now', 'Format', 'yyyyMMdd_HHmmss');
outName = sprintf('combined_%s_%s.csv', thisMode, timestamp);
outPath =fullfile(dataFolder, outName);
writetable(combined, outPath);
fprintf('Saved: %s\n', outPath);

if ~isempty(skipped)
    fprintf('\nSkipped %d file(s):\n', numel(skipped));
    for ii = 1:numel(skipped)
        fprintf('%s\n', skipped{ii});
    end
end
function labels = loadContractionLabels(folder)
txtfile = fullfile(folder, 'contractionLabels.txt');

if ~isfile(txtfile)
    labels = {};
    return;
end

% Read numeric or string values line-by-line
raw = readlines(txtfile);
raw = strtrim(raw);
raw = raw(raw ~= "");   % remove empty lines

labels = cellstr(raw);
end

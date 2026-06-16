function t = getTargetOrEmpty(Data, field)
    if isfield(Data, field) && ~isempty(Data.(field))
        t = Data.(field);
    else
        t = [];
    end
end
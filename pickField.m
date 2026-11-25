function val = pickField(S, aliases, default)
i = find(isfield(S, aliases), 1);
if isempty(i), val = default; else, val = S.(aliases{i}); end
end
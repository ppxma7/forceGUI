function template = template_derby()

template.type = "derby";

template.fields = struct( ...
    'Force',  {{'FORCE','Force'}}, ...
    'Target', {{}} ...
    );

template.fallbacks = struct( ...
    'Force',  @(S) extractDerbyForce(S), ...
    'Target', @(S) [], ...
    'fs',     @(S) 2048, ...
    'Time',   @(S) [] ...
    );

template.scaling = struct();   % no scaling

template.special = struct( ...
    'RawForce', true ...
    );

end

function f = extractDerbyForce(S)
likelyChannel = 66;
if isfield(S,'Data')
    if iscell(S.Data)
        f = S.Data{1}(:,likelyChannel);
    else
        f = S.Data(:,likelyChannel);
    end
else
    f = S.FORCE(:);
end
end

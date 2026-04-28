function template = template_ramp()

template.type = "ramp";

template.fields = struct( ...
    'Force',  {{'ref_signal'}}, ...
    'Target', {{}} ...
);

template.fallbacks = struct( ...
    'Force',  @(S) error('ref_signal missing'), ...
    'Target', @(S) [], ...
    'fs',     @getFs, ...
    'Time',   @(S) [] ...
);

template.scaling = struct();   % no scaling

template.special = struct();   % no special logic

end

function fs = getFs(S)
    if isfield(S,'fsamp')
        fs = S.fsamp;
    elseif isfield(S,'SamplingFrequency')
        fs = S.SamplingFrequency;
    else
        fs = 2000;
    end
end

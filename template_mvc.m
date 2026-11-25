function template = template_mvc()

template.type = "mvc";

template.fields = struct();  % handled by special.extract

template.fallbacks = struct( ...
    'fs',   @(S) [], ...
    'Time', @(S) [] ...
    );

template.scaling = struct();   % no target, no scaling

template.special = struct( ...
    'extract', @extractMVC ...
    );

end


function dataStruct = extractMVC(S)

% Preferred: direct force fields
if isfield(S,'ForceL') && isfield(S,'ForceR')

    dataStruct.ForceL  = S.ForceL(:);
    dataStruct.ForceR  = S.ForceR(:);

    if isfield(S,'ForceBi')
        dataStruct.ForceBi = S.ForceBi(:);
    else
        dataStruct.ForceBi = dataStruct.ForceL + dataStruct.ForceR;
    end

% Legacy: signal_mvc structure
elseif isfield(S,'signal_mvc') && isfield(S.signal_mvc,'auxiliary')

    aux = S.signal_mvc.auxiliary;

    if size(aux,1) >= 3
        dataStruct.ForceBi = aux(1,:)';
        dataStruct.ForceL  = aux(2,:)';
        dataStruct.ForceR  = aux(3,:)';
    else
        f = aux(1,:)';
        dataStruct.ForceBi = f;
        dataStruct.ForceL  = f;
        dataStruct.ForceR  = f;
    end

% Legacy: single force channel
elseif isfield(S,'Force')

    f = S.Force(:);

    dataStruct.ForceBi = f;
    dataStruct.ForceL  = f;
    dataStruct.ForceR  = f;

else
    error('extractMVC: Cannot find force channels');
end

% Sampling frequency
if isfield(S,'fsamp')
    fs = S.fsamp;
elseif isfield(S,'signal_mvc') && isfield(S.signal_mvc,'fsamp')
    fs = S.signal_mvc.fsamp;
else
    fs = 2000;
end

dataStruct.fs = fs;
dataStruct.Target = [];

end

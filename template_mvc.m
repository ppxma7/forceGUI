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

% row 1 = bilat (Force_Sum_raw), row 2 = left, row 3 = right
if isfield(S,'signal_mvc') && isfield(S.signal_mvc,'auxiliary')
    aux = S.signal_mvc.auxiliary;
    dataStruct.ForceBi = aux(1,:)';   % real recorded bilateral channel — for display
    dataStruct.ForceL  = aux(2,:)';
    dataStruct.ForceR  = aux(3,:)';

elseif isfield(S,'Force')
    keyboard
    % legacy/broken single-channel file - fix in recorder
    dataStruct.ForceL  = S.Force(:);
    dataStruct.ForceR  = S.Force(:);
    dataStruct.ForceBi = [S.Force(:), S.Force(:)];

else
    error('extractMVC: cannot find force channel');
end

% --- Sampling frequency ---
if isfield(S,'signal_mvc') && isfield(S.signal_mvc,'fsamp')
    fs = S.signal_mvc.fsamp;
elseif isfield(S,'fsamp')
    fs = S.fsamp;
else
    fs = 2000;
end

dataStruct.fs     = fs;
dataStruct.Target = [];

end
function template = selectTemplate(mode, rig, analysis, redoFlag)
% tidying up from main app, move it here
%
% instead of multiple load functions, have a select template. Which gets
% populated. Then it sends it to load data generic.

if redoFlag
    template = "redo";
    return
end

if strcmp(analysis, 'TRAP_multi')
    template = template_multiContract();
    return
end

if strcmp(mode, 'Single Channel')

    if strcmp(rig, 'Derby Chair')
        if strcmp(analysis, 'TRAP')
            template = template_derby();
        elseif strcmp(analysis, 'MCON')
            template = template_single();
        elseif strcmp(analysis, 'RAMP')
            template = template_ramp();
        end

    elseif strcmp(analysis, 'RAMP')
        template = template_ramp();

    else
        template = template_single();
    end

else
    % Multi-channel TRAP
    template = template_multi();
end
end

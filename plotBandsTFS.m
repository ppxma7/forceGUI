function plotBandsTFS(bands, axForce, axSpec)
% PLOTBANDSTFS Plots smooth TFS data with frequency band boundary lines.

    if isempty(bands.S_PdB)
        warning('No TFS data found in bands structure.');
        return;
    end

    if nargin < 3
        figure('Name', 'High-Resolution TFS Analysis', 'Color', 'w');
        tiledlayout(2, 1, 'TileSpacing', 'compact', 'Padding', 'compact');
        ax1 = nexttile;
        ax2 = nexttile;
    else
        ax1 = axForce;
        ax2 = axSpec;
    end

    % --- Top Panel: Filtered Force Signal ---
    plot(ax1, bands.t, bands.filtF, 'k-', 'LineWidth', 1.2);
    ylabel(ax1, 'Force');
    title(ax1, 'Time-Domain Force Signal');
    grid(ax1, 'on');
    xlim(ax1, [0, bands.t(end)]);

    % --- Bottom Panel: High-Res Smooth Spectrogram ---
    % Using pcolor with interp shading removes the blocky image pixels
    %h = pcolor(ax2, bands.S_t, bands.S_f, bands.S_PdB);
    h = pcolor(ax2, bands.S_t, bands.S_f, bands.S_PdB);
    set(h, 'EdgeColor', 'none');
    shading(ax2, 'interp'); % Bilinear interpolation for smooth gradient
    
    colormap(ax2, 'turbo'); % 'turbo' or 'jet' provides clear spectral contrast
    ylabel(ax2, 'Frequency (Hz)');
    xlabel(ax2, 'Time (s)');
    title(ax2, 'Time-Frequency Spectrum (0-35 Hz)');
    xlim(ax2, [0, bands.t(end)]);
    ylim(ax2, [0, max(bands.S_f)]);
    
    cb = colorbar(ax2);
    cb.Label.String = 'Power Density (dB/Hz)';

    % --- Overlay Frequency Band Boundaries ---
    hold(ax2, 'on');
    boundaries = [4, 8, 13, 30]; % Delta/Theta, Theta/Alpha, Alpha/Beta, Beta boundary
    labels     = {'Delta (0.5-4Hz)', 'Theta (4-8Hz)', 'Alpha (8-13Hz)', 'Beta (13-30Hz)'};
    labelYPos  = [2, 6, 10.5, 21.5];

    xEnd = bands.t(end);

    for i = 1:length(boundaries)
        y = boundaries(i);
        line(ax2, [0, xEnd], [y, y], 'Color', [1 1 1 0.6], ...
            'LineStyle', '--', 'LineWidth', 1.0);
    end

    % Add text labels inside each band region
    for i = 1:length(labels)
        text(ax2, xEnd * 0.01, labelYPos(i), labels{i}, ...
            'Color', 'w', 'FontSize', 8, 'FontWeight', 'bold', ...
            'BackgroundColor', [0 0 0 0.4], 'Margin', 2);
    end
    hold(ax2, 'off');

    % Synchronize horizontal zooming
    linkaxes([ax1, ax2], 'x');
end
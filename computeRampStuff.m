function M = computeRampStuff(upramp, downramp, T_up, T_dn)

upramp = upramp(:);
downramp = downramp(:);

% hasTarget = ~isempty(T_up) && ~isempty(T_dn);

% if hasTarget
%     % --- Use target-based residuals ---
%     res_up = upramp - T_up(:);
%     res_dn = downramp - T_dn(:);
%
%     M.up.sd      = std(res_up);
%     M.up.rmse    = sqrt(mean(res_up.^2));
%
%     M.down.sd      = std(res_dn);
%     M.down.rmse    = sqrt(mean(res_dn.^2));
%
% else
% --- Fall back to detrending ---
x_up = (1:length(upramp))';
p_up = polyfit(x_up, upramp, 1);
fit_up = polyval(p_up, x_up);
res_up = upramp - fit_up;

x_dn = (1:length(downramp))';
p_dn = polyfit(x_dn, downramp, 1);
fit_dn = polyval(p_dn, x_dn);
res_dn = downramp - fit_dn;

M.up.sd   = std(res_up);
M.up.rmse    = sqrt(mean(res_up.^2));

M.down.sd   = std(res_dn);
M.down.rmse   = sqrt(mean(res_dn.^2));

% Normalise by the range of the ramp: the wobble is X% of the total ramp amplitude
M.up.rmse_norm   = M.up.rmse   / (max(upramp) - min(upramp));
M.down.rmse_norm = M.down.rmse / (max(downramp) - min(downramp));


%% plotting this?
figure('Color','w','Position',[100 100 900 420]);
tiledlayout(1,2,'TileSpacing','compact','Padding','compact');

% --- Up ramp ---
ax1 = nexttile;
hold on;
t_up = (1:length(upramp))';
plot(t_up, upramp, 'Color',[0.6 0.6 0.6], 'LineWidth',1.0, 'DisplayName','Signal');
plot(t_up, fit_up, 'Color',[0.2 0.5 0.9], 'LineWidth',1.8, 'DisplayName','Linear fit');

nan_sep = nan(1, length(t_up));
xpatch = [t_up'; t_up'; nan_sep];
ypatch = [upramp'; fit_up'; nan_sep];
plot(xpatch(:), ypatch(:), 'Color',[0.9 0.4 0.2 0.3], 'LineWidth',0.8);

legend('Location','best','FontSize',9);
xlabel('Sample'); ylabel('Amplitude');
%title(sprintf('Up ramp  |  RMSE = %.4f', M.up.rmse));
title(sprintf('Up ramp  |  RMSE = %.1f%%', M.up.rmse_norm * 100));
set(ax1,'Box','off','FontSize',10);
hold off;

% --- Down ramp ---
ax2 = nexttile;
hold on;
t_dn = (1:length(downramp))';
plot(t_dn, downramp, 'Color',[0.6 0.6 0.6], 'LineWidth',1.0, 'DisplayName','Signal');
plot(t_dn, fit_dn,   'Color',[0.2 0.5 0.9], 'LineWidth',1.8, 'DisplayName','Linear fit');

nan_sep = nan(1, length(t_dn));
xpatch = [t_dn'; t_dn'; nan_sep];
ypatch = [downramp'; fit_dn'; nan_sep];
plot(xpatch(:), ypatch(:), 'Color',[0.9 0.4 0.2 0.3], 'LineWidth',0.8);

legend('Location','best','FontSize',9);
xlabel('Sample'); ylabel('Amplitude');
%title(sprintf('Down ramp  |  RMSE = %.4f', M.down.rmse));
title(sprintf('Down ramp  |  RMSE = %.1f%%', M.down.rmse_norm * 100));
set(ax2,'Box','off','FontSize',10);
hold off;




end
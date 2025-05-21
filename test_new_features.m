% Test script for 'Automated Panel Labeling' and 'Basic Statistical Overlay'
% features in beautify_figure.m

disp('Starting test_new_features.m...');

% Ensure beautify_figure is in the path (assuming it's in the current directory or a directory named 'src')
if ~(exist('beautify_figure', 'file') == 2)
    if exist('../beautify_figure.m', 'file')
        addpath('..');
        disp('Added parent directory to path for beautify_figure.m');
    elseif exist('src/beautify_figure.m', 'file')
        addpath('src');
        disp('Added src directory to path for beautify_figure.m');
    else
        error('beautify_figure.m not found. Please add it to the MATLAB path.');
    end
end

% Create an 'output' directory for exported figures if it doesn't exist
if ~exist('output', 'dir')
    mkdir('output');
end
disp('Output directory ensured.');

% --- Scenario 1: Single Plot ---
disp('Running Scenario 1: Single Plot...');
fig1 = figure('Name', 'Scenario 1: Single Plot', 'Position', [100, 600, 500, 400]);
plot(1:10, rand(1,10));
title('Single Plot with Stats');
params1_pl = struct('enabled', true); % Panel labeling
params1_so = struct('enabled', true, 'statistics', {{'mean', 'std', 'min', 'max', 'N'}});

% Apply panel labeling (should be handled gracefully, likely no label for single non-subplot/tiled axes)
beautify_figure(gca, struct('panel_labeling', params1_pl, 'log_level', 1)); 
disp('Applied panel labeling to single plot.');

% Apply stats overlay
beautify_figure(gca, struct('stats_overlay', params1_so, 'export_settings', struct('enabled', true, 'filename', 'output/single_plot_stats', 'format', 'png'), 'log_level', 1));
disp('Applied stats overlay and exported single_plot_stats.png');
drawnow; pause(1);

% --- Scenario 2: Multiple Subplots (using subplot) ---
disp('Running Scenario 2: Multiple Subplots...');
fig2 = figure('Name', 'Scenario 2: Subplots', 'Position', [600, 600, 700, 600]);
subplot(2,2,1); plot(rand(10,1)); title('Subplot A');
subplot(2,2,2); scatter(rand(20,1), rand(20,1)); title('Subplot B');
subplot(2,2,3); plot(sin(1:0.1:10)); title('Subplot C');
subplot(2,2,4); bar(rand(5,1)); title('Subplot D');

params2 = struct();
params2.panel_labeling.enabled = true;
params2.panel_labeling.style = 'a)';
params2.stats_overlay.enabled = true;
params2.stats_overlay.position = 'southwest_inset';
params2.export_settings.enabled = true;
params2.export_settings.filename = 'output/subplots_panel_stats';
params2.export_settings.format = 'png';
params2.log_level = 1;

beautify_figure(fig2, params2);
disp('Applied panel labeling and stats to subplots, exported subplots_panel_stats.png');
drawnow; pause(1);

% --- Scenario 3: Tiled Layout ---
disp('Running Scenario 3: Tiled Layout (Dark Theme)...');
fig3 = figure('Name', 'Scenario 3: Tiled Layout Dark', 'Position', [100, 100, 900, 350]);
tcl = tiledlayout(1,3, 'Padding', 'compact', 'TileSpacing', 'compact');

nexttile; plot(1:10, randn(1,10)); title('Tile 1');
nexttile; imagesc(rand(10,10)); title('Tile 2'); % imagesc won't have stats overlay by default
nexttile; plot(cos(1:0.2:20)); title('Tile 3');

params3 = struct();
params3.panel_labeling.enabled = true;
params3.panel_labeling.style = 'I';
params3.panel_labeling.position = 'northeast_inset';
params3.stats_overlay.enabled = true;
params3.stats_overlay.statistics = {{'median', 'N'}};
params3.theme = 'dark';
params3.export_settings.enabled = true;
params3.export_settings.filename = 'output/tiled_dark_panel_stats';
params3.export_settings.format = 'png';
params3.log_level = 1;

beautify_figure(fig3, params3);
disp('Applied panel labeling and stats to tiled layout (dark theme), exported tiled_dark_panel_stats.png');
drawnow; pause(1);

% --- Scenario 4: Features Disabled ---
disp('Running Scenario 4: Features Disabled...');
fig4 = figure('Name', 'Scenario 4: Features Disabled', 'Position', [600, 100, 700, 350]);
tcl2 = tiledlayout(1,2);
nexttile(tcl2); plot(rand(15,1)); title('Disabled Feature Tile 1');
nexttile(tcl2); bar(rand(10,1)); title('Disabled Feature Tile 2');

params4 = struct();
params4.panel_labeling.enabled = false; % Explicitly disable
params4.stats_overlay.enabled = false;  % Explicitly disable
% Or simply: params4 = struct(); if defaults are false
params4.export_settings.enabled = true;
params4.export_settings.filename = 'output/features_disabled';
params4.export_settings.format = 'png';
params4.log_level = 1;

beautify_figure(fig4, params4);
disp('Applied beautify_figure with features disabled, exported features_disabled.png');
drawnow; pause(1);

% --- Scenario 5: Specific Plot Targeting for Stats & Customization ---
disp('Running Scenario 5: Targeted Stats & Customization...');
fig5 = figure('Name', 'Scenario 5: Targeted Stats', 'Position', [100, -400, 800, 400]);
tcl3 = tiledlayout(1,2);

% First tile
ax1_fig5 = nexttile(tcl3);
hold(ax1_fig5, 'on');
plot(ax1_fig5, 1:20, rand(1,20)*2, 'DisplayName', 'Line 1');
plot(ax1_fig5, 1:20, rand(1,20)*5, 'Tag', 'TargetLineForStats', 'DisplayName', 'Target Line');
hold(ax1_fig5, 'off');
title(ax1_fig5, 'Tile with Targeted Stats');
legend(ax1_fig5, 'show');

% Second tile
ax2_fig5 = nexttile(tcl3);
plot(ax2_fig5, randn(30,1));
title(ax2_fig5, 'Tile with Default Stats');

params5 = struct();
params5.panel_labeling.enabled = true;
params5.stats_overlay.enabled = true;
params5.stats_overlay.target_plot_handle_tag = 'TargetLineForStats';
params5.stats_overlay.text_color = [0.8 0.1 0.1];       % Custom red
params5.stats_overlay.background_color = [0.9 0.9 0.9]; % Light gray
params5.stats_overlay.edge_color = [0.3 0.3 0.3];       % Dark gray
params5.export_settings.enabled = true;
params5.export_settings.filename = 'output/targeted_stats_custom';
params5.export_settings.format = 'png';
params5.log_level = 2; % More verbose for this one

beautify_figure(fig5, params5);
disp('Applied targeted and customized stats, exported targeted_stats_custom.png');
drawnow; pause(1);

disp('All scenarios complete. Check the "output" directory for PNG files.');
disp('Please visually inspect the figures and their exported PNGs.');

% Optional: Close all figures
% close all;

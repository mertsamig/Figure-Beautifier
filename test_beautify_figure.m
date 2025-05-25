% Test script for beautify_figure.m
% This script will test various functionalities of beautify_figure.m
% and allow for visual comparison of figures before and after beautification.
% -------------------------------------------------------------------------
% USER INSTRUCTIONS:
%
% Purpose:
%   This script tests the functionalities of `beautify_figure.m`.
%   It generates various plots, applies different beautification settings,
%   and saves 'original' and 'beautified' versions of these plots as PNG
%   images for visual comparison.
%
% Prerequisites:
%   1. Ensure `beautify_figure.m` is on the MATLAB path or in the same
%      directory as this test script. If not, you may need to use `addpath`.
%   2. If you have the 'cbrewer' package for color palettes, some tests
%      might implicitly use it if `beautify_figure` is configured to do so,
%      but it's not a hard requirement for this test script itself to run.
%
% How to Run:
%   1. Open this file (`test_beautify_figure.m`) in the MATLAB Editor.
%   2. Click the "Run" button, or type `test_beautify_figure` in the
%      MATLAB Command Window and press Enter.
%
% What to Expect:
%   - The script will execute a series of test cases. Console messages
%     will indicate the progress and which test case is running.
%   - For the Log Level Control test case (now Test Case 6), you will be prompted to press Enter
%     to continue. Observe the MATLAB Command Window for differences in
%     output verbosity from `beautify_figure.m` during this test.
%   - "Original" and "Beautified" figures for each test case (or sub-case)
%     will be saved as PNG images in a subdirectory named 'test_beautify_output'
%     (created in the same directory where this script is run).
%   - At the end, a "Test Script Complete" message will be displayed. You can
%     then inspect the generated images in the 'test_beautify_output' folder.
%   - Figures generated during the tests are closed automatically after each
%     test case or sub-case to avoid clutter.
%
% Interpreting Results:
%   - Visually compare the 'original' and 'beautified' PNG images for each
%     test case in the 'test_beautify_output' directory.
%   - Check for any error messages in the MATLAB Command Window.
%   - For the Export Functionality test case (now Test Case 4), verify that additional .png
%     and .pdf files (e.g., 'exported_figure_case_04.png', 
%     'exported_figure_case_04.pdf') are created in the output directory.
%
% -------------------------------------------------------------------------

%% Setup
% Add necessary paths (if beautify_figure.m is not in the current path)
% curr_dir = fileparts(mfilename('fullpath'));
% addpath(curr_dir); % Assuming beautify_figure.m is in the same directory as the test script

% Create an output directory for saved figures
output_dir = 'test_beautify_output';
if ~exist(output_dir, 'dir')
    mkdir(output_dir);
end
fprintf('Test figures will be saved in: %s\n', fullfile(pwd, output_dir));

% Initialize test case counter
test_case_idx = 1;

%% Helper Functions
function save_comparison_figure(fig_handle, test_name, stage, output_dir_local)
    % stage can be 'original' or 'beautified'
    
    if ~ishandle(fig_handle) || ~strcmp(get(fig_handle, 'Type'), 'figure')
        fprintf('ERROR: Invalid figure handle provided to save_comparison_figure for test: %s, stage: %s.\n', test_name, stage);
        return;
    end
    
    filename = fullfile(output_dir_local, sprintf('%s_%s.png', test_name, stage));
    try
        drawnow; 
        original_visibility = get(fig_handle, 'Visible');
        if strcmp(original_visibility, 'off')
            set(fig_handle, 'Visible', 'on');
            drawnow;
        end
        saveas(fig_handle, filename);
        fprintf('Saved: %s\n', filename);
        if strcmp(original_visibility, 'off')
            set(fig_handle, 'Visible', 'off');
        end
    catch ME
        fprintf('ERROR saving figure %s: %s\n', filename, ME.message);
    end
end

%% Test Cases

% --- Test Case 1: Default Beautification ---
fprintf('\n--- Running Test Case %d: Default Beautification ---\n', test_case_idx);
test_name_case1 = sprintf('test_case_%02d_default_beautification', test_case_idx);

fig1 = figure('Visible', 'off');
plot(1:10, rand(1,10).* (1:10));
title([test_name_case1 ' Original'], 'Interpreter', 'none');
xlabel('X-axis');
ylabel('Y-axis');
save_comparison_figure(fig1, test_name_case1, 'original', output_dir);

try
    beautify_figure(fig1); 
    title([test_name_case1 ' Beautified'], 'Interpreter', 'none'); 
    fprintf('Applied beautify_figure() with default settings.\n');
    save_comparison_figure(fig1, test_name_case1, 'beautified', output_dir);
catch ME
    fprintf('ERROR during Test Case 1 (Default Beautification): %s\n', ME.message);
end
if ishandle(fig1); close(fig1); end
test_case_idx = test_case_idx + 1;

% --- Test Case 2: Style Presets ---
fprintf('\n--- Running Test Case %d: Style Presets ---\n', test_case_idx);
style_presets = {'default', 'publication', 'presentation_dark', 'presentation_light', 'minimalist'};
params_preset = struct();

for i = 1:length(style_presets)
    current_preset = style_presets{i};
    test_name_case2 = sprintf('test_case_%02d_preset_%s', test_case_idx, current_preset);
    fprintf('  Testing preset: %s\n', current_preset);

    fig2 = figure('Visible', 'off');
    subplot(1,2,1);
    plot(1:10, sin(1:10));
    title('Sine Wave'); xlabel('X1'); ylabel('Y1');
    subplot(1,2,2);
    scatter(rand(20,1), rand(20,1)*5, 'filled');
    title('Scatter Plot'); xlabel('X2'); ylabel('Y2');
    sgtitle([test_name_case2 ' Original'], 'Interpreter', 'none');
    save_comparison_figure(fig2, test_name_case2, 'original', output_dir);

    try
        params_preset.style_preset = current_preset;
        params_preset.figure_handle = fig2;
        beautify_figure(params_preset); 
        sgtitle([test_name_case2 ' Beautified (' current_preset ')'], 'Interpreter', 'none'); 
        fprintf('  Applied beautify_figure() with preset: %s\n', current_preset);
        save_comparison_figure(fig2, test_name_case2, 'beautified', output_dir);
    catch ME
        fprintf('  ERROR during Test Case 2 (Preset: %s): %s\n', current_preset, ME.message);
    end
    if ishandle(fig2); close(fig2); end
end
test_case_idx = test_case_idx + 1;

% --- Test Case 3: Specific Parameter Customization ---
fprintf('\n--- Running Test Case %d: Specific Parameter Customization ---\n', test_case_idx);
test_name_case3 = sprintf('test_case_%02d_custom_params', test_case_idx);

fig3 = figure('Visible', 'off');
bar(rand(1,5)*10);
title([test_name_case3 ' Original'], 'Interpreter', 'none');
xlabel('Category'); ylabel('Value');
set(gca, 'XTickLabel', {'A', 'B', 'C', 'D', 'E'});
save_comparison_figure(fig3, test_name_case3, 'original', output_dir);

custom_params.theme = 'dark';
custom_params.font_name = 'Arial';
custom_params.plot_line_width = 2.5;
custom_params.color_palette = 'viridis';
custom_params.grid_density = 'major_only';
fprintf('  Applying custom parameters: theme=''dark'', font_name=''Arial'', plot_line_width=2.5, color_palette=''viridis'', grid_density=''major_only''\n');

try
    custom_params.figure_handle = fig3;
    beautify_figure(custom_params); 
    title([test_name_case3 ' Beautified (Custom)'], 'Interpreter', 'none'); 
    fprintf('  Applied beautify_figure() with custom parameters.\n');
    save_comparison_figure(fig3, test_name_case3, 'beautified', output_dir);
catch ME
    fprintf('  ERROR during Test Case 3 (Custom Parameters): %s\n', ME.message);
end
if ishandle(fig3); close(fig3); end
test_case_idx = test_case_idx + 1;

% Test Case 4 (Original Test Case 5): Statistics Overlay
fprintf('\n--- Running Test Case %d: Statistics Overlay ---\n', test_case_idx);
test_name_case4_stats = sprintf('test_case_%02d_stats_overlay', test_case_idx); % Renamed from test_name_case5

fig4_stats = figure('Visible', 'off'); % Renamed from fig5
x_data_stats = 1:50; % Renamed from x_data
y_data_stats = 5*sin(x_data_stats/5) + randn(1,50)*2 + 10; % Renamed from y_data
plot(x_data_stats, y_data_stats, 'Tag', 'NoisyDataLineStats', 'LineWidth', 1); % Tag changed slightly for clarity
title([test_name_case4_stats ' Original'], 'Interpreter', 'none');
xlabel('Time (s)'); ylabel('Signal Strength (mV)'); grid on;
save_comparison_figure(fig4_stats, test_name_case4_stats, 'original', output_dir);

stats_params.stats_overlay.enabled = true;
stats_params.stats_overlay.target_plot_handle_tag = 'NoisyDataLineStats';
stats_params.stats_overlay.statistics = {'mean', 'std', 'N', 'min', 'max'};
stats_params.stats_overlay.position = 'northeast_inset';
stats_params.stats_overlay.precision = 3;
stats_params.stats_overlay.font_scale_factor = 0.85;
stats_params.stats_overlay.background_color = [0.95 0.95 0.95];
stats_params.stats_overlay.edge_color = 'black';
fprintf('  Enabling stats overlay: target_tag=''NoisyDataLineStats'', stats={''mean'', ''std'', ''N'', ''min'', ''max''}\n');

try
    stats_params.figure_handle = fig4_stats;
    beautify_figure(stats_params); 
    title([test_name_case4_stats ' Beautified (Stats Overlay)'], 'Interpreter', 'none'); 
    fprintf('  Applied beautify_figure() with statistics overlay.\n');
    save_comparison_figure(fig4_stats, test_name_case4_stats, 'beautified', output_dir);
catch ME
    fprintf('  ERROR during Test Case %d (Statistics Overlay): %s\n', test_case_idx, ME.message);
end
if ishandle(fig4_stats); close(fig4_stats); end
test_case_idx = test_case_idx + 1;

% Test Case 5 (Original Test Case 6): Export Functionality
fprintf('\n--- Running Test Case %d: Export Functionality ---\n', test_case_idx);
test_name_case5_export = sprintf('test_case_%02d_export', test_case_idx); % Renamed
export_filename_base_case5 = fullfile(output_dir, sprintf('exported_figure_case_%02d', test_case_idx)); % Renamed

fig5_export = figure('Visible', 'off'); % Renamed
[X_export, Y_export, Z_export] = peaks(25); % Renamed for clarity
surf(X_export, Y_export, Z_export); colormap jet;
title([test_name_case5_export ' Original'], 'Interpreter', 'none');
xlabel('X-axis'); ylabel('Y-axis'); zlabel('Z-axis'); axis tight;
save_comparison_figure(fig5_export, test_name_case5_export, 'original', output_dir);

export_params_tc5.export_settings.enabled = true; % Renamed
export_params_tc5.export_settings.filename = export_filename_base_case5;
export_params_tc5.export_settings.format = 'png';
export_params_tc5.export_settings.resolution = 150;
export_params_tc5.export_settings.open_exported_file = false;

export_params_pdf_tc5 = export_params_tc5; % Renamed
export_params_pdf_tc5.export_settings.format = 'pdf';
fprintf('  Configuring export: PNG and PDF to filenames starting with "%s"\n', export_filename_base_case5);

try
    fprintf('  Applying beautify_figure() with PNG export enabled.\n');
    export_params_tc5.figure_handle = fig5_export;
    beautify_figure(export_params_tc5); 
    title([test_name_case5_export ' Beautified (PNG Export Attempted)'], 'Interpreter', 'none');
    save_comparison_figure(fig5_export, test_name_case5_export, 'beautified_for_png_export_test', output_dir);
    
    expected_png_file_tc5 = [export_filename_base_case5 '.' export_params_tc5.export_settings.format]; % Renamed
    if exist(expected_png_file_tc5, 'file')
        fprintf('  SUCCESS: Exported PNG file found: %s\n', expected_png_file_tc5);
    else
        fprintf('  FAILURE: Exported PNG file NOT found: %s\n', expected_png_file_tc5);
    end

    fig5_pdf_test = figure('Visible', 'off'); % Renamed
    surf(X_export,Y_export,Z_export); colormap jet; 
    title([test_name_case5_export ' Original for PDF'], 'Interpreter', 'none'); 
    xlabel('X-axis'); ylabel('Y-axis'); zlabel('Z-axis'); axis tight;
    fprintf('  Applying beautify_figure() with PDF export enabled to a fresh figure.\n');
    export_params_pdf_tc5.figure_handle = fig5_pdf_test;
    beautify_figure(export_params_pdf_tc5);
    
    expected_pdf_file_tc5 = [export_filename_base_case5 '.' export_params_pdf_tc5.export_settings.format]; % Renamed
    if exist(expected_pdf_file_tc5, 'file')
        fprintf('  SUCCESS: Exported PDF file found: %s\n', expected_pdf_file_tc5);
    else
        fprintf('  FAILURE: Exported PDF file NOT found: %s\n', expected_pdf_file_tc5);
    end
    if ishandle(fig5_pdf_test); close(fig5_pdf_test); end
catch ME
    fprintf('  ERROR during Test Case %d (Export Functionality): %s\n', test_case_idx, ME.message);
end
if ishandle(fig5_export); close(fig5_export); end
test_case_idx = test_case_idx + 1;

% Test Case 6 (Original Test Case 8): Log Level Control
fprintf('\n--- Running Test Case %d: Log Level Control ---\n', test_case_idx);

test_name_case6_silent = sprintf('test_case_%02d_loglevel_0_silent', test_case_idx); % Renamed
fprintf('  Running with log_level = 0 (Silent). Expect minimal to no output from beautify_figure.\n');
fig6_silent = figure('Visible', 'off'); % Renamed
plot(1:5, rand(1,5));
title([test_name_case6_silent ' Original'], 'Interpreter', 'none');
save_comparison_figure(fig6_silent, test_name_case6_silent, 'original', output_dir);
log_params_silent_tc6.log_level = 0; % Renamed
try
    log_params_silent_tc6.figure_handle = fig6_silent;
    beautify_figure(log_params_silent_tc6);
    title([test_name_case6_silent ' Beautified (Log Level 0)'], 'Interpreter', 'none');
    save_comparison_figure(fig6_silent, test_name_case6_silent, 'beautified', output_dir);
    fprintf('  Applied beautify_figure with log_level = 0.\n');
catch ME
    fprintf('  ERROR during Test Case %d (Log Level 0): %s\n', test_case_idx, ME.message);
end
if ishandle(fig6_silent); close(fig6_silent); end

input('  Press Enter to continue to Log Level 2 (Detailed) test...\n', 's');

test_name_case6_detailed = sprintf('test_case_%02d_loglevel_2_detailed', test_case_idx); % Renamed
fprintf('  Running with log_level = 2 (Detailed). Expect verbose output from beautify_figure.\n');
fig6_detailed = figure('Visible', 'off'); % Renamed
plot(1:5, rand(1,5)); 
title([test_name_case6_detailed ' Original'], 'Interpreter', 'none');
save_comparison_figure(fig6_detailed, test_name_case6_detailed, 'original', output_dir);
log_params_detailed_tc6.log_level = 2; % Renamed
try
    log_params_detailed_tc6.figure_handle = fig6_detailed;
    beautify_figure(log_params_detailed_tc6);
    title([test_name_case6_detailed ' Beautified (Log Level 2)'], 'Interpreter', 'none');
    save_comparison_figure(fig6_detailed, test_name_case6_detailed, 'beautified', output_dir);
    fprintf('  Applied beautify_figure with log_level = 2.\n');
catch ME
    fprintf('  ERROR during Test Case %d (Log Level 2): %s\n', test_case_idx, ME.message);
end
if ishandle(fig6_detailed); close(fig6_detailed); end
fprintf('  Test Case %d (Log Level Control) complete. Please review command window output for verbosity differences.\n', test_case_idx);
test_case_idx = test_case_idx + 1;

% Test Case 7 (Original Test Case 9): Different Plot Types
fprintf('\n--- Running Test Case %d: Different Plot Types ---\n', test_case_idx);

test_name_case7_errorbar = sprintf('test_case_%02d_errorbar_plot', test_case_idx); % Renamed
fprintf('  Running Sub-case 7.1: Error Bar Plot with default beautification.\n');
fig7_errorbar = figure('Visible', 'off'); % Renamed
x_eb7 = 1:5; y_eb7 = [2 4 3 5 4.5]; err_eb7 = rand(1,5) * 0.5 + 0.2;
errorbar(x_eb7, y_eb7, err_eb7, '-s', 'MarkerSize', 8, 'MarkerEdgeColor','red','MarkerFaceColor','red', 'CapSize', 8);
title([test_name_case7_errorbar ' Original'], 'Interpreter', 'none');
xlabel('Group'); ylabel('Measurement +/- Error'); grid on;
save_comparison_figure(fig7_errorbar, test_name_case7_errorbar, 'original', output_dir);
try
    beautify_figure(fig7_errorbar);
    title([test_name_case7_errorbar ' Beautified'], 'Interpreter', 'none');
    save_comparison_figure(fig7_errorbar, test_name_case7_errorbar, 'beautified', output_dir);
    fprintf('  Applied default beautify_figure to Error Bar Plot.\n');
catch ME
    fprintf('  ERROR during Test Case %d, Sub-case 1 (Error Bar Plot): %s\n', test_case_idx, ME.message);
end
if ishandle(fig7_errorbar); close(fig7_errorbar); end

test_name_case7_histogram = sprintf('test_case_%02d_histogram_plot', test_case_idx); % Renamed
fprintf('  Running Sub-case 7.2: Histogram with default beautification.\n');
fig7_histogram = figure('Visible', 'off'); % Renamed
data_hist7 = randn(1000,1) * 2 + 5;
histogram(data_hist7, 20, 'FaceColor', 'm', 'EdgeColor', 'b');
title([test_name_case7_histogram ' Original'], 'Interpreter', 'none');
xlabel('Value Bins'); ylabel('Frequency'); grid on;
save_comparison_figure(fig7_histogram, test_name_case7_histogram, 'original', output_dir);
try
    beautify_figure(fig7_histogram);
    title([test_name_case7_histogram ' Beautified'], 'Interpreter', 'none');
    save_comparison_figure(fig7_histogram, test_name_case7_histogram, 'beautified', output_dir);
    fprintf('  Applied default beautify_figure to Histogram.\n');
catch ME
    fprintf('  ERROR during Test Case %d, Sub-case 2 (Histogram): %s\n', test_case_idx, ME.message);
end
if ishandle(fig7_histogram); close(fig7_histogram); end
fprintf('  Test Case %d (Different Plot Types) complete.\n', test_case_idx);
test_case_idx = test_case_idx + 1;

% Test Case 8 (Original Test Case 10): Advanced Line Plot Features
fprintf('\n--- Running Test Case %d: Advanced Line Plot Features ---\n', test_case_idx);

test_name_case8_styles = sprintf('test_case_%02d_adv_line_styles_palette', test_case_idx); % Renamed
fprintf('  Running Sub-case 8.1: Cycle Marker/Line Styles & Custom RGB Palette\n');
fig8_styles = figure('Visible', 'off', 'Position', [100,100,700,500]); % Renamed
hold on;
plot(1:10, rand(1,10)+1, 'DisplayName', 'Series 1');
plot(1:10, rand(1,10)+3, 'DisplayName', 'Series 2');
plot(1:10, rand(1,10)+5, 'DisplayName', 'Series 3');
plot(1:10, rand(1,10)+7, 'DisplayName', 'Series 4');
hold off;
title([test_name_case8_styles ' Original'], 'Interpreter', 'none');
xlabel('X-axis'); ylabel('Y-axis'); grid on; legend show;
save_comparison_figure(fig8_styles, test_name_case8_styles, 'original', output_dir);
adv_line_params_tc8.cycle_marker_styles = true; % Renamed
adv_line_params_tc8.cycle_line_styles = true;
adv_line_params_tc8.custom_color_palette = [[1 0 0]; [0 1 0]; [0 0 1]; [1 0 1]];
adv_line_params_tc8.color_palette = 'custom';
adv_line_params_tc8.marker_cycle_threshold = 2; 
adv_line_params_tc8.line_style_cycle_threshold = 1; 
fprintf('  Params: cycle_marker_styles=true, cycle_line_styles=true, custom RGB palette, color_palette=''custom''\n');
try
    adv_line_params_tc8.figure_handle = fig8_styles;
    beautify_figure(adv_line_params_tc8);
    title([test_name_case8_styles ' Beautified'], 'Interpreter', 'none');
    save_comparison_figure(fig8_styles, test_name_case8_styles, 'beautified', output_dir);
    fprintf('  Applied beautify_figure for cycle styles & custom palette.\n');
catch ME
    fprintf('  ERROR during Test Case %d, Sub-case 1 (Cycle Styles): %s\n', test_case_idx, ME.message);
end
if ishandle(fig8_styles); close(fig8_styles); end

test_name_case8_fontscale = sprintf('test_case_%02d_adv_font_scale', test_case_idx); % Renamed
fprintf('  Running Sub-case 8.2: Global Font Scale Factor\n');
fig8_fontscale1 = figure('Visible', 'off'); % Renamed
plot(1:10, rand(1,10));
title([test_name_case8_fontscale ' Original (Scale 1.0)'], 'Interpreter', 'none');
xlabel('X-axis'); ylabel('Y-axis');
save_comparison_figure(fig8_fontscale1, [test_name_case8_fontscale '_scale_1_0'], 'original', output_dir);
font_scale_params1_tc8.global_font_scale_factor = 1.0; % Renamed
try
    font_scale_params1_tc8.figure_handle = fig8_fontscale1;
    beautify_figure(font_scale_params1_tc8);
    title([test_name_case8_fontscale ' Beautified (Scale 1.0)'], 'Interpreter', 'none');
    save_comparison_figure(fig8_fontscale1, [test_name_case8_fontscale '_scale_1_0'], 'beautified', output_dir);
    fprintf('  Applied beautify_figure with global_font_scale_factor = 1.0\n');
catch ME
    fprintf('  ERROR during Test Case %d, Sub-case 2 (Font Scale 1.0): %s\n', test_case_idx, ME.message);
end
if ishandle(fig8_fontscale1); close(fig8_fontscale1); end

fig8_fontscale2 = figure('Visible', 'off'); % Renamed
plot(1:10, rand(1,10));
title([test_name_case8_fontscale ' Original (Scale 1.5)'], 'Interpreter', 'none');
xlabel('X-axis'); ylabel('Y-axis');
save_comparison_figure(fig8_fontscale2, [test_name_case8_fontscale '_scale_1_5'], 'original', output_dir);
font_scale_params2_tc8.global_font_scale_factor = 1.5; % Renamed
fprintf('  Params: global_font_scale_factor = 1.5\n');
try
    font_scale_params2_tc8.figure_handle = fig8_fontscale2;
    beautify_figure(font_scale_params2_tc8);
    title([test_name_case8_fontscale ' Beautified (Scale 1.5)'], 'Interpreter', 'none');
    save_comparison_figure(fig8_fontscale2, [test_name_case8_fontscale '_scale_1_5'], 'beautified', output_dir);
    fprintf('  Applied beautify_figure with global_font_scale_factor = 1.5\n');
catch ME
    fprintf('  ERROR during Test Case %d, Sub-case 2 (Font Scale 1.5): %s\n', test_case_idx, ME.message);
end
if ishandle(fig8_fontscale2); close(fig8_fontscale2); end
test_case_idx = test_case_idx + 1;

% Test Case 9 (Original Test Case 11): Axes Styling Options
fprintf('\n--- Running Test Case %d: Axes Styling Options ---\n', test_case_idx);

test_name_case9_box_off = sprintf('test_case_%02d_axes_box_off', test_case_idx); % Renamed
fprintf('  Running Sub-case 9.1: axis_box_style = ''off''\n');
fig9_box_off = figure('Visible', 'off'); % Renamed
plot(1:10, rand(1,10));
title([test_name_case9_box_off ' Original'], 'Interpreter', 'none');
xlabel('X-axis'); ylabel('Y-axis'); grid on;
save_comparison_figure(fig9_box_off, test_name_case9_box_off, 'original', output_dir);
box_off_params_tc9.axis_box_style = 'off'; % Renamed
fprintf('  Params: axis_box_style = ''off''\n');
try
    box_off_params_tc9.figure_handle = fig9_box_off;
    beautify_figure(box_off_params_tc9);
    title([test_name_case9_box_off ' Beautified (Box Off)'], 'Interpreter', 'none');
    save_comparison_figure(fig9_box_off, test_name_case9_box_off, 'beautified', output_dir);
    fprintf('  Applied beautify_figure with axis_box_style = ''off''.\n');
catch ME
    fprintf('  ERROR during Test Case %d, Sub-case 1 (Box Off): %s\n', test_case_idx, ME.message);
end
if ishandle(fig9_box_off); close(fig9_box_off); end

test_name_case9_layer_bottom = sprintf('test_case_%02d_axes_layer_bottom', test_case_idx); % Renamed
fprintf('  Running Sub-case 9.2: axes_layer = ''bottom''\n');
fig9_layer_bottom = figure('Visible', 'off'); % Renamed
hold on;
plot(1:0.1:10, sin(1:0.1:10), 'b', 'LineWidth', 2);
patch([2 4 4 2], [-0.5 -0.5 0.5 0.5], 'red', 'FaceAlpha', 0.3, 'EdgeColor', 'none');
hold off; grid on;
title([test_name_case9_layer_bottom ' Original'], 'Interpreter', 'none');
xlabel('X-axis'); ylabel('Y-axis');
legend({'Line', 'Patch'}, 'Location', 'northwest');
save_comparison_figure(fig9_layer_bottom, test_name_case9_layer_bottom, 'original', output_dir);
layer_bottom_params_tc9.axes_layer = 'bottom'; % Renamed
layer_bottom_params_tc9.grid_density = 'normal'; 
fprintf('  Params: axes_layer = ''bottom'', grid_density = ''normal''\n');
try
    layer_bottom_params_tc9.figure_handle = fig9_layer_bottom;
    beautify_figure(layer_bottom_params_tc9);
    title([test_name_case9_layer_bottom ' Beautified (Layer Bottom)'], 'Interpreter', 'none');
    save_comparison_figure(fig9_layer_bottom, test_name_case9_layer_bottom, 'beautified', output_dir);
    fprintf('  Applied beautify_figure with axes_layer = ''bottom''. Grid lines should be behind plot elements.\n');
catch ME
    fprintf('  ERROR during Test Case %d, Sub-case 2 (Layer Bottom): %s\n', test_case_idx, ME.message);
end
if ishandle(fig9_layer_bottom); close(fig9_layer_bottom); end
test_case_idx = test_case_idx + 1;

% Test Case 10 (Original Test Case 12): Legend Specifics
fprintf('\n--- Running Test Case %d: Legend Specifics ---\n', test_case_idx);

test_name_case10_location = sprintf('test_case_%02d_legend_location_interactive', test_case_idx); % Renamed
fprintf('  Running Sub-case 10.1: legend_location & interactive_legend=true\n');
fig10_loc = figure('Visible', 'off'); % Renamed
hold on;
plot(1:10, rand(1,10), 'DisplayName', 'Data A');
plot(1:10, rand(1,10)+1, 'DisplayName', 'Data B');
hold off;
title([test_name_case10_location ' Original'], 'Interpreter', 'none');
xlabel('X'); ylabel('Y'); grid on; legend show;
save_comparison_figure(fig10_loc, test_name_case10_location, 'original', output_dir);
leg_loc_params_tc10.legend_location = 'northeastoutside'; % Renamed
leg_loc_params_tc10.interactive_legend = true;
fprintf('  Params: legend_location=''northeastoutside'', interactive_legend=true\n');
try
    leg_loc_params_tc10.figure_handle = fig10_loc;
    beautify_figure(leg_loc_params_tc10);
    title([test_name_case10_location ' Beautified (Legend NE Outside, Interactive)'], 'Interpreter', 'none');
    save_comparison_figure(fig10_loc, test_name_case10_location, 'beautified', output_dir);
    fprintf('  Applied beautify_figure. Check legend position and for no errors with interactive_legend.\n');
catch ME
    fprintf('  ERROR during Test Case %d, Sub-case 1 (Legend Location/Interactive): %s\n', test_case_idx, ME.message);
end
if ishandle(fig10_loc); close(fig10_loc); end

test_name_case10_smart = sprintf('test_case_%02d_legend_smart_false', test_case_idx); % Renamed
fprintf('  Running Sub-case 10.2: smart_legend_display = false (single item legend)\n');
fig10_smart = figure('Visible', 'off'); % Renamed
plot(1:10, rand(1,10), 'DisplayName', 'Single Series');
title([test_name_case10_smart ' Original (No Legend Expected)'], 'Interpreter', 'none');
xlabel('X'); ylabel('Y'); grid on;
save_comparison_figure(fig10_smart, test_name_case10_smart, 'original', output_dir);
leg_smart_params_tc10.smart_legend_display = false; % Renamed
leg_smart_params_tc10.legend_force_single_entry = true;
fprintf('  Params: smart_legend_display=false, legend_force_single_entry=true\n');
try
    leg_smart_params_tc10.figure_handle = fig10_smart;
    beautify_figure(leg_smart_params_tc10);
    title([test_name_case10_smart ' Beautified (Legend Forced for Single Item)'], 'Interpreter', 'none');
    save_comparison_figure(fig10_smart, test_name_case10_smart, 'beautified', output_dir);
    fprintf('  Applied beautify_figure. Legend should be visible for the single series.\n');
catch ME
    fprintf('  ERROR during Test Case %d, Sub-case 2 (Smart Legend False): %s\n', test_case_idx, ME.message);
end
if ishandle(fig10_smart); close(fig10_smart); end
test_case_idx = test_case_idx + 1;

% Test Case 11 (Original Test Case 13): Plot with Colorbar
test_name_case11_colorbar = sprintf('test_case_%02d_plot_with_colorbar', test_case_idx); % Renamed
fprintf('\n--- Running Test Case %d: Plot with Colorbar (Default Beautification) ---\n', test_case_idx);
fig11_cb = figure('Visible', 'off'); % Renamed
[X_cb11, Y_cb11, Z_cb11] = peaks(25); % Renamed
contourf(X_cb11, Y_cb11, Z_cb11, 10);
h_cb11 = colorbar; % Renamed
xlabel('X-axis'); ylabel('Y-axis');
title([test_name_case11_colorbar ' Original'], 'Interpreter', 'none');
ylabel(h_cb11, 'Colorbar Units');
save_comparison_figure(fig11_cb, test_name_case11_colorbar, 'original', output_dir);
fprintf('  Applying default beautify_figure. Expect colorbar to be beautified.\n');
try
    beautify_figure(fig11_cb);
    title([test_name_case11_colorbar ' Beautified'], 'Interpreter', 'none');
    save_comparison_figure(fig11_cb, test_name_case11_colorbar, 'beautified', output_dir);
    fprintf('  Applied default beautify_figure. Check appearance of plot and colorbar.\n');
catch ME
    fprintf('  ERROR during Test Case %d (Plot with Colorbar): %s\n', test_case_idx, ME.message);
end
if ishandle(fig11_cb); close(fig11_cb); end
test_case_idx = test_case_idx + 1;

% Test Case 12 (Original Test Case 14): Polar Plot
test_name_case12_polar = sprintf('test_case_%02d_polar_plot', test_case_idx); % Renamed
fprintf('\n--- Running Test Case %d: Polar Plot (Default Beautification) ---\n', test_case_idx);
fig12_polar = figure('Visible', 'off'); % Renamed
theta12 = 0:0.01:2*pi; rho12 = abs(sin(2*theta12).*cos(2*theta12));
polarplot(theta12, rho12, 'r', 'LineWidth', 1.5);
pax12 = gca; % Renamed
pax12.ThetaZeroLocation = 'top'; pax12.ThetaDir = 'clockwise';
title([test_name_case12_polar ' Original'], 'Interpreter', 'none');
save_comparison_figure(fig12_polar, test_name_case12_polar, 'original', output_dir);
fprintf('  Applying default beautify_figure. Expect polar plot to be beautified.\n');
try
    beautify_figure(fig12_polar);
    title([test_name_case12_polar ' Beautified'], 'Interpreter', 'none'); 
    save_comparison_figure(fig12_polar, test_name_case12_polar, 'beautified', output_dir);
    fprintf('  Applied default beautify_figure. Check appearance of polar plot.\n');
catch ME
    fprintf('  ERROR during Test Case %d (Polar Plot): %s\n', test_case_idx, ME.message);
end
if ishandle(fig12_polar); close(fig12_polar); end
test_case_idx = test_case_idx + 1;

% Test Case 13 (Original Test Case 15): LaTeX in Labels
test_name_case13_latex = sprintf('test_case_%02d_latex_labels', test_case_idx); % Renamed
fprintf('\n--- Running Test Case %d: LaTeX in Labels (Default Beautification) ---\n', test_case_idx);
fig13_latex = figure('Visible', 'off'); % Renamed
x_latex13 = 0:0.1:2*pi; y_latex13 = sin(x_latex13);
plot(x_latex13, y_latex13, 'LineWidth', 1);
title_str_orig13 = 'Plot of $y = \sin(x)$ with $\Sigma_{i=1}^N x_i$';
xlabel_str_orig13 = 'Angle $\theta$ (radians)';
ylabel_str_orig13 = 'Amplitude $\alpha^2$';
title(title_str_orig13, 'Interpreter', 'latex');
xlabel(xlabel_str_orig13, 'Interpreter', 'latex');
ylabel(ylabel_str_orig13, 'Interpreter', 'latex');
grid on;
save_comparison_figure(fig13_latex, test_name_case13_latex, 'original', output_dir);
fprintf('  Applying default beautify_figure. Expect LaTeX in labels to be rendered correctly.\n');
fprintf('  Original title: %s\n', title_str_orig13);
fprintf('  Original xlabel: %s\n', xlabel_str_orig13);
fprintf('  Original ylabel: %s\n', ylabel_str_orig13);
try
    beautify_figure(fig13_latex);
    current_title13 = get(get(gca,'Title'),'String'); % Renamed
    current_xlabel13 = get(get(gca,'XLabel'),'String'); % Renamed
    current_ylabel13 = get(get(gca,'YLabel'),'String'); % Renamed
    fprintf('  Beautified title string (may differ slightly due to processing): %s\n', current_title13);
    fprintf('  Beautified xlabel string: %s\n', current_xlabel13);
    fprintf('  Beautified ylabel string: %s\n', current_ylabel13);
    title([test_name_case13_latex ' Beautified (LaTeX Check)'], 'Interpreter', 'none');
    save_comparison_figure(fig13_latex, test_name_case13_latex, 'beautified', output_dir);
    fprintf('  Applied default beautify_figure. Check appearance of LaTeX in labels in the saved image.\n');
catch ME
    fprintf('  ERROR during Test Case %d (LaTeX in Labels): %s\n', test_case_idx, ME.message);
end
if ishandle(fig13_latex); close(fig13_latex); end
test_case_idx = test_case_idx + 1;

% Test Case 14 (Original Test Case 16): Object Exclusion
test_name_case14_exclusion = sprintf('test_case_%02d_object_exclusion', test_case_idx); % Renamed
fprintf('\n--- Running Test Case %d: Object Exclusion by Tag ---\n', test_case_idx);
fig14_exclude = figure('Visible', 'off'); % Renamed
hold on;
line1_tc14 = plot(1:10, rand(1,10)+2, 'LineWidth', 1, 'Color', 'blue', 'Marker', 'o'); % Renamed
line2_tc14 = plot(1:10, rand(1,10), 'LineWidth', 3, 'Color', 'red', 'Marker', 'x', 'Tag', 'ExcludeThisLine'); % Renamed
hold off;
title([test_name_case14_exclusion ' Original'], 'Interpreter', 'none');
xlabel('X-axis'); ylabel('Y-axis'); grid on;
legend({'Line 1 (Beautify)', 'Line 2 (Exclude)'});
original_line2_lw_tc14 = line2_tc14.LineWidth; % Renamed
original_line2_color_tc14 = line2_tc14.Color; % Renamed
original_line2_marker_tc14 = line2_tc14.Marker; % Renamed
save_comparison_figure(fig14_exclude, test_name_case14_exclusion, 'original', output_dir);
exclude_params_tc14.exclude_object_tags = {'ExcludeThisLine'}; % Renamed
exclude_params_tc14.plot_line_width = 0.5; 
exclude_params_tc14.color_palette = 'lines';
fprintf('  Excluding objects with tag ''ExcludeThisLine''. Applying plot_line_width=0.5.\n');
try
    exclude_params_tc14.figure_handle = fig14_exclude;
    beautify_figure(exclude_params_tc14);
    title([test_name_case14_exclusion ' Beautified (One Line Excluded)'], 'Interpreter', 'none');
    save_comparison_figure(fig14_exclude, test_name_case14_exclusion, 'beautified', output_dir);
    fprintf('  Performing programmatic verification for excluded object...\n');
    if isvalid(line2_tc14) && ...
       abs(line2_tc14.LineWidth - original_line2_lw_tc14) < 1e-6 && ...
       isequal(line2_tc14.Color, original_line2_color_tc14) && ...
       strcmp(line2_tc14.Marker, original_line2_marker_tc14)
        fprintf('  TEST RESULT (Test Case %d - Object Exclusion Verification): PASS - Tagged line correctly retained its original style.\n', test_case_idx);
    else
        fprintf('  TEST RESULT (Test Case %d - Object Exclusion Verification): FAIL - Tagged line style changed or handle is invalid.\n', test_case_idx);
        if ~isvalid(line2_tc14)
            fprintf('    ERROR: Handle for line2_tc14 became invalid after beautification.\n');
        else
            if abs(line2_tc14.LineWidth - original_line2_lw_tc14) >= 1e-6
                fprintf('    LineWidth mismatch: Current LW: %.2f (Original: %.2f)\n', line2_tc14.LineWidth, original_line2_lw_tc14);
            end
            if ~isequal(line2_tc14.Color, original_line2_color_tc14)
                fprintf('    Color mismatch: Current Color: [%.2f %.2f %.2f] (Original: [%.2f %.2f %.2f])\n', line2_tc14.Color, original_line2_color_tc14);
            end
            if ~strcmp(line2_tc14.Marker, original_line2_marker_tc14)
                fprintf('    Marker mismatch: Current Marker: %s (Original: %s)\n', line2_tc14.Marker, original_line2_marker_tc14);
            end
        end
    end
    fprintf('  Visual check: The red, thick, x-marked line should have retained its original style in the saved image.\n');
catch ME
    fprintf('  ERROR during Test Case %d (Object Exclusion): %s\n', test_case_idx, ME.message);
end
if ishandle(fig14_exclude); close(fig14_exclude); end
test_case_idx = test_case_idx + 1;

% Test Case 15 (Original Test Case 17): Empty Figure
fprintf('\n--- Running Test Case %d: Empty Figure ---\n', test_case_idx);
test_name_case15_empty = sprintf('test_case_%02d_empty_figure', test_case_idx); % Renamed
fig15_empty = figure('Visible', 'off'); % Renamed
fprintf('  Created an empty figure (no axes, no data).\n');
save_comparison_figure(fig15_empty, test_name_case15_empty, 'original', output_dir);
fprintf('  Applying beautify_figure() to the empty figure.\n');
error_occurred_empty_fig_test_tc15 = false; % Renamed
try
    beautify_figure(fig15_empty);
    fprintf('  Successfully applied beautify_figure() to an empty figure.\n');
catch ME
    fprintf('  ERROR during Test Case %d (Empty Figure): %s\n', test_case_idx, ME.message);
    error_occurred_empty_fig_test_tc15 = true;
end
if ~error_occurred_empty_fig_test_tc15
    save_comparison_figure(fig15_empty, test_name_case15_empty, 'beautified', output_dir);
else
    fprintf('  Skipping save of "beautified" empty figure due to error during beautification.\n');
end
if ishandle(fig15_empty); close(fig15_empty); end
test_case_idx = test_case_idx + 1;

% Test Case 16 (Original Test Case 18): Figure with UI Tabs
fprintf('\n--- Running Test Case %d: Figure with UI Tabs ---\n', test_case_idx);
test_name_case16_uitabs = sprintf('test_case_%02d_uitabs_figure', test_case_idx); % Renamed
fig16_tabs = figure('Visible', 'off', 'Position', [100, 100, 700, 500]); % Renamed
fprintf('  Created a figure with UI tabs.\n');
tab_group16 = uitabgroup(fig16_tabs); % Renamed
tab1_tc16 = uitab(tab_group16, 'Title', 'First Tab'); % Renamed
ax1_tab16 = axes(tab1_tc16); % Renamed
plot(ax1_tab16, 1:10, rand(1,10).* (1:10), 'r-o');
title(ax1_tab16, 'Plot in Tab 1'); xlabel(ax1_tab16, 'X-Tab1'); ylabel(ax1_tab16, 'Y-Tab1'); grid(ax1_tab16, 'on');
tab2_tc16 = uitab(tab_group16, 'Title', 'Second Tab'); % Renamed
ax2_tab16 = axes(tab2_tc16); % Renamed
scatter(ax2_tab16, rand(20,1), rand(20,1)*5, 36, 'b', 'filled', 'Marker', '*');
title(ax2_tab16, 'Plot in Tab 2'); xlabel(ax2_tab16, 'X-Tab2'); ylabel(ax2_tab16, 'Y-Tab2'); grid(ax2_tab16, 'on');
try sgtitle(fig16_tabs, [test_name_case16_uitabs ' Original'], 'Interpreter', 'none'); catch; end
save_comparison_figure(fig16_tabs, test_name_case16_uitabs, 'original', output_dir);
fprintf('  Applying beautify_figure() to the figure with UI tabs.\n');
error_occurred_uitab_fig_test_tc16 = false; % Renamed
try
    beautify_figure(fig16_tabs); 
    fprintf('  Successfully applied beautify_figure() to a figure with UI tabs.\n');
    try sgtitle(fig16_tabs, [test_name_case16_uitabs ' Beautified'], 'Interpreter', 'none'); catch; end
catch ME
    fprintf('  ERROR during Test Case %d (UI Tabs Figure): %s\n', test_case_idx, ME.message);
    error_occurred_uitab_fig_test_tc16 = true;
end
if ~error_occurred_uitab_fig_test_tc16
    if isvalid(tab_group16) && ~isempty(tab_group16.Children)
        tab_group16.SelectedTab = tab1_tc16; 
        drawnow;
    end
    save_comparison_figure(fig16_tabs, test_name_case16_uitabs, 'beautified', output_dir);
else
    fprintf('  Skipping save of "beautified" UI tab figure due to error during beautification.\n');
end
if ishandle(fig16_tabs); close(fig16_tabs); end
test_case_idx = test_case_idx + 1;

% Test Case 17 (Original Test Case 19): Invalid Parameters
fprintf('\n--- Running Test Case %d: Invalid Parameters ---\n', test_case_idx);
test_name_case17_invalid = sprintf('test_case_%02d_invalid_params', test_case_idx); % Renamed
fig17_invalid = figure('Visible', 'off'); % Renamed
plot(1:10, rand(1,10));
title([test_name_case17_invalid ' Original'], 'Interpreter', 'none');
xlabel('X-axis'); ylabel('Y-axis'); grid on;
save_comparison_figure(fig17_invalid, test_name_case17_invalid, 'original', output_dir);

invalid_params_tc17.font_name = 123; % Renamed
invalid_params_tc17.plot_line_width = 'not_a_number';
invalid_params_tc17.theme = 'non_existent_theme';
invalid_params_tc17.log_level = 2;
invalid_params_tc17.export_settings = 'not_a_struct';
% invalid_params_tc17.panel_labeling.enabled = 'maybe'; % Panel labeling removed
invalid_params_tc17.stats_overlay.precision = -1.5;
fprintf('  Defined invalid parameters: font_name=123, plot_line_width=''not_a_number'', theme=''non_existent_theme'', export_settings=''not_a_struct'', stats_overlay.precision=-1.5 \n'); % Panel labeling removed from message

error_occurred_invalid_params_test_tc17 = false; % Renamed
console_output_tc17 = ''; % Renamed

missing_warnings_details_tc17 = {}; % Renamed

% Initialize expected_warnings_found_tc17 and its fields to false
expected_warnings_found_tc17 = struct();
expected_warnings_found_tc17.font_name = false;
expected_warnings_found_tc17.plot_line_width = false;
expected_warnings_found_tc17.theme = false;
expected_warnings_found_tc17.export_settings_type = false;
expected_warnings_found_tc17.stats_overlay_precision_value = false;

try
    fprintf('  Applying beautify_figure() with intentionally invalid parameters. Expect warnings in console output.\n');
    invalid_params_tc17.figure_handle = fig17_invalid;
    console_output_tc17 = evalc('beautify_figure(invalid_params_tc17)');
    fprintf('  beautify_figure() completed execution.\n');
    
    if contains(console_output_tc17, 'Invalid value for font_name', 'IgnoreCase', true) || contains(console_output_tc17, 'Invalid type for font_name', 'IgnoreCase', true)
        expected_warnings_found_tc17.font_name = true;
    end
    if contains(console_output_tc17, 'Invalid value for plot_line_width', 'IgnoreCase', true)
        expected_warnings_found_tc17.plot_line_width = true;
    end
    if contains(console_output_tc17, 'Invalid value for theme', 'IgnoreCase', true) || contains(console_output_tc17, 'Unknown style preset', 'IgnoreCase', true)
        expected_warnings_found_tc17.theme = true;
    end
    if contains(console_output_tc17, 'Parameter ''export_settings'' is not a struct', 'IgnoreCase', true)
        expected_warnings_found_tc17.export_settings_type = true;
    end
    % Panel labeling check removed
    if contains(console_output_tc17, 'Invalid value for stats_overlay.precision', 'IgnoreCase', true)
        expected_warnings_found_tc17.stats_overlay_precision_value = true;
    end
catch ME
    fprintf('  CRITICAL ERROR: beautify_figure() crashed with invalid parameters: %s\n', ME.message);
    fprintf('  Stack trace:\n');
    for k_stack = 1:length(ME.stack)
        fprintf('    File: %s, Name: %s, Line: %d\n', ME.stack(k_stack).file, ME.stack(k_stack).name, ME.stack(k_stack).line);
    end
    fprintf('  This test expects graceful handling (warnings/logging), not a crash.\n');
    error_occurred_invalid_params_test_tc17 = true;
end

if ishandle(fig17_invalid)
    title([test_name_case17_invalid ' After Invalid Params Attempt'], 'Interpreter', 'none');
    save_comparison_figure(fig17_invalid, test_name_case17_invalid, 'beautified_after_invalid_attempt', output_dir);
else
    fprintf('  Figure handle for invalid params test became invalid. Cannot save "beautified" state.\n');
end
if ishandle(fig17_invalid); close(fig17_invalid); end

all_warnings_detected_tc17 = all(struct2array(expected_warnings_found_tc17)); % Renamed
if error_occurred_invalid_params_test_tc17
    fprintf('  TEST RESULT (Test Case %d - Invalid Parameters): FAIL - beautify_figure crashed.\n', test_case_idx);
elseif ~all_warnings_detected_tc17
    fprintf('  TEST RESULT (Test Case %d - Invalid Parameters): FAIL - beautify_figure did not crash, but some expected warnings were NOT found.\n', test_case_idx);
    warning_fields_tc17 = fieldnames(expected_warnings_found_tc17); % Renamed
    for k_wf = 1:length(warning_fields_tc17)
        if ~expected_warnings_found_tc17.(warning_fields_tc17{k_wf})
            missing_warnings_details_tc17{end+1} = sprintf('Missing expected warning related to: %s', warning_fields_tc17{k_wf});
            fprintf('    - %s\n', missing_warnings_details_tc17{end});
        end
    end
    fprintf('  Captured console output for review:\n%s\n', console_output_tc17);
else
    fprintf('  TEST RESULT (Test Case %d - Invalid Parameters): PASS - beautify_figure did not crash and all expected warnings were found.\n', test_case_idx);
    fprintf('  Captured console output (contains expected warnings):\n%s\n', console_output_tc17);
end
test_case_idx = test_case_idx + 1;

%% Teardown
fprintf('\n--- Test Script Complete ---\n');
fprintf('Please check the "%s" directory for saved figures.\n', output_dir);
fprintf('For Test Case 6 (Log Level), please check the MATLAB command window output during the test run.\n'); % Updated TC number

% Close all figures
% close all; 
fprintf('Done.\n');

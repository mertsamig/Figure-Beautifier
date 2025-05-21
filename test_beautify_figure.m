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
%   - For Test Case 8 (Log Level Control), you will be prompted to press Enter
%     to continue. Observe the MATLAB Command Window for differences in
%     output verbosity from `beautify_figure.m` during this test.
%   - "Original" and "Beautified" figures for each test case (or sub-case)
%     will be saved as PNG images in a subdirectory named 'test_beautify_output'
%     (created in the same directory where this script is run).
%   - At the end, a "Test Script Complete" message will be displayed. You can
%     then inspect the generated images in the 'test_beautify_output' folder.
%   - Figures generated during the tests are closed automatically after each
%     test case or sub-case to avoid clutter, except potentially the very
%     last one if `close all` in Teardown is commented out.
%
% Interpreting Results:
%   - Visually compare the 'original' and 'beautified' PNG images for each
%     test case in the 'test_beautify_output' directory.
%   - Check for any error messages in the MATLAB Command Window.
%   - For Test Case 6 (Export Functionality), verify that additional .png
%     and .pdf files (e.g., 'exported_figure_case_06.png', 
%     'exported_figure_case_06.pdf') are created in the output directory.
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
% Function to save and compare figures (will be detailed in Plan Step 2)
% For now, a placeholder or a simple save function.
function save_comparison_figure(fig_handle, test_name, stage, output_dir_local)
    % stage can be 'original' or 'beautified'
    
    % Check if fig_handle is a valid figure handle
    if ~ishandle(fig_handle) || ~strcmp(get(fig_handle, 'Type'), 'figure')
        fprintf('ERROR: Invalid figure handle provided to save_comparison_figure for test: %s, stage: %s.\n', test_name, stage);
        return;
    end
    
    filename = fullfile(output_dir_local, sprintf('%s_%s.png', test_name, stage));
    try
        % Ensure figure is rendered before saving
        drawnow; 
        % For headless environments or ensuring proper saving, make figure visible briefly
        original_visibility = get(fig_handle, 'Visible');
        if strcmp(original_visibility, 'off')
            set(fig_handle, 'Visible', 'on');
            drawnow;
        end
        saveas(fig_handle, filename);
        fprintf('Saved: %s\n', filename);
        if strcmp(original_visibility, 'off') % Restore original visibility
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

% Create a simple line plot
fig1 = figure('Visible', 'off'); % Create invisible figure
plot(1:10, rand(1,10).* (1:10));
title([test_name_case1 ' Original']);
xlabel('X-axis');
ylabel('Y-axis');

% Save the original figure
save_comparison_figure(fig1, test_name_case1, 'original', output_dir);

% Apply beautify_figure() with no arguments
try
    beautify_figure(fig1); % Apply to the specific figure handle
    title([test_name_case1 ' Beautified']); % Update title
    fprintf('Applied beautify_figure() with default settings.\n');
    % Save the beautified figure
    save_comparison_figure(fig1, test_name_case1, 'beautified', output_dir);
catch ME
    fprintf('ERROR during Test Case 1 (Default Beautification): %s\n', ME.message);
end

% Close the figure for this test case
if ishandle(fig1); close(fig1); end

test_case_idx = test_case_idx + 1;

% --- Test Case 2: Style Presets ---
fprintf('\n--- Running Test Case %d: Style Presets ---\n', test_case_idx);
style_presets = {'default', 'publication', 'presentation_dark', 'presentation_light', 'minimalist'};

style_presets = {'default', 'publication', 'presentation_dark', 'presentation_light', 'minimalist'};
params_preset = struct(); % Define params_preset struct once before the loop

for i = 1:length(style_presets)
    current_preset = style_presets{i};
    test_name_case2 = sprintf('test_case_%02d_preset_%s', test_case_idx, current_preset);
    
    fprintf('  Testing preset: %s\n', current_preset);

    % Create a figure with two subplots
    fig2 = figure('Visible', 'off');
    subplot(1,2,1);
    plot(1:10, sin(1:10));
    title('Sine Wave');
    xlabel('X1');
    ylabel('Y1');

    subplot(1,2,2);
    scatter(rand(20,1), rand(20,1)*5, 'filled');
    title('Scatter Plot');
    xlabel('X2');
    ylabel('Y2');
    
    sgtitle([test_name_case2 ' Original']); % Super title for the whole figure

    % Save the original figure (for each preset, to have a clean comparison pair)
    save_comparison_figure(fig2, test_name_case2, 'original', output_dir);

    % Apply beautify_figure() with the current preset
    try
        params_preset.style_preset = current_preset; % Set the current preset
        beautify_figure(fig2, params_preset); % Apply to the specific figure handle
        sgtitle([test_name_case2 ' Beautified (' current_preset ')']); % Update super title
        fprintf('  Applied beautify_figure() with preset: %s\n', current_preset);
        
        % Save the beautified figure
        save_comparison_figure(fig2, test_name_case2, 'beautified', output_dir);
    catch ME
        fprintf('  ERROR during Test Case 2 (Preset: %s): %s\n', current_preset, ME.message);
    end

    % Close the figure for this specific preset test
    if ishandle(fig2); close(fig2); end
end

test_case_idx = test_case_idx + 1;

% --- Test Case 3: Specific Parameter Customization ---
fprintf('\n--- Running Test Case %d: Specific Parameter Customization ---\n', test_case_idx);
test_name_case3 = sprintf('test_case_%02d_custom_params', test_case_idx);

% Create a bar plot
fig3 = figure('Visible', 'off');
bar_data = rand(1,5)*10;
bar(bar_data);
title([test_name_case3 ' Original']);
xlabel('Category');
ylabel('Value');
set(gca, 'XTickLabel', {'A', 'B', 'C', 'D', 'E'});

% Save the original figure
save_comparison_figure(fig3, test_name_case3, 'original', output_dir);

% Define custom parameters
custom_params.theme = 'dark';
custom_params.font_name = 'Arial'; % A commonly available font
custom_params.plot_line_width = 2.5; % Bar edges are often related to line width
custom_params.color_palette = 'viridis'; % A perceptually uniform colormap
custom_params.grid_density = 'major_only';
% For bar plots, FaceColor might be more directly relevant than plot_line_width for the bars themselves.
% beautify_figure might handle this internally or apply plot_line_width to bar edges.
% The color_palette will likely affect the bar face colors.

fprintf('  Applying custom parameters: theme=''dark'', font_name=''Arial'', plot_line_width=2.5, color_palette=''viridis'', grid_density=''major_only''\n');

% Apply beautify_figure() with custom parameters
try
    beautify_figure(fig3, custom_params); % Apply to the specific figure handle
    title([test_name_case3 ' Beautified (Custom)']); % Update title
    fprintf('  Applied beautify_figure() with custom parameters.\n');
    
    % Save the beautified figure
    save_comparison_figure(fig3, test_name_case3, 'beautified', output_dir);
catch ME
    fprintf('  ERROR during Test Case 3 (Custom Parameters): %s\n', ME.message);
end

% Close the figure for this test case
if ishandle(fig3); close(fig3); end

test_case_idx = test_case_idx + 1;

% --- Test Case 4: Panel Labeling ---
fprintf('\n--- Running Test Case %d: Panel Labeling ---\n', test_case_idx);
test_name_case4 = sprintf('test_case_%02d_panel_labeling', test_case_idx);

% Create a figure with a 2x2 tiled layout
fig4 = figure('Visible', 'off', 'Position', [100, 100, 800, 700]); % Larger figure for tiled layout
tcl = tiledlayout(2,2, 'Padding', 'compact', 'TileSpacing', 'compact');
title(tcl, [test_name_case4 ' Original']); % Title for the tiled layout

% Add 4 plots
ax1 = nexttile;
plot(ax1, 1:10, rand(1,10));
title(ax1, 'Plot 1');

ax2 = nexttile;
scatter(ax2, rand(10,1), rand(10,1), 'r', 'filled');
title(ax2, 'Plot 2');

ax3 = nexttile;
plot(ax3, 1:20, cos((1:20)/pi));
title(ax3, 'Plot 3');

ax4 = nexttile;
bar(ax4, rand(1,3));
title(ax4, 'Plot 4');

% Save the original figure
save_comparison_figure(fig4, test_name_case4, 'original', output_dir);

% Define panel labeling parameters
panel_params.panel_labeling.enabled = true;
panel_params.panel_labeling.style = 'A';
panel_params.panel_labeling.position = 'northwest_inset';
panel_params.panel_labeling.font_scale_factor = 1.1;
panel_params.panel_labeling.font_weight = 'bold';
% panel_params.base_font_size = 8; % Example of potentially reducing base font size for dense plots

fprintf('  Enabling panel labeling: style=''A'', position=''northwest_inset''\n');

% Apply beautify_figure() with panel labeling settings
try
    beautify_figure(fig4, panel_params); % Apply to the specific figure handle
    title(tcl, [test_name_case4 ' Beautified (Panel Labels)']); % Update tiled layout title
    fprintf('  Applied beautify_figure() with panel labeling.\n');
    
    % Save the beautified figure
    save_comparison_figure(fig4, test_name_case4, 'beautified', output_dir);
catch ME
    fprintf('  ERROR during Test Case 4 (Panel Labeling): %s\n', ME.message);
end

% Close the figure for this test case
if ishandle(fig4); close(fig4); end

test_case_idx = test_case_idx + 1;

% --- Test Case 5: Statistics Overlay ---
fprintf('\n--- Running Test Case %d: Statistics Overlay ---\n', test_case_idx);
test_name_case5 = sprintf('test_case_%02d_stats_overlay', test_case_idx);

% Create a line plot with some noise
fig5 = figure('Visible', 'off');
x_data = 1:50;
y_data = 5*sin(x_data/5) + randn(1,50)*2 + 10; % Sinusoidal with noise
plot(x_data, y_data, 'Tag', 'NoisyDataLine', 'LineWidth', 1); % Assign a Tag
title([test_name_case5 ' Original']);
xlabel('Time (s)');
ylabel('Signal Strength (mV)');
grid on;

% Save the original figure
save_comparison_figure(fig5, test_name_case5, 'original', output_dir);

% Define statistics overlay parameters
stats_params.stats_overlay.enabled = true;
stats_params.stats_overlay.target_plot_handle_tag = 'NoisyDataLine';
stats_params.stats_overlay.statistics = {'mean', 'std', 'N', 'min', 'max'};
stats_params.stats_overlay.position = 'northeast_inset';
stats_params.stats_overlay.precision = 3;
stats_params.stats_overlay.font_scale_factor = 0.85;
stats_params.stats_overlay.background_color = [0.95 0.95 0.95]; % Light gray background
stats_params.stats_overlay.edge_color = 'black';

fprintf('  Enabling stats overlay: target_tag=''NoisyDataLine'', stats={''mean'', ''std'', ''N'', ''min'', ''max''}\n');

% Apply beautify_figure() with statistics overlay settings
try
    beautify_figure(fig5, stats_params); % Apply to the specific figure handle
    title([test_name_case5 ' Beautified (Stats Overlay)']); % Update title
    fprintf('  Applied beautify_figure() with statistics overlay.\n');
    
    % Save the beautified figure
    save_comparison_figure(fig5, test_name_case5, 'beautified', output_dir);
catch ME
    fprintf('  ERROR during Test Case 5 (Statistics Overlay): %s\n', ME.message);
end

% Close the figure for this test case
if ishandle(fig5); close(fig5); end

test_case_idx = test_case_idx + 1;

% --- Test Case 6: Export Functionality ---
fprintf('\n--- Running Test Case %d: Export Functionality ---\n', test_case_idx);
test_name_case6 = sprintf('test_case_%02d_export', test_case_idx);
export_filename_base = fullfile(output_dir, sprintf('exported_figure_case_%02d', test_case_idx));

% Create a simple surface plot
fig6 = figure('Visible', 'off');
[X, Y, Z] = peaks(25);
surf(X, Y, Z);
colormap jet; % Use a common colormap
title([test_name_case6 ' Original']);
xlabel('X-axis'); ylabel('Y-axis'); zlabel('Z-axis');
axis tight;

% Save the original figure (as PNG via helper)
save_comparison_figure(fig6, test_name_case6, 'original', output_dir);

% Define export parameters
export_params.export_settings.enabled = true;
export_params.export_settings.filename = export_filename_base; % Base name for export
export_params.export_settings.format = 'png'; % Will export as export_filename_base.png
export_params.export_settings.resolution = 150; % Lower res for test speed
export_params.export_settings.open_exported_file = false; % Do not open during test

% Also test PDF export by running beautify_figure again with different export format
export_params_pdf = export_params;
export_params_pdf.export_settings.format = 'pdf';

fprintf('  Configuring export: PNG and PDF to filenames starting with "%s"\n', export_filename_base);

try
    % --- Test PNG Export ---
    fprintf('  Applying beautify_figure() with PNG export enabled.\n');
    % Need to ensure the figure state is reset if we apply beautify_figure multiple times
    % or make a copy. For this test, let's use the same figure sequentially.
    % The first beautify_figure call will alter fig6.
    beautify_figure(fig6, export_params); 
    title([test_name_case6 ' Beautified (PNG Export Attempted)']);
    
    % Save the beautified figure (as PNG via helper for comparison)
    save_comparison_figure(fig6, test_name_case6, 'beautified_for_png_export_test', output_dir);
    
    % Verify PNG export
    expected_png_file = [export_filename_base '.' export_params.export_settings.format];
    if exist(expected_png_file, 'file')
        fprintf('  SUCCESS: Exported PNG file found: %s\n', expected_png_file);
    else
        fprintf('  FAILURE: Exported PNG file NOT found: %s\n', expected_png_file);
    end

    % --- Test PDF Export ---
    % Re-apply beautification with PDF export settings. 
    % Note: beautify_figure will be applied again to an already beautified figure if not careful.
    % For a clean test, ideally, one would restart with the original figure.
    % However, the primary goal here is to check if the export mechanism works.
    % Let's create a NEW figure for the PDF export test based on the original data for cleaner separation.
    
    fig6_pdf_test = figure('Visible', 'off');
    surf(X,Y,Z); colormap jet; 
    title([test_name_case6 ' Original for PDF']); 
    xlabel('X-axis'); ylabel('Y-axis'); zlabel('Z-axis'); axis tight;
    % No need to save this original via helper, its purpose is for export testing.

    fprintf('  Applying beautify_figure() with PDF export enabled to a fresh figure.\n');
    beautify_figure(fig6_pdf_test, export_params_pdf);
    % No need to save this via helper, its purpose is for export file generation.
    
    % Verify PDF export
    expected_pdf_file = [export_filename_base '.' export_params_pdf.export_settings.format];
    if exist(expected_pdf_file, 'file')
        fprintf('  SUCCESS: Exported PDF file found: %s\n', expected_pdf_file);
    else
        fprintf('  FAILURE: Exported PDF file NOT found: %s\n', expected_pdf_file);
    end
    if ishandle(fig6_pdf_test); close(fig6_pdf_test); end

catch ME
    fprintf('  ERROR during Test Case 6 (Export Functionality): %s\n', ME.message);
end

% Close the main figure for this test case
if ishandle(fig6); close(fig6); end

test_case_idx = test_case_idx + 1;

% --- Test Case 7: Applying to Specific Axes ---
fprintf('\n--- Running Test Case %d: Applying to Specific Axes ---\n', test_case_idx);
test_name_case7 = sprintf('test_case_%02d_specific_axes', test_case_idx);

% Create a figure with two subplots
fig7 = figure('Visible', 'off', 'Position', [100, 100, 900, 400]); % Wider figure
ax1_fig7 = subplot(1,2,1);
plot(ax1_fig7, 1:10, rand(1,10).*exp(0.2*(1:10)));
title(ax1_fig7, 'Subplot 1 (Target for Beautify)');
xlabel(ax1_fig7, 'X1');
ylabel(ax1_fig7, 'Y1');

ax2_fig7 = subplot(1,2,2);
plot(ax2_fig7, 1:10, (10-(1:10)).*rand(1,10));
title(ax2_fig7, 'Subplot 2 (Should Remain Original)');
xlabel(ax2_fig7, 'X2');
ylabel(ax2_fig7, 'Y2');

sgtitle(fig7, [test_name_case7 ' Original']);

% Save the original figure
save_comparison_figure(fig7, test_name_case7, 'original', output_dir);

% Define parameters for the specific axis
% These parameters should make a clear visual difference.
specific_axis_params.base_font_size = 16; % Larger font size
specific_axis_params.font_name = 'Courier New'; % Distinct font
specific_axis_params.theme = 'dark'; 
% Note: Applying a 'dark' theme to only one subplot while the figure background 
% remains default light might look unusual, but it will clearly show if beautify_figure
% correctly targets only the specified axes for font and color changes it controls.
% The figure background itself is a figure-level property.

fprintf('  Applying beautify_figure to first subplot with: base_font_size=16, font_name=''Courier New'', theme=''dark''\n');

% Apply beautify_figure() to the first subplot only
try
    beautify_figure(ax1_fig7, specific_axis_params); % Pass axes handle and params
    sgtitle(fig7, [test_name_case7 ' Beautified (Subplot 1 Only)']); % Update super title
    % The title of ax1_fig7 might be altered by beautify_figure, that's expected.
    fprintf('  Applied beautify_figure() to specific axes.\n');
    
    % Save the beautified figure (showing one modified, one original subplot)
    save_comparison_figure(fig7, test_name_case7, 'beautified', output_dir);
catch ME
    fprintf('  ERROR during Test Case 7 (Specific Axes): %s\n', ME.message);
end

% Close the figure for this test case
if ishandle(fig7); close(fig7); end

test_case_idx = test_case_idx + 1;

% --- Test Case 8: Log Level Control ---
fprintf('\n--- Running Test Case %d: Log Level Control ---\n', test_case_idx);
% This test primarily involves observing command window output.

% --- Sub-case 8.1: Log Level 0 (Silent) ---
test_name_case8_silent = sprintf('test_case_%02d_loglevel_0_silent', test_case_idx);
fprintf('  Running with log_level = 0 (Silent). Expect minimal to no output from beautify_figure.\n');

fig8_silent = figure('Visible', 'off');
plot(1:5, rand(1,5));
title([test_name_case8_silent ' Original']);

% Save original for reference (optional for this test, but good for consistency)
save_comparison_figure(fig8_silent, test_name_case8_silent, 'original', output_dir);

log_params_silent.log_level = 0;
try
    beautify_figure(fig8_silent, log_params_silent);
    title([test_name_case8_silent ' Beautified (Log Level 0)']);
    save_comparison_figure(fig8_silent, test_name_case8_silent, 'beautified', output_dir);
    fprintf('  Applied beautify_figure with log_level = 0.\n');
catch ME
    fprintf('  ERROR during Test Case 8 (Log Level 0): %s\n', ME.message);
end
if ishandle(fig8_silent); close(fig8_silent); end

input('  Press Enter to continue to Log Level 2 (Detailed) test...\n', 's'); % Pause for user to observe

% --- Sub-case 8.2: Log Level 2 (Detailed) ---
test_name_case8_detailed = sprintf('test_case_%02d_loglevel_2_detailed', test_case_idx);
fprintf('  Running with log_level = 2 (Detailed). Expect verbose output from beautify_figure.\n');

fig8_detailed = figure('Visible', 'off');
plot(1:5, rand(1,5)); % Similar plot
title([test_name_case8_detailed ' Original']);

% Save original for reference
save_comparison_figure(fig8_detailed, test_name_case8_detailed, 'original', output_dir);

log_params_detailed.log_level = 2;
try
    beautify_figure(fig8_detailed, log_params_detailed);
    title([test_name_case8_detailed ' Beautified (Log Level 2)']);
    save_comparison_figure(fig8_detailed, test_name_case8_detailed, 'beautified', output_dir);
    fprintf('  Applied beautify_figure with log_level = 2.\n');
catch ME
    fprintf('  ERROR during Test Case 8 (Log Level 2): %s\n', ME.message);
end
if ishandle(fig8_detailed); close(fig8_detailed); end

fprintf('  Test Case 8 (Log Level Control) complete. Please review command window output for verbosity differences.\n');
test_case_idx = test_case_idx + 1;

% --- Test Case 9: Different Plot Types ---
fprintf('\n--- Running Test Case %d: Different Plot Types ---\n', test_case_idx);

% --- Sub-case 9.1: Error Bar Plot ---
test_name_case9_errorbar = sprintf('test_case_%02d_errorbar_plot', test_case_idx);
fprintf('  Running Sub-case 9.1: Error Bar Plot with default beautification.\n');

fig9_errorbar = figure('Visible', 'off');
x_eb = 1:5;
y_eb = [2 4 3 5 4.5];
err_eb = rand(1,5) * 0.5 + 0.2; % Random errors
errorbar(x_eb, y_eb, err_eb, '-s', 'MarkerSize', 8,...
    'MarkerEdgeColor','red','MarkerFaceColor','red', 'CapSize', 8);
title([test_name_case9_errorbar ' Original']);
xlabel('Group');
ylabel('Measurement +/- Error');
grid on;

save_comparison_figure(fig9_errorbar, test_name_case9_errorbar, 'original', output_dir);

try
    beautify_figure(fig9_errorbar); % Default beautification
    title([test_name_case9_errorbar ' Beautified']);
    save_comparison_figure(fig9_errorbar, test_name_case9_errorbar, 'beautified', output_dir);
    fprintf('  Applied default beautify_figure to Error Bar Plot.\n');
catch ME
    fprintf('  ERROR during Test Case 9.1 (Error Bar Plot): %s\n', ME.message);
end
if ishandle(fig9_errorbar); close(fig9_errorbar); end

% --- Sub-case 9.2: Histogram ---
test_name_case9_histogram = sprintf('test_case_%02d_histogram_plot', test_case_idx);
fprintf('  Running Sub-case 9.2: Histogram with default beautification.\n');

fig9_histogram = figure('Visible', 'off');
data_hist = randn(1000,1) * 2 + 5; % Normally distributed data
histogram(data_hist, 20, 'FaceColor', 'm', 'EdgeColor', 'b'); % Specify some initial colors
title([test_name_case9_histogram ' Original']);
xlabel('Value Bins');
ylabel('Frequency');
grid on;

save_comparison_figure(fig9_histogram, test_name_case9_histogram, 'original', output_dir);

try
    beautify_figure(fig9_histogram); % Default beautification
    title([test_name_case9_histogram ' Beautified']);
    save_comparison_figure(fig9_histogram, test_name_case9_histogram, 'beautified', output_dir);
    fprintf('  Applied default beautify_figure to Histogram.\n');
catch ME
    fprintf('  ERROR during Test Case 9.2 (Histogram): %s\n', ME.message);
end
if ishandle(fig9_histogram); close(fig9_histogram); end

fprintf('  Test Case 9 (Different Plot Types) complete.\n');
test_case_idx = test_case_idx + 1;

% --- Test Case 10: Advanced Line Plot Features ---
fprintf('\n--- Running Test Case %d: Advanced Line Plot Features ---\n', test_case_idx);

% --- Sub-case 10.1: Cycle Styles & Custom Palette ---
test_name_case10_styles = sprintf('test_case_%02d_adv_line_styles_palette', test_case_idx);
fprintf('  Running Sub-case 10.1: Cycle Marker/Line Styles & Custom RGB Palette\n');

fig10_styles = figure('Visible', 'off', 'Position', [100,100,700,500]);
hold on;
plot(1:10, rand(1,10)+1, 'DisplayName', 'Series 1');
plot(1:10, rand(1,10)+3, 'DisplayName', 'Series 2');
plot(1:10, rand(1,10)+5, 'DisplayName', 'Series 3');
plot(1:10, rand(1,10)+7, 'DisplayName', 'Series 4');
hold off;
title([test_name_case10_styles ' Original']);
xlabel('X-axis'); ylabel('Y-axis'); grid on;
legend show;

save_comparison_figure(fig10_styles, test_name_case10_styles, 'original', output_dir);

adv_line_params.cycle_marker_styles = true;
adv_line_params.cycle_line_styles = true;
adv_line_params.custom_color_palette = [ % Define a 4x3 RGB matrix
    1 0 0;   % Red
    0 1 0;   % Green
    0 0 1;   % Blue
    1 0 1    % Magenta
];
adv_line_params.color_palette = 'custom'; % Important: to use custom_color_palette

% Optional: to make cycling more evident if default thresholds are high for 4 lines
adv_line_params.marker_cycle_threshold = 2; 
adv_line_params.line_style_cycle_threshold = 1; 

fprintf('  Params: cycle_marker_styles=true, cycle_line_styles=true, custom RGB palette, color_palette=''custom''\n');

try
    beautify_figure(fig10_styles, adv_line_params);
    title([test_name_case10_styles ' Beautified']);
    save_comparison_figure(fig10_styles, test_name_case10_styles, 'beautified', output_dir);
    fprintf('  Applied beautify_figure for cycle styles & custom palette.\n');
catch ME
    fprintf('  ERROR during Test Case 10.1 (Cycle Styles): %s\n', ME.message);
end
if ishandle(fig10_styles); close(fig10_styles); end

% --- Sub-case 10.2: Global Font Scale Factor ---
test_name_case10_fontscale = sprintf('test_case_%02d_adv_font_scale', test_case_idx);
fprintf('  Running Sub-case 10.2: Global Font Scale Factor\n');

% Figure 1: Default scale (or explicit 1.0)
fig10_fontscale1 = figure('Visible', 'off');
plot(1:10, rand(1,10));
title([test_name_case10_fontscale ' Original (Scale 1.0)']);
xlabel('X-axis'); ylabel('Y-axis');
save_comparison_figure(fig10_fontscale1, [test_name_case10_fontscale '_scale_1_0'], 'original', output_dir);

font_scale_params1.global_font_scale_factor = 1.0; % Explicit default
try
    beautify_figure(fig10_fontscale1, font_scale_params1);
    title([test_name_case10_fontscale ' Beautified (Scale 1.0)']);
    save_comparison_figure(fig10_fontscale1, [test_name_case10_fontscale '_scale_1_0'], 'beautified', output_dir);
    fprintf('  Applied beautify_figure with global_font_scale_factor = 1.0\n');
catch ME
    fprintf('  ERROR during Test Case 10.2 (Font Scale 1.0): %s\n', ME.message);
end
if ishandle(fig10_fontscale1); close(fig10_fontscale1); end

% Figure 2: Larger scale (e.g., 1.5)
fig10_fontscale2 = figure('Visible', 'off');
plot(1:10, rand(1,10)); % Same plot data
title([test_name_case10_fontscale ' Original (Scale 1.5)']); % Title indicates intended scale for clarity
xlabel('X-axis'); ylabel('Y-axis');
save_comparison_figure(fig10_fontscale2, [test_name_case10_fontscale '_scale_1_5'], 'original', output_dir);

font_scale_params2.global_font_scale_factor = 1.5;
fprintf('  Params: global_font_scale_factor = 1.5\n');
try
    beautify_figure(fig10_fontscale2, font_scale_params2);
    title([test_name_case10_fontscale ' Beautified (Scale 1.5)']);
    save_comparison_figure(fig10_fontscale2, [test_name_case10_fontscale '_scale_1_5'], 'beautified', output_dir);
    fprintf('  Applied beautify_figure with global_font_scale_factor = 1.5\n');
catch ME
    fprintf('  ERROR during Test Case 10.2 (Font Scale 1.5): %s\n', ME.message);
end
if ishandle(fig10_fontscale2); close(fig10_fontscale2); end

test_case_idx = test_case_idx + 1;

% --- Test Case 11: Axes Styling Options ---
fprintf('\n--- Running Test Case %d: Axes Styling Options ---\n', test_case_idx);

% --- Sub-case 11.1: axis_box_style = 'off' ---
test_name_case11_box_off = sprintf('test_case_%02d_axes_box_off', test_case_idx);
fprintf('  Running Sub-case 11.1: axis_box_style = ''off''\n');

fig11_box_off = figure('Visible', 'off');
plot(1:10, rand(1,10));
title([test_name_case11_box_off ' Original']);
xlabel('X-axis'); ylabel('Y-axis'); grid on;

save_comparison_figure(fig11_box_off, test_name_case11_box_off, 'original', output_dir);

box_off_params.axis_box_style = 'off';
fprintf('  Params: axis_box_style = ''off''\n');
try
    beautify_figure(fig11_box_off, box_off_params);
    title([test_name_case11_box_off ' Beautified (Box Off)']);
    save_comparison_figure(fig11_box_off, test_name_case11_box_off, 'beautified', output_dir);
    fprintf('  Applied beautify_figure with axis_box_style = ''off''.\n');
catch ME
    fprintf('  ERROR during Test Case 11.1 (Box Off): %s\n', ME.message);
end
if ishandle(fig11_box_off); close(fig11_box_off); end

% --- Sub-case 11.2: axes_layer = 'bottom' ---
test_name_case11_layer_bottom = sprintf('test_case_%02d_axes_layer_bottom', test_case_idx);
fprintf('  Running Sub-case 11.2: axes_layer = ''bottom''\n');

fig11_layer_bottom = figure('Visible', 'off');
% For axes_layer='bottom' to be visible, plot elements should obscure the grid if grid is on top.
% If grid is part of axes and axes is at bottom, plot elements should be on top of grid.
hold on;
x_data_layer = 1:0.1:10;
y_data_layer = sin(x_data_layer);
plot(x_data_layer, y_data_layer, 'b', 'LineWidth', 2); % Line plot
h_patch = patch([2 4 4 2], [-0.5 -0.5 0.5 0.5], 'red', 'FaceAlpha', 0.3, 'EdgeColor', 'none'); % A patch object
hold off;
grid on; % Ensure grid is on to see its layering
title([test_name_case11_layer_bottom ' Original']);
xlabel('X-axis'); ylabel('Y-axis');
legend({'Line', 'Patch'}, 'Location', 'northwest');

save_comparison_figure(fig11_layer_bottom, test_name_case11_layer_bottom, 'original', output_dir);

layer_bottom_params.axes_layer = 'bottom';
% Optional: ensure grid is on to make layer effect visible
layer_bottom_params.grid_density = 'normal'; 
fprintf('  Params: axes_layer = ''bottom'', grid_density = ''normal''\n');

try
    beautify_figure(fig11_layer_bottom, layer_bottom_params);
    title([test_name_case11_layer_bottom ' Beautified (Layer Bottom)']);
    save_comparison_figure(fig11_layer_bottom, test_name_case11_layer_bottom, 'beautified', output_dir);
    fprintf('  Applied beautify_figure with axes_layer = ''bottom''. Grid lines should be behind plot elements.\n');
catch ME
    fprintf('  ERROR during Test Case 11.2 (Layer Bottom): %s\n', ME.message);
end
if ishandle(fig11_layer_bottom); close(fig11_layer_bottom); end

test_case_idx = test_case_idx + 1;

% --- Test Case 12: Legend Specifics ---
fprintf('\n--- Running Test Case %d: Legend Specifics ---\n', test_case_idx);

% --- Sub-case 12.1: Legend Location & Interactive ---
test_name_case12_location = sprintf('test_case_%02d_legend_location_interactive', test_case_idx);
fprintf('  Running Sub-case 12.1: legend_location & interactive_legend=true\n');

fig12_loc = figure('Visible', 'off');
hold on;
plot(1:10, rand(1,10), 'DisplayName', 'Data A');
plot(1:10, rand(1,10)+1, 'DisplayName', 'Data B');
hold off;
title([test_name_case12_location ' Original']);
xlabel('X'); ylabel('Y'); grid on;
legend show; % Show default legend initially

save_comparison_figure(fig12_loc, test_name_case12_location, 'original', output_dir);

leg_loc_params.legend_location = 'northeastoutside';
leg_loc_params.interactive_legend = true; % Should run without error
fprintf('  Params: legend_location=''northeastoutside'', interactive_legend=true\n');
try
    beautify_figure(fig12_loc, leg_loc_params);
    title([test_name_case12_location ' Beautified (Legend NE Outside, Interactive)']);
    save_comparison_figure(fig12_loc, test_name_case12_location, 'beautified', output_dir);
    fprintf('  Applied beautify_figure. Check legend position and for no errors with interactive_legend.\n');
catch ME
    fprintf('  ERROR during Test Case 12.1 (Legend Location/Interactive): %s\n', ME.message);
end
if ishandle(fig12_loc); close(fig12_loc); end

% --- Sub-case 12.2: smart_legend_display = false ---
test_name_case12_smart = sprintf('test_case_%02d_legend_smart_false', test_case_idx);
fprintf('  Running Sub-case 12.2: smart_legend_display = false (single item legend)\n');

fig12_smart = figure('Visible', 'off');
plot(1:10, rand(1,10), 'DisplayName', 'Single Series'); % Only one plottable item with DisplayName
title([test_name_case12_smart ' Original (No Legend Expected)']);
xlabel('X'); ylabel('Y'); grid on;
% No explicit legend command here, relying on smart_legend_display logic in beautify_figure

save_comparison_figure(fig12_smart, test_name_case12_smart, 'original', output_dir);

leg_smart_params.smart_legend_display = false;
leg_smart_params.legend_force_single_entry = true; % Ensure single entry is shown if not smart
fprintf('  Params: smart_legend_display=false, legend_force_single_entry=true\n');
try
    beautify_figure(fig12_smart, leg_smart_params);
    title([test_name_case12_smart ' Beautified (Legend Forced for Single Item)']);
    save_comparison_figure(fig12_smart, test_name_case12_smart, 'beautified', output_dir);
    fprintf('  Applied beautify_figure. Legend should be visible for the single series.\n');
catch ME
    fprintf('  ERROR during Test Case 12.2 (Smart Legend False): %s\n', ME.message);
end
if ishandle(fig12_smart); close(fig12_smart); end

test_case_idx = test_case_idx + 1;

% --- Test Case 13: Plot with Colorbar ---
test_name_case13_colorbar = sprintf('test_case_%02d_plot_with_colorbar', test_case_idx);
fprintf('\n--- Running Test Case %d: Plot with Colorbar (Default Beautification) ---\n', test_case_idx);

fig13_cb = figure('Visible', 'off');
[X, Y, Z] = peaks(25); % Re-use peaks data
contourf(X, Y, Z, 10); % Filled contour plot, 10 levels
h_cb = colorbar; % Add colorbar
xlabel('X-axis'); ylabel('Y-axis');
title([test_name_case13_colorbar ' Original']);
ylabel(h_cb, 'Colorbar Units'); % Add a label to the colorbar itself

save_comparison_figure(fig13_cb, test_name_case13_colorbar, 'original', output_dir);

% No specific params, testing default beautification of colorbar
% (apply_to_colorbars is true by default in beautify_figure)
fprintf('  Applying default beautify_figure. Expect colorbar to be beautified.\n');
try
    beautify_figure(fig13_cb); % Apply default beautification
    title([test_name_case13_colorbar ' Beautified']);
    % beautify_figure should also have beautified h_cb.Label if it exists
    save_comparison_figure(fig13_cb, test_name_case13_colorbar, 'beautified', output_dir);
    fprintf('  Applied default beautify_figure. Check appearance of plot and colorbar.\n');
catch ME
    fprintf('  ERROR during Test Case 13 (Plot with Colorbar): %s\n', ME.message);
end
if ishandle(fig13_cb); close(fig13_cb); end

test_case_idx = test_case_idx + 1;

% --- Test Case 14: Polar Plot ---
test_name_case14_polar = sprintf('test_case_%02d_polar_plot', test_case_idx);
fprintf('\n--- Running Test Case %d: Polar Plot (Default Beautification) ---\n', test_case_idx);

fig14_polar = figure('Visible', 'off');
theta = 0:0.01:2*pi;
rho = abs(sin(2*theta).*cos(2*theta)); % Example data for a flower shape
polarplot(theta, rho, 'r', 'LineWidth', 1.5); % Use polarplot

pax = gca; % Get polar axes handle
pax.ThetaZeroLocation = 'top';
pax.ThetaDir = 'clockwise';
title([test_name_case14_polar ' Original']);
% For polar plots, titles are often set directly on the polar axes:
% title(pax, [test_name_case14_polar ' Original']); 
% However, beautify_figure might interact with figure title or sgtitle by default.
% Let's stick to the figure title for consistency with other tests for now.

save_comparison_figure(fig14_polar, test_name_case14_polar, 'original', output_dir);

% No specific params, testing default beautification of polar plot
% (apply_to_polaraxes is true by default in beautify_figure)
fprintf('  Applying default beautify_figure. Expect polar plot to be beautified.\n');
try
    beautify_figure(fig14_polar); % Apply default beautification
    title([test_name_case14_polar ' Beautified']); 
    % If title was on pax, it would be: title(pax, [test_name_case14_polar ' Beautified']);
    save_comparison_figure(fig14_polar, test_name_case14_polar, 'beautified', output_dir);
    fprintf('  Applied default beautify_figure. Check appearance of polar plot.\n');
catch ME
    fprintf('  ERROR during Test Case 14 (Polar Plot): %s\n', ME.message);
end
if ishandle(fig14_polar); close(fig14_polar); end

test_case_idx = test_case_idx + 1;

% --- Test Case 15: LaTeX in Labels ---
test_name_case15_latex = sprintf('test_case_%02d_latex_labels', test_case_idx);
fprintf('\n--- Running Test Case %d: LaTeX in Labels (Default Beautification) ---\n', test_case_idx);

fig15_latex = figure('Visible', 'off');
x_latex = 0:0.1:2*pi;
y_latex = sin(x_latex);
plot(x_latex, y_latex, 'LineWidth', 1);

% Add title and labels with LaTeX strings
title_str_orig = 'Plot of $y = \sin(x)$ with $\Sigma_{i=1}^N x_i$';
xlabel_str_orig = 'Angle $\theta$ (radians)';
ylabel_str_orig = 'Amplitude $\alpha^2$';

title(title_str_orig, 'Interpreter', 'latex'); % Set interpreter for original to see it
xlabel(xlabel_str_orig, 'Interpreter', 'latex');
ylabel(ylabel_str_orig, 'Interpreter', 'latex');
grid on;

% To make the test more explicit for auto_latex_interpreter_for_labels,
% we will save this original with its LaTeX interpreter set.
% beautify_figure is expected to preserve or re-apply LaTeX if detected.

save_comparison_figure(fig15_latex, test_name_case15_latex, 'original', output_dir);

% No specific params for beautify_figure call.
% We are testing the default behavior of auto_latex_interpreter_for_labels (true by default)
% and force_latex_if_dollar_present (true by default).
fprintf('  Applying default beautify_figure. Expect LaTeX in labels to be rendered correctly.\n');
fprintf('  Original title: %s\n', title_str_orig); % Print to console for reference
fprintf('  Original xlabel: %s\n', xlabel_str_orig);
fprintf('  Original ylabel: %s\n', ylabel_str_orig);

try
    beautify_figure(fig15_latex); % Apply default beautification
    
    % Check current text of labels/title after beautification for comparison
    % (beautify_figure might re-format the string slightly, e.g. newlines)
    current_title = get(get(gca,'Title'),'String');
    current_xlabel = get(get(gca,'XLabel'),'String');
    current_ylabel = get(get(gca,'YLabel'),'String');
    
    fprintf('  Beautified title string (may differ slightly due to processing): %s\n', current_title);
    fprintf('  Beautified xlabel string: %s\n', current_xlabel);
    fprintf('  Beautified ylabel string: %s\n', current_ylabel);
    
    % For the saved figure, the title is just generic "Beautified"
    % The key is visual inspection of the saved image for LaTeX rendering.
    title([test_name_case15_latex ' Beautified (LaTeX Check)']);

    save_comparison_figure(fig15_latex, test_name_case15_latex, 'beautified', output_dir);
    fprintf('  Applied default beautify_figure. Check appearance of LaTeX in labels in the saved image.\n');
catch ME
    fprintf('  ERROR during Test Case 15 (LaTeX in Labels): %s\n', ME.message);
end
if ishandle(fig15_latex); close(fig15_latex); end

test_case_idx = test_case_idx + 1;

% --- Test Case 16: Object Exclusion ---
test_name_case16_exclusion = sprintf('test_case_%02d_object_exclusion', test_case_idx);
fprintf('\n--- Running Test Case %d: Object Exclusion by Tag ---\n', test_case_idx);

fig16_exclude = figure('Visible', 'off');
hold on;
% Line 1: To be beautified
line1 = plot(1:10, rand(1,10)+2, 'LineWidth', 1, 'Color', 'blue', 'Marker', 'o');
% Line 2: To be excluded, give it a specific tag and distinct original style
line2 = plot(1:10, rand(1,10), 'LineWidth', 3, 'Color', 'red', 'Marker', 'x', 'Tag', 'ExcludeThisLine');
hold off;
title([test_name_case16_exclusion ' Original']);
xlabel('X-axis'); ylabel('Y-axis'); grid on;
legend({'Line 1 (Beautify)', 'Line 2 (Exclude)'});

% Store original properties of Line 2 for later comparison (optional, for programmatic check)
original_line2_linewidth = line2.LineWidth;
original_line2_color = line2.Color;
original_line2_marker = line2.Marker;

save_comparison_figure(fig16_exclude, test_name_case16_exclusion, 'original', output_dir);

% Define parameters for exclusion
exclude_params.exclude_object_tags = {'ExcludeThisLine'};
% Forcing a style that would clearly change Line 1 if applied to Line 2
exclude_params.plot_line_width = 0.5; 
exclude_params.color_palette = 'lines'; % Use a standard palette that would change blue/red

fprintf('  Excluding objects with tag ''ExcludeThisLine''. Applying plot_line_width=0.5.\n');

try
    beautify_figure(fig16_exclude, exclude_params);
    title([test_name_case16_exclusion ' Beautified (One Line Excluded)']);
    save_comparison_figure(fig16_exclude, test_name_case16_exclusion, 'beautified', output_dir);
    
    % Verification (optional, for programmatic check if desired, visual is primary)
    if isvalid(line2) && ...
       line2.LineWidth == original_line2_linewidth && ...
       isequal(line2.Color, original_line2_color) && ...
       strcmp(line2.Marker, original_line2_marker)
        fprintf('  VERIFICATION SUCCESS: Tagged line appears to have retained its original style.\n');
    else
        fprintf('  VERIFICATION WARNING: Tagged line style may have changed or handle is invalid.\n');
        if isvalid(line2)
            fprintf('    Current LW: %.2f (Original: %.2f)\n', line2.LineWidth, original_line2_linewidth);
            fprintf('    Current Color: [%.2f %.2f %.2f] (Original: [%.2f %.2f %.2f])\n', line2.Color, original_line2_color);
            fprintf('    Current Marker: %s (Original: %s)\n', line2.Marker, original_line2_marker);
        end
    end
    fprintf('  Applied beautify_figure. Check that the red, thick, x-marked line retained its original style.\n');
    
catch ME
    fprintf('  ERROR during Test Case 16 (Object Exclusion): %s\n', ME.message);
end
if ishandle(fig16_exclude); close(fig16_exclude); end

test_case_idx = test_case_idx + 1;


%% Teardown
fprintf('\n--- Test Script Complete ---\n');
fprintf('Please check the "%s" directory for saved figures.\n', output_dir);
fprintf('For Test Case 8 (Log Level), please check the MATLAB command window output during the test run.\n');

% Close all figures
% close all; % Commented out for now to allow user to see last figures if run interactively. 
             % Can be enabled for fully automated runs.

fprintf('Done.\n');

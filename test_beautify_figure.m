% Test script for beautify_figure.m
% This script will test various functionalities of beautify_figure.m
% focusing on new and previously untested scenarios.
% -------------------------------------------------------------------------
% USER INSTRUCTIONS:
%
% Purpose:
%   This script tests functionalities of `beautify_figure.m` that were
%   not covered by the original test script. It generates various plots,
%   applies specific beautification settings relevant to the test case,
%   and saves 'original' and 'beautified' versions of these plots as PNG
%   images for visual comparison.
%
% Prerequisites:
%   1. Ensure `beautify_figure.m` is on the MATLAB path or in the same
%      directory as this test script.
%   2. Ensure `old_test_beautify_figure.m` (the renamed original test script)
%      is also available if any reference is needed, though this script
%      is designed to be self-contained with new tests.
%
% How to Run:
%   1. Open this file (`test_beautify_figure.m`) in the MATLAB Editor.
%   2. Click the "Run" button, or type `test_beautify_figure` in the
%      MATLAB Command Window and press Enter.
%
% What to Expect:
%   - The script will execute a series of new test cases. Console messages
%     will indicate the progress.
%   - "Original" and "Beautified" figures for each test case will be
%     saved as PNG images in a subdirectory named 'test_beautify_output_new'.
%   - At the end, a "New Test Script Complete" message will be displayed.
%
% Interpreting Results:
%   - Visually compare the 'original' and 'beautified' PNG images for each
%     test case in the 'test_beautify_output_new' directory.
%   - Check for any error messages in the MATLAB Command Window.
%   - To test font substitution warnings: Set a `font_name` in `params_current` for any test case to a font you know is unavailable on your system (e.g., `params_current.font_name = 'NonExistentFont123';`). Also, ensure `params_current.log_level` is set to 1 or 2. Run the test. You should see warning messages in the MATLAB console indicating that the font was not found and was substituted by MATLAB.
%
% -------------------------------------------------------------------------

%% Setup
% Add necessary paths (if beautify_figure.m is not in the current path)
% curr_dir = fileparts(mfilename('fullpath'));
% addpath(curr_dir); % Assuming beautify_figure.m is in the same directory

% Create an output directory for saved figures
output_dir_new = 'test_beautify_output_new';
if ~exist(output_dir_new, 'dir')
    mkdir(output_dir_new);
end
fprintf('New test figures will be saved in: %s\n', fullfile(pwd, output_dir_new));

% Initialize test case counter
test_case_num = 1;

%% Helper Functions
function save_comparison_figure_new(fig_handle, test_name_str, stage_str, out_dir_str)
% stage_str can be 'original' or 'beautified'
if ~ishandle(fig_handle) || ~strcmp(get(fig_handle, 'Type'), 'figure')
    fprintf('ERROR (save_comparison_figure_new): Invalid figure handle for test: %s, stage: %s.\n', test_name_str, stage_str);
    return;
end

filename_str = fullfile(out_dir_str, sprintf('%s_%s.png', test_name_str, stage_str));
try
    drawnow;
    original_visibility_str = get(fig_handle, 'Visible');
    if strcmp(original_visibility_str, 'off')
        set(fig_handle, 'Visible', 'on');
        drawnow; % Allow figure to render if it was off
    end
    saveas(fig_handle, filename_str);
    fprintf('Saved: %s\n', filename_str);
    if strcmp(original_visibility_str, 'off') % Restore visibility if changed
        set(fig_handle, 'Visible', 'off');
    end
catch ME_save
    fprintf('ERROR (save_comparison_figure_new) saving figure %s: %s\n', filename_str, ME_save.message);
end
end

% Helper mapping for marker shorthands to their common full names
marker_shorthand_to_full_map = containers.Map(...
    {'o', 's', 'd', '^', 'v', '>', '<', 'p', 'h', '.', 'x', '+', '*'}, ...
    {{'o', 'circle'}, {'s', 'square'}, {'d', 'diamond'}, {'^', 'triangleup'}, ...
    {'v', 'triangledown'}, {'>', 'triangleright'}, {'<', 'triangleleft'}, ...
    {'p', 'pentagram'}, {'h', 'hexagram'}, {'.', 'point'}, ...
    {'x', 'cross'}, {'+', 'plus'}, {'*', 'star'}});

%% --- Test Case Placeholders ---
% New test cases will be added here sequentially.

% Example Structure for a new test case:
% fprintf('\n--- Running New Test Case %d: [Test Case Name] ---\n', test_case_num);
% test_name_current = sprintf('new_test_%02d_[short_name]', test_case_num);
% fig_current = figure('Visible', 'off');
% % ... (plotting commands for original figure) ...
% title([test_name_current ' Original'], 'Interpreter', 'none');
% save_comparison_figure_new(fig_current, test_name_current, 'original', output_dir_new);
%
% params_current = struct();
% % ... (define specific params for beautify_figure for this test) ...
% try
%     params_current.figure_handle = fig_current; % Or beautify_figure(fig_current, params_current)
%     beautify_figure(params_current);
%     title([test_name_current ' Beautified'], 'Interpreter', 'none');
%     save_comparison_figure_new(fig_current, test_name_current, 'beautified', output_dir_new);
%     fprintf('  Applied beautify_figure for %s.\n', test_name_current);
% catch ME_test
%     fprintf('  ERROR during New Test Case %d (%s): %s\n', test_case_num, test_name_current, ME_test.message);
% end
% if ishandle(fig_current); close(fig_current); end
% test_case_num = test_case_num + 1;

%% --- Test Case: `apply_to_colorbars = false` ---
fprintf('\n--- Running New Test Case %d: `apply_to_colorbars = false` ---\n', test_case_num);
test_name_current = sprintf('new_test_%02d_apply_to_colorbars_false', test_case_num);

fig_current = figure('Visible', 'off', 'Position', [100, 100, 600, 450]);
[X_contour, Y_contour] = meshgrid(-2:0.2:2);
Z_contour = X_contour .* exp(-X_contour.^2 - Y_contour.^2);
contourf(X_contour, Y_contour, Z_contour, 10);
h_cb_original = colorbar;
original_cb_fontsize = h_cb_original.FontSize;
original_cb_fontname = h_cb_original.FontName;
original_cb_linewidth = h_cb_original.LineWidth;
original_cb_color = h_cb_original.Color;
if isprop(h_cb_original, 'Label') && isvalid(h_cb_original.Label)
    ylabel(h_cb_original, 'Original Colorbar Label');
    original_cb_label_str = h_cb_original.Label.String;
    original_cb_label_fontsize = h_cb_original.Label.FontSize;
else
    original_cb_label_str = '';
    original_cb_label_fontsize = [];
end

title([test_name_current ' Original'], 'Interpreter', 'none');
xlabel('X-axis'); ylabel('Y-axis');
save_comparison_figure_new(fig_current, test_name_current, 'original', output_dir_new);

params_current = struct();
params_current.apply_to_colorbars = false;
params_current.style_preset = 'default'; % Apply some styling to the main plot
params_current.log_level = 0;

fprintf('  Testing with apply_to_colorbars = false.\n');
try
    params_current.figure_handle = fig_current;
    beautify_figure(params_current);
    title([test_name_current ' Beautified (Colorbar Unchanged)'], 'Interpreter', 'none');

    h_cb_beautified = findobj(fig_current, 'Type', 'ColorBar');
    passed_verification = true;
    if isempty(h_cb_beautified)
        fprintf('  VERIFICATION FAIL: Colorbar disappeared after beautification.\n');
        passed_verification = false;
    else
        h_cb_beautified = h_cb_beautified(1); % Take the first one if multiple (should not happen here)
        if abs(h_cb_beautified.FontSize - original_cb_fontsize) > 0.1 % Allow for tiny numerical differences
            fprintf('  VERIFICATION FAIL: Colorbar FontSize changed. Original: %.1f, Current: %.1f\n', original_cb_fontsize, h_cb_beautified.FontSize);
            passed_verification = false;
        end
        if ~strcmp(h_cb_beautified.FontName, original_cb_fontname)
            fprintf('  VERIFICATION FAIL: Colorbar FontName changed. Original: %s, Current: %s\n', original_cb_fontname, h_cb_beautified.FontName);
            passed_verification = false;
        end
        if abs(h_cb_beautified.LineWidth - original_cb_linewidth) > 0.01
            fprintf('  VERIFICATION FAIL: Colorbar LineWidth changed. Original: %.2f, Current: %.2f\n', original_cb_linewidth, h_cb_beautified.LineWidth);
            passed_verification = false;
        end
        if ~isequal(h_cb_beautified.Color, original_cb_color)
            fprintf('  VERIFICATION FAIL: Colorbar Color changed.\n');
            passed_verification = false;
        end
        if isprop(h_cb_beautified, 'Label') && isvalid(h_cb_beautified.Label)
            if ~strcmp(h_cb_beautified.Label.String, original_cb_label_str)
                fprintf('  VERIFICATION FAIL: Colorbar Label String changed.\n');
                passed_verification = false;
            end
            if ~isempty(original_cb_label_fontsize) && abs(h_cb_beautified.Label.FontSize - original_cb_label_fontsize) > 0.1
                fprintf('  VERIFICATION FAIL: Colorbar Label FontSize changed.\n');
                passed_verification = false;
            end
        elseif ~isempty(original_cb_label_str) % Original had a label, but beautified doesn't or it's invalid
            fprintf('  VERIFICATION FAIL: Colorbar Label seems to have been removed or is invalid.\n');
            passed_verification = false;
        end
    end

    if passed_verification
        fprintf('  VERIFICATION PASS: Colorbar properties appear unchanged as expected.\n');
    else
        fprintf('  VERIFICATION FAIL: Some colorbar properties changed unexpectedly.\n');
    end

    save_comparison_figure_new(fig_current, test_name_current, 'beautified', output_dir_new);
    fprintf('  Applied beautify_figure. Check that the colorbar is NOT styled, but the rest of the plot is.\n');
catch ME_test
    fprintf('  ERROR during New Test Case %d (%s): %s\n', test_case_num, test_name_current, ME_test.message);
end
if ishandle(fig_current); close(fig_current); end
test_case_num = test_case_num + 1;

%% --- Test Case: `apply_to_polaraxes = false` ---
fprintf('\n--- Running New Test Case %d: `apply_to_polaraxes = false` ---\n', test_case_num);
test_name_current = sprintf('new_test_%02d_apply_to_polaraxes_false', test_case_num);

fig_current = figure('Visible', 'off', 'Position', [100, 100, 600, 450]);
theta_polar = 0:0.01:2*pi;
rho_polar = abs(sin(3*theta_polar).*cos(3*theta_polar)); % A more complex polar pattern
polarplot(theta_polar, rho_polar, 'm', 'LineWidth', 1.5); % Magenta color for original
pax_original = gca;
original_pax_fontsize = pax_original.FontSize;
original_pax_fontname = pax_original.FontName;
original_pax_linewidth = pax_original.LineWidth;
original_pax_gridcolor = pax_original.GridColor;
original_pax_rcolor = pax_original.RColor;
original_pax_thetacolor = pax_original.ThetaColor;
original_pax_title_str = 'Original Polar Title';
title(original_pax_title_str);

save_comparison_figure_new(fig_current, test_name_current, 'original', output_dir_new);

params_current = struct();
params_current.apply_to_polaraxes = false;
params_current.style_preset = 'default'; % Apply some styling to potentially other elements if any
params_current.font_name = 'Arial'; % A font different from MATLAB default for main fig
params_current.base_font_size = 14; % A size different from MATLAB default
params_current.log_level = 0;

fprintf('  Testing with apply_to_polaraxes = false.\n');
try
    params_current.figure_handle = fig_current;
    beautify_figure(params_current);
    % Change the main figure title to indicate beautification attempt
    % but the polar axes title (if part of polar axes) should remain original.
    sgtitle_obj = findobj(fig_current, 'Type', 'text', 'Tag', 'sgtitle'); % sgtitle might be used by beautify_figure
    if ~isempty(sgtitle_obj)
        sgtitle_obj.String = [test_name_current ' Beautified (Polar Unchanged?)'];
    else
        % If no sgtitle, maybe the figure has a main title if it wasn't a polar axes directly
        % For this test, we focus on the polar axes itself.
        % The title on the polar axes itself is the key.
    end

    pax_beautified = findobj(fig_current, 'Type', 'PolarAxes');
    passed_verification = true;
    if isempty(pax_beautified)
        fprintf('  VERIFICATION FAIL: PolarAxes disappeared after beautification.\n');
        passed_verification = false;
    else
        pax_beautified = pax_beautified(1);
        if abs(pax_beautified.FontSize - original_pax_fontsize) > 0.1
            fprintf('  VERIFICATION FAIL: PolarAxes FontSize changed. Original: %.1f, Current: %.1f\n', original_pax_fontsize, pax_beautified.FontSize);
            passed_verification = false;
        end
        if ~strcmp(pax_beautified.FontName, original_pax_fontname)
            fprintf('  VERIFICATION FAIL: PolarAxes FontName changed. Original: %s, Current: %s\n', original_pax_fontname, pax_beautified.FontName);
            passed_verification = false;
        end
        if abs(pax_beautified.LineWidth - original_pax_linewidth) > 0.01
            fprintf('  VERIFICATION FAIL: PolarAxes LineWidth changed. Original: %.2f, Current: %.2f\n', original_pax_linewidth, pax_beautified.LineWidth);
            passed_verification = false;
        end
        if ~isequal(pax_beautified.GridColor, original_pax_gridcolor)
            fprintf('  VERIFICATION FAIL: PolarAxes GridColor changed.\n');
            passed_verification = false;
        end
        if ~isequal(pax_beautified.RColor, original_pax_rcolor)
            fprintf('  VERIFICATION FAIL: PolarAxes RColor changed.\n');
            passed_verification = false;
        end
        if ~isequal(pax_beautified.ThetaColor, original_pax_thetacolor)
            fprintf('  VERIFICATION FAIL: PolarAxes ThetaColor changed.\n');
            passed_verification = false;
        end
        if isvalid(pax_beautified.Title) && ~strcmp(pax_beautified.Title.String, original_pax_title_str)
            fprintf('  VERIFICATION FAIL: PolarAxes Title string changed. Original: "%s", Current: "%s"\n', original_pax_title_str, pax_beautified.Title.String);
            passed_verification = false;
        elseif ~isvalid(pax_beautified.Title) && ~isempty(original_pax_title_str)
            fprintf('  VERIFICATION FAIL: PolarAxes Title removed or invalid after beautification.\n');
            passed_verification = false;
        end
    end

    if passed_verification
        fprintf('  VERIFICATION PASS: PolarAxes properties appear unchanged as expected.\n');
    else
        fprintf('  VERIFICATION FAIL: Some PolarAxes properties changed unexpectedly.\n');
    end

    % Explicitly set a title for the saved image if not sgtitle
    if isempty(sgtitle_obj) && isvalid(pax_beautified) && isvalid(pax_beautified.Title)
        pax_beautified.Title.String = [test_name_current ' Beautified (Polar Unchanged)'];
    elseif isempty(sgtitle_obj) && isvalid(pax_beautified) && ~isvalid(pax_beautified.Title)
        title(pax_beautified, [test_name_current ' Beautified (Polar Unchanged)']);
    end

    save_comparison_figure_new(fig_current, test_name_current, 'beautified', output_dir_new);
    fprintf('  Applied beautify_figure. Check that the polar plot is NOT styled (font, colors, line width of axes/grid).\n');
catch ME_test
    fprintf('  ERROR during New Test Case %d (%s): %s\n', test_case_num, test_name_current, ME_test.message);
end
if ishandle(fig_current); close(fig_current); end
test_case_num = test_case_num + 1;

%% --- Test Case: `axis_limit_mode` (focus on 'tight') ---
fprintf('\n--- Running New Test Case %d: `axis_limit_mode` (focus on ''tight'') ---\n', test_case_num);
test_name_current = sprintf('new_test_%02d_axis_limit_mode_tight', test_case_num);

% Data that doesn't span a huge range initially
x_data_limits = linspace(0, 5, 100);
y_data_limits = sin(x_data_limits) + 0.5; % Shifted sine wave

fig_current = figure('Visible', 'off', 'Position', [100, 100, 600, 450]);
plot(x_data_limits, y_data_limits, 'b-');
% Set initial loose limits
xlim([-1, 6]);
ylim([-1, 2]);
original_xlim = xlim;
original_ylim = ylim;
title([test_name_current ' Original (Loose Limits)'], 'Interpreter', 'none');
xlabel('X-axis'); ylabel('Y-axis'); grid on;
save_comparison_figure_new(fig_current, test_name_current, 'original', output_dir_new);

params_current = struct();
params_current.axis_limit_mode = 'tight';
params_current.style_preset = 'default';
params_current.log_level = 0;

fprintf('  Testing with axis_limit_mode = ''tight''.\n');
try
    params_current.figure_handle = fig_current;
    beautify_figure(params_current);
    title([test_name_current ' Beautified (Tight Limits Expected)'], 'Interpreter', 'none');

    ax_beautified = gca;
    beautified_xlim = xlim(ax_beautified);
    beautified_ylim = ylim(ax_beautified);

    % Verification: Check if limits are tighter than original and close to data range
    % For 'tight', the limits should be very close to min/max of data, possibly with a small internal padding.
    % beautify_figure might add its own small padding even with 'tight', so direct equality to data min/max is too strict.
    % We check if they are significantly different from original loose limits and closer to data bounds.

    expected_xlim_tight = [min(x_data_limits), max(x_data_limits)];
    expected_ylim_tight = [min(y_data_limits), max(y_data_limits)];

    passed_verification = true;
    tolerance = 1e-9; % A small tolerance for floating point comparisons

    if ~all(abs(beautified_xlim - expected_xlim_tight) < tolerance)
        fprintf('  VERIFICATION FAIL: Xlim is [%.2f, %.2f], expected tight limits [%.2f, %.2f]. Diff: [%.e, %.e]\n', ...
            beautified_xlim(1), beautified_xlim(2), expected_xlim_tight(1), expected_xlim_tight(2), ...
            abs(beautified_xlim(1) - expected_xlim_tight(1)), abs(beautified_xlim(2) - expected_xlim_tight(2)) );
        passed_verification = false;
    end

    if ~all(abs(beautified_ylim - expected_ylim_tight) < tolerance)
        fprintf('  VERIFICATION FAIL: Ylim is [%.2f, %.2f], expected tight limits [%.2f, %.2f]. Diff: [%.e, %.e]\n', ...
            beautified_ylim(1), beautified_ylim(2), expected_ylim_tight(1), expected_ylim_tight(2), ...
            abs(beautified_ylim(1) - expected_ylim_tight(1)), abs(beautified_ylim(2) - expected_ylim_tight(2)) );
        passed_verification = false;
    end

    if passed_verification
        fprintf('  VERIFICATION PASS: Axis limits are tight to data extents as expected.\n');
    else
        fprintf('  VERIFICATION FAIL: Axis limits are not perfectly tight to data extents.\n');
    end
    fprintf('  VERIFICATION INFO: Original limits X[%.2f, %.2f] Y[%.2f, %.2f]. New limits X[%.2f, %.2f] Y[%.2f, %.2f]. Data X[%.2f, %.2f] Y[%.2f, %.2f].\n', ...
        original_xlim(1), original_xlim(2), original_ylim(1), original_ylim(2), beautified_xlim(1), beautified_xlim(2), beautified_ylim(1), beautified_ylim(2), ...
        min(x_data_limits), max(x_data_limits), min(y_data_limits), max(y_data_limits));

    save_comparison_figure_new(fig_current, test_name_current, 'beautified', output_dir_new);
    fprintf('  Applied beautify_figure. Check that the axis limits are now tight around the data.\n');
catch ME_test
    fprintf('  ERROR during New Test Case %d (%s): %s\n', test_case_num, test_name_current, ME_test.message);
end
if ishandle(fig_current); close(fig_current); end
test_case_num = test_case_num + 1;

%% --- Test Case: `legend_num_columns` and `legend_reverse_order` ---
fprintf('\n--- Running New Test Case %d: `legend_num_columns` and `legend_reverse_order` ---\n', test_case_num);

% Sub-case 1: legend_num_columns
test_name_multicolumn = sprintf('new_test_%02d_legend_num_columns', test_case_num);
fig_multicolumn = figure('Visible', 'off', 'Position', [100, 100, 700, 500]);
hold on;
plot(1:10, rand(1,10)+6, 'DisplayName', 'Series Alpha');
plot(1:10, rand(1,10)+4, 'DisplayName', 'Series Beta');
plot(1:10, rand(1,10)+2, 'DisplayName', 'Series Gamma');
plot(1:10, rand(1,10)+0, 'DisplayName', 'Series Delta');
hold off;
legend('show');
title([test_name_multicolumn ' Original (Single Column Legend)'], 'Interpreter', 'none');
xlabel('X-data'); ylabel('Y-data'); grid on;
save_comparison_figure_new(fig_multicolumn, test_name_multicolumn, 'original', output_dir_new);

params_multicolumn = struct();
params_multicolumn.legend_num_columns = 2;
params_multicolumn.log_level = 0;

fprintf('  Testing with legend_num_columns = 2.\n');
try
    params_multicolumn.figure_handle = fig_multicolumn;
    beautify_figure(params_multicolumn);
    title([test_name_multicolumn ' Beautified (2-Column Legend)'], 'Interpreter', 'none');

    lgd_multicolumn = findobj(fig_multicolumn, 'Type', 'Legend');
    passed_multicolumn = false;
    if ~isempty(lgd_multicolumn) && isprop(lgd_multicolumn(1), 'NumColumns') && lgd_multicolumn(1).NumColumns == 2
        fprintf('  VERIFICATION PASS: Legend NumColumns is 2 as expected.\n');
        passed_multicolumn = true;
    elseif ~isempty(lgd_multicolumn) && isprop(lgd_multicolumn(1), 'NumColumns')
        fprintf('  VERIFICATION FAIL: Legend NumColumns is %d, expected 2.\n', lgd_multicolumn(1).NumColumns);
    elseif isempty(lgd_multicolumn)
        fprintf('  VERIFICATION FAIL: Legend not found after beautification for multicolumn test.\n');
    else
        fprintf('  VERIFICATION WARN: Could not verify NumColumns property (possibly older MATLAB version or unexpected legend object).\n');
    end

    save_comparison_figure_new(fig_multicolumn, test_name_multicolumn, 'beautified', output_dir_new);
    fprintf('  Applied beautify_figure. Check that the legend now has 2 columns.\n');
catch ME_test_multicolumn
    fprintf('  ERROR during New Test Case %d (%s): %s\n', test_case_num, test_name_multicolumn, ME_test_multicolumn.message);
end
if ishandle(fig_multicolumn); close(fig_multicolumn); end

% Sub-case 2: legend_reverse_order
test_name_revorder = sprintf('new_test_%02d_legend_reverse_order', test_case_num);
fig_revorder = figure('Visible', 'off', 'Position', [100, 100, 700, 500]);
hold on;
h_plots_rev(1) = plot(1:10, rand(1,10)+3, 'DisplayName', 'First Plot (Top in Code)');
h_plots_rev(2) = plot(1:10, rand(1,10)+1, 'DisplayName', 'Second Plot (Bottom in Code)');
hold off;
legend_original_revorder = legend('show');
original_legend_strings = legend_original_revorder.String;
title([test_name_revorder ' Original (Normal Legend Order)'], 'Interpreter', 'none');
xlabel('X-data'); ylabel('Y-data'); grid on;
save_comparison_figure_new(fig_revorder, test_name_revorder, 'original', output_dir_new);

params_revorder = struct();
params_revorder.legend_reverse_order = true;
params_revorder.log_level = 0;

fprintf('  Testing with legend_reverse_order = true.\n');
try
    params_revorder.figure_handle = fig_revorder;
    beautify_figure(params_revorder);
    title([test_name_revorder ' Beautified (Reversed Legend Order)'], 'Interpreter', 'none');

    lgd_revorder = findobj(fig_revorder, 'Type', 'Legend');
    passed_revorder = false;
    if ~isempty(lgd_revorder) && isprop(lgd_revorder(1), 'String')
        beautified_legend_strings = lgd_revorder(1).String;
        if length(beautified_legend_strings) == length(original_legend_strings) && ...
                strcmp(beautified_legend_strings{1}, original_legend_strings{2}) && ...
                strcmp(beautified_legend_strings{2}, original_legend_strings{1})
            fprintf('  VERIFICATION PASS: Legend order appears reversed as expected.\n');
            passed_revorder = true;
        else
            fprintf('  VERIFICATION FAIL: Legend order does not appear reversed. Original: {%s, %s}, Current: {%s, %s}.\n', ...
                original_legend_strings{1}, original_legend_strings{2}, beautified_legend_strings{1}, beautified_legend_strings{2});
        end
    elseif isempty(lgd_revorder)
        fprintf('  VERIFICATION FAIL: Legend not found after beautification for reverse order test.\n');
    else
        fprintf('  VERIFICATION WARN: Could not verify legend strings for reverse order test.\n');
    end

    save_comparison_figure_new(fig_revorder, test_name_revorder, 'beautified', output_dir_new);
    fprintf('  Applied beautify_figure. Check that the legend entry order is reversed.\n');
catch ME_test_revorder
    fprintf('  ERROR during New Test Case %d (%s): %s\n', test_case_num, test_name_revorder, ME_test_revorder.message);
end
if ishandle(fig_revorder); close(fig_revorder); end

test_case_num = test_case_num + 1;

%% --- Test Case: `stats_overlay` positions and inheritance ---
fprintf('\n--- Running New Test Case %d: `stats_overlay` positions and inheritance ---\n', test_case_num);

% Sub-case 1: Different position (southwest_inset)
test_name_stats_pos = sprintf('new_test_%02d_stats_pos_sw', test_case_num);
fig_stats_pos = figure('Visible', 'off', 'Position', [100, 100, 600, 450]);
x_data_stats_pos = 1:30;
y_data_stats_pos = cos(x_data_stats_pos/3) + randn(1,30)*0.5;
plot(x_data_stats_pos, y_data_stats_pos, 'Tag', 'DataForStatsPos', 'LineWidth', 1.2, 'Color', [0.2 0.5 0.2]);
title([test_name_stats_pos ' Original'], 'Interpreter', 'none');
xlabel('X'); ylabel('Y'); grid on;
save_comparison_figure_new(fig_stats_pos, test_name_stats_pos, 'original', output_dir_new);

params_stats_pos = struct();
params_stats_pos.stats_overlay.enabled = true;
params_stats_pos.stats_overlay.target_plot_handle_tag = 'DataForStatsPos';
params_stats_pos.stats_overlay.statistics = {'mean', 'N'};
params_stats_pos.stats_overlay.position = 'southwest_inset'; % Different position
params_stats_pos.stats_overlay.precision = 4;
params_stats_pos.log_level = 0;

fprintf('  Testing stats_overlay with position = ''southwest_inset''.\n');
try
    params_stats_pos.figure_handle = fig_stats_pos;
    beautify_figure(params_stats_pos);
    title([test_name_stats_pos ' Beautified (Stats SW)'], 'Interpreter', 'none');
    % Visual verification needed for position
    fprintf('  VERIFICATION INFO: Visual check needed for stats overlay in southwest_inset position.\n');
    save_comparison_figure_new(fig_stats_pos, test_name_stats_pos, 'beautified', output_dir_new);
catch ME_test_stats_pos
    fprintf('  ERROR during New Test Case %d (%s - SW Position): %s\n', test_case_num, test_name_stats_pos, ME_test_stats_pos.message);
end
if ishandle(fig_stats_pos); close(fig_stats_pos); end

% Sub-case 2: Font and Color Inheritance for stats_overlay
test_name_stats_inherit = sprintf('new_test_%02d_stats_font_color_inherit', test_case_num);
fig_stats_inherit = figure('Visible', 'off', 'Position', [100, 100, 600, 450]);
x_data_stats_inherit = 1:30;
y_data_stats_inherit = sin(x_data_stats_inherit/5) * 2;
plot(x_data_stats_inherit, y_data_stats_inherit, 'Tag', 'DataForStatsInherit', 'LineWidth', 1.2, 'Color', [0.7 0.2 0.2]);
title([test_name_stats_inherit ' Original'], 'Interpreter', 'none');
xlabel('X'); ylabel('Y'); grid on;
save_comparison_figure_new(fig_stats_inherit, test_name_stats_inherit, 'original', output_dir_new);

params_stats_inherit = struct();
% Set global font and colors that stats overlay should inherit
params_stats_inherit.font_name = 'Courier New'; % A distinct font
params_stats_inherit.text_color = [0.1 0.5 0.1]; % A distinct color (dark green)
params_stats_inherit.base_font_size = 12; % To make label font size predictable

params_stats_inherit.stats_overlay.enabled = true;
params_stats_inherit.stats_overlay.target_plot_handle_tag = 'DataForStatsInherit';
params_stats_inherit.stats_overlay.statistics = {'median', 'std'};
params_stats_inherit.stats_overlay.position = 'northwest_inset';
% params_stats_inherit.stats_overlay.font_name is NOT set (should inherit)
% params_stats_inherit.stats_overlay.text_color is NOT set (should inherit)
params_stats_inherit.log_level = 2; % ENABLE DETAILED LOGGING FOR THIS SUB-CASE

fprintf('  Testing stats_overlay for font and color inheritance.\n');
fprintf('  Global font: %s, Global text color: [%.1f %.1f %.1f]\n', params_stats_inherit.font_name, params_stats_inherit.text_color);
try
    params_stats_inherit.figure_handle = fig_stats_inherit;
    beautify_figure(params_stats_inherit);
    title([test_name_stats_inherit ' Beautified (Stats Inherit Font/Color)'], 'Interpreter', 'none');

    stats_text_obj = findobj(fig_stats_inherit, 'Type', 'text', 'Tag', 'BeautifyFig_StatsOverlay');
    passed_inherit_verification = true;
    if isempty(stats_text_obj)
        fprintf('  VERIFICATION FAIL: Stats overlay text object not found for inheritance test.\n');
        passed_inherit_verification = false;
    else
        stats_text_obj = stats_text_obj(1);
        actual_font_name = stats_text_obj.FontName;
        actual_text_color = stats_text_obj.Color;

        if ~strcmp(actual_font_name, params_stats_inherit.font_name)
            fprintf('  VERIFICATION FAIL: Stats overlay FontName ("%s") does not match global FontName ("%s").\n', actual_font_name, params_stats_inherit.font_name);
            passed_inherit_verification = false;
        else
            fprintf('  VERIFICATION PASS: Stats overlay FontName correctly inherited as "%s".\n', actual_font_name);
        end

        if ~isequal(actual_text_color, params_stats_inherit.text_color)
            fprintf('  VERIFICATION FAIL: Stats overlay TextColor ([%.1f %.1f %.1f]) does not match global TextColor ([%.1f %.1f %.1f]).\n', actual_text_color, params_stats_inherit.text_color);
            passed_inherit_verification = false;
        else
            fprintf('  VERIFICATION PASS: Stats overlay TextColor correctly inherited.\n');
        end
    end

    if ~passed_inherit_verification
        fprintf('  VERIFICATION FAIL: Stats overlay did not correctly inherit font/color properties.\n');
    end

    save_comparison_figure_new(fig_stats_inherit, test_name_stats_inherit, 'beautified', output_dir_new);
catch ME_test_stats_inherit
    fprintf('  ERROR during New Test Case %d (%s - Inheritance): %s\n', test_case_num, test_name_stats_inherit, ME_test_stats_inherit.message);
end
if ishandle(fig_stats_inherit); close(fig_stats_inherit); end

test_case_num = test_case_num + 1;

%% --- Test Case: `beautify_sgtitle = false` ---
fprintf('\n--- Running New Test Case %d: `beautify_sgtitle = false` ---\n', test_case_num);
test_name_current = sprintf('new_test_%02d_beautify_sgtitle_false', test_case_num);

fig_current = figure('Visible', 'off', 'Position', [100, 100, 600, 450]);
% Create a layout to ensure sgtitle has a target
tiledlayout(fig_current, 1, 1, 'Padding', 'compact');
ax_sgtitle_test = nexttile;
plot(ax_sgtitle_test, 1:10, rand(1,10));
title(ax_sgtitle_test, 'Subplot Title (should be styled)');
original_sgtitle_text = 'Original SGTitle (Should NOT Be Styled)';
original_sgtitle_fontname = 'Helvetica'; % Set a specific original font
original_sgtitle_fontsize = 18;      % Set a specific original size
original_sgtitle_color = [0.8 0.2 0.2]; % Set a specific original color (e.g., dark red)

sgt_handle = sgtitle(fig_current, original_sgtitle_text, ...
    'FontName', original_sgtitle_fontname, ...
    'FontSize', original_sgtitle_fontsize, ...
    'Color', original_sgtitle_color, ...
    'FontWeight', 'bold'); % Also check weight

save_comparison_figure_new(fig_current, test_name_current, 'original', output_dir_new);

params_current = struct();
params_current.beautify_sgtitle = false;
% Apply some global styles to see they are NOT applied to sgtitle
params_current.font_name = 'Arial'; % Different from sgtitle's original
params_current.base_font_size = 10;   % Different from sgtitle's original
params_current.text_color = [0 0.5 0]; % Different from sgtitle's original (dark green)
params_current.title_scale = 1.5; % This would affect sgtitle if it were processed
params_current.log_level = 0;

fprintf('  Testing with beautify_sgtitle = false.\n');
fprintf('  Original sgtitle - Font: %s, Size: %d, Color: [%.1f %.1f %.1f]\n', ...
    original_sgtitle_fontname, original_sgtitle_fontsize, original_sgtitle_color);
fprintf('  Global beautify params - Font: %s, BaseSize: %d, TextColor: [%.1f %.1f %.1f]\n', ...
    params_current.font_name, params_current.base_font_size, params_current.text_color);

try
    params_current.figure_handle = fig_current;
    beautify_figure(params_current);
    % We don't set the main figure title here, as we are checking sgtitle specifically

    sgt_handle_after = findobj(fig_current, 'Type', 'text', '-and', 'Tag', 'sgtitle'); % sgtitle creates a text object with this tag
    passed_verification = true;

    if isempty(sgt_handle_after) || ~isvalid(sgt_handle_after)
        fprintf('  VERIFICATION FAIL: SGTitle handle not found or invalid after beautification.\n');
        passed_verification = false;
    else
        sgt_handle_after = sgt_handle_after(1); % Use the first one found
        if ~strcmp(sgt_handle_after.String, original_sgtitle_text)
            % This shouldn't happen as beautify_figure doesn't change string content
            fprintf('  VERIFICATION WARN: SGTitle String changed. Original: "%s", Current: "%s"\n', original_sgtitle_text, sgt_handle_after.String);
        end
        if ~strcmp(sgt_handle_after.FontName, original_sgtitle_fontname)
            fprintf('  VERIFICATION FAIL: SGTitle FontName changed. Original: %s, Current: %s\n', original_sgtitle_fontname, sgt_handle_after.FontName);
            passed_verification = false;
        end
        if abs(sgt_handle_after.FontSize - original_sgtitle_fontsize) > 0.1
            fprintf('  VERIFICATION FAIL: SGTitle FontSize changed. Original: %.1f, Current: %.1f\n', original_sgtitle_fontsize, sgt_handle_after.FontSize);
            passed_verification = false;
        end
        if ~isequal(sgt_handle_after.Color, original_sgtitle_color)
            fprintf('  VERIFICATION FAIL: SGTitle Color changed. Original: [%.1f %.1f %.1f], Current: [%.1f %.1f %.1f]\n', ...
                original_sgtitle_color, sgt_handle_after.Color);
            passed_verification = false;
        end
        if ~strcmp(lower(sgt_handle_after.FontWeight), 'bold') % Original was bold
            fprintf('  VERIFICATION FAIL: SGTitle FontWeight changed. Original: bold, Current: %s\n', sgt_handle_after.FontWeight);
            passed_verification = false;
        end
    end

    % Also check that the subplot title IS styled
    ax_title_after = ax_sgtitle_test.Title;
    expected_ax_title_font = params_current.font_name;
    % Scaled font size for subplot title: base_font_size * title_scale * scale_factor
    % For a single plot (1x1 tiled layout), scale_factor is 1.6 from default_params.scaling_map{1}
    % global_font_scale_factor is 1.0 by default in params_current unless overridden
    effective_base_font_size = params_current.base_font_size * (params_current.global_font_scale_factor); % global_font_scale_factor is 1.0
    scale_factor_for_single_plot = 1.6; % From default_params.scaling_map for 1 subplot
    expected_ax_title_fontsize = round(effective_base_font_size * params_current.title_scale * scale_factor_for_single_plot);

    if isvalid(ax_title_after)
        if strcmp(ax_title_after.FontName, expected_ax_title_font) && ...
                abs(ax_title_after.FontSize - expected_ax_title_fontsize) < 1.1 && ... % Allow 1 point difference due to rounding
                isequal(ax_title_after.Color, params_current.text_color)
            fprintf('  VERIFICATION INFO: Subplot title appears styled as expected.\n');
        else
            fprintf('  VERIFICATION WARN: Subplot title does not appear to be styled as expected.\n');
            fprintf('    Subplot Title - Font: %s (Exp: %s), Size: %.1f (Exp: ~%.1f), Color: [%.1f %.1f %.1f] (Exp: [%.1f %.1f %.1f])\n', ...
                ax_title_after.FontName, expected_ax_title_font, ax_title_after.FontSize, expected_ax_title_fontsize, ax_title_after.Color, params_current.text_color);
        end
    else
        fprintf('  VERIFICATION WARN: Could not find subplot title to check if it was styled.\n');
    end

    if passed_verification
        fprintf('  VERIFICATION PASS: SGTitle properties appear unchanged as expected.\n');
    else
        fprintf('  VERIFICATION FAIL: Some SGTitle properties changed unexpectedly.\n');
    end

    save_comparison_figure_new(fig_current, test_name_current, 'beautified', output_dir_new);
    fprintf('  Applied beautify_figure. Check that the main sgtitle is NOT styled (font, size, color), but the subplot title IS styled.\n');
catch ME_test
    fprintf('  ERROR during New Test Case %d (%s): %s\n', test_case_num, test_name_current, ME_test.message);
end
if ishandle(fig_current); close(fig_current); end
test_case_num = test_case_num + 1;

%% --- Test Case: `marker_cycle_threshold` and `line_style_cycle_threshold` ('auto' mode) ---
fprintf('\n--- Running New Test Case %d: Marker/Line Cycle Thresholds (auto mode) ---\n', test_case_num);

common_params_threshold_test = struct();
common_params_threshold_test.cycle_marker_styles = 'auto';
common_params_threshold_test.cycle_line_styles = 'auto';
common_params_threshold_test.log_level = 2; % ENABLE DETAILED LOGGING
% Define some default marker and line styles for beautify_figure to use if it decides to cycle
common_params_threshold_test.marker_styles = {'o', 's', 'd', '^'};
common_params_threshold_test.line_style_order = {'-', '--', ':'};

% Sub-case 1: Marker cycling based on marker_cycle_threshold
marker_thresh = 3; % Let's use the default from beautify_figure: params.marker_cycle_threshold = 3
common_params_threshold_test.marker_cycle_threshold = marker_thresh;

% Test just below threshold (markers should NOT cycle, all should be 'none' or their original if any)
num_plots_below_marker_thresh = marker_thresh;
test_name_marker_below = sprintf('new_test_%02d_marker_cycle_below_thresh%d', test_case_num, num_plots_below_marker_thresh);
fig_marker_below = figure('Visible', 'off', 'Position', [100,100,700,500]);
hold on;
h_plots_marker_below = gobjects(num_plots_below_marker_thresh, 1);
for p_idx = 1:num_plots_below_marker_thresh
    h_plots_marker_below(p_idx) = plot(1:5, rand(1,5) + p_idx, 'DisplayName', sprintf('Series %d', p_idx));
end
hold off; legend('show'); grid on;
title([test_name_marker_below ' Original'], 'Interpreter', 'none');
save_comparison_figure_new(fig_marker_below, test_name_marker_below, 'original', output_dir_new);

fprintf('  Testing marker cycling: %d plots (<= threshold %d). Markers should NOT cycle beyond plot defaults.\n', num_plots_below_marker_thresh, marker_thresh);
try
    params_marker_below = common_params_threshold_test;
    params_marker_below.figure_handle = fig_marker_below;
    beautify_figure(params_marker_below);
    title([test_name_marker_below ' Beautified (Markers Unchanged)'], 'Interpreter', 'none');

    passed_marker_below = true;
    for p_idx = 1:num_plots_below_marker_thresh
        if ~isvalid(h_plots_marker_below(p_idx)) continue; end
        current_marker = get(h_plots_marker_below(p_idx), 'Marker');
        % Default for plot is 'none'. If beautify_figure didn't cycle, it should remain 'none'.
        if ~strcmp(current_marker, 'none')
            fprintf('  VERIFICATION FAIL (Marker Below Thresh): Plot %d Marker is "%s", expected "none" (no cycle).\n', p_idx, current_marker);
            passed_marker_below = false;
        end
    end
    if passed_marker_below
        fprintf('  VERIFICATION PASS (Marker Below Thresh): Markers did not cycle as expected.\n');
    end
    save_comparison_figure_new(fig_marker_below, test_name_marker_below, 'beautified', output_dir_new);
catch ME_marker_below
    fprintf('  ERROR during New Test Case %d (%s): %s\n', test_case_num, test_name_marker_below, ME_marker_below.message);
end
if ishandle(fig_marker_below); close(fig_marker_below); end

% Test just above threshold (markers SHOULD cycle)
num_plots_above_marker_thresh = marker_thresh + 1;
test_name_marker_above = sprintf('new_test_%02d_marker_cycle_above_thresh%d', test_case_num, num_plots_above_marker_thresh);
fig_marker_above = figure('Visible', 'off', 'Position', [100,100,700,500]);
hold on;
h_plots_marker_above = gobjects(num_plots_above_marker_thresh, 1);
for p_idx = 1:num_plots_above_marker_thresh
    h_plots_marker_above(p_idx) = plot(1:5, rand(1,5) + p_idx, 'DisplayName', sprintf('Series %d', p_idx));
end
hold off; legend('show'); grid on;
title([test_name_marker_above ' Original'], 'Interpreter', 'none');
save_comparison_figure_new(fig_marker_above, test_name_marker_above, 'original', output_dir_new);

fprintf('  Testing marker cycling: %d plots (> threshold %d). Markers SHOULD cycle.\n', num_plots_above_marker_thresh, marker_thresh);
try
    params_marker_above = common_params_threshold_test;
    params_marker_above.figure_handle = fig_marker_above;
    beautify_figure(params_marker_above);
    title([test_name_marker_above ' Beautified (Markers Cycled)'], 'Interpreter', 'none');

    passed_marker_above = true;
    cycled_markers_found = zeros(num_plots_above_marker_thresh,1);
    for p_idx = 1:num_plots_above_marker_thresh
        if ~isvalid(h_plots_marker_above(p_idx)) continue; end
        current_marker_from_plot = get(h_plots_marker_above(p_idx), 'Marker');
        expected_marker_shorthand = common_params_threshold_test.marker_styles{mod(p_idx-1, length(common_params_threshold_test.marker_styles))+1};

        is_match = false;
        % Use the map defined earlier (ensure it's in scope, e.g., marker_shorthand_to_full_map)
        if marker_shorthand_to_full_map.isKey(expected_marker_shorthand)
            possible_names = marker_shorthand_to_full_map(expected_marker_shorthand);
            if any(strcmp(current_marker_from_plot, possible_names))
                is_match = true;
            end
        else % Fallback for safety, though all default markers are in map
            if strcmp(current_marker_from_plot, expected_marker_shorthand)
                is_match = true;
            end
        end

        if ~is_match
            fprintf('  VERIFICATION FAIL (Marker Above Thresh): Plot %d Marker is "%s", expected shorthand "%s" (or its full equivalent) from cycle.\n', p_idx, current_marker_from_plot, expected_marker_shorthand);
            passed_marker_above = false;
        else
            cycled_markers_found(p_idx) = 1;
        end
    end
    if passed_marker_above && sum(cycled_markers_found) == num_plots_above_marker_thresh
        fprintf('  VERIFICATION PASS (Marker Above Thresh): Markers cycled as expected.\n');
    elseif passed_marker_above % individual checks passed but maybe not all plots checked if some invalid
        fprintf('  VERIFICATION INFO (Marker Above Thresh): All valid plots showed expected cycled markers.\n');
    else
        fprintf('  VERIFICATION FAIL (Marker Above Thresh): Not all markers cycled as expected.\n');
    end
    save_comparison_figure_new(fig_marker_above, test_name_marker_above, 'beautified', output_dir_new);
catch ME_marker_above
    fprintf('  ERROR during New Test Case %d (%s): %s\n', test_case_num, test_name_marker_above, ME_marker_above.message);
end
if ishandle(fig_marker_above); close(fig_marker_above); end


% Sub-case 2: Line style cycling based on line_style_cycle_threshold
line_thresh = 2; % Let's use the default from beautify_figure: params.line_style_cycle_threshold = 2
common_params_threshold_test.line_style_cycle_threshold = line_thresh;
common_params_threshold_test.cycle_marker_styles = false; % Turn off marker cycling for this sub-test clarity

% Test just below threshold (line styles should NOT cycle beyond plot defaults)
num_plots_below_line_thresh = line_thresh;
test_name_line_below = sprintf('new_test_%02d_line_cycle_below_thresh%d', test_case_num, num_plots_below_line_thresh);
fig_line_below = figure('Visible', 'off', 'Position', [100,100,700,500]);
hold on;
h_plots_line_below = gobjects(num_plots_below_line_thresh, 1);
for p_idx = 1:num_plots_below_line_thresh
    h_plots_line_below(p_idx) = plot(1:5, rand(1,5) + p_idx, 'DisplayName', sprintf('Series %d', p_idx));
end
hold off; legend('show'); grid on;
title([test_name_line_below ' Original'], 'Interpreter', 'none');
save_comparison_figure_new(fig_line_below, test_name_line_below, 'original', output_dir_new);

fprintf('  Testing line style cycling: %d plots (<= threshold %d). Line styles should NOT cycle beyond plot defaults (solid).\n', num_plots_below_line_thresh, line_thresh);
try
    params_line_below = common_params_threshold_test;
    params_line_below.figure_handle = fig_line_below;
    beautify_figure(params_line_below);
    title([test_name_line_below ' Beautified (Lines Unchanged)'], 'Interpreter', 'none');

    passed_line_below = true;
    for p_idx = 1:num_plots_below_line_thresh
        if ~isvalid(h_plots_line_below(p_idx)) continue; end
        current_linestyle = get(h_plots_line_below(p_idx), 'LineStyle');
        % Default for plot is '-'. If beautify_figure didn't cycle, it should remain '-'.
        if ~strcmp(current_linestyle, '-')
            fprintf('  VERIFICATION FAIL (Line Below Thresh): Plot %d LineStyle is "%s", expected "-" (no cycle).\n', p_idx, current_linestyle);
            passed_line_below = false;
        end
    end
    if passed_line_below
        fprintf('  VERIFICATION PASS (Line Below Thresh): Line styles did not cycle as expected.\n');
    end
    save_comparison_figure_new(fig_line_below, test_name_line_below, 'beautified', output_dir_new);
catch ME_line_below
    fprintf('  ERROR during New Test Case %d (%s): %s\n', test_case_num, test_name_line_below, ME_line_below.message);
end
if ishandle(fig_line_below); close(fig_line_below); end

% Test just above threshold (line styles SHOULD cycle)
num_plots_above_line_thresh = line_thresh + 1;
test_name_line_above = sprintf('new_test_%02d_line_cycle_above_thresh%d', test_case_num, num_plots_above_line_thresh);
fig_line_above = figure('Visible', 'off', 'Position', [100,100,700,500]);
hold on;
h_plots_line_above = gobjects(num_plots_above_line_thresh, 1);
for p_idx = 1:num_plots_above_line_thresh
    h_plots_line_above(p_idx) = plot(1:5, rand(1,5) + p_idx, 'DisplayName', sprintf('Series %d', p_idx));
end
hold off; legend('show'); grid on;
title([test_name_line_above ' Original'], 'Interpreter', 'none');
save_comparison_figure_new(fig_line_above, test_name_line_above, 'original', output_dir_new);

fprintf('  Testing line style cycling: %d plots (> threshold %d). Line styles SHOULD cycle.\n', num_plots_above_line_thresh, line_thresh);
try
    params_line_above = common_params_threshold_test;
    params_line_above.figure_handle = fig_line_above;
    beautify_figure(params_line_above);
    title([test_name_line_above ' Beautified (Lines Cycled)'], 'Interpreter', 'none');

    passed_line_above = true;
    cycled_lines_found = zeros(num_plots_above_line_thresh,1);
    for p_idx = 1:num_plots_above_line_thresh
        if ~isvalid(h_plots_line_above(p_idx)) continue; end
        current_linestyle = get(h_plots_line_above(p_idx), 'LineStyle');
        expected_linestyle = common_params_threshold_test.line_style_order{mod(p_idx-1, length(common_params_threshold_test.line_style_order))+1};
        if ~strcmp(current_linestyle, expected_linestyle)
            fprintf('  VERIFICATION FAIL (Line Above Thresh): Plot %d LineStyle is "%s", expected "%s" from cycle.\n', p_idx, current_linestyle, expected_linestyle);
            passed_line_above = false;
        else
            cycled_lines_found(p_idx) = 1;
        end
    end
    if passed_line_above && sum(cycled_lines_found) == num_plots_above_line_thresh
        fprintf('  VERIFICATION PASS (Line Above Thresh): Line styles cycled as expected.\n');
    elseif passed_line_above
        fprintf('  VERIFICATION INFO (Line Above Thresh): All valid plots showed expected cycled line styles.\n');
    else
        fprintf('  VERIFICATION FAIL (Line Above Thresh): Not all line styles cycled as expected.\n');
    end
    save_comparison_figure_new(fig_line_above, test_name_line_above, 'beautified', output_dir_new);
catch ME_line_above
    fprintf('  ERROR during New Test Case %d (%s): %s\n', test_case_num, test_name_line_above, ME_line_above.message);
end
if ishandle(fig_line_above); close(fig_line_above); end

test_case_num = test_case_num + 1;

%% --- Test Case: Specific Named Color Palettes ('turbo', 'cividis') ---
fprintf('\n--- Running New Test Case %d: Specific Named Color Palettes ---\n', test_case_num);
palettes_to_test = {'turbo', 'cividis'};
num_lines_palette_test = 5; % Number of lines to plot

for p_idx = 1:length(palettes_to_test)
    current_palette_name = palettes_to_test{p_idx};
    test_name_current_palette = sprintf('new_test_%02d_palette_%s', test_case_num, current_palette_name);

    fig_palette = figure('Visible', 'off', 'Position', [100, 100, 650, 480]);
    hold on;
    h_plot_lines_palette = gobjects(num_lines_palette_test, 1);
    for line_idx = 1:num_lines_palette_test
        h_plot_lines_palette(line_idx) = plot(1:10, rand(1,10) + line_idx*2, 'DisplayName', sprintf('Data %d', line_idx));
    end
    hold off;
    legend('show');
    title([test_name_current_palette ' Original (Default Colors)'], 'Interpreter', 'none');
    xlabel('X-value'); ylabel('Y-value'); grid on;
    save_comparison_figure_new(fig_palette, test_name_current_palette, 'original', output_dir_new);

    params_palette = struct();
    params_palette.color_palette = current_palette_name;
    params_palette.plot_line_width = 1.5; % Make lines reasonably thick
    params_palette.log_level = 0;

    fprintf('  Testing with color_palette = ''%s''.\n', current_palette_name);
    try
        params_palette.figure_handle = fig_palette;
        beautify_figure(params_palette);
        title([test_name_current_palette ' Beautified (' current_palette_name ')'], 'Interpreter', 'none');

        % Verification: Check if line colors are different from default and from each other
        % This is a basic check; exact color values depend on the palette definition.
        colors_changed = false;
        if num_lines_palette_test > 1 && isvalid(h_plot_lines_palette(1)) && isvalid(h_plot_lines_palette(2))
            color1 = get(h_plot_lines_palette(1), 'Color');
            color2 = get(h_plot_lines_palette(2), 'Color');
            if ~isequal(color1, color2)
                colors_changed = true; % At least the first two are different
            end
            % A more robust check would involve comparing with known values from these palettes
            % but that's too complex for this auto-generated script.
            % For now, we rely on visual inspection and the fact that an error isn't thrown.
            fprintf('  VERIFICATION INFO: Line colors are expected to match the ''%s'' palette. Visual check required.\n', current_palette_name);
            if colors_changed
                fprintf('    Basic check: First two line colors are different, suggesting palette application.\n');
            else
                fprintf('    Basic check WARN: First two line colors are the same. Palette may not have applied as expected or has few unique colors.\n');
            end
        elseif num_lines_palette_test == 1
            fprintf('  VERIFICATION INFO: Single line plotted. Visual check required for ''%s'' palette color.\n', current_palette_name);
        end

        save_comparison_figure_new(fig_palette, test_name_current_palette, 'beautified', output_dir_new);
        fprintf('  Applied beautify_figure with %s palette. Visually inspect line colors.\n', current_palette_name);
    catch ME_test_palette
        fprintf('  ERROR during New Test Case %d (%s with %s palette): %s\n', test_case_num, test_name_current_palette, current_palette_name, ME_test_palette.message);
    end
    if ishandle(fig_palette); close(fig_palette); end
end
test_case_num = test_case_num + 1;

%% --- Test Case: Stats Overlay Default Interpreter ---
fprintf('\n--- Running New Test Case %d: Stats Overlay Default Interpreter ---\n', test_case_num);
test_name_stats_interpreter = sprintf('new_test_%02d_stats_interpreter', test_case_num);
fig_stats_interpreter = figure('Visible', 'off', 'Position', [100, 100, 600, 450]);
try
    ax = axes(fig_stats_interpreter);
    x_data_stats_interpreter = 1:10;
    y_data_stats_interpreter = rand(1,10) * 5;
    plot(ax, x_data_stats_interpreter, y_data_stats_interpreter, 'Tag', 'DataForStatsInterpreterTest', 'LineWidth', 1.5);
    title(ax, [strrep(test_name_stats_interpreter, '_', '\_') ' Original'], 'Interpreter', 'tex');
    xlabel(ax, 'X-axis'); ylabel(ax, 'Y-axis'); grid(ax, 'on');
    save_comparison_figure_new(fig_stats_interpreter, test_name_stats_interpreter, 'original', output_dir_new);

    params_stats_interpreter = struct();
    params_stats_interpreter.stats_overlay.enabled = true;
    params_stats_interpreter.stats_overlay.target_plot_handle_tag = 'DataForStatsInterpreterTest';
    params_stats_interpreter.stats_overlay.statistics = {'mean', 'N'}; % Standard stats
    params_stats_interpreter.log_level = 0; % Suppress beautify_figure's internal logs

    fprintf('  Testing stats_overlay for default TeX interpreter behavior.\n');

    params_stats_interpreter.figure_handle = fig_stats_interpreter;
    beautify_figure(params_stats_interpreter); % Apply beautification

    title(ax, [strrep(test_name_stats_interpreter, '_', '\_') ' Beautified (Stats Default Interpreter)'], 'Interpreter', 'tex');

    stats_text_obj_interpreter = findobj(fig_stats_interpreter, 'Type', 'text', 'Tag', 'BeautifyFig_StatsOverlay');
    passed_interpreter_verification = true;

    if isempty(stats_text_obj_interpreter)
        fprintf('  VERIFICATION FAIL (Stats Interpreter): Stats overlay text object not found.\n');
        passed_interpreter_verification = false;
    elseif ~isvalid(stats_text_obj_interpreter(1)) % Check if the first found object is valid
        fprintf('  VERIFICATION FAIL (Stats Interpreter): Stats overlay text object handle is invalid.\n');
        passed_interpreter_verification = false;
    else
        stats_text_obj_interpreter = stats_text_obj_interpreter(1); % Use the first valid object
        actual_interpreter = get(stats_text_obj_interpreter, 'Interpreter');
        if ~strcmp(actual_interpreter, 'tex')
            fprintf('  VERIFICATION FAIL (Stats Interpreter): Interpreter is "%s", expected default "tex".\n', actual_interpreter);
            passed_interpreter_verification = false;
        else
            fprintf('  VERIFICATION PASS (Stats Interpreter): Interpreter is "tex" as expected by default.\n');
        end
    end

    if passed_interpreter_verification
        fprintf('  Overall VERIFICATION PASS for stats overlay interpreter.\n');
    else
        fprintf('  Overall VERIFICATION FAIL for stats overlay interpreter.\n');
    end

    fprintf('  VERIFICATION INFO (Stats Interpreter): Visual check: If default stat labels (e.g., "Mean", "N") ever contained TeX characters like "_" or "^", they should render accordingly due to the default ''tex'' interpreter.\n');
    save_comparison_figure_new(fig_stats_interpreter, test_name_stats_interpreter, 'beautified', output_dir_new);

catch ME_test_stats_interpreter
    fprintf('  ERROR during New Test Case %d (%s - Stats Interpreter): %s\n', test_case_num, test_name_stats_interpreter, ME_test_stats_interpreter.message);
    if isprop(ME_test_stats_interpreter, 'stack') && ~isempty(ME_test_stats_interpreter.stack)
        for k_stack = 1:length(ME_test_stats_interpreter.stack)
            fprintf('    Error in %s (line %d)\n', ME_test_stats_interpreter.stack(k_stack).name, ME_test_stats_interpreter.stack(k_stack).line);
        end
    end
end
if ishandle(fig_stats_interpreter); close(fig_stats_interpreter); end
test_case_num = test_case_num + 1;

%% --- Test Case: Interactive Legend Recreation Robustness ---
fprintf('\n--- Running New Test Case %d: Interactive Legend Recreation Robustness ---\n', test_case_num);
test_name_current = sprintf('new_test_%02d_interactive_legend_recreation', test_case_num);
fig_current = figure('Visible', 'off', 'Position', [100, 100, 700, 500]);
ax_handle = axes(fig_current); % Get axes handle for plot modifications
try
    % Initial plot
    hold(ax_handle, 'on');
    h_plots = gobjects(2,1); % Pre-allocate for plot handles
    h_plots(1) = plot(ax_handle, 1:10, rand(1,10), 'DisplayName', 'Series A - Original');
    h_plots(2) = plot(ax_handle, 1:10, rand(1,10)+2, 'DisplayName', 'Series B - Original');
    hold(ax_handle, 'off');
    legend(ax_handle, 'show');
    title(ax_handle, [strrep(test_name_current, '_', '\_') ' Original'], 'Interpreter', 'tex');
    xlabel(ax_handle, 'X-axis'); ylabel(ax_handle, 'Y-axis'); grid(ax_handle, 'on');
    save_comparison_figure_new(fig_current, test_name_current, 'original', output_dir_new);

    % First call to beautify_figure
    params_current = struct();
    params_current.interactive_legend = true;
    params_current.log_level = 0;
    params_current.figure_handle = fig_current; % Explicitly pass figure handle

    fprintf('  Calling beautify_figure (1st time) with interactive_legend = true.\n');
    beautify_figure(params_current);
    title(ax_handle, [strrep(test_name_current, '_', '\_') ' Beautified - First Call'], 'Interpreter', 'tex');
    save_comparison_figure_new(fig_current, [test_name_current '_beautified_first_call'], 'beautified', output_dir_new);
    fprintf('  First call to beautify_figure complete.\n');

    % Modify the plot: delete one line, add another
    fprintf('  Modifying plot elements before second call...\n');
    if isvalid(h_plots(1)); delete(h_plots(1)); end % Delete Series A
    hold(ax_handle, 'on');
    plot(ax_handle, 1:10, rand(1,10)+5, 'DisplayName', 'Series C - New', 'LineWidth', 2, 'Color', 'green');
    hold(ax_handle, 'off');
    % Legend will be updated by the next beautify_figure call.

    % Second call to beautify_figure on the same figure
    fprintf('  Calling beautify_figure (2nd time) on the same figure with interactive_legend = true.\n');
    beautify_figure(params_current); % Re-apply to the same fig_current
    title(ax_handle, [strrep(test_name_current, '_', '\_') ' Beautified - Second Call'], 'Interpreter', 'tex');

    fprintf('  VERIFICATION INFO: Interactive legend robustness test. Check %s_beautified_second_call.png.\n', test_name_current);
    fprintf('  Manual interaction with legend (clicking items, ctrl-clicking) in MATLAB environment should work without errors if possible.\n');
    fprintf('  Test primarily ensures no crash during repeated calls with plot modifications.\n');
    save_comparison_figure_new(fig_current, [test_name_current '_beautified_second_call'], 'beautified', output_dir_new);
    fprintf('  Second call to beautify_figure complete. Test passed if no errors occurred.\n');

catch ME_test
    fprintf('  ERROR during New Test Case %d (%s): %s\n', test_case_num, test_name_current, ME_test.message);
    if isprop(ME_test, 'stack') && ~isempty(ME_test.stack)
        for k_stack = 1:length(ME_test.stack)
            fprintf('    Error in %s (line %d)\n', ME_test.stack(k_stack).name, ME_test.stack(k_stack).line);
        end
    end
end
if ishandle(fig_current); close(fig_current); end
test_case_num = test_case_num + 1;

%% Teardown
fprintf('
--- New Test Script Complete ---
');
fprintf('Please check the "%s" directory for saved figures from new tests.
', output_dir_new);
% close all; % Optional: close all figures at the very end
fprintf('Done with new tests.
');

function test_beautify_figure()
% TEST_BEAUTIFY_FIGURE A test suite for the beautify_figure function.
%
%   This script runs a series of tests on the beautify_figure function,
%   generating 'before' and 'after' images for visual comparison. The
%   images are saved in a 'test_outputs' directory.

% --- Setup ---
fprintf('--- Setting up test environment ---\n');
output_dir = 'test_outputs';
if ~exist(output_dir, 'dir')
    mkdir(output_dir);
    fprintf('Created directory: %s\n', output_dir);
end

% Add the current directory to the path to ensure beautify_figure is found
addpath(pwd);

% --- Test Runner ---
% List of test functions to run
test_handles = {
    @test_case_default, ...
    @test_case_presets, ...
    @test_case_themes, ...
    @test_case_layouts, ...
    @test_case_plot_types, ...
    @test_case_color_palettes, ...
    @test_case_legend_options, ...
    @test_case_stats_overlay, ...
    @test_case_edge_cases, ...
    @test_case_more_features ...
};

total_tests = length(test_handles);
passed_tests = 0;
failed_tests = 0;

fprintf('--- Starting test suite ---\n');
for k = 1:total_tests
    test_func = test_handles{k};
    test_name = func2str(test_func);
    fprintf('Running test (%d/%d): %s...\n', k, total_tests, test_name);
    try
        test_func(output_dir);
        fprintf('  ...PASSED\n');
        passed_tests = passed_tests + 1;
    catch me
        fprintf('  ...FAILED: %s\n', me.message);
        fprintf('    Error in %s (line %d)\n', me.stack(1).name, me.stack(1).line);
        failed_tests = failed_tests + 1;
    end
end

fprintf('--- Test suite finished ---\n');
fprintf('Results: %d passed, %d failed, %d total.\n', passed_tests, failed_tests, total_tests);

% Exit with error code if any tests failed (for CI)
if failed_tests > 0
    exit(1);
else
    exit(0);
end

end


% =========================================================================
% --- TEST CASES ---
% =========================================================================

function test_case_default(output_dir)
    % Tests the default beautification on a simple plot.
    fig = figure('Visible', 'off');
    plot(1:10, rand(1, 10).* (1:10), 's-');
    title('Default Beautification Test');
    xlabel('X-axis');
    ylabel('Y-axis');
    save_before_after(fig, 'default', output_dir, {});
    close(fig);
end

function test_case_presets(output_dir)
    % Tests all available style presets.
    presets = {'publication', 'presentation_dark', 'presentation_light', 'minimalist'};
    for k = 1:length(presets)
        preset_name = presets{k};
        fig = figure('Visible', 'off');
        plot(sind(0:10:360), 'o--');
        title(['Preset: ' strrep(preset_name, '_', ' ')]);
        params = {'style_preset', preset_name};
        save_before_after(fig, ['preset_' preset_name], output_dir, params);
        close(fig);
    end
end

function test_case_themes(output_dir)
    % Tests the 'dark' theme specifically.
    fig = figure('Visible', 'off');
    plot(rand(10, 3));
    title('Dark Theme Test');
    legend('Series 1', 'Series 2', 'Series 3');
    params = {'theme', 'dark'};
    save_before_after(fig, 'theme_dark', output_dir, params);
    close(fig);
end

function test_case_layouts(output_dir)
    % Tests beautification on figures with subplots and tiled layouts.

    % Subplot test
    fig_subplot = figure('Visible', 'off');
    subplot(2, 2, 1); plot(rand(10,1)); title('Subplot 1');
    subplot(2, 2, 2); scatter(rand(20,1), rand(20,1)); title('Subplot 2');
    subplot(2, 2, 3); bar(rand(5,1)); title('Subplot 3');
    subplot(2, 2, 4); imagesc(rand(10,10)); title('Subplot 4');
    save_before_after(fig_subplot, 'layout_subplot', output_dir, {});
    close(fig_subplot);

    % Tiled layout test
    fig_tiled = figure('Visible', 'off');
    tiledlayout(2, 1);
    nexttile;
    plot(rand(10, 2));
    title('Tiled Layout - Tile 1');
    nexttile;
    histogram(randn(100, 1));
    title('Tiled Layout - Tile 2');
    save_before_after(fig_tiled, 'layout_tiled', output_dir, {});
    close(fig_tiled);
end

function test_case_plot_types(output_dir)
    % Tests various plot types in one figure.
    fig = figure('Visible', 'off', 'Position', [100 100 800 600]);
    tiledlayout(2, 2);

    nexttile;
    bar(1:5, rand(1,5));
    title('Bar Plot');

    nexttile;
    [X, Y, Z] = peaks(20);
    surface(X, Y, Z);
    title('Surface Plot');

    nexttile;
    theta = 0:0.01:2*pi;
    rho = sin(2*theta).*cos(2*theta);
    polarplot(theta, rho);
    title('Polar Plot');

    nexttile;
    try
        heatmap(rand(8, 5));
        title('Heatmap');
    catch
        % Heatmap might not be available in all versions
        text(0.5, 0.5, 'Heatmap not available', 'HorizontalAlignment', 'center');
        title('Heatmap (Skipped)');
    end

    save_before_after(fig, 'plot_types', output_dir, {});
    close(fig);
end

function test_case_color_palettes(output_dir)
    % Tests different color palettes.
    fig = figure('Visible', 'off');
    hold on;
    for k = 1:5
        plot(1:10, rand(1, 10) + k);
    end
    hold off;
    title('Color Palette: Viridis');
    params = {'color_palette', 'viridis'};
    save_before_after(fig, 'palette_viridis', output_dir, params);
    close(fig);

    % Custom palette
    fig_custom = figure('Visible', 'off');
    hold on;
    for k = 1:3
        plot(1:10, rand(1, 10) + k);
    end
    hold off;
    title('Custom Color Palette');
    custom_palette = [1 0 0; 0 1 0; 0 0 1]; % Red, Green, Blue
    params_custom = {'color_palette', custom_palette};
    save_before_after(fig_custom, 'palette_custom', output_dir, params_custom);
    close(fig_custom);
end

function test_case_legend_options(output_dir)
    % Tests legend options like location and smart display.
    fig = figure('Visible', 'off');
    plot(1:10, rand(10,3));
    title('Legend Test: Northeast Outside');
    legend('A', 'B', 'C');
    params = {'legend_location', 'northeastoutside'};
    save_before_after(fig, 'legend_location', output_dir, params);
    close(fig);
end

function test_case_stats_overlay(output_dir)
    % Tests the statistical overlay feature.
    fig = figure('Visible', 'off');
    x = 1:20;
    y = 2*x + randn(1, 20);
    plot(x, y, 's-');
    title('Statistics Overlay Test');
    stats_params.enabled = true;
    stats_params.statistics = {'mean', 'std', 'N'};
    params = {'stats_overlay', stats_params};
    save_before_after(fig, 'stats_overlay', output_dir, params);
    close(fig);
end

function test_case_edge_cases(output_dir)
    % Tests various edge cases.

    % Empty figure
    fig_empty = figure('Visible', 'off');
    title('Empty Figure Test');
    save_before_after(fig_empty, 'edge_case_empty', output_dir, {});
    close(fig_empty);

    % Figure with single plot (for smart legend)
    fig_single = figure('Visible', 'off');
    plot(1:10);
    legend('Single Line');
    title('Single Plot Line (Smart Legend)');
    params_smart = {'smart_legend_display', true}; % Legend should be hidden
    save_before_after(fig_single, 'edge_case_single_line_smart', output_dir, params_smart);

    % Now force it to show
    beautify_figure('figure_handle', fig_single, 'legend_force_single_entry', true);
    saveas(fig_single, fullfile(output_dir, 'edge_case_single_line_forced.png'));
    close(fig_single);

    % Figure with no plottable data in axes
    fig_no_data = figure('Visible', 'off');
    axes;
    title('Figure with Axes but No Data');
    save_before_after(fig_no_data, 'edge_case_no_data', output_dir, {});
    close(fig_no_data);
end


% =========================================================================
% --- HELPER FUNCTION ---
% =========================================================================

function test_case_more_features(output_dir)
    % Tests a variety of other features and parameters.

    % Test 1: Errorbar plot with marker/line cycling
    fig1 = figure('Visible', 'off');
    x = 1:10;
    y = 2*x + randn(size(x));
    err = rand(size(x));
    hold on;
    errorbar(x, y, err, 's');
    errorbar(x, y-3, err, 'd');
    hold off;
    title('Errorbar with Style Cycling');
    params1 = {'cycle_marker_styles', true, 'cycle_line_styles', true};
    save_before_after(fig1, 'features_errorbar_cycling', output_dir, params1);
    close(fig1);

    % Test 2: 'left-bottom' axis box style
    fig2 = figure('Visible', 'off');
    plot(rand(10,1));
    title('Axis Box Style: Left-Bottom');
    params2 = {'axis_box_style', 'left-bottom'};
    save_before_after(fig2, 'features_box_style', output_dir, params2);
    close(fig2);

    % Test 3: apply_to_colorbars = false
    fig3 = figure('Visible', 'off');
    [X, Y, Z] = peaks;
    contourf(X, Y, Z, 10);
    colorbar;
    title('apply_to_colorbars = false');
    % Use dark theme to make changes obvious
    params3 = {'apply_to_colorbars', false, 'theme', 'dark'};
    save_before_after(fig3, 'features_no_colorbar', output_dir, params3);
    close(fig3);
end


% =========================================================================
% --- HELPER FUNCTION ---
% =========================================================================

function save_before_after(fig_handle, test_name, output_dir, beautify_params)
% Saves a 'before' image, applies beautify_figure, and saves an 'after' image.

% Ensure figure is drawn before saving
drawnow;

% Save "before" image
try
    filename_before = fullfile(output_dir, [test_name '_before.png']);
    saveas(fig_handle, filename_before);
catch me_save_before
    warning('Could not save "before" image for test %s: %s', test_name, me_save_before.message);
end

% Apply beautification
beautify_figure('figure_handle', fig_handle, beautify_params{:});

% Ensure figure is drawn again after beautification
drawnow;

% Save "after" image
try
    filename_after = fullfile(output_dir, [test_name '_after.png']);
    saveas(fig_handle, filename_after);
catch me_save_after
    warning('Could not save "after" image for test %s: %s', test_name, me_save_after.message);
end

end

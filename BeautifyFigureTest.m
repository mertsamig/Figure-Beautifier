classdef BeautifyFigureTest < matlab.unittest.TestCase
    % BeautifyFigureTest tests the beautify_figure function.
    %
    %   To run these tests, execute 'runtests('BeautifyFigureTest')' in the MATLAB command window.
    %
    %   Requires MATLAB R2019b or newer for some features being tested (e.g., tiledlayout).

    properties
        TestFigure
    end

    methods(TestMethodSetup)
        function createFigure(testCase)
            % Create a new, invisible figure for each test.
            testCase.TestFigure = figure('Visible', 'off');
        end
    end

    methods(TestMethodTeardown)
        function closeFigure(testCase)
            % Close the figure after each test.
            close(testCase.TestFigure);
        end
    end

    properties (TestParameter)
        % Define parameters to be tested. The framework will run tests for each value.
        style_preset = {'default', 'publication', 'presentation_dark', 'presentation_light', 'minimalist'};
        theme = {'light', 'dark'};
    end

    methods(Test)
        function testDefaultBeautification(testCase)
            % Test that default beautification changes key properties from MATLAB defaults.

            % Create a simple plot
            plot(testCase.TestFigure, 1:10, rand(1, 10));
            ax = get(testCase.TestFigure, 'CurrentAxes');

            % Get some baseline properties
            original_font_size = get(ax, 'FontSize');
            original_line_width = get(ax.Children(1), 'LineWidth');

            % Apply beautification
            beautify_figure('figure_handle', testCase.TestFigure);

            % Verify properties have changed
            testCase.verifyNotEqual(get(ax, 'FontSize'), original_font_size, ...
                'FontSize should change from the MATLAB default.');
            testCase.verifyNotEqual(get(ax.Children(1), 'LineWidth'), original_line_width, ...
                'LineWidth of plot line should change from the MATLAB default.');
            testCase.verifyEqual(get(ax, 'Box'), 'on', ...
                'Box property should be "on" by default.');
        end

        function testPresetApplication(testCase, style_preset)
            % Test that applying a preset runs without error.
            % This is a smoke test to ensure no combination of parameters causes a crash.

            plot(testCase.TestFigure, 1:10, rand(1, 10));

            % The main verification is that this command runs without error.
            beautify_figure('figure_handle', testCase.TestFigure, 'style_preset', style_preset);

            % Add a simple, universal verification
            ax = get(testCase.TestFigure, 'CurrentAxes');
            testCase.verifyTrue(isvalid(ax), ['Axes should be valid after applying preset: ' style_preset]);
        end

        function testThemeApplication(testCase, theme)
            % Test that applying a theme runs without error and sets colors correctly.
            plot(testCase.TestFigure, 1:10, rand(1, 10));
            ax = get(testCase.TestFigure, 'CurrentAxes');

            beautify_figure('figure_handle', testCase.TestFigure, 'theme', theme);

            fig_color = get(testCase.TestFigure, 'Color');
            ax_color = get(ax, 'XColor');

            if strcmpi(theme, 'dark')
                testCase.verifyTrue(all(fig_color < 0.5), 'Dark theme should have a dark figure background.');
                testCase.verifyTrue(all(ax_color > 0.5), 'Dark theme should have light axes color.');
            else % light theme
                testCase.verifyTrue(all(fig_color > 0.5), 'Light theme should have a light figure background.');
                testCase.verifyTrue(all(ax_color < 0.5), 'Light theme should have dark axes color.');
            end
        end

        function testStatsOverlay(testCase)
            % Test the stats overlay feature.
            x = 1:10;
            y = (1:10) * 2; % Predictable data
            plot(testCase.TestFigure, x, y);

            stats_params.enabled = true;
            stats_params.statistics = {'mean', 'std', 'N'};

            % Capture command window output to check logs
            evalc("beautify_figure('figure_handle', testCase.TestFigure, 'stats_overlay', stats_params)");

            ax = get(testCase.TestFigure, 'CurrentAxes');
            stats_text_handle = findobj(ax, 'Type', 'text', 'Tag', 'BeautifyFig_StatsOverlay');

            % Verify that the text object was created
            testCase.verifyNotEmpty(stats_text_handle, 'Stats overlay text object should be created.');

            % Verify the content of the text object
            stats_string = get(stats_text_handle, 'String');

            % Calculate expected stats
            expected_mean = mean(y);
            expected_std = std(y);
            expected_N = length(y);

            expected_str_mean = sprintf('Mean: %.2f', expected_mean);
            expected_str_std = sprintf('Std Dev: %.2f', expected_std);
            expected_str_N = sprintf('N: %d', expected_N);

            testCase.verifyTrue(any(strcmp(stats_string, expected_str_mean)), 'Mean value in stats overlay is incorrect.');
            testCase.verifyTrue(any(strcmp(stats_string, expected_str_std)), 'Std Dev value in stats overlay is incorrect.');
            testCase.verifyTrue(any(strcmp(stats_string, expected_str_N)), 'N value in stats overlay is incorrect.');
        end

        function testSmartLegend(testCase)
            % Test the smart legend feature.

            % Case 1: Single plot line, legend should be hidden
            plot(testCase.TestFigure, 1:10);
            legend('Single Line');
            beautify_figure('figure_handle', testCase.TestFigure, 'smart_legend_display', true);
            leg_handle = findobj(testCase.TestFigure, 'Type', 'Legend');
            testCase.verifyEqual(get(leg_handle, 'Visible'), 'off', 'Legend should be hidden for a single plot with smart display on.');

            % Case 2: Force legend for single plot
            beautify_figure('figure_handle', testCase.TestFigure, 'smart_legend_display', true, 'legend_force_single_entry', true);
            leg_handle = findobj(testCase.TestFigure, 'Type', 'Legend');
            testCase.verifyEqual(get(leg_handle, 'Visible'), 'on', 'Legend should be visible when forced for a single plot.');

            % Case 3: Multiple plot lines, legend should be visible
            cla(testCase.TestFigure); % Clear figure for next plot
            plot(testCase.TestFigure, rand(10, 2));
            legend('Line 1', 'Line 2');
            beautify_figure('figure_handle', testCase.TestFigure, 'smart_legend_display', true);
            leg_handle_multi = findobj(testCase.TestFigure, 'Type', 'Legend');
            testCase.verifyEqual(get(leg_handle_multi, 'Visible'), 'on', 'Legend should be visible for multiple plots with smart display on.');
        end

        function testInvalidInput(testCase)
            % Test that the function handles invalid inputs gracefully.

            % Test with an invalid figure handle
            % We expect a warning/error message to be logged.
            % We use evalc to capture the command window output.
            invalid_handle = -1; % A handle that is guaranteed to be invalid
            cmd_output = evalc("beautify_figure('figure_handle', invalid_handle)");

            % Check for the expected error message in the captured output
            testCase.verifyMatches(cmd_output, 'No valid figure available', ...
                'Function should log an error for an invalid figure handle.');
        end

    end

    methods(Test)
        function testAxisBoxStyleLeftBottom(testCase)
            % Test the 'left-bottom' axis box style.
            plot(testCase.TestFigure, 1:10, rand(1, 10));
            ax = get(testCase.TestFigure, 'CurrentAxes');

            beautify_figure('figure_handle', testCase.TestFigure, 'axis_box_style', 'left-bottom');

            testCase.verifyEqual(get(ax, 'Box'), 'off', ...
                'Box property should be "off" for left-bottom style.');
            testCase.verifyEqual(get(ax, 'XAxisLocation'), 'bottom', ...
                'XAxisLocation should be "bottom" for left-bottom style.');
            testCase.verifyEqual(get(ax, 'YAxisLocation'), 'left', ...
                'YAxisLocation should be "left" for left-bottom style.');
        end

        function testApplyToColorbarsFalse(testCase)
            % Test that the colorbar is not modified when apply_to_colorbars is false.
            contourf(testCase.TestFigure, peaks(20));
            ax = get(testCase.TestFigure, 'CurrentAxes');
            cb = colorbar(ax);

            % Get original colorbar properties
            original_font_size = get(cb, 'FontSize');
            original_line_width = get(cb, 'LineWidth');

            % Apply beautification, which would normally change these
            beautify_figure('figure_handle', testCase.TestFigure, 'apply_to_colorbars', false);

            % Verify properties have NOT changed
            testCase.verifyEqual(get(cb, 'FontSize'), original_font_size, ...
                'Colorbar FontSize should not change when apply_to_colorbars is false.');
            testCase.verifyEqual(get(cb, 'LineWidth'), original_line_width, 'AbsTol', 1e-9, ...
                'Colorbar LineWidth should not change when apply_to_colorbars is false.');
        end
    end

    methods(Test)
        function testLogLevels(testCase)
            % Test the log_level parameter.
            plot(testCase.TestFigure, 1:10);

            % Test log_level 0 (silent)
            output_silent = evalc("beautify_figure('figure_handle', testCase.TestFigure, 'log_level', 0)");
            testCase.verifyEmpty(strtrim(output_silent), 'log_level 0 should produce no console output.');

            % Test log_level 1 (normal) - should produce some output
            output_normal = evalc("beautify_figure('figure_handle', testCase.TestFigure, 'log_level', 1)");
            testCase.verifyNotEmpty(strtrim(output_normal), 'log_level 1 should produce some console output.');

            % Test log_level 2 (detailed) - should produce more output
            output_detailed = evalc("beautify_figure('figure_handle', testCase.TestFigure, 'log_level', 2)");
            testCase.verifyGreaterThan(length(output_detailed), length(output_normal), ...
                'log_level 2 should produce more output than log_level 1.');
        end

        function testInteractiveLegendCallback(testCase)
            % Test that the interactive_legend parameter sets the callback.
            plot(testCase.TestFigure, rand(10, 2));
            legend('Line 1', 'Line 2');

            % Test with interactive legend enabled
            beautify_figure('figure_handle', testCase.TestFigure, 'interactive_legend', true);
            leg_handle = findobj(testCase.TestFigure, 'Type', 'Legend');
            testCase.verifyNotEmpty(get(leg_handle, 'ItemHitFcn'), ...
                'ItemHitFcn should be set when interactive_legend is true.');

            % Test with interactive legend disabled
            cla(testCase.TestFigure);
            plot(testCase.TestFigure, rand(10, 2));
            legend('Line 1', 'Line 2');
            beautify_figure('figure_handle', testCase.TestFigure, 'interactive_legend', false);
            leg_handle_disabled = findobj(testCase.TestFigure, 'Type', 'Legend');
            testCase.verifyEmpty(get(leg_handle_disabled, 'ItemHitFcn'), ...
                'ItemHitFcn should be empty when interactive_legend is false.');
        end

        function testExcludeObjectTags(testCase)
            % Test the exclude_object_tags parameter.
            ax = get(testCase.TestFigure, 'CurrentAxes');
            hold(ax, 'on');
            p1 = plot(ax, 1:10, rand(1, 10), 'Tag', 'plot1');
            p2 = plot(ax, 1:10, rand(1, 10) + 1, 'Tag', 'exclude_this_one');
            hold(ax, 'off');

            original_p2_linewidth = get(p2, 'LineWidth');

            % Beautify, excluding the second plot
            beautify_figure('figure_handle', testCase.TestFigure, 'exclude_object_tags', {'exclude_this_one'});

            % Verify p1's LineWidth changed
            testCase.verifyNotEqual(get(p1, 'LineWidth'), 0.5, 'AbsTol', 1e-9, ... % 0.5 is MATLAB default
                'LineWidth of non-excluded plot should change.');

            % Verify p2's LineWidth did NOT change
            testCase.verifyEqual(get(p2, 'LineWidth'), original_p2_linewidth, 'AbsTol', 1e-9, ...
                'LineWidth of excluded plot should not change.');
        end
    end

    methods(Test)
        function testInvalidParameterHandling(testCase)
            % Test that the function correctly handles various invalid parameter inputs.

            plot(testCase.TestFigure, 1:10);
            ax = get(testCase.TestFigure, 'CurrentAxes');

            % --- Test Case 1: Invalid enumerated string ---
            invalid_grid_density = 'totally_wrong_value';
            cmd_output_grid = evalc("beautify_figure('figure_handle', testCase.TestFigure, 'grid_density', invalid_grid_density)");

            % Verify warning message
            testCase.verifyMatches(cmd_output_grid, 'Invalid value for grid_density', ...
                'Should warn about invalid grid_density value.');
            testCase.verifyMatches(cmd_output_grid, 'Resetting to default', ...
                'Warning for grid_density should mention resetting to default.');

            % Verify fallback to default ('normal')
            % The default 'normal' sets XGrid to 'on'
            testCase.verifyEqual(get(ax, 'XGrid'), 'on', ...
                'grid_density should fall back to default value.');


            % --- Test Case 2: Invalid numeric scalar ---
            invalid_font_size = 'not a number';
            cmd_output_font = evalc("beautify_figure('figure_handle', testCase.TestFigure, 'base_font_size', invalid_font_size)");

            % Verify warning message
            testCase.verifyMatches(cmd_output_font, 'Invalid value for base_font_size', ...
                'Should warn about invalid base_font_size value.');

            % Verify fallback to default (10)
            % We can't know the exact final font size due to scaling, but it should be a number close to the default.
            final_font_size = get(ax, 'FontSize');
            testCase.verifyTrue(isnumeric(final_font_size) && isscalar(final_font_size), ...
                'FontSize should be a numeric scalar after fallback.');
        end
    end
end

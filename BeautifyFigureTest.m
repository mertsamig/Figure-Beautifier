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

        function testPublicationPreset(testCase)
            % Test the 'publication' style preset.

            plot(testCase.TestFigure, 1:10, rand(1, 10));
            ax = get(testCase.TestFigure, 'CurrentAxes');

            % Apply beautification with preset
            beautify_figure('figure_handle', testCase.TestFigure, 'style_preset', 'publication');

            % Verify key properties of the publication preset
            testCase.verifyEqual(get(ax, 'FontName'), 'Arial', ...
                'FontName should be Arial for publication preset.');
            test_line_width = get(ax.Children(1), 'LineWidth');
            testCase.verifyEqual(test_line_width, 1.0, 'AbsTol', 1e-9, ...
                'LineWidth should be 1.0 for publication preset.');
            testCase.verifyEqual(get(ax, 'Grid'), 'on', ...
                'Grid should be on for major lines in publication preset.');
            testCase.verifyEqual(get(ax, 'XMinorGrid'), 'off', ...
                'Minor grid should be off for publication preset.');
        end

        function testDarkTheme(testCase)
            % Test the 'dark' theme.
            plot(testCase.TestFigure, 1:10, rand(1, 10));
            ax = get(testCase.TestFigure, 'CurrentAxes');

            % Apply beautification with dark theme
            beautify_figure('figure_handle', testCase.TestFigure, 'theme', 'dark');

            % Verify colors
            dark_bg_color = get(testCase.TestFigure, 'Color');
            ax_color = get(ax, 'XColor'); % Assume XColor is representative

            % Background should be dark, axes should be light
            testCase.verifyTrue(all(dark_bg_color < 0.5), 'Figure background should be dark.');
            testCase.verifyTrue(all(ax_color > 0.5), 'Axes color should be light.');
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
end

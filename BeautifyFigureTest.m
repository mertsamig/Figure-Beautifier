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
end

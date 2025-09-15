% verify_optimization.m
% A script to verify the performance of beautify_figure.m

fprintf('Creating a complex figure to test beautify_figure performance...\n');

% Create a figure with many subplots
figure('Name', 'Performance Test Figure', 'NumberTitle', 'off');
t = tiledlayout(5, 5, 'TileSpacing', 'compact', 'Padding', 'compact');
title(t, 'Complex Figure for Performance Test');

% Populate the subplots
for i = 1:25
    nexttile;
    hold on;
    % Add multiple plot elements to each subplot
    plot(rand(10, 3), 'LineWidth', 0.5); % 3 lines
    scatter(rand(20, 1), rand(20, 1), 'filled'); % 1 scatter plot
    bar(rand(1, 5)); % 1 bar plot
    if mod(i, 2) == 0
        title(['Subplot ' num2str(i)]);
        xlabel('X-axis');
        ylabel('Y-axis');
    end
    if mod(i, 5) == 0
        legend('Line A', 'Line B', 'Line C', 'Data points', 'Bar data', 'Location', 'northeastoutside');
    end
    if mod(i, 3) == 0
        colorbar;
    end
end

fprintf('Figure created. Now running beautify_figure...\n');

% Time the execution of beautify_figure
tic;
beautify_figure('log_level', 1); % Use a less verbose log level for timing
elapsed_time = toc;

fprintf('beautify_figure execution completed.\n');
fprintf('Elapsed time: %.4f seconds.\n', elapsed_time);

% To properly verify the optimization, one would run this script with the
% version of beautify_figure.m from before the optimization, record the time,
% and then run it again with the optimized version. A significant decrease
% in elapsed time would confirm the effectiveness of the optimizations.
%
% For example:
%
% Before optimization: Elapsed time: ~X.XX seconds.
% After optimization:  Elapsed time: ~Y.YY seconds.
%
% We expect Y.YY to be noticeably smaller than X.XX, especially on complex
% figures like this one, due to the caching of findobj results for legends
% and colorbars and the batching of `set` calls.

disp('Verification script finished. Please compare the elapsed time with a pre-optimization run.');

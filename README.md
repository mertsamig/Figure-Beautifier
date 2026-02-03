# MATLAB Figure Beautifier (`beautify_figure.m`)

A MATLAB function to systematically enhance the aesthetics of figures for presentations and publications.

![Beautify Figure Example](https://user-images.githubusercontent.com/12345/beautify_figure_example.png)
*(Note: Example image. You can generate more sample images by running the `test_beautify_figure.m` script.)*

## Purpose

The `beautify_figure.m` script provides a comprehensive set of tools to improve the visual appeal of MATLAB figures. It allows for customization of fonts, colors, line styles, markers, grid, legend, titles, and much more. It operates on an entire figure, handling multiple subplots, tiled layouts, and tabs to apply consistent styling throughout.

## Basic Usage

The script uses name-value pair arguments for customization.

**To apply default beautification settings to the current figure:**
```matlab
% Generate a sample plot
figure;
plot(rand(10,3));
title('My Sample Plot');

% Beautify it!
beautify_figure();
```

**To apply custom settings:**
```matlab
% Generate another plot
figure;
scatter(rand(50,1), rand(50,1), 'filled');
title('Customized Scatter Plot');

% Beautify with specific parameters
beautify_figure('plot_line_width', 2, 'font_name', 'Helvetica', 'style_preset', 'minimalist');
```

**To apply beautification to a specific figure:**
```matlab
% Create two figures
h_fig1 = figure; plot(1:10); title('Figure 1');
h_fig2 = figure; plot(sin(1:0.1:10)); title('Figure 2');

% Apply settings only to the second figure
beautify_figure('figure_handle', h_fig2, 'color_palette', 'viridis');
```

## Parameters

The `beautify_figure.m` script offers a wide range of customizable parameters, passed as **name-value pairs**. For a detailed list of all parameters and their default values, please refer to the extensive help text within the `beautify_figure.m` script itself (e.g., by typing `help beautify_figure` in MATLAB).

Key parameters include:
*   `style_preset`: String, e.g., `'default'`, `'publication'`, `'presentation_light'`, `'minimalist'`. Applies a predefined set of styles.
*   `font_name`: Font family (e.g., `'Arial'`, `'Helvetica'`). (Can be part of a preset).
*   `base_font_size`: Base font size for scaling elements.
*   `plot_line_width`: Base line width for plotted data.
*   `color_palette`: Predefined palettes (`'default_matlab'`, `'lines'`, `'parula'`, `'viridis'`, etc.) or a custom Nx3 RGB matrix.
*   `export_settings`: A `struct` for controlling automatic figure export (see details below).
*   `stats_overlay`: A `struct` for configuring a basic statistical overlay (see details below).

## Font Considerations

For the most predictable visual results, it is recommended to specify font names (e.g., via the `font_name` parameter or within style presets) that are known to be installed on your system.

While `beautify_figure.m` requests specific fonts (like 'Swiss 721 BT' as a default or 'Helvetica Neue' in certain presets), MATLAB may automatically substitute these with available system fonts if the requested ones are not found. This substitution ensures that the script runs without error, but the visual appearance may differ from the intended design if the specified fonts are not present on the user's system. You can use the `listfonts` command in MATLAB to see available system fonts.

## Features

*   Configurable style presets (e.g., `'publication'`, `'presentation_light'`, `'minimalist'`) for quick common setups.
*   Font and text property adjustments (size, weight, color, font family).
*   Control over line styles, markers, and color palettes.
*   Automatic scaling of elements based on subplot density.
*   Support for tiled layouts and figure tabs.
*   Styling for various plot types, including line, scatter, bar, histogram, and heatmap charts.
*   Interactive legends (clickable items to toggle plot visibility, R2019b+).
*   Axes styling (box, grid, tick direction, layer).
*   Optional automatic export of figures to various formats (PNG, PDF, EPS, etc.).
*   Basic Statistical Overlay: Display basic statistics (mean, std, min, max, N, etc.) for plotted data directly on the figure.

## Detailed Features

### Style Presets

The `style_preset` parameter allows you to quickly apply a predefined collection of settings tailored for common use cases. User-defined parameters will always override any values set by a preset.

Available presets:
*   **`'default'`**: The standard beautification settings.
*   **`'publication'`**: Optimized for academic publications. Typically uses standard fonts (e.g., Arial or Times), appropriate font sizes, thinner lines for potentially dense plots, a black and white color scheme for axes/text, and a clear color palette for plots. Grid is often major lines only.
*   **`'presentation_light'`**: Suited for presentations on light backgrounds. Uses larger fonts, clear lines, and bright, distinct color palettes (e.g., 'turbo' is the default for this preset).
*   **`'minimalist'`**: A clean, uncluttered look with minimal gridlines, often using only left and bottom axes, and a grayscale or simple color scheme.

Example:
```matlab
% Apply the 'publication' preset
beautify_figure('style_preset', 'publication');

% Use 'presentation_light' but customize the font and palette
beautify_figure('style_preset', 'presentation_light', ...
                'font_name', 'Helvetica', ...
                'color_palette', 'viridis');
```

### Automatic Figure Export

The `export_settings` parameter accepts a `struct` to allow for direct export of the beautified figure.

Key `export_settings` fields:
*   `enabled` (boolean): Set to `true` to activate export. Default: `false`.
*   `filename` (string): The desired name for the output file, without the extension (e.g., `'my_plot'`). Default: `'beautified_figure'`.
*   `format` (string): The export format. Common options: `'png'`, `'jpeg'`, `'pdf'`, `'eps'`, `'svg'`, `'tiff'`. Default: `'png'`.
*   `resolution` (numeric): Resolution in Dots Per Inch (DPI) for raster formats (like PNG, JPEG, TIFF). Default: `300`.
*   `open_exported_file` (boolean): If `true`, attempts to open the exported file using the system's default application. Default: `false`.
*   `renderer` (string): MATLAB renderer to use (e.g., `'painters'`, `'opengl'`). Relevant for the `print` command fallback. Default: `'painters'`.
*   `ui` (boolean): If `true` (and MATLAB R2020a+), attempts to use `exportgraphics`. Otherwise, uses `print -noui`. Default: `false`.

Example:
```matlab
% Beautify and export to PDF
figure;
plot(1:10, (1:10).^2);
title('Square Values');

export_options.enabled = true;
export_options.filename = 'squares_plot';
export_options.format = 'pdf';
export_options.resolution = 300;

beautify_figure('export_settings', export_options);
% This will create 'squares_plot.pdf'
```

### Basic Statistical Overlay

This feature allows for the display of basic statistical information (like mean, standard deviation, N, etc.) for a chosen plot directly on the figure. Settings are managed via the `stats_overlay` `struct`.

Key `stats_overlay` parameters:
*   `enabled` (boolean): Set to `true` to enable the statistical overlay. Default: `false`.
*   `statistics` (cell array of strings): Specifies which statistics to display. Options: `'mean'`, `'std'`, `'min'`, `'max'`, `'N'`, `'median'`, `'sum'`. Default: `{'mean', 'std'}`.
*   `position` (string): Position of the stats text box on the axes (e.g., `'northeast_inset'`, `'southwest_inset'`). Default: `'northeast_inset'`.
*   `precision` (integer): Number of decimal places for the displayed statistical values. Default: `2`.
*   `target_plot_handle_tag` (string): The `Tag` property of a specific plot object (e.g., a line or scatter plot) from which to calculate statistics. If empty, the function attempts to use the first valid plot object found in the axes. Default: `''`.
*   `font_scale_factor` (numeric): Multiplier for the font size, relative to the axes labels' font size. Default: `0.9`.
*   `text_color` (color spec): Color of the statistics text. If empty (`[]`), inherits from `params.text_color`.
*   `font_name` (string): Font name for the statistics text. If empty (`[]`), inherits from `params.font_name`.
*   `background_color` (color spec or string): Background of the stats text box. Can be a color spec, `'figure'`, or empty.
*   `edge_color` (color spec or string): Edge color of the stats text box. Can be a color spec, `'axes'`, or empty.

Example:
```matlab
figure; 
plot(1:20, randn(1,20) + 10, 'Tag', 'TemperatureData', 'LineWidth', 1.5);
title('Experimental Data');

stats_opts.enabled = true;
stats_opts.statistics = {'mean', 'std', 'N', 'max'};
stats_opts.target_plot_handle_tag = 'TemperatureData';
stats_opts.position = 'southeast_inset';
stats_opts.background_color = [0.95 0.95 0.85]; % Light yellow background
stats_opts.edge_color = [0.5 0.5 0.5];      % Gray border

beautify_figure('stats_overlay', stats_opts);
% Expected: A text box in the bottom-right of the plot showing stats for the 'TemperatureData' line.
```

## Dependencies

*   MATLAB (R2019b or newer recommended for full feature compatibility, especially interactive legends).

## Testing

This repository includes a comprehensive test suite to ensure the functionality and stability of `beautify_figure.m`. The tests are located in the root directory.

### Visual Regression Tests (`test_beautify_figure.m`)

This is a script-based test suite that generates a series of "before" and "after" `.png` images for various features and use cases. It allows for easy visual inspection of the script's output.

**To run:**
```matlab
% This will create a 'test_outputs' directory with the image files.
test_beautify_figure;
```

### Automated Unit Tests (`BeautifyFigureTest.m`)

This is a class-based test suite using the MATLAB Unit Testing Framework. It provides automated, programmatic checks for the script's logic, parameter handling, and error conditions, without requiring manual visual inspection.

**To run:**
```matlab
% This will run all tests in the file and display a summary in the command window.
runtests('BeautifyFigureTest.m');
```

## Development

### Coding Standards

This project follows strict coding standards to ensure maintainability and consistency. If you wish to contribute, please adhere to the following rules:
*   **Naming Convention:** All variable and function names must use `snake_case`.
*   **Loop Variables:** Avoid using `i` as a loop variable; use `k`, `idx`, or more descriptive names.
*   **Line Length:** Keep lines of code under 100 characters.
*   **File Structure:** The main functionality is contained within `beautify_figure.m`. Helper functions should be nested within this main file.

For more details, see the `AGENTS.md` file.

### Continuous Integration

We use GitHub Actions to automatically run our test suite on every push and pull request. The workflow is defined in `.github/workflows/matlab-tests.yml` and includes:
*   Automated unit tests using the MATLAB Unit Testing Framework.
*   Visual regression tests to verify aesthetic changes.

## License

This project is licensed under the MIT License. See the `LICENSE.md` file for details.

# MATLAB Figure Beautifier (`beautify_figure.m`)

A MATLAB function to systematically enhance the aesthetics of figures for presentations and publications.

## Purpose

The `beautify_figure.m` script provides a comprehensive set of tools to improve the visual appeal of MATLAB figures. It allows for customization of fonts, colors, line styles, markers, grid, legend, titles, and much more. It can handle figures with multiple subplots, tiled layouts, and tabs, applying consistent styling throughout.

## Basic Usage

To apply default beautification settings to the current figure:

```matlab
% Generate a sample plot
figure;
plot(rand(10,3));
title('My Sample Plot');

% Beautify it!
beautify_figure();
```

To apply custom settings:

```matlab
my_params.theme = 'dark';
my_params.font_name = 'Helvetica';
my_params.plot_line_width = 2;
beautify_figure(my_params);
```

To apply to specific axes:

```matlab
h_axes1 = subplot(1,2,1); plot(rand(5)); title('First Plot');
h_axes2 = subplot(1,2,2); scatter(rand(10,1), rand(10,1)); title('Second Plot');
beautify_figure([h_axes1, h_axes2]); % Apply default to specific axes
```

## Using the Beautify Figure App (GUI)

For users who prefer a graphical interface, this project also includes `BeautifyFigureApp.mlapp`. This app provides an interactive way to apply many of the beautification settings available in the `beautify_figure.m` script.

**To launch the app:**
1.  Open `BeautifyFigureApp.mlapp` in the MATLAB editor.
2.  Click the "Run" button in the editor's toolbar.
Alternatively, if the project is packaged as a MATLAB App (`.mlappinstall` file), you can install it via the MATLAB Apps tab and then run it from the Apps toolbar.

The app allows you to:
*   Load and apply settings to the currently active figure.
*   Adjust parameters through various UI controls (dropdowns, checkboxes, spinners).
*   Import and export parameter presets as `.mat` files.
*   Access a built-in help dialog for app usage.

While the app covers many common parameters, the full range of options and fine-grained control (especially for complex parameters like custom color palettes as matrices or detailed marker style cycling) is available through the `beautify_figure.m` script directly.
Note: Advanced features like Panel Labeling and Stats Overlay are configurable via the `beautify_figure.m` script, but GUI controls in the `BeautifyFigureApp.mlapp` are planned for a future update.

## Parameters

The `beautify_figure.m` script offers a wide range of customizable parameters. These are passed as fields in a structure. For a detailed list of all parameters and their default values, please refer to the extensive help text within the `beautify_figure.m` script itself (e.g., by typing `help beautify_figure` in MATLAB).

Key parameters include:
*   `style_preset`: String, e.g., 'default', 'publication', 'presentation_dark', 'presentation_light', 'minimalist'. Applies a predefined set of styles.
*   `theme`: 'light' (default), 'dark'. Sets a base theme for colors. (Can be part of a preset).
*   `font_name`: Font family (e.g., 'Arial', 'Helvetica'). (Can be part of a preset).
*   `base_font_size`: Base font size for scaling elements.
*   `plot_line_width`: Base line width for plotted data.
*   `color_palette`: Predefined palettes ('default_matlab', 'lines', 'parula', 'viridis', 'turbo', 'cividis', 'cbrewer_qual_Set1', etc.) or custom RGB matrix.
*   `view_preset_3d`: ('none') Applies predefined 3D views (e.g., 'iso', 'top').
*   `export_settings`: Structure for controlling automatic figure export (see details below).
*   `panel_labeling`: Structure for automated panel labeling (see details below).
*   `stats_overlay`: Structure for basic statistical overlay (see details below).

## Features

*   Customizable themes (light/dark).
*   Configurable style presets (e.g., 'publication', 'presentation_dark', 'minimalist') for quick common setups.
*   Font and text property adjustments (size, weight, color, font family).
*   Control over line styles, markers, and color palettes.
*   Automatic scaling of elements based on subplot density.
*   Support for tiled layouts and figure tabs.
*   Interactive legends (clickable items to toggle plot visibility, R2019b+).
*   Axes styling (box, grid, tick direction, layer).
*   Optional automatic export of figures to various formats (PNG, PDF, EPS, etc.).
*   Automated Panel Labeling: Automatically add panel labels like 'A', 'B', 'C' or 'a)', 'b)' to subplots/tiles.
*   Basic Statistical Overlay: Display basic statistics (mean, std, min, max, N, etc.) for plotted data directly on the figure.


## Examples

The basic usage examples above demonstrate how to apply default settings, custom parameters, or target specific axes. Below are more detailed examples of the preset and export functionalities.

## Detailed Features

### Style Presets

The `style_preset` parameter allows you to quickly apply a predefined collection of settings tailored for common use cases. User-defined parameters will always override any values set by a preset.

Available presets:
*   **`'default'`**: The standard beautification settings.
*   **`'publication'`**: Optimized for academic publications. Typically uses standard fonts (e.g., Arial or Times), appropriate font sizes, thinner lines for potentially dense plots, black and white color scheme for axes/text, and a clear color palette for plots. Grid is often major lines only.
*   **`'presentation_dark'`**: Designed for presentations using a dark background. Employs larger fonts, thicker lines, and a color palette that is clear on dark backgrounds (e.g., 'viridis').
*   **`'presentation_light'`**: Suited for presentations on light backgrounds. Uses larger fonts, clear lines, and bright, distinct color palettes.
*   **`'minimalist'`**: A clean, uncluttered look with minimal gridlines, often using only left and bottom axes, and a grayscale or simple color scheme.

Example:
```matlab
% Apply the 'publication' preset
beautify_figure('style_preset', 'publication');

% Use 'presentation_dark' but customize the font
my_settings.style_preset = 'presentation_dark';
my_settings.font_name = 'Helvetica';
beautify_figure(my_settings);
```

### Automatic Figure Export

The `export_settings` parameter (a structure) allows for direct export of the beautified figure.

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

export_options.export_settings.enabled = true;
export_options.export_settings.filename = 'squares_plot';
export_options.export_settings.format = 'pdf';
export_options.export_settings.resolution = 300; % Good for vector PDF too
beautify_figure(export_options); 
% This will create 'squares_plot.pdf'
```

### Automated Panel Labeling

This feature helps in automatically adding panel labels (e.g., 'A', 'B', 'a)', 'I') to subplots or tiles within a figure, which is useful for referencing specific panels in publications or reports. The settings are controlled via the `panel_labeling` structure.

Key `panel_labeling` parameters:
*   `enabled` (boolean): Set to `true` to enable panel labeling. Default: `false`.
*   `style` (string): Defines the labeling style. Options include: `'A'` (A, B, C...), `'a'` (a, b, c...), `'a)'` (a), b), c)...), `'I'` (I, II, III...), `'i'` (i, ii, iii...), `'1'` (1, 2, 3...). Default: `'A'`.
*   `position` (string): Specifies where the label is placed on the axes. Common options: `'northwest_inset'`, `'northeast_inset'`, `'southwest_inset'`, `'southeast_inset'`. Default: `'northwest_inset'`.
*   `font_scale_factor` (numeric): Multiplier for the font size, relative to the axes title's font size. Default: `1.0`.
*   `font_weight` (string): Font weight for the panel labels, e.g., `'bold'`, `'normal'`. Default: `'bold'`.
*   `x_offset` (numeric): Normalized horizontal offset from the edge defined by `position`. Default: `0.02`.
*   `y_offset` (numeric): Normalized vertical offset from the edge defined by `position`. Default: `0.02`.
*   `text_color` (color spec): Color of the panel label text. If empty (`[]`), it inherits from the global `params.text_color`.
*   `font_name` (string): Font name for the panel labels. If empty (`[]`), it inherits from the global `params.font_name`.

Example:
```matlab
% For a figure with subplots
figure; subplot(1,2,1); plot(rand(5)); subplot(1,2,2); plot(rand(5));
my_settings.panel_labeling.enabled = true;
my_settings.panel_labeling.style = 'a)';
my_settings.panel_labeling.position = 'northeast_inset'; % Custom position
beautify_figure(my_settings);
% Expected: labels 'a)' and 'b)' in the top-right corner of each subplot.
```

### Basic Statistical Overlay

This feature allows for the display of basic statistical information (like mean, standard deviation, N, etc.) for a chosen plot directly on the figure. This is useful for quickly conveying key data characteristics. Settings are managed via the `stats_overlay` structure.

Key `stats_overlay` parameters:
*   `enabled` (boolean): Set to `true` to enable the statistical overlay. Default: `false`.
*   `statistics` (cell array of strings): Specifies which statistics to display. Options: `'mean'`, `'std'`, `'min'`, `'max'`, `'N'`, `'median'`, `'sum'`. Default: `{'mean', 'std'}`.
*   `position` (string): Position of the stats text box on the axes (e.g., `'northeast_inset'`, `'southwest_inset'`). Default: `'northeast_inset'`.
*   `precision` (integer): Number of decimal places for the displayed statistical values. Default: `2`.
*   `target_plot_handle_tag` (string): The `Tag` property of a specific plot object (e.g., a line or scatter plot) from which to calculate statistics. If empty, the function attempts to use the first valid plot object found in the axes. Default: `''`.
*   `font_scale_factor` (numeric): Multiplier for the font size, relative to the axes labels' font size. Default: `0.9`.
*   `text_color` (color spec): Color of the statistics text. If empty (`[]`), inherits from `params.text_color`.
*   `font_name` (string): Font name for the statistics text. If empty (`[]`), inherits from `params.font_name`.
*   `background_color` (color spec or string): Background color of the stats text box. Can be an RGB triplet, a standard MATLAB color string (e.g., `'yellow'`), or `'figure'` to match the figure background. If empty (`[]`), no background is drawn.
*   `edge_color` (color spec or string): Edge color of the stats text box. Can be an RGB triplet, a color string, or `'axes'` to match the axes color. If empty (`[]`), no edge is drawn.

Example:
```matlab
figure; 
plot(1:20, randn(1,20) + 10, 'Tag', 'TemperatureData', 'LineWidth', 1.5);
title('Experimental Data');

my_settings.stats_overlay.enabled = true;
my_settings.stats_overlay.statistics = {'mean', 'std', 'N', 'max'};
my_settings.stats_overlay.target_plot_handle_tag = 'TemperatureData'; % Target this specific plot
my_settings.stats_overlay.position = 'southeast_inset';
my_settings.stats_overlay.background_color = [0.95 0.95 0.85]; % Light yellow background
my_settings.stats_overlay.edge_color = [0.5 0.5 0.5];      % Gray border
beautify_figure(my_settings);
% Expected: A text box in the bottom-right of the plot showing mean, std, N, and max
% for the 'TemperatureData' line, with a light yellow background and gray border.
```

### 3D View Presets

The `view_preset_3d` parameter allows for quick application of common camera views to 3D plots. This is particularly useful for standardizing views across multiple figures.

*   `view_preset_3d` (string):
    *   `'none'` (default): No change to the current view.
    *   `'iso'`: Standard MATLAB isometric view (`view(3)`).
    *   `'top'`: Top-down view (`view(0,90)`).
    *   `'front'`: Front view (`view(0,0)`).
    *   `'side_left'`: View from the left (`view(-90,0)`).
    *   `'side_right'`: View from the right (`view(90,0)`).

Example:
```matlab
figure;
surf(peaks(25));
title('Peak Surface');
my_settings.view_preset_3d = 'iso';
beautify_figure(my_settings);
% The figure will now show an isometric view of the peaks surface.
```

## Recent Enhancements and Current Status

### `BeautifyFigureApp.mlapp` Improvements
The accompanying GUI, `BeautifyFigureApp.mlapp`, has received several updates to enhance its robustness and user experience:
*   **Preset Loading:** Loading presets from `.mat` files is now more resilient. If a preset file is missing some parameters, the App will apply the settings that are present and issue a warning to the user detailing which settings were skipped or defaulted.
*   **Input Validation:** Validation has been added for the "Custom Color Palette" and "Statistics" text input fields. The App now provides `uialert` warnings if the input in these fields is malformed (e.g., an invalid matrix string for the color palette, or an unparseable cell array string for statistics).
*   **Font Selection:** The font name dropdown list population is more robust and includes better fallbacks if system fonts cannot be fully enumerated, ensuring the App remains functional.

### Test Script (`test_beautify_figure.m`) Enhancements
The `test_beautify_figure.m` script has been significantly expanded to improve test coverage and verify the stability of `beautify_figure.m` under various conditions. New test cases include:
*   Applying beautification to an **empty figure** (a figure with no axes or plotted data) to ensure no errors occur.
*   Processing figures that contain **UI tabs** (`uitabgroup`), verifying that axes within each tab are correctly identified and beautified.
*   Handling of **invalid parameters** passed to `beautify_figure.m`, ensuring that the function logs appropriate warnings/errors and does not crash, instead applying default or valid portions of parameters where possible.

### Status of `beautify_figure.m` Refactoring
The `beautify_figure.m` script is continuously maintained, with ongoing efforts to improve its functionality and robustness. Future updates may include further refactoring and feature enhancements.

## Dependencies

*   MATLAB (R2019b or newer recommended for full feature compatibility, especially interactive legends).
*   The `cbrewer` function is optionally used for some color palettes. If not present, the script will fall back to default palettes. (Available from MATLAB File Exchange).

## License

This project is licensed under the MIT License. See the `LICENSE.md` file for details.

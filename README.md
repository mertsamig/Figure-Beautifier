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

## Parameters

This function offers a wide range of customizable parameters. These are passed as fields in a structure. For a detailed list of all parameters and their default values, please refer to the extensive help text within the `beautify_figure.m` script itself (e.g., by typing `help beautify_figure` in MATLAB).

Key parameters include:
*   `style_preset`: String, e.g., 'default', 'publication', 'presentation_dark', 'presentation_light', 'minimalist'. Applies a predefined set of styles.
*   `theme`: 'light' (default), 'dark'. Sets a base theme for colors. (Can be part of a preset).
*   `font_name`: Font family (e.g., 'Arial', 'Helvetica'). (Can be part of a preset).
*   `base_font_size`: Base font size for scaling elements.
*   `plot_line_width`: Base line width for plotted data.
*   `color_palette`: Predefined palettes or custom RGB matrix.
*   `export_settings`: Structure for controlling automatic figure export. Key sub-fields:
    *   `enabled`: (boolean) `true` to enable export.
    *   `filename`: (string) Name of the output file (without extension).
    *   `format`: (string) e.g., 'png', 'pdf', 'eps', 'svg', 'jpeg', 'tiff'.
    *   `resolution`: (numeric) DPI for raster formats, e.g., 300.
    *   `open_exported_file`: (boolean) `true` to attempt opening the file after export.
    *   (Other fields like `renderer` and `ui` exist, see script help text for full details).

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

## Dependencies

*   MATLAB (R2019b or newer recommended for full feature compatibility, especially interactive legends).
*   The `cbrewer` function is optionally used for some color palettes. If not present, the script will fall back to default palettes. (Available from MATLAB File Exchange).

## License

This project is licensed under the MIT License. See the `LICENSE.md` file for details.

---
Copyright (c) 2024 MATLAB Figure Beautifier Contributors

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

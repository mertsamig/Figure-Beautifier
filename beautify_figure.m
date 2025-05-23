function beautify_figure(user_params_or_axes_handle, user_params_for_specific_axes)
% BEAUTIFY_FIGURE Enhances the aesthetics of the current MATLAB figure or specified axes.
%
% SYNTAX:
%   beautify_figure()
%       Applies default beautification settings to the current figure (gcf).
%
%   beautify_figure(params_struct)
%       Applies beautification with custom settings defined in params_struct to gcf.
%
%   beautify_figure(axes_handle_array)
%       Applies default beautification settings to the specified axes handle(s).
%
%   beautify_figure(axes_handle_array, params_struct)
%       Applies custom settings to the specified axes handle(s).
%
% DESCRIPTION:
%   This function systematically modifies various properties of a MATLAB figure
%   and its children (axes, plots, legends, text, etc.) to improve its visual
%   appeal and readability, making it suitable for presentations or publications.
%   It supports adaptive scaling based on the number of subplots in a tiled
%   layout, handles figures with multiple tabs, and offers a wide range of
%   customizable parameters.
%
% PARAMETERS (params_struct fields - see default_params inside for all options):
%   - style_preset: ('default') Predefined style set. Options:
%     - 'default': Standard beautify_figure settings.
%     - 'publication': Optimized for print publications (e.g., Arial font, black/white/gray, smaller markers).
%     - 'presentation_dark': For dark background presentations (e.g., Calibri, larger fonts, vivid colors).
%     - 'presentation_light': For light background presentations (e.g., Calibri, larger fonts, bright colors).
%     - 'minimalist': Clean, minimal style with few distractions.
%   - theme: 'light' (default), 'dark'. Sets a base theme for colors. Overridden by preset if preset defines it.
%   - font_name: Font family (e.g., 'Arial', 'Helvetica'). Overridden by preset if preset defines it.
%   - base_font_size: Base font size for scaling.
%   - global_font_scale_factor: Multiplier for all font sizes.
%   - plot_line_width: Base line width for plotted data.
%   - axis_to_plot_linewidth_ratio: Ratio of axis line width to plot line width.
%   - marker_size: Base marker size.
%   - color_palette: Name of a color palette ('default_matlab', 'lines', 'parula',
%                    'viridis', 'turbo', 'cividis', 'cbrewer_qual_Set1', etc.) or an Nx3 RGB matrix.
%   - view_preset_3d: ('none') Applies predefined 3D views. Options:
%     'none' (no change), 'iso' (isometric), 'top' (top-down, view(0,90)),
%     'front' (view(0,0)), 'side_left' (view(-90,0)), 'side_right' (view(90,0)).
%   - cycle_marker_styles: 'auto' (default), true, false. Controls marker cycling.
%   - cycle_line_styles: 'auto' (default), true, false. Controls line style cycling.
%   - grid_density: 'normal' (default), 'major_only', 'none'.
%   - axis_box_style: 'on' (default), 'off', 'left-bottom'.
%   - axes_layer: 'top' (default), 'bottom'. Sets axes Layer property.
%   - legend_location: 'best' (default), 'northeastoutside', 'none', etc.
%   - smart_legend_display: true (default). Avoids unnecessary legends.
%   - interactive_legend: true (default). Enables clickable legend items.
%   - log_level: 0 (silent), 1 (normal), 2 (detailed - default).
%   - export_settings: Structure for controlling figure export:
%     - enabled: (false) Set to true to export the figure.
%     - filename: ('beautified_figure') Base name for the exported file.
%     - format: ('png') Export format (e.g., 'png', 'jpeg', 'pdf', 'eps', 'svg', 'tiff').
%     - resolution: (300) Resolution in DPI for raster formats, also influences vector quality.
%     - open_exported_file: (false) If true, attempts to open the file after export.
%     - renderer: ('painters') Renderer to use. For `print`: 'painters', 'opengl', 'vector'. `exportgraphics` usually manages this automatically or via content type.
%     - ui: (false) If true and `exportgraphics` is available (R2020a+), it's preferred. Otherwise, `print` is used. Set to false to force `print -noui`.
%   - panel_labeling: (struct) Settings for automated panel labeling.
%     - enabled: (false) Set to true to enable panel labels.
%     - style: ('A') Label style: 'A','a','a)','I','i','1'.
%     - position: ('northwest_inset') e.g., 'northwest_inset', 'northeast_inset', 'southwest_inset', 'southeast_inset'.
%     - font_scale_factor: (1.0) Font size scale factor relative to title font size.
%     - font_weight: ('bold') Font weight for panel labels.
%     - x_offset: (0.02) Normalized X offset for label position.
%     - y_offset: (0.02) Normalized Y offset for label position.
%     - text_color: ([]) Label text color (inherits from global text_color if empty).
%     - font_name: ([]) Label font name (inherits from global font_name if empty).
%   - stats_overlay: (struct) Settings for statistical data overlay.
%     - enabled: (false) Set to true to enable statistical overlay.
%     - statistics: ({'mean', 'std'}) Cell array of stats to display, e.g., 'min', 'max', 'N', 'median', 'sum'.
%     - position: ('northeast_inset') Position of the stats text box, e.g., 'northeast_inset', 'southwest_inset'.
%     - precision: (2) Number of decimal places for displayed statistics.
%     - target_plot_handle_tag: ('') Tag of a specific plot object to analyze. If empty, uses the first valid plot in the axes.
%     - font_scale_factor: (0.9) Font size scale factor relative to label font size.
%     - text_color: ([]) Stats text color (inherits from global text_color if empty).
%     - font_name: ([]) Stats font name (inherits from global font_name if empty).
%     - background_color: ([]) Background of the stats text box (e.g., [0.9 0.9 0.9], 'yellow', or 'figure'). Default is none.
%     - edge_color: ([]) Edge color of the stats text box (e.g., [0.5 0.5 0.5], 'black', or 'axes'). Default is none.
%   ... and many more. Explore the default_params structure within the code.
%
% EXAMPLE:
%   figure;
%   subplot(1,2,1); plot(rand(10,3)); title('Plot 1');
%   subplot(1,2,2); scatter(rand(20,1), rand(20,1)); title('Plot 2');
%   beautify_figure(); % Apply default beautification
%
%   custom_settings.theme = 'dark';
%   custom_settings.font_name = 'Helvetica';
%   custom_settings.plot_line_width = 2;
%   custom_settings.cycle_line_styles = true;
%   beautify_figure(custom_settings); % Apply custom settings
%
% See also: gcf, legend, tiledlayout, axes, plot, set, get


% --- Default Beautification Parameters ---
% These are the master defaults. They can be overridden by user_params.
default_params.theme = 'light';
default_params.font_name = 'Swiss 721 BT'; % A common sans-serif, often needs to be installed or substituted
default_params.base_font_size = 10;
default_params.global_font_scale_factor = 1.0;
default_params.title_scale = 1.2;
default_params.label_scale = 1.0;

default_params.plot_line_width = 1.5;
default_params.axis_to_plot_linewidth_ratio = 0.5;
default_params.marker_size = 6; % In points
default_params.errorbar_cap_size_scale = 0.5;

% Theme-dependent defaults (will be adjusted if 'dark' theme is chosen)
default_params.axis_color = [0.15 0.15 0.15];
default_params.figure_background_color = get(0, 'DefaultFigureColor'); % Use MATLAB's default
default_params.text_color = [0.15 0.15 0.15];
default_params.grid_color = [0.15 0.15 0.15];

default_params.grid_density = 'normal';
default_params.grid_alpha = 0.15;
default_params.grid_line_style = '-';
default_params.minor_grid_alpha = 0.07;
default_params.minor_grid_line_style = ':';
default_params.axis_box_style = 'on';
default_params.axes_layer = 'top'; % NEW: 'top' or 'bottom'

default_params.color_palette = 'default_matlab';
default_params.custom_color_palette = [];
default_params.cycle_marker_styles = 'auto';
default_params.marker_cycle_threshold = 3; % Cycle if num candidates > this value
default_params.marker_styles = {'o', 's', 'd', '^', 'v', '>', '<', 'p', 'h', '.', 'x', '+', '*'};
default_params.line_style_order = {'-', '--', ':', '-.'}; % NEW
default_params.cycle_line_styles = 'auto'; % NEW: true, false, 'auto'
default_params.line_style_cycle_threshold = 2; % NEW: cycle if num candidates > this value when 'auto'

default_params.axis_limit_mode = 'padded';
default_params.expand_axis_limits_factor = 0.03;

default_params.legend_location = 'best';
default_params.smart_legend_display = true;
default_params.legend_force_single_entry = false;
default_params.legend_title_string = '';
default_params.interactive_legend = true; % Requires R2019b+ for ItemHitFcn
default_params.legend_num_columns = 0;
default_params.legend_reverse_order = false;

default_params.apply_to_colorbars = true;
default_params.apply_to_polaraxes = true;
default_params.apply_to_general_text = true;
default_params.beautify_sgtitle = true;

default_params.auto_latex_interpreter_for_labels = true;
default_params.force_latex_if_dollar_present = true;

default_params.exclude_object_tags = {};
default_params.exclude_object_types = {'matlab.graphics.primitive.Light'}; % Lights are often problematic

default_params.scaling_map = containers.Map(...
{1,  2,  3,  4,  6,  8,  9,  12, 16, 20, 25}, ...
{1.6,1.5,1.4,1.3,1.15,1.05,1.0,0.9,0.8,0.75,0.7} ...
);
default_params.min_scale_factor = 0.65;
default_params.max_scale_factor = 1.7;
default_params.log_level = 2; % 0:silent, 1:normal (warnings, info), 2:detailed (verbose)

% Export settings
default_params.export_settings.enabled = false;
default_params.export_settings.filename = 'beautified_figure';
default_params.export_settings.format = 'png'; % Suggested: 'png', 'jpeg', 'pdf', 'eps', 'tiff', 'svg'
default_params.export_settings.resolution = 300; % DPI
default_params.export_settings.open_exported_file = false;
default_params.export_settings.renderer = 'painters'; % Suggested: 'painters', 'opengl', 'vector' (for print), 'auto' for exportgraphics
default_params.export_settings.ui = false; % If true, tries to use exportgraphics, else print -noui

default_params.style_preset = 'default';

% Panel Labeling (as described in help, though not fully implemented in processing loop)
default_params.panel_labeling.enabled = false;
default_params.panel_labeling.style = 'A';
default_params.panel_labeling.position = 'northwest_inset';
default_params.panel_labeling.font_scale_factor = 1.0;
default_params.panel_labeling.font_weight = 'bold';
default_params.panel_labeling.x_offset = 0.02;
default_params.panel_labeling.y_offset = 0.02;
default_params.panel_labeling.text_color = [];
default_params.panel_labeling.font_name = [];

% Basic Statistical Overlay
default_params.stats_overlay.enabled = false;
default_params.stats_overlay.statistics = {'mean', 'std'}; % Cell array: 'mean', 'std', 'min', 'max', 'N', 'median', 'sum'
default_params.stats_overlay.position = 'northeast_inset'; % Options like panel_labeling, or 'best_text', 'manual_normalized_coords'
default_params.stats_overlay.precision = 2; % Decimal places
default_params.stats_overlay.text_color = []; % Inherits
default_params.stats_overlay.font_name = []; % Inherits
default_params.stats_overlay.font_scale_factor = 0.9; % Relative to axes label font size
default_params.stats_overlay.background_color = []; % Default none. Can be 'figure' or a color spec.
default_params.stats_overlay.edge_color = []; % Default none. Can be 'axes' or a color spec.
default_params.stats_overlay.target_plot_handle_tag = ''; % Tag of specific plot to analyze, empty for first valid

default_params.view_preset_3d = 'none'; % Options: 'none', 'iso', 'top', 'front', 'side_left', 'side_right'

% --- Parameter Parsing and Initialization ---
base_defaults = default_params; % Store original defaults
params = base_defaults; % Initialize params
target_axes = [];
user_provided_params_struct = struct();
fig_handle_internal = []; % Internal variable for figure handle

if nargin == 0
    fig_handle_internal = gcf;
elseif nargin == 1
    arg1 = user_params_or_axes_handle;
    if is_valid_axes_handle_array(arg1)
        target_axes = arg1;
        if ~isempty(target_axes) && isvalid(target_axes(1))
            fig_handle_internal = ancestor(target_axes(1), 'figure');
        else
            % Use base_defaults for logging as params might not be fully set or valid yet
            log_message(base_defaults, 'Provided axes handles are invalid or empty.', 0, 'Error'); return;
        end
    elseif isstruct(arg1)
        user_provided_params_struct = arg1;
        fig_handle_internal = gcf;
    elseif isgraphics(arg1, 'figure') % Syntax: beautify_current_figure(fig_handle)
        fig_handle_internal = arg1;
    else
        log_message(base_defaults, 'Invalid first argument. Expected figure handle, axes handle(s), or a parameter struct.', 0, 'Error'); return;
    end
elseif nargin == 2
    arg1 = user_params_or_axes_handle;
    arg2 = user_params_for_specific_axes;
    if is_valid_axes_handle_array(arg1)
        if ~isstruct(arg2)
            log_message(base_defaults, 'Invalid second argument when first is axes. Expected a parameter struct.', 0, 'Error'); return;
        end
        target_axes = arg1;
        user_provided_params_struct = arg2;
        if ~isempty(target_axes) && isvalid(target_axes(1))
            fig_handle_internal = ancestor(target_axes(1), 'figure');
        else
            log_message(base_defaults, 'Provided axes handles are invalid or empty for two-argument syntax.', 0, 'Error'); return;
        end
    elseif isgraphics(arg1, 'figure') % Syntax: beautify_current_figure(fig_handle, params_struct)
        if ~isstruct(arg2)
            log_message(base_defaults, 'Invalid second argument when first is figure. Expected a parameter struct.', 0, 'Error'); return;
        end
        fig_handle_internal = arg1;
        user_provided_params_struct = arg2;
    else
        log_message(base_defaults, 'Invalid first argument for two-argument syntax. Expected figure handle or axes handle(s).', 0, 'Error'); return;
    end
else % nargin > 2
    log_message(base_defaults, 'Too many input arguments.', 0, 'Error'); return;
end

% Validate fig_handle_internal and assign to 'fig'
if isempty(fig_handle_internal) || ~isvalid(fig_handle_internal)
    log_message(base_defaults, 'No valid figure found or specified to beautify.', 0, 'Error'); return;
end
fig = fig_handle_internal; % Use 'fig' consistently hereafter

% Determine active style preset
active_preset_name = base_defaults.style_preset; % Default
if isfield(user_provided_params_struct, 'style_preset') && ~isempty(user_provided_params_struct.style_preset)
    if ischar(user_provided_params_struct.style_preset) || isstring(user_provided_params_struct.style_preset)
        active_preset_name = lower(char(user_provided_params_struct.style_preset));
    else
        log_message(base_defaults, 'Invalid data type for style_preset. Using default preset.', 1, 'Warning');
    end
end

% Apply style preset (modifies 'params' struct, which was initialized from base_defaults)
known_presets = {'default', 'publication', 'presentation_dark', 'presentation_light', 'minimalist'};
if ~any(strcmp(active_preset_name, known_presets))
    log_message(base_defaults, sprintf('Unknown style preset: "%s". Applying default style parameters before user overrides.', active_preset_name), 1, 'Warning');
    active_preset_name = 'default'; % Fallback to default if unknown
end

log_message(params, sprintf('Applying style preset: "%s".', active_preset_name), 2, 'Info'); % Use params for log_level
switch active_preset_name
    case 'publication'
        params.font_name = 'Arial';
        params.base_font_size = 10;
        params.global_font_scale_factor = 1.0;
        params.plot_line_width = 1.0;
        params.axis_to_plot_linewidth_ratio = 0.75;
        params.marker_size = 5;
        params.color_palette = 'lines'; % Often good for B&W, consider 'gray' or custom grayscale too
        params.grid_density = 'major_only';
        params.theme = 'light';
        params.axis_color = [0 0 0]; % Black
        params.figure_background_color = [1 1 1]; % White
        params.text_color = [0 0 0]; % Black
        params.grid_color = [0.5 0.5 0.5]; % Gray
        params.auto_latex_interpreter_for_labels = true;
        params.axes_layer = 'bottom';
        params.legend_location = 'best';

    case 'presentation_dark'
        params.theme = 'dark';
        params.font_name = 'Calibri';
        params.base_font_size = 12;
        params.global_font_scale_factor = 1.1;
        params.plot_line_width = 2.0;
        params.marker_size = 7;
        params.color_palette = 'viridis';
        params.grid_density = 'normal';
        params.figure_background_color = [0.10 0.10 0.12];
        params.axis_color = [0.9 0.9 0.9];
        params.text_color = [0.95 0.95 0.95];
        params.grid_color = [0.6 0.6 0.6];
        params.grid_alpha = 0.25;
        params.minor_grid_alpha = 0.15;

    case 'presentation_light'
        params.theme = 'light';
        params.font_name = 'Calibri';
        params.base_font_size = 12;
        params.global_font_scale_factor = 1.1;
        params.plot_line_width = 1.8;
        params.marker_size = 6;
        params.color_palette = 'cbrewer_qual_Set1';
        params.grid_density = 'normal';
        params.figure_background_color = [0.96 0.96 0.98];
        params.axis_color = [0.15 0.15 0.15];
        params.text_color = [0.1 0.1 0.1];
        params.grid_color = [0.25 0.25 0.25];
        params.grid_alpha = 0.15;
        params.minor_grid_alpha = 0.07;

    case 'minimalist'
        params.theme = 'light';
        try % Helvetica Neue might not be available
            params.font_name = 'Helvetica Neue';
            listfonts; % check if it exists, dummy call
        catch
            params.font_name = 'Helvetica'; % Fallback
        end
        params.base_font_size = 10;
        params.plot_line_width = 1.2;
        params.marker_size = 5;
        params.color_palette = [[0.2 0.2 0.2]; [0.5 0.5 0.5]; [0.7 0.7 0.7]]; % Grayscale
        params.grid_density = 'none';
        params.axis_box_style = 'left-bottom';
        params.smart_legend_display = true;
        params.legend_location = 'northeastoutside';
        params.figure_background_color = [1 1 1];
        params.axis_color = [0.1 0.1 0.1];
        params.text_color = [0.1 0.1 0.1];
        params.title_scale = 1.0;
        params.label_scale = 1.0;

    case 'default'
        % No changes needed, params is already from base_defaults.
end

% Merge user parameters with defaults (now 'params' includes preset values)
% This handles top-level fields. Sub-structs are handled more carefully later if needed.
param_names = fieldnames(user_provided_params_struct);
for i = 1:length(param_names)
    field_name = param_names{i};
    if isfield(params, field_name)
        params.(field_name) = user_provided_params_struct.(field_name);
    else
        log_message(params, sprintf('Unknown parameter: "%s". This parameter will be ignored.', field_name), 1, 'Warning');
    end
end

% --- START Critical Parameter Validation (Top-level) ---
log_message(params, 'Performing critical parameter validation...', 2, 'Info');

% Helper function to format value for logging
function val_str = format_param_value_for_log(val)
    if isnumeric(val)
        if isscalar(val)
            val_str = num2str(val);
        else
            val_str = mat2str(val); % For arrays
        end
    elseif ischar(val)
        val_str = ['''' val ''''];
    elseif isstring(val) && isscalar(val)
        val_str = ['"' char(val) '"'];
    elseif isstring(val) % array of strings
        val_str = '[';
        for k_str = 1:numel(val)
            val_str = [val_str '"' char(val(k_str)) '"'];
            if k_str < numel(val); val_str = [val_str ', ']; end
        end
        val_str = [val_str ']'];
    elseif islogical(val)
        if val; val_str = 'true'; else; val_str = 'false'; end
    elseif iscell(val)
        val_str = '{';
        for k_cell = 1:min(5,numel(val)) % Show first few elements
            val_str = [val_str format_param_value_for_log(val{k_cell})];
            if k_cell < min(5,numel(val)); val_str = [val_str ', ']; end
        end
        if numel(val) > 5; val_str = [val_str, '...']; end
        val_str = [val_str '} (' num2str(numel(val)) ' elements)'];
    elseif isstruct(val)
        val_str = ['[struct with fields: ' strjoin(fieldnames(val),', ') ']'];
    else
        try
            val_str = ['[' class(val) ']'];
        catch
            val_str = '[unknown type]';
        end
    end
end


% Numeric scalar parameters to validate
numeric_scalar_params_to_validate = {
    'base_font_size', 'global_font_scale_factor', 'plot_line_width', ...
    'marker_size', 'log_level'
};
for k_nsp = 1:length(numeric_scalar_params_to_validate)
    param_name = numeric_scalar_params_to_validate{k_nsp};
    current_val = params.(param_name);
    if ~isnumeric(current_val) || ~isscalar(current_val) || ~isreal(current_val) || isnan(current_val)
        val_str = format_param_value_for_log(current_val);
        log_message(params, sprintf('Invalid value for %s: %s. Must be a real numeric scalar. Resetting to default (%s).', ...
            param_name, val_str, format_param_value_for_log(base_defaults.(param_name))), 1, 'Warning');
        params.(param_name) = base_defaults.(param_name);
    end
end

% String enumerated parameters to validate
% theme
current_theme_val = params.theme;
valid_themes = {'light', 'dark'};
if ~ischar(current_theme_val) || ~isvector(current_theme_val) || isempty(current_theme_val)
    val_str = format_param_value_for_log(current_theme_val);
    log_message(params, sprintf('Invalid type for theme: %s. Must be a character string. Resetting to default (%s).', ...
        val_str, format_param_value_for_log(base_defaults.theme)), 1, 'Warning');
    params.theme = base_defaults.theme;
else
    match_idx_theme = find(strcmpi(current_theme_val, valid_themes), 1);
    if isempty(match_idx_theme)
        val_str = format_param_value_for_log(current_theme_val);
        log_message(params, sprintf('Invalid value for theme: %s. Allowed: %s. Resetting to default (%s).', ...
            val_str, strjoin(valid_themes, ', '), format_param_value_for_log(base_defaults.theme)), 1, 'Warning');
        params.theme = base_defaults.theme;
    else
        params.theme = valid_themes{match_idx_theme}; % Ensure canonical (lowercase) form
    end
end

% grid_density
current_grid_density_val = params.grid_density;
valid_grid_densities = {'normal', 'major_only', 'none'};
if ~ischar(current_grid_density_val) || ~isvector(current_grid_density_val) || isempty(current_grid_density_val)
    val_str = format_param_value_for_log(current_grid_density_val);
    log_message(params, sprintf('Invalid type for grid_density: %s. Must be a character string. Resetting to default (%s).', ...
        val_str, format_param_value_for_log(base_defaults.grid_density)), 1, 'Warning');
    params.grid_density = base_defaults.grid_density;
else
    match_idx_grid = find(strcmpi(current_grid_density_val, valid_grid_densities), 1);
    if isempty(match_idx_grid)
        val_str = format_param_value_for_log(current_grid_density_val);
        log_message(params, sprintf('Invalid value for grid_density: %s. Allowed: %s. Resetting to default (%s).', ...
            val_str, strjoin(valid_grid_densities, ', '), format_param_value_for_log(base_defaults.grid_density)), 1, 'Warning');
        params.grid_density = base_defaults.grid_density;
    else
        params.grid_density = valid_grid_densities{match_idx_grid}; % Ensure canonical form
    end
end

% axis_box_style
current_axis_box_style_val = params.axis_box_style;
valid_axis_box_styles = {'on', 'off', 'left-bottom'};
if ~ischar(current_axis_box_style_val) || ~isvector(current_axis_box_style_val) || isempty(current_axis_box_style_val)
    val_str = format_param_value_for_log(current_axis_box_style_val);
    log_message(params, sprintf('Invalid type for axis_box_style: %s. Must be a character string. Resetting to default (%s).', ...
        val_str, format_param_value_for_log(base_defaults.axis_box_style)), 1, 'Warning');
    params.axis_box_style = base_defaults.axis_box_style;
else
    match_idx_box = find(strcmpi(current_axis_box_style_val, valid_axis_box_styles), 1);
    if isempty(match_idx_box)
        val_str = format_param_value_for_log(current_axis_box_style_val);
        log_message(params, sprintf('Invalid value for axis_box_style: %s. Allowed: %s. Resetting to default (%s).', ...
            val_str, strjoin(valid_axis_box_styles, ', '), format_param_value_for_log(base_defaults.axis_box_style)), 1, 'Warning');
        params.axis_box_style = base_defaults.axis_box_style;
    else
        params.axis_box_style = valid_axis_box_styles{match_idx_box}; % Ensure canonical form
    end
end
log_message(params, 'Critical parameter validation complete.', 2, 'Info');
% --- END Critical Parameter Validation ---

% --- START Sub-Struct Type and Field Validation ---
log_message(params, 'Performing sub-struct validation (type checks, merging, field checks)...', 2, 'Info');

% Helper function to validate a numeric scalar field within a sub-struct
function params = validate_numeric_scalar_field(params, base_defaults, struct_name, field_name, allow_non_negative, allow_positive, require_integer)
    default_value = base_defaults.(struct_name).(field_name);
    % Check if field exists in current params, if not, it means user struct didn't have it, so use default
    if ~isfield(params.(struct_name), field_name)
        log_message(params, sprintf('Field %s.%s not found in user/preset parameters. Using default value (%s).', ...
            struct_name, field_name, format_param_value_for_log(default_value)), 2, 'Info');
        params.(struct_name).(field_name) = default_value;
        current_value = default_value; % proceed with validation of default
    else
        current_value = params.(struct_name).(field_name);
    end
    
    valid = true;
    if ~isnumeric(current_value) || ~isscalar(current_value) || ~isreal(current_value) || isnan(current_value)
        valid = false;
    elseif allow_non_negative && current_value < 0
        valid = false;
    elseif allow_positive && current_value <= 0
        valid = false;
    elseif require_integer && (floor(current_value) ~= current_value)
        valid = false;
    end

    if ~valid
        val_str = format_param_value_for_log(current_value);
        criteria_str = 'real numeric scalar';
        if require_integer; criteria_str = [criteria_str ', integer']; end
        if allow_non_negative; criteria_str = [criteria_str ', non-negative']; end
        if allow_positive; criteria_str = [criteria_str ', positive']; end
        log_message(params, sprintf('Invalid value for %s.%s: %s. Must be a %s. Resetting to default (%s).', ...
            struct_name, field_name, val_str, criteria_str, format_param_value_for_log(default_value)), 1, 'Warning');
        params.(struct_name).(field_name) = default_value;
    end
end

% Helper function to validate a logical/boolean field within a sub-struct
function params = validate_logical_field(params, base_defaults, struct_name, field_name)
    default_value = base_defaults.(struct_name).(field_name);
    if ~isfield(params.(struct_name), field_name)
        log_message(params, sprintf('Field %s.%s not found in user/preset parameters. Using default value (%s).', ...
            struct_name, field_name, format_param_value_for_log(default_value)), 2, 'Info');
        params.(struct_name).(field_name) = default_value;
        current_value = default_value;
    else
        current_value = params.(struct_name).(field_name);
    end
        
    if islogical(current_value) && isscalar(current_value)
        % Value is already a scalar logical, no change needed.
    elseif isnumeric(current_value) && isscalar(current_value) && (current_value == 0 || current_value == 1)
        params.(struct_name).(field_name) = logical(current_value); % Cast to logical
    else
        val_str = format_param_value_for_log(current_value);
        log_message(params, sprintf('Invalid value for %s.%s: %s. Must be logical (true/false) or numeric (0/1). Resetting to default (%s).', ...
            struct_name, field_name, val_str, format_param_value_for_log(default_value)), 1, 'Warning');
        params.(struct_name).(field_name) = default_value;
    end
end

% Helper function to validate a cell array of char row vectors
function params = validate_cell_array_of_strings_field(params, base_defaults, struct_name, field_name)
    default_value = base_defaults.(struct_name).(field_name);
    if ~isfield(params.(struct_name), field_name)
        log_message(params, sprintf('Field %s.%s not found in user/preset parameters. Using default value (%s).', ...
            struct_name, field_name, format_param_value_for_log(default_value)), 2, 'Info');
        params.(struct_name).(field_name) = default_value;
        current_value = default_value;
    else
         current_value = params.(struct_name).(field_name);
    end
    
    valid = true;
    if ~iscell(current_value)
        valid = false;
    else
        for i = 1:length(current_value)
            if ~ischar(current_value{i}) || (~isvector(current_value{i}) && ~isempty(current_value{i})) % Allow empty char '', but if not empty, must be row vector
                valid = false;
                break;
            end
        end
    end

    if ~valid
        val_str = format_param_value_for_log(current_value);
        log_message(params, sprintf('Invalid value for %s.%s: %s. Must be a cell array of character row vectors. Resetting to default (%s).', ...
            struct_name, field_name, val_str, format_param_value_for_log(default_value)), 1, 'Warning');
        params.(struct_name).(field_name) = default_value;
    end
end

% Validate top-level structure types first
sub_struct_names = {'export_settings', 'stats_overlay', 'panel_labeling'};
for i = 1:length(sub_struct_names)
    ss_name = sub_struct_names{i};
    if isfield(params, ss_name) % It should be, from base_defaults
        if ~isstruct(params.(ss_name)) % If user overwrote with non-struct, or preset was bad
            val_str = format_param_value_for_log(params.(ss_name));
            log_message(params, sprintf('Parameter ''%s'' is not a struct (type: %s). Reverting to default %s settings.', ...
                ss_name, val_str, ss_name), 1, 'Warning');
            params.(ss_name) = base_defaults.(ss_name);
        end
    else % Should not happen if base_defaults is complete
        log_message(params, sprintf('Default parameter for ''%s'' is missing. This is an internal bug. Using empty struct.', ss_name), 0, 'Error');
        params.(ss_name) = struct(); % Failsafe
    end
end

% Special merge for sub-structs like stats_overlay (if user provided partial struct)
% This allows user to specify e.g. user_params.stats_overlay.enabled = true
% without needing to define the whole user_params.stats_overlay struct.
% This step is performed *after* params.stats_overlay is guaranteed to be a struct (from above).
log_message(params, 'Merging user-provided fields for specific sub-structs (e.g., stats_overlay)...', 2, 'Info');
if isfield(user_provided_params_struct, 'stats_overlay') && isstruct(user_provided_params_struct.stats_overlay)
   % params.stats_overlay is already a struct (either from default/preset, or user's full replacement, or reset if user gave bad type)
   % Now, merge fields from user_provided_params_struct.stats_overlay into params.stats_overlay
   user_so_fields = fieldnames(user_provided_params_struct.stats_overlay);
   for k_so = 1:length(user_so_fields)
       field_to_merge = user_so_fields{k_so};
       if isfield(base_defaults.stats_overlay, field_to_merge) % Only merge known fields
           params.stats_overlay.(field_to_merge) = user_provided_params_struct.stats_overlay.(field_to_merge);
       else
           log_message(params, sprintf('Unknown field in user-provided stats_overlay: "%s". This field will be ignored.', field_to_merge), 1, 'Warning');
       end
   end
end
% Similar merge for panel_labeling
if isfield(user_provided_params_struct, 'panel_labeling') && isstruct(user_provided_params_struct.panel_labeling)
   user_pl_fields = fieldnames(user_provided_params_struct.panel_labeling);
   for k_pl = 1:length(user_pl_fields)
       field_to_merge = user_pl_fields{k_pl};
       if isfield(base_defaults.panel_labeling, field_to_merge)
           params.panel_labeling.(field_to_merge) = user_provided_params_struct.panel_labeling.(field_to_merge);
       else
           log_message(params, sprintf('Unknown field in user-provided panel_labeling: "%s". This field will be ignored.', field_to_merge), 1, 'Warning');
       end
   end
end
log_message(params, 'Sub-struct field merging complete.', 2, 'Info');


% Perform detailed field-by-field validation on the (potentially merged) sub-structs
log_message(params, 'Performing detailed sub-struct FIELD validation...', 2, 'Info');

% export_settings validation
if isstruct(params.export_settings) % Should be true due to earlier type check
    % Ensure all default fields exist in params.export_settings, validate them
    default_es_fields = fieldnames(base_defaults.export_settings);
    for k_esf = 1:length(default_es_fields)
        fn = default_es_fields{k_esf};
        % validate_..._field helpers will add default if missing and validate
        switch fn
            case 'resolution'; params = validate_numeric_scalar_field(params, base_defaults, 'export_settings', fn, true, true, false);
            case {'enabled', 'open_exported_file', 'ui'}; params = validate_logical_field(params, base_defaults, 'export_settings', fn);
            case {'filename', 'format', 'renderer'} % String fields, specific validation if needed
                if ~isfield(params.export_settings, fn) || ~ischar(params.export_settings.(fn))
                    log_message(params, sprintf('Field export_settings.%s is missing or not a string. Resetting to default (%s).', fn, format_param_value_for_log(base_defaults.export_settings.(fn))), 1, 'Warning');
                    params.export_settings.(fn) = base_defaults.export_settings.(fn);
                end
            otherwise % Unknown field in defaults, internal issue
                 log_message(params, sprintf('Unhandled default field in export_settings: %s', fn), 1, 'Warning');
        end
    end
    % Warn about extra fields provided by user not in defaults
    current_es_fields = fieldnames(params.export_settings);
    extra_es_fields = setdiff(current_es_fields, default_es_fields);
    for k_ex = 1:length(extra_es_fields)
        log_message(params, sprintf('Unknown field in params.export_settings: "%s". Ignored.', extra_es_fields{k_ex}), 1, 'Warning');
    end
else
    log_message(params, '''params.export_settings'' is unexpectedly not a struct before detailed field validation. This may indicate an internal problem.', 0, 'Error');
    if isfield(base_defaults, 'export_settings'); params.export_settings = base_defaults.export_settings; end % Attempt recovery
end

% stats_overlay validation
if isstruct(params.stats_overlay)
    default_so_fields = fieldnames(base_defaults.stats_overlay);
    for k_sof = 1:length(default_so_fields)
        fn = default_so_fields{k_sof};
        switch fn
            case 'font_scale_factor'; params = validate_numeric_scalar_field(params, base_defaults, 'stats_overlay', fn, true, false, false);
            case 'precision'; params = validate_numeric_scalar_field(params, base_defaults, 'stats_overlay', fn, true, false, true);
            case 'enabled'; params = validate_logical_field(params, base_defaults, 'stats_overlay', fn);
            case 'statistics'; params = validate_cell_array_of_strings_field(params, base_defaults, 'stats_overlay', fn);
            case {'position', 'target_plot_handle_tag'} % String fields
                if ~isfield(params.stats_overlay, fn) || ~ischar(params.stats_overlay.(fn))
                    log_message(params, sprintf('Field stats_overlay.%s is missing or not a string. Resetting to default (%s).', fn, format_param_value_for_log(base_defaults.stats_overlay.(fn))), 1, 'Warning');
                    params.stats_overlay.(fn) = base_defaults.stats_overlay.(fn);
                end
            case {'text_color', 'font_name', 'background_color', 'edge_color'} % Color/font name (can be empty)
                if ~isfield(params.stats_overlay, fn)
                     params.stats_overlay.(fn) = base_defaults.stats_overlay.(fn); % Add if missing
                end
                % Further validation for color specs could be added if complex
            otherwise
                log_message(params, sprintf('Unhandled default field in stats_overlay: %s', fn), 1, 'Warning');
        end
    end
    current_so_fields = fieldnames(params.stats_overlay);
    extra_so_fields = setdiff(current_so_fields, default_so_fields);
    for k_ex = 1:length(extra_so_fields)
        log_message(params, sprintf('Unknown field in params.stats_overlay: "%s". Ignored.', extra_so_fields{k_ex}), 1, 'Warning');
    end
else
    log_message(params, '''params.stats_overlay'' is unexpectedly not a struct before detailed field validation.', 0, 'Error');
    if isfield(base_defaults, 'stats_overlay'); params.stats_overlay = base_defaults.stats_overlay; end
end

% panel_labeling validation (similar to stats_overlay)
if isstruct(params.panel_labeling)
    default_pl_fields = fieldnames(base_defaults.panel_labeling);
    for k_plf = 1:length(default_pl_fields)
        fn = default_pl_fields{k_plf};
        switch fn
            case {'font_scale_factor', 'x_offset', 'y_offset'}
                params = validate_numeric_scalar_field(params, base_defaults, 'panel_labeling', fn, false, false, false); % Allow any scalar
            case 'enabled'; params = validate_logical_field(params, base_defaults, 'panel_labeling', fn);
            case {'style', 'position', 'font_weight'} % String fields
                if ~isfield(params.panel_labeling, fn) || ~ischar(params.panel_labeling.(fn))
                    log_message(params, sprintf('Field panel_labeling.%s is missing or not a string. Resetting to default (%s).', fn, format_param_value_for_log(base_defaults.panel_labeling.(fn))),1,'Warning');
                    params.panel_labeling.(fn) = base_defaults.panel_labeling.(fn);
                end
            case {'text_color', 'font_name'} % Color/font name (can be empty)
                 if ~isfield(params.panel_labeling, fn)
                     params.panel_labeling.(fn) = base_defaults.panel_labeling.(fn);
                 end
            otherwise
                 log_message(params, sprintf('Unhandled default field in panel_labeling: %s', fn), 1, 'Warning');
        end
    end
    current_pl_fields = fieldnames(params.panel_labeling);
    extra_pl_fields = setdiff(current_pl_fields, default_pl_fields);
    for k_ex = 1:length(extra_pl_fields)
        log_message(params, sprintf('Unknown field in params.panel_labeling: "%s". Ignored.', extra_pl_fields{k_ex}), 1, 'Warning');
    end
else
    log_message(params, '''params.panel_labeling'' is unexpectedly not a struct before detailed field validation.', 0, 'Error');
    if isfield(base_defaults, 'panel_labeling'); params.panel_labeling = base_defaults.panel_labeling; end
end


log_message(params, 'Detailed sub-struct FIELD validation complete.', 2, 'Info');
% --- END Sub-Struct Type and Field Validation ---

% Apply theme defaults intelligently after presets and user params have been merged.
original_light_theme_colors.axis_color = base_defaults.axis_color;
original_light_theme_colors.text_color = base_defaults.text_color;
original_light_theme_colors.grid_color = base_defaults.grid_color;
original_light_theme_colors.figure_background_color = base_defaults.figure_background_color;

dark_theme_generic_colors.axis_color = [0.85 0.85 0.85];
dark_theme_generic_colors.text_color = [0.9 0.9 0.9];
dark_theme_generic_colors.grid_color = [0.7 0.7 0.7];
dark_theme_generic_colors.figure_background_color = [0.12 0.12 0.15];

theme_changed_log_needed = false; % Changed variable name
if strcmpi(params.theme, 'dark')
    % Only apply dark theme generic colors if the user hasn't specified them AND
    % the current color is still the original light theme default (meaning a preset didn't already set a specific dark theme color)
    if ~isfield(user_provided_params_struct, 'axis_color') && isequal(params.axis_color, original_light_theme_colors.axis_color)
        params.axis_color = dark_theme_generic_colors.axis_color; theme_changed_log_needed = true;
    end
    if ~isfield(user_provided_params_struct, 'text_color') && isequal(params.text_color, original_light_theme_colors.text_color)
        params.text_color = dark_theme_generic_colors.text_color; theme_changed_log_needed = true;
    end
    if ~isfield(user_provided_params_struct, 'grid_color') && isequal(params.grid_color, original_light_theme_colors.grid_color)
        params.grid_color = dark_theme_generic_colors.grid_color; theme_changed_log_needed = true;
    end
    if ~isfield(user_provided_params_struct, 'figure_background_color') && isequal(params.figure_background_color, original_light_theme_colors.figure_background_color)
        params.figure_background_color = dark_theme_generic_colors.figure_background_color; theme_changed_log_needed = true;
    end
    if theme_changed_log_needed; log_message(params, 'Generic dark theme color defaults applied where not specified by preset or user.', 2, 'Info'); end
else % Light theme is active
    % If theme is light, but colors might be dark (e.g. from a dark preset then user changed theme to light), revert.
    if ~isfield(user_provided_params_struct, 'axis_color') && isequal(params.axis_color, dark_theme_generic_colors.axis_color)
        params.axis_color = original_light_theme_colors.axis_color; theme_changed_log_needed = true;
    end
    if ~isfield(user_provided_params_struct, 'text_color') && isequal(params.text_color, dark_theme_generic_colors.text_color)
        params.text_color = original_light_theme_colors.text_color; theme_changed_log_needed = true;
    end
    if ~isfield(user_provided_params_struct, 'grid_color') && isequal(params.grid_color, dark_theme_generic_colors.grid_color)
        params.grid_color = original_light_theme_colors.grid_color; theme_changed_log_needed = true;
    end
    if ~isfield(user_provided_params_struct, 'figure_background_color') && isequal(params.figure_background_color, dark_theme_generic_colors.figure_background_color)
        params.figure_background_color = original_light_theme_colors.figure_background_color; theme_changed_log_needed = true;
    end
    if theme_changed_log_needed; log_message(params, 'Generic light theme color defaults applied/reverted where not specified by preset or user.', 2, 'Info'); end
end

% Calculate derived parameters
params.axis_line_width = params.plot_line_width * params.axis_to_plot_linewidth_ratio;
params.base_font_size = params.base_font_size * params.global_font_scale_factor; % Effective base font size

% --- Figure-Level Adjustments (only if processing whole figure) ---
if isempty(target_axes) && ~isempty(params.figure_background_color)
    try
        current_fig_color = get(fig, 'Color');
        if ~isequal(current_fig_color, params.figure_background_color)
            set(fig, 'Color', params.figure_background_color);
        end
    catch ME_figcolor
        log_message(params, sprintf('Failed to set figure background color: %s', ME_figcolor.message), 1, 'Warning');
    end
end

% Prepare color palette
try
    params.active_color_palette = get_color_palette(params, fig);
    params.num_palette_colors = size(params.active_color_palette, 1);
catch ME_palette
    log_message(params, sprintf('Failed to prepare color palette: %s. Using default "lines".', ME_palette.message), 1, 'Warning');
    params.active_color_palette = lines(7); % Default from MATLAB
    params.num_palette_colors = 7;
end

% --- Main Processing Logic ---
if ~isempty(target_axes)
    log_message(params, sprintf('Processing %d specified axes...', numel(target_axes)), 1, 'Info');
    for i = 1:numel(target_axes)
        ax = target_axes(i);
        if isvalid(ax)
            parent_layout = ancestor(ax, 'matlab.graphics.layout.TiledChartLayout');
            num_to_scale_by = get_scale_basis_for_axes(ax, parent_layout, params);
            scale_factor = get_scale_factor(num_to_scale_by, params.scaling_map, params.min_scale_factor, params.max_scale_factor);
            log_message(params, sprintf('  Processing Axes (Tag: %s, Type: %s). Scale: %.2f', ax.Tag, class(ax), scale_factor), 2, 'Info');
            beautify_single_axes(ax, params, scale_factor, i);
        else
            log_message(params, sprintf('  Skipping invalid axes handle at index %d.', i), 1, 'Warning');
        end
    end
else % Process whole figure
    % Handle tabs if present
    tab_groups = findobj(fig, 'Type', 'uitabgroup', '-depth', 1);
    if isempty(tab_groups)
        log_message(params, 'Processing figure (no tabs found)...', 1, 'Info');
        process_container(fig, params);
    else
        for tg_idx = 1:length(tab_groups)
            current_tab_group = tab_groups(tg_idx);
            if ~isvalid(current_tab_group); continue; end
            tabs = current_tab_group.Children;
            for t_idx = 1:length(tabs)
                current_tab = tabs(t_idx);
                if ~isvalid(current_tab) || ~isprop(current_tab, 'Title'); continue; end
                tab_title_for_disp = ['Tab ' num2str(t_idx)];
                if ~isempty(current_tab.Title); tab_title_for_disp = current_tab.Title; end
                log_message(params, sprintf('Processing %s...', tab_title_for_disp), 1, 'Info');
                process_container(current_tab, params);
            end
        end
    end
end

% --- Export Figure (if enabled) ---
if params.export_settings.enabled
    [fpath, name_part, ~] = fileparts(params.export_settings.filename);
    if isempty(name_part); name_part = 'beautified_figure'; end
    current_format = lower(params.export_settings.format);
    
    % Normalize common extensions
    if any(strcmp(current_format, {'jpeg', 'jpg'}))
        export_ext = 'jpg'; print_driver_format = 'jpeg';
    elseif any(strcmp(current_format, {'tiff', 'tif'}))
        export_ext = 'tif'; print_driver_format = 'tiff';
    elseif strcmp(current_format, 'eps')
        export_ext = 'eps'; print_driver_format = 'epsc'; % Ensure color EPS
    else
        export_ext = current_format; print_driver_format = current_format;
    end
    
    full_filename_with_ext = fullfile(fpath, [name_part, '.', export_ext]);
    
    log_message(params, sprintf('Exporting figure to "%s"...', full_filename_with_ext), 1, 'Info');
    try
        export_done_successfully = false;
        % exportgraphics is generally preferred if available (R2020a+) and UI is true OR renderer is auto for it
        use_exportgraphics = exist('exportgraphics','file') == 2 && ...
                             (params.export_settings.ui || strcmpi(params.export_settings.renderer, 'auto'));
        
        if use_exportgraphics
            log_message(params, sprintf('Attempting exportgraphics (resolution %d DPI).', params.export_settings.resolution), 2, 'Info');
            exportgraphics_args = {fig, full_filename_with_ext, 'Resolution', params.export_settings.resolution};
            % ContentType for vector/raster preference with exportgraphics
            if any(strcmpi(export_ext, {'pdf', 'eps', 'svg'}))
                exportgraphics_args = [exportgraphics_args, {'ContentType', 'vector'}];
            else
                exportgraphics_args = [exportgraphics_args, {'ContentType', 'image'}];
            end
            exportgraphics(exportgraphics_args{:});
            log_message(params, 'Export successful using exportgraphics.', 1, 'Info');
            export_done_successfully = true;
        else
            if ~params.export_settings.ui && exist('exportgraphics','file') == 2 && ~strcmpi(params.export_settings.renderer, 'auto')
                 log_message(params, 'UI set to false and specific renderer for print chosen. Using `print`.', 2, 'Info');
            elseif exist('exportgraphics','file') ~= 2
                 log_message(params, 'exportgraphics not available. Using `print`.', 2, 'Info');
            end

            format_flag = ['-d' print_driver_format];
            
            valid_print_formats = {'png', 'jpeg', 'tiff', 'pdf', 'epsc', 'svg', 'bmp', 'gif', 'pcx', 'pbm', 'pgm', 'ppm'}; % Common print formats
            if ~any(strcmpi(print_driver_format, valid_print_formats))
                 log_message(params, sprintf('Unsupported export format for print command: "%s". Skipping export.', print_driver_format), 1, 'Warning');
                 format_flag = ''; % Will skip print
            end

            if ~isempty(format_flag)
                resolution_flag = sprintf('-r%d', params.export_settings.resolution);
                cmd_parts = {fig, full_filename_with_ext, format_flag, resolution_flag};

                renderer_to_use_for_print = params.export_settings.renderer;
                if strcmpi(renderer_to_use_for_print, 'auto') % 'auto' for print isn't a specific flag
                    renderer_to_use_for_print = 'painters'; % Default to painters for print if auto
                    log_message(params, 'Renderer "auto" selected for print; defaulting to "painters".', 2, 'Info');
                end
                
                if any(strcmpi(print_driver_format, {'pdf', 'epsc', 'svg'})) % Vector formats
                    if ~any(strcmpi(renderer_to_use_for_print, {'painters', 'vector'}))
                        log_message(params, sprintf('Renderer "%s" not ideal for vector format "%s" with print. Suggesting "painters".', renderer_to_use_for_print, print_driver_format), 1, 'Warning');
                        % User choice is respected unless it was 'auto'
                    end
                end
                
                if ~isempty(renderer_to_use_for_print)
                    valid_renderers_print = {'painters', 'opengl', 'vector', 'zbuffer'};
                    if any(strcmpi(renderer_to_use_for_print, valid_renderers_print))
                        renderer_flag = sprintf('-%s', renderer_to_use_for_print);
                        cmd_parts{end+1} = renderer_flag;
                    else
                        log_message(params, sprintf('Invalid renderer "%s" for print. Using MATLAB default for this format.', renderer_to_use_for_print), 1, 'Warning');
                    end
                end
                
                if ~params.export_settings.ui % Add -noui if not using UI (relevant for print)
                    cmd_parts{end+1} = '-noui';
                end
                
                log_message(params, sprintf('Using print command with options: %s', strjoin(cmd_parts(3:end),' ')), 2, 'Info');
                print(cmd_parts{:});
                log_message(params, 'Export successful using print command.', 1, 'Info');
                export_done_successfully = true;
            else
                 log_message(params, 'Export skipped due to empty format_flag (unsupported or invalid format for print).', 1, 'Warning');
            end
        end

        if export_done_successfully && params.export_settings.open_exported_file
            log_message(params, sprintf('Attempting to open exported file: %s', full_filename_with_ext), 2, 'Info');
            try
                open(full_filename_with_ext); % MATLAB's open function
            catch ME_open_matlab
                log_message(params, sprintf('MATLAB open() failed: "%s". Trying system open.', ME_open_matlab.message), 1, 'Warning');
                try
                    % Ensure full path for system command
                    if isempty(fpath); current_file_path_abs = fullfile(pwd, full_filename_with_ext);
                    else; current_file_path_abs = full_filename_with_ext; end

                    if ispc
                        system(['start "" "', current_file_path_abs, '"']);
                    elseif ismac
                        system(['open "', current_file_path_abs, '"']);
                    else % Linux or other Unix
                        system(['xdg-open "', current_file_path_abs, '"']);
                    end
                catch ME_sys_open
                    log_message(params, sprintf('System open command failed: %s', ME_sys_open.message), 1, 'Warning');
                end
            end
        elseif ~export_done_successfully
            log_message(params, 'Export was not successful, skipping file open.', 1, 'Warning');
        end

    catch ME_export
        log_message(params, sprintf('Figure export process failed: %s (File: %s, Line: %d)', ME_export.message, ME_export.stack(1).name, ME_export.stack(1).line), 0, 'Error');
    end
end

log_message(params, 'Figure beautification complete.', 1, 'Info');
drawnow; % Ensure all changes are rendered
end

% --- Helper Function: Validate Axes Handle Array ---
function tf = is_valid_axes_handle_array(h_array)
if isempty(h_array)
    tf = true; 
    return;
end

% Check if all elements are graphics handles
if ~all(ishghandle(h_array)) % ishghandle is more robust for graphics
    tf = false;
    return;
end

% Check if all handles are valid (not deleted)
if ~all(isvalid(h_array))
    tf = false;
    return;
end

% Check if all valid handles are of the correct type (Axes or PolarAxes)
is_correct_type = arrayfun(@(h) isa(h, 'matlab.graphics.axis.Axes') || isa(h, 'matlab.graphics.axis.PolarAxes'), h_array);
if ~all(is_correct_type)
    tf = false;
    return;
end
tf = true;
end

% --- Helper Function: Get Scale Basis for an Axes ---
function num_to_scale_by = get_scale_basis_for_axes(ax_ref, parent_layout, params)
% ax_ref is one of the axes in the layout, or the single axes if no layout.
num_to_scale_by = 1; % Default for standalone axes
if ~isempty(parent_layout) && isvalid(parent_layout)
    try
        grid_size = parent_layout.GridSize;
        % Define tags/types to ignore when counting plottable axes within a layout
        axes_to_ignore_for_scaling = [{'legend', 'Colorbar', 'ColormapPreview', 'scribeOverlay'}, params.exclude_object_tags];
        if ~params.apply_to_colorbars; axes_to_ignore_for_scaling{end+1} = 'Colorbar'; end % If colorbars not beautified, don't count them for scaling.
        
        % Count only valid, plottable axes children of this specific layout
        axes_in_layout_raw = get_axes_from_parent(parent_layout, params, axes_to_ignore_for_scaling);
        num_axes_found = numel(axes_in_layout_raw);

        num_to_scale_by = max(1, num_axes_found);
        % If grid is defined and larger than found axes, use grid size for more consistent scaling
        % This helps if some grid cells are empty but intended for plots.
        if prod(grid_size) > num_axes_found && prod(grid_size) > 0
            num_to_scale_by = prod(grid_size);
        end
    catch ME_scale_basis
        log_message(params, sprintf('Could not determine scale basis for axes in TiledLayout: %s. Using default of 1.', ME_scale_basis.message), 1, 'Warning');
        num_to_scale_by = 1; % Fallback
    end
else % No parent_layout, might be a figure with multiple non-tiled subplots
    fig_parent = ancestor(ax_ref, 'figure');
    if ~isempty(fig_parent)
        axes_to_ignore_for_scaling = [{'legend', 'Colorbar', 'ColormapPreview', 'scribeOverlay'}, params.exclude_object_tags];
        if ~params.apply_to_colorbars; axes_to_ignore_for_scaling{end+1} = 'Colorbar'; end
        
        all_axes_in_fig = get_axes_from_parent(fig_parent, params, axes_to_ignore_for_scaling);
        % Check if these axes are direct children or in non-tiled subplots (not in a TiledLayout)
        axes_not_in_tiled_layout = [];
        for k_ax = 1:numel(all_axes_in_fig)
            if isempty(ancestor(all_axes_in_fig(k_ax), 'matlab.graphics.layout.TiledChartLayout'))
                axes_not_in_tiled_layout = [axes_not_in_tiled_layout; all_axes_in_fig(k_ax)]; %#ok<AGROW>
            end
        end
        num_to_scale_by = max(1, numel(axes_not_in_tiled_layout));
    end
end
end

% --- Helper Function: Get Color Palette ---
function active_palette = get_color_palette(params, fig_handle)
    % Define Turbo and Cividis 10-color maps locally
    turbo_map_10 = [
        0.18995,0.07176,0.23217; 0.29325,0.31756,0.97420; 0.15136,0.56099,0.93081;
        0.06059,0.75147,0.71000; 0.33951,0.86366,0.39968; 0.68301,0.88631,0.18263;
        0.90100,0.79200,0.21400; 0.98324,0.59224,0.27638; 0.90093,0.34687,0.20899;
        0.73263,0.16332,0.09368
    ];
    cividis_map_10 = [
        0.00000,0.12911,0.27800; 0.24196,0.21900,0.46080; 0.41211,0.30930,0.55020;
        0.56453,0.40778,0.57890; 0.70838,0.51325,0.55930; 0.84693,0.62846,0.50350;
        0.97397,0.75820,0.42250; 0.99520,0.89370,0.41480; 0.93696,0.99212,0.58970;
        0.96822,0.99868,0.97000
    ];

    palette_source = params.color_palette;
    if ischar(palette_source) || isstring(palette_source)
        palette_source_char = lower(char(palette_source));
        switch palette_source_char
            case 'lines'; active_palette = lines(7);
            case 'parula'; active_palette = parula(10);
            case 'viridis'
                if exist('viridis','file') == 2; active_palette = viridis(10);
                else; log_message(params,'"viridis" colormap function not found. Using "lines".',1,'Warning'); active_palette = lines(7); end
            case 'turbo'
                active_palette = turbo_map_10;
            case 'cividis'
                active_palette = cividis_map_10;
            case 'default_matlab'
                original_visibility = ''; fig_valid_and_has_prop = false;
                if isvalid(fig_handle) && isprop(fig_handle, 'HandleVisibility')
                    original_visibility = get(fig_handle,'HandleVisibility');
                    safe_set(params, fig_handle,'HandleVisibility','on'); % Use safe_set
                    fig_valid_and_has_prop = true;
                end
                ax_temp = axes('Parent', fig_handle, 'Visible', 'off', 'HandleVisibility', 'off', 'Tag', 'BeautifyFig_TempAxesForColorOrder');
                try
                    active_palette = get(ax_temp,'colororder');
                catch
                    active_palette = get(groot,'defaultAxesColorOrder');
                end
                delete(ax_temp);
                if fig_valid_and_has_prop; safe_set(params, fig_handle,'HandleVisibility',original_visibility); end % Use safe_set
                if size(active_palette,1) < 2; active_palette = get(groot,'defaultAxesColorOrder'); end % Fallback if temp axes failed badly
            case {'cbrewer_qual_set1', 'cbrewer_qual_set2', 'cbrewer_qual_set3', ...
                  'cbrewer_seq_blues', 'cbrewer_div_brbg'} % Add more as needed
                if exist('cbrewer','file') == 2
                    try
                        parts = strsplit(palette_source_char, '_'); ctype = parts{2}; cname = parts{3}; num_colors = 8;
                        if length(parts) > 3 && ~isempty(str2double(parts{4})); num_colors = str2double(parts{4}); end
                        active_palette = cbrewer(ctype, cname, max(3,num_colors)); % cbrewer needs at least 3 colors
                    catch ME_cbrewer
                        log_message(params, sprintf('cbrewer palette "%s" failed: %s. Using "lines".', palette_source_char, ME_cbrewer.message), 1,'Warning'); active_palette = lines(7);
                    end
                else
                    log_message(params,'"cbrewer" function not found. Using "lines".',1,'Warning'); active_palette = lines(7);
                end
            case 'custom'
                if ~isempty(params.custom_color_palette) && isnumeric(params.custom_color_palette) && ndims(params.custom_color_palette) == 2 && size(params.custom_color_palette,2) == 3 && size(params.custom_color_palette,1) > 0
                    active_palette = params.custom_color_palette;
                else
                    log_message(params, 'Invalid "custom_color_palette" data. Must be an Nx3 numeric matrix. Using "lines".', 1,'Warning'); active_palette = lines(7);
                end
            otherwise
                log_message(params, sprintf('Unknown color palette name: "%s". Using "lines".', palette_source_char), 1,'Warning'); active_palette = lines(7);
        end
    elseif isnumeric(palette_source) && ndims(palette_source) == 2 && size(palette_source,2) == 3 && size(palette_source,1) > 0
        active_palette = palette_source;
    else
        log_message(params, 'Invalid color palette format. Must be a known string or Nx3 RGB matrix. Using "lines".', 1,'Warning'); active_palette = lines(7);
    end
    if isempty(active_palette); active_palette = lines(7); end % Final fallback
end

% --- Helper Function: Process a Container (Figure or Tab) ---
function process_container(container_handle, params)
    axes_to_ignore_combined = [{'legend', 'Colorbar', 'ColormapPreview', 'scribeOverlay'}, params.exclude_object_tags];
    if ~params.apply_to_colorbars; axes_to_ignore_combined{end+1} = 'Colorbar'; end % Tag for colorbar axes is 'Colorbar'

    if params.beautify_sgtitle
        % sgtitle applies to TiledChartLayout or Figure (if TiledChartLayout is direct child)
        if isa(container_handle, 'matlab.ui.Figure')
            % Find TiledChartLayouts that are direct children of the figure
            tls_in_fig = findobj(container_handle, 'Type', 'tiledlayout', '-depth', 1);
            for k_tl = 1:length(tls_in_fig)
                if isvalid(tls_in_fig(k_tl)); beautify_sgtitle_if_exists(tls_in_fig(k_tl), params); end
            end
        elseif isa(container_handle, 'matlab.graphics.layout.TiledChartLayout')
             beautify_sgtitle_if_exists(container_handle, params);
        elseif isa(container_handle, 'matlab.ui.container.Tab')
            % Find TiledChartLayouts within this tab
            tls_in_tab = findobj(container_handle, 'Type', 'tiledlayout'); % Search deeper in tab
            for k_tl = 1:length(tls_in_tab)
                if isvalid(tls_in_tab(k_tl)); beautify_sgtitle_if_exists(tls_in_tab(k_tl), params); end
            end
        end
    end

    tiled_layouts_in_container = findobj(container_handle, 'Type', 'tiledlayout'); % Find all tiled layouts in container
    processed_axes_in_tiled_layouts = [];

    if ~isempty(tiled_layouts_in_container)
        for tl_idx = 1:length(tiled_layouts_in_container)
            current_tiled_layout = tiled_layouts_in_container(tl_idx);
            if ~isvalid(current_tiled_layout); continue; end
            
            axes_in_this_layout = get_axes_from_parent(current_tiled_layout, params, axes_to_ignore_combined);
            if isempty(axes_in_this_layout); continue; end
            
            num_to_scale_by = get_scale_basis_for_axes(axes_in_this_layout(1), current_tiled_layout, params);
            scale_factor = get_scale_factor(num_to_scale_by, params.scaling_map, params.min_scale_factor, params.max_scale_factor);
            grid_size_disp = current_tiled_layout.GridSize;
            log_message(params, sprintf('  TiledLayout (Grid: %dx%d, Axes found: %d). Scale: %.2f', grid_size_disp(1), grid_size_disp(2), numel(axes_in_this_layout), scale_factor), 2, 'Info');
            
            for ax_loop_idx = 1:numel(axes_in_this_layout)
                ax_to_beautify = axes_in_this_layout(ax_loop_idx);
                if isvalid(ax_to_beautify)
                    beautify_single_axes(ax_to_beautify, params, scale_factor, ax_loop_idx);
                    processed_axes_in_tiled_layouts = [processed_axes_in_tiled_layouts; ax_to_beautify]; %#ok<AGROW>
                end
            end
        end
    end
    
    % Process axes directly in container that are NOT in any TiledLayout
    all_axes_in_container_direct = get_axes_from_parent(container_handle, params, axes_to_ignore_combined);
    axes_not_in_any_tiled_layout = [];
    for k_ax_direct = 1:numel(all_axes_in_container_direct)
        ax_candidate = all_axes_in_container_direct(k_ax_direct);
        % Check if this axis was already processed because it was in a TiledLayout
        is_already_processed = any(processed_axes_in_tiled_layouts == ax_candidate);
        if ~is_already_processed
             % Also ensure it's not part of ANY tiled layout, even one not directly under this container
             if isempty(ancestor(ax_candidate, 'matlab.graphics.layout.TiledChartLayout'))
                axes_not_in_any_tiled_layout = [axes_not_in_any_tiled_layout; ax_candidate]; %#ok<AGROW>
             end
        end
    end

    if isempty(axes_not_in_any_tiled_layout)
        if isempty(tiled_layouts_in_container) % No tiled layouts AND no other axes
             log_message(params, '  No plottable axes found in this container.', 2, 'Info');
        end
        return; 
    end
    
    num_axes_no_tl = numel(axes_not_in_any_tiled_layout);
    % For non-tiled axes, scale_factor is based on their count within the current container
    % (fig or tab), assuming they are somewhat "subplot-like".
    scale_factor_no_tl = get_scale_factor(num_axes_no_tl, params.scaling_map, params.min_scale_factor, params.max_scale_factor);
    log_message(params, sprintf('  Container has %d axes not in a TiledLayout. Scale: %.2f', num_axes_no_tl, scale_factor_no_tl), 2, 'Info');
    
    for ax_idx = 1:num_axes_no_tl
        ax_to_beautify = axes_not_in_any_tiled_layout(ax_idx);
        if isvalid(ax_to_beautify)
            beautify_single_axes(ax_to_beautify, params, scale_factor_no_tl, ax_idx);
        end
    end
end

% --- Helper Function: Beautify Super Title (sgtitle) ---
function beautify_sgtitle_if_exists(layout_or_fig_handle, params)
% layout_or_fig_handle can be a TiledChartLayout or a Figure
try
    sgt = [];
    if isa(layout_or_fig_handle, 'matlab.graphics.layout.TiledChartLayout')
        if isprop(layout_or_fig_handle, 'Title') && isvalid(layout_or_fig_handle.Title) && ~isempty(layout_or_fig_handle.Title.String)
            sgt = layout_or_fig_handle.Title;
        end
    elseif isa(layout_or_fig_handle, 'matlab.ui.Figure')
        % For a figure, sgtitle might be associated with a TiledChartLayout child
        % This case is handled by iterating TiledChartLayouts in process_container
        % Or, if user called sgtitle(fig, ...), it creates a special axes.
        % This scenario is less common with modern TiledLayouts.
        % For simplicity, this helper focuses on TiledChartLayout.Title
        return; % Figure-level sgtitle handled by iterating its TiledLayouts
    end

    if ~isempty(sgt)
        % Use a slightly larger scale for sgtitle than for regular titles
        % Max scale factor is used as sgtitle is unique per layout/figure.
        sg_font_size = round(params.base_font_size * params.title_scale * params.max_scale_factor * 1.15); % Slightly smaller multiplier
        sg_font_size = max(sg_font_size, round(params.base_font_size * 1.6)); % Ensure a minimum prominent size
        process_text_prop(sgt, sgt.String, sg_font_size, 'bold', params.text_color, params.font_name, params, true); % LaTeX auto usually off for sgtitle
    end
catch ME_sgtitle
    log_message(params, sprintf('Could not beautify sgtitle: %s', ME_sgtitle.message), 1, 'Warning');
end
end

% --- Helper Function: Get Plottable Axes from Parent ---
function axes_handles = get_axes_from_parent(parent_handle, params, ignore_tags_combined)
axes_handles = matlab.graphics.axis.Axes.empty; % Initialize with correct empty type
if ~isvalid(parent_handle); return; end
try
    % Find children that are Axes or PolarAxes, at depth 1 (direct children)
    % This is crucial for TiledChartLayout where axes are direct children.
    % For figure/tab, this will find top-level axes.
    potential_children = findobj(parent_handle, '-depth', 1); 
catch ME_findobj
    log_message(params, sprintf('findobj failed for parent %s (Tag: %s): %s', class(parent_handle), parent_handle.Tag, ME_findobj.message),1,'Warning');
    return;
end

for k=1:length(potential_children)
    child = potential_children(k);
    if child == parent_handle || ~isvalid(child); continue; end % Skip self or invalid

    is_valid_axis_type = (isa(child, 'matlab.graphics.axis.Axes') || ...
                         (params.apply_to_polaraxes && isa(child, 'matlab.graphics.axis.PolarAxes')));

    if is_valid_axis_type
        child_tag = ''; 
        try 
            if isprop(child,'Tag'); child_tag = get(child,'Tag'); end
        catch
            % Tag property might not exist or be accessible in rare edge cases
        end 
        
        is_ignored_by_tag = false;
        if ~isempty(child_tag) && iscellstr(ignore_tags_combined) %#ok<ISCLSTR> compatibility
             is_ignored_by_tag = any(strcmp(child_tag, ignore_tags_combined));
        end
        
        is_ignored_by_type = any(strcmp(class(child), params.exclude_object_types));

        if ~is_ignored_by_tag && ~is_ignored_by_type
            axes_handles(end+1) = child; 
        end
    end
end
end

% --- Helper Function: Get Scaling Factor ---
function sf = get_scale_factor(num_sps, scaling_map, min_sf, max_sf)
    keys = cell2mat(scaling_map.keys); 
    values = cell2mat(scaling_map.values); 
    if num_sps <= 0; num_sps = 1; end % Ensure num_sps is at least 1
    
    idx = find(keys == num_sps, 1); 
    if ~isempty(idx)
        sf = values(idx);
    else
        sorted_keys = sort(keys); % Ensure keys are sorted for interpolation/extrapolation logic
        min_key = sorted_keys(1);
        max_key = sorted_keys(end);
        
        if num_sps < min_key
            % Extrapolate downwards: scale factor increases as num_sps decreases
            sf = values(keys == min_key) * nthroot(min_key / num_sps, 2.5); % Ratio > 1
        elseif num_sps > max_key
            % Extrapolate upwards: scale factor decreases as num_sps increases
            sf = values(keys == max_key) * nthroot(max_key / num_sps, 2.5); % Ratio < 1
        else
            % Interpolate
            sf = interp1(keys, values, num_sps, 'linear'); % 'extrap' not needed due to prior checks
            
            % Clamp interpolation to avoid extreme values if map is sparse near num_sps
            % Find nearest lower and upper bound values from the map
            lower_bound_val = interp1(keys, values, max(keys(keys<num_sps)), 'nearest');
            upper_bound_val = interp1(keys, values, min(keys(keys>num_sps)), 'nearest');
            % Ensure sf is not drastically different from its neighbors in the map
            sf = max(min(sf, max(lower_bound_val, upper_bound_val) * 1.1), min(lower_bound_val, upper_bound_val) * 0.9);
        end
    end
    sf = max(min_sf, min(max_sf, sf)); % Clamp to global min/max scale factors
end


% --- Core Function: Beautify a Single Axes Object ---
function beautify_single_axes(ax, params, scale_factor, ~) % axes_idx not used currently
if ~isvalid(ax); return; end
current_hold_state = ishold(ax); if ~current_hold_state; safe_hold(params, ax, 'on'); end

% Calculate scaled dimensions
fs = round(params.base_font_size * scale_factor); % General font size for axis numbers etc.
tfs = round(params.base_font_size * params.title_scale * scale_factor); % Title font size
lfs = round(params.base_font_size * params.label_scale * scale_factor); % Label font size
actual_plot_lw = max(0.75, params.plot_line_width * scale_factor); % Plot line width
alw = max(0.5, params.axis_line_width * scale_factor); % Axis line width (re-scale the derived param)
ms = max(3, params.marker_size * scale_factor); % Marker size (points)

% --- Apply Axes Properties ---
common_props = {'FontName', params.font_name, 'FontSize', fs, 'LineWidth', alw, 'TickDir', 'out', ...
                'GridColor', params.grid_color, 'GridAlpha', params.grid_alpha, 'GridLineStyle', params.grid_line_style, ...
                'MinorGridColor', params.grid_color, 'MinorGridAlpha', params.minor_grid_alpha, 'MinorGridLineStyle', params.minor_grid_line_style};

switch lower(params.axis_box_style)
    case 'on'; common_props = [common_props, {'Box', 'on'}];
    case 'off'; common_props = [common_props, {'Box', 'off'}];
    case 'left-bottom'
        common_props = [common_props, {'Box', 'off'}]; % Box off first
        % Then set locations, which might re-enable parts of the box if not handled carefully
        % For modern graphics, setting XAxisLocation/YAxisLocation is preferred
        if isprop(ax, 'XAxisLocation'); safe_set(params, ax, 'XAxisLocation', 'bottom'); end
        if isprop(ax, 'YAxisLocation'); safe_set(params, ax, 'YAxisLocation', 'left'); end
        
        % Explicitly hide other axes if they exist (e.g., for YAxis on right)
        try
            if isprop(ax, 'XAxis') && numel(ax.XAxis) > 1; safe_set(params, ax.XAxis(2), 'Visible', 'off'); end
            if isprop(ax, 'YAxis') && numel(ax.YAxis) > 1; safe_set(params, ax.YAxis(2), 'Visible', 'off'); end
            if isprop(ax, 'ZAxis') && numel(ax.ZAxis) > 1; safe_set(params, ax.ZAxis(2), 'Visible', 'off'); end
        catch ME_hide_extra_axes
             log_message(params, sprintf('Minor issue hiding extra axes for left-bottom style: %s', ME_hide_extra_axes.message), 2, 'Debug');
        end
end

major_grid_on = 'off'; minor_grid_on = 'off';
if strcmpi(params.grid_density, 'normal'); major_grid_on = 'on'; minor_grid_on = 'on';
elseif strcmpi(params.grid_density, 'major_only'); major_grid_on = 'on'; end

try
    if isa(ax, 'matlab.graphics.axis.Axes')
        safe_set(params, ax, common_props{:}, ...
                 'XGrid', major_grid_on, 'YGrid', major_grid_on, 'ZGrid', major_grid_on, ...
                 'XMinorGrid', minor_grid_on, 'YMinorGrid', minor_grid_on, 'ZMinorGrid', minor_grid_on, ...
                 'XColor', params.axis_color, 'YColor', params.axis_color, 'ZColor', params.axis_color, ...
                 'Layer', params.axes_layer);
        process_text_prop(ax.Title, ax.Title.String, tfs, 'bold', params.text_color, params.font_name, params);
        process_text_prop(ax.XLabel, ax.XLabel.String, lfs, 'normal', params.text_color, params.font_name, params);
        process_text_prop(ax.YLabel, ax.YLabel.String, lfs, 'normal', params.text_color, params.font_name, params);
        process_text_prop(ax.ZLabel, ax.ZLabel.String, lfs, 'normal', params.text_color, params.font_name, params);

        if ~isgeoaxes(ax) && strcmpi(params.axis_limit_mode, 'padded') && params.expand_axis_limits_factor > 0
            expand_axis_lims(ax, 'XLim', params.expand_axis_limits_factor, params);
            expand_axis_lims(ax, 'YLim', params.expand_axis_limits_factor, params);
            if isprop(ax,'ZAxis') && ~isempty(ax.ZAxis) && isprop(ax, 'ZLim') && diff(ax.ZLim) > 1e-9 % Check ZLim specifically
                expand_axis_lims(ax, 'ZLim', params.expand_axis_limits_factor, params); 
            end
        elseif strcmpi(params.axis_limit_mode, 'tight')
            try; axis(ax, 'tight');
                if params.expand_axis_limits_factor > 0 && params.expand_axis_limits_factor < 0.015 % very slight pad after tight
                    expand_axis_lims(ax, 'XLim', params.expand_axis_limits_factor*0.5, params); 
                    expand_axis_lims(ax, 'YLim', params.expand_axis_limits_factor*0.5, params);
                end
            catch ME_tight
                log_message(params, sprintf('Warning: "axis tight" failed for axes (Tag: %s): %s', ax.Tag, ME_tight.message),1,'Warning'); 
            end
        end
    elseif isa(ax, 'matlab.graphics.axis.PolarAxes') && params.apply_to_polaraxes
        % PolarAxes does not have 'Layer', 'X/Y/ZColor', 'X/Y/ZGrid/MinorGrid'
        % It has RColor, ThetaColor, RGrid, ThetaGrid
        safe_set(params, ax, common_props{:}, ... % common_props includes FontName, FontSize, LineWidth, TickDir, GridColor etc.
                 'RGrid', major_grid_on, 'ThetaGrid', major_grid_on, ... % No minor grid for polar by default properties
                 'RColor', params.axis_color, 'ThetaColor', params.axis_color);
        % For PolarAxes, grid lines are controlled by GridColor/Alpha/LineStyle from common_props.
        % Minor grid lines controlled by MinorGridColor/Alpha/LineStyle
        % Need to check if PolarAxes supports MinorGrid properties directly
        if isprop(ax, 'MinorGridLineStyle'); safe_set(params, ax, 'MinorGridVisible', minor_grid_on); end % R2021a+
        
        process_text_prop(ax.Title, ax.Title.String, tfs, 'bold', params.text_color, params.font_name, params);
        % Polar axes have RLabel, ThetaLabel but they are not direct properties like XLabel
        % Access them via ax.RAxis.Label, ax.ThetaAxis.Label if needed, or assume title is enough for now.
    end
catch ME_axes_props
    log_message(params, sprintf('Error setting main axes properties for (Tag: %s, Type: %s): %s', ax.Tag, class(ax), ME_axes_props.message), 1, 'Warning');
end

% --- Beautify Child Graphics Objects ---
try; all_children_orig = get(ax, 'Children'); catch; all_children_orig = []; end
all_children_filtered = [];
for k_child = 1:length(all_children_orig)
    child_obj = all_children_orig(k_child);
    if ~isvalid(child_obj); continue; end
    child_tag = ''; if isprop(child_obj,'Tag'); try child_tag = get(child_obj,'Tag'); catch; end; end
    
    is_excluded_tag = false;
    if ~isempty(child_tag) && iscellstr(params.exclude_object_tags) %#ok<ISCLSTR>
        is_excluded_tag = any(strcmp(child_tag, params.exclude_object_tags));
    end
    is_excluded_type = any(strcmp(class(child_obj), params.exclude_object_types));
    
    if ~is_excluded_tag && ~is_excluded_type
        all_children_filtered = [all_children_filtered; child_obj]; %#ok<AGROW>
    end
end

color_idx = 0; % Tracks unique plottable items for color/marker/linestyle cycling
num_marker_styles = length(params.marker_styles);
num_line_styles = length(params.line_style_order);
plottable_children_for_legend = []; % Store handles that are candidates for legend

% Determine number of legend candidates for auto cycling logic
temp_legend_candidates = [];
for i = 1:length(all_children_filtered)
    if is_legend_candidate_check(all_children_filtered(i))
        temp_legend_candidates = [temp_legend_candidates; all_children_filtered(i)]; %#ok<AGROW>
    end
end
num_total_legend_candidates = length(temp_legend_candidates);

activate_marker_cycle_now = false;
if islogical(params.cycle_marker_styles) && params.cycle_marker_styles
    activate_marker_cycle_now = true;
elseif ischar(params.cycle_marker_styles) && strcmpi(params.cycle_marker_styles, 'auto') && num_total_legend_candidates > params.marker_cycle_threshold
    activate_marker_cycle_now = true;
end

activate_linestyle_cycle_now = false;
if islogical(params.cycle_line_styles) && params.cycle_line_styles
    activate_linestyle_cycle_now = true;
elseif ischar(params.cycle_line_styles) && strcmpi(params.cycle_line_styles, 'auto') && num_total_legend_candidates > params.line_style_cycle_threshold
    activate_linestyle_cycle_now = true;
end

% Process children in specified order for legend consistency
processed_children_order = all_children_filtered;
if params.legend_reverse_order
    processed_children_order = flipud(all_children_filtered); % flipud works on column vectors
end

for i = 1:length(processed_children_order)
    child = processed_children_order(i);
    try
        is_leg_cand_current = is_legend_candidate_check(child);
        current_color_to_apply = []; 
        current_marker_style_name = 'none'; % Default marker style unless cycled
        current_line_style_name = ''; % Default line style (usually solid) unless cycled
        
        if is_leg_cand_current
            plottable_children_for_legend = [plottable_children_for_legend; child]; %#ok<AGROW>
            color_idx = color_idx + 1; % Increment for each legend candidate
            current_color_to_apply = params.active_color_palette(mod(color_idx-1, params.num_palette_colors)+1, :);
            
            if activate_marker_cycle_now && num_marker_styles > 0
                current_marker_style_name = params.marker_styles{mod(color_idx-1, num_marker_styles)+1};
            end
            if activate_linestyle_cycle_now && num_line_styles > 0
                current_line_style_name = params.line_style_order{mod(color_idx-1, num_line_styles)+1};
            end
        end

        % Apply properties to different plot types
        if isa(child, 'matlab.graphics.chart.primitive.Line')
            safe_set(params, child, 'LineWidth', actual_plot_lw, 'MarkerSize', ms);
            if ~isempty(current_color_to_apply); safe_set(params, child, 'Color', current_color_to_apply); end
            if ~isempty(current_line_style_name); safe_set(params, child, 'LineStyle', current_line_style_name); end
            
            % Marker settings for Line objects
            if ~strcmpi(current_marker_style_name, 'none') % If a marker style is determined (cycled or pre-existing and we want to style it)
                safe_set(params, child, 'Marker', current_marker_style_name);
                if ~strcmpi(current_marker_style_name, '.') && ~isempty(current_color_to_apply) % For non-'.' markers
                    safe_set(params, child, 'MarkerFaceColor', current_color_to_apply, 'MarkerEdgeColor', current_color_to_apply*0.7);
                elseif strcmpi(current_marker_style_name, '.') && ~isempty(current_color_to_apply) % For '.' marker
                    safe_set(params, child, 'MarkerEdgeColor', current_color_to_apply); % Only EdgeColor for '.'
                    safe_set(params, child, 'MarkerFaceColor', 'none'); % Ensure no face color for '.'
                end
            elseif ~strcmpi(child.Marker,'none') && ~isempty(current_color_to_apply) % If marker exists but not cycling, ensure its colors match assigned line color
                 if isprop(child,'MarkerFaceColor') && ~ischar(child.MarkerFaceColor) && ~any(strcmpi(child.MarkerFaceColor,{'auto','none'}))
                     safe_set(params, child,'MarkerFaceColor',current_color_to_apply);
                 end
                 if isprop(child,'MarkerEdgeColor') && ~ischar(child.MarkerEdgeColor) && ~any(strcmpi(child.MarkerEdgeColor,{'auto','none'}))
                      safe_set(params, child,'MarkerEdgeColor',current_color_to_apply*0.7);
                 end
            end

        elseif isa(child, 'matlab.graphics.chart.primitive.Scatter')
            safe_set(params, child, 'SizeData', ms^2, 'LineWidth', actual_plot_lw*0.5);
            if ~isempty(current_color_to_apply)
                % Only set if not 'flat' or 'none' which imply CData usage or no color
                if isprop(child, 'MarkerFaceColor') && ~(ischar(child.MarkerFaceColor) && any(strcmpi(child.MarkerFaceColor,{'none','flat'})))
                    safe_set(params, child,'MarkerFaceColor', current_color_to_apply); 
                end
                if isprop(child, 'MarkerEdgeColor') && ~(ischar(child.MarkerEdgeColor) && strcmpi(child.MarkerEdgeColor,'none'))
                    safe_set(params, child,'MarkerEdgeColor', current_color_to_apply*0.75); 
                end
            end
            if ~strcmpi(current_marker_style_name, 'none'); safe_set(params, child, 'Marker', current_marker_style_name); end
        
        elseif isa(child, 'matlab.graphics.chart.primitive.Bar')
            safe_set(params, child, 'LineWidth', alw*0.9); % Bar edge slightly thinner than axis line
            if ~isempty(current_color_to_apply)
                % Only set FaceColor if it's not 'flat' (implying CData usage)
                if isprop(child, 'FaceColor') && (~ischar(child.FaceColor) || ~strcmpi(child.FaceColor,'flat'))
                     safe_set(params, child, 'FaceColor', current_color_to_apply);
                end
                % Set EdgeColor based on FaceColor or a general dark color
                 edge_c = current_color_to_apply * 0.7; % Darker shade of face color
                 if isequal(edge_c, [0 0 0]); edge_c = params.axis_color*0.5; end % Avoid pure black if face is dark
                 safe_set(params, child, 'EdgeColor', edge_c);
            else % No color cycling, use general theme colors
                 safe_set(params, child, 'EdgeColor', params.axis_color*0.7);
            end

        elseif isa(child, 'matlab.graphics.chart.primitive.Histogram')
            safe_set(params, child, 'LineWidth', alw*0.8, 'FaceAlpha', 0.7);
             if ~isempty(current_color_to_apply)
                safe_set(params, child, 'FaceColor', current_color_to_apply);
                safe_set(params, child, 'EdgeColor', current_color_to_apply*0.5); % Darker shade for edge
             else
                safe_set(params, child, 'EdgeColor', params.axis_color*0.5);
             end

        elseif isa(child, 'matlab.graphics.chart.primitive.ErrorBar')
            safe_set(params, child, 'LineWidth', actual_plot_lw*0.8, 'MarkerSize', ms*0.8, 'CapSize', actual_plot_lw*params.errorbar_cap_size_scale*6);
            if ~isempty(current_color_to_apply); safe_set(params, child,'Color',current_color_to_apply); end
            if ~strcmpi(current_marker_style_name, 'none'); safe_set(params, child, 'Marker', current_marker_style_name); end
        
        elseif isa(child,'matlab.graphics.primitive.Surface') || ...
               isa(child,'matlab.graphics.chart.primitive.Surface') || ...
               isa(child,'matlab.graphics.primitive.Patch')
            safe_set(params, child, 'EdgeColor', params.axis_color*0.6, 'LineWidth', alw*0.7);
            % FaceColor for these is often colormap-driven, so typically not set here unless specific params exist
        end
    catch ME_child
        child_tag_disp = ''; if isprop(child,'Tag'); child_tag_disp = child.Tag; end
        log_message(params, sprintf('Error processing child object (Type: %s, Tag: %s): %s', class(child), child_tag_disp, ME_child.message), 1, 'Warning');
    end
end

if params.legend_reverse_order && ~isempty(plottable_children_for_legend)
    plottable_children_for_legend = flipud(plottable_children_for_legend); 
end

% --- Beautify General Text Objects in Axes ---
if params.apply_to_general_text
    try; text_children = findobj(ax, 'Type', 'text', '-depth', 1); catch; text_children = []; end
    for k_text = 1:length(text_children)
        txt_obj=text_children(k_text); 
        if ~isvalid(txt_obj); continue; end
        
        is_label_or_title_or_legend_text = false;
        if isprop(txt_obj,'Tag')
            tag_str = txt_obj.Tag;
            is_label_or_title_or_legend_text = any(strcmp(tag_str, {'XLabel','YLabel','ZLabel','Title'}));
        end
        try % Check if text is part of a legend
            parent_obj = get(txt_obj,'Parent');
            if isa(parent_obj,'matlab.graphics.illustration.Legend') || ...
               (isprop(parent_obj, 'Parent') && isa(get(parent_obj,'Parent'),'matlab.graphics.illustration.Legend')) % Text inside legend entry
                is_label_or_title_or_legend_text = true;
            end
        catch
            % Issue getting parent, assume not legend text for safety
        end
        
        if ~is_label_or_title_or_legend_text && ~strcmp(txt_obj.Tag, 'BeautifyFig_StatsOverlay') % Don't re-process stats overlay text
            % For general text, use scaled base font size 'fs', and preserve its existing weight/color unless overridden by params
            current_text_color = txt_obj.Color;
            if isequal(current_text_color, base_defaults.text_color) || isempty(current_text_color) % If it was default or empty, apply new theme text color
                current_text_color = params.text_color;
            end
            process_text_prop(txt_obj, txt_obj.String, fs, txt_obj.FontWeight, current_text_color, params.font_name, params);
        end
    end
end

% --- Handle Legend ---
beautify_legend(ax, params, plottable_children_for_legend, fs, alw);

% --- Handle Colorbar ---
if params.apply_to_colorbars; beautify_colorbar(ax, params, fs, lfs, alw); end

% --- Apply 3D View Preset ---
if isprop(ax, 'View') && ~isempty(params.view_preset_3d) && ~strcmpi(params.view_preset_3d, 'none')
    % Check if axes is meaningfully 3D (e.g., ZLim has a span, or ZLabel has text)
    % This is a heuristic; user might want to apply view to a 2D plot in a 3D axes.
    is_intended_3d = false;
    if diff(get(ax,'ZLim')) > 1e-9; is_intended_3d = true; end
    if isprop(ax, 'ZLabel') && isvalid(ax.ZLabel) && ~isempty(ax.ZLabel.String); is_intended_3d = true; end
    
    if ~is_intended_3d && isa(ax, 'matlab.graphics.axis.Axes') % Only log for standard Axes
        log_message(params, sprintf('Axes (Tag: %s) appears 2D. Applying 3D view preset "%s" might be unexpected but will proceed.', ax.Tag, params.view_preset_3d), 2, 'Info');
    end

    current_view_preset = lower(params.view_preset_3d);
    log_message(params, sprintf('Applying 3D view preset "%s" to Axes (Tag: %s).', current_view_preset, ax.Tag), 2, 'Info');
    try
        switch current_view_preset
            case 'iso'; view(ax, 3); % Standard MATLAB isometric view
            case 'top'; view(ax, 0, 90);
            case 'front'; view(ax, 0, 0);
            case 'side_left'; view(ax, -90, 0);
            case 'side_right'; view(ax, 90, 0);
            otherwise
                log_message(params, sprintf('Unknown 3D view preset: "%s". No view change applied.', params.view_preset_3d), 1, 'Warning');
        end
    catch ME_view
        log_message(params, sprintf('Error applying 3D view preset "%s": %s', params.view_preset_3d, ME_view.message), 1, 'Warning');
    end
end

% Apply Basic Statistical Overlay
if params.stats_overlay.enabled && isa(ax, 'matlab.graphics.axis.Axes') % Stats overlay usually for Cartesian axes
   try
       apply_stats_overlay(ax, params, scale_factor);
   catch ME_stats_overlay
       log_message(params, sprintf('Error applying stats overlay to Axes (Tag: %s): %s (Line: %d)', ax.Tag, ME_stats_overlay.message, ME_stats_overlay.stack(1).line), 1, 'Warning');
   end
end

if ~current_hold_state; safe_hold(params, ax, 'off'); end
end

% --- Helper Function: Check if an object is a legend candidate ---
function is_candidate = is_legend_candidate_check(obj_handle)
is_candidate = false;
if ~isvalid(obj_handle) || ~isprop(obj_handle,'Visible') || ~strcmpi(get(obj_handle, 'Visible'), 'on'); return; end

% Check for common plottable types that usually appear in legends
is_plottype = isa(obj_handle, 'matlab.graphics.chart.primitive.Line') || ...
              isa(obj_handle, 'matlab.graphics.chart.primitive.Scatter') || ...
              isa(obj_handle, 'matlab.graphics.chart.primitive.Bar') || ...
              isa(obj_handle, 'matlab.graphics.chart.primitive.Stair') || ...
              isa(obj_handle, 'matlab.graphics.chart.primitive.Area') || ...
              isa(obj_handle, 'matlab.graphics.chart.primitive.ErrorBar') || ...
              isa(obj_handle, 'matlab.graphics.primitive.Patch') || ... % Patches can have DisplayName
              isa(obj_handle, 'matlab.graphics.primitive.Surface'); % Surfaces too

if ~is_plottype; return; end

% Check for DisplayName (primary method) or Annotation (older method)
try
    if isprop(obj_handle,'DisplayName') && ~isempty(get(obj_handle, 'DisplayName'))
        is_candidate = true;
        return; % Found DisplayName, it's a candidate
    end
    
    if isprop(obj_handle, 'Annotation') && ...
       isprop(obj_handle.Annotation, 'LegendInformation') && ...
       isprop(obj_handle.Annotation.LegendInformation, 'IconDisplayStyle') && ...
       strcmpi(obj_handle.Annotation.LegendInformation.IconDisplayStyle, 'on')
        is_candidate = true;
    end
catch ME_leg_check
    % Property access failed, assume not a candidate or log if necessary
    % For now, suppress error and return false
    % log_message(params, sprintf('Error checking legend candidacy for object of type %s: %s', class(obj_handle), ME_leg_check.message), 2, 'Debug');
end
end

% --- Helper Function: Beautify Legend ---
function beautify_legend(ax, params, plottable_children_for_legend, fs, alw)
try
    existing_legend = []; 
    % Modern MATLAB (R2017a+) uses Legend property on Axes
    if isprop(ax, 'Legend') && isa(ax.Legend, 'matlab.graphics.illustration.Legend') && isvalid(ax.Legend)
        existing_legend = ax.Legend;
    end

    % Fallback for older MATLAB or cases where Legend property might not be populated
    if isempty(existing_legend)
        fig_handle = ancestor(ax, 'figure');
        if isvalid(fig_handle)
            all_legends_in_fig = findobj(fig_handle, 'Type','Legend');
            for k_leg = 1:numel(all_legends_in_fig)
                current_lgd = all_legends_in_fig(k_leg);
                associated_axes = [];
                if isprop(current_lgd, 'Axes') % R2022a+
                    associated_axes = current_lgd.Axes;
                elseif isprop(current_lgd, 'Axle') && isprop(current_lgd.Axle, 'Peer') % Older versions
                    associated_axes = current_lgd.Axle.Peer;
                end
                if isequal(associated_axes, ax)
                    existing_legend = current_lgd;
                    break;
                end
            end
        end
    end
    
    num_actual_legend_entries = numel(plottable_children_for_legend);
    should_show_legend = false;

    if strcmpi(params.legend_location,'none')
        if ~isempty(existing_legend) && isvalid(existing_legend); safe_set(params, existing_legend,'Visible','off');end
    else
        if params.smart_legend_display
            if num_actual_legend_entries > 1
                should_show_legend = true; % Will use existing or create if needed
            elseif num_actual_legend_entries == 1 && params.legend_force_single_entry
                should_show_legend = true; % Create new or use existing
            else % 0 entries, or 1 entry not forced
                if ~isempty(existing_legend) && isvalid(existing_legend); safe_set(params, existing_legend,'Visible','off'); end
            end
        else % Not smart display: create/show if items exist (respecting force_single_entry)
            if num_actual_legend_entries > 0
                if num_actual_legend_entries == 1 && ~params.legend_force_single_entry
                    if ~isempty(existing_legend) && isvalid(existing_legend); safe_set(params, existing_legend,'Visible','off'); end
                else
                    should_show_legend = true;
                end
            else % 0 entries
                 if ~isempty(existing_legend) && isvalid(existing_legend); safe_set(params, existing_legend,'Visible','off'); end
            end
        end
    end

    leg_handle_to_use = [];
    if should_show_legend
        if ~isempty(existing_legend) && isvalid(existing_legend)
            leg_handle_to_use = existing_legend;
            log_message(params,sprintf('  Updating existing legend for Axes (Tag: %s).',ax.Tag),2,'Info');
        else % Create new legend if no valid one exists and we decided to show one
            if ~isempty(plottable_children_for_legend)
                valid_plot_children_for_leg_creation = plottable_children_for_legend(arrayfun(@(h) isvalid(h) && is_legend_candidate_check(h), plottable_children_for_legend));
                if ~isempty(valid_plot_children_for_leg_creation)
                    try
                        leg_handle_to_use = legend(ax, valid_plot_children_for_leg_creation); 
                        log_message(params,sprintf('  Created new legend for Axes (Tag: %s).',ax.Tag),2,'Info');
                    catch ME_leg_create
                        log_message(params,sprintf('  Could not create legend for Axes (Tag: %s): %s',ax.Tag,ME_leg_create.message),1,'Warning');
                    end
                else
                    log_message(params,sprintf('  No valid plot children with display names found to create legend for Axes (Tag: %s).', ax.Tag),2,'Info');
                end
            end
        end
    end

    if ~isempty(leg_handle_to_use) && isvalid(leg_handle_to_use)
        leg_props.FontSize = round(fs*0.93); 
        leg_props.LineWidth = alw*0.85;
        leg_props.TextColor = params.text_color; 
        leg_props.EdgeColor = params.axis_color*0.85; 
        leg_props.FontName = params.font_name;
        leg_props.Visible = 'on'; 
        leg_props.Location = params.legend_location;
        
        if strcmpi(params.axis_box_style,'off') || strcmpi(params.axis_box_style,'left-bottom')
            leg_props.Box = 'off';
        else
            leg_props.Box = 'on'; % Match axis box style 'on'
        end

        if params.legend_num_columns > 0 && isprop(leg_handle_to_use,'NumColumns')
            leg_props.NumColumns = params.legend_num_columns; 
        end

        current_interpreter = 'tex'; 
        if isprop(leg_handle_to_use, 'Interpreter') && isprop(leg_handle_to_use, 'String')
            legend_strings = leg_handle_to_use.String;
            if ~iscell(legend_strings); legend_strings = {legend_strings}; end 

            use_latex_for_legend_strings = false;
            if params.auto_latex_interpreter_for_labels 
                for k_str = 1:numel(legend_strings) 
                    if ~isempty(legend_strings{k_str}) && contains_latex_chars(legend_strings{k_str}, params)
                        use_latex_for_legend_strings = true;
                        break;
                    end
                end
            end
            if use_latex_for_legend_strings; current_interpreter = 'latex'; end
            leg_props.Interpreter = current_interpreter;
        end

        if isprop(leg_handle_to_use,'Title') && isvalid(leg_handle_to_use.Title)
            if ~isempty(params.legend_title_string)
                safe_set(params, leg_handle_to_use.Title, 'String', params.legend_title_string, 'Visible', 'on');
                process_text_prop(leg_handle_to_use.Title,params.legend_title_string,round(leg_props.FontSize*1.05),'bold',params.text_color,params.font_name,params);
            else
                safe_set(params, leg_handle_to_use.Title, 'String', '', 'Visible', 'off'); 
            end
        end
        safe_set(params, leg_handle_to_use, leg_props);

        if params.interactive_legend && isprop(leg_handle_to_use, 'ItemHitFcn') && verLessThan('matlab','9.7') == 0 % R2019b+
            try
                if ~isempty(leg_handle_to_use.ItemHitFcn); leg_handle_to_use.ItemHitFcn=''; end % Clear previous
                leg_handle_to_use.ItemHitFcn = @(src,evt)toggle_plot_visibility_adv(src,evt,params);
                
                % Initialize appdata for visibility states
                if ~isappdata(leg_handle_to_use,'OriginalVisibilityStates') && ...
                   isprop(leg_handle_to_use,'PlotChildren') && ~isempty(leg_handle_to_use.PlotChildren)
                    
                    valid_legend_plot_children = leg_handle_to_use.PlotChildren(arrayfun(@isvalid, leg_handle_to_use.PlotChildren));
                    if ~isempty(valid_legend_plot_children)
                        orig_vis = arrayfun(@(h)get(h,'Visible'), valid_legend_plot_children,'UniformOutput',false);
                        setappdata(leg_handle_to_use,'OriginalVisibilityStates',orig_vis);
                        setappdata(leg_handle_to_use,'IsolationModeActive',false);
                    end
                end
                log_message(params,sprintf('  Interactive legend enabled for Axes (Tag: %s).',ax.Tag),2,'Info');
            catch ME_leg_int
                log_message(params,sprintf('Could not set interactive legend: %s',ME_leg_int.message),1,'Warning');
            end
        elseif params.interactive_legend && verLessThan('matlab','9.7') == 1
            log_message(params, 'Interactive legend (ItemHitFcn) requires MATLAB R2019b or newer.', 1, 'Info');
        end
        % After setting properties, update appearance based on visibility
        update_legend_item_appearance(leg_handle_to_use, params);
    end
catch ME_legend
    log_message(params, sprintf('Error processing legend for Axes (Tag: %s): %s (Line: %d)', ax.Tag, ME_legend.message, ME_legend.stack(1).line), 1, 'Warning');
end
end

% --- Helper Function: Beautify Colorbar ---
function beautify_colorbar(ax, params, fs, lfs, alw)
try
    cb=[]; fig_handle=ancestor(ax,'figure');
    if ~isvalid(fig_handle); return; end

    % Modern way: Axes has a Colorbar property (R2014b+)
    if isprop(ax, 'Colorbar') && isa(ax.Colorbar, 'matlab.graphics.illustration.ColorBar') && isvalid(ax.Colorbar)
        cb = ax.Colorbar;
    else % Fallback: find colorbars in figure and check association
        all_colorbars_in_fig = findobj(fig_handle,'Type','colorbar');
        for cb_idx=1:length(all_colorbars_in_fig)
            current_cb_candidate = all_colorbars_in_fig(cb_idx); 
            if ~isvalid(current_cb_candidate); continue; end
            
            cb_associated_ax = [];
            if isprop(current_cb_candidate,'Axes'); % R2022a+
                cb_associated_ax = current_cb_candidate.Axes;
            elseif isprop(current_cb_candidate,'Axle') && isprop(current_cb_candidate.Axle,'Peer') % Older
                cb_associated_ax = current_cb_candidate.Axle.Peer;
            end
            
            if isequal(cb_associated_ax, ax)
                cb = current_cb_candidate; 
                break; 
            end
        end
    end

    if ~isempty(cb) && isvalid(cb)
        cb_to_style = cb(1); % Should only be one per axes
        safe_set(params, cb_to_style, 'FontSize', round(fs*0.9), 'LineWidth', alw*0.85, 'Color', params.axis_color, 'TickDirection', 'out', 'FontName', params.font_name);
        if isprop(cb_to_style,'Label') && isvalid(cb_to_style.Label)
            process_text_prop(cb_to_style.Label,cb_to_style.Label.String,lfs,'normal',params.text_color,params.font_name,params);
        end
    end
catch ME_colorbar
    log_message(params, sprintf('Error processing colorbar for Axes (Tag: %s): %s', ax.Tag, ME_colorbar.message), 1, 'Warning');
end
end

% --- Helper Function: Process Text Properties (Title, Labels, etc.) ---
function process_text_prop(text_handle, original_str, font_size, font_weight, color, font_name, params, force_latex_off_for_this)
if nargin < 8; force_latex_off_for_this = false; end
if isempty(text_handle) || ~isvalid(text_handle); return; end

try
    fixed_str = format_text_string(original_str); % Handles cell arrays of strings
    is_truly_empty = false;
    if ischar(original_str) && isempty(original_str); is_truly_empty = true;
    elseif iscell(original_str) && (isempty(original_str) || all(cellfun('isempty',original_str))); is_truly_empty = true;
    elseif isstring(original_str) && (isscalar(original_str) && strlength(original_str)==0 || isempty(original_str)); is_truly_empty = true;
    end

    if isempty(fixed_str) && is_truly_empty % If the original string was truly empty
        if isprop(text_handle,'Visible'); safe_set(params, text_handle,'Visible','off'); end
        return;
    else
        if isprop(text_handle,'Visible'); safe_set(params, text_handle,'Visible','on'); end
    end

    safe_set(params, text_handle,'String',fixed_str,'FontName',font_name,'FontSize',max(1,font_size),'FontWeight',font_weight,'Color',color);
    if isprop(text_handle,'Interpreter')
        should_use_latex = false;
        if ~force_latex_off_for_this && params.auto_latex_interpreter_for_labels
            if contains_latex_chars(fixed_str, params)
                should_use_latex = true;
            end
        end
        if should_use_latex
            safe_set(params, text_handle, 'Interpreter', 'latex');
        else
            safe_set(params, text_handle, 'Interpreter', 'tex');
        end
    end
catch ME_text_prop
    str_preview = char(original_str); if length(str_preview) > 30; str_preview = [str_preview(1:27) '...']; end
    log_message(params, sprintf('Error setting text property (String: "%s"): %s', str_preview, ME_text_prop.message), 1, 'Warning');
end
end

% --- Helper Function: Check if String Contains LaTeX Characters ---
function tf = contains_latex_chars(str_in, params)
tf = false;
if isempty(str_in) || (~ischar(str_in) && ~isstring(str_in) && ~iscell(str_in)); return; end

% Convert to single char string for checking
if iscell(str_in)
    str_in_char = strjoin(str_in(~cellfun('isempty',str_in)),' '); % Join non-empty cells
else
    str_in_char = char(str_in); % Converts string scalar/array to char
    if size(str_in_char,1) > 1 % If it was a column vector of chars or string array
        str_in_char = strjoin(cellstr(str_in_char), ' ');
    end
end
if isempty(str_in_char); return; end

% Basic LaTeX characters
latex_patterns = {'\', '_', '^'}; 
tf = any(arrayfun(@(p)contains(str_in_char,p), latex_patterns));
if tf; return; end % Found basic LaTeX char

% Check for \command or \symbol (e.g., \alpha, \neq)
if contains(str_in_char, '\')
    if ~isempty(regexp(str_in_char, '\\[a-zA-Z]+', 'once')); tf = true; return; end % \ followed by letters
    if ~isempty(regexp(str_in_char, '\\[^a-zA-Z0-9\s]', 'once')); tf = true; return; end % \ followed by non-alphanumeric, non-space symbol
end

% Check for $...$ or $$...$$ if forced
if params.force_latex_if_dollar_present
    if contains(str_in_char, '$') % Simpler check, might need refinement for escaped $
        % A more robust check for unescaped $ pairs:
        if ~isempty(regexp(str_in_char, '(?<!\\)\$.*?(?<!\\)\$', 'once')) % $...$ not preceded by \
           tf = true;
        end
    end
end
end

% --- Helper Function: Format Multi-line/Cell Strings ---
function fixed_str = format_text_string(original_str)
if iscell(original_str)
    non_empty_cells = original_str(~cellfun('isempty',original_str));
    if isempty(non_empty_cells)
        fixed_str = '';
    else
        fixed_str = strjoin(non_empty_cells,'\newline');
    end
elseif isstring(original_str) % Handle MATLAB string type
    if isempty(original_str) || all(strlength(original_str)==0) % Empty string array or all elements are ""
        fixed_str = '';
    else
        fixed_str_cell = cellstr(original_str); % Convert to cell array of char vectors
        fixed_str = strjoin(fixed_str_cell, '\newline'); % Join with newline
    end
else % char array or other
    fixed_str = original_str;
end
end

% --- Helper Function: Expand Axis Limits ---
function expand_axis_lims(ax,limit_prop_name,factor, params)
try
    current_lim = get(ax,limit_prop_name);
    if diff(current_lim) < 1e-9 || ~all(isfinite(current_lim)); return; end 

    scale_prop_name = [limit_prop_name(1) 'Scale']; is_log = false;
    if isprop(ax,scale_prop_name) && strcmpi(get(ax,scale_prop_name),'log')
        is_log = true;
    end

    if is_log
        if all(current_lim > 0) % Log scale only works for positive limits
            log_lim = log10(current_lim);
            range = diff(log_lim);
            if abs(range) < 1e-9; range = abs(log_lim(1))*0.1 + 1e-9; end % Handle very small/zero log range
            
            new_lim_log = [log_lim(1) - range*factor, log_lim(2) + range*factor];
            new_lim = 10.^new_lim_log;
            
            % Prevent lower limit from becoming zero or negative on log scale
            if new_lim(1) <= 0
                new_lim(1) = current_lim(1) * (1 - factor*0.8); % Be more conservative
                if new_lim(1) <= 0; new_lim(1) = min(current_lim(current_lim>0))/2; end % Fallback
                if new_lim(1) <= 0; new_lim(1) = eps(class(current_lim(1))); end % Ultimate fallback
            end
        else
            log_message(params, sprintf('Cannot expand log-scaled %s for Axes (Tag: %s) because limits are not all positive. Limits: [%s].', limit_prop_name, ax.Tag, num2str(current_lim)), 2, 'Warning');
            return;
        end
    else % Linear scale
        range = diff(current_lim);
        if abs(range) < 1e-9; range = abs(current_lim(1))*0.1 + 1e-9; end % Handle very small/zero linear range
        
        new_lim = [current_lim(1) - range*factor, current_lim(2) + range*factor];
        
        % Prevent crossing zero if original limit was at zero
        if abs(current_lim(1)) < 1e-9 && new_lim(1) < 0; new_lim(1) = 0; end
        if abs(current_lim(2)) < 1e-9 && new_lim(2) > 0; new_lim(2) = 0; end
    end
    
    if all(isfinite(new_lim)) && new_lim(2) > new_lim(1)
        safe_set(params, ax,limit_prop_name,new_lim);
    end

catch ME_expand
    log_message(params, sprintf('Failed to expand axis limits for %s on Axes (Tag: %s): %s. Limits remain unchanged.', limit_prop_name, ax.Tag, ME_expand.message), 2, 'Warning');
end
end

% --- Helper Function: Check for Geographic Axes ---
function tf = isgeoaxes(ax)
    tf = isa(ax,'matlab.graphics.axis.GeographicAxes') || ...
         (isprop(ax,'Type') && strcmp(ax.Type,'geoaxes')); % Older check
end

% --- Helper Function: Advanced Interactive Legend Callback ---
function toggle_plot_visibility_adv(legend_handle,event_data,params)
try
    clicked_plot_object = event_data.Peer;
    if ~isvalid(clicked_plot_object); return; end
    
    fig_handle = ancestor(legend_handle,'figure');
    modifier_keys = get(fig_handle,'CurrentModifier');
    is_ctrl_cmd_pressed = any(strcmpi(modifier_keys,'control')) || any(strcmpi(modifier_keys,'command'));

    all_legend_plots = [];
    if isprop(legend_handle,'PlotChildren')
        all_legend_plots = legend_handle.PlotChildren(arrayfun(@isvalid, legend_handle.PlotChildren)); 
    end
    if isempty(all_legend_plots)
        log_message(params,'Interactive legend: No valid PlotChildren found.',1,'Warning');
        return;
    end

    original_vis_states = getappdata(legend_handle,'OriginalVisibilityStates');
    isolation_active = getappdata(legend_handle,'IsolationModeActive');
    if isempty(isolation_active); isolation_active = false; end % Initialize if not present

    if is_ctrl_cmd_pressed % Isolate or unisolate logic
        is_currently_isolated_object = false;
        if isolation_active && isappdata(legend_handle, 'IsolatedObject')
            is_currently_isolated_object = (getappdata(legend_handle,'IsolatedObject') == clicked_plot_object);
        end

        if is_currently_isolated_object % Clicked on the already isolated object with Ctrl/Cmd -> unisolate
            for k=1:length(all_legend_plots)
                if k <= length(original_vis_states); safe_set(params, all_legend_plots(k),'Visible',original_vis_states{k}); end
            end
            setappdata(legend_handle,'IsolationModeActive',false);
            if isappdata(legend_handle,'IsolatedObject'); rmappdata(legend_handle,'IsolatedObject'); end
            log_message(params,'Legend: Isolation mode deactivated.',2,'Info');
        else % Isolate this new object (or re-isolate if different)
            for k=1:length(all_legend_plots)
                if all_legend_plots(k) == clicked_plot_object
                    safe_set(params, all_legend_plots(k),'Visible','on');
                else
                    safe_set(params, all_legend_plots(k),'Visible','off');
                end
            end
            setappdata(legend_handle,'IsolationModeActive',true);
            setappdata(legend_handle,'IsolatedObject',clicked_plot_object);
            obj_disp_name = ''; if isprop(clicked_plot_object,'DisplayName'); obj_disp_name = get(clicked_plot_object,'DisplayName'); end
            log_message(params,sprintf('Legend: Object "%s" isolated.',obj_disp_name),2,'Info');
        end
    else % Normal click (no Ctrl/Cmd) -> toggle visibility
        if isolation_active % If something was isolated, first unisolate everything
            for k=1:length(all_legend_plots)
                if k <= length(original_vis_states); safe_set(params, all_legend_plots(k),'Visible',original_vis_states{k}); end
            end
            setappdata(legend_handle,'IsolationModeActive',false);
            if isappdata(legend_handle,'IsolatedObject'); rmappdata(legend_handle,'IsolatedObject'); end
            log_message(params,'Legend: Isolation mode deactivated by normal click.',2,'Info');
        end
        
        % Then, toggle the clicked plot object
        current_visibility = get(clicked_plot_object,'Visible');
        if strcmpi(current_visibility,'on')
            safe_set(params, clicked_plot_object,'Visible','off');
        else
            safe_set(params, clicked_plot_object,'Visible','on');
        end
        
        % Update original_vis_states if not in isolation mode when click happened
        % This ensures the "original" state reflects user toggles made outside isolation.
        if ~isempty(original_vis_states)
            idx = find(all_legend_plots == clicked_plot_object, 1);
            if ~isempty(idx) && idx <= length(original_vis_states)
                original_vis_states{idx} = get(clicked_plot_object,'Visible');
                setappdata(legend_handle,'OriginalVisibilityStates',original_vis_states);
            end
        end
    end
    update_legend_item_appearance(legend_handle, params);
catch ME_interactive_leg
    log_message(params, sprintf('Error in interactive legend callback: %s', ME_interactive_leg.message), 1, 'Warning');
end
end

% --- Helper Function: Update Legend Item Appearance (Fade/Unfade) ---
function update_legend_item_appearance(legend_handle,params)
try
    if ~isprop(legend_handle,'PlotChildren') || isempty(legend_handle.PlotChildren) || ...
       ~isprop(legend_handle,'EntryContainer') || ~isprop(legend_handle.EntryContainer,'Children')
        return;
    end

    plot_objects = legend_handle.PlotChildren(arrayfun(@isvalid, legend_handle.PlotChildren));
    legend_entries_raw = legend_handle.EntryContainer.Children;
    legend_entries = legend_entries_raw(arrayfun(@isvalid, legend_entries_raw)); % Filter valid entries

    num_to_process = min(length(plot_objects),length(legend_entries));

    default_text_color_struct = params.text_color; 
    faded_text_color_struct = default_text_color_struct*0.4 + 0.5; % Make it grayish

    for i=1:num_to_process
        entry = legend_entries(i);
        corresponding_plot = plot_objects(i);
        if ~isvalid(entry) || ~isvalid(corresponding_plot); continue; end

        is_plot_visible = strcmpi(get(corresponding_plot,'Visible'),'on');

        % Update text label appearance
        if isprop(entry,'Label') && isprop(entry.Label,'Color') && isvalid(entry.Label)
            if is_plot_visible
                safe_set(params, entry.Label,'Color', default_text_color_struct);
            else
                safe_set(params, entry.Label,'Color', faded_text_color_struct);
            end
        end

        % Update icon appearance (more complex)
        if isprop(entry,'Icon') && isprop(entry.Icon,'Children') && isvalid(entry.Icon)
            icon_parts = entry.Icon.Children(arrayfun(@isvalid, entry.Icon.Children));
            for ip_idx = 1:length(icon_parts)
                part = icon_parts(ip_idx);
                if ~isvalid(part); continue; end

                original_plot_color = []; % Attempt to get base color from the plot object
                alpha_val = 1.0; if ~is_plot_visible; alpha_val = 0.3; end

                if isa(part, 'matlab.graphics.primitive.Line') % Line in icon
                    if isprop(corresponding_plot, 'Color') && ~ischar(corresponding_plot.Color)
                        original_plot_color = corresponding_plot.Color;
                    end
                    if ~isempty(original_plot_color); safe_set(params, part, 'Color', original_plot_color); end
                    if isprop(part, 'ColorAlpha'); safe_set(params, part, 'ColorAlpha', alpha_val); % R2022a+
                    elseif ~is_plot_visible && ~isempty(original_plot_color) % Fallback for older MATLAB if no ColorAlpha
                        safe_set(params, part, 'Color', original_plot_color*0.6 + 0.4); % Blend with gray
                    end
                elseif isa(part, 'matlab.graphics.primitive.Patch') % Marker face/edge in icon
                    % Try to determine if it's a face or edge part of the icon
                    % This is heuristic; icon structure can be complex
                    is_face_like = isprop(part, 'FaceColor') && ~strcmpi(part.FaceColor, 'none');
                    is_edge_like = isprop(part, 'EdgeColor') && ~strcmpi(part.EdgeColor, 'none');

                    if is_face_like && isprop(corresponding_plot, 'MarkerFaceColor') && ...
                       ~ischar(corresponding_plot.MarkerFaceColor) && ~strcmpi(corresponding_plot.MarkerFaceColor,'none')
                        original_plot_color = corresponding_plot.MarkerFaceColor;
                    elseif is_edge_like && isprop(corresponding_plot, 'MarkerEdgeColor') && ...
                           ~ischar(corresponding_plot.MarkerEdgeColor) && ~strcmpi(corresponding_plot.MarkerEdgeColor,'none')
                        original_plot_color = corresponding_plot.MarkerEdgeColor;
                    elseif isprop(corresponding_plot, 'Color')  % Fallback to line color if scatter/line
                         original_plot_color = corresponding_plot.Color;
                    end
                    
                    if isempty(original_plot_color); original_plot_color = params.axis_color; end % Default fallback

                    if is_face_like
                        safe_set(params, part, 'FaceColor', original_plot_color);
                        if isprop(part, 'FaceAlpha'); safe_set(params, part, 'FaceAlpha', alpha_val); end
                    end
                    if is_edge_like
                        safe_set(params, part, 'EdgeColor', original_plot_color*0.7); % Darker edge
                        if isprop(part, 'EdgeAlpha'); safe_set(params, part, 'EdgeAlpha', alpha_val); end
                    end
                     % Fallback for older MATLAB if no alpha properties
                    if ~is_plot_visible && ~isprop(part,'FaceAlpha') && ~isprop(part,'EdgeAlpha')
                        if is_face_like; safe_set(params, part, 'FaceColor', original_plot_color*0.6 + 0.4); end
                        if is_edge_like; safe_set(params, part, 'EdgeColor', (original_plot_color*0.7)*0.6 + 0.4); end
                    end
                end
                if isprop(part, 'Visible'); safe_set(params, part, 'Visible', 'on'); end % Ensure icon part itself is visible
            end
        end
    end
catch ME_leg_appearance
    log_message(params, sprintf('Error updating legend item appearance: %s (Line: %d)', ME_leg_appearance.message, ME_leg_appearance.stack(1).line),1,'Warning');
end
end

% --- Helper Function: Safely Set Graphics Property ---
function safe_set(params_for_log, handle_in, varargin)
try
    if ~isvalid(handle_in); return; end % Early exit if handle is invalid
    
    props_to_set = struct();
    for i = 1:2:length(varargin)
        prop_name = varargin{i};
        new_val = varargin{i+1};
        if isprop(handle_in, prop_name)
            current_val = get(handle_in, prop_name);
            if ~isequal(current_val, new_val) % Only set if different
                props_to_set.(prop_name) = new_val;
            end
        else
             % Log attempt to set non-existent property at a debug level if desired
             % log_message(params_for_log, sprintf('Property "%s" does not exist for handle of type "%s".', prop_name, class(handle_in)), 2, 'Debug');
        end
    end
    if ~isempty(fieldnames(props_to_set)) % If there's anything to set
        set(handle_in, props_to_set);
    end
catch ME_set
    prop_name_for_log_msg = 'multiple properties'; 
    try % Try to get a specific property name if error was in loop (less likely now)
        if exist('prop_name','var'); prop_name_for_log_msg = prop_name; end
    catch; end
    
    log_message(params_for_log, sprintf('safe_set failed for property "%s" on handle of type "%s" (Tag: %s): %s', ...
        prop_name_for_log_msg, class(handle_in), handle_in.Tag, ME_set.message), 2, 'Debug');
end
end

% --- Helper Function: Safely Hold Axes ---
function safe_hold(params_for_log, ax_handle, state)
try
    if isvalid(ax_handle) && isprop(ax_handle, 'NextPlot')
        current_nextplot = get(ax_handle, 'NextPlot');
        target_nextplot = '';
        if strcmpi(state, 'on'); target_nextplot = 'add';
        elseif strcmpi(state, 'off'); target_nextplot = 'replace'; end
        
        if ~isempty(target_nextplot) && ~strcmpi(current_nextplot, target_nextplot)
            set(ax_handle, 'NextPlot', target_nextplot);
        end
    end
catch ME_hold
    log_message(params_for_log, sprintf('safe_hold failed for state "%s" on handle of type "%s" (Tag: %s): %s', ...
        state, class(ax_handle), ax_handle.Tag, ME_hold.message), 2, 'Debug');
end
end

% --- Helper Function: Log Message ---
function log_message(params_struct_or_base_defaults, message_str, level, type_str)
    if nargin < 4; type_str = 'Info'; end 
    
    current_log_level = 0; % Default to silent if log_level field is missing
    if isstruct(params_struct_or_base_defaults) && isfield(params_struct_or_base_defaults, 'log_level')
        log_level_val = params_struct_or_base_defaults.log_level;
        if isnumeric(log_level_val) && isscalar(log_level_val)
            current_log_level = log_level_val;
        end
    end
    
    if current_log_level >= level
        fprintf('[BeautifyFig - %s L%d] %s\n', type_str, level, message_str);
    end
end

% --- Helper Function: Convert Number to Roman Numeral String ---
function str = local_roman_numeral(n_in) % Renamed input arg
    if ~isnumeric(n_in) || ~isscalar(n_in) || n_in <= 0 || n_in >= 4000 || floor(n_in) ~= n_in
        str = num2str(n_in); % Fallback for invalid input
        return;
    end
    map_values = [1000, 900, 500, 400, 100, 90, 50, 40, 10, 9, 5, 4, 1];
    map_symbols = {'M', 'CM', 'D', 'CD', 'C', 'XC', 'L', 'XL', 'X', 'IX', 'V', 'IV', 'I'};
    str = '';
    for i_roman = 1:length(map_values)
        while n_in >= map_values(i_roman)
            str = [str, map_symbols{i_roman}]; %#ok<AGROW>
            n_in = n_in - map_values(i_roman);
        end
    end
end

% --- Helper Function: Apply Stats Overlay ---
function apply_stats_overlay(ax, params, scale_factor)
    so_params = params.stats_overlay;
    
    target_plot_obj = [];
    ax_children = get(ax, 'Children');
    
    if ~isempty(so_params.target_plot_handle_tag)
        for i = 1:length(ax_children)
            child = ax_children(i);
            % Check direct child or children of a group (e.g., hggroup for boxplot)
            if isprop(child,'Tag') && strcmp(get(child,'Tag'), so_params.target_plot_handle_tag) && ...
               (isa(child, 'matlab.graphics.chart.primitive.Line') || isa(child, 'matlab.graphics.chart.primitive.Scatter'))
                target_plot_obj = child; break;
            elseif isa(child, 'matlab.graphics.primitive.Group') % e.g. hggroup
                potential_matches_in_group = findobj(child, 'Type',{'line','scatter'},'Tag', so_params.target_plot_handle_tag, '-depth', Inf); % Search within group
                if ~isempty(potential_matches_in_group)
                    target_plot_obj = potential_matches_in_group(1); break;
                end
            end
        end
        if isempty(target_plot_obj)
             log_message(params, sprintf('Stats Overlay: No plot found with tag "%s" in current axes.', so_params.target_plot_handle_tag), 2, 'Info'); return;
        end
    else % Tag is empty, find first suitable plot
        for i = 1:length(ax_children)
            child = ax_children(i);
            if (isa(child, 'matlab.graphics.chart.primitive.Line') || ...
                isa(child, 'matlab.graphics.chart.primitive.Scatter')) && ...
               isprop(child, 'YData') && ~isempty(child.YData) && ...
               isprop(child, 'Visible') && strcmp(get(child,'Visible'),'on')
                target_plot_obj = child; break;
            end
        end
        if isempty(target_plot_obj)
            log_message(params, 'Stats Overlay: No suitable (Line/Scatter, visible, YData) plot found in current axes.', 2, 'Info'); return;
        end
    end

    if ~isprop(target_plot_obj, 'YData') % Should have YData based on above checks, but good to be safe
        log_message(params, 'Stats Overlay: Target plot object does not have YData.', 2, 'Info'); return;
    end
    y_data_raw = get(target_plot_obj, 'YData');
    if isempty(y_data_raw) || ~isnumeric(y_data_raw)
        log_message(params, 'Stats Overlay: YData is empty or non-numeric.', 2, 'Info'); return;
    end
    y_data = y_data_raw(isfinite(y_data_raw(:))); % Ensure column vector and finite
    if isempty(y_data)
        log_message(params, 'Stats Overlay: No finite YData available for statistics.', 2, 'Info'); return;
    end

    stats_str_lines = cell(1,0); % Initialize as row cell
    for i_stat = 1:length(so_params.statistics)
        stat_name = lower(so_params.statistics{i_stat});
        val = NaN; stat_label = '';
        switch stat_name
            case 'mean'; val = mean(y_data); stat_label = 'Mean';
            case 'std'; val = std(y_data); stat_label = 'Std Dev';
            case 'min'; val = min(y_data); stat_label = 'Min';
            case 'max'; val = max(y_data); stat_label = 'Max';
            case 'n'; val = length(y_data); stat_label = 'N';
            case 'median'; val = median(y_data); stat_label = 'Median';
            case 'sum'; val = sum(y_data); stat_label = 'Sum';
            otherwise
                log_message(params,['Stats Overlay: Unknown statistic "' stat_name '" requested.'],1,'Warning'); continue;
        end
        if ~isnan(val)
            if any(strcmp(stat_name, {'n', 'count'})) % Integer stats
                stats_str_lines{end+1} = sprintf('%s: %d', stat_label, round(val));
            else % Floating point stats
                stats_str_lines{end+1} = sprintf('%s: %.*f', stat_label, so_params.precision, val);
            end
        end
    end

    if isempty(stats_str_lines); return; end
    full_stats_str = strjoin(stats_str_lines, '\newline');

    stats_font_name = so_params.font_name; if isempty(stats_font_name); stats_font_name = params.font_name; end
    stats_text_color = so_params.text_color; if isempty(stats_text_color); stats_text_color = params.text_color; end

    % Base font size for stats is derived from scaled label font size
    base_axes_lfs = round(params.base_font_size * params.label_scale * scale_factor);
    stats_fs = round(base_axes_lfs * so_params.font_scale_factor);
    stats_fs = max(stats_fs, 6); % Ensure minimum readability

    original_axes_units = get(ax, 'Units');
    safe_set(params, ax, 'Units', 'normalized'); % Set units for text placement

    % Default offsets from axes edge, in normalized units
    x_text_offset_norm = 0.03; y_text_offset_norm = 0.03; 
    text_x_norm = 0; text_y_norm = 0; horz_align = 'left'; vert_align = 'bottom';

    switch lower(so_params.position)
        case 'northeast_inset'; text_x_norm = 1 - x_text_offset_norm; text_y_norm = 1 - y_text_offset_norm; horz_align = 'right'; vert_align = 'top';
        case 'northwest_inset'; text_x_norm = x_text_offset_norm;     text_y_norm = 1 - y_text_offset_norm; horz_align = 'left';  vert_align = 'top';
        case 'southwest_inset'; text_x_norm = x_text_offset_norm;     text_y_norm = y_text_offset_norm;     horz_align = 'left';  vert_align = 'bottom';
        case 'southeast_inset'; text_x_norm = 1 - x_text_offset_norm; text_y_norm = y_text_offset_norm;     horz_align = 'right'; vert_align = 'bottom';
        % Add more positions or 'best_text' later if needed
        otherwise % Default to northeast_inset
            log_message(params, sprintf('Stats Overlay: Unknown position "%s". Defaulting to northeast_inset.', so_params.position), 1, 'Warning');
            text_x_norm = 1 - x_text_offset_norm; text_y_norm = 1 - y_text_offset_norm; horz_align = 'right'; vert_align = 'top';
    end

    text_props = {
        'Units', 'normalized', 'String', full_stats_str, 'FontName', stats_font_name, ...
        'FontSize', stats_fs, 'Color', stats_text_color, 'HorizontalAlignment', horz_align, ...
        'VerticalAlignment', vert_align, 'PickableParts', 'none', 'HandleVisibility', 'off', ...
        'Tag', 'BeautifyFig_StatsOverlay' % Tag to identify/avoid re-processing
    };

    % Handle background and edge colors for the text box
    bg_color_final = 'none'; 
    edge_color_final = 'none';

    if ~isempty(so_params.background_color)
        bg_color_val = so_params.background_color;
        if ischar(bg_color_val) && strcmpi(bg_color_val, 'figure')
            fig_h = ancestor(ax,'figure');
            if ~isempty(fig_h) && isvalid(fig_h); bg_color_final = get(fig_h,'Color'); end
        elseif isnumeric(bg_color_val) || (ischar(bg_color_val) && ~strcmpi(bg_color_val,'none'))
            bg_color_final = bg_color_val;
        end
    end
    
    if ~isempty(so_params.edge_color)
        edge_color_val = so_params.edge_color;
        if ischar(edge_color_val) && strcmpi(edge_color_val, 'axes')
            edge_color_final = params.axis_color; % Use the themed axis color
        elseif isnumeric(edge_color_val) || (ischar(edge_color_val) && ~strcmpi(edge_color_val,'none'))
            edge_color_final = edge_color_val;
        end
    end

    has_background = ~(ischar(bg_color_final) && strcmpi(bg_color_final, 'none'));
    has_edge = ~(ischar(edge_color_final) && strcmpi(edge_color_final, 'none'));

    if has_background; text_props = [text_props, {'BackgroundColor', bg_color_final}]; end
    if has_edge; text_props = [text_props, {'EdgeColor', edge_color_final}]; end
    
    if has_background || has_edge % Add margin if background or edge is active
        text_props = [text_props, {'Margin', stats_fs*0.3}]; % Margin proportional to font size
    end
    
    % Remove any pre-existing stats overlay from this function for this axes
    old_stats_text = findobj(ax, 'Type', 'text', 'Tag', 'BeautifyFig_StatsOverlay');
    if ~isempty(old_stats_text); delete(old_stats_text); end

    text(ax, text_x_norm, text_y_norm, 0, text_props{:}); % Add Z=0 for 2D text

    safe_set(params, ax, 'Units', original_axes_units); % Restore original units
end

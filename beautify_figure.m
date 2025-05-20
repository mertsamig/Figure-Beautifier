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
%                    'viridis', 'cbrewer_qual_Set1', etc.) or an Nx3 RGB matrix.
%   - cycle_marker_styles: 'auto' (default), true, false. Controls marker cycling.
%   - cycle_line_styles: 'auto' (default), true, false. Controls line style cycling.
%   - grid_density: 'normal' (default), 'major_only', 'none'.
%   - axis_box_style: 'on' (default), 'off', 'left-bottom'.
%   - axes_layer: 'top' (default), 'bottom'. Sets axes Layer property.
%   - legend_location: 'best' (default), 'northeastoutside', 'none', etc.
%   - smart_legend_display: true (default). Avoids unnecessary legends.
%   - interactive_legend: true (default). Enables clickable legend items.
%   - log_level: 0 (silent), 1 (normal), 2 (detailed).
%   - export_settings: Structure for controlling figure export:
%     - enabled: (false) Set to true to export the figure.
%     - filename: ('beautified_figure') Base name for the exported file.
%     - format: ('png') Export format (e.g., 'png', 'jpeg', 'pdf', 'eps', 'svg', 'tiff').
%     - resolution: (300) Resolution in DPI for raster formats, also influences vector quality.
%     - open_exported_file: (false) If true, attempts to open the file after export.
%     - renderer: ('painters') Renderer to use. For `print`: 'painters', 'opengl', 'vector'. `exportgraphics` usually manages this automatically or via content type.
%     - ui: (false) If true and `exportgraphics` is available (R2020a+), it's preferred. Otherwise, `print` is used. Set to false to force `print -noui`.
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
%
% Author: [Your Name/Organization]
% Version: 2.1 (Production Ready) % Updated Version
% Date: [Current Date] % Updated Date

% --- Default Beautification Parameters ---
% These are the master defaults. They can be overridden by user_params.
default_params.theme = 'light';
default_params.font_name = 'Swiss 721 BT';
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
default_params.cycle_marker_styles = 'false';
default_params.marker_cycle_threshold = 3; % Cycle if num candidates > this value
default_params.marker_styles = {'o', 's', 'd', '^', 'v', '>', '<', 'p', 'h', '.', 'x', '+', '*'};
default_params.line_style_order = {'-', '--', ':', '-.'}; % NEW
default_params.cycle_line_styles = 'false'; % NEW: true, false, 'auto'
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

default_params.style_preset = 'default'; % Added new preset parameter

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
log_message(params, 'Provided axes handles are invalid or empty.', 0, 'Error'); return;
end
elseif isstruct(arg1)
user_provided_params_struct = arg1;
fig_handle_internal = gcf;
elseif isgraphics(arg1, 'figure') % Syntax: beautify_current_figure(fig_handle)
fig_handle_internal = arg1;
else
log_message(params, 'Invalid first argument. Expected figure handle, axes handle(s), or a parameter struct.', 0, 'Error'); return;
end
elseif nargin == 2
arg1 = user_params_or_axes_handle;
arg2 = user_params_for_specific_axes;
if is_valid_axes_handle_array(arg1)
if ~isstruct(arg2)
log_message(params, 'Invalid second argument when first is axes. Expected a parameter struct.', 0, 'Error'); return;
end
target_axes = arg1;
user_provided_params_struct = arg2;
if ~isempty(target_axes) && isvalid(target_axes(1))
fig_handle_internal = ancestor(target_axes(1), 'figure');
else
log_message(params, 'Provided axes handles are invalid or empty for two-argument syntax.', 0, 'Error'); return;
end
elseif isgraphics(arg1, 'figure') % Syntax: beautify_current_figure(fig_handle, params_struct)
if ~isstruct(arg2)
log_message(params, 'Invalid second argument when first is figure. Expected a parameter struct.', 0, 'Error'); return;
end
fig_handle_internal = arg1;
user_provided_params_struct = arg2;
else
log_message(params, 'Invalid first argument for two-argument syntax. Expected figure handle or axes handle(s).', 0, 'Error'); return;
end
else % nargin > 2
log_message(params, 'Too many input arguments.', 0, 'Error'); return;
end

% Validate fig_handle_internal and assign to 'fig'
if isempty(fig_handle_internal) || ~isvalid(fig_handle_internal)
log_message(params, 'No valid figure found or specified to beautify.', 0, 'Error'); return; % Still use initial params for this early error
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

log_message(base_defaults, sprintf('Applying style preset: "%s".', active_preset_name), 2, 'Info');
switch active_preset_name
    case 'publication'
        params.font_name = 'Arial';
        params.base_font_size = 10;
        params.global_font_scale_factor = 1.0;
        params.plot_line_width = 1.0;
        params.axis_to_plot_linewidth_ratio = 0.75;
        params.marker_size = 5;
        params.color_palette = 'lines';
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
        params.font_name = 'Helvetica Neue';
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
    % No 'otherwise' needed here due to pre-check and fallback.
end

% Merge user parameters with defaults (now 'params' includes preset values)
param_names = fieldnames(user_provided_params_struct);
for i = 1:length(param_names)
if isfield(params, param_names{i})
params.(param_names{i}) = user_provided_params_struct.(param_names{i});
else
log_message(params, sprintf('Unknown parameter: "%s". This parameter will be ignored.', param_names{i}), 1, 'Warning');
end
end

% Apply theme defaults intelligently after presets and user params have been merged.
% The goal is to apply generic theme colors ONLY if they haven't been specifically
% set by a preset (for that theme) or by the user.

original_light_theme_colors.axis_color = base_defaults.axis_color;
original_light_theme_colors.text_color = base_defaults.text_color;
original_light_theme_colors.grid_color = base_defaults.grid_color;
original_light_theme_colors.figure_background_color = base_defaults.figure_background_color; % This is MATLAB's default figure color

dark_theme_generic_colors.axis_color = [0.85 0.85 0.85];
dark_theme_generic_colors.text_color = [0.9 0.9 0.9];
dark_theme_generic_colors.grid_color = [0.7 0.7 0.7];
dark_theme_generic_colors.figure_background_color = [0.12 0.12 0.15];

theme_changed_log = false;
if strcmpi(params.theme, 'dark')
    if ~isfield(user_provided_params_struct, 'axis_color') && isequal(params.axis_color, original_light_theme_colors.axis_color)
        params.axis_color = dark_theme_generic_colors.axis_color; theme_changed_log = true;
    end
    if ~isfield(user_provided_params_struct, 'text_color') && isequal(params.text_color, original_light_theme_colors.text_color)
        params.text_color = dark_theme_generic_colors.text_color; theme_changed_log = true;
    end
    if ~isfield(user_provided_params_struct, 'grid_color') && isequal(params.grid_color, original_light_theme_colors.grid_color)
        params.grid_color = dark_theme_generic_colors.grid_color; theme_changed_log = true;
    end
    if ~isfield(user_provided_params_struct, 'figure_background_color') && isequal(params.figure_background_color, original_light_theme_colors.figure_background_color)
        params.figure_background_color = dark_theme_generic_colors.figure_background_color; theme_changed_log = true;
    end
    if theme_changed_log; log_message(params, 'Generic dark theme color defaults applied where not specified by preset or user.', 2, 'Info'); end
else % Light theme is active
    % If the current params.theme is 'light', but some colors might have been set to dark theme
    % values by a preset (that was then overridden by user setting params.theme='light'),
    % ensure they revert to original light defaults if not specified by user.
    if ~isfield(user_provided_params_struct, 'axis_color') && isequal(params.axis_color, dark_theme_generic_colors.axis_color)
        params.axis_color = original_light_theme_colors.axis_color; theme_changed_log = true;
    end
    if ~isfield(user_provided_params_struct, 'text_color') && isequal(params.text_color, dark_theme_generic_colors.text_color)
        params.text_color = original_light_theme_colors.text_color; theme_changed_log = true;
    end
    if ~isfield(user_provided_params_struct, 'grid_color') && isequal(params.grid_color, dark_theme_generic_colors.grid_color)
        params.grid_color = original_light_theme_colors.grid_color; theme_changed_log = true;
    end
    if ~isfield(user_provided_params_struct, 'figure_background_color') && isequal(params.figure_background_color, dark_theme_generic_colors.figure_background_color)
        params.figure_background_color = original_light_theme_colors.figure_background_color; theme_changed_log = true;
    end
    if theme_changed_log; log_message(params, 'Generic light theme color defaults applied where not specified by preset or user.', 2, 'Info'); end
end

% Calculate derived parameters
params.axis_line_width = params.plot_line_width * params.axis_to_plot_linewidth_ratio;
params.base_font_size = params.base_font_size * params.global_font_scale_factor;

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
params.active_color_palette = lines(7);
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
beautify_single_axes(ax, params, scale_factor);
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
    % Ensure the filename is valid and includes the correct extension
    [~, name_part, ~] = fileparts(params.export_settings.filename);
    if isempty(name_part); name_part = 'beautified_figure'; end % Default if empty
    current_format = lower(params.export_settings.format);
    if any(strcmp(current_format, {'jpeg', 'jpg'}))
        current_format = 'jpg'; % Normalize to jpg for extension
    elseif any(strcmp(current_format, {'tiff', 'tif'}))
        current_format = 'tif'; % Normalize to tif for extension
    end
    full_filename_with_ext = [name_part, '.', current_format];
    
    log_message(params, sprintf('Exporting figure to "%s"...', full_filename_with_ext), 1, 'Info');
    try
        export_done_successfully = false;
        % Preferred method: exportgraphics (if UI allowed or not specified AND function exists)
        % exportgraphics is generally preferred if available (R2020a+)
        if exist('exportgraphics','file') == 2 && params.export_settings.ui 
            log_message(params, sprintf('Attempting exportgraphics (resolution %d DPI).', params.export_settings.resolution), 2, 'Info');
            exportgraphics(fig, full_filename_with_ext, 'Resolution', params.export_settings.resolution);
            log_message(params, 'Export successful using exportgraphics.', 1, 'Info');
            export_done_successfully = true;
        else
            % Fallback or explicit non-UI method: print command
            if ~params.export_settings.ui && exist('exportgraphics','file') == 2
                 log_message(params, 'UI set to false, but exportgraphics is available. Consider using exportgraphics directly if -noui behavior is not strictly needed for `print`.', 2, 'Info');
            end

            format_flag = '';
            print_format = lower(params.export_settings.format);
            switch print_format
                case {'png', 'jpeg', 'jpg', 'pdf', 'eps', 'tiff', 'tif', 'svg'}
                    format_flag = ['-d' print_format];
                    if strcmp(print_format, 'jpg'); format_flag = '-djpeg'; end % print uses -djpeg
                    if strcmp(print_format, 'tif'); format_flag = '-dtiff'; end % print uses -dtiff
                    if strcmp(print_format, 'eps'); format_flag = '-depsc'; end % ensure color eps
                otherwise
                    log_message(params, sprintf('Unsupported export format for print command: "%s". Skipping export.', print_format), 1, 'Warning');
                    format_flag = ''; % Will skip print
            end

            if ~isempty(format_flag)
                resolution_flag = sprintf('-r%d', params.export_settings.resolution);
                cmd_parts = {fig, full_filename_with_ext, format_flag, resolution_flag};

                renderer_to_use = params.export_settings.renderer;
                % For vector formats, painters is often best. For others, opengl might be needed for complex scenes.
                if any(strcmpi(print_format, {'pdf', 'eps', 'svg'}))
                    if ~any(strcmpi(renderer_to_use, {'painters', 'vector'})) % 'vector' is an alias for painters for some contexts
                        log_message(params, sprintf('Renderer "%s" not ideal for vector format "%s". Suggesting "painters".', renderer_to_use, print_format), 1, 'Warning');
                        % It's a suggestion, user's choice is still respected unless it's 'auto'
                        if strcmpi(renderer_to_use, 'auto'); renderer_to_use = 'painters'; end
                    end
                end
                
                if ~isempty(renderer_to_use) && ~strcmpi(renderer_to_use, 'auto')
                    renderer_flag = sprintf('-%s', renderer_to_use);
                    cmd_parts{end+1} = renderer_flag;
                end
                
                if ~params.export_settings.ui % Add -noui if not using UI (relevant for print)
                    cmd_parts{end+1} = '-noui';
                end
                
                log_message(params, sprintf('Using print command with options: %s', strjoin(cmd_parts(3:end),' ')), 2, 'Info');
                print(cmd_parts{:});
                log_message(params, 'Export successful using print command.', 1, 'Info');
                export_done_successfully = true;
            else
                 log_message(params, 'Export skipped due to empty format_flag (unsupported format for print).', 1, 'Warning');
            end
        end

        if export_done_successfully && params.export_settings.open_exported_file
            log_message(params, sprintf('Attempting to open exported file: %s', full_filename_with_ext), 2, 'Info');
            try
                open(full_filename_with_ext); % MATLAB's open function
            catch ME_open_matlab
                log_message(params, sprintf('MATLAB open() failed: "%s". Trying system open.', ME_open_matlab.message), 1, 'Warning');
                try
                    current_file_path = fullfile(pwd, full_filename_with_ext);
                    if ispc
                        system(['start "" "', current_file_path, '"']);
                    elseif ismac
                        system(['open "', current_file_path, '"']);
                    else % Linux or other Unix
                        system(['xdg-open "', current_file_path, '"']);
                    end
                catch ME_sys_open
                    log_message(params, sprintf('System open command failed: %s', ME_sys_open.message), 1, 'Warning');
                end
            end
        elseif ~export_done_successfully
            log_message(params, 'Export was not successful, skipping file open.', 1, 'Warning');
        end

    catch ME_export
        log_message(params, sprintf('Figure export process failed: %s (Line: %d)', ME_export.message, ME_export.stack(1).line), 0, 'Error');
    end
end

log_message(params, 'Figure beautification complete.', 1, 'Info');
drawnow; % Ensure all changes are rendered
end

% --- Helper Function: Validate Axes Handle Array ---
function tf = is_valid_axes_handle_array(h_array)
% IS_VALID_AXES_HANDLE_ARRAY Checks if h_array is an array of valid axes or polaraxes handles.
% Returns true if h_array is empty or contains only valid axes/polaraxes handles.
% Returns false otherwise.

if isempty(h_array)
    tf = true; % An empty array is considered valid as it contains no invalid handles.
    return;
end

% Check if all elements are graphics handles
if ~all(ishandle(h_array))
    tf = false;
    return;
end

% Check if all handles are valid (not deleted)
if ~all(isvalid(h_array))
    tf = false;
    return;
end

% Check if all valid handles are of the correct type (Axes or PolarAxes)
% Using arrayfun for element-wise check and then 'all' to ensure every element satisfies the condition.
is_correct_type = arrayfun(@(h) isa(h, 'matlab.graphics.axis.Axes') || isa(h, 'matlab.graphics.axis.PolarAxes'), h_array);
if ~all(is_correct_type)
    tf = false;
    return;
end

tf = true; % If all checks passed
end

% --- Helper Function: Get Scale Basis for an Axes ---
function num_to_scale_by = get_scale_basis_for_axes(ax, parent_layout, params)
num_to_scale_by = 1; % Default for standalone axes
if ~isempty(parent_layout) && isvalid(parent_layout)
try
grid_size = parent_layout.GridSize;
axes_to_ignore = [{'legend', 'Colorbar', 'ColormapPreview', 'scribeOverlay'}, params.exclude_object_tags];
% Count only valid axes children of this specific layout
axes_in_layout_raw = get_axes_from_parent(parent_layout, params, axes_to_ignore);
num_axes_found = numel(axes_in_layout_raw);

num_to_scale_by = max(1, num_axes_found);
    % If grid is defined and larger than found axes, use grid size for more consistent scaling
    if prod(grid_size) > num_axes_found && prod(grid_size) > 0
        num_to_scale_by = prod(grid_size);
    end
catch ME_scale_basis
    log_message(params, sprintf('Could not determine scale basis for axes in TiledLayout: %s. Using default.', ME_scale_basis.message), 1, 'Warning');
end


end
end

% --- Helper Function: Get Color Palette ---
function active_palette = get_color_palette(params, fig_handle)
palette_source = params.color_palette;
if ischar(palette_source)
switch lower(palette_source)
case 'lines'; active_palette = lines(7);
case 'parula'; active_palette = parula(10);
case 'viridis'
if exist('viridis','file') == 2; active_palette = viridis(10);
else; log_message(params,'"viridis" colormap not found. Using "lines".',1,'Warning'); active_palette = lines(7); end
case 'default_matlab'
original_visibility = ''; fig_valid = isvalid(fig_handle);
if fig_valid && isprop(fig_handle, 'HandleVisibility'); original_visibility = get(fig_handle,'HandleVisibility'); set(fig_handle,'HandleVisibility','on'); end
ax_temp = axes('Parent', fig_handle, 'Visible', 'off', 'HandleVisibility', 'off');
try active_palette = get(ax_temp,'colororder'); catch; active_palette = get(groot,'defaultAxesColorOrder'); end
delete(ax_temp);
if fig_valid && ~isempty(original_visibility); set(fig_handle,'HandleVisibility',original_visibility); end
if size(active_palette,1) < 2; active_palette = get(groot,'defaultAxesColorOrder'); end % Fallback
case {'cbrewer_qual_set1', 'cbrewer_qual_set2', 'cbrewer_qual_set3', ...
'cbrewer_seq_blues', 'cbrewer_div_brbg'}
if exist('cbrewer','file') == 2
try; parts = strsplit(palette_source, '_'); ctype = parts{2}; cname = parts{3}; num_colors = 8;
if length(parts) > 3 && ~isempty(str2double(parts{4})); num_colors = str2double(parts{4}); end
active_palette = cbrewer(ctype, cname, max(3,num_colors));
catch ME_cbrewer; log_message(params, sprintf('cbrewer palette "%s" failed: %s. Using "lines".', palette_source, ME_cbrewer.message), 1,'Warning'); active_palette = lines(7); end
else; log_message(params,'"cbrewer" function not found. Using "lines".',1,'Warning'); active_palette = lines(7); end
case 'custom'
if ~isempty(params.custom_color_palette) && isnumeric(params.custom_color_palette) && size(params.custom_color_palette,2) == 3; active_palette = params.custom_color_palette;
else; log_message(params, 'Invalid "custom" color palette. Using "lines".', 1,'Warning'); active_palette = lines(7); end
otherwise; log_message(params, sprintf('Unknown color palette name: "%s". Using "lines".', palette_source), 1,'Warning'); active_palette = lines(7);
end
elseif isnumeric(palette_source) && ndims(palette_source) == 2 && size(palette_source,2) == 3 && size(palette_source,1) > 0
active_palette = palette_source;
else; log_message(params, 'Invalid color palette format. Using "lines".', 1,'Warning'); active_palette = lines(7); end
if isempty(active_palette); active_palette = lines(7); end % Final fallback
end

% --- Helper Function: Process a Container (Figure or Tab) ---
function process_container(container_handle, params)
axes_to_ignore_combined = [{'legend', 'ColormapPreview', 'scribeOverlay'}, params.exclude_object_tags];
if ~params.apply_to_colorbars; axes_to_ignore_combined{end+1} = 'Colorbar'; end

if params.beautify_sgtitle
if isa(container_handle, 'matlab.graphics.layout.TiledChartLayout')
beautify_sgtitle_if_exists(container_handle, params);
else
tls_in_container = findobj(container_handle, 'Type', 'tiledlayout', '-depth', 1);
for k_tl = 1:length(tls_in_container)
if isvalid(tls_in_container(k_tl)); beautify_sgtitle_if_exists(tls_in_container(k_tl), params); end
end
end
end

tiled_layouts = findobj(container_handle, 'Type', 'tiledlayout', '-depth', 1);
if ~isempty(tiled_layouts)
for tl_idx = 1:length(tiled_layouts)
current_tiled_layout = tiled_layouts(tl_idx);
if ~isvalid(current_tiled_layout); continue; end
axes_in_layout = get_axes_from_parent(current_tiled_layout, params, axes_to_ignore_combined);
num_axes_found = numel(axes_in_layout);
if num_axes_found == 0; continue; end

num_to_scale_by = get_scale_basis_for_axes(axes_in_layout(1), current_tiled_layout, params);
    scale_factor = get_scale_factor(num_to_scale_by, params.scaling_map, params.min_scale_factor, params.max_scale_factor);
    grid_size_disp = current_tiled_layout.GridSize;
    log_message(params, sprintf('  TiledLayout (Grid: %dx%d, Axes: %d). Scale: %.2f', grid_size_disp(1), grid_size_disp(2), num_axes_found, scale_factor), 2, 'Info');
    for ax_idx = 1:num_axes_found
        if isvalid(axes_in_layout(ax_idx)); beautify_single_axes(axes_in_layout(ax_idx), params, scale_factor); end
    end
end
IGNORE_WHEN_COPYING_START
content_copy
download
Use code with caution.
IGNORE_WHEN_COPYING_END

else % No TiledLayouts, process axes directly in container
all_axes_in_container = get_axes_from_parent(container_handle, params, axes_to_ignore_combined);
if isempty(all_axes_in_container); log_message(params, '  No plottable axes found in this container.', 2, 'Info'); return; end
num_axes_found = numel(all_axes_in_container);
scale_factor = get_scale_factor(num_axes_found, params.scaling_map, params.min_scale_factor, params.max_scale_factor);
log_message(params, sprintf('  Container has %d axes (no TiledLayout). Scale: %.2f', num_axes_found, scale_factor), 2, 'Info');
for ax_idx = 1:num_axes_found
if isvalid(all_axes_in_container(ax_idx)); beautify_single_axes(all_axes_in_container(ax_idx), params, scale_factor); end
end
end
end

% --- Helper Function: Beautify Super Title (sgtitle) ---
function beautify_sgtitle_if_exists(layout_handle, params)
try
if isprop(layout_handle, 'Title') && isvalid(layout_handle.Title) && ~isempty(layout_handle.Title.String)
sgt = layout_handle.Title;
% Use a slightly larger scale for sgtitle than for regular titles
sg_font_size = round(params.base_font_size * params.title_scale * params.max_scale_factor * 1.2);
sg_font_size = max(sg_font_size, round(params.base_font_size * 1.7)); % Ensure a minimum prominent size
process_text_prop(sgt, sgt.String, sg_font_size, 'bold', params.text_color, params.font_name, params, true); % LaTeX auto usually off for sgtitle
end
catch ME_sgtitle
log_message(params, sprintf('Could not beautify sgtitle: %s', ME_sgtitle.message), 1, 'Warning');
end
end

% --- Helper Function: Get Plottable Axes from Parent ---
function axes_handles = get_axes_from_parent(parent_handle, params, ignore_tags_combined)
axes_handles = [];
if ~isvalid(parent_handle); return; end
try
potential_children = findobj(parent_handle, '-depth', 1);
catch ME_findobj
log_message(params, sprintf('findobj failed for parent %s: %s', class(parent_handle), ME_findobj.message),1,'Warning');
return;
end

for k=1:length(potential_children)
child = potential_children(k);
if child == parent_handle || ~isvalid(child); continue; end

is_valid_axis_type = (isa(child, 'matlab.graphics.axis.Axes') || ...
    (params.apply_to_polaraxes && isa(child, 'matlab.graphics.axis.PolarAxes')));

if is_valid_axis_type
    child_tag = ''; try child_tag = get(child,'Tag'); catch; end % Handle cases where Tag might not exist
    is_ignored_by_tag = any(strcmp(child_tag, ignore_tags_combined));
    is_ignored_by_type = any(strcmp(class(child), params.exclude_object_types));

    if ~is_ignored_by_tag && ~is_ignored_by_type
        axes_handles = [axes_handles; child]; %#ok<AGROW>
    end
end
IGNORE_WHEN_COPYING_START
content_copy
download
Use code with caution.
IGNORE_WHEN_COPYING_END

end
end

% --- Helper Function: Get Scaling Factor (No changes from previous robust version) ---
function sf = get_scale_factor(num_sps, scaling_map, min_sf, max_sf)
keys = cell2mat(scaling_map.keys); values = cell2mat(scaling_map.values); if num_sps <= 0; num_sps = 1; end
idx = find(keys == num_sps, 1); if ~isempty(idx); sf = values(idx);
else; sorted_keys = sort(keys);
if num_sps < min(sorted_keys); sf = values(keys == min(sorted_keys)) * nthroot(num_sps / min(sorted_keys), 2.5);
elseif num_sps > max(sorted_keys); sf = values(keys == max(sorted_keys)) * nthroot(max(sorted_keys) / num_sps, 2.5);
else; sf = interp1(keys, values, num_sps, 'linear', 'extrap');
lbv=interp1(keys,values,max(keys(keys<num_sps)),'nearest','extrap'); ubv=interp1(keys,values,min(keys(keys>num_sps)),'nearest','extrap');
sf=max(min(sf,max(lbv,ubv)*1.1),min(lbv,ubv)*0.9); % Clamp extrapolation
end; end; sf = max(min_sf, min(max_sf, sf));
end

% --- Core Function: Beautify a Single Axes Object ---
function beautify_single_axes(ax, params, scale_factor)
if ~isvalid(ax); return; end
current_hold_state = ishold(ax); if ~current_hold_state; safe_hold(ax, 'on'); end

% Calculate scaled dimensions
fs = round(params.base_font_size * scale_factor);
tfs = round(params.base_font_size * params.title_scale * scale_factor);
lfs = round(params.base_font_size * params.label_scale * scale_factor);
actual_plot_lw = max(0.75, params.plot_line_width * scale_factor);
alw = max(0.5, actual_plot_lw * params.axis_to_plot_linewidth_ratio);
ms = max(3, params.marker_size * scale_factor); % ms is in points

% --- Apply Axes Properties ---
common_props = {'FontName', params.font_name, 'FontSize', fs, 'LineWidth', alw, 'TickDir', 'out', ...
'GridColor', params.grid_color, 'GridAlpha', params.grid_alpha, 'GridLineStyle', params.grid_line_style, ...
'MinorGridColor', params.grid_color, 'MinorGridAlpha', params.minor_grid_alpha, 'MinorGridLineStyle', params.minor_grid_line_style};

switch lower(params.axis_box_style)
case 'on'; common_props = [common_props, {'Box', 'on'}];
case 'off'; common_props = [common_props, {'Box', 'off'}];
case 'left-bottom'
common_props = [common_props, {'Box', 'off', 'XAxisLocation', 'bottom', 'YAxisLocation', 'left'}];
try; if isprop(ax, 'XAxis') && numel(ax.XAxis)>1; safe_set(ax.XAxis(2), 'Visible', 'off'); end; catch; end
try; if isprop(ax, 'YAxis') && numel(ax.YAxis)>1; safe_set(ax.YAxis(2), 'Visible', 'off'); end; catch; end
end

major_grid_on = 'off'; minor_grid_on = 'off';
if strcmpi(params.grid_density, 'normal'); major_grid_on = 'on'; minor_grid_on = 'on';
elseif strcmpi(params.grid_density, 'major_only'); major_grid_on = 'on'; end

try
if isa(ax, 'matlab.graphics.axis.Axes')
safe_set(ax, common_props{:}, 'XGrid', major_grid_on, 'YGrid', major_grid_on, 'ZGrid', major_grid_on, ...
'XMinorGrid', minor_grid_on, 'YMinorGrid', minor_grid_on, 'ZMinorGrid', minor_grid_on, ...
'XColor', params.axis_color, 'YColor', params.axis_color, 'ZColor', params.axis_color, ...
'Layer', params.axes_layer); % NEW: Set Layer property
process_text_prop(ax.Title, ax.Title.String, tfs, 'bold', params.text_color, params.font_name, params);
process_text_prop(ax.XLabel, ax.XLabel.String, lfs, 'normal', params.text_color, params.font_name, params);
process_text_prop(ax.YLabel, ax.YLabel.String, lfs, 'normal', params.text_color, params.font_name, params);
process_text_prop(ax.ZLabel, ax.ZLabel.String, lfs, 'normal', params.text_color, params.font_name, params);

if ~isgeoaxes(ax) && strcmpi(params.axis_limit_mode, 'padded') && params.expand_axis_limits_factor > 0
        expand_axis_lims(ax, 'XLim', params.expand_axis_limits_factor);
        expand_axis_lims(ax, 'YLim', params.expand_axis_limits_factor);
        % BUGFIX: Removed redundant log scale check, expand_axis_lims handles it.
        if isprop(ax,'ZAxis') && ~isempty(ax.ZAxis) && diff(ax.ZLim) > 1e-9; expand_axis_lims(ax, 'ZLim', params.expand_axis_limits_factor); end
    elseif strcmpi(params.axis_limit_mode, 'tight');
        try; axis(ax, 'tight');
            if params.expand_axis_limits_factor > 0 && params.expand_axis_limits_factor < 0.015 % very slight pad after tight
                expand_axis_lims(ax, 'XLim', params.expand_axis_limits_factor*0.5); expand_axis_lims(ax, 'YLim', params.expand_axis_limits_factor*0.5);
            end
        catch ME_tight; log_message(params, sprintf('Warning: "axis tight" failed for axes (Tag: %s): %s', ax.Tag, ME_tight.message),1,'Warning'); end
    end
elseif isa(ax, 'matlab.graphics.axis.PolarAxes') && params.apply_to_polaraxes
    % PolarAxes does not have 'Layer' property
    safe_set(ax, common_props{:}, 'RGrid', major_grid_on, 'ThetaGrid', major_grid_on, ...
        'RColor', params.axis_color, 'ThetaColor', params.axis_color);
    process_text_prop(ax.Title, ax.Title.String, tfs, 'bold', params.text_color, params.font_name, params);
end
IGNORE_WHEN_COPYING_START
content_copy
download
Use code with caution.
IGNORE_WHEN_COPYING_END

catch ME_axes_props
log_message(params, sprintf('Error setting main axes properties for (Tag: %s): %s', ax.Tag, ME_axes_props.message), 1, 'Warning');
end

% --- Beautify Child Graphics Objects ---
try; all_children_orig = get(ax, 'Children'); catch; all_children_orig = []; end
all_children_filtered = [];
for k_child = 1:length(all_children_orig)
child_obj = all_children_orig(k_child);
if ~isvalid(child_obj); continue; end
child_tag = ''; try child_tag = get(child_obj,'Tag'); catch; end
is_excluded_tag = any(strcmp(child_tag, params.exclude_object_tags));
is_excluded_type = any(strcmp(class(child_obj), params.exclude_object_types));
if ~is_excluded_tag && ~is_excluded_type; all_children_filtered = [all_children_filtered; child_obj]; end %#ok<AGROW>
end

color_idx = 0; marker_idx = 0; % linestyle_idx will use color_idx
num_marker_styles = length(params.marker_styles);
num_line_styles = length(params.line_style_order); % NEW
plottable_children_for_legend = [];

temp_legend_candidates = [];
for i = 1:length(all_children_filtered)
if is_legend_candidate_check(all_children_filtered(i)); temp_legend_candidates = [temp_legend_candidates; all_children_filtered(i)]; end %#ok<AGROW>
end
num_total_legend_candidates = length(temp_legend_candidates);

activate_marker_cycle_now = false;
if islogical(params.cycle_marker_styles) && params.cycle_marker_styles; activate_marker_cycle_now = true;
elseif ischar(params.cycle_marker_styles) && strcmpi(params.cycle_marker_styles, 'auto') && num_total_legend_candidates > params.marker_cycle_threshold
activate_marker_cycle_now = true;
end

activate_linestyle_cycle_now = false; % NEW
if islogical(params.cycle_line_styles) && params.cycle_line_styles; activate_linestyle_cycle_now = true;
elseif ischar(params.cycle_line_styles) && strcmpi(params.cycle_line_styles, 'auto') && num_total_legend_candidates > params.line_style_cycle_threshold
activate_linestyle_cycle_now = true;
end

processed_children_order = all_children_filtered;
if params.legend_reverse_order; processed_children_order = flipud(all_children_filtered); end

for i = 1:length(processed_children_order)
child = processed_children_order(i);
try
is_leg_cand_current = is_legend_candidate_check(child);
if is_leg_cand_current; plottable_children_for_legend = [plottable_children_for_legend; child]; end

current_color = []; current_marker_style_name = [];
    if is_leg_cand_current
        color_idx = color_idx + 1;
        current_color = params.active_color_palette(mod(color_idx-1, params.num_palette_colors)+1, :);
        if activate_marker_cycle_now
            % marker_idx is tied to color_idx for legend candidates
            current_marker_style_name = params.marker_styles{mod(color_idx-1, num_marker_styles)+1};
        end
    end

    % Apply properties to different plot types
    if isa(child, 'matlab.graphics.chart.primitive.Line')
        safe_set(child, 'LineWidth', actual_plot_lw, 'MarkerSize', ms);
        if ~isempty(current_color); safe_set(child, 'Color', current_color); end

        % NEW: Line style cycling
        if activate_linestyle_cycle_now && is_leg_cand_current && num_line_styles > 0
            current_line_style_name_for_line = params.line_style_order{mod(color_idx-1, num_line_styles)+1};
            safe_set(child, 'LineStyle', current_line_style_name_for_line);
        end

        if ~isempty(current_marker_style_name) && ~strcmpi(child.LineStyle,'none')
            safe_set(child, 'Marker', current_marker_style_name);
            if ~strcmpi(current_marker_style_name,'none') && ~strcmpi(current_marker_style_name,'.') && ~isempty(current_color)
                safe_set(child, 'MarkerFaceColor', current_color, 'MarkerEdgeColor', current_color*0.7);
            elseif strcmpi(current_marker_style_name,'.') && ~isempty(current_color); safe_set(child, 'MarkerEdgeColor',current_color); end
        elseif ~strcmpi(child.Marker,'none') && ~isempty(current_color) % No cycle, but marker exists & color assigned
            if isprop(child,'MarkerFaceColor')&&~ischar(child.MarkerFaceColor)&&~any(strcmpi(child.MarkerFaceColor,{'auto','none'}));safe_set(child,'MarkerFaceColor',current_color);end
            if isprop(child,'MarkerEdgeColor')&&~ischar(child.MarkerEdgeColor)&&~any(strcmpi(child.MarkerEdgeColor,{'auto','none'}));safe_set(child,'MarkerEdgeColor',current_color*0.7);end
        end
    elseif isa(child, 'matlab.graphics.chart.primitive.Scatter')
        % BUGFIX: Corrected SizeData scaling. ms is already scaled points value. SizeData is points^2.
        safe_set(child, 'SizeData', ms^2, 'LineWidth', actual_plot_lw*0.5);
        if ~isempty(current_color)
            if ~(ischar(child.MarkerFaceColor)&&any(strcmpi(child.MarkerFaceColor,{'none','flat'}))); safe_set(child,'MarkerFaceColor',current_color); end
            if ~(ischar(child.MarkerEdgeColor)&&strcmpi(child.MarkerEdgeColor,'none')); safe_set(child,'MarkerEdgeColor',current_color*0.75); end
        end
        if ~isempty(current_marker_style_name); safe_set(child, 'Marker', current_marker_style_name); end
    elseif isa(child, 'matlab.graphics.chart.primitive.Bar')
        safe_set(child, 'LineWidth', alw*0.9, 'EdgeColor', params.axis_color*0.7);
        if ~isempty(current_color) && ((ischar(child.FaceColor)&&~strcmpi(child.FaceColor,'flat'))||~ischar(child.FaceColor)); safe_set(child, 'FaceColor', current_color); end
    elseif isa(child, 'matlab.graphics.chart.primitive.Histogram')
        safe_set(child, 'LineWidth', alw*0.8, 'EdgeColor', params.axis_color*0.5, 'FaceAlpha', 0.7);
        if ~isempty(current_color); safe_set(child, 'FaceColor', current_color); end
    elseif isa(child, 'matlab.graphics.chart.primitive.ErrorBar')
        safe_set(child, 'LineWidth', actual_plot_lw*0.8, 'MarkerSize', ms*0.8, 'CapSize', actual_plot_lw*params.errorbar_cap_size_scale*6);
        if ~isempty(current_color); safe_set(child,'Color',current_color); end
        if ~isempty(current_marker_style_name); safe_set(child, 'Marker', current_marker_style_name); end
    elseif isa(child,'matlab.graphics.primitive.Surface')||isa(child,'matlab.graphics.chart.primitive.Surface')||isa(child,'matlab.graphics.primitive.Patch')
        safe_set(child, 'EdgeColor', params.axis_color*0.6, 'LineWidth', alw*0.7);
    end
catch ME_child
    log_message(params, sprintf('Error processing child object (Type: %s, Tag: %s): %s', class(child), child.Tag, ME_child.message), 1, 'Warning');
end
IGNORE_WHEN_COPYING_START
content_copy
download
Use code with caution.
IGNORE_WHEN_COPYING_END

end

if params.legend_reverse_order; plottable_children_for_legend = flipud(plottable_children_for_legend); end

% --- Beautify General Text Objects in Axes ---
if params.apply_to_general_text
try; text_children = findobj(ax, 'Type', 'text', '-depth', 1); catch; text_children = []; end
for k_text = 1:length(text_children)
txt_obj=text_children(k_text); if ~isvalid(txt_obj); continue; end
is_label_or_title=any(strcmp(txt_obj.Tag,{'XLabel','YLabel','ZLabel','Title'}));
is_in_legend = false; try; if isprop(txt_obj,'Parent') && isa(get(txt_obj,'Parent'),'matlab.graphics.illustration.Legend'); is_in_legend=true; end; catch; end
if ~is_label_or_title && ~is_in_legend; process_text_prop(txt_obj,txt_obj.String,fs,txt_obj.FontWeight,txt_obj.Color,params.font_name,params); end
end
end

% --- Handle Legend ---
beautify_legend(ax, params, plottable_children_for_legend, fs, alw);

% --- Handle Colorbar ---
if params.apply_to_colorbars; beautify_colorbar(ax, params, fs, lfs, alw); end

if ~current_hold_state; safe_hold(ax, 'off'); end
end

% --- Helper Function: Check if an object is a legend candidate ---
function is_candidate = is_legend_candidate_check(obj_handle)
is_candidate = false;
if ~isvalid(obj_handle) || ~isprop(obj_handle,'Visible') || ~strcmpi(get(obj_handle, 'Visible'), 'on'); return; end

is_plottype = isa(obj_handle, 'matlab.graphics.chart.primitive.Line') || ...
isa(obj_handle, 'matlab.graphics.chart.primitive.Scatter') || ...
isa(obj_handle, 'matlab.graphics.chart.primitive.ErrorBar') || ...
isa(obj_handle, 'matlab.graphics.chart.primitive.Stair') || ...
isa(obj_handle, 'matlab.graphics.chart.primitive.Area') || ...
isa(obj_handle, 'matlab.graphics.chart.primitive.Bar');

if ~is_plottype; return; end

try
if isprop(obj_handle,'DisplayName') && ~isempty(get(obj_handle, 'DisplayName'))
is_candidate = true;
elseif isprop(obj_handle, 'Annotation') && isprop(obj_handle.Annotation, 'LegendInformation') && ...
isprop(obj_handle.Annotation.LegendInformation, 'IconDisplayStyle') && ...
strcmpi(obj_handle.Annotation.LegendInformation.IconDisplayStyle, 'on')
is_candidate = true;
end
catch
% Property access failed, assume not a candidate
end
end

% --- Helper Function: Beautify Legend ---
function beautify_legend(ax, params, plottable_children_for_legend, fs, alw)
try
existing_legend = []; % Initialize
% Try direct property first (often most reliable)
if isprop(ax, 'Legend') && isa(ax.Legend, 'matlab.graphics.illustration.Legend') && isvalid(ax.Legend)
existing_legend = ax.Legend;
end

% If not found or invalid, try findobj specifically for this axis
if isempty(existing_legend)
    all_legends_in_parent = findobj(get(ax,'Parent'), 'Type','Legend');
    for k_leg = 1:numel(all_legends_in_parent)
        current_lgd = all_legends_in_parent(k_leg);
        % Check if legend is associated with the current axes 'ax'
        % Different MATLAB versions might store this differently.
        % Modern approach: legend has an 'Axes' property pointing to its axes.
        if isprop(current_lgd, 'Axes') && isequal(current_lgd.Axes, ax)
            existing_legend = current_lgd;
            break;
        else
            % Older approach or fallback: check if 'ax' is a peer of the legend's axle
            if isprop(current_lgd, 'Axle') && isprop(current_lgd.Axle, 'Peer') && isequal(current_lgd.Axle.Peer, ax)
                existing_legend = current_lgd;
                break;
            end
        end
    end
end

% At this point, existing_legend is either a scalar valid legend handle for 'ax', or empty.
% Subsequent checks like (~isempty(existing_legend) && isvalid(existing_legend)) will be safe.

num_actual_legend_entries = length(plottable_children_for_legend);
should_show_legend = false;

if strcmpi(params.legend_location,'none')
    if ~isempty(existing_legend)&&isvalid(existing_legend); safe_set(existing_legend,'Visible','off');end
else
    if params.smart_legend_display
        if num_actual_legend_entries>1; should_show_legend=(~isempty(existing_legend)&&isvalid(existing_legend)); % Only if exists
            % BUGFIX: Corrected typo from &¶ms to && params
        elseif num_actual_legend_entries==1 && params.legend_force_single_entry; should_show_legend=true; % Can create new
        else; if ~isempty(existing_legend)&&isvalid(existing_legend);safe_set(existing_legend,'Visible','off');end; end
    else % Not smart display: create if plottable items exist and not single (unless forced)
        if num_actual_legend_entries>0
            if num_actual_legend_entries==1&&~params.legend_force_single_entry; if ~isempty(existing_legend)&&isvalid(existing_legend);safe_set(existing_legend,'Visible','off');end
            else; should_show_legend=true; end
        else; if ~isempty(existing_legend)&&isvalid(existing_legend);safe_set(existing_legend,'Visible','off');end; end
    end
end

leg_handle_to_use=[];
if should_show_legend
    if ~isempty(existing_legend)&&isvalid(existing_legend); leg_handle_to_use=existing_legend; log_message(params,sprintf('  Updating existing legend for Axes (Tag: %s).',ax.Tag),2,'Info');
    else % Create new legend
        if ~isempty(plottable_children_for_legend)
            valid_plot_children = plottable_children_for_legend(arrayfun(@isvalid, plottable_children_for_legend));
            if ~isempty(valid_plot_children)
                try; leg_handle_to_use=legend(ax, valid_plot_children); log_message(params,sprintf('  Created new legend for Axes (Tag: %s).',ax.Tag),2,'Info');
                catch ME_leg_create; log_message(params,sprintf('  Could not create legend for Axes (Tag: %s): %s',ax.Tag,ME_leg_create.message),1,'Warning'); end
            end
        end
    end
end

if ~isempty(leg_handle_to_use)&&isvalid(leg_handle_to_use)
    leg_props.FontSize=round(fs*0.93); leg_props.Box=params.axis_box_style; leg_props.LineWidth=alw*0.85;
    leg_props.TextColor=params.text_color; leg_props.EdgeColor=params.axis_color*0.85; leg_props.FontName=params.font_name;
    leg_props.Visible='on'; leg_props.Location=params.legend_location;
    if params.legend_num_columns > 0 && isprop(leg_handle_to_use,'NumColumns'); leg_props.NumColumns=params.legend_num_columns; end

    % REFINEMENT: Streamlined interpreter logic
    current_interpreter = 'tex'; % Default
    if isprop(leg_handle_to_use, 'Interpreter') && isprop(leg_handle_to_use, 'String')
        legend_strings = leg_handle_to_use.String;
        if ~iscell(legend_strings); legend_strings = {legend_strings}; end % Ensure cell for uniform processing

        use_latex_for_legend_strings = false;
        if params.auto_latex_interpreter_for_labels % Master switch for auto-detection
            for k_str = 1:numel(legend_strings) % Use numel for robustness with cells
                if ~isempty(legend_strings{k_str}) && contains_latex_chars(legend_strings{k_str}, params)
                    use_latex_for_legend_strings = true;
                    break;
                end
            end
        end
        if use_latex_for_legend_strings; current_interpreter = 'latex'; end
        leg_props.Interpreter = current_interpreter;
    end

    if isprop(leg_handle_to_use,'Title')
        if ~isempty(params.legend_title_string)
            safe_set(leg_handle_to_use.Title, 'String', params.legend_title_string, 'Visible', 'on');
            process_text_prop(leg_handle_to_use.Title,params.legend_title_string,round(leg_props.FontSize*1.05),'bold',params.text_color,params.font_name,params);
        else; safe_set(leg_handle_to_use.Title, 'Visible', 'off'); end
    end
    safe_set(leg_handle_to_use,leg_props);

    if params.interactive_legend && isprop(leg_handle_to_use, 'ItemHitFcn') && verLessThan('matlab','9.7') == 0 % R2019b+ for ItemHitFcn
        try; if ~isempty(leg_handle_to_use.ItemHitFcn);leg_handle_to_use.ItemHitFcn='';end % Clear previous
            leg_handle_to_use.ItemHitFcn=@(src,evt)toggle_plot_visibility_adv(src,evt,params);
            if ~isappdata(leg_handle_to_use,'OriginalVisibilityStates')&&isprop(leg_handle_to_use,'PlotChildren')&&~isempty(leg_handle_to_use.PlotChildren)
                valid_children = leg_handle_to_use.PlotChildren(arrayfun(@isvalid, leg_handle_to_use.PlotChildren));
                orig_vis=arrayfun(@(h)get(h,'Visible'), valid_children,'UniformOutput',false);
                setappdata(leg_handle_to_use,'OriginalVisibilityStates',orig_vis);setappdata(leg_handle_to_use,'IsolationModeActive',false);
            end; log_message(params,sprintf('  Interactive legend enabled for Axes (Tag: %s).',ax.Tag),2,'Info');
        catch ME_leg_int; log_message(params,sprintf('Could not set interactive legend: %s',ME_leg_int.message),1,'Warning');end
    elseif params.interactive_legend && verLessThan('matlab','9.7') == 1
        log_message(params, 'Interactive legend (ItemHitFcn) requires MATLAB R2019b or newer.', 1, 'Info');
    end
end
IGNORE_WHEN_COPYING_START
content_copy
download
Use code with caution.
IGNORE_WHEN_COPYING_END

catch ME_legend
log_message(params, sprintf('Error processing legend for Axes (Tag: %s): %s', ax.Tag, ME_legend.message), 1, 'Warning');
end
end

% --- Helper Function: Beautify Colorbar ---
function beautify_colorbar(ax, params, fs, lfs, alw)
try
cb=[]; fig_handle=ancestor(ax,'figure');
if ~isvalid(fig_handle); return; end
all_colorbars=findobj(fig_handle,'Type','colorbar');
for cb_idx=1:length(all_colorbars)
current_cb = all_colorbars(cb_idx); if ~isvalid(current_cb); continue; end
cb_ax_prop=[];
if isprop(current_cb,'Axes'); cb_ax_prop=current_cb.Axes; % R2022a+
elseif isprop(current_cb,'Axle') && isprop(current_cb.Axle,'Peer'); cb_ax_prop=current_cb.Axle.Peer; % Older
end
if ~isempty(cb_ax_prop) && any(cb_ax_prop == ax); cb=current_cb; break; end
end
if isempty(cb) && isprop(ax,'Colorbar') && isvalid(ax.Colorbar); cb=ax.Colorbar; end

if ~isempty(cb) && isvalid(cb)
    cb=cb(1); % Take the first one if multiple (should not happen for a single axes peer)
    safe_set(cb, 'FontSize', round(fs*0.9), 'LineWidth', alw*0.85, 'Color', params.axis_color, 'TickDirection', 'out');
    if isprop(cb,'Label') && isvalid(cb.Label)
        process_text_prop(cb.Label,cb.Label.String,lfs,'normal',params.text_color,params.font_name,params);
    end
end
IGNORE_WHEN_COPYING_START
content_copy
download
Use code with caution.
IGNORE_WHEN_COPYING_END

catch ME_colorbar
log_message(params, sprintf('Error processing colorbar for Axes (Tag: %s): %s', ax.Tag, ME_colorbar.message), 1, 'Warning');
end
end

% --- Helper Function: Process Text Properties (Title, Labels, etc.) ---
function process_text_prop(text_handle, original_str, font_size, font_weight, color, font_name, params, force_latex_off_for_this)
if nargin < 8; force_latex_off_for_this = false; end
if isempty(text_handle) || ~isvalid(text_handle); return; end

try
fixed_str = format_text_string(original_str);
is_truly_empty = (ischar(original_str)&&isempty(original_str))||(iscell(original_str)&&(isempty(original_str)||all(cellfun('isempty',original_str))))||(isstring(original_str)&&(isempty(original_str)||all(original_str=="")));

if isempty(fixed_str) && is_truly_empty
    if isprop(text_handle,'Visible'); safe_set(text_handle,'Visible','off'); end; return;
else
    if isprop(text_handle,'Visible'); safe_set(text_handle,'Visible','on'); end;
end

safe_set(text_handle,'String',fixed_str,'FontName',font_name,'FontSize',max(1,font_size),'FontWeight',font_weight,'Color',color);
if isprop(text_handle,'Interpreter')
    should_use_latex = false;
    if ~force_latex_off_for_this
        % The contains_latex_chars function itself checks params.force_latex_if_dollar_present
        if params.auto_latex_interpreter_for_labels && contains_latex_chars(fixed_str,params)
            should_use_latex = true;
        end
    end
    if should_use_latex; safe_set(text_handle, 'Interpreter', 'latex'); else; safe_set(text_handle, 'Interpreter', 'tex'); end
end
IGNORE_WHEN_COPYING_START
content_copy
download
Use code with caution.
IGNORE_WHEN_COPYING_END

catch ME_text_prop
log_message(params, sprintf('Error setting text property (String: "%s"): %s', char(original_str), ME_text_prop.message), 1, 'Warning');
end
end

% --- Helper Function: Check if String Contains LaTeX Characters ---
function tf = contains_latex_chars(str_in, params)
tf = false;
if isempty(str_in)||~ischar(str_in)&&~isstring(str_in)&&~iscell(str_in);return;end
if iscell(str_in);str_in=strjoin(str_in(~cellfun('isempty',str_in)),' ');else;str_in=char(str_in);end
if isempty(str_in);return;end

latex_patterns={'\','_','^'}; tf=any(cellfun(@(p)contains(str_in,p),latex_patterns));
if ~tf && contains(str_in,'') % Check for \command or \symbol
if ~isempty(regexp(str_in,'\[a-zA-Z]+','once'));tf=true;
elseif ~isempty(regexp(str_in,'\[^a-zA-Z0-9\s]','once')); tf=true;end % \ followed by non-alphanumeric, non-space
end
if params.force_latex_if_dollar_present && (contains(str_in,'
') || (contains(str_in,'
')))
tf = true;
end
end

% --- Helper Function: Format Multi-line/Cell Strings ---
function fixed_str = format_text_string(original_str)
if iscell(original_str);non_empty_cells=original_str(~cellfun('isempty',original_str));
if isempty(non_empty_cells);fixed_str='';else;fixed_str=strjoin(non_empty_cells,'\newline');end
elseif isstring(original_str);if isempty(original_str)||all(strlength(original_str)==0);fixed_str='';else;fixed_str=join(original_str,'\newline');fixed_str=fixed_str{1};end % Handle string array
else;fixed_str=original_str;end
end

% --- Helper Function: Expand Axis Limits ---
function expand_axis_lims(ax,limit_prop_name,factor)
try
current_lim=get(ax,limit_prop_name);
if diff(current_lim) < 1e-9 || ~all(isfinite(current_lim));return;end % Avoid division by zero or NaN issues

scale_prop_name=[limit_prop_name(1) 'Scale'];is_log=false;
if isprop(ax,scale_prop_name)&&strcmpi(get(ax,scale_prop_name),'log');is_log=true;end

if is_log
    if all(current_lim>0);log_lim=log10(current_lim);range=diff(log_lim);
        if range < 1e-9; range = abs(log_lim(1))*0.1 + 1e-9; end % Handle very small log range
        new_lim_log = [log_lim(1)-range*factor, log_lim(2)+range*factor];
        new_lim = 10.^new_lim_log;
        if new_lim(1)<=0;new_lim(1)=current_lim(1)*(1-factor*0.8);end; % Be more conservative with log lower bound
        if new_lim(1)<=0;new_lim(1)=min(current_lim(current_lim>0))/2; end % Fallback
        if new_lim(1)<=0;new_lim(1)=eps(class(current_lim(1)));end
    else;return;end % Cannot expand log limits if not all positive
else
    range=diff(current_lim);
    if range < 1e-9; range = abs(current_lim(1))*0.1 + 1e-9; end % Handle very small linear range
    new_lim=[current_lim(1)-range*factor, current_lim(2)+range*factor];
    if abs(current_lim(1))<1e-9 && new_lim(1)<0;new_lim(1)=0;end; % Keep zero if originally zero
    if abs(current_lim(2))<1e-9 && new_lim(2)>0;new_lim(2)=0;end;
end
if all(isfinite(new_lim))&&new_lim(2)>new_lim(1);safe_set(ax,limit_prop_name,new_lim);end
IGNORE_WHEN_COPYING_START
content_copy
download
Use code with caution.
IGNORE_WHEN_COPYING_END

catch ME_expand
% log_message called from beautify_single_axes if needed
end
end

% --- Helper Function: Check for Geographic Axes ---
function tf = isgeoaxes(ax);tf=isa(ax,'matlab.graphics.axis.GeographicAxes')||(isprop(ax,'Type')&&strcmpi(ax.Type,'geoaxes'));end

% --- Helper Function: Advanced Interactive Legend Callback ---
function toggle_plot_visibility_adv(legend_handle,event_data,params)
try
clicked_plot_object=event_data.Peer;if~isvalid(clicked_plot_object);return;end
fig_handle=ancestor(legend_handle,'figure');modifier_keys=get(fig_handle,'CurrentModifier');
is_ctrl_cmd_pressed=any(strcmpi(modifier_keys,'control'))||any(strcmpi(modifier_keys,'command'));

all_legend_plots=[];
if isprop(legend_handle,'PlotChildren'); all_legend_plots=legend_handle.PlotChildren(arrayfun(@isvalid, legend_handle.PlotChildren)); end % Filter valid
if isempty(all_legend_plots);log_message(params,'Interactive legend: No valid PlotChildren found.',1,'Warning');return;end

original_vis_states=getappdata(legend_handle,'OriginalVisibilityStates');
isolation_active=getappdata(legend_handle,'IsolationModeActive');if isempty(isolation_active);isolation_active=false;end

if is_ctrl_cmd_pressed
    if isolation_active&&isappdata(legend_handle,'IsolatedObject')&&getappdata(legend_handle,'IsolatedObject')==clicked_plot_object
        for k=1:length(all_legend_plots);if k<=length(original_vis_states);safe_set(all_legend_plots(k),'Visible',original_vis_states{k});end;end
        setappdata(legend_handle,'IsolationModeActive',false);rmappdata(legend_handle,'IsolatedObject');log_message(params,'Legend: Isolation mode deactivated.',2,'Info');
    else
        for k=1:length(all_legend_plots)
            if all_legend_plots(k)==clicked_plot_object;safe_set(all_legend_plots(k),'Visible','on');else;safe_set(all_legend_plots(k),'Visible','off');end
        end
        setappdata(legend_handle,'IsolationModeActive',true);setappdata(legend_handle,'IsolatedObject',clicked_plot_object);
        obj_disp_name = ''; if isprop(clicked_plot_object,'DisplayName'); obj_disp_name = get(clicked_plot_object,'DisplayName'); end
        log_message(params,sprintf('Legend: Object "%s" isolated.',obj_disp_name),2,'Info');
    end
else
    if isolation_active
        for k=1:length(all_legend_plots);if k<=length(original_vis_states);safe_set(all_legend_plots(k),'Visible',original_vis_states{k});end;end
        setappdata(legend_handle,'IsolationModeActive',false);if isappdata(legend_handle,'IsolatedObject');rmappdata(legend_handle,'IsolatedObject');end
        log_message(params,'Legend: Isolation mode deactivated by normal click.',2,'Info');
    end
    % Regular toggle after deactivating isolation (if any)
    current_visibility=get(clicked_plot_object,'Visible');
    if strcmpi(current_visibility,'on');safe_set(clicked_plot_object,'Visible','off');else;safe_set(clicked_plot_object,'Visible','on');end
    % Update original_vis_states if not in isolation mode when click happened
    if ~isolation_active && ~isempty(original_vis_states)
        idx=find(all_legend_plots==clicked_plot_object,1);
        if ~isempty(idx)&&idx<=length(original_vis_states);original_vis_states{idx}=get(clicked_plot_object,'Visible');end
        setappdata(legend_handle,'OriginalVisibilityStates',original_vis_states);
    end
end
update_legend_item_appearance(legend_handle,params);
IGNORE_WHEN_COPYING_START
content_copy
download
Use code with caution.
IGNORE_WHEN_COPYING_END

catch ME_interactive_leg
log_message(params, sprintf('Error in interactive legend callback: %s', ME_interactive_leg.message), 1, 'Warning');
end
end

% --- Helper Function: Update Legend Item Appearance (Fade/Unfade) ---
function update_legend_item_appearance(legend_handle,params)
try
if ~isprop(legend_handle,'PlotChildren')||isempty(legend_handle.PlotChildren)||...
~isprop(legend_handle,'EntryContainer')||~isprop(legend_handle.EntryContainer,'Children')
return;
end

plot_objects=legend_handle.PlotChildren(arrayfun(@isvalid, legend_handle.PlotChildren)); % Valid plot objects
legend_entries=legend_handle.EntryContainer.Children;
num_to_process=min(length(plot_objects),length(legend_entries));

for i=1:num_to_process
    entry=legend_entries(i);corresponding_plot=plot_objects(i);
    if~isvalid(entry)||~isvalid(corresponding_plot);continue;end

    is_plot_visible=strcmpi(get(corresponding_plot,'Visible'),'on');

    if isprop(entry,'Label')&&isprop(entry.Label,'Color')
        if is_plot_visible; safe_set(entry.Label,'Color',params.text_color);
        else; safe_set(entry.Label,'Color',params.text_color*0.4+0.5);end % Faded color
    end

    if isprop(entry,'Icon') && isprop(entry.Icon,'Children')
        icon_parts=entry.Icon.Children;
        for ip_idx=1:length(icon_parts)
            part=icon_parts(ip_idx); if ~isvalid(part); continue; end

            % Attempt to get original color from plot object
            original_part_color = [];
            if isprop(corresponding_plot, 'Color') && ~ischar(corresponding_plot.Color)
                original_part_color = corresponding_plot.Color;
            elseif isprop(corresponding_plot, 'MarkerFaceColor') && ~ischar(corresponding_plot.MarkerFaceColor) && ~strcmpi(corresponding_plot.MarkerFaceColor, 'none')
                original_part_color = corresponding_plot.MarkerFaceColor;
            elseif isprop(corresponding_plot, 'MarkerEdgeColor') && ~ischar(corresponding_plot.MarkerEdgeColor) && ~strcmpi(corresponding_plot.MarkerEdgeColor, 'none')
                original_part_color = corresponding_plot.MarkerEdgeColor;
            end
            if isempty(original_part_color); original_part_color = params.axis_color; end % Fallback

            alpha_val = 1.0; if ~is_plot_visible; alpha_val = 0.3; end

            % This part is tricky as Icon parts are complex. Focus on Color and Alpha if available.
            if isprop(part, 'Color') && ~ischar(part.Color)
                safe_set(part, 'Color', original_part_color); % Set base color first
                if isprop(part, 'ColorAlpha'); safe_set(part,'ColorAlpha', alpha_val); % R2022a+ for Line
                elseif isprop(part, 'FaceAlpha') && ~ischar(part.FaceColor); safe_set(part, 'FaceAlpha', alpha_val); % For patches in icon
                elseif isprop(part, 'EdgeAlpha'); safe_set(part, 'EdgeAlpha', alpha_val);
                end
            end
            % For older MATLAB, direct alpha on icon parts might not work well.
            % Fading color might be an alternative but less ideal.
            if isprop(part, 'Visible'); safe_set(part, 'Visible', 'on'); end % Ensure visible
        end
    end
end
IGNORE_WHEN_COPYING_START
content_copy
download
Use code with caution.
IGNORE_WHEN_COPYING_END

catch ME_leg_appearance
log_message(params, sprintf('Error updating legend item appearance: %s', ME_leg_appearance.message),1,'Warning');
end
end

% --- Helper Function: Safely Set Graphics Property ---
function safe_set(handle, varargin)
try
% Only set if property exists and new value is different (for non-color props)
for i = 1:2:length(varargin)
prop_name = varargin{i};
new_val = varargin{i+1};
if isprop(handle, prop_name)
current_val = get(handle, prop_name);
% For colors, isequal is fine. For other things, direct comparison or specific checks.
% This reduces unnecessary graphics updates.
if ~isequal(current_val, new_val)
set(handle, prop_name, new_val);
end
end
end
catch ME_set
% Suppress errors during set if handle is invalid or prop is bad,
% as the main function's try-catch will handle major issues.
% Or, log it at a very verbose level if needed.
% log_message(params_struct_if_available, sprintf('safe_set failed for %s: %s', prop_name, ME_set.message), 3, 'Debug');
end
end

% --- Helper Function: Safely Hold Axes ---
function safe_hold(ax_handle, state)
try
if isvalid(ax_handle) && isprop(ax_handle, 'NextPlot')
current_nextplot = get(ax_handle, 'NextPlot');
if strcmpi(state, 'on') && ~strcmpi(current_nextplot, 'add')
set(ax_handle, 'NextPlot', 'add');
elseif strcmpi(state, 'off') && ~strcmpi(current_nextplot, 'replace')
set(ax_handle, 'NextPlot', 'replace');
end
end
catch ME_hold
% log_message(params_struct_if_available, sprintf('safe_hold failed: %s', ME_hold.message), 1, 'Warning');
end
end

% --- Helper Function: Log Message ---
function log_message(params_struct, message_str, level, type_str)
if nargin < 4; type_str = 'Info'; end % Default type
if isfield(params_struct, 'log_level') && params_struct.log_level >= level
fprintf('[BeautifyFig - %s L%d] %s\n', type_str, level, message_str);
end
end

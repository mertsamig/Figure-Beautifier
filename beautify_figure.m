function beautify_figure(varargin)
% BEAUTIFY_FIGURE Enhances the aesthetics of the current MATLAB figure.
%
% SYNTAX:
%   beautify_figure('param1', value1, 'param2', value2, ...)
%       Applies beautification settings to the current figure (gcf) using
%       name-value pairs.
%
%   beautify_figure('figure_handle', fig_handle, 'param1', value1, ...)
%       Applies beautification to the specified figure handle.
%
% DESCRIPTION:
%   (The rest of the description is unchanged)
%
%   NOTE: The old calling syntaxes beautify_figure(fig_handle) and
%   beautify_figure(params_struct) are deprecated in favor of name-value pairs.
%
% PARAMETERS (Name-Value Pairs):
%   - 'figure_handle': (handle) A valid figure handle to target. Defaults to gcf.
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
%                    'viridis', 'turbo', 'cividis', etc.) or an Nx3 RGB matrix.
%   - cycle_marker_styles: 'auto' (default), true, false. Controls marker cycling.
%   - cycle_line_styles: 'auto' (default), true, false. Controls line style cycling.
%   - grid_density: 'normal' (default), 'major_only', 'none'.
%   - axis_box_style: 'on' (default), 'off', 'left-bottom'.
%   - axes_layer: 'top' (default), 'bottom'. Sets axes Layer property.
%   - legend_location: 'best' (default), 'northeastoutside', 'none', etc.
%   - smart_legend_display: true (default). Avoids unnecessary legends.
%   - interactive_legend: true (default). Enables clickable legend items.
%   - log_level: 0 (silent), 1 (normal), 2 (detailed - default).
%   - export_settings: Structure for controlling figure export (see details below).
%   - stats_overlay: (struct) Settings for statistical data overlay (see details below).
%     - Note: Statistics are calculated based on the data currently visible within the axes limits (e.g., after zooming).
%   ... and many more. Explore the default_parameters structure within the code.
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
% See also: gcf, legend, tiledlayout, axes, plot, set, get, test_beautify_figure, BeautifyFigureTest


% --- Default Beautification Parameters ---
% These are the master defaults. They can be overridden by user_params.
default_parameters.font_name = 'Swiss 721 BT'; % A common sans-serif, often needs to be installed or substituted
default_parameters.base_font_size = 10;
default_parameters.global_font_scale_factor = 1.0;
default_parameters.title_scale = 1.2;
default_parameters.label_scale = 1.0;

default_parameters.plot_line_width = 1.5;
default_parameters.axis_to_plot_linewidth_ratio = 0.5;
default_parameters.marker_size = 6; % In points
default_parameters.errorbar_cap_size_scale = 0.5;

% Theme-dependent defaults (will be adjusted if 'dark' theme is chosen)
default_parameters.axis_color = [0.15 0.15 0.15];
default_parameters.figure_background_color = get(0, 'DefaultFigureColor'); % Use MATLAB's default
default_parameters.text_color = [0.15 0.15 0.15];
default_parameters.grid_color = [0.15 0.15 0.15];

default_parameters.grid_density = 'normal';
default_parameters.grid_alpha = 0.15;
default_parameters.grid_line_style = '-';
default_parameters.minor_grid_alpha = 0.07;
default_parameters.minor_grid_line_style = ':';
default_parameters.axis_box_style = 'on';
default_parameters.axes_layer = 'top'; % NEW: 'top' or 'bottom'

default_parameters.color_palette = 'default_matlab';
default_parameters.custom_color_palette = [];
default_parameters.cycle_marker_styles = 'auto';
default_parameters.marker_cycle_threshold = 3; % Cycle if num candidates > this value
default_parameters.marker_styles = {'o', 's', 'd', '^', 'v', '>', '<', 'p', 'h', '.', 'x', '+', '*'};
default_parameters.line_style_order = {'-', '--', ':', '-.'}; % NEW
default_parameters.cycle_line_styles = 'auto'; % NEW: true, false, 'auto'
default_parameters.line_style_cycle_threshold = 2; % NEW: cycle if num candidates > this value when 'auto'

default_parameters.axis_limit_mode = 'padded';
default_parameters.expand_axis_limits_factor = 0.03;

default_parameters.legend_location = 'best';
default_parameters.smart_legend_display = true;
default_parameters.legend_force_single_entry = false;
default_parameters.legend_title_string = '';
default_parameters.interactive_legend = true; % Requires R2019b+ for ItemHitFcn
default_parameters.legend_num_columns = 0;
default_parameters.legend_reverse_order = false;

default_parameters.apply_to_colorbars = true;
default_parameters.apply_to_polaraxes = true;
default_parameters.apply_to_general_text = true;
default_parameters.beautify_sgtitle = true;

default_parameters.scaling_map = containers.Map(...
    {1,  2,  3,  4,  6,  8,  9,  12, 16, 20, 25}, ...
    {1.6,1.5,1.4,1.3,1.15,1.05,1.0,0.9,0.8,0.75,0.7} ...
    );
default_parameters.min_scale_factor = 0.65;
default_parameters.max_scale_factor = 1.7;
default_parameters.log_level = 2; % 0:silent, 1:normal (warnings, info), 2:detailed (verbose)

% Export settings
default_parameters.export_settings.enabled = false;
default_parameters.export_settings.filename = 'beautified_figure';
default_parameters.export_settings.format = 'png'; % Suggested: 'png', 'jpeg', 'pdf', 'eps', 'tiff', 'svg'
default_parameters.export_settings.resolution = 300; % DPI
default_parameters.export_settings.open_exported_file = false;
default_parameters.export_settings.renderer = 'painters'; % Suggested: 'painters', 'opengl', 'vector' (for print), 'auto' for exportgraphics
default_parameters.export_settings.ui = false; % If true, tries to use exportgraphics, else print -noui

default_parameters.style_preset = 'default';

% Basic Statistical Overlay
default_parameters.stats_overlay.enabled = false;
default_parameters.stats_overlay.statistics = {'mean', 'std'}; % Cell array: 'mean', 'std', 'min', 'max', 'N', 'median', 'sum'
default_parameters.stats_overlay.position = 'northeast_inset'; % Options like panel_labeling, or 'best_text', 'manual_normalized_coords'
default_parameters.stats_overlay.precision = 2; % Decimal places
default_parameters.stats_overlay.text_color = []; % Inherits
default_parameters.stats_overlay.font_name = []; % Inherits
default_parameters.stats_overlay.font_scale_factor = 0.9; % Relative to axes label font size
default_parameters.stats_overlay.background_color = []; % Default none. Can be 'figure' or a color spec.
default_parameters.stats_overlay.edge_color = []; % Default none. Can be 'axes' or a color spec.
default_parameters.stats_overlay.target_plot_handle_tag = ''; % Tag of specific plot to analyze, empty for first valid
default_parameters.exclude_object_tags = {}; % Cell array of strings (tags) to exclude

% Store the original defaults before any modifications
base_default_parameters = default_parameters;

% --- Parameter Parsing and Initialization ---
input_parser = inputParser;

% Add figure_handle as an optional name-value pair
addParameter(input_parser, 'figure_handle', [], @(h) ishghandle(h) && isgraphics(h, 'figure') && isvalid(h));

% Add all other parameters from the default_parameters struct
default_parameter_names = fieldnames(default_parameters);
for parameter_index = 1:length(default_parameter_names)
    parameter_name = default_parameter_names{parameter_index};
    default_value = default_parameters.(parameter_name);
    addParameter(input_parser, parameter_name, default_value);
end

% Parse the inputs
parse(input_parser, varargin{:});
params = input_parser.Results;

% Handle the figure handle logic
if isempty(params.figure_handle)
    figure_handle = gcf;
else
    figure_handle = params.figure_handle;
end

% Check for valid figure handle one last time
if isempty(figure_handle) || ~isvalid(figure_handle)
    log_message(default_parameters, 'No valid figure available. Cannot proceed.', 0, 'Error');
    return;
end

% PERFORMANCE: Pre-find all legends and colorbars in the figure once to avoid
% repeated `findobj` calls within loops.
params.all_legends_in_figure = findobj(figure_handle, 'Type', 'Legend');
params.all_colorbars_in_figure = findobj(figure_handle, 'Type', 'Colorbar');


% The old logic for merging user_provided_parameters_struct is no longer needed,
% as inputParser handles the merging of defaults and user-provided values.
% The 'params' struct is now the definitive set of parameters.

% For compatibility with later code that checks for user-provided-only
% parameters (like style_preset), we reconstruct a struct containing only
% the parameters the user actually passed in.
all_parameter_names = fieldnames(input_parser.Results);
defaulted_parameter_names = input_parser.UsingDefaults;
user_provided_parameter_names = setdiff(all_parameter_names, defaulted_parameter_names);
user_provided_parameters_struct = struct();
for user_parameter_index = 1:length(user_provided_parameter_names)
    parameter_name = user_provided_parameter_names{user_parameter_index};
    if isfield(input_parser.Results, parameter_name)
        user_provided_parameters_struct.(parameter_name) = input_parser.Results.(parameter_name);
    end
end

% The inputParser has already merged defaults and user-provided values.
% Now, we handle the style preset, which acts as a conditional set of
% different defaults. The logic is: if a parameter is part of a preset,
% apply the preset's value, but ONLY if the user did not provide that parameter.

active_preset_name = params.style_preset;
known_presets = {'default', 'publication', 'presentation_dark', 'presentation_light', 'minimalist'};
if ~any(strcmp(active_preset_name, known_presets))
    log_message(params, sprintf('Unknown style preset: "%s". Applying default style parameters.', active_preset_name), 1, 'Warning');
    active_preset_name = 'default';
end

% Helper to apply a value from a preset only if the user did not specify it.

    %APPLY_PRESET_VALUE Applies a preset value if not overridden by the user.
    %   This is a nested helper function that checks if a given parameter
    %   is using its default value (i.e., was not specified by the user).
    %   If it is, the function updates the 'params' struct in the parent
    %   workspace with the new value from the style preset.
    %
    %   INPUTS:
    %       parameter_name: (char/string) The name of the parameter.
    %       value:      (any) The value to apply from the preset.
    function apply_preset_value(parameter_name, value)
        if ismember(parameter_name, input_parser.UsingDefaults)
            params.(parameter_name) = value;
        end
    end

log_message(params, sprintf('Applying style preset: "%s".', active_preset_name), 2, 'Info');
switch active_preset_name
    case 'publication'
        apply_preset_value('font_name', 'Arial');
        apply_preset_value('base_font_size', 10);
        apply_preset_value('global_font_scale_factor', 1.0);
        apply_preset_value('plot_line_width', 1.0);
        apply_preset_value('axis_to_plot_linewidth_ratio', 0.75);
        apply_preset_value('marker_size', 5);
        apply_preset_value('color_palette', 'lines');
        apply_preset_value('grid_density', 'major_only');
        apply_preset_value('axis_color', [0 0 0]);
        apply_preset_value('figure_background_color', [1 1 1]);
        apply_preset_value('text_color', [0 0 0]);
        apply_preset_value('grid_color', [0.5 0.5 0.5]);
        apply_preset_value('axes_layer', 'bottom');
        apply_preset_value('legend_location', 'best');

    case 'presentation_light'
        apply_preset_value('font_name', 'Calibri');
        apply_preset_value('base_font_size', 12);
        apply_preset_value('global_font_scale_factor', 1.1);
        apply_preset_value('plot_line_width', 1.8);
        apply_preset_value('marker_size', 6);
        apply_preset_value('color_palette', 'turbo');
        apply_preset_value('grid_density', 'normal');
        apply_preset_value('figure_background_color', [0.96 0.96 0.98]);
        apply_preset_value('axis_color', [0.15 0.15 0.15]);
        apply_preset_value('text_color', [0.1 0.1 0.1]);
        apply_preset_value('grid_color', [0.25 0.25 0.25]);
        apply_preset_value('grid_alpha', 0.15);
        apply_preset_value('minor_grid_alpha', 0.07);

    case 'presentation_dark'
        apply_preset_value('font_name', 'Calibri');
        apply_preset_value('base_font_size', 14);
        apply_preset_value('global_font_scale_factor', 1.15);
        apply_preset_value('plot_line_width', 2.0);
        apply_preset_value('marker_size', 7);
        apply_preset_value('color_palette', 'viridis');
        apply_preset_value('figure_background_color', [0.1 0.1 0.15]);
        apply_preset_value('axis_color', [0.9 0.9 0.9]);
        apply_preset_value('text_color', [0.9 0.9 0.9]);
        apply_preset_value('grid_color', [0.7 0.7 0.7]);
        apply_preset_value('grid_alpha', 0.2);
        apply_preset_value('axes_layer', 'top');
        apply_preset_value('grid_density', 'normal');

    case 'minimalist'
        try % Helvetica Neue might not be available
            apply_preset_value('font_name', 'Helvetica Neue');
        catch
            apply_preset_value('font_name', 'Helvetica'); % Fallback
        end
        apply_preset_value('base_font_size', 10);
        apply_preset_value('plot_line_width', 1.2);
        apply_preset_value('marker_size', 5);
        apply_preset_value('color_palette', [[0.2 0.2 0.2]; [0.5 0.5 0.5]; [0.7 0.7 0.7]]);
        apply_preset_value('grid_density', 'none');
        apply_preset_value('axis_box_style', 'left-bottom');
        apply_preset_value('smart_legend_display', true);
        apply_preset_value('legend_location', 'northeastoutside');
        apply_preset_value('figure_background_color', [1 1 1]);
        apply_preset_value('axis_color', [0.1 0.1 0.1]);
        apply_preset_value('text_color', [0.1 0.1 0.1]);
        apply_preset_value('title_scale', 1.0);
        apply_preset_value('label_scale', 1.0);

    case 'default'
        % No changes needed.
end

% --- START Critical Parameter Validation (Top-level) ---
log_message(params, 'Performing critical parameter validation...', 2, 'Info');

% Helper function to format value for logging
    function value_as_string = format_param_value_for_log(value)
        if isnumeric(value)
            if isscalar(value)
                value_as_string = num2str(value);
            else
                value_as_string = mat2str(value); % For arrays
            end
        elseif ischar(value)
            value_as_string = ['''' value ''''];
        elseif isstring(value) && isscalar(value)
            value_as_string = ['"' char(value) '"'];
        elseif isstring(value) % array of strings
            value_as_string = '[';
            for string_index = 1:numel(value)
                value_as_string = [value_as_string '"' char(value(string_index)) '"'];
                if string_index < numel(value); value_as_string = [value_as_string ', ']; end
            end
            value_as_string = [value_as_string ']'];
        elseif islogical(value)
            if value; value_as_string = 'true'; else; value_as_string = 'false'; end
        elseif iscell(value)
            value_as_string = '{';
            for cell_index = 1:min(5,numel(value)) % Show first few elements
                value_as_string = [value_as_string format_param_value_for_log(value{cell_index})];
                if cell_index < min(5,numel(value)); value_as_string = [value_as_string ', ']; end
            end
            if numel(value) > 5; value_as_string = [value_as_string, '...']; end
            value_as_string = [value_as_string '} (' num2str(numel(value)) ' elements)'];
        elseif isstruct(value)
            value_as_string = ['[struct with fields: ' strjoin(fieldnames(value),', ') ']'];
        else
            try
                value_as_string = ['[' class(value) ']'];
            catch
                value_as_string = '[unknown type]';
            end
        end
    end


% Helper function to validate numeric scalar parameters
    function validate_numeric_scalar(parameter_name)
        current_value = params.(parameter_name);
        if ~isnumeric(current_value) || ~isscalar(current_value) || ~isreal(current_value) || isnan(current_value)
            value_as_string = format_param_value_for_log(current_value);
            log_message(params, sprintf('Invalid value for %s: %s. Must be a real numeric scalar. Resetting to default (%s).', ...
                parameter_name, value_as_string, format_param_value_for_log(base_default_parameters.(parameter_name))), 1, 'Warning');
            params.(parameter_name) = base_default_parameters.(parameter_name);
        end
    end

% Numeric scalar parameters to validate
validate_numeric_scalar('base_font_size');
validate_numeric_scalar('global_font_scale_factor');
validate_numeric_scalar('plot_line_width');
validate_numeric_scalar('marker_size');
validate_numeric_scalar('log_level');

% font_name validation
current_font_name_value = params.font_name;
if ~(ischar(current_font_name_value) && (isvector(current_font_name_value) || isempty(current_font_name_value))) && ...
        ~(isstring(current_font_name_value) && isscalar(current_font_name_value))
    value_as_string = format_param_value_for_log(current_font_name_value); % Uses existing helper
    log_message(params, sprintf('Invalid type for font_name: %s. Must be a character string or string scalar. Resetting to default (%s).', ...
        value_as_string, format_param_value_for_log(base_default_parameters.font_name)), 1, 'Warning');
    params.font_name = base_default_parameters.font_name;
end

% Helper function to validate enumerated string parameters
    function validate_enum_parameter(parameter_name, valid_options)
        current_value = params.(parameter_name);
        reset_to_default = false;

        if ~ischar(current_value) || ~isvector(current_value) || isempty(current_value)
            value_as_string = format_param_value_for_log(current_value);
            log_message(params, sprintf('Invalid type for %s: %s. Must be a character string. Resetting to default (%s).', ...
                parameter_name, value_as_string, format_param_value_for_log(base_default_parameters.(parameter_name))), 1, 'Warning');
            reset_to_default = true;
        else
            match_index = find(strcmpi(current_value, valid_options), 1);
            if isempty(match_index)
                value_as_string = format_param_value_for_log(current_value);
                log_message(params, sprintf('Invalid value for %s: %s. Allowed: %s. Resetting to default (%s).', ...
                    parameter_name, value_as_string, strjoin(valid_options, ', '), format_param_value_for_log(base_default_parameters.(parameter_name))), 1, 'Warning');
                reset_to_default = true;
            else
                params.(parameter_name) = valid_options{match_index}; % Ensure canonical form
            end
        end

        if reset_to_default
            params.(parameter_name) = base_default_parameters.(parameter_name);
        end
    end

% String enumerated parameters to validate
validate_enum_parameter('grid_density', {'normal', 'major_only', 'none'});
validate_enum_parameter('axis_box_style', {'on', 'off', 'left-bottom'});
validate_enum_parameter('axes_layer', {'top', 'bottom'});

% Helper function to validate a top-level cell array of strings
    function validate_top_level_cell_array_of_strings(parameter_name)
        current_value = params.(parameter_name);
        is_valid = true;
        if ~iscell(current_value)
            is_valid = false;
        else
            for value_index = 1:length(current_value)
                if ~ischar(current_value{value_index}) || (~isvector(current_value{value_index}) && ~isempty(current_value{value_index}))
                    is_valid = false;
                    break;
                end
            end
        end

        if ~is_valid
            value_as_string = format_param_value_for_log(current_value);
            log_message(params, sprintf('Invalid value for %s: %s. Must be a cell array of character row vectors. Resetting to default (%s).', ...
                parameter_name, value_as_string, format_param_value_for_log(base_default_parameters.(parameter_name))), 1, 'Warning');
            params.(parameter_name) = base_default_parameters.(parameter_name);
        end
    end

% exclude_object_tags validation
validate_top_level_cell_array_of_strings('exclude_object_tags');

log_message(params, 'Critical parameter validation complete.', 2, 'Info');
% --- END Critical Parameter Validation ---

% --- START Sub-Struct Type and Field Validation ---
log_message(params, 'Performing sub-struct validation (type checks, merging, field checks)...', 2, 'Info');

% Helper function to validate a numeric scalar field within a sub-struct
    function params = validate_numeric_scalar_field(params, base_default_parameters, structure_name, field_name, allow_non_negative, allow_positive, require_integer)
        default_value = base_default_parameters.(structure_name).(field_name);
        % Check if field exists in current params, if not, it means user struct didn't have it, so use default
        if ~isfield(params.(structure_name), field_name)
            log_message(params, sprintf('Field %s.%s not found in user/preset parameters. Using default value (%s).', ...
                structure_name, field_name, format_param_value_for_log(default_value)), 2, 'Info');
            params.(structure_name).(field_name) = default_value;
            current_value = default_value; % proceed with validation of default
        else
            current_value = params.(structure_name).(field_name);
        end

        is_valid = true;
        if ~isnumeric(current_value) || ~isscalar(current_value) || ~isreal(current_value) || isnan(current_value)
            is_valid = false;
        elseif allow_non_negative && current_value < 0
            is_valid = false;
        elseif allow_positive && current_value <= 0
            is_valid = false;
        elseif require_integer && (floor(current_value) ~= current_value)
            is_valid = false;
        end

        if ~is_valid
            value_as_string = format_param_value_for_log(current_value);
            criteria_string = 'real numeric scalar';
            if require_integer; criteria_string = [criteria_string ', integer']; end
            if allow_non_negative; criteria_string = [criteria_string ', non-negative']; end
            if allow_positive; criteria_string = [criteria_string ', positive']; end
            log_message(params, sprintf('Invalid value for %s.%s: %s. Must be a %s. Resetting to default (%s).', ...
                structure_name, field_name, value_as_string, criteria_string, format_param_value_for_log(default_value)), 1, 'Warning');
            params.(structure_name).(field_name) = default_value;
        end
    end

% Helper function to validate a logical/boolean field within a sub-struct
    function params = validate_logical_field(params, base_default_parameters, structure_name, field_name)
        default_value = base_default_parameters.(structure_name).(field_name);
        if ~isfield(params.(structure_name), field_name)
            log_message(params, sprintf('Field %s.%s not found in user/preset parameters. Using default value (%s).', ...
                structure_name, field_name, format_param_value_for_log(default_value)), 2, 'Info');
            params.(structure_name).(field_name) = default_value;
            current_value = default_value;
        else
            current_value = params.(structure_name).(field_name);
        end

        if islogical(current_value) && isscalar(current_value)
            % Value is already a scalar logical, no change needed.
        elseif isnumeric(current_value) && isscalar(current_value) && (current_value == 0 || current_value == 1)
            params.(structure_name).(field_name) = logical(current_value); % Cast to logical
        else
            value_as_string = format_param_value_for_log(current_value);
            log_message(params, sprintf('Invalid value for %s.%s: %s. Must be logical (true/false) or numeric (0/1). Resetting to default (%s).', ...
                structure_name, field_name, value_as_string, format_param_value_for_log(default_value)), 1, 'Warning');
            params.(structure_name).(field_name) = default_value;
        end
    end

% Helper function to validate a cell array of char row vectors
    function params = validate_cell_array_of_strings_field(params, base_default_parameters, structure_name, field_name)
        default_value = base_default_parameters.(structure_name).(field_name);
        if ~isfield(params.(structure_name), field_name)
            log_message(params, sprintf('Field %s.%s not found in user/preset parameters. Using default value (%s).', ...
                structure_name, field_name, format_param_value_for_log(default_value)), 2, 'Info');
            params.(structure_name).(field_name) = default_value;
            current_value = default_value;
        else
            current_value = params.(structure_name).(field_name);
        end

        is_valid = true;
        if ~iscell(current_value)
            is_valid = false;
        else
            for value_index = 1:length(current_value)
                if ~ischar(current_value{value_index}) || (~isvector(current_value{value_index}) && ~isempty(current_value{value_index})) % Allow empty char '', but if not empty, must be row vector
                    is_valid = false;
                    break;
                end
            end
        end

        if ~is_valid
            value_as_string = format_param_value_for_log(current_value);
            log_message(params, sprintf('Invalid value for %s.%s: %s. Must be a cell array of character row vectors. Resetting to default (%s).', ...
                structure_name, field_name, value_as_string, format_param_value_for_log(default_value)), 1, 'Warning');
            params.(structure_name).(field_name) = default_value;
        end
    end

% Validate top-level structure types first
sub_structure_names = {'export_settings', 'stats_overlay'};
for sub_structure_index = 1:length(sub_structure_names)
    sub_structure_name = sub_structure_names{sub_structure_index};
    if isfield(params, sub_structure_name) % It should be, from base_default_parameters
        if ~isstruct(params.(sub_structure_name)) % If user overwrote with non-struct, or preset was bad
            value_as_string = format_param_value_for_log(params.(sub_structure_name));
            log_message(params, sprintf('Parameter ''%s'' is not a struct (type: %s). Reverting to default %s settings.', ...
                sub_structure_name, value_as_string, sub_structure_name), 1, 'Warning');
            params.(sub_structure_name) = base_default_parameters.(sub_structure_name);
        end
    else % Should not happen if base_default_parameters is complete
        log_message(params, sprintf('Default parameter for ''%s'' is missing. This is an internal bug. Using empty struct.', sub_structure_name), 0, 'Error');
        params.(sub_structure_name) = struct(); % Failsafe
    end
end

% Special merge for sub-structs like stats_overlay (if user provided partial struct)
% This allows user to specify e.g. user_params.stats_overlay.enabled = true
% without needing to define the whole user_params.stats_overlay struct.
% This step is performed *after* params.stats_overlay is guaranteed to be a struct (from above).
log_message(params, 'Merging user-provided fields for specific sub-structs (e.g., stats_overlay)...', 2, 'Info');
if isfield(user_provided_parameters_struct, 'stats_overlay') && isstruct(user_provided_parameters_struct.stats_overlay)
    % params.stats_overlay is already a struct (either from default/preset, or user's full replacement, or reset if user gave bad type)
    % Now, merge fields from user_provided_parameters_struct.stats_overlay into params.stats_overlay
    user_stats_overlay_fields = fieldnames(user_provided_parameters_struct.stats_overlay);
    for stats_overlay_field_index = 1:length(user_stats_overlay_fields)
        field_to_merge = user_stats_overlay_fields{stats_overlay_field_index};
        if isfield(base_default_parameters.stats_overlay, field_to_merge) % Only merge known fields
            params.stats_overlay.(field_to_merge) = user_provided_parameters_struct.stats_overlay.(field_to_merge);
        else
            log_message(params, sprintf('Unknown field in user-provided stats_overlay: "%s". This field will be ignored.', field_to_merge), 1, 'Warning');
        end
    end
end
log_message(params, 'Sub-struct field merging complete.', 2, 'Info');


% Perform detailed field-by-field validation on the (potentially merged) sub-structs
log_message(params, 'Performing detailed sub-struct FIELD validation...', 2, 'Info');

% export_settings validation
if isstruct(params.export_settings) % Should be true due to earlier type check
    % Ensure all default fields exist in params.export_settings, validate them
    default_export_settings_fields = fieldnames(base_default_parameters.export_settings);
    for export_settings_field_index = 1:length(default_export_settings_fields)
        field_name = default_export_settings_fields{export_settings_field_index};
        % validate_..._field helpers will add default if missing and validate
        switch field_name
            case 'resolution'; params = validate_numeric_scalar_field(params, base_default_parameters, 'export_settings', field_name, true, true, false);
            case {'enabled', 'open_exported_file', 'ui'}; params = validate_logical_field(params, base_default_parameters, 'export_settings', field_name);
            case {'filename', 'format', 'renderer'} % String fields, specific validation if needed
                if ~isfield(params.export_settings, field_name) || ~ischar(params.export_settings.(field_name))
                    log_message(params, sprintf('Field export_settings.%s is missing or not a string. Resetting to default (%s).', field_name, format_param_value_for_log(base_default_parameters.export_settings.(field_name))), 1, 'Warning');
                    params.export_settings.(field_name) = base_default_parameters.export_settings.(field_name);
                elseif strcmp(field_name, 'renderer') % Specific validation for renderer
                    current_renderer_value = params.export_settings.(field_name);
                    valid_renderers = {'painters', 'opengl', 'vector', 'auto', 'zbuffer'};
                    renderer_match_index = find(strcmpi(current_renderer_value, valid_renderers), 1);
                    if isempty(renderer_match_index)
                        value_as_string = format_param_value_for_log(current_renderer_value);
                        log_message(params, sprintf('Invalid value for export_settings.renderer: %s. Allowed: %s. Resetting to default (%s).', ...
                            value_as_string, strjoin(valid_renderers, ', '), format_param_value_for_log(base_default_parameters.export_settings.(field_name))), 1, 'Warning');
                        params.export_settings.(field_name) = base_default_parameters.export_settings.(field_name);
                    else
                        params.export_settings.(field_name) = valid_renderers{renderer_match_index}; % Ensure canonical form
                    end
                end
            otherwise % Unknown field in defaults, internal issue
                log_message(params, sprintf('Unhandled default field in export_settings: %s', field_name), 1, 'Warning');
        end
    end
    % Warn about extra fields provided by user not in defaults
    current_export_settings_fields = fieldnames(params.export_settings);
    extra_export_settings_fields = setdiff(current_export_settings_fields, default_export_settings_fields);
    for extra_field_index = 1:length(extra_export_settings_fields)
        log_message(params, sprintf('Unknown field in params.export_settings: "%s". Ignored.', extra_export_settings_fields{extra_field_index}), 1, 'Warning');
    end
else
    log_message(params, '''params.export_settings'' is unexpectedly not a struct before detailed field validation. This may indicate an internal problem.', 0, 'Error');
    if isfield(base_default_parameters, 'export_settings'); params.export_settings = base_default_parameters.export_settings; end % Attempt recovery
end

% stats_overlay validation
if isstruct(params.stats_overlay)
    default_stats_overlay_fields = fieldnames(base_default_parameters.stats_overlay);
    for stats_overlay_field_index = 1:length(default_stats_overlay_fields)
        field_name = default_stats_overlay_fields{stats_overlay_field_index};
        switch field_name
            case 'font_scale_factor'; params = validate_numeric_scalar_field(params, base_default_parameters, 'stats_overlay', field_name, true, false, false);
            case 'precision'; params = validate_numeric_scalar_field(params, base_default_parameters, 'stats_overlay', field_name, true, false, true);
            case 'enabled'; params = validate_logical_field(params, base_default_parameters, 'stats_overlay', field_name);
            case 'statistics'; params = validate_cell_array_of_strings_field(params, base_default_parameters, 'stats_overlay', field_name);
            case {'target_plot_handle_tag'} % String fields (position handled separately)
                if ~isfield(params.stats_overlay, field_name) || ~ischar(params.stats_overlay.(field_name))
                    log_message(params, sprintf('Field stats_overlay.%s is missing or not a string. Resetting to default (%s).', field_name, format_param_value_for_log(base_default_parameters.stats_overlay.(field_name))), 1, 'Warning');
                    params.stats_overlay.(field_name) = base_default_parameters.stats_overlay.(field_name);
                end
            case 'position' % Specific validation for stats_overlay.position
                if ~isfield(params.stats_overlay, field_name) || ~ischar(params.stats_overlay.(field_name))
                    log_message(params, sprintf('Field stats_overlay.position is missing or not a string. Resetting to default (%s).', format_param_value_for_log(base_default_parameters.stats_overlay.position)), 1, 'Warning');
                    params.stats_overlay.position = base_default_parameters.stats_overlay.position;
                else
                    current_position_value = params.stats_overlay.position;
                    valid_stat_positions = {'northeast_inset', 'northwest_inset', 'southwest_inset', 'southeast_inset'}; % Add more if your apply_stats_overlay supports them
                    position_match_index = find(strcmpi(current_position_value, valid_stat_positions), 1);
                    if isempty(position_match_index)
                        value_as_string = format_param_value_for_log(current_position_value);
                        log_message(params, sprintf('Invalid value for stats_overlay.position: %s. Allowed: %s. Resetting to default (%s).', ...
                            value_as_string, strjoin(valid_stat_positions, ', '), format_param_value_for_log(base_default_parameters.stats_overlay.position)), 1, 'Warning');
                        params.stats_overlay.position = base_default_parameters.stats_overlay.position;
                    else
                        params.stats_overlay.position = valid_stat_positions{position_match_index}; % Ensure canonical form
                    end
                end
            case 'font_name' % Specifically for stats_overlay.font_name
                if ~isfield(params.stats_overlay, field_name)
                    params.stats_overlay.(field_name) = base_default_parameters.stats_overlay.(field_name); % Add if missing
                else % Field is present, validate it
                    value = params.stats_overlay.(field_name);
                    if ~isempty(value) && ~(ischar(value) && (isvector(value) || isempty(value))) && ...
                            ~(isstring(value) && isscalar(value))
                        log_message(params, sprintf('Invalid type for stats_overlay.font_name: %s. Must be char/string or empty. Resetting to default empty value.', format_param_value_for_log(value)), 1, 'Warning');
                        params.stats_overlay.(field_name) = base_default_parameters.stats_overlay.(field_name); % Reset to default (which is [])
                    end
                end
            case {'text_color', 'background_color', 'edge_color'} % Color specs (can be empty, char, or numeric RGB)
                if ~isfield(params.stats_overlay, field_name)
                    params.stats_overlay.(field_name) = base_default_parameters.stats_overlay.(field_name); % Add if missing
                else % Field is present, validate it
                    value = params.stats_overlay.(field_name);
                    is_valid_color_specification = false;
                    if isempty(value); is_valid_color_specification = true; end % [] is valid, means inherit or 'none'
                    if (ischar(value) && (isvector(value) || isempty(value))); is_valid_color_specification = true; end % 'red', 'none', 'figure', 'axes'
                    if (isstring(value) && isscalar(value)); is_valid_color_specification = true; end % "red", "none", etc.
                    if isnumeric(value) && (isempty(value) || (isvector(value) && length(value) == 3 && all(value >= 0 & value <= 1))); is_valid_color_specification = true; end % RGB triplet [0-1] or []

                    if ~is_valid_color_specification
                        log_message(params, sprintf('Invalid type/value for stats_overlay.%s: %s. Must be valid color spec (char, string, 1x3 RGB [0-1], or empty). Resetting to default empty value.', field_name, format_param_value_for_log(value)), 1, 'Warning');
                        params.stats_overlay.(field_name) = base_default_parameters.stats_overlay.(field_name); % Reset to default (which is [])
                    end
                end
            otherwise
                log_message(params, sprintf('Unhandled default field in stats_overlay: %s', field_name), 1, 'Warning');
        end
    end
    current_stats_overlay_fields = fieldnames(params.stats_overlay);
    extra_stats_overlay_fields = setdiff(current_stats_overlay_fields, default_stats_overlay_fields);
    for extra_field_index = 1:length(extra_stats_overlay_fields)
        log_message(params, sprintf('Unknown field in params.stats_overlay: "%s". Ignored.', extra_stats_overlay_fields{extra_field_index}), 1, 'Warning');
    end
else
    log_message(params, '''params.stats_overlay'' is unexpectedly not a struct before detailed field validation.', 0, 'Error');
    if isfield(base_default_parameters, 'stats_overlay'); params.stats_overlay = base_default_parameters.stats_overlay; end
end

log_message(params, 'Detailed sub-struct FIELD validation complete.', 2, 'Info');
% --- END Sub-Struct Type and Field Validation ---

% Calculate derived parameters
params.axis_line_width = params.plot_line_width * params.axis_to_plot_linewidth_ratio;
params.base_font_size = params.base_font_size * params.global_font_scale_factor; % Effective base font size

% --- Figure-Level Adjustments ---
% This section now always applies as we are always processing a whole figure.
if ~isempty(params.figure_background_color)
    try
        current_figure_color = get(figure_handle, 'Color');
        if ~isequal(current_figure_color, params.figure_background_color)
            set(fig, 'Color', params.figure_background_color);
        end
    catch me_figure_color
        log_message(params, sprintf('Failed to set figure background color: %s', me_figure_color.message), 1, 'Warning');
    end
end

% Prepare color palette
try
    params.active_color_palette = get_color_palette(params, fig);
    params.num_palette_colors = size(params.active_color_palette, 1);
catch me_palette
    log_message(params, sprintf('Failed to prepare color palette: %s. Using default "lines".', me_palette.message), 1, 'Warning');
    params.active_color_palette = lines(7); % Default from MATLAB
    params.num_palette_colors = 7;
end

% --- Main Processing Logic ---
% The logic now always processes the whole figure 'fig'.
% The distinction for target_axes is removed.

% Handle tabs if present within the figure 'fig'
tab_groups = findobj(fig, 'Type', 'uitabgroup', '-depth', 1);
if isempty(tab_groups)
    log_message(params, 'Processing figure (no tabs found)...', 1, 'Info');
    process_container(fig, params);
else
    for tab_group_index = 1:length(tab_groups)
        current_tab_group = tab_groups(tab_group_index);
        if ~isvalid(current_tab_group); continue; end
        tabs = current_tab_group.Children;
        for tab_index = 1:length(tabs)
            current_tab = tabs(tab_index);
            if ~isvalid(current_tab) || ~isprop(current_tab, 'Title'); continue; end
            tab_title_for_display = ['Tab ' num2str(tab_index)];
            if ~isempty(current_tab.Title); tab_title_for_display = current_tab.Title; end
            log_message(params, sprintf('Processing %s...', tab_title_for_display), 1, 'Info');
            process_container(current_tab, params);
        end
    end
end
% Note: The 'else % Process whole figure' that previously wrapped this block
% has been removed, as the function now always processes a whole figure.

% --- Export Figure (if enabled) ---
if params.export_settings.enabled
    [file_path, name_part, ~] = fileparts(params.export_settings.filename);
    if isempty(name_part); name_part = 'beautified_figure'; end
    current_format = lower(params.export_settings.format);

    % Normalize common extensions
    if any(strcmp(current_format, {'jpeg', 'jpg'}))
        export_extension = 'jpg'; print_driver_format = 'jpeg';
    elseif any(strcmp(current_format, {'tiff', 'tif'}))
        export_extension = 'tif'; print_driver_format = 'tiff';
    elseif strcmp(current_format, 'eps')
        export_extension = 'eps'; print_driver_format = 'epsc'; % Ensure color EPS
    else
        export_extension = current_format; print_driver_format = current_format;
    end

    full_filename_with_extension = fullfile(file_path, [name_part, '.', export_extension]);

    log_message(params, sprintf('Exporting figure to "%s"...', full_filename_with_extension), 1, 'Info');
    try
        export_done_successfully = false;
        % exportgraphics is generally preferred if available (R2020a+) and UI is true OR renderer is auto for it
        use_exportgraphics = exist('exportgraphics','file') == 2 && ...
            (params.export_settings.ui || strcmpi(params.export_settings.renderer, 'auto'));

        if use_exportgraphics
            log_message(params, sprintf('Attempting exportgraphics (resolution %d DPI).', params.export_settings.resolution), 2, 'Info');
            exportgraphics_args = {figure_handle, full_filename_with_extension, 'Resolution', params.export_settings.resolution};
            % ContentType for vector/raster preference with exportgraphics
            if any(strcmpi(export_extension, {'pdf', 'eps', 'svg'}))
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
                command_parts = {figure_handle, full_filename_with_extension, format_flag, resolution_flag};

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
                    valid_renderers_for_print = {'painters', 'opengl', 'vector', 'zbuffer'};
                    if any(strcmpi(renderer_to_use_for_print, valid_renderers_for_print))
                        renderer_flag = sprintf('-%s', renderer_to_use_for_print);
                        command_parts{end+1} = renderer_flag;
                    else
                        log_message(params, sprintf('Invalid renderer "%s" for print. Using MATLAB default for this format.', renderer_to_use_for_print), 1, 'Warning');
                    end
                end

                if ~params.export_settings.ui % Add -noui if not using UI (relevant for print)
                    command_parts{end+1} = '-noui';
                end

                log_message(params, sprintf('Using print command with options: %s', strjoin(command_parts(3:end),' ')), 2, 'Info');
                print(command_parts{:});
                log_message(params, 'Export successful using print command.', 1, 'Info');
                export_done_successfully = true;
            else
                log_message(params, 'Export skipped due to empty format_flag (unsupported or invalid format for print).', 1, 'Warning');
            end
        end

        if export_done_successfully && params.export_settings.open_exported_file
            log_message(params, sprintf('Attempting to open exported file: %s', full_filename_with_extension), 2, 'Info');
            try
                open(full_filename_with_extension); % MATLAB's open function
            catch me_open_matlab
                log_message(params, sprintf('MATLAB open() failed: "%s". Trying system open.', me_open_matlab.message), 1, 'Warning');
                try
                    % Ensure full path for system command
                    if isempty(file_path); current_file_path_absolute = fullfile(pwd, full_filename_with_extension);
                    else; current_file_path_absolute = full_filename_with_extension; end

                    if ispc
                        system(['start "" "', current_file_path_absolute, '"']);
                    elseif ismac
                        system(['open "', current_file_path_absolute, '"']);
                    else % Linux or other Unix
                        system(['xdg-open "', current_file_path_absolute, '"']);
                    end
                catch me_system_open
                    log_message(params, sprintf('System open command failed: %s', me_system_open.message), 1, 'Warning');
                end
            end
        elseif ~export_done_successfully
            log_message(params, 'Export was not successful, skipping file open.', 1, 'Warning');
        end

    catch me_export
        log_message(params, sprintf('Figure export process failed: %s (File: %s, Line: %d)', me_export.message, me_export.stack(1).name, me_export.stack(1).line), 0, 'Error');
    end
end

log_message(params, 'Figure beautification complete.', 1, 'Info');
drawnow; % Ensure all changes are rendered
end

% --- Helper Function: Validate Axes Handle Array ---
% This function is no longer needed as direct axes array input is removed.
% function tf = is_valid_axes_handle_array(h_array) ... (entire function removed)

% --- Helper Function: Get Scale Basis for an Axes ---
function num_to_scale_by = get_scale_basis_for_axes(axes_reference, parent_layout, params)
% axes_reference is one of the axes in the layout, or the single axes if no layout.
num_to_scale_by = 1; % Default for standalone axes
if ~isempty(parent_layout) && isvalid(parent_layout)
    try
        grid_size = parent_layout.GridSize;
        % Define tags/types to ignore when counting plottable axes within a layout
        axes_to_ignore_for_scaling = {'legend', 'Colorbar', 'ColormapPreview', 'scribeOverlay'};
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
    catch me_scale_basis
        log_message(params, sprintf('Could not determine scale basis for axes in TiledLayout: %s. Using default of 1.', me_scale_basis.message), 1, 'Warning');
        num_to_scale_by = 1; % Fallback
    end
else % No parent_layout, might be a figure with multiple non-tiled subplots
    figure_parent = ancestor(axes_reference, 'figure');
    if ~isempty(figure_parent)
        axes_to_ignore_for_scaling = {'legend', 'Colorbar', 'ColormapPreview', 'scribeOverlay'};
        if ~params.apply_to_colorbars; axes_to_ignore_for_scaling{end+1} = 'Colorbar'; end

        all_axes_in_figure = get_axes_from_parent(figure_parent, params, axes_to_ignore_for_scaling);
        % Use logical indexing to find axes not in a TiledLayout, which avoids growing arrays.
        is_in_tiled_layout_mask = false(1, numel(all_axes_in_figure));
        for axes_index = 1:numel(all_axes_in_figure)
            is_in_tiled_layout_mask(axes_index) = ~isempty(ancestor(all_axes_in_figure(axes_index), 'matlab.graphics.layout.TiledChartLayout'));
        end
        axes_not_in_tiled_layout = all_axes_in_figure(~is_in_tiled_layout_mask);
        num_to_scale_by = max(1, numel(axes_not_in_tiled_layout));
    end
end
end

% --- Helper Function: Get Color Palette ---
function active_palette = get_color_palette(params, figure_handle)
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
            if exist('turbo','file') == 2; active_palette = turbo(10);
            else; active_palette = turbo_map_10; end
        case 'cividis'
            if exist('cividis','file') == 2; active_palette = cividis(10);
            else; active_palette = cividis_map_10; end
        case 'default_matlab'
            original_visibility = ''; figure_is_valid_and_has_property = false;
            if isvalid(figure_handle) && isprop(figure_handle, 'HandleVisibility')
                original_visibility = get(figure_handle,'HandleVisibility');
                safe_set(params, figure_handle,'HandleVisibility','on'); % Use safe_set
                figure_is_valid_and_has_property = true;
            end
            temporary_axes = axes('Parent', figure_handle, 'Visible', 'off', 'HandleVisibility', 'off', 'Tag', 'BeautifyFig_TempAxesForColorOrder');
            try
                active_palette = get(temporary_axes,'colororder');
            catch
                active_palette = get(groot,'defaultAxesColorOrder');
            end
            delete(temporary_axes);
            if figure_is_valid_and_has_property; safe_set(params, figure_handle,'HandleVisibility',original_visibility); end % Use safe_set
            if size(active_palette,1) < 2; active_palette = get(groot,'defaultAxesColorOrder'); end % Fallback if temp axes failed badly
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
axes_to_ignore_combined = {'legend', 'Colorbar', 'ColormapPreview', 'scribeOverlay'};
if ~params.apply_to_colorbars; axes_to_ignore_combined{end+1} = 'Colorbar'; end % Tag for colorbar axes is 'Colorbar'
if ~params.beautify_sgtitle
    axes_to_ignore_combined{end+1} = 'sgtitle';
    axes_to_ignore_combined{end+1} = 'suptitle'; % Common tag for super titles
end

if params.beautify_sgtitle
    % sgtitle applies to TiledChartLayout or Figure (if TiledChartLayout is direct child)
    if isa(container_handle, 'matlab.ui.Figure')
        % Find TiledChartLayouts that are direct children of the figure
        tiled_layouts_in_figure = findobj(container_handle, 'Type', 'tiledlayout', '-depth', 1);
        for tiled_layout_index = 1:length(tiled_layouts_in_figure)
            if isvalid(tiled_layouts_in_figure(tiled_layout_index)); beautify_super_title_if_exists(tiled_layouts_in_figure(tiled_layout_index), params); end
        end
    elseif isa(container_handle, 'matlab.graphics.layout.TiledChartLayout')
        beautify_super_title_if_exists(container_handle, params);
    elseif isa(container_handle, 'matlab.ui.container.Tab')
        % Find TiledChartLayouts within this tab
        tiled_layouts_in_tab = findobj(container_handle, 'Type', 'tiledlayout'); % Search deeper in tab
        for tiled_layout_index = 1:length(tiled_layouts_in_tab)
            if isvalid(tiled_layouts_in_tab(tiled_layout_index)); beautify_super_title_if_exists(tiled_layouts_in_tab(tiled_layout_index), params); end
        end
    end
end

tiled_layouts_in_container = findobj(container_handle, 'Type', 'tiledlayout'); % Find all tiled layouts in container

% --- Pre-allocate array for handles of axes processed in tiled layouts ---
num_axes_in_tiled_layouts = 0;
if ~isempty(tiled_layouts_in_container)
    for tiled_layout_index = 1:length(tiled_layouts_in_container)
        current_tiled_layout = tiled_layouts_in_container(tiled_layout_index);
        if ~isvalid(current_tiled_layout); continue; end
        axes_in_this_layout = get_axes_from_parent(current_tiled_layout, params, axes_to_ignore_combined);
        num_axes_in_tiled_layouts = num_axes_in_tiled_layouts + numel(axes_in_this_layout);
    end
end
processed_axes_in_tiled_layouts = gobjects(1, num_axes_in_tiled_layouts);
processed_index = 0;

if ~isempty(tiled_layouts_in_container)
    for tiled_layout_index = 1:length(tiled_layouts_in_container)
        current_tiled_layout = tiled_layouts_in_container(tiled_layout_index);
        if ~isvalid(current_tiled_layout); continue; end

        axes_in_this_layout = get_axes_from_parent(current_tiled_layout, params, axes_to_ignore_combined);
        if isempty(axes_in_this_layout); continue; end

        num_to_scale_by = get_scale_basis_for_axes(axes_in_this_layout(1), current_tiled_layout, params);
        scale_factor = get_scale_factor(num_to_scale_by, params.scaling_map, params.min_scale_factor, params.max_scale_factor);
        grid_size_display = current_tiled_layout.GridSize;
        log_message(params, sprintf('  TiledLayout (Grid: %dx%d, Axes found: %d). Scale: %.2f', grid_size_display(1), grid_size_display(2), numel(axes_in_this_layout), scale_factor), 2, 'Info');

        for axes_loop_index = 1:numel(axes_in_this_layout)
            axes_to_beautify = axes_in_this_layout(axes_loop_index);
            if isvalid(axes_to_beautify)
                beautify_single_axes(axes_to_beautify, params, scale_factor, axes_loop_index);
                processed_index = processed_index + 1;
                processed_axes_in_tiled_layouts(processed_index) = axes_to_beautify;
            end
        end
    end
end

% Process axes directly in container that are NOT in any TiledLayout
all_axes_in_container_direct = get_axes_from_parent(container_handle, params, axes_to_ignore_combined);
% Use a logical mask to identify axes not in any TiledLayout, avoiding array growth.
is_not_in_any_tiled_layout_mask = true(size(all_axes_in_container_direct));
for direct_axes_index = 1:numel(all_axes_in_container_direct)
    axes_candidate = all_axes_in_container_direct(direct_axes_index);
    % Check if this axis was already processed because it was in a TiledLayout
    is_already_processed = any(processed_axes_in_tiled_layouts == axes_candidate);
    if is_already_processed || ~isempty(ancestor(axes_candidate, 'matlab.graphics.layout.TiledChartLayout'))
        is_not_in_any_tiled_layout_mask(direct_axes_index) = false;
    end
end
axes_not_in_any_tiled_layout = all_axes_in_container_direct(is_not_in_any_tiled_layout_mask);

if isempty(axes_not_in_any_tiled_layout)
    if isempty(tiled_layouts_in_container) % No tiled layouts AND no other axes
        log_message(params, '  No plottable axes found in this container.', 2, 'Info');
    end
    return;
end

num_axes_no_tiled_layout = numel(axes_not_in_any_tiled_layout);
% For non-tiled axes, scale_factor is based on their count within the current container
% (figure_handle or tab), assuming they are somewhat "subplot-like".
scale_factor_no_tiled_layout = get_scale_factor(num_axes_no_tiled_layout, params.scaling_map, params.min_scale_factor, params.max_scale_factor);
log_message(params, sprintf('  Container has %d axes not in a TiledLayout. Scale: %.2f', num_axes_no_tiled_layout, scale_factor_no_tiled_layout), 2, 'Info');

for axes_index = 1:num_axes_no_tiled_layout
    axes_to_beautify = axes_not_in_any_tiled_layout(axes_index);
    if isvalid(axes_to_beautify)
        beautify_single_axes(axes_to_beautify, params, scale_factor_no_tiled_layout, axes_index);
    end
end
end

% --- Helper Function: Beautify Super Title (sgtitle) ---
function beautify_super_title_if_exists(layout_or_figure_handle, params)
% layout_or_figure_handle can be a TiledChartLayout or a Figure
try
    super_title_handle = [];
    if isa(layout_or_figure_handle, 'matlab.graphics.layout.TiledChartLayout')
        if isprop(layout_or_figure_handle, 'Title') && isvalid(layout_or_figure_handle.Title) && ~isempty(layout_or_figure_handle.Title.String)
            super_title_handle = layout_or_figure_handle.Title;
        end
    elseif isa(layout_or_figure_handle, 'matlab.ui.Figure')
        % For a figure, sgtitle might be associated with a TiledChartLayout child
        % This case is handled by iterating TiledChartLayouts in process_container
        % Or, if user called sgtitle(fig, ...), it creates a special axes.
        % This scenario is less common with modern TiledLayouts.
        % For simplicity, this helper focuses on TiledChartLayout.Title
        return; % Figure-level sgtitle handled by iterating its TiledLayouts
    end

    if ~isempty(super_title_handle)
        % Use a slightly larger scale for sgtitle than for regular titles
        % Max scale factor is used as sgtitle is unique per layout/figure.
        super_title_font_size = round(params.base_font_size * params.title_scale * params.max_scale_factor * 1.15); % Slightly smaller multiplier
        super_title_font_size = max(super_title_font_size, round(params.base_font_size * 1.6)); % Ensure a minimum prominent size
        process_text_property(super_title_handle, super_title_handle.String, super_title_font_size, 'bold', params.text_color, params.font_name, params, true); % LaTeX auto usually off for sgtitle
    end
catch me_super_title
    log_message(params, sprintf('Could not beautify sgtitle: %s', me_super_title.message), 1, 'Warning');
end
end

% --- Helper Function: Get Plottable Axes from Parent ---
function axes_handles = get_axes_from_parent(parent_handle, params, ignore_tags_and_types) % Renamed for clarity
axes_handles = matlab.graphics.axis.Axes.empty; % Initialize with correct empty type
if ~isvalid(parent_handle); return; end
try
    % Find children that are Axes or PolarAxes, at depth 1 (direct children)
    % This is crucial for TiledChartLayout where axes are direct children.
    % For figure/tab, this will find top-level axes.
    potential_children = findobj(parent_handle, '-depth', 1);
catch me_find_object
    log_message(params, sprintf('findobj failed for parent %s (Tag: %s): %s', class(parent_handle), parent_handle.Tag, me_find_object.message),1,'Warning');
    return;
end

for child_index=1:length(potential_children)
    child = potential_children(child_index);
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

        is_ignored_by_tag_or_type = false; % Simplified check
        if ~isempty(child_tag) && iscellstr(ignore_tags_and_types) %#ok<ISCLSTR>
            is_ignored_by_tag_or_type = any(strcmp(child_tag, ignore_tags_and_types));
        end
        % Removed is_ignored_by_type check as params.exclude_object_types is gone

        if ~is_ignored_by_tag_or_type
            % Explicitly check for ColorBar type if apply_to_colorbars is false
            if isa(child, 'matlab.graphics.illustration.ColorBar') && ~params.apply_to_colorbars
                % Skip adding this colorbar to the list of axes to be beautified by beautify_single_axes
                log_message(params, sprintf('Skipping ColorBar object (Tag: %s) from main axes processing list because apply_to_colorbars is false.', child_tag), 2, 'Debug');
            else
                axes_handles(end+1) = child;
            end
        end
    end
end
end

% --- Helper Function: Get Scaling Factor ---
function scale_factor = get_scale_factor(num_subplots, scaling_map, min_scale_factor, max_scale_factor)
map_keys = cell2mat(scaling_map.keys);
map_values = cell2mat(scaling_map.values);
if num_subplots <= 0; num_subplots = 1; end % Ensure num_subplots is at least 1

index = find(map_keys == num_subplots, 1);
if ~isempty(index)
    scale_factor = map_values(index);
else
    sorted_keys = sort(map_keys); % Ensure keys are sorted for interpolation/extrapolation logic
    min_key = sorted_keys(1);
    max_key = sorted_keys(end);

    if num_subplots < min_key
        % Extrapolate downwards: scale factor increases as num_subplots decreases
        scale_factor = map_values(map_keys == min_key) * nthroot(min_key / num_subplots, 2.5); % Ratio > 1
    elseif num_subplots > max_key
        % Extrapolate upwards: scale factor decreases as num_subplots increases
        scale_factor = map_values(map_keys == max_key) * nthroot(max_key / num_subplots, 2.5); % Ratio < 1
    else
        % Interpolate
        scale_factor = interp1(map_keys, map_values, num_subplots, 'linear'); % 'extrap' not needed due to prior checks

        % Clamp interpolation to avoid extreme values if map is sparse near num_subplots
        % Find nearest lower and upper bound values from the map
        lower_bound_value = interp1(map_keys, map_values, max(map_keys(map_keys<num_subplots)), 'nearest');
        upper_bound_value = interp1(map_keys, map_values, min(map_keys(map_keys>num_subplots)), 'nearest');
        % Ensure scale_factor is not drastically different from its neighbors in the map
        scale_factor = max(min(scale_factor, max(lower_bound_value, upper_bound_value) * 1.1), min(lower_bound_value, upper_bound_value) * 0.9);
    end
end
scale_factor = max(min_scale_factor, min(max_scale_factor, scale_factor)); % Clamp to global min/max scale factors
end

% --- START OF CHILD STYLING HELPERS ---

function style_line(child, params, scaled_sizes, style_properties)
    properties_to_set = {'LineWidth', scaled_sizes.actual_plot_line_width, 'MarkerSize', scaled_sizes.marker_size_scaled};
    if ~isempty(style_properties.color); properties_to_set = [properties_to_set, {'Color', style_properties.color}]; end
    if ~isempty(style_properties.line_style); properties_to_set = [properties_to_set, {'LineStyle', style_properties.line_style}]; end
    if ~strcmpi(style_properties.marker, 'none')
        properties_to_set = [properties_to_set, {'Marker', style_properties.marker}];
        if ~strcmpi(style_properties.marker, '.') && ~isempty(style_properties.color)
            properties_to_set = [properties_to_set, {'MarkerFaceColor', style_properties.color, 'MarkerEdgeColor', style_properties.color*0.7}];
        elseif strcmpi(style_properties.marker, '.') && ~isempty(style_properties.color)
            properties_to_set = [properties_to_set, {'MarkerEdgeColor', style_properties.color, 'MarkerFaceColor', 'none'}];
        end
    elseif ~strcmpi(child.Marker,'none') && ~isempty(style_properties.color)
        if isprop(child,'MarkerFaceColor') && ~ischar(child.MarkerFaceColor) && ~any(strcmpi(child.MarkerFaceColor,{'auto','none'}))
            properties_to_set = [properties_to_set, {'MarkerFaceColor',style_properties.color}];
        end
        if isprop(child,'MarkerEdgeColor') && ~ischar(child.MarkerEdgeColor) && ~any(strcmpi(child.MarkerEdgeColor,{'auto','none'}))
            properties_to_set = [properties_to_set, {'MarkerEdgeColor',style_properties.color*0.7}];
        end
    end
    safe_set(params, child, properties_to_set{:});
end

function style_scatter(child, params, scaled_sizes, style_properties)
    properties_to_set = {'SizeData', scaled_sizes.marker_size_scaled^2, 'LineWidth', scaled_sizes.actual_plot_line_width*0.5};
    if ~isempty(style_properties.color)
        if isprop(child, 'MarkerFaceColor') && ~(ischar(child.MarkerFaceColor) && any(strcmpi(child.MarkerFaceColor,{'none','flat'})))
            properties_to_set = [properties_to_set, {'MarkerFaceColor', style_properties.color}];
        end
        if isprop(child, 'MarkerEdgeColor') && ~(ischar(child.MarkerEdgeColor) && strcmpi(child.MarkerEdgeColor,'none'))
            properties_to_set = [properties_to_set, {'MarkerEdgeColor', style_properties.color*0.75}];
        end
    end
    if ~strcmpi(style_properties.marker, 'none'); properties_to_set = [properties_to_set, {'Marker', style_properties.marker}]; end
    safe_set(params, child, properties_to_set{:});
end

function style_bar(child, params, scaled_sizes, style_properties)
    properties_to_set = {'LineWidth', scaled_sizes.axis_line_width_scaled*0.9};
    if ~isempty(style_properties.color)
        if isprop(child, 'FaceColor') && (~ischar(child.FaceColor) || ~strcmpi(child.FaceColor,'flat'))
            properties_to_set = [properties_to_set, {'FaceColor', style_properties.color}];
        end
        edge_color = style_properties.color * 0.7;
        if isequal(edge_color, [0 0 0]); edge_color = params.axis_color*0.5; end
        properties_to_set = [properties_to_set, {'EdgeColor', edge_color}];
    else
        properties_to_set = [properties_to_set, {'EdgeColor', params.axis_color*0.7}];
    end
    safe_set(params, child, properties_to_set{:});
end

function style_histogram(child, params, scaled_sizes, style_properties)
    properties_to_set = {'LineWidth', scaled_sizes.axis_line_width_scaled*0.8, 'FaceAlpha', 0.7};
    if ~isempty(style_properties.color)
        properties_to_set = [properties_to_set, {'FaceColor', style_properties.color, 'EdgeColor', style_properties.color*0.5}];
    else
        properties_to_set = [properties_to_set, {'EdgeColor', params.axis_color*0.5}];
    end
    safe_set(params, child, properties_to_set{:});
end

function style_errorbar(child, params, scaled_sizes, style_properties)
    base_cap_size_for_error_bar = params.marker_size * 0.8;
    scaled_cap_size = base_cap_size_for_error_bar * params.errorbar_cap_size_scale * scaled_sizes.font_size / params.base_font_size;
    properties_to_set = {'LineWidth', scaled_sizes.actual_plot_line_width*0.8, 'MarkerSize', scaled_sizes.marker_size_scaled*0.8, 'CapSize', max(1, scaled_cap_size)};
    if ~isempty(style_properties.color); properties_to_set = [properties_to_set, {'Color',style_properties.color}]; end
    if ~strcmpi(style_properties.marker, 'none'); properties_to_set = [properties_to_set, {'Marker', style_properties.marker}]; end
    safe_set(params, child, properties_to_set{:});
end

function style_surface(child, params, scaled_sizes)
    props_to_set = {'EdgeColor', params.axis_color*0.6, 'LineWidth', scaled_sizes.axis_line_width_scaled*0.7};
    safe_set(params, child, props_to_set{:});
end

function style_heatmap(child, params, scaled_sizes)
    props_to_set = {'FontName', params.font_name, 'FontSize', scaled_sizes.font_size, 'FontColor', params.text_color};
    if strcmpi(params.grid_density, 'none')
        props_to_set = [props_to_set, {'GridVisible', 'off'}];
    else
        props_to_set = [props_to_set, {'GridVisible', 'on', 'GridColor', params.grid_color}];
    end
    safe_set(params, child, props_to_set{:});

    process_text_prop(child.Title, child.Title.String, scaled_sizes.title_font_size, 'bold', params.text_color, params.font_name, params);
    process_text_prop(child.XLabel, child.XLabel.String, scaled_sizes.label_font_size, 'normal', params.text_color, params.font_name, params);
    process_text_prop(child.YLabel, child.YLabel.String, scaled_sizes.label_font_size, 'normal', params.text_color, params.font_name, params);
    if params.apply_to_colorbars && isprop(child, 'Colorbar') && isvalid(child.Colorbar)
        beautify_colorbar(child, params, scaled_sizes.font_size, scaled_sizes.label_font_size, scaled_sizes.axis_line_width_scaled);
    end
end

% --- END OF CHILD STYLING HELPERS ---

% --- START OF SINGLE AXES REFACTORED HELPERS ---

function scaled_sizes = calculate_scaled_sizes(params, scale_factor)
    % Calculates all scaled font sizes and line widths for an axes.
    scaled_sizes.font_size = round(params.base_font_size * scale_factor);
    scaled_sizes.title_font_size = round(params.base_font_size * params.title_scale * scale_factor);
    scaled_sizes.label_font_size = round(params.base_font_size * params.label_scale * scale_factor);
    scaled_sizes.actual_plot_line_width = max(0.75, params.plot_line_width * scale_factor);
    scaled_sizes.axis_line_width_scaled = max(0.5, params.axis_line_width * scale_factor);
    scaled_sizes.marker_size_scaled = max(3, params.marker_size * scale_factor);
end

function apply_base_axes_style(ax, params, scaled_sizes)
    % Applies the base styling to the axes object itself (fonts, grids, colors, etc.)
    common_props = {'FontName', params.font_name, 'FontSize', scaled_sizes.font_size, 'LineWidth', scaled_sizes.axis_line_width_scaled, 'TickDir', 'out', ...
        'GridColor', params.grid_color, 'GridAlpha', params.grid_alpha, 'GridLineStyle', params.grid_line_style, ...
        'MinorGridColor', params.grid_color, 'MinorGridAlpha', params.minor_grid_alpha, 'MinorGridLineStyle', params.minor_grid_line_style};

    switch lower(params.axis_box_style)
        case 'on'; common_props = [common_props, {'Box', 'on'}];
        case 'off'; common_props = [common_props, {'Box', 'off'}];
        case 'left-bottom'
            common_props = [common_props, {'Box', 'off'}];
            if isprop(ax, 'XAxisLocation'); safe_set(params, ax, 'XAxisLocation', 'bottom'); end
            if isprop(ax, 'YAxisLocation'); safe_set(params, ax, 'YAxisLocation', 'left'); end
            try
                if isprop(ax, 'XAxis') && numel(ax.XAxis) > 1; safe_set(params, ax.XAxis(2), 'Visible', 'off'); end
                if isprop(ax, 'YAxis') && numel(ax.YAxis) > 1; safe_set(params, ax.YAxis(2), 'Visible', 'off'); end
                if isprop(ax, 'ZAxis') && numel(ax.ZAxis) > 1; safe_set(params, ax.ZAxis(2), 'Visible', 'off'); end
            catch me_hide_extra_axes
                log_message(params, sprintf('Minor issue hiding extra axes for left-bottom style: %s', me_hide_extra_axes.message), 2, 'Debug');
            end
    end

    major_grid_on = 'off'; minor_grid_on = 'off';
    if strcmpi(params.grid_density, 'normal'); major_grid_on = 'on'; minor_grid_on = 'on';
    elseif strcmpi(params.grid_density, 'major_only'); major_grid_on = 'on'; end

    try
        if isa(ax, 'matlab.graphics.axis.Axes')
            current_axes_props = {common_props{:}, ...
                'XGrid', major_grid_on, 'YGrid', major_grid_on, 'ZGrid', major_grid_on, ...
                'XMinorGrid', minor_grid_on, 'YMinorGrid', minor_grid_on, 'ZMinorGrid', minor_grid_on, ...
                'XColor', params.axis_color, 'YColor', params.axis_color, 'ZColor', params.axis_color, ...
                'Layer', params.axes_layer};
            safe_set(params, ax, current_axes_props{:});
            process_text_prop(ax.Title, ax.Title.String, scaled_sizes.title_font_size, 'bold', params.text_color, params.font_name, params);
            process_text_prop(ax.XLabel, ax.XLabel.String, scaled_sizes.label_font_size, 'normal', params.text_color, params.font_name, params);
            process_text_prop(ax.YLabel, ax.YLabel.String, scaled_sizes.label_font_size, 'normal', params.text_color, params.font_name, params);
            process_text_prop(ax.ZLabel, ax.ZLabel.String, scaled_sizes.label_font_size, 'normal', params.text_color, params.font_name, params);

            if ~isgeoaxes(ax) && strcmpi(params.axis_limit_mode, 'padded') && params.expand_axis_limits_factor > 0
                expand_axis_limits(ax, 'XLim', params.expand_axis_limits_factor, params);
                expand_axis_limits(ax, 'YLim', params.expand_axis_limits_factor, params);
                if isprop(ax,'ZAxis') && ~isempty(ax.ZAxis) && isprop(ax, 'ZLim') && diff(ax.ZLim) > 1e-9
                    expand_axis_limits(ax, 'ZLim', params.expand_axis_limits_factor, params);
                end
            elseif strcmpi(params.axis_limit_mode, 'tight')
                try
                    axis(ax, 'tight');
                catch me_tight
                    log_message(params, sprintf('Warning: "axis tight" failed for axes (Tag: %s): %s', ax.Tag, me_tight.message),1,'Warning');
                end
            end
        elseif isa(ax, 'matlab.graphics.axis.PolarAxes') && params.apply_to_polaraxes
            current_polar_props = {common_props{:}, ...
                'RGrid', major_grid_on, 'ThetaGrid', major_grid_on, ...
                'RColor', params.axis_color, 'ThetaColor', params.axis_color};
            safe_set(params, ax, current_polar_props{:});
            if isprop(ax, 'MinorGridLineStyle'); safe_set(params, ax, 'MinorGridVisible', minor_grid_on); end
            process_text_prop(ax.Title, ax.Title.String, scaled_sizes.title_font_size, 'bold', params.text_color, params.font_name, params);
        end
    catch me_axes_props
        log_message(params, sprintf('Error setting main axes properties for (Tag: %s, Type: %s): %s', ax.Tag, class(ax), me_axes_props.message), 1, 'Warning');
    end
end

function plottable_children_for_legend = style_plot_children(ax, params, scaled_sizes)
    % Styles all plottable objects (lines, bars, etc.) within an axes.
    try
        all_children_original = get(ax, 'Children');
    catch
        all_children_original = [];
    end

    if ~isempty(params.exclude_object_tags)
        children_to_keep_indices = true(size(all_children_original));
        ax_tag_for_log = ''; if isprop(ax, 'Tag') && ~isempty(ax.Tag); ax_tag_for_log = ax.Tag; end
        for child_index = 1:length(all_children_original)
            obj = all_children_original(child_index);
            if isprop(obj, 'Tag')
                obj_tag = get(obj, 'Tag');
                if ~isempty(obj_tag) && ismember(obj_tag, params.exclude_object_tags)
                    children_to_keep_indices(child_index) = false;
                    if isempty(ax_tag_for_log); ax_identifier_for_log = sprintf('of type %s (no Tag)', class(ax));
                    else; ax_identifier_for_log = sprintf('(Tag: %s)', ax_tag_for_log); end
                    log_message(params, sprintf('  Excluding object with tag "%s" from beautification in axes %s.', obj_tag, ax_identifier_for_log), 2, 'Info');
                end
            end
        end
        all_children_filtered = all_children_original(children_to_keep_indices);
    else
        all_children_filtered = all_children_original;
    end

    is_legend_candidate_mask = arrayfun(@is_legend_candidate_check, all_children_filtered);
    temp_legend_candidates = all_children_filtered(is_legend_candidate_mask);
    num_total_legend_candidates = length(temp_legend_candidates);

    activate_marker_cycle_now = (islogical(params.cycle_marker_styles) && params.cycle_marker_styles) || ...
        (strcmpi(params.cycle_marker_styles, 'auto') && num_total_legend_candidates > params.marker_cycle_threshold);

    activate_line_style_cycle_now = (islogical(params.cycle_line_styles) && params.cycle_line_styles) || ...
        (strcmpi(params.cycle_line_styles, 'auto') && num_total_legend_candidates > params.line_style_cycle_threshold);

    processed_children_order = all_children_filtered;
    if ~params.legend_reverse_order
        processed_children_order = flipud(all_children_filtered);
    end

    is_legend_candidate_mask_for_processed = arrayfun(@is_legend_candidate_check, processed_children_order);
    plottable_children_for_legend = processed_children_order(is_legend_candidate_mask_for_processed);

    color_index = 0;
    num_marker_styles = length(params.marker_styles);
    num_line_styles = length(params.line_style_order);

    for child_index = 1:length(processed_children_order)
        child = processed_children_order(child_index);
        try
            is_plottable_for_styling = isa(child, 'matlab.graphics.chart.primitive.Line') || ...
                                      isa(child, 'matlab.graphics.chart.primitive.Scatter') || ...
                                      isa(child, 'matlab.graphics.chart.primitive.Bar') || ...
                                      isa(child, 'matlab.graphics.chart.primitive.Histogram') || ...
                                      isa(child, 'matlab.graphics.chart.primitive.ErrorBar') || ...
                                      isa(child, 'matlab.graphics.chart.primitive.Stair') || ...
                                      isa(child, 'matlab.graphics.chart.primitive.Area');

            style_props.color = []; style_props.marker = 'none'; style_props.line_style = '';
            if is_plottable_for_styling
                color_index = color_index + 1;
                style_props.color = params.active_color_palette(mod(color_index-1, params.num_palette_colors)+1, :);
                if activate_marker_cycle_now && num_marker_styles > 0
                    style_props.marker = params.marker_styles{mod(color_index-1, num_marker_styles)+1};
                end
                if activate_line_style_cycle_now && num_line_styles > 0
                    style_props.line_style = params.line_style_order{mod(color_index-1, num_line_styles)+1};
                end
            end

            if isa(child, 'matlab.graphics.chart.primitive.Line')
                style_line(child, params, scaled_sizes, style_props);
            elseif isa(child, 'matlab.graphics.chart.primitive.Scatter')
                style_scatter(child, params, scaled_sizes, style_props);
            elseif isa(child, 'matlab.graphics.chart.primitive.Bar')
                style_bar(child, params, scaled_sizes, style_props);
            elseif isa(child, 'matlab.graphics.chart.primitive.Histogram')
                style_histogram(child, params, scaled_sizes, style_props);
            elseif isa(child, 'matlab.graphics.chart.primitive.ErrorBar')
                style_errorbar(child, params, scaled_sizes, style_props);
            elseif isa(child,'matlab.graphics.primitive.Surface') || isa(child,'matlab.graphics.chart.primitive.Surface') || isa(child,'matlab.graphics.primitive.Patch')
                style_surface(child, params, scaled_sizes);
        elseif isa(child, 'matlab.graphics.chart.HeatmapChart')
                style_heatmap(child, params, scaled_sizes);
            end
        catch me_child
            child_tag_display = ''; if isprop(child,'Tag'); child_tag_display = child.Tag; end
            log_message(params, sprintf('Error processing child object (Type: %s, Tag: %s): %s', class(child), child_tag_display, me_child.message), 1, 'Warning');
        end
    end
end

function style_general_text_objects(ax, params, font_size)
    % Styles general text objects within an axes that are not titles or labels.
    try
        text_children = findobj(ax, 'Type', 'text', '-depth', 1);
    catch
        text_children = [];
    end

    for text_index = 1:length(text_children)
        text_obj = text_children(text_index);
        if ~isvalid(text_obj); continue; end

        parent_of_text = [];
        try parent_of_text = get(text_obj, 'Parent'); catch; end
        if isa(parent_of_text, 'matlab.graphics.illustration.ColorBar') && ~params.apply_to_colorbars
            continue;
        end

        is_label_or_title_or_legend_text = false;
        if isprop(text_obj,'Tag')
            tag_str = text_obj.Tag;
            is_label_or_title_or_legend_text = any(strcmpi(tag_str, {'xlabel','ylabel','zlabel','title', 'legend_title_text'}));
        end

        try
            parent_obj_for_legend_check = get(text_obj,'Parent');
            if isa(parent_obj_for_legend_check,'matlab.graphics.illustration.Legend') || ...
               (isprop(parent_obj_for_legend_check, 'Parent') && isa(get(parent_obj_for_legend_check,'Parent'),'matlab.graphics.illustration.Legend'))
                is_label_or_title_or_legend_text = true;
            end
        catch
        end

        if ~is_label_or_title_or_legend_text && ~strcmp(text_obj.Tag, 'BeautifyFig_StatsOverlay')
            process_text_prop(text_obj, text_obj.String, font_size, text_obj.FontWeight, params.text_color, params.font_name, params);
        end
    end
end

function [original_props, colorbar_handle] = store_original_colorbar_props(ax, params)
    % Stores original properties of a colorbar if it should not be beautified.
    original_props = [];
    colorbar_handle = [];
    if isa(ax, 'matlab.graphics.illustration.ColorBar') || params.apply_to_colorbars
        return;
    end

    colorbar_handle = find_associated_colorbar(ax, params);
    if ~isempty(colorbar_handle) && isvalid(colorbar_handle)
        try
            original_props.FontName = colorbar_handle.FontName;
            original_props.FontSize = colorbar_handle.FontSize;
            original_props.Color = colorbar_handle.Color;
            original_props.LineWidth = colorbar_handle.LineWidth;
            original_props.TickDirection = colorbar_handle.TickDirection;
            if isprop(colorbar_handle, 'Label') && isvalid(colorbar_handle.Label)
                original_props.LabelString = colorbar_handle.Label.String;
                if ~isempty(original_props.LabelString)
                    original_props.LabelFontName = colorbar_handle.Label.FontName;
                    original_props.LabelFontSize = colorbar_handle.Label.FontSize;
                    original_props.LabelColor = colorbar_handle.Label.Color;
                    if isprop(colorbar_handle.Label, 'Interpreter')
                        original_props.LabelInterpreter = colorbar_handle.Label.Interpreter;
                    end
                end
            end
        catch me_store_colorbar
            log_message(params, sprintf('Could not store all original colorbar properties: %s', me_store_colorbar.message), 1, 'Warning');
            original_props = []; colorbar_handle = [];
        end
    end
end

function restore_original_colorbar_props(colorbar_handle, original_props, params)
    % Restores original colorbar properties if they were stored.
    if isempty(original_props) || isempty(colorbar_handle) || ~isvalid(colorbar_handle)
        return;
    end

    safe_set(params, colorbar_handle, ...
        'FontName', original_props.FontName, ...
        'FontSize', original_props.FontSize, ...
        'Color', original_props.Color, ...
        'LineWidth', original_props.LineWidth, ...
        'TickDirection', original_props.TickDirection);

    if isprop(colorbar_handle, 'Label') && isvalid(colorbar_handle.Label)
        if isfield(original_props, 'LabelString') && ~isempty(original_props.LabelString)
            safe_set(params, colorbar_handle.Label, ...
                'String', original_props.LabelString, ...
                'FontName', original_props.LabelFontName, ...
                'FontSize', original_props.LabelFontSize, ...
                'Color', original_props.LabelColor, ...
                'Visible', 'on');
            if isfield(original_props, 'LabelInterpreter')
                safe_set(params, colorbar_handle.Label, 'Interpreter', original_props.LabelInterpreter);
            end
        elseif isfield(original_props, 'LabelString')
            safe_set(params, colorbar_handle.Label, 'String', '', 'Visible', 'off');
        end
    end
end

% --- Core Function: Beautify a Single Axes Object ---
function beautify_single_axes(axes_handle, params, scale_factor, ~) % axes_index not used currently
    if ~isvalid(axes_handle); return; end

    % Early exit for non-applicable colorbars
    if isa(axes_handle, 'matlab.graphics.illustration.ColorBar') && ~params.apply_to_colorbars
        axes_tag_info = ''; if isprop(axes_handle,'Tag'); axes_tag_info = axes_handle.Tag; end
        log_message(params, sprintf('Skipping all styling for ColorBar object (Tag: %s) itself as apply_to_colorbars is false.', axes_tag_info), 1, 'Info');
        return;
    end

    % Store original colorbar properties if it's associated with this axes and shouldn't be touched
    [original_colorbar_properties, colorbar_handle_for_restore] = store_original_colorbar_properties(axes_handle, params);

    current_hold_state = ishold(axes_handle); if ~current_hold_state; safe_hold(params, axes_handle, 'on'); end

    % Calculate all scaled sizes in one place
    scaled_sizes = calculate_scaled_sizes(params, scale_factor);

    % Apply base styling to the axes object itself
    apply_base_axes_style(axes_handle, params, scaled_sizes);

    % Style all the plot objects (lines, bars, etc.) within the axes
    plottable_children_for_legend = style_plot_children(axes_handle, params, scaled_sizes);

    % Style general text objects that are not titles or labels
    if params.apply_to_general_text
        style_general_text_objects(axes_handle, params, scaled_sizes.font_size);
    end

    % Apply final touches like legends, colorbars, and overlays
    beautify_legend(axes_handle, params, plottable_children_for_legend, scaled_sizes.font_size, scaled_sizes.axis_line_width_scaled);
    if params.apply_to_colorbars; beautify_colorbar(axes_handle, params, scaled_sizes.font_size, scaled_sizes.label_font_size, scaled_sizes.axis_line_width_scaled); end
    if params.stats_overlay.enabled && isa(axes_handle, 'matlab.graphics.axis.Axes')
        try
            apply_stats_overlay(axes_handle, params, scale_factor);
        catch me_stats_overlay
            log_message(params, sprintf('Error applying stats overlay to Axes (Tag: %s): %s (Line: %d)', axes_handle.Tag, me_stats_overlay.message, me_stats_overlay.stack(1).line), 1, 'Warning');
        end
    end

    % Restore original colorbar properties if they were stored
    restore_original_colorbar_properties(colorbar_handle_for_restore, original_colorbar_properties, params);

    if ~current_hold_state; safe_hold(params, axes_handle, 'off'); end
end


% --- Helper Function: Check if an object is a legend candidate ---
function is_candidate = is_legend_candidate_check(obj_handle)
is_candidate = false;
if ~isvalid(obj_handle) || ~isprop(obj_handle,'Visible') || ~strcmpi(get(obj_handle, 'Visible'), 'on'); return; end

% Check for common plottable types that usually appear in legends
is_plot_type = isa(obj_handle, 'matlab.graphics.chart.primitive.Line') || ...
    isa(obj_handle, 'matlab.graphics.chart.primitive.Scatter') || ...
    isa(obj_handle, 'matlab.graphics.chart.primitive.Bar') || ...
    isa(obj_handle, 'matlab.graphics.chart.primitive.Stair') || ...
    isa(obj_handle, 'matlab.graphics.chart.primitive.Area') || ...
    isa(obj_handle, 'matlab.graphics.chart.primitive.ErrorBar') || ...
    isa(obj_handle, 'matlab.graphics.primitive.Patch') || ... % Patches can have DisplayName
    isa(obj_handle, 'matlab.graphics.primitive.Surface'); % Surfaces too

if ~is_plot_type; return; end

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
catch me_legend_check
    % Property access failed, assume not a candidate or log if necessary
    % For now, suppress error and return false
    % log_message(params, sprintf('Error checking legend candidacy for object of type %s: %s', class(obj_handle), me_legend_check.message), 2, 'Debug');
end
end

% --- Helper Function: Beautify Legend ---
function beautify_legend(ax, params, plottable_children_for_legend, font_size, axis_line_width_scaled)
try
    % Find existing legend for the axes
    existing_legend = [];
    if isprop(ax, 'Legend') && isa(ax.Legend, 'matlab.graphics.illustration.Legend') && isvalid(ax.Legend)
        existing_legend = ax.Legend;
    elseif isfield(params, 'all_legends_in_fig') && ~isempty(params.all_legends_in_fig)
        all_legends_in_fig = params.all_legends_in_fig;
        for legend_index = 1:numel(all_legends_in_fig)
            current_legend = all_legends_in_fig(legend_index);
            if ~isvalid(current_legend); continue; end
            associated_axes = [];
            try
                if isprop(current_legend, 'Axes'); associated_axes = current_legend.Axes;
                elseif isprop(current_legend, 'Axle') && isprop(current_legend.Axle, 'Peer'); associated_axes = current_legend.Axle.Peer; end
            catch; end
            if isequal(associated_axes, ax)
                existing_legend = current_legend;
                break;
            end
        end
    end

    % Determine if the legend should be shown
    num_actual_legend_entries = numel(plottable_children_for_legend);
    should_show_legend = false;
    if ~strcmpi(params.legend_location, 'none')
        if params.smart_legend_display
            if num_actual_legend_entries > 1 || (num_actual_legend_entries == 1 && params.legend_force_single_entry)
                should_show_legend = true;
            end
        else % Not smart, show if any entries exist
            if num_actual_legend_entries > 0
                should_show_legend = true;
            end
        end
    end

    % Create, update, or hide the legend based on the decision
    legend_handle_to_use = [];
    if should_show_legend && ~isempty(plottable_children_for_legend)
        % Delete existing legend to ensure proper refresh of items and order
        if ~isempty(existing_legend) && isvalid(existing_legend)
            try
                delete(existing_legend);
                log_message(params,sprintf('  Deleted existing legend to re-apply order/items for Axes (Tag: %s).',ax.Tag),2,'Debug');
            catch me_delete_legend
                log_message(params,sprintf('  Could not delete existing legend for Axes (Tag: %s): %s. Order may not update correctly.',ax.Tag, me_delete_legend.message),1,'Warning');
            end
        end

        % Create the new legend
        try
            legend_handle_to_use = legend(ax, plottable_children_for_legend);
            log_message(params,sprintf('  Created/Recreated legend for Axes (Tag: %s) with specified order/items.',ax.Tag),2,'Info');
        catch me_legend_create
            log_message(params,sprintf('  Could not create legend for Axes (Tag: %s): %s',ax.Tag,me_legend_create.message),1,'Warning');
        end
    elseif ~isempty(existing_legend) && isvalid(existing_legend)
        % If not showing legend, ensure any existing one is hidden
        safe_set(params, existing_legend, 'Visible', 'off');
    end

    % Style the legend if it was created
    if ~isempty(legend_handle_to_use) && isvalid(legend_handle_to_use)
        legend_props.FontSize = round(font_size*0.93);
        legend_props.LineWidth = axis_line_width_scaled*0.85;
        legend_props.TextColor = params.text_color;
        legend_props.EdgeColor = params.axis_color*0.85;
        legend_props.FontName = params.font_name;
        legend_props.Visible = 'on';
        legend_props.Location = params.legend_location;

        if strcmpi(params.axis_box_style,'off') || strcmpi(params.axis_box_style,'left-bottom')
            legend_props.Box = 'off';
        else
            legend_props.Box = 'on'; % Match axis box style 'on'
        end

        if params.legend_num_columns > 0 && isprop(legend_handle_to_use,'NumColumns')
            legend_props.NumColumns = params.legend_num_columns;
        end

        if isprop(legend_handle_to_use, 'Interpreter') && isprop(legend_handle_to_use, 'String')
            legend_props.Interpreter = 'tex'; % Default to TeX for legends
        end

        if isprop(legend_handle_to_use,'Title') && isvalid(legend_handle_to_use.Title)
            if ~isempty(params.legend_title_string)
                safe_set(params, legend_handle_to_use.Title, 'String', params.legend_title_string, 'Visible', 'on');
                process_text_prop(legend_handle_to_use.Title,params.legend_title_string,round(legend_props.FontSize*1.05),'bold',params.text_color,params.font_name,params);
            else
                safe_set(params, legend_handle_to_use.Title, 'String', '', 'Visible', 'off');
            end
        end

        % Convert struct to name-value pairs for safe_set
        nv_pairs_for_legend = local_struct_to_nv_pairs(legend_props);
        safe_set(params, legend_handle_to_use, nv_pairs_for_legend{:});

        % Clear potentially stale appdata before setting up new interactivity
        if params.interactive_legend % Only bother if interactivity is enabled
            appdata_names_to_clear = {'OriginalVisibilityStates', 'IsolationModeActive', 'IsolatedObject'};
            ax_tag_for_log_message = ''; % Default for log message
            if isprop(ax, 'Tag') && ~isempty(ax.Tag); ax_tag_for_log_message = ax.Tag; else; ax_tag_for_log_message = sprintf('of type %s (no Tag)', class(ax)); end

            for ad_idx = 1:length(appdata_names_to_clear)
                current_ad_name = appdata_names_to_clear{ad_idx};
                if isappdata(legend_handle_to_use, current_ad_name)
                    rmappdata(legend_handle_to_use, current_ad_name);
                    log_message(params, sprintf('Cleared stale %s appdata from legend (Axes: %s).', current_ad_name, ax_tag_for_log_message), 2, 'Debug');
                end
            end
        end

if params.interactive_legend && isprop(legend_handle_to_use, 'ItemHitFcn') && verLessThan('matlab','9.7') == 0 % R2019b+
            try
                if ~isempty(legend_handle_to_use.ItemHitFcn); legend_handle_to_use.ItemHitFcn=''; end % Clear previous
                legend_handle_to_use.ItemHitFcn = @(src,evt)toggle_plot_visibility_adv(src,evt,params);

                % Initialize appdata for visibility states
                if ~isappdata(legend_handle_to_use,'OriginalVisibilityStates') && ...
                        isprop(legend_handle_to_use,'PlotChildren') && ~isempty(legend_handle_to_use.PlotChildren)

                    valid_legend_plot_children = legend_handle_to_use.PlotChildren(arrayfun(@isvalid, legend_handle_to_use.PlotChildren));
                    if ~isempty(valid_legend_plot_children)
                        original_visibility = arrayfun(@(h)get(h,'Visible'), valid_legend_plot_children,'UniformOutput',false);
                        setappdata(legend_handle_to_use,'OriginalVisibilityStates',original_visibility);
                        setappdata(legend_handle_to_use,'IsolationModeActive',false);
                    end
                end
                log_message(params,sprintf('  Interactive legend enabled for Axes (Tag: %s).',ax.Tag),2,'Info');
            catch me_legend_interactive
                log_message(params,sprintf('Could not set interactive legend: %s',me_legend_interactive.message),1,'Warning');
            end
elseif params.interactive_legend && verLessThan('matlab','9.7') == 1
            log_message(params, 'Interactive legend (ItemHitFcn) requires MATLAB R2019b or newer.', 1, 'Info');
        end
        % After setting properties, update appearance based on visibility
        update_legend_item_appearance(legend_handle_to_use, params);

        % Check for legend font substitution
        if ~isempty(params.font_name) && isprop(legend_handle_to_use, 'FontName')
            actual_legend_font_name = get(legend_handle_to_use, 'FontName');
            if ~strcmpi(actual_legend_font_name, params.font_name)
                log_message(params, sprintf('Font "%s" not fully matched for legend entries. MATLAB used "%s". Ensure font is installed.', ...
                                          params.font_name, actual_legend_font_name), 1, 'Warning');
            end
        end
    end
catch me_legend
    log_message(params, sprintf('Error processing legend for Axes (Tag: %s): %s (Line: %d)', ax.Tag, me_legend.message, me_legend.stack(1).line), 1, 'Warning');
end
end

% --- Local Helper Function: Convert struct to name-value pairs ---
function nv_pairs = local_struct_to_nv_pairs(s)
fields = fieldnames(s);
nv_pairs = cell(1, 2 * numel(fields));
for k_local_struct = 1:numel(fields) % Renamed loop variable
    nv_pairs{2*k_local_struct-1} = fields{k_local_struct};
    nv_pairs{2*k_local_struct} = s.(fields{k_local_struct});
end
end

% --- Helper Function: Beautify Colorbar ---
function beautify_colorbar(ax, params, font_size, label_font_size, axis_line_width_scaled)
colorbar_handle = find_associated_colorbar(ax, params); % Use the new helper
if ~isempty(colorbar_handle) && isvalid(colorbar_handle)
    colorbar_to_style = colorbar_handle(1); % Should only be one per axes
    safe_set(params, colorbar_to_style, 'FontSize', round(font_size*0.9), 'LineWidth', axis_line_width_scaled*0.85, 'Color', params.axis_color, 'TickDirection', 'out', 'FontName', params.font_name);

    % Check for colorbar font substitution (for tick labels)
    if ~isempty(params.font_name) && isprop(colorbar_to_style, 'FontName')
        actual_colorbar_font_name = get(colorbar_to_style, 'FontName');
        if ~strcmpi(actual_colorbar_font_name, params.font_name)
            colorbar_tag_info = ''; if isprop(colorbar_to_style, 'Tag'); colorbar_tag_info = colorbar_to_style.Tag; end
            log_message(params, sprintf('Font "%s" not fully matched for colorbar (Tag: %s) tick labels. MATLAB used "%s". Ensure font is installed.', ...
                                      params.font_name, colorbar_tag_info, actual_colorbar_font_name), 1, 'Warning');
        end
    end

    if isprop(colorbar_to_style,'Label') && isvalid(colorbar_to_style.Label)
        process_text_prop(colorbar_to_style.Label,colorbar_to_style.Label.String,label_font_size,'normal',params.text_color,params.font_name,params);
    end
end
end

% --- Helper Function: Process Text Properties (Title, Labels, etc.) ---
function process_text_prop(text_handle, original_string, font_size, font_weight, color, requested_font_name, params) % Renamed font_name to requested_font_name
if isempty(text_handle) || ~isvalid(text_handle); return; end

try
    final_string = format_text_string(original_string);
    is_truly_empty = false;
    if ischar(original_string) && isempty(original_string); is_truly_empty = true;
    elseif iscell(original_string) && (isempty(original_string) || all(cellfun('isempty',original_string))); is_truly_empty = true;
    elseif isstring(original_string) && (isscalar(original_string) && strlength(original_string)==0 || isempty(original_string)); is_truly_empty = true;
    end

    if isempty(final_string) && is_truly_empty
        if isprop(text_handle,'Visible'); safe_set(params, text_handle,'Visible','off'); end
        return;
    else
        if isprop(text_handle,'Visible'); safe_set(params, text_handle,'Visible','on'); end
    end

    % No more interpreter checking or TeX escaping.
    % String is set as final_string directly.

    safe_set(params, text_handle, ...
        'String', final_string, ... % Set the string as formatted
        'FontName', requested_font_name, ... % Attempt to set the requested font
        'FontSize', max(1, font_size), ...
        'FontWeight', font_weight, ...
        'Color', color);

    % Check for font substitution
    if ~isempty(requested_font_name) && isprop(text_handle, 'FontName')
        actual_font_name_on_object = get(text_handle, 'FontName');
        if ~strcmpi(actual_font_name_on_object, requested_font_name)
            preview_string = char(original_string); % Use original_string for preview as final_string might be cell
            if length(preview_string) > 20; preview_string = [preview_string(1:17) '...']; end
            object_tag_info = '';
            if isprop(text_handle, 'Tag') && ~isempty(text_handle.Tag); object_tag_info = ['Tag: ' text_handle.Tag];
            else; object_tag_info = ['Type: ' class(text_handle)]; end % Use type if no tag

            log_message(params, sprintf('Font "%s" not fully matched for text object (%s, String: "%s"). MATLAB used "%s". Ensure font is installed.', ...
                                      requested_font_name, object_tag_info, strtrim(preview_string), actual_font_name_on_object), 1, 'Warning');
        end
    end
catch me_text_prop
    string_preview = char(original_string); if length(string_preview) > 30; string_preview = [string_preview(1:27) '...']; end
    log_message(params, sprintf('Error setting text property (String: "%s"): %s', string_preview, me_text_prop.message), 1, 'Warning');
end
end

% --- Helper Function: Format Multi-line/Cell Strings ---
function fixed_string = format_text_string(original_string)
if iscell(original_string)
    non_empty_cells = original_string(~cellfun('isempty',original_string));
    if isempty(non_empty_cells)
        fixed_string = '';
    else
        fixed_string = strjoin(non_empty_cells,'\newline');
    end
elseif isstring(original_string) % Handle MATLAB string type
    if isempty(original_string) || all(strlength(original_string)==0) % Empty string array or all elements are ""
        fixed_string = '';
    else
        fixed_string_cell = cellstr(original_string); % Convert to cell array of char vectors
        fixed_string = strjoin(fixed_string_cell, '\newline'); % Join with newline
    end
else % char array or other
    fixed_string = original_string;
end
end

% --- Helper Function: Expand Axis Limits ---
function expand_axis_limits(ax,limit_property_name,factor, params)
try
    current_limit = get(ax,limit_property_name);
    if diff(current_limit) < 1e-9 || ~all(isfinite(current_limit)); return; end

    scale_property_name = [limit_property_name(1) 'Scale']; is_log = false;
    if isprop(ax,scale_property_name) && strcmpi(get(ax,scale_property_name),'log')
        is_log = true;
    end

    if is_log
        if all(current_limit > 0) % Log scale only works for positive limits
            log_limit = log10(current_limit);
            range = diff(log_limit);
            if abs(range) < 1e-9; range = abs(log_limit(1))*0.1 + 1e-9; end % Handle very small/zero log range

            new_limit_log = [log_limit(1) - range*factor, log_limit(2) + range*factor];
            new_limit = 10.^new_limit_log;

            % Prevent lower limit from becoming zero or negative on log scale
            if new_limit(1) <= 0
                new_limit(1) = current_limit(1) * (1 - factor*0.8); % Be more conservative
                if new_limit(1) <= 0; new_limit(1) = min(current_limit(current_limit>0))/2; end % Fallback
                if new_limit(1) <= 0; new_limit(1) = eps(class(current_limit(1))); end % Ultimate fallback
            end
        else
            log_message(params, sprintf('Cannot expand log-scaled %s for Axes (Tag: %s) because limits are not all positive. Limits: [%s].', limit_property_name, ax.Tag, num2str(current_limit)), 2, 'Warning');
            return;
        end
    else % Linear scale
        range = diff(current_limit);
        if abs(range) < 1e-9; range = abs(current_limit(1))*0.1 + 1e-9; end % Handle very small/zero linear range

        new_limit = [current_limit(1) - range*factor, current_limit(2) + range*factor];

        % Prevent crossing zero if original limit was at zero
        if abs(current_limit(1)) < 1e-9 && new_limit(1) < 0; new_limit(1) = 0; end
        if abs(current_limit(2)) < 1e-9 && new_limit(2) > 0; new_limit(2) = 0; end
    end

    if all(isfinite(new_limit)) && new_limit(2) > new_limit(1)
        safe_set(params, ax,limit_property_name,new_limit);
    end

catch me_expand
    log_message(params, sprintf('Failed to expand axis limits for %s on Axes (Tag: %s): %s. Limits remain unchanged.', limit_property_name, ax.Tag, me_expand.message), 2, 'Warning');
end
end

% --- Helper Function: Check for Geographic Axes ---
function tf = isgeoaxes(ax)
tf = isa(ax,'matlab.graphics.axis.GeographicAxes') || ...
    (isprop(ax,'Type') && strcmp(ax.Type,'geoaxes')); % Older check
end

% --- Helper Function: Find Associated Colorbar ---
function colorbar_handle = find_associated_colorbar(ax, params_for_log)
colorbar_handle = [];

% Modern way: Axes has a Colorbar property (R2014b+)
if isprop(ax, 'Colorbar') && isa(ax.Colorbar, 'matlab.graphics.illustration.ColorBar') && isvalid(ax.Colorbar)
    colorbar_handle = ax.Colorbar;
else % Fallback: find colorbars in figure and check association
    if isfield(params_for_log, 'all_colorbars_in_fig')
        all_colorbars_in_fig = params_for_log.all_colorbars_in_fig;
        for colorbar_idx=1:length(all_colorbars_in_fig)
            current_colorbar_candidate = all_colorbars_in_fig(colorbar_idx);
            if ~isvalid(current_colorbar_candidate); continue; end

            colorbar_associated_ax = [];
            if isprop(current_colorbar_candidate,'Axes'); % R2022a+
                colorbar_associated_ax = current_colorbar_candidate.Axes;
            elseif isprop(current_colorbar_candidate,'Axle') && isprop(current_colorbar_candidate.Axle,'Peer') % Older
                colorbar_associated_ax = current_colorbar_candidate.Axle.Peer;
            end

            if isequal(colorbar_associated_ax, ax)
                colorbar_handle = current_colorbar_candidate;
                break;
            end
        end
    end
end
if ~isempty(colorbar_handle) && isvalid(colorbar_handle) % check isvalid for colorbar_handle
    colorbar_tag_info = ''; if isprop(colorbar_handle,'Tag'); colorbar_tag_info = colorbar_handle.Tag; end
    ax_tag_info = ''; if isprop(ax,'Tag'); ax_tag_info = ax.Tag; end
    log_message(params_for_log, sprintf('Found associated colorbar (Tag: %s) for axes (Tag: %s)', colorbar_tag_info, ax_tag_info), 2, 'Debug');
end
end

% --- Helper Function: Advanced Interactive Legend Callback ---
function toggle_plot_visibility_adv(legend_handle, event_data, params)
try
    clicked_plot_object = event_data.Peer;
    if ~isvalid(clicked_plot_object); return; end

    fig_handle = ancestor(legend_handle, 'figure');
    modifier_keys = get(fig_handle, 'CurrentModifier');
    is_ctrl_cmd_pressed = any(strcmpi(modifier_keys, 'control')) || any(strcmpi(modifier_keys, 'command'));

    all_legend_plots = [];
    if isprop(legend_handle, 'PlotChildren')
        all_legend_plots = legend_handle.PlotChildren(arrayfun(@isvalid, legend_handle.PlotChildren));
    end
    if isempty(all_legend_plots)
        log_message(params, 'Interactive legend: No valid PlotChildren found.', 1, 'Warning');
        return;
    end

    original_visibility_states = getappdata(legend_handle, 'OriginalVisibilityStates');
    isolation_active = getappdata(legend_handle, 'IsolationModeActive');
    if isempty(isolation_active); isolation_active = false; end

    % --- Nested Helper to Restore Visibility ---
    function unisolate_all()
        if ~isempty(original_visibility_states)
            for k_vis = 1:length(all_legend_plots)
                if k_vis <= length(original_visibility_states) && ~isempty(original_visibility_states{k_vis})
                    safe_set(params, all_legend_plots(k_vis), 'Visible', original_visibility_states{k_vis});
                else
                    safe_set(params, all_legend_plots(k_vis), 'Visible', 'on'); % Fallback
                end
            end
        else % Fallback if OriginalVisibilityStates is missing
            for k_vis = 1:length(all_legend_plots)
                safe_set(params, all_legend_plots(k_vis), 'Visible', 'on');
            end
        end
        setappdata(legend_handle, 'IsolationModeActive', false);
        if isappdata(legend_handle, 'IsolatedObject'); rmappdata(legend_handle, 'IsolatedObject'); end
        log_message(params, 'Legend: Isolation mode deactivated.', 2, 'Info');
    end

    % --- Main Logic ---
    if is_ctrl_cmd_pressed
        is_currently_isolated_object = isolation_active && isappdata(legend_handle, 'IsolatedObject') && (getappdata(legend_handle, 'IsolatedObject') == clicked_plot_object);

        if is_currently_isolated_object
            unisolate_all();
        else % Isolate this new object
            for k = 1:length(all_legend_plots)
                safe_set(params, all_legend_plots(k), 'Visible', 'off');
            end
            safe_set(params, clicked_plot_object, 'Visible', 'on');
            setappdata(legend_handle, 'IsolationModeActive', true);
            setappdata(legend_handle, 'IsolatedObject', clicked_plot_object);
            object_display_name = ''; if isprop(clicked_plot_object, 'DisplayName'); object_display_name = get(clicked_plot_object, 'DisplayName'); end
            log_message(params, sprintf('Legend: Object "%s" isolated.', object_display_name), 2, 'Info');
        end
    else % Normal click
        if isolation_active
            unisolate_all();
        end

        % Toggle visibility of the clicked plot object
        current_visibility = get(clicked_plot_object, 'Visible');
        if strcmpi(current_visibility, 'on')
            safe_set(params, clicked_plot_object, 'Visible', 'off');
        else
            safe_set(params, clicked_plot_object, 'Visible', 'on');
        end

        % Update the stored original visibility state to reflect the manual toggle
        if ~isempty(original_visibility_states)
            idx = find(all_legend_plots == clicked_plot_object, 1);
            if ~isempty(idx) && idx <= length(original_visibility_states)
                original_visibility_states{idx} = get(clicked_plot_object, 'Visible');
                setappdata(legend_handle, 'OriginalVisibilityStates', original_visibility_states);
            end
        end
    end

    update_legend_item_appearance(legend_handle, params);
catch me_interactive_legend
    log_message(params, sprintf('Error in interactive legend callback: %s', me_interactive_legend.message), 1, 'Warning');
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

    default_text_color = params.text_color;
    faded_text_color = default_text_color*0.4 + 0.5; % Make it grayish

for entry_index=1:num_to_process
        entry = legend_entries(entry_index);
        corresponding_plot = plot_objects(entry_index);
        if ~isvalid(entry) || ~isvalid(corresponding_plot); continue; end

        is_plot_visible = strcmpi(get(corresponding_plot,'Visible'),'on');

        % Update text label appearance
        if isprop(entry,'Label') && isprop(entry.Label,'Color') && isvalid(entry.Label)
            if is_plot_visible
                safe_set(params, entry.Label,'Color', default_text_color);
            else
                safe_set(params, entry.Label,'Color', faded_text_color);
            end
        end

        % Update icon appearance (more complex)
        if isprop(entry,'Icon') && isprop(entry.Icon,'Children') && isvalid(entry.Icon)
            icon_parts = entry.Icon.Children(arrayfun(@isvalid, entry.Icon.Children));
            for icon_part_idx = 1:length(icon_parts)
                part = icon_parts(icon_part_idx);
                if ~isvalid(part); continue; end

                original_plot_color = []; % Attempt to get base color from the plot object
                alpha_value = 1.0; if ~is_plot_visible; alpha_value = 0.3; end

                if isa(part, 'matlab.graphics.primitive.Line') % Line in icon
                    if isprop(corresponding_plot, 'Color') && ~ischar(corresponding_plot.Color)
                        original_plot_color = corresponding_plot.Color;
                    end
                    if ~isempty(original_plot_color); safe_set(params, part, 'Color', original_plot_color); end
                    if isprop(part, 'ColorAlpha'); safe_set(params, part, 'ColorAlpha', alpha_value); % R2022a+
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
                        if isprop(part, 'FaceAlpha'); safe_set(params, part, 'FaceAlpha', alpha_value); end
                    end
                    if is_edge_like
                        safe_set(params, part, 'EdgeColor', original_plot_color*0.7); % Darker edge
                        if isprop(part, 'EdgeAlpha'); safe_set(params, part, 'EdgeAlpha', alpha_value); end
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
catch me_legend_appearance
    log_message(params, sprintf('Error updating legend item appearance: %s (Line: %d)', me_legend_appearance.message, me_legend_appearance.stack(1).line),1,'Warning');
end
end

% --- Helper Function: Safely Set Graphics Property ---
function safe_set(params_for_log, handle_in, varargin)
try
    if ~isvalid(handle_in); return; end % Early exit if handle is invalid

    % PERFORMANCE: Get all properties at once to minimize calls to the graphics engine.
    all_current_props = get(handle_in);
    props_to_set = struct();

    for k_arg = 1:2:length(varargin)
        prop_name = varargin{k_arg};
        new_value = varargin{k_arg+1};

        % Check if the property exists on the object using the retrieved struct
        if isfield(all_current_props, prop_name)
            current_value = all_current_props.(prop_name);
            % Only add to set struct if the new value is different
            if ~isequal(current_value, new_value) % Only set if different
                props_to_set.(prop_name) = new_value;
            end
        else
            % Log attempt to set non-existent property at a debug level if desired
            % log_message(params_for_log, sprintf('Property "%s" does not exist for handle of type "%s".', prop_name, class(handle_in)), 2, 'Debug');
        end
    end

    % Batch set only the properties that have changed
    if ~isempty(fieldnames(props_to_set))
        set(handle_in, props_to_set);
    end
catch me_set
    prop_name_for_log_message = 'multiple properties';
    try % Try to get a specific property name if error was in loop (less likely now)
        if exist('prop_name','var'); prop_name_for_log_message = prop_name; end
    catch; end

    log_message(params_for_log, sprintf('safe_set failed for property "%s" on handle of type "%s" (Tag: %s): %s', ...
        prop_name_for_log_message, class(handle_in), handle_in.Tag, me_set.message), 2, 'Debug');
end
end

% --- Helper Function: Safely Hold Axes ---
function safe_hold(params_for_log, ax_handle, state)
try
    if isvalid(ax_handle) && isprop(ax_handle, 'NextPlot')
        current_next_plot = get(ax_handle, 'NextPlot');
        target_next_plot = '';
        if strcmpi(state, 'on'); target_next_plot = 'add';
        elseif strcmpi(state, 'off'); target_next_plot = 'replace'; end

        if ~isempty(target_next_plot) && ~strcmpi(current_next_plot, target_next_plot)
            set(ax_handle, 'NextPlot', target_next_plot);
        end
    end
catch me_hold
    log_message(params_for_log, sprintf('safe_hold failed for state "%s" on handle of type "%s" (Tag: %s): %s', ...
        state, class(ax_handle), ax_handle.Tag, me_hold.message), 2, 'Debug');
end
end

% --- Helper Function: Log Message ---
function log_message(params_struct_or_base_defaults, message_string, level, type_string)
if nargin < 4; type_string = 'Info'; end

current_log_level = 0; % Default to silent if log_level field is missing
if isstruct(params_struct_or_base_defaults) && isfield(params_struct_or_base_defaults, 'log_level')
    log_level_value = params_struct_or_base_defaults.log_level;
    if isnumeric(log_level_value) && isscalar(log_level_value)
        current_log_level = log_level_value;
    end
end

if current_log_level >= level
    fprintf('[BeautifyFig - %s L%d] %s\n', type_string, level, message_string);
end
end

% --- Helper Function: Apply Stats Overlay ---
function apply_stats_overlay(ax, params, scale_factor)
stats_overlay_params = params.stats_overlay;

target_plot_object = [];
ax_children = get(ax, 'Children');

if ~isempty(stats_overlay_params.target_plot_handle_tag)
    for child_index = 1:length(ax_children)
        child = ax_children(child_index);
        % Check direct child or children of a group (e.g., hggroup for boxplot)
        if isprop(child,'Tag') && strcmp(get(child,'Tag'), stats_overlay_params.target_plot_handle_tag) && ...
                (isa(child, 'matlab.graphics.chart.primitive.Line') || isa(child, 'matlab.graphics.chart.primitive.Scatter'))
            target_plot_object = child; break;
        elseif isa(child, 'matlab.graphics.primitive.Group') % e.g. hggroup
            potential_matches_in_group = findobj(child, 'Type',{'line','scatter'},'Tag', stats_overlay_params.target_plot_handle_tag, '-depth', Inf); % Search within group
            if ~isempty(potential_matches_in_group)
                target_plot_object = potential_matches_in_group(1); break;
            end
        end
    end
    if isempty(target_plot_object)
        log_message(params, sprintf('Stats Overlay: No plot found with tag "%s" in current axes.', stats_overlay_params.target_plot_handle_tag), 2, 'Info'); return;
    end
else % Tag is empty, find first suitable plot
    for child_index = 1:length(ax_children)
        child = ax_children(child_index);
        if (isa(child, 'matlab.graphics.chart.primitive.Line') || ...
                isa(child, 'matlab.graphics.chart.primitive.Scatter')) && ...
                isprop(child, 'YData') && ~isempty(child.YData) && ...
                isprop(child, 'Visible') && strcmp(get(child,'Visible'),'on')
            target_plot_object = child; break;
        end
    end
    if isempty(target_plot_object)
        log_message(params, 'Stats Overlay: No suitable (Line/Scatter, visible, YData) plot found in current axes.', 2, 'Info'); return;
    else % A target_plot_object was found
        % Check if the selection was ambiguous (only if tag was empty)
        if isempty(stats_overlay_params.target_plot_handle_tag)
            num_suitable_plots = 0;
            for child_check_index = 1:length(ax_children)
                child_check = ax_children(child_check_index);
                 if (isa(child_check, 'matlab.graphics.chart.primitive.Line') || ...
                     isa(child_check, 'matlab.graphics.chart.primitive.Scatter')) && ...
                     isprop(child_check, 'YData') && ~isempty(child_check.YData) && ...
                     isprop(child_check, 'Visible') && strcmp(get(child_check,'Visible'),'on')
                    num_suitable_plots = num_suitable_plots + 1;
                end
            end
            if num_suitable_plots > 1
                target_tag_info = '';
                if isprop(target_plot_object, 'Tag') && ~isempty(get(target_plot_object, 'Tag'))
                    target_tag_info = sprintf('Tag: "%s"', get(target_plot_object, 'Tag'));
                else
                    target_tag_info = sprintf('Type: %s (no Tag, index %d in children)', class(target_plot_object), find(ax_children == target_plot_object,1));
                end
                log_message(params, sprintf('Stats Overlay: target_plot_handle_tag was empty and %d suitable plots found. Auto-selected first suitable plot: %s.', num_suitable_plots, target_tag_info), 2, 'Info');
            end
        end
    end
end

if isempty(target_plot_object) % Re-check, because it might be empty if tag was specified but not found
    log_message(params, 'Stats Overlay: No target plot object found after checks. Cannot apply overlay.', 2, 'Info'); return;
end

if ~isprop(target_plot_object, 'XData') || ~isprop(target_plot_object, 'YData')
    log_message(params, 'Stats Overlay: Target plot object does not have XData or YData.', 2, 'Info'); return;
end

x_data_raw = get(target_plot_object, 'XData');
y_data_raw = get(target_plot_object, 'YData');

if isempty(x_data_raw) || ~isnumeric(x_data_raw) || isempty(y_data_raw) || ~isnumeric(y_data_raw)
    log_message(params, 'Stats Overlay: XData or YData is empty or non-numeric.', 2, 'Info'); return;
end

if length(x_data_raw) ~= length(y_data_raw)
    log_message(params, 'Stats Overlay: XData and YData lengths do not match.', 1, 'Warning'); return;
end

% Get current axis limits
current_x_limit = get(ax, 'XLim');
% current_ylim = get(ax, 'YLim'); % YLim filtering might be added later if necessary for specific stats

% Filter data based on current XLim
% Ensure x_data_raw and y_data_raw are column vectors for consistent indexing
x_data_column = x_data_raw(:);
y_data_column = y_data_raw(:);

visible_indices = (x_data_column >= current_x_limit(1)) & (x_data_column <= current_x_limit(2));

% Further filter out non-finite Y values from the visible portion
y_data_visible_potentially_nonfinite = y_data_column(visible_indices);
finite_y_indices_in_visible = isfinite(y_data_visible_potentially_nonfinite);

y_data = y_data_visible_potentially_nonfinite(finite_y_indices_in_visible);
% x_data_for_stats = x_data_column(visible_indices); % X data corresponding to y_data, if needed for future stats
% x_data_for_stats = x_data_for_stats(finite_y_indices_in_visible);


if isempty(y_data)
    log_message(params, sprintf('Stats Overlay: No finite YData available within the current XLim [%.2f, %.2f] for statistics.', current_x_limit(1), current_x_limit(2)), 2, 'Info'); return;
end

stats_string_lines = cell(1,0); % Initialize as row cell
for stat_index = 1:length(stats_overlay_params.statistics)
    stat_name = lower(stats_overlay_params.statistics{stat_index});
    value = NaN; stat_label = '';
    switch stat_name
        case 'mean'; value = mean(y_data); stat_label = 'Mean';
        case 'std'; value = std(y_data); stat_label = 'Std Dev';
        case 'min'; value = min(y_data); stat_label = 'Min';
        case 'max'; value = max(y_data); stat_label = 'Max';
        case 'n'; value = length(y_data); stat_label = 'N';
        case 'median'; value = median(y_data); stat_label = 'Median';
        case 'sum'; value = sum(y_data); stat_label = 'Sum';
        otherwise
            log_message(params,['Stats Overlay: Unknown statistic "' stat_name '" requested.'],1,'Warning'); continue;
    end
    if ~isnan(value)
        if any(strcmp(stat_name, {'n', 'count'})) % Integer stats
            stats_string_lines{end+1} = sprintf('%s: %d', stat_label, round(value));
        else % Floating point stats
            stats_string_lines{end+1} = sprintf('%s: %.*f', stat_label, stats_overlay_params.precision, value);
        end
    end
end

if isempty(stats_string_lines); return; end
% full_stats_str = strjoin(stats_string_lines, '\newline'); % Removed: Use cell array directly

% Robustly determine stats_font_name
stats_font_name = stats_overlay_params.font_name;
if isempty(stats_font_name) || (ischar(stats_font_name) && isempty(strtrim(stats_font_name)))
    stats_font_name = params.font_name;
end
if isempty(stats_font_name) || (ischar(stats_font_name) && isempty(strtrim(stats_font_name)))
    stats_font_name = 'Helvetica'; % A universally available safe default
    log_message(params, 'Stats Overlay: stats_font_name was empty after checking params.font_name, defaulted to Helvetica.', 1, 'Warning');
end

stats_text_color = stats_overlay_params.text_color;
if isempty(stats_text_color) || (ischar(stats_text_color) && isempty(strtrim(stats_text_color))) % Also treat blank string as empty for color
    stats_text_color = params.text_color;
end

% Base font size for stats is derived from scaled label font size
base_axes_label_font_size = round(params.base_font_size * params.label_scale * scale_factor);
stats_font_size = round(base_axes_label_font_size * stats_overlay_params.font_scale_factor);
stats_font_size = max(stats_font_size, 6); % Ensure minimum readability

original_axes_units = get(ax, 'Units');
safe_set(params, ax, 'Units', 'normalized'); % Set units for text placement

% Default offsets from axes edge, in normalized units
x_text_offset_norm = 0.03; y_text_offset_norm = 0.03;
text_x_norm = 0; text_y_norm = 0; horizontal_align = 'left'; vertical_align = 'bottom';

switch lower(stats_overlay_params.position)
    case 'northeast_inset'; text_x_norm = 1 - x_text_offset_norm; text_y_norm = 1 - y_text_offset_norm; horizontal_align = 'right'; vertical_align = 'top';
    case 'northwest_inset'; text_x_norm = x_text_offset_norm;     text_y_norm = 1 - y_text_offset_norm; horizontal_align = 'left';  vertical_align = 'top';
    case 'southwest_inset'; text_x_norm = x_text_offset_norm;     text_y_norm = y_text_offset_norm;     horizontal_align = 'left';  vertical_align = 'bottom';
    case 'southeast_inset'; text_x_norm = 1 - x_text_offset_norm; text_y_norm = y_text_offset_norm;     horizontal_align = 'right'; vertical_align = 'bottom';
        % Add more positions or 'best_text' later if needed
    otherwise % Default to northeast_inset
        log_message(params, sprintf('Stats Overlay: Unknown position "%s". Defaulting to northeast_inset.', stats_overlay_params.position), 1, 'Warning');
        text_x_norm = 1 - x_text_offset_norm; text_y_norm = 1 - y_text_offset_norm; horizontal_align = 'right'; vertical_align = 'top';
end

text_props = {
    'Units', 'normalized', 'String', stats_string_lines, 'FontName', stats_font_name, ... % Changed full_stats_str to stats_string_lines
    'FontSize', stats_font_size, 'Color', stats_text_color, 'HorizontalAlignment', horizontal_align, ...
    'VerticalAlignment', vertical_align, ...
    'Tag', 'BeautifyFig_StatsOverlay' % Tag to identify/avoid re-processing
    };

% Handle background and edge colors for the text box
background_color_final = 'none';
edge_color_final = 'none';

if ~isempty(stats_overlay_params.background_color) && ~(ischar(stats_overlay_params.background_color) && isempty(strtrim(stats_overlay_params.background_color)))
    background_color_value = stats_overlay_params.background_color;
    if ischar(background_color_value) && strcmpi(background_color_value, 'figure')
        fig_handle_local = ancestor(ax,'figure');
        if ~isempty(fig_handle_local) && isvalid(fig_handle_local); background_color_final = get(fig_handle_local,'Color'); end
    elseif isnumeric(background_color_value) || (ischar(background_color_value) && ~strcmpi(background_color_value,'none')) % Check it's not 'none' before assigning
        background_color_final = background_color_value;
        % If background_color_value was '' (and not just spaces), background_color_final remains 'none'
    end
end

if ~isempty(stats_overlay_params.edge_color) && ~(ischar(stats_overlay_params.edge_color) && isempty(strtrim(stats_overlay_params.edge_color)))
    edge_color_value = stats_overlay_params.edge_color;
    if ischar(edge_color_value) && strcmpi(edge_color_value, 'axes')
        edge_color_final = params.axis_color; % Use the themed axis color
    elseif isnumeric(edge_color_value) || (ischar(edge_color_value) && ~strcmpi(edge_color_value,'none')) % Check it's not 'none'
        edge_color_final = edge_color_value;
        % If edge_color_value was '' (and not just spaces), edge_color_final remains 'none'
    end
end

has_background = ~(ischar(background_color_final) && strcmpi(background_color_final, 'none'));
has_edge = ~(ischar(edge_color_final) && strcmpi(edge_color_final, 'none'));

if has_background; text_props = [text_props, {'BackgroundColor', background_color_final}]; end
if has_edge; text_props = [text_props, {'EdgeColor', edge_color_final}]; end

if has_background || has_edge % Add margin if background or edge is active
    text_props = [text_props, {'Margin', stats_font_size*0.3}]; % Margin proportional to font size
end

% Remove any pre-existing stats overlay from this function for this axes
old_stats_text = findobj(ax, 'Type', 'text', 'Tag', 'BeautifyFig_StatsOverlay');
if ~isempty(old_stats_text); delete(old_stats_text); end

% Defensive checks before text() call
if isempty(stats_font_name)
    log_message(params, 'Stats Overlay: stats_font_name was unexpectedly empty, defaulting to Helvetica.', 1, 'Warning');
    stats_font_name = 'Helvetica';
end
if isempty(stats_text_color)
    log_message(params, 'Stats Overlay: stats_text_color was unexpectedly empty, defaulting to black.', 1, 'Warning');
    stats_text_color = [0 0 0]; % Default to black
end
if isempty(horizontal_align)
    log_message(params, 'Stats Overlay: horizontal_align was unexpectedly empty, defaulting to left.', 1, 'Warning');
    horizontal_align = 'left';
end
if isempty(vertical_align)
    log_message(params, 'Stats Overlay: vertical_align was unexpectedly empty, defaulting to bottom.', 1, 'Warning');
    vertical_align = 'bottom';
end
if isempty(stats_string_lines) % text() might handle cell(1,0) but not a truly empty [] for 'String'
    log_message(params, 'Stats Overlay: stats_string_lines was unexpectedly empty, defaulting to an empty cell string.', 1, 'Warning');
    stats_string_lines = {''}; % Use a single empty string to be safe if text() fails with {} for String via {:}
end

log_message(params, sprintf('Attempting to create stats overlay text object in axes (Tag: %s)...', ax.Tag), 2, 'Info');
text_handle_stats_overlay = text(ax, text_x_norm, text_y_norm, 0, text_props{:}); % Add Z=0 for 2D text
log_message(params, sprintf('Stats overlay text object created. Handle valid: %s. Tag: %s', num2str(isvalid(text_handle_stats_overlay)), get(text_handle_stats_overlay,'Tag')), 2, 'Info');

    % Check for stats overlay font substitution
    if isvalid(text_handle_stats_overlay) && ~isempty(stats_font_name) && isprop(text_handle_stats_overlay, 'FontName')
        actual_stats_font_name = get(text_handle_stats_overlay, 'FontName');
        if ~strcmpi(actual_stats_font_name, stats_font_name)
            ax_tag_info = ''; if isprop(ax, 'Tag') && ~isempty(ax.Tag); ax_tag_info = ax.Tag; else ax_tag_info = sprintf('Type %s', class(ax)); end
            log_message(params, sprintf('Font "%s" not fully matched for stats overlay on axes %s. MATLAB used "%s". Ensure font is installed.', ...
                                      stats_font_name, ax_tag_info, actual_stats_font_name), 1, 'Warning');
        end
    end

safe_set(params, ax, 'Units', original_axes_units); % Restore original units
end
classdef TestBeautifyFigure < matlab.unittest.TestCase
    % Test class for beautify_figure.m

    properties
        outputDir = 'test_beautify_output_unittest';
        testFigure;
        originalPath;
    end

    properties (TestParameter)
        % Used for Test Case 2: Style Presets
        presetName = {'default', 'publication', 'presentation_dark', 'presentation_light', 'minimalist'};
        % Used for Test Case 18: 3D View Presets
        viewPreset = {'iso', 'top', 'front', 'side_left', 'side_right'};
    end

    methods (TestClassSetup)
        function classSetup(test)
            if ~exist(test.outputDir, 'dir')
                mkdir(test.outputDir);
            end
            fprintf('Test figures will be saved in: %s\n', fullfile(pwd, test.outputDir));
            test.originalPath = path; 
            curr_dir = fileparts(mfilename('fullpath'));
            addpath(curr_dir); % Add the directory of TestBeautifyFigure.m
            
            parent_dir = fileparts(curr_dir); 
            addpath(parent_dir);

            fprintf('Added %s and %s to path.\n', curr_dir, parent_dir);
            
            if exist('beautify_figure', 'file') ~= 2
                warning('beautify_figure.m not found on path. Tests may fail. Current path:\n%s', path);
            else
                fprintf('beautify_figure.m found.\n');
            end
        end
    end

    methods (TestClassTeardown)
        function classTeardown(test)
            fprintf('\n--- All tests complete ---\n');
            fprintf('Please check the "%s" directory for saved figures.\n', test.outputDir);
            path(test.originalPath);
            fprintf('Restored original path.\n');
        end
    end

    methods (TestMethodSetup)
        function methodSetup(test)
            % Close any existing figure from a previous test method (especially for parameterized tests)
            if ~isempty(test.testFigure) && ishandle(test.testFigure)
                close(test.testFigure);
            end
            test.testFigure = figure('Visible', 'off');
            fprintf('\n--- Starting test: %s ---\n', test.DisplayName);
        end
    end

    methods (TestMethodTeardown)
        function methodTeardown(test)
            if ~isempty(test.testFigure) && ishandle(test.testFigure)
                close(test.testFigure);
            end
            fprintf('--- Finished test: %s ---\n', test.DisplayName);
        end
    end

    methods (Access = private)
        function saveTestFigure(test, stage, filenameSuffix)
            fig_handle = test.testFigure;
            safeFilenameSuffix = regexprep(filenameSuffix, '[^\w_.-]', '_');
            if ~ishandle(fig_handle) || ~strcmp(get(fig_handle, 'Type'), 'figure')
                fprintf('ERROR: Invalid figure handle for test suffix: %s, stage: %s.\n', safeFilenameSuffix, stage);
                return;
            end
            filename = fullfile(test.outputDir, sprintf('%s_%s.png', safeFilenameSuffix, stage));
            try
                drawnow; 
                original_visibility = get(fig_handle, 'Visible');
                if strcmp(original_visibility, 'off'); set(fig_handle, 'Visible', 'on'); drawnow; end
                saveas(fig_handle, filename);
                fprintf('Saved: %s\n', filename);
                if strcmp(original_visibility, 'off'); set(fig_handle, 'Visible', 'off'); end
            catch ME
                fprintf('ERROR saving figure %s: %s\n', filename, ME.message);
            end
        end
    end

    methods (Test)
        % --- Test Case 1: Default Beautification ---
        function testDefaultBeautification(test)
            test_name_case = test.DisplayName;
            ax = axes('Parent', test.testFigure); 
            h_plot_line = plot(ax, 1:10, rand(1,10).* (1:10));
            title(ax, [test_name_case ' Original']); xlabel(ax, 'X-axis'); ylabel(ax, 'Y-axis');
            test.saveTestFigure('original', test_name_case);
            try
                bf_params = beautify_figure(test.testFigure); 
                title(ax, [test_name_case ' Beautified']); 
                test.saveTestFigure('beautified', test_name_case);
                
                ax_retrieved = findobj(test.testFigure, 'Type', 'axes');
                test.verifyNumElements(ax_retrieved, 1, 'Should be one axes.'); ax = ax_retrieved(1);
                
                subplot_scale_factor = 1.6; % For 1 subplot
                test.verifyEqual(ax.FontName, bf_params.font_name, sprintf('Default FontName was %s, expected %s.', ax.FontName, bf_params.font_name));
                test.verifyEqual(ax.XGrid, 'on', 'Default XGrid should be on.');
                test.verifyEqual(ax.YGrid, 'on', 'Default YGrid should be on.');
                expected_axes_fs = round(bf_params.base_font_size * bf_params.global_font_scale_factor * subplot_scale_factor);
                test.verifyEqual(round(ax.FontSize), expected_axes_fs, 'AbsTol', 1, 'Default FontSize incorrect.');
                expected_title_fs = round(bf_params.base_font_size * bf_params.title_scale * bf_params.global_font_scale_factor * subplot_scale_factor);
                test.verifyEqual(round(get(ax.Title, 'FontSize')), expected_title_fs, 'AbsTol', 1, 'Default Title FontSize incorrect.');
                if ~isempty(h_plot_line) && isvalid(h_plot_line)
                    expected_line_width = bf_params.plot_line_width * subplot_scale_factor;
                    test.verifyEqual(h_plot_line.LineWidth, expected_line_width, 'AbsTol', 0.05*subplot_scale_factor, 'Default plot_line_width incorrect.');
                end
            catch ME
                test.verifyTrue(false, sprintf('Error in beautify_figure (Default): %s', ME.message));
            end
        end
        
        % --- Test Case 2: Style Presets ---
        function testStylePresets(test, presetName)
            current_preset = presetName;
            test_name_case = sprintf('%s_preset_%s', test.DisplayName, current_preset);
            fprintf('  Testing preset: %s\n', current_preset);
            ax1 = subplot(1,2,1, 'Parent', test.testFigure); plot(ax1, 1:10, sin(1:10)); title(ax1, 'Sine');
            ax2 = subplot(1,2,2, 'Parent', test.testFigure); scatter(ax2, rand(20,1), rand(20,1)*5, 'filled'); title(ax2, 'Scatter');
            sgtitle(test.testFigure, [test_name_case ' Original']);
            test.saveTestFigure('original', test_name_case);
            try
                params_to_apply.style_preset = current_preset;
                bf_params = beautify_figure(test.testFigure, params_to_apply);
                sgtitle(test.testFigure, [test_name_case ' Beautified (' current_preset ')']);
                test.saveTestFigure('beautified', test_name_case);

                all_axes_found = findobj(test.testFigure, 'Type', 'axes');
                ax1_test = []; 
                if numel(all_axes_found) == 2
                    positions = arrayfun(@(x) get(x,'Position')(1), all_axes_found);
                    [~, sort_idx] = sort(positions); ax1_test = all_axes_found(sort_idx(1));
                else; test.fatalAssertFail('Expected two axes for preset tests.'); end
                
                subplot_scale_factor = 1.5; % For 2 subplots
                test.verifyEqual(ax1_test.FontName, bf_params.font_name, [current_preset ' preset FontName. Is ' ax1_test.FontName ', Exp ' bf_params.font_name]);
                expected_title_fs = round(bf_params.base_font_size*bf_params.title_scale*bf_params.global_font_scale_factor*subplot_scale_factor);
                test.verifyEqual(round(get(ax1_test.Title, 'FontSize')), expected_title_fs, 'AbsTol', 2, [current_preset ' preset Title FS.']);
                h_line1 = findobj(ax1_test, 'Type', 'line');
                if ~isempty(h_line1) && isvalid(h_line1)
                    test.verifyEqual(h_line1(1).LineWidth, bf_params.plot_line_width*subplot_scale_factor, 'AbsTol', 0.05*subplot_scale_factor, [current_preset ' preset LW.']);
                end
                test.verifyEqual(test.testFigure.Color, bf_params.fig_color, 'AbsTol', 0.01, [current_preset ' preset FigColor.']);

                switch current_preset 
                    case 'publication'
                        test.verifyEqual(ax1_test.XGrid, 'on', 'Pub XGrid'); test.verifyEqual(ax1_test.YGrid, 'on', 'Pub YGrid');
                        test.verifyEqual(ax1_test.XMinorGrid, 'off', 'Pub XMinorGrid'); 
                        test.verifyEqual(test.testFigure.Color, [1 1 1], 'AbsTol', 0.01, 'Pub fig color');
                    case 'presentation_dark'
                        test.verifyEqual(ax1_test.XColor, bf_params.axes_color, 'AbsTol', 0.01, 'PresDark XColor'); 
                        test.verifyEqual(get(ax1_test.Title, 'Color'), bf_params.text_color, 'AbsTol', 0.01, 'PresDark TitleColor');
                        test.verifyEqual(test.testFigure.Color, [0.10 0.10 0.12], 'AbsTol', 0.01, 'PresDark fig color');
                    case 'presentation_light'
                        test.verifyEqual(ax1_test.XColor, bf_params.axes_color, 'AbsTol', 0.01, 'PresLight XColor');
                        test.verifyEqual(test.testFigure.Color, [0.90 0.90 0.92], 'AbsTol', 0.01, 'PresLight fig color');
                    case 'minimalist'
                        test.verifyEqual(ax1_test.XGrid, 'off','Min XGrid'); test.verifyEqual(ax1_test.Box, 'off','Min Box');
                end
            catch ME
                test.verifyTrue(false, sprintf('Error preset %s: %s', current_preset, ME.message));
            end
        end

        % --- Test Case 3: Specific Parameter Customization ---
        function testSpecificParameterCustomization(test)
            test_name_case = test.DisplayName;
            ax = axes('Parent', test.testFigure); h_bar = bar(ax, rand(1,5)*10); title(ax, 'Original');  xlabel(ax, 'X');
            test.saveTestFigure('original', test_name_case);
            custom_params.theme='dark'; custom_params.font_name='Arial'; custom_params.plot_line_width=2.5; 
            custom_params.color_palette='viridis'; custom_params.grid_density='major_only'; custom_params.base_font_size=12;
            try
                bf_params = beautify_figure(test.testFigure, custom_params);
                title(ax, [test_name_case ' Beautified']); test.saveTestFigure('beautified', test_name_case);
                ax_retrieved = findobj(test.testFigure, 'Type', 'axes'); test.verifyNumElements(ax_retrieved,1); ax = ax_retrieved(1);
                subplot_scale_factor = 1.6;
                test.verifyEqual(ax.FontName, custom_params.font_name, 'Custom FontName');
                expected_axes_fs = round(custom_params.base_font_size * bf_params.global_font_scale_factor * subplot_scale_factor);
                test.verifyEqual(round(ax.FontSize), expected_axes_fs, 'AbsTol', 1, 'Custom FontSize');
                test.verifyEqual(get(ax.XLabel,'FontName'), custom_params.font_name, 'Custom XLabel FontName');
                test.verifyEqual(test.testFigure.Color, bf_params.fig_color, 'AbsTol', 0.01, 'Dark theme FigColor');
                test.verifyEqual(ax.XColor, bf_params.axes_color, 'AbsTol', 0.01, 'Dark theme XColor');
                test.verifyEqual(get(ax.Title, 'Color'), bf_params.text_color, 'AbsTol', 0.01, 'Dark theme TitleColor');
                test.verifyEqual(ax.XGrid, 'on','Custom XGrid'); test.verifyEqual(ax.XMinorGrid, 'off', 'Custom XMinorGrid');
                if ~isempty(h_bar) && isvalid(h_bar)
                    test.verifyNotEqual(h_bar.FaceColor, [0 0.4470 0.7410], 'AbsTol', 0.1, 'Bar FaceColor'); 
                    expected_bar_lw = custom_params.plot_line_width * bf_params.axis_to_plot_linewidth_ratio * subplot_scale_factor;
                    test.verifyEqual(h_bar.LineWidth, expected_bar_lw, 'AbsTol', 0.1*subplot_scale_factor, 'Bar LW');
                end
            catch ME
                test.verifyTrue(false, sprintf('Error custom params: %s', ME.message));
            end
        end

        % --- Test Case 4: Panel Labeling ---
        function testPanelLabeling(test)
            test_name_case = test.DisplayName;
            tcl = tiledlayout(test.testFigure, 2,2, 'Padding', 'compact', 'TileSpacing', 'compact'); 
            ax_plot1 = nexttile(tcl); title(ax_plot1,'P1'); nexttile(tcl); title('P2'); nexttile(tcl); title('P3'); nexttile(tcl); title('P4'); 
            title(tcl, 'Original Panels'); test.saveTestFigure('original', test_name_case);
            panel_params.panel_labeling.enabled=true; panel_params.panel_labeling.style='A'; 
            panel_params.panel_labeling.font_scale_factor=1.1; panel_params.panel_labeling.font_weight='bold';
            panel_params.base_font_size=10; 
            try
                bf_params_panel = beautify_figure(test.testFigure, panel_params);
                title(tcl, [test_name_case ' Beautified']); test.saveTestFigure('beautified', test_name_case);
                panel_labels = findall(test.testFigure, 'Type', 'text', 'Tag', 'BeautifyFig_PanelLabel');
                test.verifyEqual(numel(panel_labels), 4, 'Num panel labels');
                expected_L_base = {'A', 'B', 'C', 'D'}; 
                found_L_text = sort(arrayfun(@(x) x.String, panel_labels, 'UniformOutput', false));
                is_match = all(arrayfun(@(i) startsWith(found_L_text{i}, expected_L_base{i}), 1:numel(expected_L_base)));
                test.verifyTrue(is_match, 'Panel label text content.');
                if ~isempty(panel_labels)
                    test.verifyEqual(panel_labels(1).FontWeight, 'bold', 'Panel label FontWeight.');
                    subplot_sf = 1.3; % 4 subplots
                    title_fs_ref = round(bf_params_panel.base_font_size*bf_params_panel.title_scale*bf_params_panel.global_font_scale_factor*subplot_sf);
                    expected_pl_fs = round(title_fs_ref * panel_params.panel_labeling.font_scale_factor);
                    test.verifyEqual(round(panel_labels(1).FontSize), expected_pl_fs, 'AbsTol', 2, 'Panel label FontSize.');
                end
            catch ME
                test.verifyTrue(false, sprintf('Error panel labeling: %s', ME.message));
            end
        end

        % --- Test Case 5: Statistics Overlay ---
        function testStatisticsOverlay(test)
            test_name_case = test.DisplayName;
            ax = axes('Parent', test.testFigure); plot(ax, 1:50, 5*sin((1:50)/5)+randn(1,50)*2+10, 'Tag','DataLine');
            title(ax, 'Original Stats'); xlabel(ax,'X');test.saveTestFigure('original', test_name_case);
            stats_params.stats_overlay.enabled=true; stats_params.stats_overlay.target_plot_handle_tag='DataLine';
            stats_params.stats_overlay.statistics={'mean','std','N','min','max'}; stats_params.stats_overlay.background_color=[0.95 0.95 0.95];
            stats_params.stats_overlay.font_scale_factor=0.85; stats_params.base_font_size=10; stats_params.stats_overlay.edge_color = 'black';
            try
                bf_params_stats = beautify_figure(test.testFigure, stats_params);
                title(ax, [test_name_case ' Beautified']); test.saveTestFigure('beautified', test_name_case);
                stats_obj = findobj(ax, 'Tag', 'BeautifyFig_StatsOverlay');
                test.verifyNotEmpty(stats_obj, 'Stats overlay obj not found.');
                if ~isempty(stats_obj)
                    test.verifyTrue(contains(stats_obj.String, 'Mean:'),'Stats Mean'); test.verifyTrue(contains(stats_obj.String, 'N:'),'Stats N');
                    test.verifyEqual(stats_obj.BackgroundColor, stats_params.stats_overlay.background_color, 'AbsTol',0.01,'Stats BG Color');
                    test.verifyEqual(stats_obj.EdgeColor, stats_params.stats_overlay.edge_color, 'AbsTol',0.01,'Stats Edge Color');
                    subplot_sf=1.6; label_fs_ref=round(bf_params_stats.base_font_size*bf_params_stats.label_scale*bf_params_stats.global_font_scale_factor*subplot_sf);
                    expected_stats_fs = round(label_fs_ref * stats_params.stats_overlay.font_scale_factor);
                    test.verifyEqual(round(stats_obj.FontSize), expected_stats_fs, 'AbsTol', 1, 'Stats overlay FontSize.');
                end
            catch ME
                test.verifyTrue(false, sprintf('Error stats overlay: %s', ME.message));
            end
        end

        % --- Test Case 6: Export Functionality ---
        function testExportFunctionality(test)
            safe_name = regexprep(test.DisplayName, '[^\w_.-]', '_'); 
            export_base = fullfile(test.outputDir, sprintf('exported_%s', safe_name));
            ax=axes('Parent',test.testFigure); [X,Y,Z]=peaks(25); surf(ax,X,Y,Z); title('Original Export');
            test.saveTestFigure('original', [safe_name '_setup_export']);
            params_png.export_settings = struct('enabled',true,'filename',export_base,'format','png','resolution',150,'open_exported_file',false);
            params_pdf.export_settings = struct('enabled',true,'filename',export_base,'format','pdf','resolution',150,'open_exported_file',false);
            try
                beautify_figure(test.testFigure, params_png); 
                expected_png = [export_base '.png']; test.verifyTrue(exist(expected_png,'file')==2, 'PNG not exported.');
                if exist(expected_png,'file')==2; delete(expected_png); fprintf('Deleted %s\n',expected_png); end
                
                fig_pdf = figure('Visible','off'); ax_pdf=axes('Parent',fig_pdf); surf(ax_pdf,X,Y,Z); title('PDF Export');
                beautify_figure(fig_pdf, params_pdf); 
                if ishandle(fig_pdf); close(fig_pdf); end 
                expected_pdf = [export_base '.pdf']; test.verifyTrue(exist(expected_pdf,'file')==2, 'PDF not exported.');
                if exist(expected_pdf,'file')==2; delete(expected_pdf); fprintf('Deleted %s\n',expected_pdf); end
            catch ME
                if ishandle(fig_pdf) && fig_pdf ~= 0 && isvalid(fig_pdf); close(fig_pdf); end 
                test.verifyTrue(false, sprintf('Error export: %s', ME.message));
            end
        end

        % --- Test Case 7: Applying to Specific Axes ---
        function testSpecificAxes(test)
            ax1=subplot(1,2,1,'Parent',test.testFigure); plot(ax1,1:10); title(ax1,'Ax1 Orig');  xlabel(ax1,'X1');
            ax2=subplot(1,2,2,'Parent',test.testFigure); plot(ax2,1:10); title(ax2,'Ax2 Orig');  xlabel(ax2,'X2');
            original_ax2_title_fs = get(get(ax2, 'Title'), 'FontSize'); original_ax2_fontname = get(ax2, 'FontName');
            original_ax2_XColor = ax2.XColor;
            test.saveTestFigure('original', test.DisplayName);
            params_ax1.base_font_size=16; params_ax1.font_name='Courier New'; params_ax1.theme='dark'; params_ax1.title_scale=1.1;
            params_ax1.global_font_scale_factor = 1.0; 
            try
                bf_params_ax1 = beautify_figure(ax1, params_ax1);
                test.saveTestFigure('beautified', test.DisplayName);
                subplot_sf_ax1 = 1.6; 
                expected_ax1_title_fs = round(bf_params_ax1.base_font_size*bf_params_ax1.title_scale*bf_params_ax1.global_font_scale_factor*subplot_sf_ax1);
                test.verifyEqual(round(get(get(ax1,'Title'),'FontSize')), expected_ax1_title_fs, 'AbsTol',2, 'Ax1 Title FS');
                test.verifyEqual(ax1.FontName, params_ax1.font_name, 'Ax1 FontName');
                test.verifyEqual(ax1.XColor, bf_params_ax1.axes_color, 'AbsTol',0.01, 'Ax1 XColor');
                test.verifyEqual(get(get(ax2,'Title'),'FontSize'), original_ax2_title_fs, 'AbsTol',0.1, 'Ax2 Title FS changed');
                test.verifyEqual(ax2.FontName, original_ax2_fontname, 'Ax2 FontName changed');
                test.verifyEqual(ax2.XColor, original_ax2_XColor, 'AbsTol',0.01, 'Ax2 XColor changed');
            catch ME
                test.verifyTrue(false, sprintf('Error specific axes: %s', ME.message));
            end
        end
        
        % --- Test Case 8.1: Log Level 0 (Silent) ---
        function testLogLevelSilent(test)
            ax=axes('Parent',test.testFigure); plot(ax,1:5); title('Silent Orig'); test.saveTestFigure('original',test.DisplayName);
            try
                output_silent = evalc('beautify_figure(test.testFigure, struct(''log_level'',0));');
                test.saveTestFigure('beautified',test.DisplayName);
                test.verifyLessThan(length(output_silent), 50, 'Log 0 output too verbose.');
            catch ME; test.verifyTrue(false,['Err Log 0: ' ME.message]); end
        end

        % --- Test Case 8.2: Log Level 2 (Detailed) ---
        function testLogLevelDetailed(test)
            ax=axes('Parent',test.testFigure); plot(ax,1:5); title('Detailed Orig'); test.saveTestFigure('original',test.DisplayName);
            try
                output_detailed = evalc('beautify_figure(test.testFigure, struct(''log_level'',2));');
                test.saveTestFigure('beautified',test.DisplayName);
                test.verifyGreaterThan(length(output_detailed),100, 'Log 2 output too short.');
                test.verifyTrue(contains(output_detailed,'Processing axes') || contains(output_detailed,'BeautifyFigure'), 'Log 2 missing verbose msg.');
            catch ME; test.verifyTrue(false,['Err Log 2: ' ME.message]); end
        end
        
        % --- Test Case 9.1: Error Bar Plot ---
        function testErrorBarPlot(test)
            test_name_case = sprintf('%s_ErrorBar', test.DisplayName);
            ax=axes('Parent',test.testFigure); h_eb=errorbar(ax,1:5,rand(1,5)*2+2,rand(1,5)*0.5+0.2,'-s','MarkerSize',8,'MarkerEdgeColor','r','MarkerFaceColor','r','CapSize',8);
            original_eb_color = h_eb.Color; original_eb_lw = h_eb.LineWidth;
            title(ax, 'ErrorBar Orig'); test.saveTestFigure('original', test_name_case);
            try
                bf_params_eb = beautify_figure(test.testFigure);
                title(ax, [test_name_case ' Beautified']); test.saveTestFigure('beautified', test_name_case);
                subplot_sf=1.6; expected_lw=bf_params_eb.plot_line_width*subplot_sf; test.verifyEqual(h_eb.LineWidth,expected_lw,'AbsTol',0.05*subplot_sf,'Errorbar LW');
                expected_ms=bf_params_eb.marker_size*subplot_sf; test.verifyEqual(h_eb.MarkerSize,expected_ms,'AbsTol',0.1*subplot_sf,'Errorbar MS');
                expected_cs=expected_ms*bf_params_eb.errorbar_cap_size_scale; test.verifyEqual(h_eb.CapSize,expected_cs,'AbsTol',0.1*subplot_sf,'Errorbar CapSize');
                test.verifyNotEqual(h_eb.Color,original_eb_color,'AbsTol',0.01,'Errorbar Color');
                test.verifyNotEqual(h_eb.LineWidth, original_eb_lw, 'AbsTol', 0.001, 'Errorbar LW should change.');
            catch ME; test.verifyTrue(false,['Err ErrorBar: ' ME.message]); end
        end

        % --- Test Case 9.2: Histogram ---
        function testHistogramPlot(test)
            test_name_case = sprintf('%s_Histogram', test.DisplayName);
            ax=axes('Parent',test.testFigure); h_hist=histogram(ax,randn(1000,1)*2+5,20,'FaceColor','m','EdgeColor','b');
            original_face_color = h_hist.FaceColor; 
            title(ax,'Hist Orig'); test.saveTestFigure('original',test_name_case);
            try
                bf_params_hist = beautify_figure(test.testFigure);
                title(ax,[test_name_case ' Beautified']); test.saveTestFigure('beautified',test_name_case);
                subplot_sf=1.6; expected_edge_lw=bf_params_hist.plot_line_width*bf_params_hist.axis_to_plot_linewidth_ratio*subplot_sf;
                test.verifyEqual(h_hist.LineWidth,expected_edge_lw,'AbsTol',0.05*subplot_sf, 'Hist Edge LW');
                test.verifyNotEqual(h_hist.FaceColor,original_face_color,'AbsTol',0.01, 'Hist FaceColor');
                test.verifyEqual(h_hist.EdgeColor,h_hist.FaceColor,'AbsTol',0.01, 'Hist EdgeColor should match FaceColor');
            catch ME; test.verifyTrue(false,['Err Hist: ' ME.message]); end
        end
        
        % --- Test Case 10.1: Cycle Styles & Custom Palette ---
        function testCycleStylesAndCustomPalette(test)
            ax=axes('Parent',test.testFigure); hold(ax,'on');
            plots=arrayfun(@(i)plot(ax,1:10,rand(1,10)+i*2,'DisplayName',['S' num2str(i)]),1:4); hold(ax,'off'); title(ax,'Cycle Orig'); legend(ax,'show');
            test.saveTestFigure('original',test.DisplayName);
            params.cycle_marker_styles=true; params.cycle_line_styles=true; params.custom_color_palette=[1 0 0;0 1 0;0 0 1;1 0 1]; %R,G,B,M
            params.color_palette='custom'; params.marker_cycle_threshold=2; params.line_style_cycle_threshold=1; 
            params.marker_styles={'o','s','d','^'}; params.line_style_order={'-','--',':','-.'};
            try
                bf_params = beautify_figure(test.testFigure, params);
                title(ax,[test.DisplayName ' Beaut']); test.saveTestFigure('beautified',test.DisplayName);
                subplot_sf=1.6;
                for i=1:numel(plots)
                    p=plots(i); color_idx=mod(i-1,size(params.custom_color_palette,1))+1; test.verifyEqual(p.Color,params.custom_color_palette(color_idx,:),'AbsTol',0.01,['Plot ' num2str(i) ' color']);
                    if params.cycle_marker_styles
                        if i >= params.marker_cycle_threshold 
                            marker_idx_eff = mod(i - params.marker_cycle_threshold, numel(params.marker_styles)) + 1;
                            test.verifyEqual(p.Marker,params.marker_styles{marker_idx_eff},['Plot ' num2str(i) ' marker']); 
                        else
                            test.verifyEqual(p.Marker,'none',['Plot ' num2str(i) ' marker none']); 
                        end
                    end
                    if params.cycle_line_styles
                        if i >= params.line_style_cycle_threshold
                             linestyle_idx_eff = mod(i - params.line_style_cycle_threshold, numel(params.line_style_order)) + 1;
                            test.verifyEqual(p.LineStyle,params.line_style_order{linestyle_idx_eff},['Plot ' num2str(i) ' linestyle']);
                        else
                             test.verifyEqual(p.LineStyle,params.line_style_order{1},['Plot ' num2str(i) ' linestyle pre-cycle']); 
                        end
                    end
                    test.verifyEqual(p.LineWidth,bf_params.plot_line_width*subplot_sf,'AbsTol',0.05*subplot_sf,['Plot ' num2str(i) ' LW']);
                end
            catch ME; test.verifyTrue(false,['Err Cycle: ' ME.message]); end
        end

        % --- Test Case 10.2: Global Font Scale Factor ---
        function testGlobalFontScaleFactor(test)
            subplot_sf=1.6; params1=struct('global_font_scale_factor',1.0,'base_font_size',10,'title_scale',1.2,'label_scale',1.0);
            ax1=axes('Parent',test.testFigure); plot(ax1,1:10); title(ax1,'Scale 1.0 Orig'); xlabel(ax1,'X'); test.saveTestFigure('original',[test.DisplayName '_Scale1']);
            try
                bf_params1=beautify_figure(test.testFigure,params1); 
                title(ax1,'Scale 1.0 Beaut'); test.saveTestFigure('beautified',[test.DisplayName '_Scale1']);
                exp_title_fs1=round(bf_params1.base_font_size*bf_params1.title_scale*bf_params1.global_font_scale_factor*subplot_sf);
                test.verifyEqual(round(get(ax1.Title,'FontSize')),exp_title_fs1,'AbsTol',1,'Title FS Scale 1.0');
                exp_label_fs1=round(bf_params1.base_font_size*bf_params1.label_scale*bf_params1.global_font_scale_factor*subplot_sf);
                test.verifyEqual(round(get(ax1.XLabel,'FontSize')),exp_label_fs1,'AbsTol',1,'XLabel FS Scale 1.0');
            catch ME; test.verifyTrue(false,['Err Scale1: ' ME.message]); end
            
            if ishandle(test.testFigure); close(test.testFigure); end; test.testFigure=figure('Visible','off'); 
            params2=struct('global_font_scale_factor',1.5,'base_font_size',10,'title_scale',1.2,'label_scale',1.0);
            ax2=axes('Parent',test.testFigure); plot(ax2,1:10); title(ax2,'Scale 1.5 Orig'); xlabel(ax2,'X'); test.saveTestFigure('original',[test.DisplayName '_Scale1.5']);
            try
                bf_params2=beautify_figure(test.testFigure,params2);
                title(ax2,'Scale 1.5 Beaut'); test.saveTestFigure('beautified',[test.DisplayName '_Scale1.5']);
                exp_title_fs2=round(bf_params2.base_font_size*bf_params2.title_scale*bf_params2.global_font_scale_factor*subplot_sf);
                test.verifyEqual(round(get(ax2.Title,'FontSize')),exp_title_fs2,'AbsTol',2,'Title FS Scale 1.5'); 
                exp_label_fs2=round(bf_params2.base_font_size*bf_params2.label_scale*bf_params2.global_font_scale_factor*subplot_sf);
                test.verifyEqual(round(get(ax2.XLabel,'FontSize')),exp_label_fs2,'AbsTol',2,'XLabel FS Scale 1.5');
            catch ME; test.verifyTrue(false,['Err Scale1.5: ' ME.message]); end
        end
        
        % --- Test Case 11.1: axis_box_style = 'off' ---
        function testAxesBoxStyleOff(test)
            ax=axes('Parent',test.testFigure); plot(ax,1:10); title(ax,'Box Orig'); test.saveTestFigure('original',test.DisplayName);
            try; beautify_figure(test.testFigure,struct('axis_box_style','off')); test.saveTestFigure('beautified',test.DisplayName); test.verifyEqual(ax.Box,'off','Axes Box'); 
            catch ME; test.verifyTrue(false,['Err BoxOff: ' ME.message]); end
        end

        % --- Test Case 11.2: axes_layer = 'bottom' ---
        function testAxesLayerBottom(test)
            ax=axes('Parent',test.testFigure); plot(ax,1:10); grid(ax,'on'); title(ax,'Layer Orig'); test.saveTestFigure('original',test.DisplayName);
            try; beautify_figure(test.testFigure,struct('axes_layer','bottom','grid_density','normal')); test.saveTestFigure('beautified',test.DisplayName); test.verifyEqual(ax.Layer,'bottom','Axes Layer');
            catch ME; test.verifyTrue(false,['Err LayerBottom: ' ME.message]); end
        end

        % --- Test Case 12.1: Legend Location & Interactive ---
        function testLegendLocationAndInteractive(test)
            ax=axes('Parent',test.testFigure); plot(ax,1:10,'DisplayName','A'); plot(ax,randn(1,10)+1,'DisplayName','B'); legend(ax,'show'); title(ax,'Legend Orig'); test.saveTestFigure('original',test.DisplayName);
            params=struct('legend_location','northeastoutside','interactive_legend',true);
            try
                beautify_figure(test.testFigure,params); test.saveTestFigure('beautified',test.DisplayName);
                lgd=findobj(test.testFigure,'Type','Legend'); test.verifyNotEmpty(lgd,'Legend obj');
                if ~isempty(lgd); test.verifyEqual(lgd(1).Location,params.legend_location,'Legend Loc'); if verLessThan('matlab','9.7')==0; test.verifyNotEmpty(lgd(1).ItemHitFcn,'Legend Interactive'); end; end
            catch ME; test.verifyTrue(false,['Err Legend Loc: ' ME.message]); end
        end

        % --- Test Case 12.2: smart_legend_display = false ---
        function testSmartLegendDisplayFalse(test)
            ax=axes('Parent',test.testFigure); plot(ax,1:10,'DisplayName','Single'); title(ax,'Smart Legend Orig'); test.saveTestFigure('original',test.DisplayName);
            params=struct('smart_legend_display',false,'legend_force_single_entry',true);
            try
                beautify_figure(test.testFigure,params); test.saveTestFigure('beautified',test.DisplayName);
                lgd=findobj(test.testFigure,'Type','Legend'); test.verifyNotEmpty(lgd,'Legend obj (smart_legend_display=false)');
                if ~isempty(lgd); test.verifyEqual(numel(lgd(1).String),1,'Legend num entries'); end
            catch ME; test.verifyTrue(false,['Err Smart Legend: ' ME.message]); end
        end
        
        % --- Test Case 13: Plot with Colorbar ---
        function testPlotWithColorbar(test)
            ax=axes('Parent',test.testFigure); [~,~,Z]=peaks(25); contourf(ax,Z,10); h_cb=colorbar(ax); ylabel(h_cb,'Units');
            title(ax, 'Colorbar Orig'); test.saveTestFigure('original',test.DisplayName);
            try
                bf_params_cb = beautify_figure(test.testFigure);
                title(ax,[test.DisplayName ' Beaut']); test.saveTestFigure('beautified',test.DisplayName);
                test.verifyNotEmpty(h_cb, 'Colorbar handle');
                if isvalid(h_cb)
                    subplot_sf=1.6; exp_cb_fs=round(bf_params_cb.base_font_size*bf_params_cb.colorbar_font_scale*bf_params_cb.global_font_scale_factor*subplot_sf);
                    test.verifyEqual(round(h_cb.FontSize),exp_cb_fs,'AbsTol',1, 'Colorbar FS');
                    test.verifyEqual(h_cb.TickDirection,'out','Colorbar TickDir'); test.verifyEqual(h_cb.Box,bf_params_cb.colorbar_box_style,'Colorbar Box');
                    test.verifyEqual(h_cb.LineWidth,bf_params_cb.plot_line_width*bf_params_cb.axis_to_plot_linewidth_ratio*subplot_sf,'AbsTol',0.05*subplot_sf,'Colorbar LW');
                    cb_label=get(h_cb,'Label'); if ishandle(cb_label)&&~isempty(cb_label.String)
                        exp_cb_label_fs=round(bf_params_cb.base_font_size*bf_params_cb.label_scale*bf_params_cb.global_font_scale_factor*subplot_sf);
                        test.verifyEqual(round(get(cb_label,'FontSize')),exp_cb_label_fs,'AbsTol',1,'Colorbar Label FS');
                        test.verifyEqual(get(cb_label,'FontName'),bf_params_cb.font_name,'Colorbar Label FontName');
                    end
                end
            catch ME; test.verifyTrue(false,['Err Colorbar: ' ME.message]); end
        end

        % --- Test Case 14: Polar Plot ---
        function testPolarPlot(test)
            pax=polaraxes('Parent',test.testFigure); h_line=polarplot(pax,0:0.01:2*pi,abs(sin(2*(0:0.01:2*pi)).*cos(2*(0:0.01:2*pi))),'r','LW',1.5);
            title(pax,'Polar Orig'); test.saveTestFigure('original',test.DisplayName);
            try
                bf_params_polar = beautify_figure(test.testFigure);
                title(pax,[test.DisplayName ' Beaut']); test.saveTestFigure('beautified',test.DisplayName);
                subplot_sf=1.6; test.verifyEqual(pax.FontName,bf_params_polar.font_name, 'Polar FontName');
                test.verifyEqual(pax.RGridColor,bf_params_polar.grid_color,'AbsTol',0.01,'Polar RGridColor');
                test.verifyEqual(pax.ThetaGridColor,bf_params_polar.grid_color,'AbsTol',0.01,'Polar ThetaGridColor');
                exp_polar_fs=round(bf_params_polar.base_font_size*bf_params_polar.global_font_scale_factor*subplot_sf);
                test.verifyEqual(round(pax.FontSize),exp_polar_fs,'AbsTol',1,'Polar FS');
                exp_polar_title_fs=round(bf_params_polar.base_font_size*bf_params_polar.title_scale*bf_params_polar.global_font_scale_factor*subplot_sf);
                test.verifyEqual(round(get(get(pax,'Title'),'FontSize')),exp_polar_title_fs,'AbsTol',1,'Polar Title FS');
                if ~isempty(h_line) && isvalid(h_line); exp_polar_lw=bf_params_polar.plot_line_width*subplot_sf; test.verifyEqual(h_line(1).LineWidth,exp_polar_lw,'AbsTol',0.05*subplot_sf,'Polar LW'); test.verifyNotEqual(h_line(1).Color,[1 0 0],'AbsTol',0.01,'Polar Color'); end
            catch ME; test.verifyTrue(false,['Err Polar: ' ME.message]); end
        end

        % --- Test Case 15: LaTeX in Labels ---
        function testLaTeXInLabels(test)
            ax=axes('Parent',test.testFigure); plot(ax,0:0.1:2*pi,sin(0:0.1:2*pi));
            title_str_orig='$y=\sin(x)$';xl_str_orig='$\theta$';yl_str_orig='$\alpha^2$';
            title(ax,title_str_orig,'Interpreter','latex');xlabel(ax,xl_str_orig,'Interpreter','latex');ylabel(ax,yl_str_orig,'Interpreter','latex');
            test.saveTestFigure('original',test.DisplayName);
            try
                bf_params_latex = beautify_figure(test.testFigure);
                title_h=get(ax,'Title');xl_h=get(ax,'XLabel');yl_h=get(ax,'YLabel');
                test.verifyEqual(get(title_h,'Interpreter'),'latex','Title Interp'); test.verifyEqual(get(xl_h,'Interpreter'),'latex','XLabel Interp'); test.verifyEqual(get(yl_h,'Interpreter'),'latex','YLabel Interp');
                test.verifyEqual(get(xl_h,'FontName'),bf_params_latex.font_name,'XLabel FontName');
                test.verifyTrue(contains(get(title_h,'String'),'\sin'),'Title LaTeX content'); 
                test.verifyTrue(contains(get(xl_h,'String'),'\theta'),'XLabel LaTeX content'); 
                test.verifyTrue(contains(get(yl_h,'String'),'\alpha'),'YLabel LaTeX content');
                title(ax,[test.DisplayName ' Beaut']); test.saveTestFigure('beautified',test.DisplayName); 
            catch ME; test.verifyTrue(false,['Err LaTeX: ' ME.message]); end
        end

        % --- Test Case 16: Object Exclusion ---
        function testObjectExclusion(test)
            ax=axes('Parent',test.testFigure);hold(ax,'on');
            line1=plot(ax,1:10,rand(1,10)+2,'LW',1,'Color','b','Marker','o');
            line2=plot(ax,1:10,rand(1,10),'LW',3,'Color','r','Marker','x','Tag','ExcludeThisLine');
            hold(ax,'off');title(ax,'Exclusion Orig');legend(ax,{'L1','L2'});test.saveTestFigure('original',test.DisplayName);
            orig_l2_lw=line2.LineWidth;orig_l2_color=line2.Color;orig_l2_marker=line2.Marker;orig_l1_color=line1.Color;
            params.exclude_object_tags={'ExcludeThisLine'};params.plot_line_width=0.5;params.color_palette='parula';
            try
                bf_params_exc = beautify_figure(test.testFigure,params);
                title(ax,[test.DisplayName ' Beaut']);test.saveTestFigure('beautified',test.DisplayName);
                subplot_sf=1.6;
                test.verifyEqual(line2.LineWidth,orig_l2_lw,'AbsTol',1e-6,'Excluded LW');test.verifyEqual(line2.Color,orig_l2_color,'AbsTol',1e-6,'Excluded Color');test.verifyEqual(line2.Marker,orig_l2_marker,'Excluded Marker');
                exp_l1_lw=params.plot_line_width*subplot_sf;test.verifyEqual(line1.LineWidth,exp_l1_lw,'AbsTol',0.05*subplot_sf,'Line1 LW');
                test.verifyNotEqual(line1.Color,orig_l1_color,'AbsTol',0.01,'Line1 Color changed');
                if ~isempty(bf_params_exc.color_order) && size(bf_params_exc.color_order,1)>0 && ~isequal(bf_params_exc.color_order(1,:),orig_l2_color)
                     test.verifyNotEqual(line1.Color,orig_l2_color,'AbsTol',0.01,'Line1 Color vs Excluded');
                end
            catch ME; test.verifyTrue(false,['Err Exclude: ' ME.message]);end
        end

        % --- Test Case 17: New Color Palettes (Turbo & Cividis) ---
        function testNewColorPalettes(test)
            turbo_map_expected_first4 = [
                0.18995,0.07176,0.23217; 0.29325,0.31756,0.97420; 
                0.15136,0.56099,0.93081; 0.06059,0.75147,0.71000
            ];
            cividis_map_expected_first4 = [
                0.00000,0.12911,0.27800; 0.24196,0.21900,0.46080; 
                0.41211,0.30930,0.55020; 0.56453,0.40778,0.57890
            ];
            
            palettes_to_test = {'turbo', 'cividis'};
            expected_colors_map = containers.Map();
            expected_colors_map('turbo') = turbo_map_expected_first4;
            expected_colors_map('cividis') = cividis_map_expected_first4;

            for i = 1:length(palettes_to_test)
                current_palette_name = palettes_to_test{i};
                current_expected_colors = expected_colors_map(current_palette_name);
                
                base_test_name = regexprep(test.DisplayName, ' \(.*?\)', ''); 
                test_name_case = sprintf('%s_%s_palette', base_test_name, current_palette_name);
                
                if ishandle(test.testFigure); close(test.testFigure); end
                test.testFigure = figure('Visible', 'off');
                ax = axes('Parent', test.testFigure);

                hold(ax, 'on');
                num_lines = 4; 
                plots_array = gobjects(1, num_lines);
                original_colors = cell(1, num_lines);
                for line_idx = 1:num_lines
                    plots_array(line_idx) = plot(ax, 1:10, rand(1,10)+line_idx*2, 'DisplayName', ['Series ' char('W'+line_idx)]);
                    original_colors{line_idx} = plots_array(line_idx).Color;
                end
                hold(ax, 'off');
                title(ax, [test_name_case ' Original']);
                legend(ax, 'show');

                test.saveTestFigure('original', test_name_case);

                palette_params.color_palette = current_palette_name;
                palette_params.theme = 'light'; 
                
                fprintf('  Testing palette: %s\n', current_palette_name);

                try
                    bf_params = beautify_figure(test.testFigure, palette_params);
                    title(ax, [test_name_case ' Beautified']);
                    test.saveTestFigure('beautified', test_name_case);

                    for line_idx = 1:num_lines
                        test.verifyNotEqual(plots_array(line_idx).Color, original_colors{line_idx}, 'AbsTol', 0.02, ...
                            sprintf('%s Palette: Line %d color should change.', current_palette_name, line_idx));
                        test.verifyEqual(plots_array(line_idx).Color, current_expected_colors(line_idx,:), 'AbsTol', 0.02, ...
                            sprintf('%s Palette: Line %d color incorrect.', current_palette_name, line_idx));
                    end
                    
                    lgd = findobj(test.testFigure, 'Type', 'Legend');
                    if ~isempty(lgd) && isvalid(lgd)
                        test.verifyEqual(lgd(1).TextColor, bf_params.text_color, 'AbsTol', 0.02, ...
                            sprintf('%s Palette: Legend text color incorrect.', current_palette_name));
                    else
                        test.fail(sprintf('%s Palette: Legend not found.', current_palette_name));
                    end

                catch ME
                    fprintf('  ERROR during %s (Palette: %s): %s\n', test_name_case, current_palette_name, ME.message);
                    test.verifyTrue(false, sprintf('Error testing palette %s: %s', current_palette_name, ME.message));
                end
            end
        end
        
        % --- Test Case 18: 3D View Presets ---
        function test3DViewPresets(test, viewPreset)
            test_name_case = sprintf('%s_view_%s', test.DisplayName, viewPreset);
            
            % Ensure a clean figure for each parameterized test instance
            if ishandle(test.testFigure); close(test.testFigure); end
            test.testFigure = figure('Visible', 'off');
            ax = axes('Parent', test.testFigure);
            
            surf(ax, peaks(20)); % Create a 3D surface plot
            title(ax, [test_name_case ' Original']);
            test.saveTestFigure('original', test_name_case);

            params_view.view_preset_3d = viewPreset;
            fprintf('  Testing 3D View Preset: %s\n', viewPreset);

            try
                beautify_figure(test.testFigure, params_view);
                title(ax, [test_name_case ' Beautified (' viewPreset ')']);
                test.saveTestFigure('beautified', test_name_case);

                current_view_angles = get(ax, 'View');
                expected_view = [];

                switch viewPreset
                    case 'iso'
                        % Get MATLAB's default isometric view angles
                        temp_fig_iso = figure('Visible','off'); temp_ax_iso = axes('Parent',temp_fig_iso);
                        view(temp_ax_iso, 3);
                        expected_view = get(temp_ax_iso, 'View');
                        close(temp_fig_iso);
                    case 'top'
                        expected_view = [0, 90];
                    case 'front'
                        expected_view = [0, 0];
                    case 'side_left'
                        expected_view = [-90, 0];
                    case 'side_right'
                        expected_view = [90, 0];
                end
                
                test.verifyEqual(current_view_angles, expected_view, 'AbsTol', 1, ...
                    sprintf('View preset "%s" set incorrect view angles. Expected [%.1f, %.1f], Got [%.1f, %.1f].', ...
                    viewPreset, expected_view(1), expected_view(2), current_view_angles(1), current_view_angles(2)));

            catch ME
                fprintf('  ERROR during %s (3D View Preset: %s): %s\n', test.DisplayName, viewPreset, ME.message);
                test.verifyTrue(false, sprintf('Error testing 3D view preset %s: %s', viewPreset, ME.message));
            end
        end

    end % methods (Test)
end % classdef

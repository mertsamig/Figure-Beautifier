# Known Bugs and Areas for Improvement in beautify_figure.m

This document lists potential bugs, inconsistencies, and areas for improvement identified in the `beautify_figure.m` script.

## Potential Bugs & Inconsistencies

1.  **Object Exclusion Feature (`exclude_object_tags`):**
    *   **Issue:** `old_test_beautify_figure.m` (Test Case 14) tests a feature `params.exclude_object_tags` which allows specific graphics objects to be excluded from beautification. The current `beautify_figure.m` code does not seem to contain the implementation for this feature.
    *   **Location in `beautify_figure.m` (Suspected Missing Logic):** Primarily in `beautify_single_axes`, before iterating through `all_children_filtered`.
    *   **Impact:** If this feature is still intended to be supported, it's currently non-functional.
    *   **Evidence:** Test Case 14 in `old_test_beautify_figure.m`.

2.  **`stats_overlay` Text Interpreter Hardcoding:**
    *   **Issue:** The `apply_stats_overlay` function explicitly sets `'Interpreter', 'tex'`. This is inconsistent with the general approach of allowing MATLAB's default interpreter behavior (established by recent refactoring of `process_text_prop`).
    *   **Location in `beautify_figure.m`:** `apply_stats_overlay` function, around line 1538.
    *   **Impact:** The stats overlay text will always be processed by the 'tex' interpreter, reducing flexibility and potentially misinterpreting stat labels if they contain TeX special characters.
    *   **Evidence:** Code inspection of `apply_stats_overlay`.

3.  **Font Availability and Substitution:**
    *   **Issue:** The script uses specific font names (e.g., 'Swiss 721 BT', 'Calibri', 'Helvetica Neue') which may not be installed on all systems. MATLAB substitutes them, leading to inconsistent visuals, and the user is not warned.
    *   **Location in `beautify_figure.m`:** `default_params.font_name`, preset definitions, and font application points.
    *   **Impact:** Figures may not appear as designed across different systems.
    *   **Evidence:** Common MATLAB behavior; 'minimalist' preset has a `try-catch` for 'Helvetica Neue'.

4.  **Legend Interactivity (`ItemHitFcn`) Robustness with Multiple Calls:**
    *   **Issue:** If `beautify_figure` is called multiple times on a figure with an interactive legend and changing plot elements, persisted `appdata` from a previous legend instance might not match the new legend's `PlotChildren`, potentially leading to errors or incorrect behavior in `toggle_plot_visibility_adv`.
    *   **Location in `beautify_figure.m`:** `beautify_legend` (ItemHitFcn setup) and `toggle_plot_visibility_adv`.
    *   **Impact:** Interactive legend may behave erratically or error out if `beautify_figure` is applied repeatedly to a dynamic figure.
    *   **Evidence:** Logical analysis of appdata initialization and legend recreation.

## Areas for Improvement & Minor Issues

5.  **Default Beautification Parameter Alignment (Old Test):**
    *   **Issue:** `old_test_beautify_figure.m` (Test Case 1) has detailed programmatic checks for default properties. Failures against these checks would indicate divergence from a previously established default appearance.
    *   **Location in `beautify_figure.m`:** `default_params` structure, and styling logic in `beautify_single_axes`.
    *   **Impact:** Potential regression from a previously expected default appearance.
    *   **Evidence:** Test Case 1 in `old_test_beautify_figure.m`.

6.  **`sgtitle` Font Scaling:**
    *   **Issue:** The font size for `sgtitle` (in `beautify_sgtitle_if_exists`) is scaled using `params.max_scale_factor` rather than the current figure's actual `scale_factor`.
    *   **Location in `beautify_figure.m`:** `beautify_sgtitle_if_exists` function.
    *   **Impact:** `sgtitle` font size might not always be optimally harmonized with other text elements for varying subplot densities.
    *   **Evidence:** Code inspection.

7.  **Errorbar Cap Size Scaling Logic:**
    *   **Issue:** The base for `errorbar_cap_size_scale` is `params.marker_size` (unscaled), and then `scale_factor` (subplot density based) is also applied. This might be a more pronounced scaling effect on cap sizes than intended.
    *   **Location in `beautify_figure.m`:** `beautify_single_axes`.
    *   **Impact:** Error bar cap sizes might appear disproportionately large or small.
    *   **Evidence:** Code inspection.

8.  **Clarity of `get_color_palette` with Invalid Figure Handle:**
    *   **Issue:** In `get_color_palette`, for `'default_matlab'` colors, if `fig_handle` is invalid, the logic for temporarily making it visible and restoring might not execute perfectly.
    *   **Location in `beautify_figure.m`:** `get_color_palette` function.
    *   **Impact:** Very minor; potential to fail to get figure-specific default colors or a brief figure flash.
    *   **Evidence:** Code inspection.

9.  **Invalid Parameter Warning for `theme` (Old Test Mismatch):**
    *   **Issue:** `old_test_beautify_figure.m` (Test Case 17) expects a warning for an invalid `theme` value. The current `beautify_figure.m` validates `style_preset` enums, but not `theme` itself as a top-level enum.
    *   **Location in `beautify_figure.m`:** Parameter validation section.
    *   **Impact:** The old test for this specific invalid parameter might be misleading.
    *   **Evidence:** Comparison of old test with current validation logic.

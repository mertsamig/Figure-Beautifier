# Agent Instructions

## General Context

This repository contains a MATLAB script for enhancing the visual aesthetics of figures, named `beautify_figure.m`. The script is designed to be a single, self-contained file with nested helper functions. It uses MATLAB's `inputParser` for handling a wide range of customizable parameters.

## Key Files

-   `beautify_figure.m`: The main and only MATLAB script file.
-   `README.md`: Provides an overview of the project.
-   `LICENSE.md`: The license for the project.

## Development Rules

### Coding Style

-   **Variable Naming:** All variable names must be in `snake_case`. This is a strict requirement.
-   **Loop Variables:** Do not use `i` as a loop variable. Use `k`, `idx`, or a more descriptive name (e.g., `k_param`).
-   **Function Naming:** Function names should also be in `snake_case`.
-   **Line Length:** Keep lines of code under 100 characters.
-   **Comments:** Add comments to explain complex or non-obvious parts of the code.

### File Structure

-   The script `beautify_figure.m` must remain a single file. Do not create a `src` directory or separate files for helper functions. All helper functions must be nested within the main function.

### Input Handling

-   All input parameters must be handled through MATLAB's `inputParser`. The old style of using `nargin` and `isstruct` for parsing is deprecated and should not be used.

### Error Handling

-   Use `try-catch` blocks to handle potential errors gracefully. When catching an exception, name the `MException` object `me_...` (e.g., `me_figure_color`).

## Verification

Before submitting any changes, ensure the following:
1.  The `beautify_figure.m` script can be executed without errors.
2.  All variable and function names adhere to the `snake_case` convention.
3.  The file structure rules are followed.
4.  The script correctly uses `inputParser` for all parameter handling.

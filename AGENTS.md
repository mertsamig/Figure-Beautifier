# Instructions for AI Agents

This document provides guidelines for AI agents contributing to the **OpenVSP-MATLAB-Clone** repository. Adherence to these instructions is mandatory to ensure code quality, consistency, and alignment with the project's objectives.

## 1. General Context

This repository contains the **MATLAB Figure Beautifier**, an open-source tool for enhancing the aesthetics of MATLAB figures, implemented entirely in **MATLAB**. The current implementation is focused on providing a programmatic interface (`beautify_figure.m`) and a graphical user interface (GUI) for applying visual styles to figures, making them suitable for presentations and publications. All AI-generated code must strictly follow the conventions established in this codebase.

## 2. Programming Style Guidelines

All code contributions must align with the existing coding style and structure. Follow these rules:

- **File Structure**: Each new function or class must be in its own `.m` file. Use **four spaces** for indentation (no tabs).
- **Naming Conventions**:
    - **Classes**: `PascalCase` (e.g., `AerodynamicModel`).
    - **Functions & Variables**: `snake_case` (e.g., `flutter_analysis`, `vlm_results`). New contributions must use `snake_case` for consistency. Do not use capital letters in function or variable names.
- **Code Comments**: Place a one-line comment above each distinct block of code to explain its purpose. Comments must always be on the line(s) immediately preceding the code they describe.
- **Function Documentation**: Every function file must start with a documentation block explaining its purpose, syntax, inputs, and outputs. Refer to existing functions in the `src` directory for the required format.
- **Input Validation**: All non-trivial public functions must use MATLAB's `inputParser` class for input argument validation to ensure correct type, shape, and value.
- **Operator Spacing**: Always use spaces around binary arithmetic and logical operators (e.g., `a = b + c * d`).
- **Variable Names**: Use clear, descriptive variable names. Avoid vague names, with the exception of simple loop indices (e.g., `n`, `k`). Do not use `i` or `j` as variable names to prevent confusion with imaginary units.
-- **General Formatting**: For all other style aspects (e.g., parentheses, line breaks), mimic the existing code in the `src` directory.

## 3. Execution Policies

- **Accuracy**: Never fabricate information, code, or documentation. All generated content must be accurate and directly supported by the codebase or user instructions. If unsure, ask for clarification.
- **Follow Instructions**: Execute all user instructions precisely and produce all requested outputs. Do not ignore any part of a request.
- **Complete All Tasks**: Do not terminate work prematurely. If multiple files or sections are requested, generate all of them before finishing.
- **Verify Your Work**: After generating output, proactively double-check it against the user's instructions and these guidelines. If anything is missing or incorrect, you must fix it.
- **Feature Proposals**: Do not add any new features without first proposing a detailed plan and receiving approval.
- **Testing Limitation**: AI agents cannot run MATLAB-based tests. Code modifications should be based on visual inspection and logical analysis.
- **Code Submission**: **Do not solely depend on code reviewer.** Check yourself too based on feedback. If there is something wrong with submission, report to the user, do not take any action in this case.

# AGENTS.md

This file provides guidance to agents when working with code in this repository.

### **Language & Communication**

- Always respond in Bahasa Indonesia (Casual/Santai)
- Keep technical terms in English, don't force weird Indonesian translations

### **Code Style**

- **No Formatter**: NEVER use any code formatters
- **Follow Existing Pattern**: If the codebase has a specific pattern (indentation, bracket style, naming convention), follow it exactly
- **Keep It Simple**: Avoid over-engineering. If it can be done in 10 lines, don't make it 50
- **Readability First**: Write code that's easy for humans to read, not just "works"
- **Minimal UI Copy**: Avoid subtitles, helper text, descriptions, and redundant labels unless explicitly requested or required
- **remove compile file**: if you compile code, please remove, example `__pycache__`

### **Documentation**

- Minimalist comments. Don't explain the obvious
- BAD example: `// increment i by 1` → i++
- GOOD example: `// workaround for bug in library X v2.1`
- Comments language: English

### **Problem Solving**

- **Think First**: Explain the logic before giving code
- **Edge Cases**: Always consider error handling and edge cases
- **No YOLO Code**: Don't blindly copypaste from the internet without understanding
- **Clarify Ambiguity**: If anything is ambiguous, ask for clarification first. Do not execute unless you are 100% sure you understand the requirements.

### **Tools & Commands**

- Read the file content first before editing
- When in doubt, ask before executing
- **QA On Request Only**: Do not perform QA unless explicitly requested
- **Flutter Build/Run On Request Only**: Do not run `flutter build` or `flutter run` or `flutter pub *` unless explicitly requested

### **Language Separation**

- Respond in Bahasa Indonesia (Casual), but code elements (comments, vars, docs) MUST be in English.



## Code Style & Linting (Non-Standard)

- **Print Statements Allowed**: avoid_print: false (unusual for Flutter apps)
- **Constant Identifiers Allowed**: constant_identifier_names: false (allows non-const identifiers)
- **Relative Imports Required**: prefer_relative_imports: true (enforced)
- **Single Quotes Required**: prefer_single_quotes: true (enforced)
- **Relaxed Curly Braces**: curly_braces_in_flow_control_structures: false
- **TODO Comments Ignored**: todo: ignore (no warnings for TODO comments)
- **Protected Members Allowed**: invalid_use_of_protected_member: ignore

- **File System Access**: Tests need appropriate permissions for external drives and file operations

## Development Commands

- **Build Commands**: Standard Flutter build (flutter build macos)

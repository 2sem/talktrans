# Task Completion Checklist

When completing a task, ensure the following:

## Code Quality
- [ ] Code follows Swift style conventions
- [ ] No compiler errors or warnings
- [ ] Code is properly formatted

## Tuist Project Generation (CRITICAL)
- [ ] If you modified any `Project.swift` or `Workspace.swift` files, **MUST regenerate**:
  ```bash
  tuist generate
  ```
- [ ] Verify the generated workspace opens correctly:
  ```bash
  open talktrans.xcworkspace
  ```
- [ ] **Never commit changes to generated Xcode project files** - only commit `Project.swift` changes

## Testing
- [ ] Run tests to ensure nothing is broken:
  ```bash
  # In Xcode: Cmd+U
  # Or via command line:
  xcodebuild test -workspace talktrans.xcworkspace -scheme App
  ```

## Build Verification
- [ ] Verify the project builds successfully:
  ```bash
  xcodebuild build -workspace talktrans.xcworkspace -scheme App
  ```
- [ ] Or build in Xcode: Cmd+B

## Code Review Checklist
- [ ] Changes are consistent with existing codebase patterns
- [ ] Dependencies are properly added to the correct project (App, ThirdParty, or DynamicThirdParty)
- [ ] Dependencies are defined in `Project.swift` using Tuist syntax (`.package()`)
- [ ] Bundle IDs and configurations are correct
- [ ] No hardcoded values that should be in configuration files
- [ ] Resources are properly included in the project definition
- [ ] If adding new targets, they're properly defined in the appropriate `Project.swift` file

## Tuist-Specific Checks
- [ ] Project definitions use correct Tuist `ProjectDescription` APIs
- [ ] Package dependencies use correct version requirements (`.upToNextMajor`, `.exact`, etc.)
- [ ] Framework targets use correct product types (`.staticFramework` vs `.framework`)
- [ ] Workspace includes all necessary projects
- [ ] Generated files are in `.gitignore` (if applicable)

## Before Committing
- [ ] All tests pass
- [ ] Project builds without errors
- [ ] `tuist generate` runs successfully
- [ ] No unnecessary files are included
- [ ] Changes are properly documented if needed
- [ ] Only source files and `Project.swift` files are committed (not generated Xcode files)
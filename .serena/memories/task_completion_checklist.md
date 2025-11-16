# Task Completion Checklist

When completing a task, ensure the following:

## Code Quality
- [ ] Code follows Swift style conventions
- [ ] No compiler errors or warnings
- [ ] Code is properly formatted

## Testing
- [ ] Run tests to ensure nothing is broken:
  ```bash
  # In Xcode: Cmd+U
  # Or via command line:
  xcodebuild test -workspace talktrans.xcworkspace -scheme App
  ```

## Project Generation
- [ ] If you modified `Project.swift` files, regenerate the Xcode project:
  ```bash
  tuist generate
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
- [ ] Bundle IDs and configurations are correct
- [ ] No hardcoded values that should be in configuration files
- [ ] Resources are properly included in the project

## Before Committing
- [ ] All tests pass
- [ ] Project builds without errors
- [ ] No unnecessary files are included
- [ ] Changes are properly documented if needed
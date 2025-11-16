# Suggested Commands for Talktrans Project

## Project Setup
```bash
# Install mise (if not already installed)
# Then install Tuist via mise
mise install

# Generate Xcode project
tuist generate

# Open the generated workspace
open talktrans.xcworkspace
```

## Development Commands
```bash
# Generate Xcode project (after changes to Project.swift files)
tuist generate

# Clean and regenerate
tuist clean
tuist generate

# Run tests
# Use Xcode's test runner or:
xcodebuild test -workspace talktrans.xcworkspace -scheme App -destination 'platform=iOS Simulator,name=iPhone 15'

# Build the project
xcodebuild build -workspace talktrans.xcworkspace -scheme App -destination 'platform=iOS Simulator,name=iPhone 15'
```

## System Utilities (Darwin/macOS)
```bash
# File operations
ls -la          # List files
cd <directory>  # Change directory
find . -name "*.swift"  # Find files
grep -r "pattern" .     # Search in files

# Git operations
git status
git add .
git commit -m "message"
git push
git pull

# Process management
ps aux | grep <process>
kill <pid>
```

## Tuist Commands
```bash
tuist generate          # Generate Xcode project
tuist clean             # Clean generated files
tuist graph             # Generate dependency graph
tuist edit              # Edit project manifest
tuist dump              # Dump project manifest
```

## Xcode Commands
```bash
# Build
xcodebuild -workspace talktrans.xcworkspace -scheme App build

# Test
xcodebuild -workspace talktrans.xcworkspace -scheme App test

# Archive (for distribution)
xcodebuild -workspace talktrans.xcworkspace -scheme App archive -archivePath ./build/App.xcarchive
```
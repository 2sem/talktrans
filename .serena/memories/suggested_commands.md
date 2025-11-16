# Suggested Commands for Talktrans Project

## Important: Tuist-Migrated Project
**This project uses Tuist for project generation.** The Xcode project files are generated and should not be edited manually. Always modify `Project.swift` files and regenerate.

## Project Setup
```bash
# Install mise (if not already installed)
# Then install Tuist via mise
mise install

# Generate Xcode project from Tuist definitions
tuist generate

# Open the generated workspace (note: workspace, not project)
open talktrans.xcworkspace
```

## Development Commands

### Tuist Commands (Most Important)
```bash
# Generate Xcode project (MUST run after any Project.swift changes)
tuist generate

# Clean generated files and regenerate
tuist clean
tuist generate

# Generate dependency graph (useful for understanding project structure)
tuist graph

# Edit project manifest (opens in Xcode)
tuist edit

# Dump project manifest (for debugging)
tuist dump
```

### Building and Testing
```bash
# Build the project
xcodebuild build -workspace talktrans.xcworkspace -scheme App -destination 'platform=iOS Simulator,name=iPhone 15'

# Run tests
xcodebuild test -workspace talktrans.xcworkspace -scheme App -destination 'platform=iOS Simulator,name=iPhone 15'

# Or use Xcode directly:
# Build: Cmd+B
# Test: Cmd+U
```

### Common Workflow
```bash
# 1. Make changes to Project.swift files
# 2. Regenerate project
tuist generate

# 3. Open in Xcode
open talktrans.xcworkspace

# 4. Build and test in Xcode
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

## Xcode Commands
```bash
# Build
xcodebuild -workspace talktrans.xcworkspace -scheme App build

# Test
xcodebuild -workspace talktrans.xcworkspace -scheme App test

# Archive (for distribution)
xcodebuild -workspace talktrans.xcworkspace -scheme App archive -archivePath ./build/App.xcarchive
```

## Troubleshooting Tuist
```bash
# If generation fails, clean and retry
tuist clean
tuist generate

# Check Tuist version
tuist version

# Update Tuist (via mise)
mise install tuist@latest
```
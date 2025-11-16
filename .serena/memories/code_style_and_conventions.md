# Code Style and Conventions

## Project Architecture: Tuist-Based
**This project has been migrated to Tuist.** All project configuration is defined in `Project.swift` files using Tuist's `ProjectDescription` framework. The Xcode project files are generated and should never be edited manually.

## Swift Style Guide
- **Swift Version**: 5.0
- **Language**: Modern Swift with SwiftUI

## Naming Conventions
- **Structs/Classes**: PascalCase (e.g., `TalktransApp`, `ContentView`)
- **Variables/Functions**: camelCase (e.g., `body`, `ContentView`)
- **Constants**: camelCase (e.g., `skAdNetworks`)

## Tuist Project Structure Conventions
- **Workspace Definition**: `Workspace.swift` at root defines the workspace
- **Project Definitions**: Each project has a `Project.swift` file
  - `Projects/App/Project.swift` - Main app project
  - `Projects/ThirdParty/Project.swift` - Static framework project
  - `Projects/DynamicThirdParty/Project.swift` - Dynamic framework project
- **Tuist Configuration**: `Projects/App/Tuist.swift` for app-specific Tuist settings
- **Package Configuration**: `Tuist/Package.swift` for Tuist plugin dependencies

## Source Code Organization
- **Sources**: Application source code in `Projects/App/Sources/`
- **Resources**: Assets and resources in `Projects/App/Resources/`
- **Tests**: Unit tests in `Projects/App/Tests/`
- **Configs**: Build configurations in `Projects/App/Configs/` (`.xcconfig` files)

## Code Organization
- Use SwiftUI for UI components
- Follow SwiftUI patterns (Views, ViewModels, Models)
- Use `@main` attribute for app entry point
- Use `public` access control for reusable components (as seen in `ContentView`)

## Tuist Project Configuration
- **Project Definitions**: Use Tuist's `ProjectDescription` framework
- **Dependencies**: Defined in `Project.swift` using `.package()` syntax
- **Bundle IDs**: Follow pattern `com.credif.talktrans` with suffixes for modules
  - App: `com.credif.talktrans`
  - ThirdParty: `com.credif.talktrans.thirdparty`
  - DynamicThirdParty: `com.credif.talktrans.thirdparty.dynamic`
- **Deployment Target**: iOS 18.0+
- **Platforms**: Supports both iPhone and iPad

## Dependencies Management (Tuist)
- Dependencies are managed via Swift Package Manager through Tuist
- Packages are defined in `Project.swift` files using `.remote()` or `.local()` syntax
- Third-party libraries are organized into separate framework targets:
  - `ThirdParty`: Static framework (`.staticFramework`) for most dependencies
  - `DynamicThirdParty`: Dynamic framework (`.framework`) for Firebase and SDWebImage
- Dependencies are referenced using `.package(product:type:)` syntax

## Testing
- Uses Swift Testing framework (not XCTest)
- Test structure: `@Test func example() async throws`
- Tests are in `Projects/App/Tests/` directory

## Important Tuist Conventions
- **Never edit generated files**: Only edit `Project.swift`, `Workspace.swift`, and source files
- **Always regenerate**: Run `tuist generate` after modifying project definitions
- **Use ProjectDescriptionHelpers**: Imported in project files for helper functions
- **Workspace vs Project**: The workspace (`sendadv`) contains multiple projects
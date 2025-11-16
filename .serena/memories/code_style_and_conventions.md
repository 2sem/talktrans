# Code Style and Conventions

## Swift Style Guide
- **Swift Version**: 5.0
- **Language**: Modern Swift with SwiftUI

## Naming Conventions
- **Structs/Classes**: PascalCase (e.g., `TalktransApp`, `ContentView`)
- **Variables/Functions**: camelCase (e.g., `body`, `ContentView`)
- **Constants**: camelCase (e.g., `skAdNetworks`)

## Project Structure Conventions
- **Sources**: Application source code in `Projects/App/Sources/`
- **Resources**: Assets and resources in `Projects/App/Resources/`
- **Tests**: Unit tests in `Projects/App/Tests/`
- **Configs**: Build configurations in `Projects/App/Configs/`

## Code Organization
- Use SwiftUI for UI components
- Follow SwiftUI patterns (Views, ViewModels, Models)
- Use `@main` attribute for app entry point
- Use `public` access control for reusable components (as seen in `ContentView`)

## Project Configuration
- Project definitions use Tuist's `ProjectDescription` framework
- Bundle IDs follow pattern: `com.credif.talktrans` with suffixes for modules
- Deployment target: iOS 18.0+
- Supports both iPhone and iPad

## Dependencies Management
- Dependencies are managed via Swift Package Manager through Tuist
- Third-party libraries are organized into separate framework targets:
  - `ThirdParty`: Static framework for most dependencies
  - `DynamicThirdParty`: Dynamic framework for Firebase and SDWebImage

## Testing
- Uses Swift Testing framework (not XCTest)
- Test structure: `@Test func example() async throws`
- Tests are in `Projects/App/Tests/` directory
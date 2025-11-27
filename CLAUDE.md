# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**TalkTrans** is an iOS translation application built with SwiftUI and managed by Tuist. The app provides real-time translation using multiple translation APIs (Naver Papago, Apple Translation) with speech recognition support.

- **Framework**: SwiftUI (migrated from UIKit)
- **Build System**: Tuist
- **Architecture**: MVVM pattern
- **Target iOS Version**: iOS 18.0+
- **Platform**: iOS only (iPhone and iPad)
- **Languages**: Swift 6.0+

## Essential Commands

### Tuist Commands

**IMPORTANT**: This project uses `mise` to manage Tuist. Always run Tuist commands via `mise x --`:

```bash
# Generate Xcode project (MUST run this before opening Xcode)
mise x -- tuist generate

# Clean generated files
mise x -- tuist clean

# Build the project
mise x -- tuist build

# Run tests
mise x -- tuist test

# Build for specific configuration
mise x -- tuist build --configuration Release

# Check Tuist version
mise x -- tuist version
```

**Note**: Running `tuist` directly will NOT work. You must use `mise x -- tuist` because:
- Tuist is managed via mise tool version manager
- `mise` is located at `/opt/homebrew/bin/mise`
- Running Tuist without mise will result in "command not found" errors

### Git Workflow

The project uses git-secret for managing sensitive files like API keys. Secret files use `.plist.secret` extension and should never be committed.

## Project Architecture

### Directory Structure

```
Projects/
├── App/                           # Main app target
│   ├── Sources/
│   │   ├── App.swift             # SwiftUI app entry point
│   │   ├── AppDelegate.swift     # Legacy support
│   │   ├── Screens/              # Full-screen views (end with "Screen")
│   │   │   ├── TranslationScreen.swift
│   │   │   ├── LanguageSelectionScreen.swift
│   │   │   └── SpeechRecognitionScreen.swift
│   │   ├── Views/                # Reusable views (end with "View" or "Button")
│   │   │   ├── TranslationInputView.swift
│   │   │   ├── TranslationOutputView.swift
│   │   │   └── LanguagePickerButton.swift
│   │   ├── ViewModels/           # MVVM ViewModels
│   │   │   ├── TranslationViewModel.swift
│   │   │   └── SpeechRecognitionViewModel.swift
│   │   ├── Models/               # Data models
│   │   │   ├── TranslationLocale.swift
│   │   │   └── TranslationLocale+Extension.swift
│   │   ├── Managers/             # Business logic and services
│   │   │   ├── TranslationManager.swift
│   │   │   ├── SwiftUIAdManager.swift
│   │   │   └── ReviewManager.swift
│   │   ├── Datas/                # Data persistence
│   │   │   └── LSDefaults.swift
│   │   └── Extensions/           # Extensions and helpers
│   ├── Resources/
│   │   ├── Images/langs/         # Language flag images
│   │   ├── InfoPlist/            # Configuration files (*.plist)
│   │   └── Strings/              # Localization (.lproj folders)
│   ├── Configs/                  # Build configurations
│   │   ├── app.debug.xcconfig
│   │   └── app.release.xcconfig
│   └── Project.swift             # Tuist project definition
├── ThirdParty/                   # Static framework dependencies
└── DynamicThirdParty/            # Dynamic framework dependencies

Tuist/
├── Package.swift                 # SPM dependencies
└── ProjectDescriptionHelpers/    # Tuist helper extensions
```

### Key Architectural Patterns

#### MVVM with SwiftUI

All screens follow this pattern:

```swift
// Screen (View)
struct TranslationScreen: View {
    @StateObject private var viewModel = TranslationViewModel()

    var body: some View {
        // View implementation
    }
}

// ViewModel
@MainActor
class TranslationViewModel: ObservableObject {
    @Published var property: String = ""

    func performAction() {
        // Business logic
    }
}
```

#### Naming Conventions

- **Screens**: Full-screen views end with `Screen` (e.g., `TranslationScreen`)
- **Views**: Reusable components end with `View` or describe the component (e.g., `TranslationInputView`, `LanguagePickerButton`)
- **ViewModels**: End with `ViewModel` (e.g., `TranslationViewModel`)
- **Managers**: Singletons for services end with `Manager` (e.g., `TranslationManager`)

#### Navigation

- Use `NavigationStack` (NOT `NavigationView`)
- Use `.sheet()` for modal presentations
- Use `.presentationDetents()` for custom sheet sizes

### Translation System

The app supports multiple translation backends through `TranslationManager`:

1. **Naver Papago API** - Primary translation service
2. **Apple Translation Framework** - Native iOS translation support

Translation configuration is stored in:
- `Resources/InfoPlist/NaverPapago.plist` (API configuration)
- `Resources/InfoPlist/NaverPapago.plist.secret` (API keys - NOT committed)

Supported languages are defined in `TranslationLocale` enum with 13 languages including Korean, English, Japanese, Chinese, Spanish, German, French, etc.

### Data Persistence

- **UserDefaults wrapper**: `LSDefaults` class for preferences like `isUpsideDown`, `isRotateFixed`
- **Core Data**: Models defined in `Resources/Datas/talktrans.xcdatamodeld/` (for future use)

## Code Style Guidelines

### SwiftUI Specifics

- Use `@StateObject` for view-owned ViewModels
- Use `@ObservedObject` for passed ViewModels
- Use `@State` for local view state
- Use `@Binding` for two-way data binding
- Always use `@MainActor` for ViewModels that update UI

### Swift Style

- **Indentation**: Use tabs (NOT spaces)
- **Variables/Functions**: camelCase
- **Classes/Structs**: PascalCase
- **Constants**: Use `let` keyword
- **Access Control**: Default to `private` for internal properties/methods

### MARK Comments

Organize code sections with MARK comments:

```swift
// MARK: - Properties
// MARK: - Lifecycle
// MARK: - Setup
// MARK: - Actions
```

## Important Configuration

### Tuist Project Definition

The main app target is defined in `Projects/App/Project.swift`:
- Bundle ID: Defined via `.appBundleId` extension
- Deployment target: iOS 18.0+
- Dependencies: ThirdParty, DynamicThirdParty, and GADManager (Google Ads)
- Firebase Crashlytics script runs post-build

### Google Ads Integration

The app includes Google AdMob with:
- Banner ads: `ca-app-pub-9684378399371172/9513798848`
- Full-screen ads: `ca-app-pub-9684378399371172/1814946844`
- Launch ads: `ca-app-pub-9684378399371172/1669573614`

Ads are managed via `SwiftUIAdManager` and `GADManager` package.

### Secrets Management

- API keys and secrets use `.plist.secret` extension
- These files are managed by git-secret and excluded from version control
- Never hardcode API keys in source files
- Use environment-specific configuration files

## Legacy Code Notes

The following UIKit files are deprecated and kept for reference only:
- `MainViewController.swift` - Legacy UIKit implementation
- `LSLanguagePicker*` files - Legacy UIKit language picker components
- Storyboards in `Resources/Storyboards/`

**All new features should use SwiftUI exclusively.**

## Testing

Unit tests are located in `Projects/App/Tests/`. The project includes a test target `AppTests` configured in Project.swift.

When writing tests:
- Test ViewModels independently from Views
- Use mock objects for dependencies
- Use descriptive test names: `testSubject_Scenario_ExpectedBehavior()`
- Use `@MainActor` for ViewModel tests when needed

## Common Pitfalls

1. **Always run `mise x -- tuist generate` after**:
   - Pulling changes from git
   - Modifying Project.swift
   - Adding/removing dependencies
   - Changing build configurations
   - **Remember**: Use `mise x -- tuist`, NOT just `tuist`

2. **File organization**:
   - Screens go in `Sources/Screens/`
   - Reusable views go in `Sources/Views/`
   - ViewModels go in `Sources/ViewModels/`

3. **Language flags**:
   - Flag images must exist in `Resources/Images/langs/`
   - Use the naming convention: `{language}.png` (e.g., `korean.png`, `english.png`)
   - Access via `TranslationLocale.flagImageName`

4. **Localization**:
   - Update ALL language files in `Resources/Strings/` when adding new strings
   - Supported: en, ko, es, de, and more

5. **Never commit**:
   - `.xcodeproj` and `.xcworkspace` files (generated by Tuist)
   - `*.plist.secret` files
   - API keys or sensitive data

# TalkTrans Project Specific Guidelines

## Project Overview

**TalkTrans** is an iOS translation application built with:
- **Framework**: SwiftUI (renewed from UIKit)
- **Build System**: Tuist
- **Architecture**: MVVM pattern with SwiftUI
- **Target iOS Version**: iOS 18.0+
- **Localization**: Multi-language support (English, Korean, Spanish, German, etc.)

## Third-Party Services

### Firebase
- Used for analytics and cloud messaging
- Configuration in `Resources/InfoPlist/GoogleService-Info.plist`

### Translation APIs
- **Naver Papago**: Configured in `Resources/InfoPlist/NaverPapago.plist`
- **Backup APIs**: For redundancy and API switching
- **Apple Translation Framework**: Native translation support

### App Structure

```
Projects/App/
├── Sources/
│   ├── App.swift                      # SwiftUI app entry
│   ├── AppDelegate.swift              # UIKit app delegate (for legacy support)
│   ├── ContentView.swift              # SwiftUI root view
│   ├── MainViewController.swift       # Legacy UIKit controller (deprecated)
│   ├── Views/                         # SwiftUI Views
│   │   ├── TranslationScreen.swift   # Main translation screen
│   │   ├── LanguageSelectionView.swift # Language picker sheet
│   │   ├── LanguagePickerButton.swift  # Language selection button
│   │   ├── TranslationInputView.swift # Input text section
│   │   └── TranslationOutputView.swift # Output text section
│   ├── ViewModels/                    # MVVM ViewModels
│   │   ├── TranslationViewModel.swift # Translation logic
│   │   └── SpeechRecognitionViewModel.swift # Speech recognition
│   ├── Models/                        # Data models
│   │   ├── TranslationLocale.swift   # Language enum
│   │   └── TranslationLocale+Extension.swift # Language extensions
│   ├── Managers/                      # Business logic
│   │   └── TranslationManager.swift  # Translation API manager
│   ├── Datas/                         # Data persistence
│   │   └── LSDefaults.swift          # UserDefaults wrapper
│   └── Extensions/                    # Utility extensions
│       ├── View+CornerRadius.swift   # SwiftUI view extensions
│       └── [Other extensions]
├── Resources/
│   ├── Assets.xcassets/              # Images, icons, colors
│   ├── Datas/                        # Core Data models
│   ├── Images/                       # Language flags, icons
│   │   └── langs/                    # Language flag images
│   ├── InfoPlist/                    # Configuration files
│   ├── Strings/                      # Localization strings
│   └── Storyboards/                  # Legacy UI layouts (deprecated)
└── Tests/                            # Unit tests
```

## SwiftUI Architecture

### View Structure

All SwiftUI views follow this pattern:

```swift
struct FeatureScreen: View {
    @StateObject private var viewModel = FeatureViewModel()
    
    var body: some View {
        // View implementation
    }
}
```

### ViewModel Pattern

ViewModels use `@MainActor` and `ObservableObject`:

```swift
@MainActor
class FeatureViewModel: ObservableObject {
    @Published var property: String = ""
    @Published var isLoading: Bool = false
    
    func performAction() {
        // Business logic
    }
}
```

### Screen Naming Convention

- **Main screens**: End with `Screen` (e.g., `TranslationScreen`)
- **Sub views**: End with `View` (e.g., `LanguagePickerButton`)
- **ViewModels**: End with `ViewModel` (e.g., `TranslationViewModel`)

## Translation Feature Implementation

### TranslationManager

Responsibilities:
- Handle translation requests to various APIs
- Cache translation results
- Manage API key rotation and error handling
- Support Apple Translation framework

```swift
class TranslationManager {
    static let shared = TranslationManager()
    
    func requestTranslate(
        text: String,
        from sourceLocale: Locale,
        to targetLocale: Locale,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        // Translation implementation
    }
    
    func canSupportTranslate(source: Locale, target: Locale) -> Bool {
        // Check if translation is supported
    }
    
    func supportedTargetLangs(source: Locale) -> [TranslationLocale] {
        // Get supported target languages
    }
}
```

### TranslationViewModel

Manages translation state and business logic:

```swift
@MainActor
class TranslationViewModel: ObservableObject {
    @Published var nativeText: String = ""
    @Published var translatedText: String = ""
    @Published var nativeLocale: TranslationLocale = .english
    @Published var translatedLocale: TranslationLocale = .korean
    @Published var isTranslating: Bool = false
    
    func translate() {
        // Perform translation
    }
    
    func swapLanguages() {
        // Swap source and target languages
    }
}
```

### Language Support

Supported languages via `TranslationLocale` enum:

```swift
enum TranslationLocale: String, CaseIterable {
    case korean = "ko"
    case english = "en"
    case japanese = "ja"
    case chinese = "zh-Hans"
    case taiwan = "zh-Hant"
    case vietnam = "vi"
    case indonesian = "id"
    case thai = "th"
    case german = "de"
    case russian = "ru"
    case spain = "es"
    case italian = "it"
    case france = "fr"
}
```

Each locale has extensions for:
- `displayName`: Localized language name
- `flagImageName`: Path to flag image in `Resources/Images/langs/`
- `locale`: Convert to `Locale` object

## SwiftUI Components

### TranslationScreen

Main screen structure:

```swift
struct TranslationScreen: View {
    @StateObject private var viewModel = TranslationViewModel()
    @StateObject private var speechViewModel = SpeechRecognitionViewModel()
    
    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(...)
            
            ScrollView {
                VStack {
                    TranslationOutputView(...)
                    TranslationInputView(...)
                    ActionButtons(...)
                }
            }
        }
    }
}
```

### Language Selection

Language picker uses sheet presentation:

```swift
.sheet(isPresented: $showLanguagePicker) {
    LanguageSelectionView(
        languages: availableLocales,
        selectedLocale: currentLocale,
        onSelect: { locale in
            // Handle selection
        }
    )
    .presentationDetents([.medium, .large])
}
```

### Speech Recognition

Speech recognition uses `SpeechRecognitionViewModel`:

```swift
@MainActor
class SpeechRecognitionViewModel: ObservableObject {
    @Published var isRecognizing: Bool = false
    @Published var recognizedText: String = ""
    
    func startRecognition(locale: Locale, onResult: @escaping (String) -> Void) {
        // Speech recognition implementation
    }
}
```

## UI/UX Patterns

### Color Scheme

- **Primary**: Purple (`Color.purple`)
- **Background**: Gradient from purple to pink
- **Input/Output Sections**: Light purple background (`Color.purple.opacity(0.05)`)
- **Buttons**: Purple for primary, white/gray for secondary

### Layout Structure

1. **Translated Output Section** (Top)
   - Language picker button
   - Translated text display
   - Light purple background

2. **Native Input Section** (Middle)
   - Language picker button
   - Text input field
   - Light purple background

3. **Action Buttons** (Bottom)
   - Translate button (purple)
   - Speech Recognition button (white/gray)

4. **Advertisement Banner** (Very bottom)
   - Placeholder for ads

### Navigation

- Use `NavigationStack` (not `NavigationView`)
- Use `.sheet()` for modal presentations
- Use `.presentationDetents()` for custom sheet sizes

## Data Persistence

### UserDefaults

Use `LSDefaults` wrapper:

```swift
class LSDefaults {
    static var isUpsideDown: Bool?
    static var isRotateFixed: Bool?
    // Other preferences
}
```

### Core Data (Future)

Models defined in `Resources/Datas/talktrans.xcdatamodeld/`:
- **Translation History**: Store past translations
- **Favorites**: Save frequently used phrases
- **Settings**: User preferences

## Image Resources

### Language Flags

Flag images stored in `Resources/Images/langs/`:
- `korean.png`
- `english.png`
- `japanese.png`
- `chinese.png`
- `taiwanese.png`
- `vietnamese.png`
- `indonesian.png`
- `thai.png`
- `german.png`
- `russian.png`
- `spanish.png`
- `italian.png`
- `french.png`

Access via `TranslationLocale.flagImageName`:
```swift
Image(locale.flagImageName)
    .resizable()
    .scaledToFit()
```

## Network Configuration

### API Endpoints

Store in configuration files:
- `Resources/InfoPlist/NaverPapago.plist` - Naver Papago API keys
- `Resources/InfoPlist/NaverPapago.plist.secret` - Secret keys (not committed)

## Testing

### Unit Test File Organization

```
Tests/
├── ViewModels/
│   ├── TranslationViewModelTests.swift
│   └── SpeechRecognitionViewModelTests.swift
├── Managers/
│   └── TranslationManagerTests.swift
├── Mocks/
│   ├── MockTranslationManager.swift
│   └── MockSpeechRecognizer.swift
└── Helpers/
    └── TestHelper.swift
```

### SwiftUI Testing

```swift
import XCTest
import SwiftUI
@testable import App

class TranslationScreenTests: XCTestCase {
    func testTranslationScreenRenders() {
        let view = TranslationScreen()
        // Test view rendering
    }
}
```

## Localization Files

### String Resource Organization

- `Resources/Strings/en.lproj/Localizable.strings` - English
- `Resources/Strings/ko.lproj/Localizable.strings` - Korean
- `Resources/Strings/es.lproj/Localizable.strings` - Spanish
- `Resources/Strings/de.lproj/Localizable.strings` - German
- (Other languages...)

### String Keys Convention

```swift
"translate.title" = "Translate"
"translate.placeholder" = "Enter text"
"language.select" = "Select Language"
"error.network" = "Network error occurred"
"button.translate" = "Translate"
"button.speech.recognition" = "Speech Recognition"
```

## Performance Optimization

### SwiftUI Best Practices

- Use `@StateObject` for view-owned ViewModels
- Use `@ObservedObject` for passed ViewModels
- Use `@Published` for reactive properties
- Avoid unnecessary view updates

### Image Optimization

- Store language flag icons in `Resources/Images/langs/`
- Use PNG format
- Maintain @1x, @2x, @3x variants if needed

### Translation Caching

```swift
class CachedTranslationManager {
    private var cache: [String: String] = [:]
    private let manager: TranslationManager
    
    func translate(_ text: String, from: String, to: String) async throws -> String {
        let key = "\(from)-\(to)-\(text)"
        if let cached = cache[key] {
            return cached
        }
        
        let result = try await manager.translate(text, from: from, to: to)
        cache[key] = result
        return result
    }
}
```

## Common Tasks and Commands

### Generate Project
```bash
cd /Users/LYJ/Projects/leesam/talktrans/src/talktrans
tuist generate
```

### Run Tests
```bash
tuist test
```

### Build for Release
```bash
tuist build --configuration Release
```

### Clean Build Artifacts
```bash
tuist clean
```

## Important Configuration Files

- `Tuist/Package.swift` - External dependencies
- `Projects/App/Project.swift` - App target definition
- `Resources/InfoPlist/GoogleService-Info.plist` - Firebase config
- `Resources/InfoPlist/NaverPapago.plist` - Translation API keys
- `Configs/app.debug.xcconfig` - Debug build settings
- `Configs/app.release.xcconfig` - Release build settings

## Secrets Management

- Store sensitive keys in `.plist.secret` files
- Example: `Resources/InfoPlist/NaverPapago.plist.secret`
- Never commit secret files to repository
- Use environment variables or secure storage in CI/CD

## Coding Tips for TalkTrans

### When Creating a New SwiftUI Screen

1. Create `{Feature}Screen.swift` in `Sources/Views/`
2. Create `{Feature}ViewModel.swift` in `Sources/ViewModels/`
3. Use `@StateObject` for ViewModel in Screen
4. Follow SwiftUI declarative syntax
5. Add localized strings to resource files
6. Write unit tests in `Tests/`
7. Update Project.swift if adding new target

### When Adding a New Feature

1. Create View in `Sources/Views/{Feature}/`
2. Create ViewModel in `Sources/ViewModels/`
3. Add Models if needed in `Sources/Models/`
4. Register navigation routes if needed
5. Add unit tests
6. Update resource strings for all supported languages
7. Test on multiple device sizes

### When Integrating External APIs

1. Define request/response models
2. Create a protocol for the service
3. Implement manager with error handling
4. Add mock implementation for testing
5. Add API key storage in secure location
6. Implement retry logic and timeouts
7. Use async/await for modern Swift concurrency

## Migration Notes

### From UIKit to SwiftUI

- `MainViewController.swift` is kept for reference but deprecated
- All new features should use SwiftUI
- Legacy UIKit components can be wrapped with `UIViewRepresentable` if needed
- Use `@StateObject` and `@ObservedObject` instead of manual binding

### Legacy Code

- `MainViewController.swift` - Legacy UIKit implementation (can be removed after full migration)
- `LSLanguagePicker*` - Legacy UIKit components (replaced by SwiftUI views)
- Storyboards - Legacy UI (replaced by SwiftUI)

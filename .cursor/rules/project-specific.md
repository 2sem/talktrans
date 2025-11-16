# TalkTrans Project Specific Guidelines

## Project Overview

**TalkTrans** is an iOS translation application built with:
- **Framework**: UIKit (NOT SwiftUI)
- **Build System**: Tuist
- **Architecture**: MVVM with Manager pattern
- **Target iOS Version**: iOS 14.0+
- **Localization**: Multi-language support (English, Korean, Spanish, German, etc.)

## Third-Party Services

### Firebase
- Used for analytics and cloud messaging
- Configuration in `Resources/InfoPlist/GoogleService-Info.plist`

### Translation APIs
- **Naver Papago**: Configured in `Resources/InfoPlist/NaverPapago.plist`
- **Backup APIs**: For redundancy and API switching

### App Structure

```
Projects/App/
├── Sources/
│   ├── App.swift                 # SwiftUI app entry
│   ├── AppDelegate.swift         # UIKit app delegate
│   ├── ContentView.swift         # SwiftUI root view
│   ├── MainViewController.swift   # UIKit main controller
│   ├── Datas/                    # Core Data models
│   │   ├── Models
│   │   ├── Repositories
│   │   └── talktrans.xcdatamodeld/
│   ├── Extensions/               # Utility extensions
│   ├── Managers/                 # Business logic
│   │   ├── TranslationManager
│   │   ├── LanguageManager
│   │   └── StorageManager
│   └── Models/                   # Data models
├── Resources/
│   ├── Assets.xcassets/          # Images, icons, colors
│   ├── Datas/                    # Core Data models
│   ├── Images/                   # Language flags, icons
│   ├── InfoPlist/                # Configuration files
│   ├── Strings/                  # Localization strings
│   └── Storyboards/              # UI layouts (if any)
└── Tests/                        # Unit tests
```

## Translation Feature Implementation

### TranslationManager

Responsibilities:
- Handle translation requests to various APIs
- Cache translation results
- Manage API key rotation and error handling

```swift
protocol TranslationProviding {
    func translate(_ text: String, from: String, to: String) async throws -> String
}

class TranslationManager: TranslationProviding {
    private let papago: NaverPapagoProvider
    private let fallback: FallbackProvider
    
    func translate(_ text: String, from source: String, to target: String) async throws -> String {
        // Try primary API
        // Fallback to secondary if needed
    }
}
```

### Language Support

Supported languages configuration:

```swift
enum LanguageCode: String, CaseIterable {
    case english = "en"
    case korean = "ko"
    case spanish = "es"
    case german = "de"
    // ... other languages
}
```

## Data Persistence

### Core Data

Models defined in `Resources/Datas/talktrans.xcdatamodeld/`:

- **Translation History**: Store past translations
- **Favorites**: Save frequently used phrases
- **Settings**: User preferences

### Data Access Pattern

```swift
protocol TranslationRepository {
    func saveTranslation(_ translation: TranslationItem) throws
    func fetchRecentTranslations() throws -> [TranslationItem]
    func deleteTranslation(_ id: UUID) throws
}

class CoreDataTranslationRepository: TranslationRepository {
    // Implementation
}
```

## UI/UX Patterns

### Main Tab Structure

```
MainViewController
├── TranslateViewController       # Main translation screen
├── HistoryViewController         # Translation history
├── FavoritesViewController       # Saved translations
└── SettingsViewController        # App settings
```

### TranslateViewController Pattern

```swift
class TranslateViewController: UIViewController {
    private let viewModel: TranslateViewModel
    
    // Source and target language pickers
    private let sourceLanguageButton = UIButton()
    private let targetLanguageButton = UIButton()
    
    // Input and output text views
    private let inputTextView = UITextView()
    private let outputTextView = UITextView()
    
    // Action buttons
    private let translateButton = UIButton()
    private let swapLanguagesButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        bindViewModel()
    }
}
```

### Key UI Components

- **Language Picker**: Modal or popover showing language list
- **Text Input**: Accept paste, voice input, and text entry
- **Translation Output**: Display with copy and share options
- **History View**: Scrollable list of translations

## Network Configuration

### API Endpoints

Store in configuration files:

```swift
enum APIConfiguration {
    static let papagoBaseURL = "https://openapi.naver.com"
    static let googleTranslateBaseURL = "https://translation.googleapis.com"
    static let timeout: TimeInterval = 30
}
```

### Request/Response Models

```swift
struct TranslationRequest: Encodable {
    let source: String
    let target: String
    let text: String
}

struct TranslationResponse: Decodable {
    let translatedText: String
    let sourceLanguage: String
    let targetLanguage: String
}
```

## Testing

### Unit Test File Organization

```
Tests/
├── Features/
│   ├── TranslateViewControllerTests.swift
│   ├── TranslateViewModelTests.swift
│   └── TranslationManagerTests.swift
├── Mocks/
│   ├── MockTranslationManager.swift
│   └── MockLanguageManager.swift
└── Helpers/
    └── TestHelper.swift
```

### Mock Implementation Pattern

```swift
class MockTranslationManager: TranslationProviding {
    var translateWasCalled = false
    var translateResult: Result<String, Error> = .success("Mocked translation")
    
    func translate(_ text: String, from: String, to: String) async throws -> String {
        translateWasCalled = true
        return try translateResult.get()
    }
}
```

## Localization Files

### String Resource Organization

- `Resources/Strings/en.lproj/Localizable.strings` - English
- `Resources/Strings/ko.lproj/Localizable.strings` - Korean
- `Resources/Strings/es.lproj/Localizable.strings` - Spanish
- `Resources/Strings/de.lproj/Localizable.strings` - German

### String Keys Convention

```swift
"translate.title" = "Translate"
"translate.placeholder" = "Enter text"
"language.select" = "Select Language"
"error.network" = "Network error occurred"
"button.translate" = "Translate"
```

## Performance Optimization

### Image Optimization

- Store language flag icons in `Resources/Images/langs/`
- Use PNG/WebP format
- Maintain @1x, @2x, @3x variants

### Translation Caching

```swift
class CachedTranslationManager: TranslationProviding {
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

### When Creating a New View Controller

1. Create `{Feature}ViewController.swift` in `Sources/`
2. Create `{Feature}ViewModel.swift` for business logic
3. Use UIKit with NSLayoutAnchor or SnapKit
4. Follow MARK organization pattern
5. Add localized strings to resource files
6. Write unit tests in `Tests/`
7. Update Project.swift if adding new target

### When Adding a New Feature

1. Create directory under `Sources/Features/{FeatureName}/`
2. Add ViewController, ViewModel, and Models
3. Register routes in navigation manager
4. Add unit tests
5. Update resource strings for all supported languages
6. Test on multiple device sizes and orientations

### When Integrating External APIs

1. Define request/response models
2. Create a protocol for the service
3. Implement manager with error handling
4. Add mock implementation for testing
5. Add API key storage in secure location
6. Implement retry logic and timeouts

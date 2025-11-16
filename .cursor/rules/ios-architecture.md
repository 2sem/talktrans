# iOS Architecture Rules

## Project Structure

This project uses **Tuist** for project generation and **SwiftUI** for UI development (migrated from UIKit).

### Directory Organization

```
Projects/
├── App/                    # Main application target
│   ├── Sources/           # Swift source files
│   │   ├── App.swift      # SwiftUI application entry point
│   │   ├── AppDelegate.swift
│   │   ├── ContentView.swift # SwiftUI root view
│   │   ├── Views/         # SwiftUI Views
│   │   │   ├── TranslationScreen.swift
│   │   │   ├── LanguageSelectionView.swift
│   │   │   └── [Other Views]
│   │   ├── ViewModels/    # MVVM ViewModels
│   │   │   ├── TranslationViewModel.swift
│   │   │   └── [Other ViewModels]
│   │   ├── Models/        # Data models
│   │   ├── Managers/      # Business logic managers
│   │   ├── Datas/         # Data persistence
│   │   └── Extensions/    # SwiftUI/Foundation extensions
│   ├── Resources/         # Localizations, assets, configurations
│   │   ├── Assets.xcassets/
│   │   ├── Images/        # Language flags, icons
│   │   ├── Strings/       # Localization files
│   │   ├── InfoPlist/     # Configuration files
│   │   └── Storyboards/    # Legacy UI (deprecated)
│   ├── Tests/             # Unit and integration tests
│   ├── Configs/           # Build configurations
│   └── Project.swift      # Tuist project definition
├── ThirdParty/            # Static dependencies
├── DynamicThirdParty/      # Dynamic dependencies
Tuist/
├── Package.swift           # Tuist dependencies
└── ProjectDescriptionHelpers/
    ├── Path+.swift
    ├── Swift+.swift
    └── TargetDependency+.swift
```

## SwiftUI Conventions

### Screen Structure

```swift
// Screen naming: [Feature]Screen.swift
struct TranslationScreen: View {
    @StateObject private var viewModel = TranslationViewModel()
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(...)
            
            // Content
            ScrollView {
                VStack {
                    // View components
                }
            }
        }
    }
}
```

### View Structure

- Use `View` protocol for all UI components
- Break down complex views into smaller sub-views
- Use `@StateObject` for view-owned ViewModels
- Use `@ObservedObject` for passed ViewModels
- Use `@State` for local view state
- Use `@Binding` for two-way data binding

### ViewModel Pattern

```swift
@MainActor
class TranslationViewModel: ObservableObject {
    @Published var property: String = ""
    @Published var isLoading: Bool = false
    
    func performAction() {
        // Business logic
    }
}
```

### Navigation Patterns

- Use `NavigationStack` (iOS 16+) instead of `NavigationView`
- Use `.sheet()` for modal presentations
- Use `.navigationDestination()` for programmatic navigation
- Use `.presentationDetents()` for custom sheet sizes
- Use dependency injection via initializers

## Legacy UIKit Support

### View Controller Hierarchy (Deprecated)

```swift
// Legacy UIKit code - kept for reference
// New code should use SwiftUI
class MainViewController: UIViewController {
    // MARK: - Properties
    private let viewModel: MainViewModel
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        bindViewModel()
    }
}
```

### UIKit Integration

When needed, wrap UIKit components with `UIViewRepresentable`:

```swift
struct UIKitComponentWrapper: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        // Create UIKit view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // Update UIKit view
    }
}
```

## Tuist Best Practices

### Project Definition (Project.swift)

```swift
let project = Project(
    name: "TalkTrans",
    targets: [
        Target(
            name: "App",
            platform: .iOS,
            product: .app,
            bundleId: "com.talktrans.app",
            infoPlist: .file(path: "Resources/InfoPlist/App-Info.plist"),
            sources: ["Sources/**"],
            resources: ["Resources/**"],
            dependencies: [
                .target(name: "Frameworks")
            ]
        )
    ]
)
```

### Dependency Management

- Define shared dependencies in `Tuist/ProjectDescriptionHelpers/`
- Use `TargetDependency+.swift` for common dependency configurations
- Keep external dependencies in `Tuist/Package.swift`

## Code Organization

### File Naming

- **Screens**: `{Feature}Screen.swift` (e.g., `TranslationScreen.swift`)
- **Views**: `{Feature}View.swift` (e.g., `LanguagePickerButton.swift`)
- **ViewModels**: `{Feature}ViewModel.swift` (e.g., `TranslationViewModel.swift`)
- **Models**: `{Feature}.swift` (e.g., `TranslationLocale.swift`)
- **Managers**: `{Feature}Manager.swift` (e.g., `TranslationManager.swift`)
- **Extensions**: `{Type}+{Feature}.swift` (e.g., `View+CornerRadius.swift`)

### Folder Structure

Organize code by layer, with feature-specific views grouped:

```
Sources/
├── App.swift         # Entry point
├── ContentView.swift # Root view
├── Views/            # SwiftUI Views
│   ├── TranslationScreen.swift
│   ├── LanguageSelectionView.swift
│   └── [Other Views]
├── ViewModels/       # MVVM ViewModels
│   ├── TranslationViewModel.swift
│   └── [Other ViewModels]
├── Models/           # Data models
│   ├── TranslationLocale.swift
│   └── [Other Models]
├── Managers/         # Business logic
│   └── TranslationManager.swift
├── Datas/            # Data persistence
└── Extensions/       # Extensions
```

## Testing

### Test Organization

```swift
// ViewModel Tests
class TranslationViewModelTests: XCTestCase {
    var viewModel: TranslationViewModel!
    var mockTranslationManager: MockTranslationManager!
    
    override func setUp() {
        super.setUp()
        mockTranslationManager = MockTranslationManager()
        viewModel = TranslationViewModel(translationManager: mockTranslationManager)
    }
    
    func testTranslationSucceeds() {
        // Arrange, Act, Assert
    }
}

// SwiftUI View Tests
class TranslationScreenTests: XCTestCase {
    func testTranslationScreenRenders() {
        let view = TranslationScreen()
        // Test view rendering
    }
}
```

### Unit Testing Best Practices

- Use mock objects for dependencies
- Test one behavior per test method
- Use descriptive test names: `testSubject_Scenario_ExpectedBehavior()`
- Test ViewModels independently from Views
- Use `@MainActor` for ViewModel tests when needed

## Localization

- Use `.strings` files in `Resources/Strings/`
- Maintain separate files for each supported language (en, ko, es, de, etc.)
- Use NSLocalizedString for runtime localization

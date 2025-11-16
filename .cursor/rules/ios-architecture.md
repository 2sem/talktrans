# iOS Architecture Rules

## Project Structure

This project uses **Tuist** for project generation and **UIKit** for UI development.

### Directory Organization

```
Projects/
├── App/                    # Main application target
│   ├── Sources/           # Swift source files
│   │   ├── App.swift     # Application entry point
│   │   ├── AppDelegate.swift
│   │   ├── ContentView.swift
│   │   ├── MainViewController.swift
│   │   ├── Datas/        # Data models and databases
│   │   ├── Extensions/   # UIKit/Foundation extensions
│   │   └── Managers/     # Business logic managers
│   ├── Resources/         # Localizations, assets, configurations
│   │   ├── Assets.xcassets/
│   │   ├── Strings/      # Localization files
│   │   ├── InfoPlist/    # Configuration files (GoogleService-Info.plist, etc.)
│   │   └── Storyboards/  # UI storyboards
│   ├── Tests/            # Unit and integration tests
│   ├── Configs/          # Build configurations
│   └── Project.swift     # Tuist project definition
├── ThirdParty/           # Static dependencies
├── DynamicThirdParty/    # Dynamic dependencies
Tuist/
├── Package.swift         # Tuist dependencies
└── ProjectDescriptionHelpers/
    ├── Path+.swift
    ├── Swift+.swift
    └── TargetDependency+.swift
```

## UIKit Conventions

### View Controller Hierarchy

```swift
// View controller naming: [Screen]ViewController.swift
class MainViewController: UIViewController {
    // MARK: - Properties
    private let viewModel: MainViewModel
    
    // MARK: - UI Components
    private let titleLabel = UILabel()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        bindViewModel()
    }
    
    // MARK: - Setup
    private func setupUI() { }
    private func setupConstraints() { }
    private func bindViewModel() { }
}
```

### View Structure

- Use `UIView` subclasses for reusable components
- Keep constraints setup in dedicated `setupConstraints()` method
- Use SnapKit or NSLayoutAnchor for programmatic constraints (preferred)

### Navigation Patterns

- Use `UINavigationController` for navigation stack
- Implement custom transition animators for complex animations
- Use dependency injection for view controller initialization

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

- **ViewControllers**: `{Feature}ViewController.swift`
- **Views**: `{Feature}View.swift` or `{Feature}Cell.swift`
- **ViewModels**: `{Feature}ViewModel.swift`
- **Models**: `{Feature}.swift`
- **Managers**: `{Feature}Manager.swift`
- **Extensions**: `{Type}+{Feature}.swift`

### Folder Structure

Organize code by feature or layer, not by type:

```
Sources/
├── App/              # Entry points
├── Features/         # Feature-specific code
│   ├── Translate/
│   │   ├── TranslateViewController.swift
│   │   ├── TranslateViewModel.swift
│   │   └── TranslateCell.swift
├── Core/             # Shared components
│   ├── Extensions/
│   ├── Managers/
│   └── Models/
```

## Testing

### Test Organization

```swift
class TranslateViewControllerTests: XCTestCase {
    var viewController: TranslateViewController!
    var mockViewModel: MockTranslateViewModel!
    
    override func setUp() {
        super.setUp()
        mockViewModel = MockTranslateViewModel()
        viewController = TranslateViewController(viewModel: mockViewModel)
    }
    
    func testTranslationSucceeds() {
        // Arrange, Act, Assert
    }
}
```

### Unit Testing Best Practices

- Use mock objects for dependencies
- Test one behavior per test method
- Use descriptive test names: `testSubject_Scenario_ExpectedBehavior()`

## Localization

- Use `.strings` files in `Resources/Strings/`
- Maintain separate files for each supported language (en, ko, es, de, etc.)
- Use NSLocalizedString for runtime localization

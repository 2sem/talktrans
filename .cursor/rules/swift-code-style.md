# Swift Code Style Guide

## Code Organization

### MARK Comments

Use MARK comments to organize code sections:

```swift
class ViewController: UIViewController {
    // MARK: - Properties
    
    // MARK: - UI Components
    
    // MARK: - Lifecycle
    
    // MARK: - Setup
    
    // MARK: - Actions
    
    // MARK: - Helpers
}
```

## Naming Conventions

### Classes and Structs

- Use PascalCase for all type names
- Suffix ViewControllers with `ViewController`
- Suffix Views with `View`
- Suffix ViewModels with `ViewModel`
- Suffix Managers with `Manager`

```swift
class MainViewController: UIViewController { }
class TranslateView: UIView { }
class TranslateViewModel { }
class TranslationManager { }
```

### Variables and Functions

- Use camelCase for variables and functions
- Use descriptive names that clearly indicate purpose
- Use verb prefixes for boolean variables: `is`, `has`, `should`, `can`

```swift
private var isLoading = false
private var hasError = false
private func setupUI() { }
private func bindViewModel() { }
```

### Constants

- Use UPPER_SNAKE_CASE for global constants
- Use meaningful names for magic numbers/strings

```swift
private let CELL_HEIGHT: CGFloat = 80
private let API_TIMEOUT: TimeInterval = 30
private let EMPTY_STRING = ""
```

## Access Control

- Default to `private` for internal properties and methods
- Use `fileprivate` only when necessary
- Use `internal` (default) for framework-level APIs
- Use `public` only for public APIs

```swift
class ViewController: UIViewController {
    private let viewModel: ViewModel
    private func setupUI() { }
}
```

## Type-Specific Conventions

### Optional Handling

```swift
// Preferred: Use guard let or if let
if let user = user {
    process(user)
}

// For early exit
guard let data = data else { return }

// Avoid force unwrapping except in guaranteed safe situations
let value = optional! // Only if 100% certain
```

### Extensions

- Organize extensions in separate files when extending external types
- Use protocol conformance extensions

```swift
// Good: UIViewController+Keyboard.swift
extension UIViewController {
    func setupKeyboardHandling() { }
}

// Good: Protocol conformance in extension
extension MainViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) { }
}
```

### Computed Properties

```swift
var displayName: String {
    return "\(firstName) \(lastName)"
}

var isValid: Bool {
    return email.contains("@") && password.count > 0
}
```

## UIKit Specific Patterns

### View Initialization

```swift
class CustomView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        setupConstraints()
    }
}
```

### Constraint Setup (NSLayoutAnchor)

```swift
private func setupConstraints() {
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
        titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
        titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
        titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
    ])
}
```

### Table View Cells

```swift
class TranslateCell: UITableViewCell {
    static let reuseIdentifier = "TranslateCell"
    static let height: CGFloat = 80
    
    private let titleLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with model: TranslateItem) {
        titleLabel.text = model.title
    }
}
```

## Documentation

### Function Documentation

```swift
/// Translates text from source language to target language.
/// - Parameters:
///   - text: The text to translate.
///   - sourceLang: The source language code (e.g., "en", "ko").
///   - targetLang: The target language code.
/// - Returns: The translated text.
/// - Throws: TranslationError if translation fails.
func translate(_ text: String, from sourceLang: String, to targetLang: String) throws -> String {
    // Implementation
}
```

### Class Documentation

```swift
/// Manages all translation operations including API calls and caching.
/// 
/// This manager handles:
/// - Translation API requests
/// - Response caching
/// - Language detection
class TranslationManager {
    // Implementation
}
```

## Error Handling

### Custom Error Types

```swift
enum TranslationError: LocalizedError {
    case invalidInput
    case networkError
    case apiError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidInput:
            return "Input text is empty"
        case .networkError:
            return "Network connection failed"
        case .apiError(let message):
            return message
        }
    }
}
```

### Error Handling Pattern

```swift
do {
    let result = try translateAPI.translate(text, to: language)
    update(with: result)
} catch TranslationError.networkError {
    showErrorAlert("Network error occurred")
} catch {
    showErrorAlert("Unknown error occurred")
}
```

## Closures and Callbacks

```swift
// Single-line closures
let doubled = numbers.map { $0 * 2 }

// Multi-line closures
let filtered = numbers.filter { number in
    return number > 10
}

// Named completion handlers
func fetchTranslation(completion: @escaping (Result<String, Error>) -> Void) {
    // Implementation
}
```

## Performance Considerations

### Memory Management

- Avoid retaining cycles in closures
- Use `[weak self]` in escaping closures

```swift
fetchData { [weak self] result in
    guard let self = self else { return }
    self.updateUI(with: result)
}
```

### UI Operations

- Always perform UI updates on the main thread
- Use `DispatchQueue.main.async` when needed

```swift
DispatchQueue.main.async {
    self.updateUI()
}
```

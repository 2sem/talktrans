# Common Patterns and Solutions

## MVVM Implementation

### ViewModel Pattern

```swift
class TranslateViewModel: NSObject, ObservableObject {
    @Published var inputText: String = ""
    @Published var outputText: String = ""
    @Published var isLoading: Bool = false
    @Published var error: String?
    
    private let translationManager: TranslationProviding
    
    init(translationManager: TranslationProviding) {
        self.translationManager = translationManager
    }
    
    @MainActor
    func translate(from: String, to: String) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let result = try await translationManager.translate(
                inputText,
                from: from,
                to: to
            )
            self.outputText = result
        } catch {
            self.error = error.localizedDescription
        }
    }
}
```

### View Controller with ViewModel

```swift
class TranslateViewController: UIViewController {
    private let viewModel: TranslateViewModel
    
    init(viewModel: TranslateViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
    }
    
    private func setupBindings() {
        // Observe viewModel changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateUI),
            name: NSNotification.Name("ViewModelUpdated"),
            object: viewModel
        )
    }
    
    @objc private func updateUI() {
        outputTextView.text = viewModel.outputText
    }
}
```

## Dependency Injection

### Constructor Injection

```swift
class TranslateViewController: UIViewController {
    private let translationManager: TranslationProviding
    private let languageManager: LanguageProviding
    
    init(
        translationManager: TranslationProviding,
        languageManager: LanguageProviding
    ) {
        self.translationManager = translationManager
        self.languageManager = languageManager
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
```

### Service Locator (Container)

```swift
class ServiceContainer {
    static let shared = ServiceContainer()
    
    private lazy var translationManager: TranslationProviding = {
        TranslationManager(
            papago: NaverPapagoProvider(),
            cache: TranslationCache()
        )
    }()
    
    private lazy var languageManager: LanguageProviding = {
        LanguageManager()
    }()
    
    func makeTranslateViewController() -> TranslateViewController {
        return TranslateViewController(
            translationManager: translationManager,
            languageManager: languageManager
        )
    }
}
```

## Async/Await Patterns

### Basic Translation Call

```swift
@MainActor
func performTranslation() async {
    do {
        let result = try await translationManager.translate(
            inputText,
            from: sourceLanguage,
            to: targetLanguage
        )
        self.outputText = result
        showSuccessMessage()
    } catch TranslationError.networkError {
        showNetworkErrorAlert()
    } catch {
        showErrorAlert(error.localizedDescription)
    }
}
```

### Concurrent Operations

```swift
@MainActor
func translateMultiple(texts: [String]) async {
    let results = await withTaskGroup(of: (Int, String?, Error?).self) { group in
        for (index, text) in texts.enumerated() {
            group.addTask {
                do {
                    let result = try await self.translationManager.translate(
                        text,
                        from: self.sourceLanguage,
                        to: self.targetLanguage
                    )
                    return (index, result, nil)
                } catch {
                    return (index, nil, error)
                }
            }
        }
        
        var results: [(Int, String?, Error?)] = []
        for await result in group {
            results.append(result)
        }
        return results
    }
    
    self.translations = results.sorted { $0.0 < $1.0 }
}
```

### Timeout Handling

```swift
func translateWithTimeout(_ text: String) async throws -> String {
    try await withThrowingTaskGroup(of: String.self) { group in
        group.addTask {
            try await self.translationManager.translate(
                text,
                from: self.sourceLanguage,
                to: self.targetLanguage
            )
        }
        
        group.addTask {
            try await Task.sleep(nanoseconds: UInt64(10 * 1_000_000_000))
            throw TranslationError.timeout
        }
        
        guard let result = try await group.nextResult() else {
            throw TranslationError.unknown
        }
        
        return try result.get()
    }
}
```

## Protocol-Based Design

### Defining Protocols

```swift
protocol TranslationProviding {
    func translate(_ text: String, from: String, to: String) async throws -> String
}

protocol LanguageProviding {
    var supportedLanguages: [Language] { get }
    func getLanguageName(_ code: String) -> String?
}

protocol TranslationCaching {
    func cache(_ translation: String, for key: String)
    func retrieve(for key: String) -> String?
}
```

### Mock Implementations for Testing

```swift
class MockTranslationManager: TranslationProviding {
    var translations: [String: String] = [:]
    var shouldThrowError: Bool = false
    
    func translate(_ text: String, from: String, to: String) async throws -> String {
        if shouldThrowError {
            throw TranslationError.apiError("Mock error")
        }
        
        let key = "\(from)-\(to)-\(text)"
        return translations[key] ?? "Mocked: \(text)"
    }
}
```

## Error Handling

### Typed Error Enum

```swift
enum TranslationError: LocalizedError, Equatable {
    case invalidInput(String)
    case networkError
    case apiError(String)
    case timeout
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .invalidInput(let message):
            return "Invalid input: \(message)"
        case .networkError:
            return "Network connection failed. Please check your connection."
        case .apiError(let message):
            return "API Error: \(message)"
        case .timeout:
            return "Request timed out. Please try again."
        case .unknown:
            return "An unknown error occurred."
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .networkError, .timeout:
            return "Check your internet connection and try again."
        case .invalidInput:
            return "Please enter valid text and try again."
        default:
            return "Please try again later."
        }
    }
}
```

### Try-Catch Pattern

```swift
func performTranslation() {
    Task {
        do {
            let result = try await translationManager.translate(
                inputText,
                from: sourceLanguage,
                to: targetLanguage
            )
            await MainActor.run {
                self.outputText = result
            }
        } catch let error as TranslationError {
            await showErrorAlert(error)
        } catch {
            await showErrorAlert(TranslationError.unknown)
        }
    }
}
```

## Resource Management

### Bundle Resources

```swift
extension Bundle {
    func decodedJSON<T: Decodable>(_ filename: String) throws -> T {
        guard let url = url(forResource: filename, withExtension: "json") else {
            throw NSError(domain: "Bundle", code: -1)
        }
        
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(T.self, from: data)
    }
}
```

### Image Resources

```swift
class ImageAssets {
    enum Language {
        static let englishFlag = UIImage(named: "flag-en")
        static let koreanFlag = UIImage(named: "flag-ko")
        static let spanishFlag = UIImage(named: "flag-es")
    }
    
    enum Icon {
        static let translate = UIImage(systemName: "character.textbox")
        static let history = UIImage(systemName: "clock.fill")
        static let favorite = UIImage(systemName: "star.fill")
    }
}
```

## Reusable Components

### Custom Button

```swift
class TranslateButton: UIButton {
    init(title: String) {
        super.init(frame: .zero)
        
        var config = UIButton.Configuration.filled()
        config.title = title
        config.baseBackgroundColor = .systemBlue
        config.cornerStyle = .medium
        
        self.configuration = config
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
```

### Stack View Wrapper

```swift
func createHorizontalStack(
    arrangedSubviews: [UIView],
    spacing: CGFloat = 8,
    alignment: UIStackView.Alignment = .center
) -> UIStackView {
    let stack = UIStackView(arrangedSubviews: arrangedSubviews)
    stack.axis = .horizontal
    stack.spacing = spacing
    stack.alignment = alignment
    stack.distribution = .fillProportionally
    return stack
}
```

## State Management

### Observable State

```swift
class AppState: ObservableObject {
    @Published var sourceLanguage: String = "en"
    @Published var targetLanguage: String = "ko"
    @Published var recentTranslations: [TranslationItem] = []
    @Published var favorites: [TranslationItem] = []
    
    func updateSourceLanguage(_ language: String) {
        sourceLanguage = language
    }
    
    func swapLanguages() {
        let temp = sourceLanguage
        sourceLanguage = targetLanguage
        targetLanguage = temp
    }
}
```

## Logging and Debugging

### Debug Logger

```swift
struct Logger {
    static func log(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        #if DEBUG
        let filename = URL(fileURLWithPath: file).lastPathComponent
        print("[\(filename):\(line)] \(function) - \(message)")
        #endif
    }
    
    static func logError(_ error: Error, file: String = #file, function: String = #function, line: Int = #line) {
        #if DEBUG
        let filename = URL(fileURLWithPath: file).lastPathComponent
        print("❌ [\(filename):\(line)] \(function) - Error: \(error.localizedDescription)")
        #endif
    }
}
```

### Usage

```swift
Logger.log("Translation started")
Logger.logError(error)
```

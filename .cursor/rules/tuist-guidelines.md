# Tuist Development Guidelines

## MCP (Model Context Protocol) 지원

Tuist는 Agentic coding에서 사용하는 MCP(Model Context Protocol)를 지원합니다. 자세한 내용과 설정 방법은 Tuist 공식 문서의 "Agentic coding / MCP" 가이드(https://docs.tuist.dev/en/guides/features/agentic-coding/mcp)를 참고하세요.

권장 사항:

- Tuist의 MCP를 활성화하면 LLM/에이전트가 프로젝트 매니페스트(예: `Project.swift`, `Workspace.swift`)와 상호작용하여 안전하게 작업을 수행할 수 있습니다.
- 그러나 프로젝트 고유의 코드 스타일, 아키텍처 규약, 패턴(예: UIKit 사용 규칙, 파일/폴더 구조, 네이밍 규칙)은 여전히 `Cursor` 규칙(`.cursor/rules/`)로 명시해 두는 것을 권장합니다. MCP는 작업 자동화와 컨텍스트 제공에 강하지만, 세부 스타일과 팀 규약을 대체하지는 않습니다.
- 실무 권장: MCP를 도입해 에이전트 통합을 자동화하되, `./.cursor/rules/`에 있는 규칙을 유지하여 생성되는 코드의 일관성과 품질을 보장하세요.

참고: MCP 관련 설정과 보안(예: 민감한 파일 접근 제어)은 Tuist 문서의 가이드를 준수하고, 민감한 키/시크릿은 리포지토리에 커밋하지 마세요.

## Project Generation

### Running Tuist Commands

```bash
# Generate Xcode project from Tuist manifests
tuist generate

# Clean generated files
tuist clean

# Install dependencies
tuist install

# Build the project
tuist build

# Run tests
tuist test
```

## Project.swift Structure

### Basic Template

```swift
import ProjectDescription

// Define project name and settings
let project = Project(
    name: "TalkTrans",
    organizationName: "TalkTrans",
    targets: [
        // App target
        Target(
            name: "App",
            platform: .iOS,
            product: .app,
            bundleId: "com.talktrans.app",
            deploymentTarget: .iOS(targetVersion: "14.0"),
            infoPlist: .file(path: "Resources/InfoPlist/App-Info.plist"),
            sources: ["Sources/**"],
            resources: ["Resources/**"],
            entitlements: .file(path: "App.entitlements"),
            scripts: [],
            dependencies: [
                // Internal framework dependencies
                .target(name: "Frameworks"),
                // External package dependencies
                .external(name: "Firebase")
            ]
        ),
        // Test target
        Target(
            name: "AppTests",
            platform: .iOS,
            product: .unitTests,
            bundleId: "com.talktrans.app.tests",
            infoPlist: .default,
            sources: ["Tests/**"],
            dependencies: [
                .target(name: "App")
            ]
        )
    ]
)
```

## Dependency Management

### TargetDependency+.swift Pattern

```swift
import ProjectDescription

extension TargetDependency {
    // MARK: - Internal Frameworks
    static let frameworks = TargetDependency.target(name: "Frameworks")
    
    // MARK: - External Packages
    static let firebase = TargetDependency.external(name: "Firebase")
    static let alamofire = TargetDependency.external(name: "Alamofire")
}
```

### Common Dependencies

Define common groups of dependencies:

```swift
// External dependencies commonly used
static let networkingDependencies: [TargetDependency] = [
    .external(name: "Alamofire"),
    .external(name: "URLSessionConfiguration")
]

static let uiDependencies: [TargetDependency] = [
    .external(name: "SnapKit"),
    .external(name: "Kingfisher")
]

static let testingDependencies: [TargetDependency] = [
    .external(name: "XCTest"),
    .external(name: "Nimble")
]
```

## Package.swift Configuration

### Swift Package Dependencies

```swift
import PackageDescription

let package = Package(
    name: "TalkTransPackages",
    dependencies: [
        // Firebase
        .package(
            url: "https://github.com/firebase/firebase-ios-sdk.git",
            .upToNextMajor(from: "10.0.0")
        ),
        // HTTP Networking
        .package(
            url: "https://github.com/Alamofire/Alamofire.git",
            .upToNextMajor(from: "5.0.0")
        ),
        // Image Loading
        .package(
            url: "https://github.com/onevcat/Kingfisher.git",
            .upToNextMajor(from: "7.0.0")
        ),
    ]
)
```

## Configuration Files

### Info.plist Management

Use file-based info plists stored in `Resources/InfoPlist/`:

```swift
infoPlist: .file(path: "Resources/InfoPlist/App-Info.plist")
```

### Build Settings (xcconfig)

Create separate config files for debug and release:

```
Configs/
├── app.debug.xcconfig
└── app.release.xcconfig
```

Example `app.debug.xcconfig`:

```xcconfig
// Debug configuration
SWIFT_ACTIVE_COMPILATION_CONDITIONS = DEBUG

// Version
MARKETING_VERSION = 1.0.0
CURRENT_PROJECT_VERSION = 1
```

## Project Organization Best Practices

### Framework Targets

Create framework targets for:
- Core functionality (networking, database, etc.)
- Shared UI components
- Business logic modules

```swift
Target(
    name: "CoreFramework",
    platform: .iOS,
    product: .framework,
    bundleId: "com.talktrans.core",
    sources: ["Sources/**"],
    dependencies: []
)
```

### Test Targets

Maintain one test target per target:

```swift
Target(
    name: "AppTests",
    platform: .iOS,
    product: .unitTests,
    bundleId: "com.talktrans.app.tests",
    sources: ["Tests/**"],
    dependencies: [
        .target(name: "App"),
        .external(name: "XCTest")
    ]
)
```

## Build Phases and Scripts

### Custom Build Scripts

Add build phases using scripts array:

```swift
scripts: [
    .pre(
        path: "Scripts/PreBuild.sh",
        name: "Pre-Build Script",
        inputPaths: [],
        inputFileListPaths: [],
        outputPaths: [],
        outputFileListPaths: [],
        runForInstallBuildsOnly: false,
        basedOnDependencyAnalysis: true
    )
]
```

## Workspace Configuration

### Workspace.swift

At the root level, define multi-project workspace:

```swift
import ProjectDescription

let workspace = Workspace(
    name: "TalkTrans",
    projects: [
        "Projects/App",
        "Projects/ThirdParty",
        "Projects/DynamicThirdParty"
    ]
)
```

## Common Issues and Solutions

### Issue: Project not generating correctly

**Solution**: 
- Ensure all paths in Project.swift are relative to the project directory
- Run `tuist clean` before `tuist generate`
- Check for syntax errors in Swift files

### Issue: Dependencies not resolving

**Solution**:
- Verify Package.swift is in `Tuist/Package.swift`
- Run `tuist install` to resolve dependencies
- Check `Package.resolved` file is not corrupted

### Issue: Build settings not applied

**Solution**:
- Verify xcconfig files are in correct location
- Ensure xcconfig is referenced in Project.swift
- Check for conflicts between xcconfig and direct settings

## Version Management

### Deployment Target

Always specify deployment target:

```swift
deploymentTarget: .iOS(targetVersion: "14.0")
```

### Swift Version

Configure in Tuist project settings:

```swift
settings: Settings(
    base: [
        "SWIFT_VERSION": "5.7"
    ]
)
```

## Continuous Integration

### Generate in CI

```bash
# Install tuist if needed
brew install tuist

# Generate and build
tuist generate
xcodebuild -workspace talktrans.xcworkspace \
    -scheme talktrans-Workspace \
    -configuration Debug \
    build
```

### Store generated files

- Do NOT commit generated `.xcodeproj` files to repository
- Add to `.gitignore`:
  ```
  *.xcodeproj
  *.xcworkspace
  .DS_Store
  ```

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
    name: "ThirdParty",
    packages: [
        .remote(url: "https://github.com/kakao/kakao-ios-sdk",
                requirement: .upToNextMajor(from: "2.22.2")),
        .remote(url: "https://github.com/jdg/MBProgressHUD.git",
                requirement: .upToNextMajor(from: "1.2.0")),
        .remote(url: "https://github.com/2sem/LSExtensions",
                requirement: .exact("0.1.22")),
        .remote(url: "https://github.com/CosmicMind/Material",
                requirement: .upToNextMajor(from: "3.1.8")),
        .remote(url: "https://github.com/devxoul/UITextView-Placeholder",
                requirement: .upToNextMajor(from: "1.4.0")),
//        .remote(url: "https://github.com/SDWebImage/SDWebImage",
//                requirement: .upToNextMajor(from: "5.20.0")),
//        .local(path: "../../../../../spms/DownPicker")
    ],
    targets: [
        .target(
            name: "ThirdParty",
            destinations: .iOS,
            product: .staticFramework,
            bundleId: .appBundleId.appending(".thirdparty"),
            dependencies: [.package(product: "KakaoSDK", type: .runtime),
                           .package(product: "MBProgressHUD", type: .runtime),
                           .package(product: "LSExtensions", type: .runtime),
                           .package(product: "Material", type: .runtime)
            ]
        ),
    ]
)
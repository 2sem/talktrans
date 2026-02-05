import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
    name: "ThirdParty",
    packages: [
        .remote(url: "https://github.com/2sem/LSExtensions",
                requirement: .exact("0.1.22")),
        .remote(url: "https://github.com/CosmicMind/Material",
                requirement: .upToNextMajor(from: "3.1.8")),
        .remote(url: "https://github.com/ReactiveX/RxSwift",
                requirement: .upToNextMajor(from: "5.1.3")),
//        .local(path: "../../../../../spms/DownPicker")
    ],
    targets: [
        .target(
            name: "ThirdParty",
            destinations: .iOS,
            product: .staticFramework,
            bundleId: .appBundleId.appending(".thirdparty"),
            deploymentTargets: .iOS("18.0"),
            dependencies: [.package(product: "LSExtensions", type: .runtime),
                           .package(product: "Material", type: .runtime),
                           .package(product: "RxSwift", type: .runtime),
                           .package(product: "RxCocoa", type: .runtime)
            ]
        ),
    ]
)
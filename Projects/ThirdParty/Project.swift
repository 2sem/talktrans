import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
    name: "ThirdParty",
    targets: [
        .target(
            name: "ThirdParty",
            destinations: .iOS,
            product: .staticFramework,
            bundleId: .appBundleId.appending(".thirdparty"),
            deploymentTargets: .iOS("18.0"),
            dependencies: [.external(name: "LSExtensions"),
                           .external(name: "Material"),
                           .external(name: "RxSwift"),
                           .external(name: "RxCocoa")
            ]
        ),
    ]
)
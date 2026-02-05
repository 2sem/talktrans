import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
    name: "DynamicThirdParty",
    packages: [.remote(url: "https://github.com/firebase/firebase-ios-sdk",
                       requirement: .upToNextMajor(from: "11.8.1")),
    ],
    targets: [
        .target(
            name: "DynamicThirdParty",
            destinations: .iOS,
            product: .framework,
            bundleId: .appBundleId.appending(".thirdparty.dynamic"),
            deploymentTargets: .iOS("18.0"),
            dependencies: [.package(product: "FirebaseCrashlytics", type: .runtime),
                           .package(product: "FirebaseAnalytics", type: .runtime),
                           .package(product: "FirebaseMessaging", type: .runtime),
                           .package(product: "FirebaseRemoteConfig", type: .runtime)
            ]
        ),
    ]
)
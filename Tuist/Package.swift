// swift-tools-version: 6.0
import PackageDescription

#if TUIST
    import struct ProjectDescription.PackageSettings

    let packageSettings = PackageSettings(
        // Customize the product types for specific package product
        // Default is .staticFramework
        // productTypes: ["Alamofire": .framework,]
        productTypes: [:]
    )
#endif

let package = Package(
    name: "talktrans",
    dependencies: [
        .package(url: "https://github.com/ReactiveX/RxSwift", from: "5.1.3"),
        .package(url: "https://github.com/2sem/LSExtensions", exact: "0.1.24"),
        .package(url: "https://github.com/CosmicMind/Material", from: "3.1.8"),
        // Add your own dependencies here:
        // .package(url: "https://github.com/Alamofire/Alamofire", from: "5.0.0"),
        // You can read more about dependencies here: https://docs.tuist.io/documentation/tuist/dependencies
    ]
)

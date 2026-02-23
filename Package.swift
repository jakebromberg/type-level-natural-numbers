// swift-tools-version: 6.0
import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "PeanoNumbers",
    platforms: [.macOS(.v10_15)],
    products: [
        .library(name: "PeanoNumbers", targets: ["PeanoNumbers"]),
        .executable(name: "PeanoNumbersClient", targets: ["PeanoNumbersClient"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-syntax.git", from: "600.0.0"),
    ],
    targets: [
        .macro(name: "PeanoNumbersMacros", dependencies: [
            .product(name: "SwiftDiagnostics", package: "swift-syntax"),
            .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
            .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
        ]),
        .target(name: "PeanoNumbers", dependencies: ["PeanoNumbersMacros"]),
        .executableTarget(name: "PeanoNumbersClient", dependencies: ["PeanoNumbers"]),
        .testTarget(name: "PeanoNumbersMacrosTests", dependencies: [
            "PeanoNumbersMacros",
            .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
        ]),
    ]
)

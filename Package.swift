// swift-tools-version: 6.0
import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "AbuseOfNotation",
    platforms: [.macOS(.v10_15)],
    products: [
        .library(name: "AbuseOfNotation", targets: ["AbuseOfNotation"]),
        .executable(name: "AbuseOfNotationClient", targets: ["AbuseOfNotationClient"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-syntax.git", from: "600.0.0"),
    ],
    targets: [
        .macro(name: "AbuseOfNotationMacros", dependencies: [
            .product(name: "SwiftDiagnostics", package: "swift-syntax"),
            .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
            .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
        ]),
        .target(name: "AbuseOfNotation", dependencies: ["AbuseOfNotationMacros"]),
        .executableTarget(name: "AbuseOfNotationClient", dependencies: ["AbuseOfNotation"]),
        .testTarget(name: "AbuseOfNotationMacrosTests", dependencies: [
            "AbuseOfNotationMacros",
            .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
        ]),
    ]
)

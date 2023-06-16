// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "VersionedCodable",
    platforms: [.macOS(.v10_15), .iOS(.v13), .tvOS(.v13), .watchOS(.v6), .macCatalyst(.v13)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "VersionedCodable",
            targets: ["VersionedCodable"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),
        // Depend on the latest Swift 5.9 prerelease of SwiftSyntax
        .package(url: "https://github.com/apple/swift-syntax.git", from: "509.0.0-swift-5.9-DEVELOPMENT-SNAPSHOT-2023-04-25-b"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .macro(
            name: "VersionedCodableMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ]
        ),
        .testTarget(name: "VersionedCodableMacroTests",
                    dependencies: [
                        "VersionedCodableMacros",
                        .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
                    ]),
        
        .target(
            name: "VersionedCodable",
            dependencies: ["VersionedCodableMacros"]),
        .testTarget(
            name: "VersionedCodableTests",
            dependencies: ["VersionedCodable"],
            resources: [
                .copy("Support/expectedEncoded.plist"),
                .copy("Support/expectedOlder.plist"),
                .copy("Support/expectedUnsupported.plist"),
            ]),
    ]
)

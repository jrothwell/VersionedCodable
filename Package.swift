// swift-tools-version: 5.7.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "VersionedCodable",
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "VersionedCodable",
            targets: ["VersionedCodable"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "VersionedCodable",
            dependencies: [],
            resources: [
                .copy("PrivacyInfo.xcprivacy")
            ]),
        .testTarget(
            name: "VersionedCodableTests",
            dependencies: ["VersionedCodable"],
            resources: [
                .copy("Support/expectedEncoded.plist"),
                .copy("Support/expectedOlder.plist"),
                .copy("Support/expectedUnsupported.plist"),
                .copy("Support/UnusualKeyPaths/sonnet-v1.json"),
                .copy("Support/UnusualKeyPaths/sonnet-v2.json")
            ]),
    ]
)

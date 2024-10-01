// swift-tools-version: 5.7.1

import PackageDescription

let package = Package(
    name: "VersionedCodable",
    products: [
        .library(
            name: "VersionedCodable",
            targets: ["VersionedCodable"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),
    ],
    targets: [
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

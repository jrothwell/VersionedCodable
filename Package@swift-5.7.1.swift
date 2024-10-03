// swift-tools-version: 5.7.1

import PackageDescription

let package = Package(
    name: "VersionedCodable",
    products: [
        .library(
            name: "VersionedCodable",
            targets: ["VersionedCodable"]),
    ],
    targets: [
        .target(
            name: "VersionedCodable",
            dependencies: [],
            resources: [
                .copy("PrivacyInfo.xcprivacy")
            ])
    ]
)

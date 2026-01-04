// swift-tools-version: 5.9
// This Package.swift is for syntax validation only.
// To build the full iOS app, create an Xcode project.

import PackageDescription

let package = Package(
    name: "TurnLab",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "TurnLabCore",
            targets: ["TurnLabCore"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "TurnLabCore",
            dependencies: [],
            path: "TurnLab",
            exclude: [
                "Resources/Content",
                "Infrastructure/CoreData/TurnLab.xcdatamodeld"
            ],
            sources: [
                "Domain/Models",
                "Domain/Protocols"
            ]
        ),
        .testTarget(
            name: "TurnLabTests",
            dependencies: ["TurnLabCore"],
            path: "TurnLabTests",
            sources: ["Fixtures"]
        )
    ]
)

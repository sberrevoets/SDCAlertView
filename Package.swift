// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "SDCAlertView",
    platforms: [
        .iOS(.v9),
    ],
    products: [
        .library(
            name: "SDCAlertView",
            targets: ["SDCAlertView"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "SDCAlertView",
            path: "Source",
            exclude: [
                "Supporting Files",
            ],
            linkerSettings: [
                .linkedFramework("UIKit"),
            ]
        ),
    ],
    swiftLanguageVersions: [.v5]
)

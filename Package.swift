// swift-tools-version: 6.0

import PackageDescription

let swiftSettings: [SwiftSetting] = [
    .swiftLanguageMode(.v5)
]

let package = Package(
    name: "SimpleNotes",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "SimpleNotes", targets: ["SimpleNotes"]),
        .library(name: "SimpleNotesCore", targets: ["SimpleNotesCore"]),
        .executable(name: "SimpleNotesChecks", targets: ["SimpleNotesChecks"])
    ],
    targets: [
        .target(
            name: "SimpleNotesCore",
            path: "SimpleNotesCore",
            swiftSettings: swiftSettings
        ),
        .executableTarget(
            name: "SimpleNotes",
            dependencies: ["SimpleNotesCore"],
            path: "SimpleNotes",
            exclude: [
                "Resources/Info.plist",
                "Resources/SimpleNotes.entitlements",
                "Resources/AppIcon.icns"
            ],
            swiftSettings: swiftSettings
        ),
        .executableTarget(
            name: "SimpleNotesChecks",
            dependencies: ["SimpleNotesCore"],
            path: "SimpleNotesChecks",
            swiftSettings: swiftSettings
        )
    ]
)

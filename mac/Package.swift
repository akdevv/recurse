// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Recurse",
    platforms: [.macOS(.v15)],
    targets: [
        .executableTarget(name: "Recurse", path: "Sources/Recurse"),
        .testTarget(name: "RecurseTests", dependencies: ["Recurse"], path: "Tests/RecurseTests"),
    ]
)

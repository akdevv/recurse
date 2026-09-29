// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "Recurse",
    platforms: [.macOS(.v26)],
    targets: [
        .executableTarget(name: "Recurse", path: "Sources/Recurse"),
        .testTarget(name: "RecurseTests", dependencies: ["Recurse"], path: "Tests/RecurseTests"),
    ]
)

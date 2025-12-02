// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "QuestionGenerator",
    platforms: [.macOS(.v14)],
    targets: [
        .executableTarget(
            name: "QuestionGenerator",
            path: "Sources"
        ),
    ]
)

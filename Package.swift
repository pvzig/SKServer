// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "SKServer",
    products: [
        .library(name: "SKServer", targets: ["SKServer"])
    ],
    dependencies: [
    	.package(url: "https://github.com/SlackKit/SKCore", .upToNextMinor(from: "4.1.0")),
    	.package(url: "https://github.com/SlackKit/SKWebAPI", .upToNextMinor(from: "4.1.0")),
        .package(url: "https://github.com/httpswift/swifter.git", .upToNextMinor(from: "1.4.0"))
    ],
    targets: [
    	.target(name: "SKServer",
        dependencies: ["SKCore", "SKWebAPI", "Swifter"],
    			path: "Sources")
    ]
)

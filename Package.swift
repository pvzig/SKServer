import PackageDescription

let package = Package(
    name: "SKServer",
    targets: [
        Target(name: "SKServer")
    ],
    dependencies: [
        .Package(url: "https://github.com/SlackKit/SKCore", majorVersion: 4),
        .Package(url: "https://github.com/SlackKit/SKWebAPI", majorVersion: 4),
        .Package(url: "https://github.com/httpswift/swifter.git", "1.3.3")
    ]
)

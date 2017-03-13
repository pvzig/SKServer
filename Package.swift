import PackageDescription

let package = Package(
    name: "SKServer",
    targets: [
        Target(name: "SKServer")
    ],
    dependencies: [
        .Package(url: "https://github.com/SlackKit/SKCore", "4.0.0"),
        .Package(url: "https://github.com/SlackKit/SKWebAPI", "4.0.0"),
        .Package(url: "https://github.com/Zewo/HTTP.git", "0.14.3"),
        .Package(url: "https://github.com/pvzig/swifter.git", "2.0.3")
    ]
)

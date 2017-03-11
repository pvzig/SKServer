import PackageDescription

let package = Package(
    name: "SKServer",
    targets: [
        Target(name: "SKServer", dependencies: [
            "SKCore",
            "SKWebAPI"
        ])
    ],
    dependencies: [
        .Package(url: "https://github.com/SlackKit/SKCore", "4.0.0"),
        .Package(url: "https://github.com/SlackKit/SKWebAPI", "4.0.0"),
        .Package(url: "https://github.com/Zewo/HTTPServer", majorVersion: 0)
    ]
)

#if os(macOS) || os(iOS) || os(tvOS)
let dependency = .Package(url: "https://github.com/pvzig/swifter.git", majorVersion: 3)
package.dependencies.append(dependency)
#endif

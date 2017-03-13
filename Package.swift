import PackageDescription

let package = Package(
    name: "SKServer",
    targets: [
        Target(name: "SKServer")
    ],
    dependencies: [
        .Package(url: "https://github.com/SlackKit/SKCore", "4.0.0"),
        .Package(url: "https://github.com/SlackKit/SKWebAPI", "4.0.0"),
        .Package(url: "https://github.com/Zewo/HTTP.git", "0.14.3")
    ]
)

var dependency: Package.Dependency
#if os(macOS) || os(iOS) || os(tvOS)
dependency = .Package(url: "https://github.com/httpswift/swifter.git", "1.3.2")
#else
dependency = .Package(url: "https://github.com/Zewo/HTTPServer", majorVersion: 0)
#endif
package.dependencies.append(dependency)

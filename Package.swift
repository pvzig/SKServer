import PackageDescription

let package = Package(
    name: "SKServer",
    targets: [
        Target(name: "SKServer")
    ],
    dependencies: [
        .Package(url: "https://github.com/SlackKit/SKCore", "4.0.0"),
        .Package(url: "https://github.com/SlackKit/SKWebAPI", "4.0.0"),
        .Package(url: "https://github.com/httpswift/swifter.git", "1.3.3")
    ]
)

var dependencies: [Package.Dependency]
var exclude: [String]
#if os(macOS) || os(iOS) || os(tvOS)
dependencies = []
exclude = []
#else
dependencies = [
    .Package(url: "https://github.com/bermudadigitalstudio/Titan", "0.7.0")
]
exclude = ["Sources/SKServer/Titan"]
#endif
package.dependencies.append(contentsOf: dependencies)
package.exclude.append(contentsOf: exclude)

// swift-tools-version: 5.10
// WhisperKit is declared only when Package.swift is evaluated on macOS.
// Linux can still resolve and test LocalWhisperCore without Apple frameworks.

import PackageDescription

var packageDependencies: [Package.Dependency] = [
    .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.3.0"),
]

var executableDependencies: [Target.Dependency] = [
    "LocalWhisperCore",
    .product(name: "ArgumentParser", package: "swift-argument-parser"),
]

var packageProducts: [Product] = [
    .executable(name: "local-whisper", targets: ["local-whisper"]),
    .library(name: "LocalWhisperCore", targets: ["LocalWhisperCore"]),
]

var packageTargets: [Target] = [
    .target(
        name: "LocalWhisperCore"
    ),
    .testTarget(
        name: "LocalWhisperCoreTests",
        dependencies: ["LocalWhisperCore"]
    ),
]

#if os(macOS)
packageDependencies.append(
    .package(url: "https://github.com/argmaxinc/argmax-oss-swift.git", from: "1.1.0")
)
packageTargets.append(
    .target(
        name: "LocalWhisperMac",
        dependencies: [
            "LocalWhisperCore",
            .product(name: "WhisperKit", package: "argmax-oss-swift"),
        ]
    )
)
executableDependencies.append("LocalWhisperMac")
packageProducts.append(
    .library(name: "LocalWhisperMac", targets: ["LocalWhisperMac"])
)
#endif

packageTargets.append(
    .executableTarget(
        name: "local-whisper",
        dependencies: executableDependencies
    )
)

let package = Package(
    name: "local-whisper",
    platforms: [
        .macOS(.v14),
    ],
    products: packageProducts,
    dependencies: packageDependencies,
    targets: packageTargets
)

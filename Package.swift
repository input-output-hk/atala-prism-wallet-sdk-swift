// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AtalaPRISMSDK",
    platforms: [.iOS(.v15), .macOS(.v12)],
    products: [
        .library(
            name: "Domain",
            targets: ["Domain"]
        ),
        .library(
            name: "Apollo",
            targets: ["Apollo"]
        ),
        .library(
            name: "Castor",
            targets: ["Castor"]
        ),
        .library(
            name: "Pollux",
            targets: ["Pollux"]
        ),
        .library(
            name: "Mercury",
            targets: ["Mercury"]
        ),
        .library(
            name: "Pluto",
            targets: ["Pluto"]
        ),
        .library(
            name: "Builders",
            targets: ["Builders"]
        ),
        .library(
            name: "PrismAgent",
            targets: ["PrismAgent"]
        ),
        .library(
            name: "Authenticate",
            targets: ["Authenticate"]
        ),
        .library(
            name: "AtalaPrismSDK",
            targets: [
                "AtalaPrismSDK",
            ]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/apple/swift-log.git",
            from: "1.4.4"
        ),
        .package(url: "git@github.com:apple/swift-protobuf.git", from: "1.7.0"),
        .package(url: "https://github.com/beatt83/didcomm-swift.git", from: "0.1.1"),
        .package(url: "https://github.com/beatt83/jose-swift.git", from: "1.2.2"),
        .package(url: "https://github.com/beatt83/peerdid-swift.git", from: "2.0.2"),
        .package(url: "https://github.com/input-output-hk/anoncreds-rs.git", exact: "0.4.1"),
        .package(url: "https://github.com/input-output-hk/atala-prism-apollo.git", exact: "1.2.11"),
    ],
    targets: [
        .target(
            name: "AtalaPrismSDK",
            dependencies: [
                "Domain",
                "Castor",
                "Apollo",
                "Mercury",
                "Pluto",
                "Pollux",
                "PrismAgent"
            ],
            path: "AtalaPrismSDK/AtalaPrismSDK/Sources"
        ),
        .target(
            name: "Domain",
            path: "AtalaPrismSDK/Domain/Sources"
        ),
        .testTarget(
            name: "DomainTests",
            dependencies: ["Domain"],
            path: "AtalaPrismSDK/Domain/Tests"
        ),
        .target(
            name: "Apollo",
            dependencies: [
                "Domain",
                "Core",
                .product(name: "AnoncredsSwift", package: "anoncreds-rs"),
                .product(name: "ApolloLibrary", package: "atala-prism-apollo")
            ],
            path: "AtalaPrismSDK/Apollo/Sources"
        ),
        .target(
            name: "Castor",
            dependencies: [
                "Domain",
                "Core",
                .product(name: "PeerDID", package: "peerdid-swift"),
                .product(name: "SwiftProtobuf", package: "swift-protobuf")
            ],
            path: "AtalaPrismSDK/Castor/Sources"
        ),
        .testTarget(
            name: "CastorTests",
            dependencies: ["Castor", "Apollo"],
            path: "AtalaPrismSDK/Castor/Tests"
        ),
        .target(
            name: "Pollux",
            dependencies: [
                "Domain",
                "Core",
                "jose-swift",
                .product(name: "AnoncredsSwift", package: "anoncreds-rs")
            ],
            path: "AtalaPrismSDK/Pollux/Sources"
        ),
        .testTarget(
            name: "PolluxTests",
            dependencies: ["Pollux", "Apollo", "Castor", "PrismAgent"],
            path: "AtalaPrismSDK/Pollux/Tests"
        ),
        .target(
            name: "Mercury",
            dependencies: [
                "Domain",
                "Core",
                "didcomm-swift"
            ],
            path: "AtalaPrismSDK/Mercury/Sources"
        ),
        .testTarget(
            name: "MercuryTests",
            dependencies: ["Mercury"],
            path: "AtalaPrismSDK/Mercury/Tests"
        ),
        .target(
            name: "Pluto",
            dependencies: [
                "Domain",
                "Core"
            ],
            path: "AtalaPrismSDK/Pluto/Sources",
            resources: [.process("Resources/PrismPluto.xcdatamodeld")]
        ),
        .testTarget(
            name: "PlutoTests",
            dependencies: ["Pluto"],
            path: "AtalaPrismSDK/Pluto/Tests"
        ),
        .target(
            name: "Builders",
            dependencies: ["Domain", "Castor", "Pollux", "Mercury", "Pluto", "Apollo"],
            path: "AtalaPrismSDK/Builders/Sources"
        ),
        .target(
            name: "PrismAgent",
            dependencies: [
                "Domain",
                "Builders",
                "jose-swift",
                "Core"
            ],
            path: "AtalaPrismSDK/PrismAgent/Sources"
        ),
        .testTarget(
            name: "PrismAgentTests",
            dependencies: ["PrismAgent", "Core"],
            path: "AtalaPrismSDK/PrismAgent/Tests"
        ),
        .target(
            name: "Authenticate",
            dependencies: ["Domain", "Builders", "Core"],
            path: "AtalaPrismSDK/Authenticate/Sources"
        ),
//        .testTarget(
//            name: "AuthenticateTests",
//            dependencies: ["Authenticate"],
//            path: "AtalaPrismSDK/Authenticate/Tests"
//        ),
//        Internal core components (ex: logging) not public distributed
        .target(
            name: "Core",
            dependencies: [
                "Domain",
                .product(name: "Logging", package: "swift-log")
            ],
            path: "Core/Sources"
        )
    ]
)

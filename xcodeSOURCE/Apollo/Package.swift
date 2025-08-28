// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Apollo",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "ApolloCore",
            targets: ["ApolloCore"]
        ),
    ],
    dependencies: [
        // External dependencies will be added when configuring Firebase and Stripe
        .package(url: "https://github.com/firebase/firebase-ios-sdk", from: "10.18.0"),
        .package(url: "https://github.com/stripe/stripe-ios", from: "23.18.0"),
    ],
    targets: [
        .target(
            name: "ApolloCore",
            dependencies: [],
            path: "Sources/ApolloCore"
        ),
        .testTarget(
            name: "ApolloCoreTests",
            dependencies: ["ApolloCore"],
            path: "Tests/ApolloCoreTests"
        ),
    ]
)

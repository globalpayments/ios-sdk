// swift-tools-version:5.8

import PackageDescription

let package = Package(
    name: "GlobalPayments-iOS-SDK",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v12)
    ],
    products: [
        .library(
            name: "GlobalPayments-iOS-SDK",
            targets: ["GlobalPayments-iOS-SDK"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "GlobalPayments-iOS-SDK",
            dependencies: [],
            path: "GlobalPayments-iOS-SDK/Classes"
        )
    ]
)

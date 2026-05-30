// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.
//
// NOTE: BUAdSDK and BUAdLive are static XCFrameworks not distributed via SPM.
// They must be present in ios/pangle_flutter/Frameworks/ (git-ignored).
// Run example/ios/setup_spm_frameworks.sh after `pod install` to populate them.
import PackageDescription

let package = Package(
    name: "pangle_flutter",
    platforms: [
        .iOS("13.0"),
    ],
    products: [
        .library(name: "pangle-flutter", targets: ["pangle_flutter"]),
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework"),
    ],
    targets: [
        .binaryTarget(
            name: "BUAdSDK",
            path: "Frameworks/BUAdSDK.xcframework"
        ),
        .target(
            name: "pangle_flutter",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework"),
                .target(name: "BUAdSDK"),
            ],
            path: "Sources/pangle_flutter",
            resources: [
                .process("PrivacyInfo.xcprivacy"),
                .copy("Resources/CSJAdSDK.bundle"),
            ],
            linkerSettings: [
                .linkedLibrary("bz2"),
                .linkedLibrary("c++"),
                .linkedLibrary("c++abi"),
                .linkedLibrary("iconv"),
                .linkedLibrary("resolv"),
                .linkedLibrary("sqlite3"),
                .linkedLibrary("xml2"),
                .linkedLibrary("z"),
                .linkedFramework("Accelerate"),
                .linkedFramework("CoreMotion"),
                .linkedFramework("CoreLocation"),
                .linkedFramework("CoreTelephony"),
                .linkedFramework("JavaScriptCore"),
                .linkedFramework("MapKit"),
                .linkedFramework("MediaPlayer"),
                .linkedFramework("MobileCoreServices"),
                .linkedFramework("StoreKit"),
                .linkedFramework("SystemConfiguration"),
            ]
        ),
    ]
)

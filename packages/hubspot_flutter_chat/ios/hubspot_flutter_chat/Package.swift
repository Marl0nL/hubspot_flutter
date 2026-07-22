// swift-tools-version: 5.9
// Swift Package Manager manifest for the hubspot_flutter chat plugin's iOS side.
//
// It declares HubSpot's official iOS mobile chat SDK as a dependency. HubSpot
// ships the SDK via SPM only, so iOS integration requires Swift Package Manager
// (Flutter's default for new iOS builds).
//
// Pinned to exactly 1.0.7 to stay aligned with the Android SDK version (see
// android/build.gradle.kts). 1.0.7 is the iOS SDK's latest release; bump both
// platforms together when they advance.
//
// NOTE (needs on-device/macOS verification): the iOS deployment target below
// (13.0) is a lower bound the plugin itself is fine with, but HubSpot's iOS
// chat SDK may require a higher minimum (commonly iOS 15/16). Confirm against
// the SDK's own Package.swift on a real build and raise this if required.
import PackageDescription

let package = Package(
    name: "hubspot_flutter_chat",
    platforms: [
        .iOS("13.0"),
    ],
    products: [
        .library(name: "hubspot_flutter_chat", targets: ["hubspot_flutter_chat"]),
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework"),
        .package(
            url: "https://github.com/HubSpot/mobile-chat-sdk-ios",
            exact: "1.0.7"
        ),
    ],
    targets: [
        .target(
            name: "hubspot_flutter_chat",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework"),
                .product(name: "HubspotMobileSDK", package: "mobile-chat-sdk-ios"),
            ]
        ),
    ]
)

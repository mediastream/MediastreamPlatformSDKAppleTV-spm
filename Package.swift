// swift-tools-version:5.9
import PackageDescription

let package = Package(
  name: "MediastreamPlatformSDKAppleTV",
  platforms: [.tvOS(.v15)],
  products: [
    // The product carries the binary AND the wrapper, so consumers get the module plus
    // IMA / Youbora / AdSupport / AppTrackingTransparency in one dependency.
    .library(
      name: "MediastreamPlatformSDKAppleTV",
      targets: ["MediastreamPlatformSDKAppleTV", "MediastreamSDKDependencies"]
    )
  ],
  dependencies: [
    // Range, not exact: `exact` on a library's dependency is imposed on the consumer's
    // whole graph, so an app that also uses IMA directly at another version would fail to
    // resolve with no way out.
    //
    // The lower bound is not arbitrary. Google renamed the product from
    // GoogleInteractiveMediaAds to GoogleInteractiveMediaAdsTvOS in 4.15.1, so anything
    // below that does not expose the product referenced here; and 4.16.0 is where the
    // package's own floor moved to tvOS 15, matching this package. Note the module the
    // source imports is still GoogleInteractiveMediaAds — the module name comes from the
    // framework inside the xcframework, not from the product name.
    .package(
      url: "https://github.com/googleads/swift-package-manager-google-interactive-media-ads-tvos.git",
      "4.16.0"..<"5.0.0"
    ),
    // YouboraLib only — NOT avplayer-adapter-ios. That adapter is distributed as source,
    // so SwiftPM builds it statically; it is already compiled into the XCFramework and
    // declaring it here would duplicate its symbols in the consumer. YouboraLib ships as
    // a binaryTarget with tvos-arm64 and tvos-arm64_x86_64-simulator slices, so it stays a
    // dynamic framework that the binary loads at runtime.
    //
    // upToNextMinor from the version the XCFramework was built against: patches carry
    // NPAW's fixes and should flow through, while a minor bump has to be validated and
    // shipped in an SDK release — 6.7 already changed behaviour by reporting
    // AVPlayerItemFailedToPlayToEndTime as a fatal error, which 6.3 ignored entirely.
    // See docs/spm-migration/LINKAGE.md in the SDK repo.
    .package(
      url: "https://bitbucket.org/npaw/lib-plugin-spm-ios.git",
      .upToNextMinor(from: "6.7.23")
    )
  ],
  targets: [
    // The name must match MediastreamPlatformSDKAppleTV.xcframework inside the archive.
    // Both fields are rewritten by the release pipeline on every publish; editing them by
    // hand is how a checksum mismatch reaches a consumer.
    .binaryTarget(
      name: "MediastreamPlatformSDKAppleTV",
      url: "https://s3.amazonaws.com/mediastream-platform-sdk-ios/appleTV-sdk/2.3.0/MediastreamPlatformSDKAppleTVxC.zip",
      checksum: "36edc5be55b101dd6f311c9ab2a335e9b74e3fe0c7c6d1e7cd7f586940bef918"
    ),
    .target(
      name: "MediastreamSDKDependencies",
      dependencies: [
        "MediastreamPlatformSDKAppleTV",
        .product(
          name: "GoogleInteractiveMediaAdsTvOS",
          package: "swift-package-manager-google-interactive-media-ads-tvos"
        ),
        .product(name: "YouboraLib", package: "lib-plugin-spm-ios")
      ],
      path: "Sources/MediastreamSDKDependencies",
      // Mirrors s.frameworks = 'AdSupport', 'AppTrackingTransparency' from the podspec.
      // The prebuilt framework already links both itself, so this is not what makes it
      // resolve — it keeps the declaration explicit if a future build stops carrying them.
      linkerSettings: [
        .linkedFramework("AdSupport"),
        .linkedFramework("AppTrackingTransparency")
      ]
    )
  ]
)

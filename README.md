# MediastreamPlatformSDKAppleTV — Swift Package

Swift Package Manager distribution for the Mediastream Platform SDK for Apple TV.

This repository holds only the package manifest. The SDK ships as a precompiled
XCFramework hosted on Mediastream's CDN; the source lives in a private repository.

Requires **tvOS 15.0** or later and Xcode 15 or later.

## Xcode

**File → Add Package Dependencies…**, paste:

```
https://github.com/mediastream/MediastreamPlatformSDKAppleTV-spm.git
```

Choose **Up to Next Major Version** from `2.1.0` and add the
`MediastreamPlatformSDKAppleTV` product to your app target.

## Package.swift

```swift
dependencies: [
  .package(
    url: "https://github.com/mediastream/MediastreamPlatformSDKAppleTV-spm.git",
    from: "2.1.0"
  )
]
```

Then:

```swift
import MediastreamPlatformSDKAppleTV
```

## Migrating from CocoaPods

`MediastreamPlatformSDKAppleTV` **2.0.0-qa.02 is the last version published to
CocoaPods.** New versions ship through the Swift package only. Versions already on trunk
stay installable forever, but they will not receive fixes.

1. Remove `pod 'MediastreamPlatformSDKAppleTV'` from your Podfile and run `pod install`.
2. Add the package as shown above.
3. **No code changes.** The public API and `import MediastreamPlatformSDKAppleTV` are
   unchanged.

Two things get better on the way out, both of which the pod imposed on your app:

- **The tvOS simulator works on Apple Silicon again.** The pod set
  `EXCLUDED_ARCHS[sdk=tvossimulator*] = arm64` on your target, not just its own, which
  left anyone on an M-series Mac unable to run a tvOS simulator. The package ships a
  `tvos-arm64_x86_64-simulator` slice and excludes nothing.
- **The deployment floor is now accurate.** The last pod declared tvOS 14 while the SDK
  had already moved on. If you still need to support tvOS 14, stay on the pod: the IMA
  tvOS package requires tvOS 15, so there is no way to go lower here.

## What the package pulls in

| Dependency | You get | Notes |
|---|---|---|
| GoogleInteractiveMediaAdsTvOS | `4.16.0` up to but not including `5.0.0` | The lower bound is not a preference: Google renamed the product in 4.15.1, and 4.16.0 is where its own floor moved to tvOS 15 |
| YouboraLib | `6.7.x` from `6.7.23` | Distributed by NPAW from **bitbucket.org** |

`AdSupport` and `AppTrackingTransparency` are linked for you. If your app shows the App
Tracking Transparency prompt, you still call `ATTrackingManager` yourself — the SDK links
the framework but does not request authorization on your behalf.

**If your build environment restricts outbound git access, allow `bitbucket.org`.** NPAW
distributes YouboraLib from there, and it is a transitive dependency you cannot avoid.

**If you filter outbound traffic, allow `a-fds.youborafds01.com`.** Youbora 6.7 moved its
configuration endpoint there from `nqs.nice264.com`.

The module you import for ads is `GoogleInteractiveMediaAds`, even though the product is
called `GoogleInteractiveMediaAdsTvOS`. The module name comes from the framework inside
Google's xcframework, not from the package's product name.

### Why the versions you resolve may differ from the ones we built against

The SDK is compiled against the **lowest** version of each range and runs against whatever
your project resolves, which is usually the highest. That direction is deliberate: building
against the lowest guarantees we never call an API missing from a version you might
resolve, while running against a newer one is safe because these SDKs add rather than
remove. See the compatibility table below for the exact versions per release.

## Chromecast

Not applicable on tvOS. An Apple TV is a Cast *receiver* target, not a sender, and the
Google Cast sender SDK does not ship for tvOS. If you are looking for the Cast
integration guide, it lives in the
[iOS package](https://github.com/mediastream/MediastreamPlatformSDKiOS-spm/blob/master/CAST_INTEGRATION.md).

## Pre-release channels

Two channels exist besides production. **A version range never resolves them** — a
dependency declared as `from: "2.1.0"` will never pick up a `-dev` or `-rc` build, so they
cannot reach you by accident. They have to be requested by name:

```swift
// a specific release candidate, for validating before it ships
.package(url: "…-spm.git", exact: "2.2.0-rc.3")

// the newest development build, for internal apps only
.package(url: "…-spm.git", branch: "develop")
```

`-rc` builds are candidates that passed QA. `-dev` builds are throwaway and carry no
guarantee at all.

## Reporting a problem

Include your **`Package.resolved`**. It records exactly which versions of the SDK and of
its dependencies your app resolved, which is the first thing needed to tell a real bug
apart from a combination outside the tested set.

Find it at:

```
YourApp.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved
```

`getVersion()` on the SDK returns the exact version of the binary you are running: it is
read from the framework bundle, not from a constant, so it cannot disagree with what was
published.

## Compatibility per release

Versions each release was **built against**, and the ranges a consumer may resolve.

| SDK | tvOS | IMA tvOS (built / allowed) | YouboraLib (built / allowed) |
|---|---|---|---|
| 2.1.0 | 15.0+ | 4.16.0 / `4.16.0 ..< 5.0.0` | 6.7.23 / `6.7.x` |

Anything outside these ranges is untested. A minor bump of a dependency is validated and
shipped in an SDK release rather than flowing through automatically, because that is where
behaviour changes have historically landed — Youbora 6.7, for instance, started reporting
recoverable playback stalls as fatal errors, which 6.3 ignored entirely.

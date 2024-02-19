# VersionedCodable ![main workflow](https://github.com/jrothwell/VersionedCodable/actions/workflows/swift.yml/badge.svg) [![Swift version compatibility](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fjrothwell%2FVersionedCodable%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/jrothwell/VersionedCodable) [![Swift platform compatibility](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fjrothwell%2FVersionedCodable%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/jrothwell/VersionedCodable)

A wrapper around Swift's [`Codable`](https://developer.apple.com/documentation/swift/codable) that allows you to version your `Codable` type, and facilitates incremental migrations from older versions. This handles a specific case where you want to be able to change the structure of a type, while retaining the ability to decode older versions of it.

You make your types versioned by making them conform to ``VersionedCodable/VersionedCodable``. Migrations take place on a step-by-step basis (i.e. v1 to v2 to v3) which reduces the maintenance burden of making potentially breaking changes to your types.

This is especially useful for document types where things regularly get added, refactored, and moved around.

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/jrothwell/VersionedCodable/main/Sources/VersionedCodable/VersionedCodable.docc/Resources/VersionedCodable%7Edark%402x.png">
  <source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/jrothwell/VersionedCodable/main/Sources/VersionedCodable/VersionedCodable.docc/Resources/VersionedCodable%402x.png">
  <img alt="Three type definitions next to each other: Poem, PoemV1, and PoemPreV1. Poem has a `static let version = 2` and has a reference to PoemV1 as its `PreviousVersion`. PoemV1's version is 1 and its PreviousVersion is PoemPreV1, whose version is nil. There's also an initializer that allows a PoemV1 to be initialized from a PoemPreV1, and a PoemV2 from a `PoemV1`." src="https://raw.githubusercontent.com/jrothwell/VersionedCodable/main/Sources/VersionedCodable/VersionedCodable.docc/Resources/VersionedCodable%402x.png">
</picture>


You can encode and decode using extensions for `Foundation`'s built-in JSON and property list encoders/decoders. It's also easy to add support to other encoders and decoders.

## Quick Start

**You will need:** Swift 5.7.1 or later.

**In a Swift package:** Add this line to your `Package.swift` file's dependencies section...

```swift
dependencies: [
    .package(url: "https://github.com/jrothwell/VersionedCodable.git", .upToNextMajor(from: "1.1.0"))
],
```

**Or open your project in Xcode,** pick "Package Dependencies," click "Add," and enter the URL for this repository. 

## Problem statement
For `Codable` types that change over time where you might need to continue to decode data in the old format, `VersionedCodable` allows you to make changes in a way where you can rationalise migrations.

Migrations happen on a step-by-step basis. That is, older versions of the type get decoded using their original decoding logic, then get transformed into successively newer types until we reach the target type.

For instance, say you've just finished refactoring your `Poem` type, which would now encode to this:

```json
{
    "version": 3,
    "author": "Anonymous",
    "poem": "An epicure dining at Crewe\nFound a rather large mouse in his stew",
    "rating": "love"
}
```


However, you might still need to be able to handle documents in an older version of the format...

```json
{
    "version": 2,
    "author": "Anonymous",
    "poem": "An epicure dining at Crewe\nFound a rather large mouse in his stew",
    "starRating": 4
}
```

...and ultimately, all you want is to be able to decode into your current type, which is this, so you can use it in your app:

```swift
struct Poem {
    var author: String
    var poem: String
    var rating: Rating
    
    enum Rating: String, Codable {
        case love, meh, hate
    }
}
```

## How to use it

You declare conformance to `VersionedCodable` like this:

```swift
extension Poem: VersionedCodable {
    // Specify the current version.
    // This will be the contents of the `version` field when you encode this
    // type. It also tells us on decoding that this type is capable of
    // decoding itself from an input with `"version": 3`.
    static let version: Int? = 3
    
    // The next oldest version of the `Poem` type.
    typealias PreviousVersion = PoemV2
    
    
    // Now we need to specify how to make a `Poem` from the previous version of the
    // type. For the sake of argument, we are replacing the numeric `starRating`
    // field with a "love/meh/hate" rating.
    init(from oldVersion: OldPoem) {
        self.author = oldVersion.author
        self.poem = oldVersion.poem
        switch oldVersion.starRating {
        case ...2:
            self.rating = .hate
        case 3:
            self.rating = .meh
        case 4...:
            self.rating = .love
        default: // the field is no longer valid in the new model, so we throw an error
            throw VersionedDecodingError.fieldNoLongerValid(
                DecodingError.Context(
                    codingPath: [CodingKeys.rating],
                    debugDescription: "Star rating \(oldVersion.starRating) is invalid")
        }
    }
}
```

The chain of previous versions of the type can be as long as the call stack will allow.

If you're converting an older type into a newer type and run across some data that means it no longer makes sense in the new data model, you can throw a `VersionedDecodingError.fieldNoLongerValid`.

For the earliest version of the type with nothing older to try decoding, you set `PreviousVersion` to `NothingEarlier`. This is necessary to make the compiler work. Any attempts to decode a type not covered by the chain of `VersionedCodable`s will throw a `VersionedDecodingError.unsupportedVersion(tried:)`.

```swift
struct PoemV1 {
    var author: String
    var poem: [String]
}

extension PoemOldVersion: VersionedCodable {
    static let version: Int? = 1
    
    typealias PreviousVersion = NothingEarlier
    // You don't need to provide an initializer here since you've defined `PreviousVersion` as `NothingEarlier.`
}
```

## Encoding and decoding
`VersionedCodable` provides thin wrappers around Swift's default `encode(_:)` and `decode(_:from:)` functions for both the JSON and property list decoders.

You decode a versioned type like this:

```swift
let decoder = JSONDecoder()
try decoder.decode(versioned: Poem.self, from: data) // where `data` contains your old poem
```

Encoding happens like this:
```swift
let encoder = JSONEncoder()
encoder.encode(versioned: myPoem) // where myPoem is of type `Poem` which conforms to `VersionedCodable`
```

## Testing
**It is a very good idea to write acceptance tests for decoding old versions of your types to act as a suite of confidence tests.** `VersionedCodable` provides the types to make this kind of migration easy, but you still need to think carefully about how you map fields between different versions of your types.

## Applications

This is mainly intended for situations where you are encoding and decoding complex types such as documents that live in storage somewhere (on someone's device's storage, in a document database, etc.) and can't all be migrated at once. In these cases, the format often changes, and decoding logic can often become unwieldy.

`VersionedCodable` was originally developed for use in [Unspool](https://unspool.app), a photo tagging app for MacOS which is not ready for the public yet.

### Hasn't this been Sherlocked by `SwiftData`?

Not really. [SwiftData](https://developer.apple.com/xcode/swiftdata/), new in iOS/iPadOS/tvOS 17, macOS 14, watchOS 10, and visionOS, is a Swifty interface over [Core Data](https://developer.apple.com/documentation/coredata). It does support schema versioning and has a number of ways to configure how you want your data persisted. It even works with `DocumentGroup`.

However, there are a few limitations to consider:
* `@Model` types have to be classes. This may not be appropriate if you want to use value types.
* `SwiftData` is part of the OS, and **not** part of Swift's standard library like `Codable` is. If you're intending to target non-Apple platforms, or OS versions earlier than the ones release in 2023, you'll find your code doesn't compile if it references `SwiftData`.

I encourage you to experiment and find the solution that works for you as well. But my current advice is:

* If you need a very lightweight way of versioning your `Codable` types and will handle persistence yourself, or if you need to version value types (`struct`s instead of `class`es)---consider `VersionedCodable`.
* If you're creating very complex types that have relations between them, and you don't need to worry about OS versions other than the newest Apple platforms as of this coming September/October time---consider `SwiftData`.

### Is there a version for Kotlin/Java/Android?
**No.** `VersionedCodable` is an open-source part of [Unspool](https://unspool.app), a photo tagging app for MacOS which will not have an Android version for the foreseeable future. I don't see why it *wouldn't* be feasible to do something similar in Kotlin, but I would caution that `VersionedCodable` relies heavily on Swift having a built-in encoding/decoding mechanism and an expressive type system. The JVM may make it difficult to achieve the same behaviour in the same way.

### We want to use this in our financial/medical/regulated app but need guarantees about security, provenance, non-infringement, etc.
Well, I must tell you that [under the terms of the MIT licence](LICENSE.md), `VersionedCodable` 'is provided "AS IS", without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose and noninfringement,' and 'in no event shall the authors or copyright holders be liable for any claim, damages or other liability, whether in an action of contract, tort or otherwise, arising from, out of or in connection with the software or the use or other dealings in the software.'

As a full-time engineer for whom `VersionedCodable` is a side project, I am not in a position to spend any time providing support, fulfilling adopters' regulatory or traceability requirements, or (e.g.) helping you compile your SBOM or SOUP list. You are, of course, welcome to fork it to create a "trusted version," or create your own solution inspired by it.

## Still Missing - Wish List

- [ ] Swift 5.9 Macros support to significantly reduce boilerplate
- [X] Allow different keypaths to the version field - **Implemented in version 1.1!**
- [ ] ~~(?) Potentially allow semantically versioned types. (This could be dangerous, though, as semantic versions have a very specific meaning—it's hard to see how you'd validate that v2.1 only adds to v2 and doesn't deprecate anything without some kind of static analysis, which is beyond the scope of `VersionedCodable`. It would also run the risk that backported releases to older versions would have no automatic migration path.)~~ Won't do because it increases the risk of diverging document versions with no guaranteed migration path when maintaining older versions of the system.

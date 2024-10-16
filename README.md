# VersionedCodable ![main workflow](https://github.com/jrothwell/VersionedCodable/actions/workflows/swift.yml/badge.svg) [![Swift version compatibility](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fjrothwell%2FVersionedCodable%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/jrothwell/VersionedCodable) [![Swift platform compatibility](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fjrothwell%2FVersionedCodable%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/jrothwell/VersionedCodable)

A wrapper around Swift's [`Codable`](https://developer.apple.com/documentation/swift/codable) that allows you to version your `Codable` type, and facilitates incremental migrations from older versions. This handles a specific case where you want to be able to change the structure of a type, while retaining the ability to decode older versions of it.

You make your types versioned by making them conform to ``VersionedCodable``. Migrations take place on a step-by-step basis (i.e. v1 to v2 to v3) which reduces the maintenance burden of making potentially breaking changes to your types.

This is especially useful for document types where things regularly get added, refactored, and moved around.

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/jrothwell/VersionedCodable/main/Sources/VersionedCodable/VersionedCodable.docc/Resources/VersionedCodable%7Edark%402x.png">
  <source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/jrothwell/VersionedCodable/main/Sources/VersionedCodable/VersionedCodable.docc/Resources/VersionedCodable%402x.png">
  <img alt="Three type definitions next to each other: Poem, PoemV1, and PoemPreV1. Poem has a `static let version = 2` and has a reference to PoemV1 as its `PreviousVersion`. PoemV1's version is 1 and its PreviousVersion is PoemPreV1, whose version is nil. There's also an initializer that allows a PoemV1 to be initialized from a PoemPreV1, and a PoemV2 from a `PoemV1`." src="https://raw.githubusercontent.com/jrothwell/VersionedCodable/main/Sources/VersionedCodable/VersionedCodable.docc/Resources/VersionedCodable%402x.png">
</picture>


You can encode and decode using extensions for `Foundation`'s built-in JSON and property list encoders/decoders. It's also easy to add support to other encoders and decoders. By default, the version key is encoded in the root of the `VersionedCodable` type: you can also specify your own version path if you need to.

## Quick Start

### You will need
* A functioning computer.
* Swift 5.7.1 or later.

> [!NOTE]
> **There is a problem with the current 1.2.x series and Swift 5.7-5.9.** This is tracked as [issue #24.](https://github.com/jrothwell/VersionedCodable/issues/24) please use the 1.1.x series if you are stuck on an older Swift version for now.

### What to do

**In a Swift package:** Add this line to your `Package.swift` file's dependencies section...

```swift
dependencies: [
    .package(url: "https://github.com/jrothwell/VersionedCodable.git", .upToNextMinor(from: "1.1.0"))
],
```

**Or: open your project in Xcode,** pick "Package Dependencies," click "Add," and enter the URL for this repository.

Read the [documentation for `VersionedCodable`, available on the Web here](https://jrothwell.github.io/VersionedCodable/documentation/versionedcodable/). If you use Xcode, it will also appear in the documentation browser.

## Problem statement
Some `Codable` types might change over time, but you may still need to decode data in the old format. `VersionedCodable` allows you to retain older versions of the type and decode them as if they were the current version, using step-by-step migrations.

Older versions of the type get decoded using their original decoding logic. They then get transformed into successively newer types until the decoder reaches the target type.

### Example

Say you've just finished refactoring your `Poem` type, which now looks like this:

```swift
struct Poem: Codable {
    var author: String
    var poem: String
    var rating: Rating
    
    enum Rating: String, Codable {
        case love, meh, hate
    }
}
```

Encoded as JSON, this would look like:

```json
{
    "version": 2,
    "author": "Anonymous",
    "poem": "An epicure dining at Crewe\nFound a rather large mouse in his stew",
    "rating": "love"
}
```

However, you might still need to be able to handle documents in an older version of the format, which look like this:

```json
{
    "version": 1,
    "author": "Anonymous",
    "poem": "An epicure dining at Crewe\nFound a rather large mouse in his stew",
    "starRating": 4
}
```

The original type might look like this:

```swift
struct OldPoem: Codable {
    var author: String
    var poem: String
    var starRating: Int
}
```

To decode and use existing `OldPoem` JSONs, you follow the following steps:

1. Make `OldPoem` conform to `VersionedCodable`. Set its `version` to 1, and its
   `PreviousVersion` to `NothingEarlier`.
2. Make `Poem` conform to `VersionedCodable`. Set its `version` to 2, and its
   `PreviousVersion` to `OldPoem`.
3. Define an initializer for `Poem` that accepts an `OldPoem`. Define how you'll
   transform your older type into the newer type.
4. In places where you decode JSON versions of `Poem`, update it to use the
   `VersionedCodable` extensions to `Foundation`.

## How to use it

You declare conformance to `VersionedCodable` like this:

```swift
extension Poem: VersionedCodable {
    // Declare the current version.
    // It tells us on decoding that this type is capable of decoding itself from
    // an input with `"version": 3`. It also gets encoded with this version key.
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

## Testing

**It is a very good idea to write acceptance tests that decode old versions of your types.** This will give you confidence that all your existing data still makes sense in your current data model, and that your migrations are doing the right thing.

`VersionedCodable` provides the infrastructure to make these kinds of migrations easy, but you still need to think carefully about how you map fields between different versions of your types. Type safety isn't a substitute for testing.

> [!TIP]
> This kind of logic is a great candidate for test driven development, since you already know what a successful input and output looks like.


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

## Applications

This is mainly intended for situations where you are encoding and decoding complex types such as documents that live in storage somewhere (on someone's device's storage, in a document database, etc.) and can't all be migrated at once. In these cases, the format often changes, and decoding logic can often become unwieldy.

`VersionedCodable` was originally developed for use in [Unspool](https://unspool.app), a photo tagging app for MacOS which is not ready for the public yet.

### Hasn't this been Sherlocked by `SwiftData`?

Not really. [SwiftData](https://developer.apple.com/xcode/swiftdata/), new in iOS/iPadOS/tvOS 17, macOS 14, watchOS 10, and visionOS, is a Swifty interface over [Core Data](https://developer.apple.com/documentation/coredata). It does support schema versioning and has a number of ways to configure how you want your data persisted. It even works with `DocumentGroup`.

However, there are a few limitations to consider:
* `@Model` types have to be classes. This may not be appropriate if you want to use value types.
* `SwiftData` is part of the OS, and **not** part of Swift's standard library like `Codable` is. If you're intending to target non-Apple platforms, or OS versions earlier than the ones released in 2023, you'll find your code doesn't compile if it references `SwiftData`.

I encourage you to experiment and find the solution that works for you. But my current suggestion is:

* If you need a very lightweight way of versioning your `Codable` types and will handle persistence yourself, or if you need to version value types (`struct`s instead of `class`es)---consider `VersionedCodable`.
* If you're creating very complex types that have relations between them, and you're only targeting Apple platforms including and after the 2023 major versions---consider `SwiftData`.

### Is there a version for Kotlin/Java/Android?
**No.** `VersionedCodable` is an open-source part of [Unspool](https://unspool.app), a photo tagging app for macOS which will not have an Android version for the foreseeable future. I don't see why it *wouldn't* be feasible to do something similar in Kotlin, but be warned that `VersionedCodable` relies heavily on Swift having a built-in encoding/decoding mechanism and an expressive type system. The JVM may make it difficult to achieve the same behaviour in a similarly safe and expressive way.

### We want to use this in our financial/medical/regulated app but need guarantees about security, provenance, non-infringement, etc.
Well, I must tell you that [under the terms of the MIT licence](LICENSE.md), `VersionedCodable` 'is provided "AS IS", without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose and noninfringement,' and 'in no event shall the authors or copyright holders be liable for any claim, damages or other liability, whether in an action of contract, tort or otherwise, arising from, out of or in connection with the software or the use or other dealings in the software.'

As a full-time software engineer and architect for whom `VersionedCodable` is a side project, I am not in a position to spend any time providing support, fulfilling adopters' regulatory or traceability requirements, or (e.g.) helping you compile your SBOM or SOUP list. You are, of course, welcome to fork it to create a "trusted version," or create your own solution inspired by it.

## Still Missing - Wish List

- [X] Allow different keypaths to the version field - **Implemented in version 1.1!**
- [ ] Some kind of type solution to prevent clashes between the version field and a field in the `VersionedCodable` type at compile time. Needs more research, may not be possible with the current Swift compiler.
- [ ] ~~Swift 5.9 Macros support to significantly reduce boilerplate~~ - *likely to be a separate package, probably not necessary for most adopters*
- [ ] ~~(?) Potentially allow semantically versioned types. (This could be dangerous, though, as semantic versions have a very specific meaning—it's hard to see how you'd validate that v2.1 only adds to v2 and doesn't deprecate anything without some kind of static analysis, which is beyond the scope of `VersionedCodable`. It would also run the risk that backported releases to older versions would have no automatic migration path.)~~ Won't do because it increases the risk of diverging document versions with no guaranteed migration path when maintaining older versions of the system.

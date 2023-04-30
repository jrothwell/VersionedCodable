# VersionedCodable ![main workflow](https://github.com/jrothwell/VersionedCodable/actions/workflows/swift.yml/badge.svg)

A wrapper around Swift's [`Codable`](https://developer.apple.com/documentation/swift/codable) that allows you to version your `Codable` type, and facilitates incremental migrations from older versions. This handles a specific case where you want to be able to change the structure of a type, while retaining the ability to decode older versions of it and reason about what has changed with each version.

Migrations happen on a step-by-step basis. That is, older versions of the type get decoded using their original decoding logic, then get transformed into successively newer types until we reach the target type. (e.g. if we have a v1 document and we want a v3 type, we decode using the v1 type, then transform to v2, then to v3.)

You can encode and decode using extensions for `Foundation`'s built-in JSON and property list encoders/decoders. It's also easy to add support to other encoders and decoders.

## Quick Start

**You will need:** Swift 5.7.1 or later.

**In a Swift package:** Add this line to your `Package.swift` file's dependencies section...

```swift
dependencies: [
    .package(url: "https://github.com/jrothwell/VersionedCodable", from: "1.0.0"),
],
```

**Or open your project in Xcode,** pick "Package Dependencies," click "Add," and enter the URL for this repository. 

## Problem statement
`VersionedCodable` deals with a very specific use case where there is a `version` key in the encoded object, and it is a sibling of other keys in the object. For example, this:

```json
{
    "version": 2,
    "author": "Anonymous",
    "poem": "An epicure dining at Crewe\nFound a rather large mouse in his stew\nCried the waiter: Don't shout\nAnd wave it about\nOr the rest will be wanting one too!"
}
```

```

However, you might still need to be able to handle documents in an older version of the format...

```json
{
    "version": 1,
    "author": "Anonymous",
    "poem": [
        "An epicure dining at Crewe",
        "Found a rather large mouse in his stew",
        "Cried the waiter: Don't shout",
        "And wave it about",
        "Or the rest will be wanting one too!"
    ]
}
```

...and ultimately, all you want is to be able to decode into your current type, which is this, so you can use it in your app:

```swift
struct Poem {
    var author: String
    var poem: String
}


## How to use it

You declare conformance to `VersionedCodable` like this:

```swift
extension Poem: VersionedCodable {
    // Specify the current version.
    // This will be the contents of the `version` field when you encode this
    // type. It also tells us on decoding that this type is capable of
    // decoding itself from an input with `"version": 2`.
    static let version: Int? = 2
    
    // The next oldest version of the `Poem` type.
    typealias PreviousVersion = PoemOldVersion
    
    
    // Now we need to specify how to make a `Poem` from the old version of the
    // type. For the sake of argument: `PoemOldVersion` has an array of `[String]` 
    // rather than one big blob separated by newlines, so we need to account for
    // this.
    init(from old: PoemOldVersion) throws {
        self.author = old.author
        self.poem = poem.joined(separator: "\n")
    }
}
```

The chain of previous versions of the type can be as long as the call stack will allow.

For the oldest version of the type with nothing older, you set `PreviousVersion` to `NothingOlder`. This is necessary to make the compiler work. Any attempts to decode a type not covered by the chain of `VersionedCodable`s will throw a `VersionedDecodingError.noOlderVersionAvailable`.

```swift
struct PoemOldVersion {
    var author: String
    var poem: [String]
}

extension PoemOldVersion: VersionedCodable {
    static let version: Int? = 1
    
    typealias PreviousVersion = NothingOlder
    // You don't need to provide an initializer here since you've defined `PreviousVersion` as `NothingOlder.`
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

## Still Missing - Wish List

- [ ] Allow different keypaths to the version field
- [ ] ~~(?) Potentially allow semantically versioned types. (This could be dangerous, though, as semantic versions have a very specific meaning—it's hard to see how you'd validate that v2.1 only adds to v2 and doesn't deprecate anything without some kind of static analysis, which is beyond the scope of `VersionedCodable`. It would also run the risk that backported releases to older versions would have no automatic migration path.)~~ Won't do because it increases the risk of diverging document versions with no guaranteed migration path when maintaining older versions of the system.

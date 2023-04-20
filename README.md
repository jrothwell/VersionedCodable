# VersionedCodable ![main workflow](https://github.com/jrothwell/VersionedCodable/actions/workflows/swift.yml/badge.svg)

A wrapper around Swift's [`Codable`](https://developer.apple.com/documentation/swift/codable) that allows you to version your `Codable` type, and facilitates incremental migrations from older versions.

Migrations take place on a step-by-step basis (i.e. v1 to v2 to v3) which reduces the maintenance burden of making potentially breaking changes to your types. This is especially useful for document types where things get added, refactored, and moved around.

⚠️ **Danger:** ``VersionedCodable`` is still under active development and the API has not stabilised yet. It should be safe to use, but please be careful if you include it in your production projects.

Currently, only encoding and decoding using the built-in JSON and property list encoders/decoders are supported. You use an extension with the signature `decode(versioned:from:)` to decode, and `encode(versioned:)` to encode.

## Problem statement
`VersionedCodable` deals with a very specific use case where there is a `version` key in the encoded object, and it is a sibling of other keys in the object. For example, this:

```json
{
    "version": 2,
    "author": "Anonymous",
    "poem": "An epicure dining at Crewe\nFound a rather large mouse in his stew\nCried the waiter: Don't shout\nAnd wave it about\nOr the rest will be wanting one too!"
}
```

...would be a representation of this:

```swift
struct Poem {
    var author: String
    var poem: String
}
```


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

You can have as many previous versions of the type as the call stack will allow.

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
**It is a very good idea to write unit tests for decoding old versions of your types to act as a suite of confidence tests.** `VersionedCodable` provides the types to make this kind of migration easy, but you still need to think carefully about how you map fields between different versions of your types.

## Applications

This is mainly intended for situations where you are encoding and decoding complex types such as documents that live in storage somewhere (on someone's device's storage, in a database, etc.) In these cases, the format often changes, and decoding logic can often become unwieldy.

`VersionedCodable` was originally developed for use in [Unspool](https://unspool.app), a photo tagging app for MacOS which is not ready for the public yet.

## Still Missing - Wish List

- [X] Add support for property lists
- [ ] Extend `Encoder` and `Decoder` to be able to deal with things other than JSON and property lists---may be difficult since not all encoders behave in the same way. May also require some kind of wrapper type since you can't override *and* delegate to the default implementation at the same time.
- [ ] (?) Potentially allow different keypaths to the version field
- [ ] (?) Potentially allow semantically versioned types. (This could be dangerous, though, as semantic versions have a very specific meaning—it's hard to see how you'd validate that v2.1 only adds to v2 and doesn't deprecate anything without some kind of static analysis, which is beyond the scope of `VersionedCodable`. It would also run the risk that backported releases to older versions would have no automatic migration path.)

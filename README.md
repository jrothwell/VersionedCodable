# VersionedCodable

A wrapper around Swift's [`Codable`](https://developer.apple.com/documentation/swift/codable) that allows you to version your `Codable` type, and rationalise and reason about migrations from older versions of the type. This is especially useful for document types where things often move around.

**Danger!** This is not stable yet! Please think twice before using this in your important production projects.

Specifically, `VersionedCodable` deals with a very specific use case where there is a `version` key in the encoded object, and it is a sibling of other keys in the object. For example, this:

```json
{
    "version": 1,
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

You declare conformance to `VersionedCodable` like this:

```swift
extension Poem: VersionedCodable {
    static let thisVersion: Int? = 2
    
    typealias PreviousVersion = PoemOldVersion
    init(from old: PoemOldVersion) throws {
        self.author = old.author
        self.poem = poem.joined(separator: "\n")
    }
}
```

You can have as many previous versions as the call stack will allow. When you've reached the oldest version and there are no previous versions of the type to try decoding, you make the compiler work and tell the decoder to stop and throw an error by doing this:

```swift
struct PoemOldVersion {
    var author: String
    var poem: [String]
}

extension PoemOldVersion: VersionedCodable {
    static let thisVersion: Int? = 1
    
    typealias PreviousVersion = NothingOlder
    // You don't need to provide an initializer here since you've defined `PreviousVersion` as `NothingOlder.`
}
```

## Encoding and decoding
`VersionedCodable` provides thin wrappers around Swift's default `JSONEncoder.encode(_:)` and `JSONDecoder.decode(_:from:)` functions.

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
**It is a very good idea to write unit tests that confidence check that you can continue to decode old versions of your types.** `VersionedCodable` provides the types to make this kind of migration easy, but you still need to think carefully about how you map fields between different versions of your types.

## Applications

This is mainly intended for situations where you are encoding and decoding complex types such as documents that live in storage somewhere (on someone's device's storage, in a database, etc.) In these cases, the format often changes, and decoding logic can often become unwieldy.

`VersionedCodable` was originally developed for use in [Unspool](https://unspool.app), a photo tagging app for MacOS which is not ready for the public yet.

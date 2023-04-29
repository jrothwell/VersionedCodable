# ``VersionedCodable``

A wrapper around Swift's `Codable` that allows you to version your `Codable` type, and facilitate incremental migrations from older versions.

This handles a specific case where you want to be able to change the structure of a type, while retaining the ability to decode older versions of it. It encodes a version number for the type as a sibling to the other fields, e.g.

```json
{
  "version": 1,
  "author": "Anonymous",
  "poem": "An epicure dining at Crewe\\nFound a rather large mouse in his stew\\nCried the waiter: Don't shout\\nAnd wave it about\\nOr the rest will be wanting one too!"
}
```

The version number is completely transparent at the point of use. You don't need to worry about it and shouldn't try to set it manually.

## Making your types versioned
You make your type versioned by making it conform to ``VersionedCodable``. This inherits from `Codable` and adds new requirements where you specify:

- The current version number of the type (``VersionedCodable/version``.) Note that this may be `nil`.
- What the type of the *previous* version is (``VersionedCodable/PreviousVersion``.) If you're using the oldest version, you set this to ``NothingEarlier``.
- An initializer for the current type which accepts the previous version of the type.


## Decoding a versioned type
``VersionedCodable`` provides extensions to Foundation's built-in `JSONDecoder` and `PropertyListDecoder` types to allow you decode these out of the box, like this:

```swift
let poem = try JSONDecoder().decode(versioned: Poem.self, from: oldPoem)
```

For other kinds of encoders and decoders you need to do a little more work, but not much. Define an extension on your decoder type to use ``VersionedCodable``'s logic to determine which type to decode:

```swift
extension HyperCardDecoder {
    public func decode<ExpectedType: VersionedCodable>(
        versioned expectedType: ExpectedType.Type,
        from data: Data) throws -> ExpectedType {
            try ExpectedType.decodeTransparently(from: data,
                                                 using: { try self.decode($0, from: $1) }) // delegate to your normal decoding logic
    }
}
```

## Encoding a versioned type

When encoding, the version is always encoded as `version` at the top level. It is encoded **after** the other keys in the `Encodable`.

```swift
let data = try JSONEncoder().encode(versioned: poem)
```

Again, for encoders and decoders that aren't the built-in `JSONEncoder` and `PropertyListDecoder`, define this extension:

```swift
extension HyperCardEncoder {
    public func encode(versioned value: any VersionedCodable) throws -> Foundation.Data {
        try value.encodeTransparently { try self.encode($0) } // again, delegate to your normal encoding logic
    }
}
```

(Internally this uses your encoding function to encode a wrapper type, which encodes all the keys of your contained type followed by a `version` key. But you don't need to create this yourself.)

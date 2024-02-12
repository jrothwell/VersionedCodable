# ``VersionedCodable``

A wrapper around Swift's `Codable` that lets you version your types, and facilitates migrations from older versions.

You make your types versioned by making them conform to ``VersionedCodable/VersionedCodable``. Migrations take place on a step-by-step basis (i.e. v1 to v2 to v3) which reduces the maintenance burden of making potentially breaking changes to your types.

This is especially useful for document types where things regularly get added, refactored, and moved around.

### Encoding and decoding

Decode and encode using the version-aware extensions to `Foundation`'s built-in property list encoders and decoders, or by extending your own decoders using ``VersionedCodable/VersionedCodable/decodeTransparently(from:using:)`` and ``VersionedCodable/VersionedCodable/encodeTransparently(using:)``.

The version number is transparent at the point of use. You don't need to worry about it and shouldn't try to set it manually.

### Behaviour

By default, it encodes a version number for the type as a sibling to the other fields:

```json
{
  "version": 1,
  "author": "Anonymous",
  "poem": "An epicure dining at Crewe\\nFound a rather large mouse in his stew"
}
```

If this behaviour is not acceptable, you can implement ``VersionPathSpec`` to customise where the version number is encoded and decoded.

### Testing

It's a very good idea to write acceptance tests for decoding old versions of your types.

``VersionedCodable/VersionedCodable`` provides the types and logic to make this kind of migration easy, **but** you still need to think carefully about how you map fields between different versions of your types.

A comprehensive set of test cases will give you confidence that:

* you can still decode earlier versions of documents
* what comes out of them is what you expect

- Tip: This kind of encoding and decoding logic is a great candidate for test driven development.

## Topics

### Essentials
- <doc:GettingStarted>
- ``VersionedCodable/VersionedCodable``

### Version field specifications
- ``VersionPathSpec``
- ``VersionKeyAtRootVersionPathSpec``
- ``VersionedCodable/VersionedCodable/VersionSpec``

### Handling Errors
- ``VersionedEncodingError``
- ``VersionedDecodingError``
- ``NothingEarlier``

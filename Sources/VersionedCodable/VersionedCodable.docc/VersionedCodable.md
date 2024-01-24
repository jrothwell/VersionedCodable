# ``VersionedCodable``

A wrapper around Swift's `Codable` that lets you version your types, and facilitates migrations from older versions.

This handles a specific case where you want to be able to change the structure of a type, while retaining the ability to decode older versions of it and reason about what has changed with each version.

It encodes a version number for the type as a sibling to the other fields, e.g.

```json
{
  "version": 1,
  "author": "Anonymous",
  "poem": "An epicure dining at Crewe\\nFound a rather large mouse in his stew"
}
```

You make your types versioned by making them conform to ``VersionedCodable/VersionedCodable``. Migrations take place on a step-by-step basis (i.e. v1 to v2 to v3) which reduces the maintenance burden of making potentially breaking changes to your types. This is especially useful for document types where things regularly get added, refactored, and moved around.

Decode and encode using the version-aware extensions to `Foundation`'s built-in property list encoders and decoders, or by extending your own decoders using ``VersionedCodable/VersionedCodable/decodeTransparently(from:using:)`` and ``VersionedCodable/VersionedCodable/encodeTransparently(using:)``.

The version number is transparent at the point of use. You don't need to worry about it and shouldn't try to set it manually.

- Tip: It is a very good idea to write acceptance tests that test you can decode old versions of your types. ``VersionedCodable/VersionedCodable`` provides the types and logic to make this kind of migration easy, **but** you still need to think carefully about how you map fields between different versions of your types. A comprehensive set of test cases will give you confidence that you can still decode earlier versions of documents, **and** that what comes out of them is what you expect.

## Topics

### Essentials
- <doc:GettingStarted>
- ``VersionedCodable/VersionedCodable``

### Handling unusual locations for version fields
- ``VersionPathSpec``
- ``VersionKeyAtRootVersionPathSpec``
- ``VersionedCodable/VersionedCodable/VersionSpec``

### Handling Errors
- ``VersionedEncodingError``
- ``VersionedDecodingError``
- ``NothingEarlier``

# ``VersionedCodable``

A wrapper around Swift's `Codable` that lets you version your `Codable` type, and facilitates migrations from older versions.

This handles a specific case where you want to be able to change the structure of a type, while retaining the ability to decode older versions of it. It encodes a version number for the type as a sibling to the other fields, e.g.

```json
{
  "version": 1,
  "author": "Anonymous",
  "poem": "An epicure dining at Crewe\\nFound a rather large mouse in his stew\\nCried the waiter: Don't shout\\nAnd wave it about\\nOr the rest will be wanting one too!"
}
```

You make your types versioned by making them conform to ``VersionedCodable/VersionedCodable``.

Decode and encode using the version-aware extensions to `Foundation`'s built-in property list encoders and decoders, 

The version number is transparent at the point of use. You don't need to worry about it and shouldn't try to set it manually.

## Topics

### Essentials
- <doc:GettingStarted>
- ``VersionedCodable/VersionedCodable``

### Handling Errors
- ``VersionedEncodingError``
- ``VersionedDecodingError``
- ``NothingEarlier``

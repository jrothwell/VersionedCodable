# ``VersionedCodable``

A wrapper around Swift's `Codable` that allows you to version your `Codable` type, and facilitate incremental migrations from older versions.

This handles a specific case where you want to save a document version number as a sibling to the other fields in your encoded type, e.g.

```json
{
  "version": 1,
  "author": "Anonymous",
  "poem": "An epicure dining at Crewe\\nFound a rather large mouse in his stew\\nCried the waiter: Don't shout\\nAnd wave it about\\nOr the rest will be wanting one too!"
}
```

- Important: ``VersionedCodable`` is still under active development and the API has not stabilised yet. It should be safe to use, but please be careful if you include it in your production projects.

- Note: Currently, the only supported ways of coding a ``VersionedCodable`` are using Foundation's built-in `JSONDecoder`/`JSONEncoder` and `PropertyListDecoder`/`PropertyListEncoder`. This may change in future but this is the situation for now.

You make your type versioned by making it conform to ``VersionedCodable``. This inherits from `Codable` and adds new requirements where you specify:

- The current version number of the type
- What the type of the *previous* version is
- An initializer for the current type which accepts the previous version

This means that when you decode a JSON document or a property list with `decode(versioned:from:)` it will keep moving back along the chain of versions until it finds one that matches the document. It decodes to the current type, effectively performing an in-memory incremental migration.

For the earliest version, you define its previous version as the special type ``NothingEarlier``. If we get to this stage during decoding, a special error ``VersionedDecodingError/unsupportedVersion(tried:)`` is thrown.

When encoding, the version is always encoded as `version` at the top level. It is encoded **after** the other keys in the `Encodable`.


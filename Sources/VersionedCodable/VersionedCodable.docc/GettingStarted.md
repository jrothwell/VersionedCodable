# Getting Started

Make a `Codable` type conform to ``VersionedCodable/VersionedCodable``, build a new version to try an incremental migration, and learn to encode and decode it.

## Overview

Some `Codable` types might change over time, but you may still need to decode data in the old format. `VersionedCodable` allows you to retain older versions of the type and decode them as if they were the current version, using step-by-step migrations.

Older versions of the type get decoded using their original decoding logic. They then get transformed into successively newer types until the decoder reaches the target type.

![Three type definitions next to each other: Poem, PoemV1, and PoemPreV1. Poem has a `static let version = 2` and has a reference to PoemV1 as its `PreviousVersion`. PoemV1's version is 1 and its PreviousVersion is PoemPreV1, whose version is nil. There's also an initializer that allows a PoemV1 to be initialized from a PoemPreV1, and a PoemV2 from a `PoemV1`.](VersionedCodable.png)

* When you encode a ``VersionedCodable/VersionedCodable`` type using the extensions on the `Foundation` encoders or using ``VersionedCodable/VersionedCodable/encodeTransparently(using:)``, it encodes an additional `version` key (by default, at the root of the type as a sibling to the other keys.) This matches the value of ``VersionedCodable/VersionedCodable/version``.
* When you decode a type in the using the extensions on the `Foundation` decoders or using ``VersionedCodable/VersionedCodable/decodeTransparently(from:using:)``, it checks to see if the ``VersionedCodable/VersionedCodable/version`` property of the type matches the `version` field in the data it wants to decode.
   * **If it matches,** then it decodes the type in the usual way.
   * **If it doesn't match, it then checks ``VersionedCodable/VersionedCodable/PreviousVersion``.** If the previous type's ``VersionedCodable/VersionedCodable/version`` matches the `version` key of the data, it decodes it, and then converts this into the current type using the initializer you provide as part of ``VersionedCodable/VersionedCodable`` conformance.
   * **If ``VersionedCodable/VersionedCodable/PreviousVersion`` is ``NothingEarlier``, it cannot decode the type** because this *is* the earliest possible version. It throws a ``VersionedDecodingError/unsupportedVersion(tried:)``.

## Making your types versioned
You make your type versioned by making it conform to ``VersionedCodable/VersionedCodable``. This inherits from `Codable` and adds new requirements where you specify:

- The current version number of the type (``VersionedCodable/VersionedCodable/version``.) This may be `nil`, to account for cases where you need to decode examples from before you adopted ``VersionedCodable``.
- What the type of the *previous* version is (``VersionedCodable/PreviousVersion``.) If you're using the oldest version, you set this to ``NothingEarlier``.
- An initializer for the current type which accepts the previous version of the type.
- *(optionally)* a specification for where to encode and decode the version key (``VersionedCodable/VersionedCodable/VersionSpec``.) By default, it assumes you have a `version` key at the root of the type. If necessary, you customise this behaviour by providing your own implementation of ``VersionPathSpec``.

Consider a `Poem` type which we want to change, which currently looks like this:

```swift
struct Poem: Codable {
    var author: String
    var poem: String
    var starRating: Int
}
```

### Adding VersionedCodable conformance to an existing type

You conform to ``VersionedCodable/VersionedCodable`` by specifying:

- ``VersionedCodable/VersionedCodable/version``: `nil` in this case, since our existing Poems don't have a `version` key
- ``VersionedCodable/VersionedCodable/PreviousVersion``: Since this *is* the oldest version of the type, this is ``NothingEarlier``.
    - Since there is no earlier version, you don't need to provide an initializer from ``NothingEarlier`` (this wouldn't make sense anyway.)

So an extension might look like this:

```swift
extension Poem: VersionedCodable {
    static let version: Int? = nil
    typealias PreviousVersion = NothingEarlier
}
```

You can now decode and encode the type using the versioned extensions to Foundation's built-in encoders and decoders.

### Creating a new version of the type
Now let's say our product owner has decided that we don't want to use star ratings any more. Instead we want to have a love/hate/neutral field. If there are any star ratings outside the 0...5 range, that's now considered invalid, so trying to decode this will produce an error.

Let's start by making a copy of our existing type, calling it `OldPoem`, making it `private`, and putting it out of the way:

```swift
private struct OldPoem: VersionedCodable {
    static let version: Int? = nil
    typealias PreviousVersion = NothingEarlier

    var author: String
    var poem: String
    var starRating: Int
}
```

Now let's change our existing type to fit our new requirement:

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

Now you need to:
* increment the version number (let's set it to 1)
* indicate that `OldPoem` is the previous version of `Poem`
* provide an initializer for `Poem` that accepts an `OldPoem`---doing the necessary transformation on `rating`

```swift
extension Poem: VersionedCodable {
    static let version: Int? = 1
    typealias PreviousVersion = OldPoem

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
        default: // the field is no longer valid
            throw VersionedDecodingError.fieldNoLongerValid(
                DecodingError.Context(
                    codingPath: [CodingKeys.rating],
                    debugDescription: "Star rating \(oldVersion.starRating) is invalid")
        }
    }
}
```

## About testing

It is a very good idea to write acceptance tests that decode old versions of your types. ``VersionedCodable/VersionedCodable`` provides the types and logic to make this kind of migration easy, **but** you still need to think carefully about how you map fields between different versions of your types. Type safety isn't a substitute for testing.

A comprehensive set of test cases will give you confidence that:
- you can still decode earlier versions of documents
- what comes out of them is what you expect.

- Tip: Although we haven't used it in this example, this kind of encoding and decoding logic is a great candidate for test driven development.

## Decoding a versioned type
``VersionedCodable`` provides extensions to Foundation's built-in `JSONDecoder` and `PropertyListDecoder` types to allow you decode these out of the box, like this:

```swift
let poem = try JSONDecoder().decode(versioned: Poem.self, from: oldPoem)
```

## Encoding a versioned type

When encoding, the version key is encoded **after** the other keys in the `Encodable`.

```swift
let data = try JSONEncoder().encode(versioned: poem)
```

- Warning: ``VersionedCodable`` can't guarantee at compile or run time that there isn't a clashing `version` field on the type you're encoding. It is your responsibility to make sure there is no clash. Don't try to set the version number of an instance manually. The behaviour is undefined if you do so.

## Decoding and encoding things other than JSON and property lists

For other kinds of encoders and decoders you need to do a little more work, but not much. Define an extension on your decoder type to use ``VersionedCodable``'s logic to determine which type to decode:

```swift
extension MagneticTapeDecoder {
    public func decode<ExpectedType: VersionedCodable>(
        versioned expectedType: ExpectedType.Type,
        from data: Data) throws -> ExpectedType {
            try ExpectedType.decodeTransparently(
                from: data,
                using: { try self.decode($0, from: $1) }) // delegate decoding to your decoder's usual logic
    }
}
```

And for the encoder, you need to define this extension:

```swift
extension MagneticTapeEncoder {
    public func encode(versioned value: any VersionedCodable) throws -> Foundation.Data {
        try value.encodeTransparently { try self.encode($0) } // delegate encoding to your encoder's usual logic
    }
}
```

Internally this uses your encoding function to encode a wrapper type, which encodes all the keys of your contained type followed by the `version` key. But you don't need to define this logic yourself.

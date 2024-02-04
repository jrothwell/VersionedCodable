# ``VersionPathSpec``

@Metadata {
    @Available("VersionedCodable", introduced: "1.1")
}

## Overview

Specifies how the coder will encode and decode versions of your ``VersionedCodable/VersionedCodable`` type.

By default, the encoder and decoder will use ``VersionKeyAtRootVersionPathSpec``, which will expect a `version` field at the root of the type.

If you need to customise this behaviour, you can create a custom implementation of ``VersionPathSpec``:

1. Create a `Codable` type in the usual way and make it conform to ``VersionPathSpec``.
2. Implement ``VersionPathSpec/keyPathToVersion``, specifying the `KeyPath` where the version field can be found.

## Example

Consider a document in this format:

```json
{
    "recipeTitle": "Potato dauphinoise",
    "_metadata": {
        "lastModifiedBy": "Sophie",
        "version": 2
    }
}
```

You start by implementing `Codable` in the usual way:

```swift
struct RecipeV2: Codable {
    var recipeTitle: String
    var lastModifiedBy: String

    struct RawRecipeV2: Codable {
        var recipeTitle: String
        var _metadata: Metadata

        struct Metadata: Codable {
            var lastModifiedBy: String
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawRecipe = try container.decode(RawRecipeV2.self)
        self.recipeTitle = rawRecipe.recipeTitle
        self.lastModifiedBy = rawRecipe._metadata.lastModifiedBy
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(
            RawRecipeV2(recipeTitle: self.recipeTitle,
                        _metadata: .init(lastModifiedBy: self.lastModifiedBy))
        )
    }
}
```

Now you create a **second** `Codable` type detailing how to encode the version, and the version **only**. Make this conform to ``VersionPathSpec``.

```swift
private struct RecipeV2VersionPath: VersionPathSpec {
    static let keyPathToVersion: KeyPath<RecipeV2VersionPathSpec, Int?> = \Self._metadata.version
    
    let _metadata: Metadata
    struct Metadata: Codable {
        var version: Int?
    }

    init(withVersion version: Int?) {
        self._metadata = Metadata(version: version)
    }
} 
```

Now you need to conform your original type to ``VersionedCodable``:

```swift
extension RecipeV2: VersionedCodable {
    static let version: Int? = 2
    typealias PreviousVersion = RecipeV1

    typealias VersionSpec = RecipeV2VersionPath
}
```

- Warning: ``VersionedCodable`` can't guarantee at compile or run time that there isn't a clashing version field on the type on which any ``VersionPathSpec`` is used. As always, the version number is transparent at the point of use---you should not try to set it manually.


## Topics
- ``VersionPathSpec/keyPathToVersion``

## See Also
- ``VersionKeyAtRootVersionPathSpec``

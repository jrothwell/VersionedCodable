//
//  VersionedDocumentSpecification.swift
//
//
//  Created by Jonathan Rothwell on 23/01/2024.
//

import Foundation

/// Describes how to decode or encode the version of a ``VersionedCodable`` type.
///
/// # Discussion
/// This allows you to execute versioned encodes and decodes on types where, for whatever reason,
/// the default behaviour (as specified in ``VersionKeyAtRootVersionPathSpec``) is not acceptable,
/// and the version needs to live somewhere else.
public protocol VersionPathSpec: Codable {
    /// The key path to the version of this type. Used to find the version key during decoding.
    static var keyPathToVersion: KeyPath<Self, Int?> { get }
    
    /// Initializes the type with the provided version.
    /// - Parameter version: The version of the document being encoded.
    /// - Note: Generally you will not need to initialize this directly.
    init(withVersion version: Int?)
}

/// Describes how to encode and decode the version of a ``VersionedCodable`` type where the
/// version key is encoded at the root of the type in a field called `version`.
///
/// Describes a versioned codable type where the version field is called `version` and lives at the root
/// of the document. For example:
///
/// ```json
/// {
///   "name": "Charlie Smith",
///   "version": 1
/// }
/// ```
///
/// # Discussion
/// This is the default behaviour of ``VersionedCodable``. If you are creating a new type,
/// you might want to adopt this behaviour, which requires no additional work over just conforming your
/// type to ``VersionedCodable`` in the usual way.
public struct VersionKeyAtRootVersionPathSpec: Codable, VersionPathSpec {
    public static let keyPathToVersion: KeyPath<VersionKeyAtRootVersionPathSpec, Int?> = \Self.version
    public init(withVersion version: Int? = nil) {
        self.version = version
    }
    
    var version: Int?
}



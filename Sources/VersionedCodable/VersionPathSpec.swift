//
//  VersionPathSpec.swift
//
//
//  Created by Jonathan Rothwell on 23/01/2024.
//

import Foundation

/// Describes how to decode or encode the version of a ``VersionedCodable`` type.
public protocol VersionPathSpec: Codable {
    /// The key path to the version of this type. Used to find the version key during decoding.
    ///
    /// Generally you declare this as a `static let`, for instance, like this:
    ///
    /// ```swift
    /// static let keyPathToVersion = \Self.metadata.version
    /// ```
    /// - Important: It is your responsibility to make sure that `keyPathToVersion` is immutable
    ///   and does not change. The behaviour if it does change mid-execution is undefined. It's not a good
    ///   idea to declare `keyPathToVersion` as a computed property, or a `var` which the caller
    ///   can then change. Nor should you capture the `KeyPath` and mutate it elsewhere.
    nonisolated(unsafe) static var keyPathToVersion: KeyPath<Self, Int?> { get }
    
    /// Initializes the type with the provided version.
    /// - Parameter version: The version of the document being encoded.
    /// - Note: Generally you will not need to initialize this directly.
    init(withVersion version: Int?)
}

/// Describes how to encode and decode the version of a ``VersionedCodable`` type where the version is encoded at the root of the type in a field called `version`.
public struct VersionKeyAtRootVersionPathSpec: Codable, VersionPathSpec {
    public static let keyPathToVersion: KeyPath<VersionKeyAtRootVersionPathSpec, Int?> = \Self.version
    public init(withVersion version: Int? = nil) {
        self.version = version
    }
    
    var version: Int?
}



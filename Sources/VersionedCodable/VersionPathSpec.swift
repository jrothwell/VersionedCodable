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
    static var keyPathToVersion: KeyPath<Self, Int?> { get }
    
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



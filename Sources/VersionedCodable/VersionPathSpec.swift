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
    /// - Warning: It is your responsibility to guarantee this key path does not change during decoding.
    ///   Typically you achieve this by making the value immutable (i.e. a `let` as opposed to a `var`.)
    // TODO: 11/06/2024 - Write a test to attempt to make this break concurrency in some way & then work around it.
    nonisolated(unsafe) static var keyPathToVersion: KeyPath<Self, Int?> { get }
    
    /// Initializes the type with the provided version.
    /// - Parameter version: The version of the document being encoded.
    /// - Note: Generally you will not need to initialize this directly.
    init(withVersion version: Int?)
}

/// Describes how to encode and decode the version of a ``VersionedCodable`` type where the version is encoded at the root of the type in a field called `version`.
public struct VersionKeyAtRootVersionPathSpec: Codable, VersionPathSpec {
    nonisolated(unsafe) public static let keyPathToVersion: KeyPath<Self, Int?> = \Self.version
    public init(withVersion version: Int? = nil) {
        self.version = version
    }
    
    let version: Int?
}



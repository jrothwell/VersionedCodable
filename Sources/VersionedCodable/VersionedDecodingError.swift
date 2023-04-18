//
//  VersionedDecodingError.swift
//  
//
//  Created by Jonathan Rothwell on 18/04/2023.
//

import Foundation

/// A problem that occurs during the decoding of a ``VersionedCodable``.
/// - Note: The decoding of a ``VersionedCodable`` can also result in the same kinds of errors
///   that are thrown during the decoding of any other `Codable`.
public enum VersionedDecodingError: Error {
    
    /// A field that was optional is no longer , such that this value no longer makes any sense in
    /// the newer version of the ``VersionedCodable``.
    ///
    /// Used in `VersionedCodable.init(from: PreviousVersion)`.
    case fieldNoLongerValid
    
    /// There is no previous version available to attempt decoding, so this type cannot be decoded.
    /// - Parameter than: The current ``VersionedCodable`` type.
    case unsupportedVersion(than: any VersionedCodable.Type)
}

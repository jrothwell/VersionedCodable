//
//  VersionedEncodingError.swift
//  
//
//  Created by Jonathan Rothwell on 22/04/2023.
//

import Foundation

/// A problem that occurs during the encoding of a ``VersionedCodable``.
/// - Note: The encoding of a ``VersionedCodable`` can also result in the same kinds of errors
///   that are thrown during the encoding of any other `Codable`.
public enum VersionedEncodingError: Error {
    
    /// Occurs when the type we are trying to encode has a property called `version`.
    ///
    /// This is an error because this it can and will be overridden by the current value of
    /// ``VersionedCodable/version``.  You should not try to set the contents of the
    /// `version` field in your document yourself.
    /// - Tip: If you absolutely **must** encode an old version of your type (e.g. for compatibility reasons),
    ///   encode that type directly. Don't try to manually set the contents of the `version` field.
    case typeHasClashingVersionField
}

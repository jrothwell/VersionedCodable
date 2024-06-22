//
//  NothingEarlier.swift
//  
//
//  Created by Jonathan Rothwell on 15/04/2023.
//

import Foundation

/// The type to indicate that a ``VersionedCodable/VersionedCodable`` does **not** have any
/// older versions, and the decoder should stop trying to decode it.
///
/// You typically use this when creating a new ``VersionedCodable/VersionedCodable`` type, or
/// conforming an existing type to ``VersionedCodable/VersionedCodable``.
///
/// - SeeAlso: ``VersionedCodable/VersionedCodable/PreviousVersion``
/// - Important: There's no way to create an instance of ``NothingEarlier``. It's an *uninhabited type*,
///   similar to `Never` in the standard library.
/// - Warning: Don't decode or initialize ``NothingEarlier``. The behaviour on decoding and
///   encoding is undefined and may result in a crash.
public enum NothingEarlier {}

extension VersionedCodable where PreviousVersion == NothingEarlier {
    // For the oldest type, this avoids people having to declare a useless
    // initializer from `NothingEarlier`.
    
    /// - Warning: Do not invoke this initializer. The behaviour on initialization is undefined: in future it
    ///   may result in an unrecoverable fatal error or assertion failure.
    public init(from: NothingEarlier) throws {
        throw VersionedDecodingError.unsupportedVersion(tried: Self.self)
    }
}

extension NothingEarlier: VersionedCodable {
    public typealias PreviousVersion = NothingEarlier
    public static let version: Int? = nil
    
    
    /// - Warning: Do not try to decode ``NothingEarlier``. The behvaiour if you do so is
    ///   undefined. In future it may result in an unrecoverable fatal error or assertion failure.
    public init(from decoder: Decoder) throws {
        let context = DecodingError.Context(
               codingPath: decoder.codingPath,
               debugDescription: "Unable to decode an instance of NothingEarlier."
        )
        throw DecodingError.typeMismatch(NothingEarlier.self, context)
    }
        
    /// - Note: It is impossible to encode ``NothingEarlier`` because ``NothingEarlier`` is
    ///   an uninhabited type, similar to `Never` in the Swift standard library---so you can never have
    ///   an instance of ``NothingEarlier`` to encode.
    public func encode(to encoder: Encoder) throws { }
}


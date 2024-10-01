
import Foundation

/// A type that can convert itself into and out of an external representation, which is versioned and can be
/// decoded from old versions of itself.
///
/// Should be used with the extensions on the Foundation decoders (e.g. ``Foundation/JSONEncoder/encode(versioned:)``,
/// ``Foundation/PropertyListDecoder/decode(versioned:from:)``.)
///
/// You can also implement support in other decoders using ``encodeTransparently(using:)`` and ``decodeTransparently(from:using:)``.
///
/// ## Decoding
/// If the ``version`` field matches the version field on the encoded type (also an optional `Int`),
/// this type will be the one that is decoded from the rest of the document.
///
/// ## Encoding
/// Upon encoding, the type will be encoded as normal and then an additional version field will be
/// encoded with the contents of ``version``.
///
/// - Note: ``version`` is optional, to account for versions of the type that were created and encoded
///   before you adopted ``VersionedCodable`` (hence making any encoded `version` value `nil`.)
public protocol VersionedCodable: Codable {
    
    /// The current version of this type. This is what is encoded into the `version` key on this type
    /// when it is encoded.
    ///
    /// Generally you declare it as a `static let`, for instance:
    ///
    /// ```swift
    /// static let version = 3
    /// ```
    ///
    /// - Note: It's possible for this to be `nil`, to account for versions of the type that were created and
    /// encoded/persisted to disk before you adopted ``VersionedCodable``.
    /// - Important: It is your responsibility to make sure that `version` is immutable and does not
    ///   change. The behaviour if it does change mid-execution is undefined. It's not a good idea to
    ///   declare `version` as a computed property, or a `var` which the caller can then change.
    static var version: Int? { get }
    
    /// The next oldest version of this type, or ``NothingEarlier`` if this *is* the oldest version.
    /// - Note: If this **is** the oldest version of the type, then use  ``NothingEarlier``. This
    ///   signals the decoder to throw an error if it can't get a match for this version.
    associatedtype PreviousVersion: VersionedCodable
    
    /// The ``VersionSpec`` used to determine how to encode and decode the version number of this
    /// type.
    associatedtype VersionSpec: VersionPathSpec = VersionKeyAtRootVersionPathSpec
    
    /// Initializes a new instance of this type from a type of ``PreviousVersion``. This is where to do
    /// mapping between the old and new version of the type.
    /// - Note: You don't need to provide this if ``PreviousVersion`` is ``NothingEarlier``.
    init(from: PreviousVersion) throws
}


struct VersionedCodableWritingWrapper: Encodable {
    var wrapped: any VersionedCodable
    var spec: any VersionPathSpec.Type
    
    func encode(to encoder: Encoder) throws {
        try wrapped.encode(to: encoder)
        try spec.init(withVersion: type(of: wrapped).version).encode(to: encoder)
    }
}

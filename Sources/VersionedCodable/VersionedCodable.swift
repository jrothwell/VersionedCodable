
import Foundation

/// A type that can convert itself into and out of an external representation, which is versioned and can be
/// decoded from old versions of itself.
///
/// ## Decoding
/// If ``thisVersion`` matches the `version` field on the encoded type (also an optional `Int`),
/// this type will be the one that is decoded from the rest of the document.
///
/// ## Encoding
/// Upon encoding, the type will be encoded as normal and then an additional `version` field will be
/// encoded with the contents of ``thisVersion``.
///
/// - Note: ``thisVersion`` is optional, to account for versions of the type that were created and encoded
///   before you adopted ``VersionedCodable`` (hence making any encoded `version` value `nil`.)
public protocol VersionedCodable: Codable {
    
    /// The current version of this type. This is what is encoded into the `version` key on this type
    /// when it is encoded.
    ///
    /// - Note: It's possible for this to be `nil`, to account for versions of the type that were created and
    /// encoded/persisted to disk before you adopted ``VersionedCodable``.
    static var thisVersion: Int? { get }
    
    /// The next oldest version of this type, or ``NothingEarlier`` if this *is* the oldest version.
    /// - Note: If this **is** the oldest version of the type, then use  ``NothingEarlier``. This
    ///   signals the decoder to throw an error if it can't get a match for this version.
    associatedtype PreviousVersion: VersionedCodable
    
    /// Initializes a new instance of this type from a type of ``PreviousVersion``. This is where to do
    /// mapping between the old and new version of the type.
    /// - Note: You don't need to provide this if ``PreviousVersion`` is ``NothingEarlier``.
    init(from: PreviousVersion) throws
}

struct VersionedDocument: Codable {
    var version: Int?
}

/// A problem that occurs during the decoding of a ``VersionedCodable``.
public enum VersionedDecodingError: Error {
    
    /// A field that was optional is no longer , such that this value no longer makes any sense in
    /// the newer version of the ``VersionedCodable``.
    ///
    /// Used in `VersionedCodable.init(from: PreviousVersion)`.
    case fieldBecameRequired
    
    /// There is no previous version available to attempt decoding, so this type cannot be decoded.
    /// - Parameter than: The current ``VersionedCodable`` type.
    case noOlderVersionAvailable(than: any VersionedCodable.Type)
}

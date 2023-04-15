
import Foundation

/// A type that can convert itself into and out of an external representation, which is versioned and can be
/// decoded from old versions of itself. The version is an integer which is coded as the `version` field on
/// the encoded type.
public protocol VersionedCodable: Codable {
    
    /// The current version of this type. This is what is encoded into the `version` key on this type
    /// when it is encoded.
    ///
    /// - Note: It's possible for this to be `nil`, to account for versions of the type that were created and
    /// encoded/persisted to disk before it adopted ``VersionedCodable``.
    static var thisVersion: Int? { get }
    
    /// The next oldest version of this type.
    /// - Note: If this **is** the oldest version of the type, then use  ``NothingOlder``. This signals
    ///   the decoder to throw an error if it can't get a match for this version.
    associatedtype PreviousVersion: VersionedCodable
    
    /// Initializes a new instance of this type from a type of ``PreviousVersion``. This is where to do
    /// mapping between the old and new version of the type.
    /// - Note: You don't need to provide this if ``PreviousVersion`` is ``NothingOlder``.
    init(from: PreviousVersion) throws
}

struct VersionedDocument: Codable {
    var version: Int?
}

public enum VersionedDecodingError: Error {
    case fieldBecameRequired
    case noOlderVersionAvailable(than: any VersionedCodable.Type)
}

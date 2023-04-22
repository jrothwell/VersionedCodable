
import Foundation

/// A type that can convert itself into and out of an external representation, which is versioned and can be
/// decoded from old versions of itself.
///
/// Note that currently, **only JSON and property list encoding/decoding is supported** using
/// `decode(versioned:from:)` and `encode(versioned:)` in the default `JSONEncoder`
/// and `PropertyListDecoder` types. If you use the default `Encodable` encoding functions
/// it will not encode the version. Similarly, the default `Decodable` decoding functions will not account
/// for or care about potential older versions.
///
/// ## Decoding
/// If ``version`` matches the `version` field on the encoded type (also an optional `Int`),
/// this type will be the one that is decoded from the rest of the document.
///
/// ## Encoding
/// Upon encoding, the type will be encoded as normal and then an additional `version` field will be
/// encoded with the contents of ``version``.
///
/// - Note: ``version`` is optional, to account for versions of the type that were created and encoded
///   before you adopted ``VersionedCodable`` (hence making any encoded `version` value `nil`.)
public protocol VersionedCodable: Codable {
    
    /// The current version of this type. This is what is encoded into the `version` key on this type
    /// when it is encoded.
    ///
    /// - Note: It's possible for this to be `nil`, to account for versions of the type that were created and
    /// encoded/persisted to disk before you adopted ``VersionedCodable``.
    static var version: Int? { get }
    
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

struct VersionedCodableWritingWrapper: Encodable {
    var wrapped: any VersionedCodable
    
    func encode(to encoder: Encoder) throws {
        guard !wrapped.hasFieldNamedVersion else {
            throw VersionedEncodingError.typeHasClashingVersionField
        }
        
        try wrapped.encode(to: encoder)
        try VersionedDocument(version: type(of: wrapped).version).encode(to: encoder)
    }
}

private extension VersionedCodable {
    // This can lead to a clash, or one `version` field being overwritten by the
    // other. We consider this to be a programmer error.
    // TODO: Find a way to stop this happening at compile time without introducing a bunch of boilerplate.
    var hasFieldNamedVersion: Bool {
        Mirror(reflecting: self)
            .children
            .contains(where: { $0.label == "version" })
    }
}

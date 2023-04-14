
import Foundation

public protocol VersionedCodable: Codable {
    static var thisVersion: Int? { get }
    
    associatedtype PreviousVersion: VersionedCodable
    init(from: PreviousVersion) throws
}


struct VersionedDocument: Codable {
    var version: Int?
}

enum VersionedDocumentKeys: CodingKey {
    case version
}


public enum VersionedDecodingError: Error {
    case fieldBecameRequired
    case olderThanOldestVersion(desiredVersion: Int?, ourMinimum: Int?)
    case noOlderVersionAvailable
}

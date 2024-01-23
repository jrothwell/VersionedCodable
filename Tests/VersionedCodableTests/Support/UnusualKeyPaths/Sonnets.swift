//
//  Sonnets.swift
//
//
//  Created by Jonathan Rothwell on 23/01/2024.
//

import Foundation
import VersionedCodable

struct SonnetV2: VersionedCodable {
    static let version: Int? = 2
    typealias PreviousVersion = SonnetV1
    typealias VersionPathSpecification = VersionedSpec
    
    var author: String
    var body: [BodyElement]
    
    enum BodyElement: Codable {
        case quatrain([String])
        case couplet([String])
    }
    
    init(from old: SonnetV1) throws {
        self.author = old.author
        self.body = old.body.quatrains.map { BodyElement.quatrain($0) } +
        old.body.couplets.map { BodyElement.couplet($0) }
    }

    struct VersionedSpec: VersionedDocumentSpecification {
        static let versionKeyPath: KeyPath<SonnetV2.VersionedSpec, Int?> = \Self.metadata.documentVersion
        
        init(withVersion version: Int?) {
            self.metadata = Metadata(documentVersion: version)
        }
        
        var metadata: Metadata
        
        struct Metadata: Codable {
            var documentVersion: Int?
        }
    }
}

struct SonnetV1: VersionedCodable {
    static let version: Int? = 1
    typealias PreviousVersion = NothingEarlier
    typealias VersionPathSpecification = VersionedSpec
    
    var author: String
    var body: Body
    
    struct Body: Codable {
        var quatrains: [[String]]
        var couplets: [[String]]
    }
    
    struct VersionedSpec: VersionedDocumentSpecification {
        static let versionKeyPath: KeyPath<SonnetV1.VersionedSpec, Int?> = \Self._version
        
        init(withVersion _version: Int? = nil) {
            self._version = _version
        }
        
        var _version: Int?
    }
}

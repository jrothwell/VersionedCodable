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
    
    var author: String
    var body: [BodyElement]
    
    enum BodyElement: Codable {
        case quatrain([String])
        case couplet([String])
        
        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let rawBody = try container.decode(RawBodyElement.self)
            switch rawBody.kind {
            case .quatrain:
                self = .quatrain(rawBody.body)
            case .couplet:
                self = .couplet(rawBody.body)
            }
        }
        
        struct RawBodyElement: Codable {
            var kind: Kind
            var body: [String]
            
            enum Kind: String, Codable {
                case quatrain
                case couplet
            }
        }
    }
    
    init(from old: SonnetV1) throws {
        self.author = old.author
        self.body = old.body.quatrains.map { BodyElement.quatrain($0) } +
        old.body.couplets.map { BodyElement.couplet($0) }
    }

}

struct SonnetV1: VersionedCodable {
    static let version: Int? = 1
    typealias PreviousVersion = NothingEarlier
    
    var author: String
    var body: Body
    
    struct Body: Codable {
        var quatrains: [[String]]
        var couplets: [[String]]
    }
}

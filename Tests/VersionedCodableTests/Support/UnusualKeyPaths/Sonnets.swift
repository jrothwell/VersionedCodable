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

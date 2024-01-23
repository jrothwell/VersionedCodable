//
//  Sonnets.swift
//
//
//  Created by Jonathan Rothwell on 23/01/2024.
//

import Foundation
import VersionedCodable

struct Sonnet: VersionedCodable {
    static let version: Int? = 1
    typealias PreviousVersion = NothingEarlier
    
    var author: String
    var body: Body
    
    struct Body: Codable {
        var quatrains: [[String]]
        var couplets: [[String]]
    }
}

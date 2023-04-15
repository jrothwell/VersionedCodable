//
//  PoemExample.swift
//  
//
//  Created by Jonathan Rothwell on 15/04/2023.
//

import Foundation
import VersionedCodable

struct Poem: VersionedCodable {
    var author: Author?
    var lines: [String]
    
    struct Author: Codable {
        var name: String
        var born: Date?
        var died: Date?
    }

    
    static let thisVersion: Int? = 4
    typealias PreviousVersion = PoemV3
    init(from old: PreviousVersion) throws {
        self.lines = old.lines
        if let name = old.authorName {
            self.author = Author(name: name,
                                 born: old.authorDateOfBirth,
                                 died: old.authorDateOfDeath)
        }
    }

    
    struct PoemPreV1: VersionedCodable {
        var author: String?
        var poem: String?
        
        static let thisVersion: Int? = nil
        typealias PreviousVersion = NothingEarlier
    }
    
    struct PoemV1: VersionedCodable {
        var author: String?
        var poem: String
        
        static let thisVersion: Int? = 1
        typealias PreviousVersion = PoemPreV1
        init(from old: PreviousVersion) throws {
            self.author = old.author
            guard let poem = old.poem else {
                throw VersionedDecodingError.fieldBecameRequired
            }
            self.poem = poem
        }

    }
    
    struct PoemV2: VersionedCodable {
        var authorName: String?
        var authorDateOfBirth: Date?
        var authorDateOfDeath: Date?
        var poem: String
        
        static let thisVersion: Int? = 2
        typealias PreviousVersion = PoemV1
        init(from old: PreviousVersion) throws {
            self.authorName = old.author
            self.poem = old.poem
        }
    }
    
    struct PoemV3: VersionedCodable {
        var authorName: String?
        var authorDateOfBirth: Date?
        var authorDateOfDeath: Date?
        var lines: [String]
        
        static let thisVersion: Int? = 3
        typealias PreviousVersion = PoemV2
        init(from old: PreviousVersion) {
            self.authorName = old.authorName
            self.lines = old.poem.components(separatedBy: "\n")
        }
    }
}

//
//  PoemDocuments.swift
//  
//
//  Created by Jonathan Rothwell on 15/04/2023.
//

import Foundation
import VersionedCodable


@versionedCodable(v: 4)
struct Poem {
    var author: Author?
    var lines: [String]
    
    struct Author: Codable {
        var name: String
        var born: Date?
        var died: Date?
    }

    typealias PreviousVersion = PoemV3
    init(from old: PreviousVersion) throws {
        self.lines = old.lines
        if let name = old.authorName {
            self.author = Author(name: name,
                                 born: old.authorDateOfBirth,
                                 died: old.authorDateOfDeath)
        }
    }

    
    @versionedCodable(v: nil)
    struct PoemPreV1 {
        var author: String?
        var poem: String?
        
        typealias PreviousVersion = NothingEarlier
    }
    
    @versionedCodable(v: 1)
    struct PoemV1 {
        var author: String?
        var poem: String
        
        typealias PreviousVersion = PoemPreV1
        init(from old: PreviousVersion) throws {
            self.author = old.author
            guard let poem = old.poem else {
                throw VersionedDecodingError.fieldNoLongerValid(
                    DecodingError.Context(codingPath: [CodingKeys.poem],
                                          debugDescription: "Poem is no longer optional")
                )
            }
            self.poem = poem
        }

    }
    
    @versionedCodable(v: 2)
    struct PoemV2 {
        var authorName: String?
        var authorDateOfBirth: Date?
        var authorDateOfDeath: Date?
        var poem: String
        
        typealias PreviousVersion = PoemV1
        init(from old: PreviousVersion) throws {
            self.authorName = old.author
            self.poem = old.poem
        }
    }
    
    @versionedCodable(v: 3)
    struct PoemV3 {
        var authorName: String?
        var authorDateOfBirth: Date?
        var authorDateOfDeath: Date?
        var lines: [String]
        
        typealias PreviousVersion = PoemV2
        init(from old: PreviousVersion) {
            self.authorName = old.authorName
            self.lines = old.poem.components(separatedBy: "\n")
        }
    }
}

@versionedCodable(v: 1)
struct PoemWithClash {
    typealias PreviousVersion = NothingEarlier
    
    var content: String
    var version: Int
}

extension Poem {
    internal init(author: Poem.Author? = nil, lines: [String]) {
        self.author = author
        self.lines = lines
    }
}

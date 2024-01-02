//
//  PoemDocuments.swift
//  
//
//  Created by Jonathan Rothwell on 15/04/2023.
//

import Foundation
import VersionedCodable


@versionedCodable(v: 4, previously: PoemV3)
struct Poem {
    var author: Author?
    var lines: [String]
    
    struct Author: Codable {
        var name: String
        var born: Date?
        var died: Date?
    }

    init(from old: PreviousVersion) throws {
        self.lines = old.lines
        if let name = old.authorName {
            self.author = Author(name: name,
                                 born: old.authorDateOfBirth,
                                 died: old.authorDateOfDeath)
        }
    }
}

@versionedCodable(v: 1, previously: NothingEarlier)
struct PoemWithClash {
    var content: String
    var version: Int
}


@versionedCodable(v: nil, previously: NothingEarlier)
struct PoemPreV1 {
    var author: String?
    var poem: String?
}

@versionedCodable(v: 1, previously: PoemPreV1)
struct PoemV1 {
    var author: String?
    var poem: String
    
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

@versionedCodable(v: 2, previously: PoemV1)
struct PoemV2 {
    var authorName: String?
    var authorDateOfBirth: Date?
    var authorDateOfDeath: Date?
    var poem: String
    
    init(from old: PreviousVersion) throws {
        self.authorName = old.author
        self.poem = old.poem
    }
}

@versionedCodable(v: 3, previously: PoemV2)
struct PoemV3 {
    var authorName: String?
    var authorDateOfBirth: Date?
    var authorDateOfDeath: Date?
    var lines: [String]
    
    init(from old: PreviousVersion) {
        self.authorName = old.authorName
        self.lines = old.poem.components(separatedBy: "\n")
    }
}

extension Poem {
    internal init(author: Poem.Author? = nil, lines: [String]) {
        self.author = author
        self.lines = lines
    }
}

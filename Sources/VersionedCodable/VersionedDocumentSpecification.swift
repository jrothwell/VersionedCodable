//
//  VersionedDocumentSpecification.swift
//
//
//  Created by Jonathan Rothwell on 23/01/2024.
//

import Foundation

public protocol VersionedDocumentSpecification: Codable {
    static var versionKeyPath: KeyPath<Self, Int?> { get }
    init(withVersion version: Int?)
}

public struct RootVersionKeyVersionedDocumentSpecification: Codable, VersionedDocumentSpecification {
    public static let versionKeyPath: KeyPath<RootVersionKeyVersionedDocumentSpecification, Int?> = \Self.version
    public init(withVersion version: Int? = nil) {
        self.version = version
    }
    
    var version: Int?
}



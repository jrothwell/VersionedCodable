//
//  VersionedDocumentSpecification.swift
//
//
//  Created by Jonathan Rothwell on 23/01/2024.
//

import Foundation

public protocol VersionedDocumentSpecification: Codable {
    static var versionKeyPath: KeyPath<Self, Int?> { get }
}

public struct RootVersionKeyVersionedDocumentSpecification: Codable, VersionedDocumentSpecification {
    public static let versionKeyPath: KeyPath<RootVersionKeyVersionedDocumentSpecification, Int?> = \Self.version
    
    var version: Int?
}



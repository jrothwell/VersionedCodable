//
//  IsTypeMismatchVs.swift
//  VersionedCodable
//
//  Created by Jonathan Rothwell on 01/10/2024.
//

func isTypeMismatch<T>(_ error: Error, vs otherType: T.Type) -> Bool {
    switch error {
    case DecodingError.typeMismatch(let thisType, _):
        return thisType == T.self
    default:
        return false
    }

}

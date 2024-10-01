//
//  Never+VersionedCodable.swift
//  VersionedCodable
//
//  Created by Jonathan Rothwell on 01/10/2024.
//

@available(swift, introduced: 5.9)
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension Never: VersionedCodable {
    public typealias PreviousVersion = NothingEarlier

    public static var version: Int? {
        nil
    }
}

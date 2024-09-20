import Testing
import Foundation
@testable import VersionedCodable

struct VersionedDocument: Codable {
    var version: Int?
}


@Suite("JSONDecoder encoding/decoding",
       .tags(.behaviour))
struct VersionedCodableJSONTests {
    @Test("decodes a grandfathered type with no version field")
    func decodingPoemPreV1ToPoemV1() throws {
        let oldPoem = """
                      {
                        "author": "John Smith",
                        "poem": "Hello"
                      }
                      """.data(using: .utf8)!
        
        
        let migrated = try JSONDecoder()
            .decode(versioned: Poem.PoemV1.self,
                    from: oldPoem)
        #expect("John Smith" == migrated.author)
        #expect("Hello" == migrated.poem)
    }
    
    @Test("throws when trying to decode type if some fields are now mandatory")
    func decodingPoemPreV1ToPoemV1ThrowsDueToNewMandatoryFields() throws {
        let oldPoem = """
                      {
                        "author": "John Smith",
                        "poem": null
                      }
                      """.data(using: .utf8)!
        
        
        #expect {
            try JSONDecoder().decode(
                versioned: Poem.PoemV1.self,
                from: oldPoem
            )
        } throws: { error in
            guard let error = error as? VersionedDecodingError,
                  case .fieldNoLongerValid(let context) = error else {
                      return false
                  }
            
            return (
                "poem" == context.codingPath[0].stringValue
            ) && (
                "Poem is no longer optional" == context.debugDescription
            )
            
        }
    }
    
    @Test("throws when decoding an older version than we support")
    func throwsWhenDecodingOlderVersionThanWeSupport() throws {
        let oldPoem = """
                      {
                        "version": -1,
                        "author": "John Smith",
                        "poem": null
                      }
                      """.data(using: .utf8)!
        
        #expect(throws: VersionedDecodingError.unsupportedVersion(tried: Poem.PoemPreV1.self)) {
            try JSONDecoder().decode(
                versioned: Poem.PoemV1.self,
                from: oldPoem
            )
        }
    }
    
    @Test("performs a multi-stage migration")
    func multiStageMigration() throws {
        let oldPoem = """
                      {
                        "version": 1,
                        "author": "A Clever Man",
                        "poem": "An epicure dining at Crewe\\nFound a rather large mouse in his stew\\nCried the waiter: Don't shout\\nAnd wave it about\\nOr the rest will be wanting one too!"
                      }
                      """.data(using: .utf8)!
        
        let migrated = try JSONDecoder().decode(
            versioned: Poem.self,
            from: oldPoem)
        
        #expect(
            [
                "An epicure dining at Crewe",
                "Found a rather large mouse in his stew",
                "Cried the waiter: Don\'t shout",
                "And wave it about",
                "Or the rest will be wanting one too!"
            ] == migrated.lines
        )
        #expect("A Clever Man" == migrated.author?.name)
    }
    
    @Test("encodes the version properly")
    func testVersionEncodedCorrectly() throws {
        let oldPoem = """
                      {
                        "version": 1,
                        "author": "A Clever Man",
                        "poem": "An epicure dining at Crewe\\nFound a rather large mouse in his stew\\nCried the waiter: Don't shout\\nAnd wave it about\\nOr the rest will be wanting one too!"
                      }
                      """.data(using: .utf8)!
        
        let migrated = try JSONDecoder()
            .decode(versioned: Poem.self,
                    from: oldPoem)
        

        let encoded = try JSONEncoder().encode(versioned: migrated)
        
        let versionedDocument = try JSONDecoder().decode(VersionedDocument.self, from: encoded)
        
        #expect(4 == versionedDocument.version)
        
        let encodedAndDecodedDocument = try JSONDecoder().decode(Poem.self, from: encoded)
        #expect(
            [
                "An epicure dining at Crewe",
                "Found a rather large mouse in his stew",
                "Cried the waiter: Don\'t shout",
                "And wave it about",
                "Or the rest will be wanting one too!"
            ] == encodedAndDecodedDocument.lines
        )
        #expect("A Clever Man" == encodedAndDecodedDocument.author?.name)
    }

}

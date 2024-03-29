import XCTest
@testable import VersionedCodable

struct VersionedDocument: Codable {
    var version: Int?
}


final class VersionedCodableJSONTests: XCTestCase {

    func testDecodingPoemPreV1ToPoemV1() throws {
        let oldPoem = """
                      {
                        "author": "John Smith",
                        "poem": "Hello"
                      }
                      """.data(using: .utf8)!
        
        
        let migrated = try JSONDecoder().decode(
            versioned: Poem.PoemV1.self,
            from: oldPoem)
        XCTAssertEqual(migrated.author, "John Smith")
        XCTAssertEqual(migrated.poem, "Hello")
    }
    
    func testDecodingPoemPreV1ToPoemV1WhereWeDiscardDueToNewMandatoryFields() throws {
        let oldPoem = """
                      {
                        "author": "John Smith",
                        "poem": null
                      }
                      """.data(using: .utf8)!
        
        XCTAssertThrowsError(try JSONDecoder().decode(
            versioned: Poem.PoemV1.self,
            from: oldPoem)) { error in
                switch error {
                case VersionedDecodingError.fieldNoLongerValid(let context):
                    XCTAssertEqual("poem", context.codingPath[0].stringValue)
                    XCTAssertEqual("Poem is no longer optional", context.debugDescription)
                default:
                    XCTFail("An error threw, but it was the wrong kind of error (expected `VersionedDecodingError.fieldNoLongerValid`, got: \(error))")
                }
            }
    }
    
    func testDecodingOlderVersionThanWeSupportExplodes() throws {
        let oldPoem = """
                      {
                        "version": -1,
                        "author": "John Smith",
                        "poem": null
                      }
                      """.data(using: .utf8)!
        
        XCTAssertThrowsError(try JSONDecoder().decode(
            versioned: Poem.PoemV1.self,
            from: oldPoem)) { error in
                switch error {
                case VersionedDecodingError.unsupportedVersion(let olderVersion):
                    XCTAssertTrue(olderVersion == Poem.PoemPreV1.self)
                default:
                    XCTFail("An error threw, but it was the wrong kind of error (expected `VersionedDecodingError.unsupportedVersion(Poem.PoemPreV1)`, got: \(error))")
                }
            }
    }
    
    func testMultiStageMigration() throws {
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
        XCTAssertEqual(["An epicure dining at Crewe", "Found a rather large mouse in his stew", "Cried the waiter: Don\'t shout", "And wave it about", "Or the rest will be wanting one too!"], migrated.lines)
        XCTAssertEqual("A Clever Man", migrated.author?.name)
    }
    
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
        
        XCTAssertEqual(4, versionedDocument.version)
        
        let encodedAndDecodedDocument = try JSONDecoder().decode(Poem.self, from: encoded)
        XCTAssertEqual(["An epicure dining at Crewe", "Found a rather large mouse in his stew", "Cried the waiter: Don\'t shout", "And wave it about", "Or the rest will be wanting one too!"], encodedAndDecodedDocument.lines)
        XCTAssertEqual("A Clever Man", encodedAndDecodedDocument.author?.name)
    }

}

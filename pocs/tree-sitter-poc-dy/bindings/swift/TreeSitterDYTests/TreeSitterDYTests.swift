import XCTest
import SwiftTreeSitter
import TreeSitterDy

final class TreeSitterDyTests: XCTestCase {
    func testCanLoadGrammar() throws {
        let parser = Parser()
        let language = Language(language: tree_sitter_dy())
        XCTAssertNoThrow(try parser.setLanguage(language),
                         "Error loading DY grammar")
    }
}

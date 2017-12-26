import Foundation
import XCTest

@testable import SakefileDescription

final class VersionTests: XCTestCase {
    
    func test_initFromString_initializesThePropertiesProperly() throws {
        assertEqual(version: try Version("3.2.1"), major: 3, minor: 2, patch: 1)
        assertEqual(version: try Version("3.2"), major: 3, minor: 2, patch: 0)
        assertEqual(version: try Version("3"), major: 3, minor: 0, patch: 0)
    }
    
    func test_string_returnsTheRightValue() throws {
        XCTAssertEqual(try Version("3.2.1").string, "3.2.1")
    }
    
    func test_bumpingMajor_returnsAVersionWithTheMajorBumped() throws {
        XCTAssertEqual(try Version("3.2.1").bumpingMajor(), try Version("4.0.0"))
    }
    
    func test_bumpingMinor_returnsAVersionWithTheMinorBumped() throws {
        XCTAssertEqual(try Version("3.2.1").bumpingMinor(), try Version("3.3.0"))
    }
    
    func test_bumpingPatch_returnsAVersionWithThePatchBumped() throws {
        XCTAssertEqual(try Version("3.2.1").bumpingPatch(), try Version("3.2.2"))
    }
    
    fileprivate func assertEqual(version: Version, major: UInt, minor: UInt, patch: UInt) {
        XCTAssertEqual(version.major, major)
        XCTAssertEqual(version.minor, minor)
        XCTAssertEqual(version.patch, patch)
    }
    
    
}

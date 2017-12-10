import Foundation
import XCTest
import PathKit

@testable import SakeKit

final class RuntimeTests: XCTestCase {
    
    func test_librariesFolder_containsTheRightFolders() {
        XCTAssertEqual(Runtime.librariesFolders(), [".build/debug", ".build/release"])
    }
    
    func test_fileDescriptionLibraryPath_returnsTheCorrectValue_whenTheLibraryExistsAtTheLibraryPath() {
        librariesPath = "/test"
        let got = Runtime.filedescriptionLibraryPath { _ in return true }
        let expected = Path("/test/libSakefileDescription.dylib")
        XCTAssertEqual(got, expected)
    }
    
    func test_fileDescriptionLibraryPath_returnsTheCorrectValue_whenTheLibraryExistsAtAnyLibraryFolder() {
        let got = Runtime.filedescriptionLibraryPath { $0 == Path(".build/release/libSakefileDescription.dylib") }
        let expected = Path(".build/release/libSakefileDescription.dylib").absolute()
        XCTAssertEqual(got, expected)
        
    }
    
    func test_fileDescriptionLibraryPath_returnsNil_whenTheLibraryDoesntExist() {
        let got = Runtime.filedescriptionLibraryPath { _ in return false }
        XCTAssertNil(got)
    }
    
    func test_utilsLibraryPath_returnsTheCorrectValue_whenTheLibraryExistsAtTheLibraryPath() {
        librariesPath = "/test"
        let got = Runtime.utilsLibraryPath { _ in return true }
        let expected = Path("/test/libSakefileUtils.dylib")
        XCTAssertEqual(got, expected)
    }
    
    func test_utilsLibraryPath_returnsTheCorrectValue_whenTheLibraryExistsAtAnyLibraryFolder() {
        let got = Runtime.utilsLibraryPath { $0 == Path(".build/release/libSakefileUtils.dylib") }
        let expected = Path(".build/release/libSakefileUtils.dylib").absolute()
        XCTAssertEqual(got, expected)
        
    }
    
    func test_utilsLibraryPath_returnsNil_whenTheLibraryDoesntExist() {
        let got = Runtime.utilsLibraryPath { _ in return false }
        XCTAssertNil(got)
    }
}

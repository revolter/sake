import Foundation
import XCTest

@testable import SakeKit

final class DescriptionVersionProviderTests: XCTestCase {
    
    var sakefileContent: String!
    var subject: DescriptionVersionProvider!
    
    override func setUp() {
        super.setUp()
        subject = DescriptionVersionProvider(sakefilePath: "/path/Sakefile.swift",
                                             descriptionLastVersion: "1",
                                             read: { _ in return self.sakefileContent })
    }
    
    func test_version_returnsTheCorrectValue_whenTheVersionIsNotSpecified() throws {
        sakefileContent = ""
        XCTAssertEqual(try subject.version(), "1")
    }
    
    func test_version_returnsTheCorrectValue_whenTheVersionIsSpecified() {
        sakefileContent = """
        // sakefile-description-version:2
        import Foundation
        import SakefileDescription
        """
        XCTAssertEqual(try subject.version(), "2")
    }
    
}

import Foundation
import XCTest
import PathKit

@testable import SakeKit

final class GenerateSakefileTests: XCTestCase {
    
    var tmpDir: Path!
    var subject: GenerateSakefile!
    
    override func setUp() {
        super.setUp()
        tmpDir = Path(NSTemporaryDirectory()) + String.random()
        if !tmpDir.exists {
            try? tmpDir.mkpath()
        }
        subject = GenerateSakefile(path: tmpDir.string)
    }
    
    override func tearDown() {
        super.tearDown()
        try? tmpDir.delete()
    }
    
    func test_execute_throwsAnErrorIfTheresAlreadyASakefile() throws {
        try (tmpDir + "Sakefile.swift").write("test")
        XCTAssertThrowsError(try subject.execute())
    }
    
    func test_execute_createsASakefileWithTheRightContent() throws {
        try subject.execute()
        let got = try String(contentsOf: (tmpDir + "Sakefile.swift").url)
        XCTAssertEqual(got, GenerateSakefile.defaultContent())
    }
    
}

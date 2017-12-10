import Foundation
import XCTest
import xcproj

@testable import SakeKit

final class GenerateProjectTests: XCTestCase {
    
    var pbxproj: PBXProj!
    var subject: GenerateProject!
    
    override func setUp() {
        super.setUp()
        subject = GenerateProject(path: "/test")
        try? subject.execute { (project, _) in
            pbxproj = project.pbxproj
        }
    }
    
    
    func test_project_hasTheCorrectGroups() {

    }
    
    
}

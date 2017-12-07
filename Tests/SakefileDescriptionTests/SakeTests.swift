import Foundation
import XCTest

@testable import SakefileDescription

final class SakeTests: XCTestCase {
    
    func test_run_runsEverythingInTheRightOrder() {
        var executionOutputs: [String] = []
        let subject = Sake {
            $0.task(name: "a", description: "desc", dependencies: ["b"]) { (_) in
                executionOutputs.append("a")
            }
            $0.task(name: "b", description: "desc") { (_) in
                executionOutputs.append("b")
            }
            $0.beforeEach { (_) in
                executionOutputs.append("before_each")
            }
            $0.beforeAll { (_) in
                executionOutputs.append("before_all")
            }
            $0.afterEach { (_) in
                executionOutputs.append("after_each")
            }
            $0.afterAll { (_) in
                executionOutputs.append("after_all")
            }
        }
        subject.run(arguments: ["task", "a"])
        XCTAssertEqual(executionOutputs, [
            "before_all",
            "before_each",
            "b",
            "after_each",
            "before_each",
            "a",
            "after_each",
            "after_all"
        ])
        
    }
    
}

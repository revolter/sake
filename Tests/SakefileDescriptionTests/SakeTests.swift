import Foundation
import XCTest

@testable import SakefileDescription

final class SakeTests: XCTestCase {
    
    func test_runTask_runsEverythingInTheRightOrder() throws {
        var executionOutputs: [String] = []
        let tasks = [
            Task("a", dependencies: ["b"]) {
                executionOutputs.append("run a")
            },
            Task("b") {
                executionOutputs.append("run b")
            }
        ]
        let subject = Sake(tasks: tasks,
                           beforeAll: { executionOutputs.append("before_all") },
                           beforeEach:  { executionOutputs.append("before_each") },
                           afterEach: { executionOutputs.append("after_each") },
                           afterAll: { executionOutputs.append("after_all") }
        )
        subject.run(arguments: ["task", "a"])
        XCTAssertEqual(executionOutputs, [
            "before_all",
            "before_each",
            "run b",
            "after_each",
            "before_each",
            "run a",
            "after_each",
            "after_all"
            ])
    }

    func test_runTasks_printsTheCorrectString() throws {
        var printed = ""
        let tasks = [Task("a", "a description"), Task("b", "b description")]
        let subject = Sake(tasks: tasks, printer: { printed += $0 })
        subject.run(arguments: ["tasks"])
        let expected = """
            a:     a description
            b:     b description
            """
        XCTAssertEqual(printed, expected)
    }
    
    func test_runWrongTask_printSuggestedTaskName() throws {
        var printed = ""
        let tasks = [Task("a", dependencies: ["b"], action:{}), Task("b", action:{})]
        let subject = Sake(tasks: tasks, printer: { printed = $0 })
        subject.run(arguments: ["task", "_"])
        let expected = "> [!] Could not find task '_'"
        XCTAssertEqual(printed, expected)
    }

    func test_shouldPrintAndThrow_whenTaskIsAlreadyRegistered() {
        var printed = ""
        let tasks = [Task("a"), Task("a")]
        Sake(tasks: tasks, printer: { printed = $0 } ).run()
        XCTAssertEqual(printed, "> Error initializing tasks: Trying to register task a that is already registered")
    }

    func test_shouldPrintAndThrow_whenTheTaskHasInvalidDependency() {
        var printed = ""
        let tasks = [Task("a", dependencies: ["b"])]
        Sake(tasks: tasks, printer: { printed = $0 } ).run()
        XCTAssertEqual(printed, "> Error initializing tasks: Task a has a dependency b that can't be found")
    }
}

extension Task {

    // Makes initializing Tasks for tests easier. Makes dependencies and action optional params
    convenience init(_ name: String, _ description: String = "", dependencies: [String] = [], action: @escaping () -> Void = {}) {
        self.init(name, description: description, dependencies: dependencies, action: action)
    }
}

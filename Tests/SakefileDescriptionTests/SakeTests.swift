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
        Sake(tasks: tasks,
             hooks: [
                .beforeAll({ executionOutputs.append("before_all") }),
                .beforeEach({ executionOutputs.append("before_each") }),
                .afterAll({ executionOutputs.append("after_all") }),
                .afterEach({ executionOutputs.append("after_each") })],
             printer: { _ in },
             exiter: { _ in },
             arguments: ["task", "a"])
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
        Sake(tasks: tasks, hooks: [], printer: { printed += $0 }, exiter: { _ in }, arguments: ["tasks"])
        let expected = """
            a:     a description
            b:     b description
            """
        XCTAssertEqual(printed, expected)
    }
    
    func test_runWrongTask_printSuggestedTaskName() throws {
        var printed = ""
        var exited: Int?
        let tasks = [Task("a", dependencies: ["b"], action:{}), Task("b", action:{})]
        Sake(tasks: tasks, hooks: [], printer: { printed = $0 }, exiter: { exited = $0 }, arguments: ["task", "_"])
        let expected = "[!] Could not find task '_'"
        XCTAssertEqual(printed, expected)
        XCTAssertEqual(exited, 1)
    }
    
    func test_shouldPrintAndThrow_whenTaskIsAlreadyRegistered() {
        var printed = ""
        let tasks = [Task("a"), Task("a")]
        Sake(tasks: tasks, hooks: [], printer: { printed = $0 }, exiter: { _ in }, arguments: [])
        XCTAssertEqual(printed, "> Error initializing tasks: Trying to register task a that is already registered")
    }
    
    func test_shouldPrintAndThrow_whenTheTaskHasInvalidDependency() {
        var printed = ""
        let tasks = [Task("a", dependencies: ["b"])]
        Sake(tasks: tasks, hooks: [], printer: { printed = $0 }, exiter: { _ in }, arguments: [])
        XCTAssertEqual(printed, "> Error initializing tasks: Task a has a dependency b that can't be found")
    }
}

extension Task {
    
    // Makes initializing Tasks for tests easier. Makes dependencies and action optional params
    convenience init(_ name: String, _ description: String = "", dependencies: [String] = [], action: @escaping () -> Void = {}) {
        self.init(name, description: description, dependencies: dependencies, action: action)
    }
}

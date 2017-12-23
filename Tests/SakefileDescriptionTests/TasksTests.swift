import Foundation
import XCTest

@testable import SakefileDescription

final class TasksTests: XCTestCase {
    
    enum Task: String, CustomStringConvertible {
        case a
        case b
        var description: String {
            return self.rawValue
        }
    }
    
    func test_taskWithClosure_shouldPrintAnError_whenTheTaskIsAlreadyRegistered() {
        var printed: String!
        let subject = Sake<Task>(printer: { printed = $0 } ) {
            try $0.task(.a) { }
            try $0.task(.a) { }
        }
        subject.run(arguments: [])
        XCTAssertEqual(printed, "> Error initializing tasks: Trying to register task a that is already registered")
    }
    
    func test_taskWithTask_shouldThrow_whenTheTaskIsAlreadyRegistered() {
        var printed: String!
        let task = SakefileDescription.Task<Task>(type: .a, action: { })
        let subject = Sake<Task>(printer: { printed = $0 } ) {
            try $0.task(task: task)
            try $0.task(task: task)
        }
        subject.run(arguments: [])
        XCTAssertEqual(printed, "> Error initializing tasks: Trying to register task a that is already registered")
    }
    
}

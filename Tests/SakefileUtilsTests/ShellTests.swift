import Foundation
import XCTest

@testable import SakefileUtils

final class StandardOutOutputStreamTests: XCTestCase {
    
    var subject: StandardOutOutputStream!
    
    func test_write_appendsTheData_whenOutputIsTrue() {
        subject = StandardOutOutputStream(printing: false, output: true)
        sendData()
        let got = String(data: subject.data, encoding: .utf8)
        XCTAssertEqual(got, "test")
    }
    
    func test_write_doesntAppendTheData_whenTheOutputIsFalse() {
        subject = StandardOutOutputStream(printing: false, output: false)
        sendData()
        let got = String(data: subject.data, encoding: .utf8)
        XCTAssertEqual(got, "")
    }
    
    func test_write_prints_whenPrintingIsTrue() {
        var printed: String?
        subject = StandardOutOutputStream(printing: true, output: false) { print in
            printed = print
        }
        sendData()
        XCTAssertEqual(printed, "test")
    }
    
    func test_write_doesntPrint_whenPrintingIsFalse() {
        var printed: String?
        subject = StandardOutOutputStream(printing: false, output: false) { print in
            printed = print
        }
        sendData()
        XCTAssertNil(printed)
    }
    
    private func sendData() {
        let data = "test".data(using: .utf8)!
        _ = data.withUnsafeBytes { (pointer: UnsafePointer<UInt8>) in
            subject.write(pointer, maxLength: data.count)
        }
    }
    
}

final class  ShellCommandExecutorTests: XCTestCase {
    
    var subject: ShellCommandExecutor!
    var launchedProcess: Process!
    var result: ShellCommandExecutor.ShellOutput!
    
    override func setUp() {
        super.setUp()
        let outputStream = StandardOutOutputStream(printing: false,
                                                   output: true)
        subject = ShellCommandExecutor(launchPath: "/bin/sh",
                                       arguments: ["arg1", "arg2"],
                                       outputStream: outputStream) { (process, outputStream) -> (output: String?, exitCode: Int32) in
                                        self.launchedProcess = process
                                        return (output: "abc\n", exitCode: 32)
        }
        result = subject.execute()
    }
    
    func test_it_propagatesTheExitCode() {
        XCTAssertEqual(result.exitCode, 32)
    }
    
    func test_itCleansLineBreaksFromTheOutput() {
        XCTAssertEqual(result.output, "abc")
    }
    
    func test_itUsesTheRightLaunchPath() {
        XCTAssertEqual(launchedProcess.launchPath, "/bin/sh")
    }
    
    func test_itUsesTheRightArguments() {
        XCTAssertNotNil(launchedProcess.arguments)
        if let arguments = launchedProcess.arguments {
            XCTAssertEqual(arguments, ["arg1", "arg2"])
        }
    }
}


final class ShellTests: XCTestCase {
    
}

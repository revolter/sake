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

final class ShellTests: XCTestCase {
    
}

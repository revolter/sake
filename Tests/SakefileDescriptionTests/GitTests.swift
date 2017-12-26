import Foundation
import XCTest

@testable import SakefileDescription

final class GitTests: XCTestCase {
    
    var shell: MockShell!
    var subject: Git!
    
    override func setUp() {
        super.setUp()
        shell = MockShell()
        subject = Git(shell: shell) {}
    }
    
    func test_branch_runsTheRightCommand() throws {
        shell.runBashStub = "branch"
        let got = try subject.branch()
        XCTAssertEqual(shell.runBashArgs.first, "git rev-parse --abbrev-ref HEAD")
        XCTAssertEqual(got, "branch")
    }
    
    func test_anyChanges_runsTheRightCommand() throws {
        shell.runBashStub = "7"
        let got = try subject.anyChanges()
        XCTAssertEqual(shell.runBashArgs.first, "git diff --stat --numstat | wc -l")
        XCTAssertTrue(got)
    }
    
    func test_commitAll_runsTheRightCommands() throws {
        try subject.commitAll(message: "message")
        XCTAssertEqual(shell.runAndPrintBashArgs.count, 2)
        if shell.runAndPrintBashArgs.count != 2 { return }
        XCTAssertEqual(shell.runAndPrintBashArgs[0], "git add .")
        XCTAssertEqual(shell.runAndPrintBashArgs[1], "git commit -m 'message'")
    }
    
    func test_commitl_runsTheRightCommands() throws {
        try subject.commit(message: "message")
        XCTAssertEqual(shell.runAndPrintBashArgs.first, "git commit -m 'message'")
    }
    
    func test_addRemote_runsTheRightCommands() throws {
        try subject.addRemote("origin", url: "whatever")
        XCTAssertEqual(shell.runAndPrintBashArgs.count, 1)
        if shell.runAndPrintBashArgs.count != 1 { return }
        XCTAssertEqual(shell.runAndPrintBashArgs[0], "git remote add origin whatever")
    }
    
    func test_removeRemote_runsTheRightCommands() throws {
        try subject.removeRemote("origin")
        XCTAssertEqual(shell.runAndPrintBashArgs.count, 1)
        if shell.runAndPrintBashArgs.count != 1 { return }
        XCTAssertEqual(shell.runAndPrintBashArgs[0], "git remote remove origin")
    }
    
    func test_tag_runsTheRightCommands() throws {
        try subject.tag("1.0.0")
        XCTAssertEqual(shell.runAndPrintBashArgs.count, 1)
        if shell.runAndPrintBashArgs.count != 1 { return }
        XCTAssertEqual(shell.runAndPrintBashArgs[0], "git tag 1.0.0")
    }
    
    func test_lastTag_runsTheRightCommand() throws {
        shell.runBashStub = "3.0.0"
        let got = try subject.lastTag()
        XCTAssertEqual(shell.runBashArgs.first, "git describe --abbrev=0 --tags")
        XCTAssertEqual(got, "3.0.0")
    }
    
    func test_removeTag_runsTheRightCommands() throws {
        try subject.removeTag("1.0.0")
        XCTAssertEqual(shell.runAndPrintBashArgs.count, 1)
        if shell.runAndPrintBashArgs.count != 1 { return }
        XCTAssertEqual(shell.runAndPrintBashArgs[0], "git tag -d 1.0.0")
    }
    
    func test_tags_runsTheRightCommands() throws {
        shell.runBashStub = "1.0.0\n2.0.0"
        let got = try subject.tags()
        XCTAssertEqual(shell.runBashArgs.first, "git tag --list")
        XCTAssertEqual(got, ["1.0.0", "2.0.0"])
    }
    
    func test_addPaths_runsTheRightCommand() throws {
        try subject.add(paths: "first", "second")
        XCTAssertEqual(shell.runAndPrintBashArgs.first, "git add first second")
    }
    
    func test_addAll_runsTheRightCommand() throws {
        try subject.addAll()
        XCTAssertEqual(shell.runAndPrintBashArgs.first, "git add .")
    }
    
    func test_push_runsTheRightCommand() throws {
        try subject.push(remote: "origin", branch: "master", tags: true)
        XCTAssertEqual(shell.runAndPrintBashArgs.first, "git push origin master --tags")
    }
    
    func test_createBranch_runsTheRightCommand() throws {
        try subject.createBranch("release")
        XCTAssertEqual(shell.runAndPrintBashArgs.first, "git checkout -b release")
    }
}

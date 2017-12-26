import Foundation
import XCTest
import PathKit

@testable import SakeKit

final class RunSakefileTests: XCTestCase {
    
    var subject: RunSakefile!
    var runCommand: String!
    
    override func setUp() {
        super.setUp()
        subject = RunSakefile(path: "/project/",
                              arguments: ["tasks", "build"],
                              verbose: false,
                              sakefilePath: { $0 + "Sakefile.swift" },
                              fileDescriptionLibraryPath: { return Path("/libraries/description.dylib") },
                              runBashCommand: { (command) in
                            self.runCommand = command
        })
        try? subject.execute()
    }
    
    func test_execute_runsTheRightCommand() {
        print(runCommand)
        XCTAssertEqual(runCommand, "exec 2>/dev/null; swiftc --driver-mode=swift -L /libraries -I /libraries -lSakefileDescription /project/Sakefile.swift tasks build")
    }
    
    
}

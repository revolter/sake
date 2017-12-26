import Foundation

@testable import SakefileDescription

final class MockShell: Shelling {
    
    var runAndPrintBashCount: UInt = 0
    var runAndPrintBashArgs: [String] = []
    var runBashCount: UInt = 0
    var runBashArgs: [String] = []
    var runBashStub: String?
    var runAndPrintCount: UInt = 0
    var runAndPrintArgs: [(String, [String])] = []
    var runCount: UInt = 0
    var runArgs: [(String, [String])] = []
    var runStub: String?
    
    func runAndPrint(bash: String) throws {
        runAndPrintBashCount += 1
        runAndPrintBashArgs.append(bash)
    }

    func run(bash: String) throws -> String {
        runBashCount += 1
        runBashArgs.append(bash)
        return runBashStub ?? ""
    }
    
    func runAndPrint(command: String, _ args: String...) throws {
        try self.runAndPrint(command: command, args)
    }
    
    func runAndPrint(command: String, _ args: [String]) throws {
        runAndPrintCount += 1
        runAndPrintArgs.append((command, args))
    }
    
    func run(command: String, _ args: String...) throws -> String {
        return try self.run(command: command, args)
    }
    
    func run(command: String, _ args: [String]) throws -> String {
        runCount += 1
        runArgs.append((command, args))
        return runStub ?? ""
    }
    
}

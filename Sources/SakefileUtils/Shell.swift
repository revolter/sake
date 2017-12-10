import Foundation

// MARK: - Shelling

protocol Shelling {
    func runAndPrint(bash bashcommand: String) throws
    @discardableResult func run(command: String) throws -> String
}

// MARK: - Shell

public final class Shell: Shelling {
    
    public func runAndPrint(bash bashcommand: String) throws {
        // TODO
    }
    
    @discardableResult public func run(command: String) throws -> String {
        // TODO
        return ""
    }
    
}

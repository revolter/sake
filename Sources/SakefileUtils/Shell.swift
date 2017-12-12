import Foundation

// MARK: - ShellResult

public enum ShellResult {
    case success(String)
    case failure(Int32)
    public var exitCode: Int32? {
        switch self {
        case .failure(let code): return code
        default: return nil
        }
    }
    public var output: String? {
        switch self {
        case .success(let output): return output
        default: return nil
        }
    }
}

// MARK: - Shelling

public protocol Shelling {
    @discardableResult func run(command: String, _ args: String...) -> ShellResult
    @discardableResult func run(command: String, environment: [String: String], _ args: String...) -> ShellResult
    @discardableResult func run(command: String, printing: Bool, _ args: String...) -> ShellResult
    @discardableResult func run(command: String, environment: [String: String], printing: Bool, _ args: [String]) -> ShellResult
    @discardableResult func run(command: String, environment: [String: String], printing: Bool, _ args: String...) -> ShellResult
}

// MARK: - Shell

public final class Shell: Shelling {
    
    public func run(command: String, _ args: String...) -> ShellResult {
        return run(command: command, environment: [:], printing: true, args)
    }
    
    public func run(command: String, environment: [String : String], _ args: String...) -> ShellResult {
        return run(command: command, environment: environment, printing: true, args)
    }
    
    public func run(command: String, printing: Bool, _ args: String...) -> ShellResult {
        return run(command: command, environment: [:], printing: printing, args)
    }

    public func run(command: String, environment: [String: String], printing: Bool, _ args: String...) -> ShellResult {
        return run(command: command, environment: environment, printing: printing, args)
    }
    
    public func run(command: String, environment: [String: String], printing: Bool, _ args: [String]) -> ShellResult {
        let process = Process()
        process.environment = environment
        process.launchPath = "/Users/pedro.pinera.buendia/.swiftenv/shims/swift"
        process.arguments = ["\(args.joined(separator: " "))"]
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardInput = FileHandle.nullDevice
        if printing {
            pipe.fileHandleForReading.readabilityHandler = { pipe in
                if let line = String(data: pipe.availableData, encoding: .utf8) {
                    print(line)
                }
            }
        }
        process.launch()
        process.waitUntilExit()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output: String = String(data: data, encoding: .utf8)!
        if process.terminationStatus == 0 {
            return .success(output)
        } else {
            return .failure(process.terminationStatus)
        }
    }


}

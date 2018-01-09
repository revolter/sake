import Foundation

/// Shell error
public struct ShellError: Error, CustomStringConvertible, ShellExitCoding {

    /// Exit code
    public let exitCode: Int32
    
    /// Initializes the ShellError with the exit code
    ///
    /// - Parameter exitCode: exit code
    init(exitCode: Int32) {
        self.exitCode = exitCode
    }
    
    public var description: String {
        return "Execution error with code: \(exitCode)"
    }
    
}

// MARK: - Shelling

public protocol Shelling {
    func runAndPrint(bash: String) throws
    @discardableResult func run(bash: String) throws -> String
    func runAndPrint(command: String, _ args: String...) throws
    func runAndPrint(command: String, _ args: [String]) throws
    @discardableResult func run(command: String, _ args: String...) throws -> String
    @discardableResult func run(command: String, _ args: [String]) throws -> String
}

/// Cleans the command output trimming whitespaces and newlines.
///
/// - Parameter output: output to be cleaned.
/// - Returns: cleaned output.
func clean(output: String) -> String {
    var output = output
    output = output.trimmingCharacters(in: .whitespacesAndNewlines)
    return output
}

class CommandRunner {
    
    let command: String
    var outputQueue = DispatchQueue(label: "bash-output-queue")
    var outputData = Data()
    var errorData = Data()
    
    init(command: String) {
        self.command = command
    }
    
    func launch() {
        let process = Process()
        process.launchPath = "/bin/bash"
        process.arguments = ["-c", command]
        
        let outputPipe = Pipe()
        process.standardOutput = outputPipe
        let errorPipe = Pipe()
        process.standardError = errorPipe
        outputPipe.fileHandleForReading.waitForDataInBackgroundAndNotify()
        errorPipe.fileHandleForReading.waitForDataInBackgroundAndNotify()
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(receivedOutputData(notification:)),
                       name: NSNotification.Name.NSFileHandleDataAvailable,
                       object: outputPipe.fileHandleForReading)
        nc.addObserver(self, selector: #selector(receivedOutputError(notification:)),
                       name: NSNotification.Name.NSFileHandleDataAvailable,
                       object: errorPipe.fileHandleForReading)
        launch()
        process.waitUntilExit()
        // Return error
    }
    
    @objc func receivedOutputData(notification: NSNotification) {
        let handle = notification.object! as! FileHandle
        let data = handle.availableData
        if data.count == 0 { return }
        outputQueue.async { [unowned self] in
            self.outputData.append(data)
        }
    }
    
    @objc func receivedOutputError(notification: NSNotification) {
        let handle = notification.object! as! FileHandle
        let data = handle.availableData
        if data.count == 0 { return }
        outputQueue.async { [unowned self] in
            self.errorData.append(data)
        }
    }

}

// MARK: - Shell

public final class Shell: Shelling {
    
    typealias Execute = (_ launchPath: String, _ arguments: [String], _ printing: Bool, _ output: Bool) -> ShellCommandExecutor.ShellOutput
    
    // MARK: - Attributes
    
    fileprivate let execute: Execute
//    fileprivate static var activeCommand: ShellCommandExecutor?
    
    // MARK: - Init
    
    init(execute: @escaping Execute = Shell.execute) {
        self.execute = execute
        Signals.trap(signal: .int) { signal in
//            Shell.activeCommand?.process.terminate()
        }
    }
    
    // MARK: - Shelling
    
    public func runAndPrint(bash: String) throws {
        try runAndPrint(command: "/bin/bash", "-c", bash)
    }
    
    public func run(bash: String) throws -> String {
        return try run(command: "/bin/bash", "-c", bash)
    }
    
    public func runAndPrint(command: String, _ args: String...) throws {
        try runAndPrint(command: command, args)
    }
    
    public func runAndPrint(command: String, _ args: [String]) throws {
        let result = execute(command: command, printing: true, output: false, args)
        if result.exitCode != 0 {
            throw ShellError(exitCode: result.exitCode)
        }
    }
    
    public func run(command: String, _ args: String...) throws -> String {
        return try run(command: command, args)
    }
    
    public func run(command: String, _ args: [String]) throws -> String {
        let result = execute(command: command, printing: false, output: true, args)
        if result.exitCode == 0 {
            return result.output ?? ""
        } else {
            throw ShellError(exitCode: result.exitCode)
        }
    }
    
    // MARK: - Fileprivate
    
    @discardableResult fileprivate func execute(command: String,
                                                printing: Bool,
                                                output: Bool,
                                                _ args: [String]) -> ShellCommandExecutor.ShellOutput {
        func launchpath(_ command: String) -> String {
            if command.contains("/") { return command }
            let result = execute("/user/bin/which", [command], false, true)
            return result.output ?? command
        }
        return execute(launchpath(command), args, printing, output)
    }
    
    fileprivate static func execute(launchPath: String,
                                    arguments: [String],
                                    printing: Bool,
                                    output: Bool) -> ShellCommandExecutor.ShellOutput {
        let command = ShellCommandExecutor(launchPath: launchPath,
                                           arguments: arguments,
                                           printing: printing,
                                           output: output)
        Shell.activeCommand = command
        let output = command.execute()
        Shell.activeCommand = nil
        return output
    }

}

import Foundation

typealias ShellOutput = (output: String?, exitCode: Int32)

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
    let printOutput: Bool
    let collectOutputData: Bool
    let process = Process()
    let arguments: [String]
    
    init(command: String,
         arguments: [String],
         printOutput: Bool,
         collectOutputData: Bool = false) {
        self.command = command
        self.arguments = arguments
        self.printOutput = printOutput
        self.collectOutputData = collectOutputData
    }
    
    func launch() -> Int32 {
        process.launchPath = command
        process.arguments = arguments
        let outputPipe = Pipe()
        process.standardOutput = outputPipe
        let errorPipe = Pipe()
        process.standardError = errorPipe
        outputPipe.fileHandleForReading.waitForDataInBackgroundAndNotify()
        errorPipe.fileHandleForReading.waitForDataInBackgroundAndNotify()
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(receivedData(notification:)),
                       name: NSNotification.Name.NSFileHandleDataAvailable,
                       object: outputPipe.fileHandleForReading)
        nc.addObserver(self, selector: #selector(receivedData(notification:)),
                       name: NSNotification.Name.NSFileHandleDataAvailable,
                       object: errorPipe.fileHandleForReading)
        process.launch()
        process.waitUntilExit()
        return process.terminationStatus
    }
    
    func terminate() {
        process.terminate()
    }
    
    @objc func receivedData(notification: NSNotification) {
        let handle = notification.object! as! FileHandle
        let data = handle.availableData
        if data.count == 0 { return }
        outputQueue.async { [unowned self] in
            if self.printOutput {
                if let line = String(data: data, encoding: .utf8) {
                    print(clean(output: line))
                }
            }
            if !self.collectOutputData { return }
            self.outputData.append(data)
            
        }
    }
    
}

// MARK: - Shell

public final class Shell: Shelling {
    
    // MARK: - Attributes
    
    fileprivate static var activeCommandRunner: CommandRunner?
    
    // MARK: - Init
    
    init() {
        Signals.trap(signal: .int) { signal in
            Shell.activeCommandRunner?.terminate()
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
        let result = execute(command: command, arguments: args, printing: true, output: false)
        if result.exitCode != 0 {
            throw ShellError(exitCode: result.exitCode)
        }
    }
    
    public func run(command: String, _ args: String...) throws -> String {
        return try run(command: command, args)
    }
    
    public func run(command: String, _ args: [String]) throws -> String {
        let result = execute(command: command, arguments: args, printing: false, output: true)
        if result.exitCode == 0 {
            return result.output ?? ""
        } else {
            throw ShellError(exitCode: result.exitCode)
        }
    }
    
    // MARK: - Fileprivate
    
    func execute(command: String,
                 arguments: [String],
                 printing: Bool,
                 output: Bool) -> ShellOutput {
        if !command.contains("/") {
            let result = execute(command: "/user/bin/which",
                                 arguments: [command],
                                 printing: false,
                                 output: true)
            let absoluteCommand = result.output ?? command
            return execute(command: absoluteCommand, arguments: arguments, printing: printing, output: output)
        }
        let runner = CommandRunner(command: command,
                                   arguments: arguments,
                                   printOutput: printing,
                                   collectOutputData: output)
        Shell.activeCommandRunner = runner
        let exitCode = runner.launch()
        Shell.activeCommandRunner = nil
        var outputString: String?
        if output {
            outputString = String.init(data: runner.outputData, encoding: .utf8)
        }
        return (output: outputString, exitCode: exitCode)
    }
    
}

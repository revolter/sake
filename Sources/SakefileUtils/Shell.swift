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
    
    /// Created by Martin Kim Dung-Pham - github.com/q231950/commands ///
    class StandardOutOutputStream: OutputStream {
        var printing: Bool
        var data: Data = Data()
        
        init(printing: Bool = true) {
            self.printing = printing
            super.init(toMemory: ())
        }
        override func write(_ buffer: UnsafePointer<UInt8>, maxLength len: Int) -> Int {
            let data = Data.init(bytes: buffer, count: len)
            self.data.append(data)
            let text = String(data: data, encoding: .utf8)
            if printing {
                print("\(text ?? "")")
            }
            return len
        }
        override func close() {}
    }
    
    class CommandExecutor {
        
        private let outputStream: StandardOutOutputStream
        private let inputPipe = Pipe()
        let launchPath: String
        let arguments: [String]
        let process = Process()
        
        public init(launchPath: String, arguments: [String], outputStream: StandardOutOutputStream = StandardOutOutputStream()) {
            self.launchPath = launchPath
            self.arguments = arguments
            self.outputStream = outputStream
        }
        
        public func execute() -> (String, Int32) {
            process.launchPath = launchPath
            process.arguments = arguments
            let pipe = outputStreamWritingPipe()
            process.standardOutput = pipe
            process.standardError = pipe
            process.standardInput = inputPipe
            process.launch()
            process.waitUntilExit()
            let output = String(data: outputStream.data, encoding: .utf8) ?? ""
            return (clean(output: output), process.terminationStatus)
        }
        
        fileprivate func clean(output: String) -> String {
            var output = output
            let firstnewline = output.index(of: "\n")
            if firstnewline == nil || output.index(after: firstnewline!) == output.endIndex {
                output = output.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            return output
        }
        
        private func outputStreamWritingPipe() -> Pipe {
            let outputPipe = Pipe()
            outputPipe.fileHandleForReading.readabilityHandler = { [weak self] handle in
                let data = handle.availableData
                if data.count > 0 {
                    _ = self?.outputStream.write([UInt8](data), maxLength: data.count)
                }
            }
            return outputPipe
        }
        
        public func write(input: String) {
            if let data = "\(input)\n".data(using: .utf8) {
                inputPipe.fileHandleForWriting.write(data)
            }
        }
        
        public func terminate() {
            process.terminate()
        }
    }
    /// Created by Martin Kim Dung-Pham - github.com/q231950/commands ///
    
    
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
        func launchpath(_ command: String) -> String {
            if command.contains("/") {
                return command
            } else {
                let result = CommandExecutor(launchPath: "/usr/bin/which",
                                             arguments: [command],
                                             outputStream: StandardOutOutputStream(printing: false)).execute()
                return result.0
            }
        }
        let result = CommandExecutor(launchPath: launchpath(command),
                                     arguments: args,
                                     outputStream: StandardOutOutputStream(printing: printing)).execute()
        if result.1 == 0 {
            return .success(result.0)
        } else {
            return .failure(result.1)
        }
    }
    
}

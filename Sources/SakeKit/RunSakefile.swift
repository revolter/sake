import Foundation
import PathKit
import SwiftShell

/// Runs the Sakefile.
public class RunSakefile {
    
    // MARK: - Attributes

    /// Path where the Sakefile.swift file is.
    let path: String
    
    /// Arguments to be passed.
    let arguments: [String]
    
    // MARK: - Init
    
    /// Default constructor.
    ///
    /// - Parameters:
    ///   - path: path where the Sakefile.swift file is.
    ///   - arguments: arguments to be passed.
    public init(path: String,
                arguments: [String]) {
        self.path = path
        self.arguments = arguments
    }
    
    // MARK: - Public
    
    /// Executes the Sakefile.swift
    ///
    /// - Throws: an error if the execution fails for any reason.
    public func execute() throws {
        guard let sakefilePath = sakefilePath() else {
            throw "Couldn't find Sakefile.swift in directory \(path)"
        }
        guard let libraryPath = Runtime.libraryFolder() else {
            throw "Couldn't find libSakefileDescription.dylib to link against to"
        }
        var arguments: [String] = []
        arguments += ["--driver-mode=swift"]
        arguments += ["-L", libraryPath.normalize().string]
        arguments += ["-I", libraryPath.normalize().string]
        arguments += ["-lSakefileDescription"]
        arguments += [sakefilePath.string]
        arguments += self.arguments
        do {
            try runAndPrint("swiftc", arguments)
        } catch {
            throw "Error running task"
        }
    }
    
    // MARK: - Fileprivate
    
    fileprivate func sakefilePath() -> Path? {
        let sakefilePath = (Path(path) + "Sakefile.swift").normalize()
        if sakefilePath.exists {
            return sakefilePath
        }
        return nil
    }
    
}

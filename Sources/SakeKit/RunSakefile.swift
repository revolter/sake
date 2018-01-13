import Foundation
import PathKit
import SakefileDescriptionV1

/// Runs the Sakefile.
public class RunSakefile {

    // MARK: - Attributes

    /// Path where the Sakefile.swift file is.
    let path: String

    /// Arguments to be passed.
    let arguments: [String]

    /// Run bash command.
    let runBashCommand: (String) throws -> ()

    /// Returns the Sakefile.swift path if it exists in the given directory.
    let sakefilePath: (Path) -> Path?

    /// Returns the file description library path.
    let fileDescriptionLibraryPath: () -> Path?

    // MARK: - Init

    /// Default constructor.
    ///
    /// - Parameters:
    ///   - path: path where the Sakefile.swift file is.
    ///   - arguments: arguments to be passed.
    convenience public init(path: String,
                            arguments: [String]) {
        self.init(path: path,
                  arguments: arguments,
                  sakefilePath: RunSakefile.sakefilePath,
                  fileDescriptionLibraryPath: { Runtime.filedescriptionLibraryPath() },
                  runBashCommand: { try Utils.shell.runAndPrint(bash: $0) })
    }

    /// Default constructor.
    ///
    /// - Parameters:
    ///   - path: path where the Sakefile.swift file is.
    ///   - arguments: arguments to be passed.
    ///   - sakefilePath: returns the Sakefile.swift path if it exists in the given directory.
    ///   - fileDescriptionLibraryPath: returns the file description library path.
    ///   - runBashCommand: closure runs the bash command.
    init(path: String,
         arguments: [String],
         sakefilePath: @escaping (Path) -> Path?,
         fileDescriptionLibraryPath: @escaping () -> Path?,
         runBashCommand: @escaping (String) throws -> Void) {
        self.path = path
        self.arguments = arguments
        self.sakefilePath = sakefilePath
        self.fileDescriptionLibraryPath = fileDescriptionLibraryPath
        self.runBashCommand = runBashCommand
    }

    // MARK: - Public

    /// Executes the Sakefile.swift
    ///
    /// - Throws: an error if the execution fails for any reason.
    public func execute() throws {
        guard let sakefilePath = sakefilePath(Path(path)) else {
            throw "Couldn't find Sakefile.swift in directory \(path)"
        }
        guard let filedescriptionLibraryPath = fileDescriptionLibraryPath() else {
            throw "Couldn't find libSakefileDescription.dylib to link against to"
        }

        var arguments: [String] = []
        arguments += ["--driver-mode=swift"]
        arguments += ["-suppress-warnings"]
        arguments += ["-L", filedescriptionLibraryPath.parent().normalize().string]
        arguments += ["-I", filedescriptionLibraryPath.parent().normalize().string]
        arguments += ["-lSakefileDescription"]
        arguments += ["-lSwiftShell"]
        arguments += [sakefilePath.string]
        arguments += self.arguments
        do {
            let bashCommand = "swiftc \(arguments.joined(separator: " "))"
            try runBashCommand(bashCommand)
        } catch {
            throw "Running 'sake \(self.arguments.joined(separator: " "))' errored"
        }
    }

    // MARK: - Fileprivate

    static func sakefilePath(path: Path) -> Path? {
        let sakefilePath = (path + "Sakefile.swift").normalize()
        if sakefilePath.exists {
            return sakefilePath
        }
        return nil
    }

}

import Foundation

/// Generates a base Sakefile.swift
public class GenerateSakefile {

    // MARK: - Attributes

    /// Path to the folder where the Sakefile.swift will be generated.
    fileprivate let path: String

    /// File manager.
    fileprivate let fileManager: FileManager = .default

    // MARK: - Init

    /// Initializes the command that generates a base Sakefile.swift
    ///
    /// - Parameter path: path to the folder where the Sakefile.swift will be generated.
    public init(path: String) {
        self.path = path
    }

    // MARK: - Public

    /// Generates the base Sakefile.swift.
    ///
    /// - Throws: an error if the generation fails.
    public func execute() throws {
        let sakefilePath = URL.init(fileURLWithPath: path).appendingPathComponent("Sakefile.swift")
        if fileManager.fileExists(atPath: sakefilePath.path) {
            throw "There's a Sakefile already at \(sakefilePath.path)"
        }
        try GenerateSakefile.defaultContent()
            .write(to: sakefilePath, atomically: true, encoding: .utf8)
        print("Sakefile.swift generated")
    }

    static func defaultContent() -> String {
        return """
        import SakefileDescription
        import SakefileUtils

        Sake(tasks: [
            Task("build", description: "Builds the project") {
                // Here is where you define your build task
            }],
            hooks: [
                .beforeAll({ /* Before all the tasks */ })
            ]
        )
        """
    }

}

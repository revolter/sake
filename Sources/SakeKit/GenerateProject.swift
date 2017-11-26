import Foundation
import XcodeGenKit
import xcproj
import PathKit
import ProjectSpec

/// Generates a Xcode Project to edit the Sakefile.
public class GenerateProject {
    
    // MARK: - Attributes

    /// Path to the folder where the Sakefile.swift is.
    fileprivate let path: String
    
    /// File manager.
    fileprivate let fileManager: FileManager = .default
    
    // MARK: - Init
    
    /// Initializes the command with the path to the folder where the Sakefile.swift is.
    ///
    /// - Parameter path: path to the folder where the Sakefile.swift file is.
    public init(path: String) {
        self.path = path
    }
    
    // MARK: - Public
    
    /// Generates the Xcode project.
    ///
    /// - Throws: error if the generation fails.
    public func execute() throws {
        let projectPath = URL.init(fileURLWithPath: path).appendingPathComponent("Sakefile.xcodeproj")
        if fileManager.fileExists(atPath: projectPath.path) {
            try fileManager.removeItem(at: projectPath)
        }
        let targets: [Target] = [
            Target(name: "Sakefile",
                   type: .staticLibrary,
                   platform: .macOS,
                   settings: Settings(buildSettings: [
                    "PRODUCT_BUNDLE_IDENTIFIER": "com.sake"
                    ], configSettings: [:], groups: []),
                   configFiles: [:],
                   sources: [
                    TargetSource.init(path: "Sakefile.swift",
                                      name: "Sakefile.swift",
                                      compilerFlags: [],
                                      excludes: [],
                                      type: TargetSource.SourceType.file)
                ])
        ]
        let settings: Settings = Settings(buildSettings: [:], configSettings: [:], groups: [])
        let settingsGroup: [String: Settings] = [:]
        let schemes: [Scheme] = []
        let options: ProjectSpec.Options = ProjectSpec.Options()
        let spec = ProjectSpec(basePath: "",
                               name: "Sakefile",
                               targets: targets,
                               settings: settings,
                               settingGroups: settingsGroup,
                               schemes: schemes,
                               options: options,
                               fileGroups: [],
                               configFiles: [:],
                               attributes: [:])
        let projectGenerator = ProjectGenerator(spec: spec)
        let project = try projectGenerator.generateProject()
        try project.write(path: Path(projectPath.path), override: true)
    }
    
}

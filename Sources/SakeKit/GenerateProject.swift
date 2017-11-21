import Foundation
import XcodeGenKit
import xcproj
import PathKit
import ProjectSpec

public class GenerateProject {
    
    // MARK: - Attributes
    
    fileprivate let path: String
    fileprivate let fileManager: FileManager = .default
    
    // MARK: - Init
    
    public init(path: String) {
        self.path = path
    }
    
    // MARK: - Public
    
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

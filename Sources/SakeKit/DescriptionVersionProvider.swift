import Foundation
import PathKit
import SakefileDescriptionV1

/// Returns the version of the description library that needs to be used.
class DescriptionVersionProvider {
    
    // MARK: - Attributes
    
    /// Sakefile.swift path.
    private let sakefilePath: Path
    
    /// SakefileDescription last version
    private let descriptionLastVersion: String
    
    /// Reads the content at a given path
    private let read: (Path) throws -> String
    
    /// Default constructor.
    ///
    /// - Parameter sakefilePath: Sakefile.swift path
    /// - Parameter descriptionLastVersion: description library last version.
    init(sakefilePath: Path,
         descriptionLastVersion: String = "1",
         read: @escaping (Path) throws -> String = { try String(contentsOf: $0.url) } ) {
        self.sakefilePath = sakefilePath
        self.descriptionLastVersion = descriptionLastVersion
        self.read = read
    }
    
    /// Returns the version of the SakefileDescription library that has to be used.
    ///
    /// - Returns: version to be used.
    /// - Throws: error if the Sakefile.swift cannot be read.
    func version() throws -> String {
        let sakefileContent = try read(sakefilePath)
        let descriptionVersion = versionFrom(sakefileContent: sakefileContent)
        return descriptionVersion ?? descriptionLastVersion
    }
    
    func versionFrom(sakefileContent: String) -> String? {
        let regex = try! NSRegularExpression(pattern: "//\\s*sakefile-description-version:([0-9]+)", options: [])
        let range = NSRange(location: 0, length: sakefileContent.utf16.count)
        guard let result = regex.firstMatch(in: sakefileContent, options: [], range: range) else { return nil }
        return (sakefileContent as NSString).substring(with: result.range(at: 1))
    }
    
}

import Foundation
import PathKit
import SwiftShell

class Runtime {

    static func filedescriptionLibraryPath(exists: (Path) -> Bool = { $0.exists }) -> Path? {
        if let librariesPath = librariesPath,
            exists(Path(librariesPath) + "libSakefileDescription.dylib") {
            return Path(librariesPath) + "libSakefileDescription.dylib"
        }
        return Runtime.librariesFolders()
            .first { (potentialPath) -> Bool in
                exists(Path(potentialPath) + "libSakefileDescription.dylib")
            }.flatMap({ (Path($0)  + "libSakefileDescription.dylib").absolute() })
    }
    
    static func utilsLibraryPath(exists: (Path) -> Bool = { $0.exists }) -> Path? {
        if let librariesPath = librariesPath,
            exists(Path(librariesPath) + "libSakefileUtils.dylib") {
            return Path(librariesPath) + "libSakefileUtils.dylib"
        }
        return Runtime.librariesFolders()
            .first { (potentialPath) -> Bool in
                exists(Path(potentialPath) + "libSakefileUtils.dylib")
            }.flatMap({ (Path($0) + "libSakefileUtils.dylib").absolute() })
    }
    
    static func librariesFolders() -> [String] {
        return [
            ".build/debug", // Local
            ".build/release" // Local
        ]
    }
    
}

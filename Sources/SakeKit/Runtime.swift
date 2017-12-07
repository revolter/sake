import Foundation
import PathKit

class Runtime {

    static func filedescriptionLibraryPath() -> Path? {
        if let librariesPath = librariesPath,
            (Path(librariesPath) + "libSakefileDescription.dylib").exists {
            return Path(librariesPath) + "libSakefileDescription.dylib"
        }
        return Runtime.librariesFolders()
            .first { (potentialPath) -> Bool in
                (Path(potentialPath) + "libSakefileDescription.dylib").exists
            }.flatMap({ (Path($0)  + "libSakefileDescription.dylib").absolute() })
    }
    
    static func utilsLibraryPath() -> Path? {
        if let librariesPath = librariesPath,
            (Path(librariesPath) + "libSakefileUtils.dylib").exists {
            return Path(librariesPath) + "libSakefileUtils.dylib"
        }
        return Runtime.librariesFolders()
            .first { (potentialPath) -> Bool in
                (Path(potentialPath) + "libSakefileUtils.dylib").exists
            }.flatMap({ (Path($0) + "libSakefileUtils.dylib").absolute() })
    }
    
    static func librariesFolders() -> [String] {
        return [
            ".build/debug", // Local
            ".build/release" // Local
        ]
    }
    
}

import Foundation
import PathKit

class Runtime {

    static func libraryFolder() -> Path? {
        if let libraryPath = libraryPath {
            return Path(libraryPath)
        }
        return [
            ".build/debug", // Local
            ".build/release" // Local
            ].first { (potentialPath) -> Bool in
                (Path(potentialPath) + "libSakefileDescription.dylib").exists
            }.flatMap({Path($0)})
    }

}

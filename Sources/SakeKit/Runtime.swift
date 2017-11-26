import Foundation
import PathKit

class Runtime {
    
    static func libraryFolder() -> Path? {
        return [
            ".build/debug", // Local
            ".build/release", // Local
            "/usr/local/lib/danger", // Homebrew
            ].first { (potentialPath) -> Bool in
                (Path(potentialPath) + "libSakefileDescription.dylib").exists
            }.flatMap({Path($0)})
    }
    
}

import Foundation
import PathKit

public class RunSakefile {
    
    // MARK: - Attributes
    
    let path: String
    let arguments: [String]
    
    // MARK: - Init
    
    public init(path: String,
                arguments: [String]) {
        self.path = path
        self.arguments = arguments
    }
    
    // MARK: - Public
    
    public func execute() throws {
        guard let sakefilePath = sakefilePath() else {
            throw "Couldn't find Sakefile.swift in directory \(path)"
        }

        // TODO
        
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


//PATH/TO/SNAPSHOT/usr/bin/swiftc \
//--driver-mode=swift \
//-I PATH/TO/SNAPSHOT/usr/lib/swift/pm \
//-L PATH/TO/SNAPSHOT/usr/lib/swift/pm \
//-lPackageDescription \
//PATH/TO/Package.swift \
//-fileno 3


import Foundation

/// Version error
///
/// - invalidFormat: invalid format.
public enum VersionError {
    case invalidFormat
}

/// Semantic version
public struct Version {

    // MARK: - Attributes

    /// Major
    public let major: UInt

    /// Minor
    public let minor: UInt

    /// Patch
    public let patch: UInt
    
    init?(_ string: String) {
        let components = string.split(separator: ".").reduce(into: (0,0,0)) { (prev, next) in
            
        }
        
    }
    
}

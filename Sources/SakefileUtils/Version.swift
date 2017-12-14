import Foundation

/// Version error
///
/// - invalidFormat: invalid format.
public enum VersionError: Error {
    case invalidFormat
}

/// Semantic version
public struct Version: CustomStringConvertible {

    // MARK: - Attributes

    /// Major
    public let major: UInt

    /// Minor
    public let minor: UInt

    /// Patch
    public let patch: UInt
    
    public init(_ string: String) throws {
        let components = try string.split(separator: ".").map { (componentString) -> UInt in
            guard let uint = UInt.init(componentString) else { throw VersionError.invalidFormat }
            return uint
        }
        major = components[0]
        minor = (components.count == 2) ? components[1] : 0
        patch = (components.count == 3) ? components[2] : 0
    }
    
    public init(major: UInt, minor: UInt? = 0, patch: UInt? = 0) {
        self.major = major
        self.minor = minor ?? 0
        self.patch = patch ?? 0
    }
    
    // MARK: - Public
    
    public var string: String {
        return "\(major).\(minor).\(patch)"
    }
    
    public var description: String {
        return self.string
    }
    
    public func bumpMajor() -> Version {
        return Version(major: major + 1, minor: 0, patch: 0)
    }
    
    public func bumpMinor() -> Version {
        return Version(major: major, minor: minor+1, patch: 0)
    }
    
    public func bumpPatch() -> Version {
        return Version(major: major, minor: minor, patch: patch+1)
    }
    
}

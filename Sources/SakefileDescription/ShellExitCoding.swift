import Foundation

/// Protocol that defines that the element that conforms it can return a shell exit code.
public protocol ShellExitCoding {
    
    /// Shell exit code.
    var exitCode: Int { get }

}

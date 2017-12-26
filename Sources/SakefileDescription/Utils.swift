import SakefileDescription
import Foundation

// MARK: - Fileprivate

fileprivate var httpInstance: HTTP!
fileprivate var shellInstance: Shell!
fileprivate var gitInstance: Git!

// MARK: - Utils

// Utils is an enum so it's not initializable
/// a bunch of useful Utilities
public enum Utils {

    /// HTTP
    public static var http = HTTP()
    
    /// Shell
    public static var shell = Shell()

    /// Git
    public static let git = Git(shell: shell)
}

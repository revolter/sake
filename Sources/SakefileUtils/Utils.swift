import SakefileDescription
import Foundation

// MARK: - Fileprivate

fileprivate var httpInstance: HTTP!
fileprivate var shellInstance: Shell!
fileprivate var gitInstance: Git!

// MARK: - Utils Extension

public extension Utils {

    /// HTTP
    public static var http = HTTP()
    
    /// Shell
    public static var shell = Shell()

    /// Git
    public static let git = Git(shell: shell)
}

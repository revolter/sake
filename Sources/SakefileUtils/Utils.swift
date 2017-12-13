import SakefileDescription
import Foundation

// MARK: - Fileprivate

fileprivate var httpInstance: HTTP!
fileprivate var shellInstance: Shell!
fileprivate var gitInstance: Git!

// MARK: - Utils Extension

public extension Utils {

    /// HTTP
    public var http: HTTP {
        if httpInstance == nil {
            httpInstance = HTTP()
        }
        return httpInstance
    }
    
    /// Shell
    public var shell: Shell {
        if shellInstance == nil {
            shellInstance = Shell()
        }
        return shellInstance
    }
    
    /// Git
    public var git: Git {
        if gitInstance == nil {
            gitInstance = Git(shell: shell)
        }
        return gitInstance
    }
}

import SakefileDescription
import Foundation

fileprivate var httpInstance: HTTP!
fileprivate var shellInstance: Shell!
fileprivate var gitInstance: Git!

public extension Utils {
    
    public var http: HTTP {
        if httpInstance == nil {
            httpInstance = HTTP()
        }
        return httpInstance
    }
    
    public var shell: Shell {
        if shellInstance == nil {
            shellInstance = Shell()
        }
        return shellInstance
    }
    
    public var git: Git {
        if gitInstance == nil {
            gitInstance = Git(shell: shell)
        }
        return gitInstance
    }
}

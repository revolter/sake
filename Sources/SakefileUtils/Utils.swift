import SakefileDescription
import Foundation

fileprivate var httpInstance: HTTP!

public extension Utils {
    
    public var http: HTTP {
        if httpInstance == nil {
            httpInstance = HTTP()
        }
        return httpInstance
    }
    
}

import Foundation

struct StringError: Error, CustomStringConvertible {
    let description: String
}

extension String {
    
    var error: Error {
        return StringError(description: self)
    }
    
}

import Foundation
import SakefileDescription

public  final class HTTP {
    
    /// URL Session used to send the requests.
    let session: URLSession = .shared
    
    /// Executes a request and parses the response using the parser function.
    ///
    /// - Parameters:
    ///   - request: request to be sent.
    ///   - parse: function to parse the response Data.
    /// - Returns: parsed response.
    /// - Throws: an error if the request/parsing fails.
    public func execute<T>(request: URLRequest, parse: @escaping (Data) throws -> T) throws -> T? {
        let semaphore = DispatchSemaphore(value: 0)
        var error: Error?
        var value: T?
        session.dataTask(with: request) { (data, _, _error) in
            defer {
                semaphore.signal()
            }
            if let _error = _error {
                error = _error
            } else if let data = data {
                do {
                    value = try parse(data)
                } catch let _error {
                    error = _error
                }
            }
            }.resume()
        semaphore.wait()
        if let error = error { throw error }
        return value
    }
    
    /// Executes a request and parses the JSON response.
    ///
    /// - Parameter request: request to be executed.
    /// - Returns: JSON response.
    /// - Throws: error if the request/parsing fails.
    public func executeJSON(request: URLRequest) throws -> Any? {
        return try self.execute(request: request) { (data) -> Any in
            return try JSONSerialization.jsonObject(with: data, options: [])
        }
    }
}

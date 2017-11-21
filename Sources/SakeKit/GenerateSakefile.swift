import Foundation

public class GenerateSakefile {
    
    // MARK: - Attributes
    
    fileprivate let path: String
    fileprivate let fileManager: FileManager = .default
    
    // MARK: - Init
    
    public init(path: String) {
        self.path = path
    }
    
    // MARK: - Public
    
    public func execute() throws {
        let sakefilePath = URL.init(fileURLWithPath: path).appendingPathComponent("Sakefile")
        if fileManager.fileExists(atPath: sakefilePath.path) {
            throw "There's a Sakefile already at \(sakefilePath.path)".error
        }
        let content = """
        import SakefileDescription

        tasks {
            $0.add("build") {
                // Add your task here
            }
        }.run()
        """
        try content.write(to: sakefilePath, atomically: true, encoding: .utf8)
    }
    
}

import Foundation

// MARK: - Git

public final class Git {
    
    // MARK: - Attributes
    
    let shell: Shelling
    
    // MARK: - Init
    
    init(shell: Shelling) {
        self.shell = shell
    }
    
    public func branch() throws -> String {
        try verifyGitDirectory()
        return try shell.run(bash: "git rev-parse --abbrev-ref HEAD")
    }
    
    public func anyChanges() throws -> Bool {
        try verifyGitDirectory()
        let changesCount = try shell.run(bash: "git diff --stat --numstat | wc -l")
        return Int(changesCount) != 0
    }
    public func commitAll(message: String) throws  {
        try verifyGitDirectory()
        try shell.runAndPrint(bash: "git add .")
        try shell.runAndPrint(bash: "git commit -m '\(message)'")
    }
    
    public func addRemote(_ remote: String, url: String) throws {
        try verifyGitDirectory()
        try shell.runAndPrint(bash: "git remote add \(remote) \(url)")
    }
    
    public func removeRemote(_ remote: String) throws {
        try verifyGitDirectory()
        try shell.runAndPrint(bash: "git remote remove \(remote)")
    }
    
    // MARK: - Fileprivate
    
    fileprivate func verifyGitDirectory() throws {
        let currentDirecory = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        let gitDirectory = currentDirecory.appendingPathComponent(".git")
        if !FileManager.default.fileExists(atPath: gitDirectory.path) {
            throw "The current directory is not a git directory"
        }
    }
}

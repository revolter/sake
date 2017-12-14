import Foundation

// MARK: - Git

public final class Git {
    
    // MARK: - Attributes
    
    let shell: Shelling
    let verifyGit: () throws -> Void
    
    // MARK: - Init
    
    init(shell: Shelling,
         verifyGit: @escaping () throws -> Void = Git.verifyGitDirectory) {
        self.shell = shell
        self.verifyGit = verifyGit
    }
    
    public func branch() throws -> String {
        try verifyGit()
        return try shell.run(bash: "git rev-parse --abbrev-ref HEAD")
    }
    
    public func anyChanges() throws -> Bool {
        try verifyGit()
        let changesCount = try shell.run(bash: "git diff --stat --numstat | wc -l")
        return Int(changesCount) != 0
    }
    public func commitAll(message: String) throws  {
        try verifyGit()
        try shell.runAndPrint(bash: "git add .")
        try shell.runAndPrint(bash: "git commit -m '\(message)'")
    }
    
    public func addRemote(_ remote: String, url: String) throws {
        try verifyGit()
        try shell.runAndPrint(bash: "git remote add \(remote) \(url)")
    }
    
    public func removeRemote(_ remote: String) throws {
        try verifyGit()
        try shell.runAndPrint(bash: "git remote remove \(remote)")
    }
    
    public func tag(_ tag: String) throws {
        try verifyGit()
        try shell.runAndPrint(bash: "git tag \(tag)")
    }
    
    public func removeTag(_ tag: String) throws {
        try verifyGit()
        try shell.runAndPrint(bash: "git tag -d \(tag)")
    }
    
    public func tags() throws -> [String] {
        try verifyGit()
        return try shell.run(bash: "git tag --list").split(separator: "\n").map(String.init)
    }
    
    // MARK: - Fileprivate
    
    fileprivate static func verifyGitDirectory() throws {
        let currentDirecory = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        let gitDirectory = currentDirecory.appendingPathComponent(".git")
        if !FileManager.default.fileExists(atPath: gitDirectory.path) {
            throw "The current directory is not a git directory"
        }
    }
}

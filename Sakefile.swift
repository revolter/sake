import Foundation
import SakefileDescription
import SakefileUtils

// MARK: - Tasks

enum Task: String, CustomStringConvertible {
    case documentation = "docs"
    case continuousIntegration = "ci"
    case release = "release"
    case updateFormula = "update_formula"
    var description: String {
        switch self {
        case .documentation:
            return "Generates the project documentation"
        case .continuousIntegration:
            return "Runs the the operations that are executed on CI"
        case .release:
            return "Releases a new version of the Sake"
        case .updateFormula:
            return "Updates the Homebrew formula version"
        }
    }
}

func generateDocs() throws {
    try Utils.shell.runAndPrint(bash: "swift package generate-xcodeproj")
    try Utils.shell.runAndPrint(bash: "bundle exec jazzy --clean --sdk macosx --xcodebuild-arguments -scheme,sake --skip-undocumented")
}

func createVersion(version: String, branch: String) throws {
    try Utils.git.createBranch(branch)
    print("> Building the project")
    try Utils.shell.runAndPrint(bash: "swift build")
    print("> Generating docs")
    try generateDocs()
    try Utils.git.addAll()
    try Utils.git.commitAll(message: "[\(branch)] Bump version")
    try Utils.git.tag(version)
    try Utils.git.push(remote: "origin", branch: branch, tags: true)
}

func updateFormula(version: String, branch: String) throws {
    let formulaPath = "Formula/sake.rb"
    print("> Updating formula to \(version)")
    let archiveURL = "https://github.com/xcodeswift/sake/archive/\(version).tar.gz"
    try Utils.shell.runAndPrint(bash: "curl -LSs \(archiveURL) -o sake.tar.gz")
    let sha = try Utils.shell.run(bash: "shasum -a 256 sake.tar.gz | awk '{printf $1}'")
    _ = try Utils.shell.run(bash: "sed -i \"\" 's|version .*$|version \"\(version)\"|' \(formulaPath)")
    _ = try Utils.shell.run(bash: "sed -i \"\" 's|sha256 .*$|sha256 \"\(sha)\"|' \(formulaPath)")
    try Utils.shell.runAndPrint(bash: "rm sake.tar.gz")
    print("> Commiting and pushing the changes to release/\(version)")
    try Utils.git.add(paths: formulaPath)
    try Utils.git.commit(message: "[\(branch)] Update formula")
    try Utils.git.push(remote: "origin", branch: branch)
}

Sake<Task> {
    try $0.task(.documentation) {
        try generateDocs()
    }
    try $0.task(.continuousIntegration) {
        print("> Linting the project")
        try Utils.shell.runAndPrint(bash: "swiftlint")
        print("> Building the project")
        try Utils.shell.runAndPrint(bash: "swift build")
        print("> Testing the project")
        try Utils.shell.runAndPrint(bash: "swift test")
    }
    try $0.task(.release) {
        if try Utils.git.anyChanges() { throw "Commit all your changes before starting the release" }
        if try Utils.git.branch() != "master" { throw "The release process should be initialized from master" }
        let nextVersion = try Version(Utils.git.lastTag()).bumpingMinor()
        let branch = "release/\(nextVersion.string)"
        try createVersion(version: nextVersion.string, branch: branch)
        try updateFormula(version: nextVersion.string, branch: branch)
    }
}.run()

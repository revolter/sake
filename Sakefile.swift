import Foundation
import SakefileDescription

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

Sake(tasks: [
    Task("docs", description: "Generates the project documentation") {
        try generateDocs()
    },
    Task("ci", description: "Runs the operations that are executed on CI") {
        print("> Linting the project")
        try Utils.shell.runAndPrint(bash: "swiftlint")
        print("> Building the project")
        try Utils.shell.runAndPrint(bash: "swift build")
        print("> Testing the project")
        try Utils.shell.runAndPrint(bash: "swift test")
    },
    Task("release", description: "Releases a new version of Sake") {
        if try Utils.git.anyChanges() { throw "Commit all your changes before starting the release" }
        if try Utils.git.branch() != "master" { throw "The release process should be initialized from master" }
        let nextVersion = try Version(Utils.git.lastTag()).bumpingMinor()
        let branch = "release/\(nextVersion.string)"
        try createVersion(version: nextVersion.string, branch: branch)
        try updateFormula(version: nextVersion.string, branch: branch)
    }]
)

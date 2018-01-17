import Foundation
import SakefileDescription

func publishWebsite() throws {
    try Utils.shell.runAndPrint(bash: "swift package generate-xcodeproj")
    try Utils.shell.runAndPrint(bash: "bundle exec jazzy --clean --sdk macosx --output api --xcodebuild-arguments -scheme,sake,-project,sake.xcodeproj --skip-undocumented")
    try Utils.shell.runAndPrint(bash: "cd website; yarn build;")
    try Utils.shell.runAndPrint(bash: "cd website; USE_SSH=true yarn run publish-gh-pages")
}

func serveWebsite() throws {
    try Utils.shell.runAndPrint(bash: "cd website; yarn start;")
}

func updateVersionSwift(version: String) throws {
    let versionContent = """
    import Foundation
    public let version = "\(version)"
    """
    let currentDirectoryPath = FileManager.default.currentDirectoryPath
    let versionURL = URL(fileURLWithPath: currentDirectoryPath)
        .appendingPathComponent("Sources/SakeKit/Version.swift")
    try versionContent.write(to: versionURL, atomically: true, encoding: .utf8)
}

func createVersion(version: String, branch: String) throws {
    print("> Building the project")
    try Utils.shell.runAndPrint(bash: "swift build")
    print("> Generating docs")
    try publishWebsite()
    try updateVersionSwift(version: version)
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
    _ = try Utils.shell.run(bash: "sed -i \"\" 's|url .*$|version \"https://github.com/xcodeswift/sake/archive/\(version).tar.gz\"|' \(formulaPath)")
    _ = try Utils.shell.run(bash: "sed -i \"\" 's|sha256 .*$|sha256 \"\(sha)\"|' \(formulaPath)")
    try Utils.shell.runAndPrint(bash: "rm sake.tar.gz")
    print("> Commiting and pushing the changes to release/\(version)")
    try Utils.git.add(paths: formulaPath)
    try Utils.git.commit(message: "[\(branch)] Update formula")
    try Utils.git.push(remote: "origin", branch: branch)
}

func auditFormula() throws {
    let currentFormulaPath = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        .appendingPathComponent("Formula/sake.rb")
        .absoluteURL
        .path
    let sakeFormulaPath = "/usr/local/Homebrew/Library/Taps/homebrew/homebrew-core/Formula/sake.rb"
    try Utils.shell.runAndPrint(bash: "rm -f \(sakeFormulaPath)")
    try Utils.shell.runAndPrint(bash: "ln -s -f \(currentFormulaPath) \(sakeFormulaPath)")
    do {
        try Utils.shell.runAndPrint(bash: "brew audit sake --strict --online")
    } catch {
        try Utils.shell.runAndPrint(bash: "rm -rf \(sakeFormulaPath)")
        throw error
    }
}

let sake = Sake(tasks: [
    Task("ci", description: "Runs the operations that are executed on CI") {
        print("> Linting the project")
        try Utils.shell.runAndPrint(bash: "swiftlint")
        print("> Auditing formula")
        try auditFormula()
        print("> Building the project")
        try Utils.shell.runAndPrint(bash: "swift build")
        print("> Testing the project")
        try Utils.shell.runAndPrint(bash: "swift test")
    },
    Task("release", description: "Releases a new version of Sake") {
        if try Utils.git.anyChanges() { throw "Commit all your changes before starting the release" }
        let nextVersion = try Version(Utils.git.lastTag()).bumpingMinor()
        let branch = "release/\(nextVersion.string)"
        try createVersion(version: nextVersion.string, branch: branch)
        try updateFormula(version: nextVersion.string, branch: branch)
    },
    Task("test", description: "Runs tests") {
        try Utils.shell.runAndPrint(bash: "swift test")
    },
    Task("audit-formula", description: "Audits the Homebrew formula") {
        try auditFormula()
    },
    Task("publish-website", description: "Generates and publish the website") {
        try publishWebsite()
    },
    Task("serve-website", description: "Serves the website") {
        try serveWebsite()
    }]
)

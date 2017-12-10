import SakefileDescription
import SakefileUtils

// MARK: - Tasks

enum Task: String, CustomStringConvertible {
  case documentation
  var description: String {
    switch self {
    case .documentation:
        return "Generates the project documentation"
    }
  }
}

// MARK: - Functions

func anyGitChanges() -> Bool {
    
}

//def any_git_changes?
//!`git status -s`.empty?
//end
//
//def build
//sh "swift build"
//end

Sake<Task> {
    $0.task(.documentation) { (utils) in
        log(message: "Generating documentation using Jazzy")
        try utils.shell.runAndPrint(command: "swift package generate-xcodeproj")
        try utils.shell.runAndPrint(command: "jazzy --clean --sdk macosx --xcodebuild-arguments -scheme,sake --skip-undocumented --no-download-badge")
    }
}.run()


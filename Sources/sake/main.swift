import Foundation
import Commander
import SakeKit

Group {
    let initCommand = command {
        try GenerateSakefile(path: FileManager.default.currentDirectoryPath).execute()
    }
    let taskCommand = command(Argument<String>("task", description: "the task to be executed")) { task in
        print("Not implemented yet")
    }
    let generateXcodeProjCommand = command {
        try GenerateProject(path: FileManager.default.currentDirectoryPath).execute()
    }
    let tasksCommand = command {
        print("Not implemented yet")
    }
    $0.addCommand("init", "initializes a Sakefile in the current directory", initCommand)
    $0.addCommand("task", "runs the task passed", taskCommand)
    $0.addCommand("tasks", "lists all the available tasks", tasksCommand)
    $0.addCommand("generate-xcodeproj", "generates an Xcode project to edit the Sakefile", generateXcodeProjCommand)
}.run()

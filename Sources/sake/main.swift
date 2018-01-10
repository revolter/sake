import Foundation
import Commander
import SakeKit

func directoryFrom(path: String) -> String {
    if path.isEmpty {
        return FileManager.default.currentDirectoryPath
    } else {
        return URL(fileURLWithPath: path).deletingLastPathComponent().path
    }
}

Group {
    let initCommand = command(Option("path", default: "", flag: "p", description: "Sakefile.swift path")) { path in
        try GenerateSakefile(path: directoryFrom(path: path)).execute()
    }
    let taskCommand = command(Argument<String>("task", description: "the task to be executed"),
                              Option("path", default: "", flag: "p", description: "Sakefile.swift path")) { (task, path) in
        try RunSakefile(path: directoryFrom(path: path), arguments: ["task", task]).execute()
    }
    let generateXcodeProjCommand = command(Option("path", default: "", flag: "p", description: "Sakefile.swift path")) { path in
        try GenerateProject(path: directoryFrom(path: path)).execute()
    }
    let tasksCommand = command(Option("path", default: "", flag: "p", description: "Sakefile.swift path")) { (path) in
        try RunSakefile(path: directoryFrom(path: path), arguments: ["tasks"]).execute()
    }
    $0.addCommand("init", "initializes a Sakefile in the current directory", initCommand)
    $0.addCommand("task", "runs the task passed", taskCommand)
    $0.addCommand("tasks", "lists all the available tasks", tasksCommand)
    $0.addCommand("generate-xcodeproj", "generates an Xcode project to edit the Sakefile", generateXcodeProjCommand)
}.run()

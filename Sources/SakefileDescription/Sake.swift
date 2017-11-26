import Foundation

// MARK: - Sake

public final class Sake {
    
    fileprivate let utils: Utils = Utils()
    fileprivate let tasks: Tasks = Tasks()
    fileprivate let tasksInitializer: (Tasks) -> ()
    
    public init(tasksInitializer: @escaping (Tasks) -> ()) {
        self.tasksInitializer = tasksInitializer
    }
    
}

// MARK: - Sake (Runner)

public extension Sake {
    
    public func run() {
        tasksInitializer(tasks)
        var arguments = CommandLine.arguments
        arguments.remove(at: 0)
        guard let argument = arguments.first else {
            print("> Error: Missing argument")
            exit(1)
        }
        if argument == "tasks" {
            printTasks()
        } else if argument == "task" {
            if arguments.count != 2 {
                print("> Error: Missing task name")
                exit(1)
            }
            do {
                try run(task: arguments[1])
            } catch {
                print("> Error: \(error)")
                exit(1)
            }
        } else {
            print("> Error: Invalid argument")
            exit(1)
        }
    }
    
    // MARK: - Fileprivate
    
    fileprivate func printTasks() {
        print(self.tasks.tasks
            .map({"\($0.name):      \($0.description)"})
            .joined(separator: "\n"))
    }
    
    fileprivate func run(task taskName: String) throws {
        guard let task = tasks.tasks.first(where: {$0.name == taskName}) else {
            return
        }
        try task.dependencies.forEach({ try run(task: $0) })
        print("> Running \"\(task.name)\"")
        try task.action(self.utils)
    }
    
}

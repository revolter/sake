import Foundation

// MARK: - Sake

public final class Sake {
    
    fileprivate let utils: Utils = Utils()
    fileprivate let tasks: Tasks = Tasks()
    fileprivate let tasksInitializer: (Tasks) -> Void
    
    public init(tasksInitializer: @escaping (Tasks) -> Void) {
        self.tasksInitializer = tasksInitializer
    }
    
}

// MARK: - Sake (Runner)

public extension Sake {
    
    public func run() {
        var arguments = CommandLine.arguments
        arguments.remove(at: 0)
        run(arguments: arguments)
    }
    
    func run(arguments: [String]) {
        tasksInitializer(tasks)
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
                try runTaskAndDependencies(task: arguments[1])
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
    
    fileprivate func runTaskAndDependencies(task taskName: String) throws {
        guard let task = tasks.tasks.first(where: {$0.name == taskName}) else {
            return
        }
        tasks.beforeAll.forEach({ $0(utils) })
        defer { tasks.afterAll.forEach({ $0(utils) }) }
        try task.dependencies.forEach { try runTask(task: $0) }
        try runTask(task: taskName)
    }
    
    fileprivate func runTask(task: String) throws {
        guard let task = tasks.tasks.first(where: {$0.name == task}) else {
            return
        }
        print("> Running \"\(task.name)\"")
        tasks.beforeEach.forEach({$0(utils)})
        try task.action(self.utils)
        tasks.afterEach.forEach({$0(utils)})
    }
    
}

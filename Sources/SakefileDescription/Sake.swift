import Foundation

// MARK: - Sake

/// Sake hooks
///
/// - beforeAll: before all the tasks get executed.
/// - afterAll: after all the tasks get executed.
/// - beforeEach: before each task gets executed.
/// - afterEach: after each task gets executed.
public enum Hook {
    case beforeAll(() -> Void)
    case afterAll(() -> Void)
    case beforeEach(() -> Void)
    case afterEach(() -> Void)
    var beforeAll: (() -> Void)? {
        switch self {
        case .beforeAll(let closure): return closure
        default: return nil
        }
    }
    var afterAll: (() -> Void)? {
        switch self {
        case .afterAll(let closure): return closure
        default: return nil
        }
    }
    var beforeEach: (() -> Void)? {
        switch self {
        case .beforeEach(let closure): return closure
        default: return nil
        }
    }
    var afterEach: (() -> Void)? {
        switch self {
        case .afterEach(let closure): return closure
        default: return nil
        }
    }
}

public final class Sake {
    
    var tasks: [String: Task]
    var taskError: Error?
    let hooks: [Hook]
    fileprivate let printer: (String) -> Void
    fileprivate let exiter: (Int) -> Void
    
    @discardableResult
    internal init(tasks: [Task],
                  hooks: [Hook],
                  printer: @escaping (String) -> Void,
                  exiter: @escaping (Int) -> Void,
                  arguments: [String]? = nil) {
        let tasksByNameResult = Sake.tasksByName(tasks)
        self.tasks = tasksByNameResult.tasks ?? [:]
        self.taskError = tasksByNameResult.error
        self.hooks = hooks
        self.printer = printer
        self.exiter = exiter
        if let arguments = arguments {
            self.run(arguments: arguments)
        } else {
            self.run()
        }
    }
    
    public convenience init(tasks: [Task],
                            hooks: [Hook] = []) {
        self.init(tasks: tasks,
                  hooks: hooks,
                  printer: { print($0) },
                  exiter: { exit(Int32($0)) })
    }
    
    /// Groups the tasks by name in a dictionary.
    ///
    /// - Parameter tasks: tasks to be grouped
    /// - Returns: returns either an the grouped tasks or an error if there are duplicated tasks or tasks with non-existing dependencies
    static func tasksByName(_ tasks: [Task]) -> (tasks: [String: Task]?, error: Error?) {
        var tasksByName: [String: Task] = [:]
        var error: Error?
        for task in tasks {
            if tasksByName[task.name] != nil {
                error = "Trying to register task \(task.name) that is already registered"
            } else {
                tasksByName[task.name] = task
            }
        }
        for task in tasks {
            for dependency in task.dependencies {
                if tasksByName[dependency] == nil {
                    error = "Task \(task.name) has a dependency \(dependency) that can't be found"
                }
            }
        }
        if let error = error {
            return (tasks: nil, error: error)
        } else {
            return (tasks: tasksByName, error: nil)
        }
    }
    
}

// MARK: - Sake (Runner)

extension Sake {
    
    func run() {
        var arguments = CommandLine.arguments
        arguments.remove(at: 0)
        run(arguments: arguments)
    }
    
    func run(arguments: [String]) {
        if let taskError = taskError {
            printer("> Error initializing tasks: \(taskError)")
            return
        }
        guard let argument = arguments.first else {
            printer("Error: Missing argument")
            exiter(1)
            return
        }
        if argument == "tasks" {
            printTasks()
        } else if argument == "task" {
            if arguments.count != 2 {
                printer("Error: Missing task name")
                exiter(1)
                return
            }
            do {
                try runTaskAndDependencies(task: arguments[1])
            } catch let shellExitError as ShellExitCoding {
                printer("Error: \(shellExitError)")
                exiter(shellExitError.exitCode)
                return
            } catch {
                printer("Error: \(error)")
                exiter(1)
                return
            }
        } else {
            printer("Error: Invalid argument")
            exiter(1)
        }
    }
    
    // MARK: - Fileprivate
    
    fileprivate func printTasks() {
        let longestName = tasks.keys.reduce(0, { $1.count > $0  ? $1.count : $0 })
        let margin = 5
        printer(self.tasks.values
            .sorted { $0.name < $1.name }
            .map { task in
                let spaces = (longestName + margin) - task.name.count
                let space = String(repeating: " ", count: spaces)
                return "\(task.name):\(space)\(task.description)"
            }
            .joined(separator: "\n"))
    }
    
    fileprivate func printWarningTaskNotFound(_ task: String) {
        var alertMessage = "[!] Could not find task '\(task)'"
        if let suggestedTaskName = findSuggestionTaskName(for: task) {
            alertMessage += ". Maybe did you mean '\(suggestedTaskName)'?"
        }
        printer(alertMessage)
    }
    
    /// Find a possible alternative task name. How it work:
    /// 1) Create an array with tuples '(task, distance)', calculating the distance between input task name and the available tasks.
    /// 2) Filter tasks without occurrences (ex: "ci", distance = 2, doesn't have occurrences).
    /// 3) Obtain the task with minimum distance.
    ///
    /// - Parameter task: the task name written by the user
    /// - Returns: alternative task name if exist
    fileprivate func findSuggestionTaskName(for task: String) -> String? {
        let taskWithDistance = self.tasks.keys
            .map { (taskName: $0, distance: $0.levenshteinDistance(task)) }
            .filter { $0.taskName.count != $0.distance }
            .min { $0.distance < $1.distance }
        return taskWithDistance?.taskName
    }
    
    fileprivate func runTaskAndDependencies(task taskName: String) throws {
        guard let task = tasks[taskName] else {
            printWarningTaskNotFound(taskName)
            exiter(1)
            return
        }
        hooks.forEach({ $0.beforeAll?() })
        defer { hooks.forEach({ $0.afterAll?() }) }
        try task.dependencies.forEach { try runTask(task: $0) }
        try runTask(task: taskName)
    }
    
    fileprivate func runTask(task taskName: String) throws {
        guard let task = tasks[taskName] else {
            printWarningTaskNotFound(taskName)
            return
        }
        printer("Running \"\(taskName)\"")
        hooks.forEach({ $0.beforeEach?() })
        try task.action()
        hooks.forEach({ $0.afterEach?() })
    }
    
}


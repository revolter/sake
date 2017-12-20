import Foundation

// MARK: - Sake

public final class Sake {

    var tasks: [String: Task]
    fileprivate let printer: (String) -> Void

    public typealias Hook = () -> Void

    /// Hooks
    var beforeAll: Hook
    var beforeEach: Hook
    var afterEach: Hook
    var afterAll: Hook

    var taskError: String?

    @discardableResult
    public init(tasks: [Task],
                printer: @escaping (String) -> Void = { print($0) },
                beforeAll: @escaping Hook = {},
                beforeEach: @escaping Hook = {},
                afterEach: @escaping Hook = {},
                afterAll: @escaping Hook = {}) {
        self.printer = printer

        var tasksByName: [String: Task] = [:]

        // check that tasks aren't already registered
        for task in tasks {
            if tasksByName[task.name] != nil {
                taskError = "Trying to register task \(task.name) that is already registered"
            } else {
                tasksByName[task.name] = task
            }
        }

        // check that tasks don't have any invalid dependencies
        for task in tasks {
            for dependency in task.dependencies {
                if tasksByName[dependency] == nil {
                    taskError = "Task \(task.name) has a dependency \(dependency) that can't be found"
                }
            }
        }
        self.tasks = tasksByName

        self.beforeAll = beforeAll
        self.beforeEach = beforeEach
        self.afterAll = afterAll
        self.afterEach = afterEach
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
            printer("> Error: Missing argument")
            exit(1)
        }
        if argument == "tasks" {
            printTasks()
        } else if argument == "task" {
            if arguments.count != 2 {
                printer("> Error: Missing task name")
                exit(1)
            }
            do {
                try runTaskAndDependencies(task: arguments[1])
            } catch {
                printer("> Error: \(error)")
                exit(1)
            }
        } else {
            printer("> Error: Invalid argument")
            exit(1)
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
        var alertMessage = "> [!] Could not find task '\(task)'"
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
            return
        }
        beforeAll()
        defer { afterAll() }
        try task.dependencies.forEach { try runTask(task: $0) }
        try runTask(task: taskName)
    }

    fileprivate func runTask(task taskName: String) throws {
        guard let task = tasks[taskName] else {
            printWarningTaskNotFound(taskName)
            return
        }
        printer("> Running \"\(taskName)\"")
        beforeEach()
        try task.action()
        afterEach()
    }

}


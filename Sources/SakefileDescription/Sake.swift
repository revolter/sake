import Foundation

// MARK: - Utils

public final class Utils {
    public  final class HTTP {
        let session: URLSession = .shared
        public func execute<T>(request: URLRequest, parse: @escaping (Data) throws -> T) throws -> T? {
            let semaphore = DispatchSemaphore(value: 0)
            var error: Error?
            var value: T?
            session.dataTask(with: request) { (data, response, _error) in
                defer {
                    semaphore.signal()
                }
                if let _error = _error {
                    error = _error
                } else if let data = data {
                    do {
                        value = try parse(data)
                    } catch let _error {
                        error = _error
                    }
                }
            }.resume()
            semaphore.wait()
            if let error = error { throw error }
            return value
        }
        public func executeJSON(request: URLRequest) throws -> Any? {
            return try self.execute(request: request) { (data) -> Any in
                return try JSONSerialization.jsonObject(with: data, options: [])
            }
        }
    }
    public let http: HTTP = HTTP()
}

// MARK: - Task

public final class Task {
    
    fileprivate let name: String
    fileprivate let description: String
    fileprivate let dependencies: [String]
    fileprivate let action: (Utils) throws -> ()
    
    init(name: String, description: String, dependencies: [String] = [], action: @escaping (Utils) throws -> ()) {
        self.name = name
        self.description = description
        self.dependencies = dependencies
        self.action = action
    }
}

// MARK: - Tasks

public final class Tasks {
    
    fileprivate var tasks: [Task] = []
    
    public func task(name: String, description: String, dependencies: [String] = [], action: @escaping (Utils) throws -> ()) {
        tasks.append(Task(name: name, description: description, dependencies: dependencies, action: action))
    }
    
    public func task(_ task: Task) {
        tasks.append(task)
    }
    
}

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
        guard let argument = CommandLine.arguments.first else {
            fatalError("Missing argument")
        }
        if argument == "tasks" {
            printTasks()
        } else if argument == "task" {
            if CommandLine.arguments.count != 2 {
                fatalError("Missing task name")
            }
            do {
                try run(task: CommandLine.arguments[1])
            } catch {
                print(error)
            }
        }
    }
    
    fileprivate func printTasks() {
        print(self.tasks.tasks
            .map({"\($0.name):      \($0.description)"})
            .joined(separator: "\n"))
    }
    
    fileprivate func run(task taskName: String) throws {
        guard let task = tasks.tasks.first(where: {$0.name == taskName}) else {
            fatalError("Task \(taskName) not found")
        }
        try task.dependencies.forEach({ try run(task: $0) })
        print("> Running \(task.name)")
        try task.action(self.utils)
    }
    
}

import Foundation

// MARK: - Task

public final class Task {

    /// Task name.
    fileprivate let name: String

    /// Task description.
    fileprivate let description: String

    /// Task dependencies (other tasks)
    fileprivate let dependencies: [String]

    /// Task action closure.
    fileprivate let action: (Utils) throws -> ()

    /// Initializes the task.
    ///
    /// - Parameters:
    ///   - name: task name.
    ///   - description: task description.
    ///   - dependencies: task dependencies.
    ///   - action: action closure.
    init(name: String, description: String, dependencies: [String] = [], action: @escaping (Utils) throws -> ()) {
        self.name = name
        self.description = description
        self.dependencies = dependencies
        self.action = action
    }
}

// MARK: - Tasks

public final class Tasks {
    
    /// Tasks.
    fileprivate var tasks: [Task] = []
    
    /// Adds a new task.
    ///
    /// - Parameters:
    ///   - name: task name.
    ///   - description: task description.
    ///   - dependencies: task dependencies.
    ///   - action: task action.
    public func task(name: String, description: String, dependencies: [String] = [], action: @escaping (Utils) throws -> ()) {
        tasks.append(Task(name: name, description: description, dependencies: dependencies, action: action))
    }
    
    /// Adds a new task.
    ///
    /// - Parameter task: task to be added.
    public func task(_ task: Task) {
        tasks.append(task)
    }
    
}

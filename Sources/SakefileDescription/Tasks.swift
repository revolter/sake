import Foundation

// MARK: - Task

public final class Task {

    /// Task name.
    let name: String

    /// Task description.
    let description: String

    /// Task dependencies (other tasks)
    let dependencies: [String]

    /// Task action closure.
    let action: (Utils) throws -> Void

    /// Initializes the task.
    ///
    /// - Parameters:
    ///   - name: task name.
    ///   - description: task description.
    ///   - dependencies: task dependencies.
    ///   - action: action closure.
    init(name: String, description: String, dependencies: [String] = [], action: @escaping (Utils) throws -> Void) {
        self.name = name
        self.description = description
        self.dependencies = dependencies
        self.action = action
    }
}

// MARK: - Tasks

public final class Tasks {
    
    /// Tasks.
    var tasks: [Task] = []
    
    /// Hooks
    var beforeAll: [(Utils) -> Void] = []
    var beforeEach: [(Utils) -> Void] = []
    var afterAll: [(Utils) -> Void] = []
    var afterEach: [(Utils) -> Void] = []

    /// Adds a new task.
    ///
    /// - Parameters:
    ///   - name: task name.
    ///   - description: task description.
    ///   - dependencies: task dependencies.
    ///   - action: task action.
    public func task(name: String, description: String, dependencies: [String] = [], action: @escaping (Utils) throws -> Void) {
        tasks.append(Task(name: name, description: description, dependencies: dependencies, action: action))
    }
    
    /// Adds a new task.
    ///
    /// - Parameter task: task to be added.
    public func task(_ task: Task) {
        tasks.append(task)
    }
    
    /// Adds a before all hook.
    ///
    /// - Parameter closure: closure that will be executed before all the tasks.
    public func beforeAll(closure: @escaping (Utils) -> Void) {
        beforeAll.append(closure)
    }
    
    /// Adds a before each hook.
    ///
    /// - Parameter closure: closure that will be executed before each task.
    public func beforeEach(closure: @escaping (Utils) -> Void) {
        beforeEach.append(closure)
    }
    
    /// Adds an after all hook.
    ///
    /// - Parameter closure: closure that will be executed after all the tasks.
    public func afterAll(closure: @escaping (Utils) -> Void) {
        afterAll.append(closure)
    }
    
    /// Adds an after each hook.
    ///
    /// - Parameter closure: closure that will be executed after each task.
    public func afterEach(closure: @escaping (Utils) -> Void) {
        afterEach.append(closure)
    }
    
}

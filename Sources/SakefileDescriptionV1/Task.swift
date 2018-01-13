import Foundation

// MARK: - Task

public final class Task {

    /// Task title
    let name: String

    /// Task description
    let description: String

    /// Task dependencies (other tasks)
    let dependencies: [String]

    /// Task action closure.
    let action: () throws -> Void


    /// Initializes the task.
    ///
    /// - Parameters:
    ///   - name: task name.
    ///   - description: task description.
    ///   - dependencies: task dependencies.
    ///   - action: action closure.
    public init(_ name: String, description: String, dependencies: [String] = [], action: @escaping () throws -> Void) {
        self.name = name
        self.description = description
        self.dependencies = dependencies
        self.action = action
    }

}

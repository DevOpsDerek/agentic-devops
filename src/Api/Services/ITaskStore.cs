using Api.Models;

namespace Api.Services;

/// <summary>Abstraction over task persistence.</summary>
public interface ITaskStore
{
    /// <summary>Returns all tasks ordered by creation time.</summary>
    IReadOnlyList<TaskItem> GetAll();

    /// <summary>Returns a single task by id, or <c>null</c> when not found.</summary>
    TaskItem? Find(Guid id);

    /// <summary>Creates a new task from the supplied request.</summary>
    TaskItem Create(CreateTaskRequest request);

    /// <summary>Updates an existing task; returns <c>null</c> when not found.</summary>
    TaskItem? Update(Guid id, UpdateTaskRequest request);

    /// <summary>Deletes a task; returns <c>true</c> when a task was removed.</summary>
    bool Delete(Guid id);
}

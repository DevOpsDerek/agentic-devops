namespace Api.Models;

/// <summary>Represents a single unit of work tracked by the API.</summary>
public sealed record TaskItem
{
    /// <summary>Unique identifier for the task.</summary>
    public Guid Id { get; init; }

    /// <summary>Short human-readable title.</summary>
    public required string Title { get; init; }

    /// <summary>Optional longer description.</summary>
    public string? Description { get; init; }

    /// <summary>Current lifecycle state of the task.</summary>
    public TaskState State { get; init; } = TaskState.Todo;

    /// <summary>UTC timestamp when the task was created.</summary>
    public DateTimeOffset CreatedAt { get; init; }

    /// <summary>UTC timestamp when the task was last updated.</summary>
    public DateTimeOffset UpdatedAt { get; init; }
}

/// <summary>Lifecycle states for a <see cref="TaskItem"/>.</summary>
public enum TaskState
{
    /// <summary>Not yet started.</summary>
    Todo,

    /// <summary>Actively being worked on.</summary>
    InProgress,

    /// <summary>Completed.</summary>
    Done
}

/// <summary>Payload used to create a new task.</summary>
public sealed record CreateTaskRequest
{
    /// <summary>Short human-readable title (required).</summary>
    public required string Title { get; init; }

    /// <summary>Optional longer description.</summary>
    public string? Description { get; init; }
}

/// <summary>Payload used to update an existing task.</summary>
public sealed record UpdateTaskRequest
{
    /// <summary>Updated title.</summary>
    public required string Title { get; init; }

    /// <summary>Updated description.</summary>
    public string? Description { get; init; }

    /// <summary>Updated state.</summary>
    public TaskState State { get; init; }
}

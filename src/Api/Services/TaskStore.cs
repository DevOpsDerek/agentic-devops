using System.Collections.Concurrent;
using Api.Models;

namespace Api.Services;

/// <summary>Thread-safe in-memory implementation of <see cref="ITaskStore"/>.</summary>
/// <remarks>
/// Suitable for a proof-of-concept. A production deployment would swap this for a
/// durable store (e.g. Azure Cosmos DB or PostgreSQL) behind the same interface.
/// </remarks>
public sealed class TaskStore : ITaskStore
{
    private readonly ConcurrentDictionary<Guid, TaskItem> _items = new();
    private readonly TimeProvider _clock;

    /// <summary>Initializes a new instance using the supplied time provider.</summary>
    public TaskStore(TimeProvider clock) => _clock = clock;

    /// <inheritdoc />
    public IReadOnlyList<TaskItem> GetAll() =>
        _items.Values.OrderBy(t => t.CreatedAt).ToList();

    /// <inheritdoc />
    public TaskItem? Find(Guid id) => _items.TryGetValue(id, out var item) ? item : null;

    /// <inheritdoc />
    public TaskItem Create(CreateTaskRequest request)
    {
        var now = _clock.GetUtcNow();
        var item = new TaskItem
        {
            Id = Guid.NewGuid(),
            Title = request.Title,
            Description = request.Description,
            State = TaskState.Todo,
            CreatedAt = now,
            UpdatedAt = now,
        };

        _items[item.Id] = item;
        return item;
    }

    /// <inheritdoc />
    public TaskItem? Update(Guid id, UpdateTaskRequest request)
    {
        if (!_items.TryGetValue(id, out var existing))
        {
            return null;
        }

        var updated = existing with
        {
            Title = request.Title,
            Description = request.Description,
            State = request.State,
            UpdatedAt = _clock.GetUtcNow(),
        };

        _items[id] = updated;
        return updated;
    }

    /// <inheritdoc />
    public bool Delete(Guid id) => _items.TryRemove(id, out _);
}

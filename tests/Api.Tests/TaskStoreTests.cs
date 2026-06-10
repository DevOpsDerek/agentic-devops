using Api.Models;
using Api.Services;

namespace Api.Tests;

public sealed class TaskStoreTests
{
    private static TaskStore NewStore() => new(TimeProvider.System);

    [Fact]
    public void Create_AssignsIdAndTimestamps()
    {
        var store = NewStore();

        var created = store.Create(new CreateTaskRequest { Title = "Write docs" });

        Assert.NotEqual(Guid.Empty, created.Id);
        Assert.Equal("Write docs", created.Title);
        Assert.Equal(TaskState.Todo, created.State);
        Assert.Equal(created.CreatedAt, created.UpdatedAt);
    }

    [Fact]
    public void Get_ReturnsCreatedTask()
    {
        var store = NewStore();
        var created = store.Create(new CreateTaskRequest { Title = "Ship it" });

        var fetched = store.Find(created.Id);

        Assert.NotNull(fetched);
        Assert.Equal(created.Id, fetched!.Id);
    }

    [Fact]
    public void GetAll_ReturnsItemsOrderedByCreation()
    {
        var store = NewStore();
        var first = store.Create(new CreateTaskRequest { Title = "First" });
        var second = store.Create(new CreateTaskRequest { Title = "Second" });

        var all = store.GetAll();

        Assert.Equal(2, all.Count);
        Assert.Equal(first.Id, all[0].Id);
        Assert.Equal(second.Id, all[1].Id);
    }

    [Fact]
    public void Update_ChangesFields_WhenTaskExists()
    {
        var store = NewStore();
        var created = store.Create(new CreateTaskRequest { Title = "Old title" });

        var updated = store.Update(created.Id, new UpdateTaskRequest
        {
            Title = "New title",
            Description = "details",
            State = TaskState.InProgress,
        });

        Assert.NotNull(updated);
        Assert.Equal("New title", updated!.Title);
        Assert.Equal("details", updated.Description);
        Assert.Equal(TaskState.InProgress, updated.State);
    }

    // NOTE: Delete(...) and the "update non-existent task" path are intentionally
    // left uncovered so the Daily Test Improver agentic workflow has a real gap to fill.
}

using Api.Models;
using Api.Services;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddSingleton(TimeProvider.System);
builder.Services.AddSingleton<ITaskStore, TaskStore>();
builder.Services.AddOpenApi();

var app = builder.Build();

// Expose the generated OpenAPI document in every environment for the PoC demo.
app.MapOpenApi();

// Liveness/readiness probe consumed by Azure Container Apps health checks.
app.MapGet("/healthz", () => Results.Ok(new { status = "healthy" }))
    .WithName("HealthCheck")
    .WithTags("Health");

var tasks = app.MapGroup("/tasks").WithTags("Tasks");

tasks.MapGet("/", (ITaskStore store) => Results.Ok(store.GetAll()))
    .WithName("ListTasks");

tasks.MapGet("/{id:guid}", (Guid id, ITaskStore store) =>
        store.Find(id) is { } task ? Results.Ok(task) : Results.NotFound())
    .WithName("GetTask");

tasks.MapPost("/", (CreateTaskRequest request, ITaskStore store) =>
    {
        if (string.IsNullOrWhiteSpace(request.Title))
        {
            return Results.ValidationProblem(new Dictionary<string, string[]>
            {
                ["title"] = ["Title is required."],
            });
        }

        var created = store.Create(request);
        return Results.Created($"/tasks/{created.Id}", created);
    })
    .WithName("CreateTask");

tasks.MapPut("/{id:guid}", (Guid id, UpdateTaskRequest request, ITaskStore store) =>
    {
        if (string.IsNullOrWhiteSpace(request.Title))
        {
            return Results.ValidationProblem(new Dictionary<string, string[]>
            {
                ["title"] = ["Title is required."],
            });
        }

        return store.Update(id, request) is { } updated
            ? Results.Ok(updated)
            : Results.NotFound();
    })
    .WithName("UpdateTask");

tasks.MapDelete("/{id:guid}", (Guid id, ITaskStore store) =>
        store.Delete(id) ? Results.NoContent() : Results.NotFound())
    .WithName("DeleteTask");

app.Run();

/// <summary>Exposed so integration tests can reference the application entry point.</summary>
public partial class Program;

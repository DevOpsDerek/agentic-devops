using System.Net;
using System.Net.Http.Json;
using Api.Models;
using Microsoft.AspNetCore.Mvc.Testing;

namespace Api.Tests;

public sealed class TaskApiTests : IClassFixture<WebApplicationFactory<Program>>
{
    private readonly WebApplicationFactory<Program> _factory;

    public TaskApiTests(WebApplicationFactory<Program> factory) => _factory = factory;

    [Fact]
    public async Task Health_ReturnsHealthy()
    {
        var client = _factory.CreateClient();

        var response = await client.GetAsync("/healthz");

        response.EnsureSuccessStatusCode();
        var body = await response.Content.ReadFromJsonAsync<HealthResponse>();
        Assert.Equal("healthy", body!.Status);
    }

    [Fact]
    public async Task CreateThenGet_RoundTripsTask()
    {
        var client = _factory.CreateClient();

        var create = await client.PostAsJsonAsync("/tasks", new CreateTaskRequest { Title = "Demo" });
        Assert.Equal(HttpStatusCode.Created, create.StatusCode);

        var created = await create.Content.ReadFromJsonAsync<TaskItem>();
        var fetched = await client.GetFromJsonAsync<TaskItem>($"/tasks/{created!.Id}");

        Assert.Equal(created.Id, fetched!.Id);
        Assert.Equal("Demo", fetched.Title);
    }

    [Fact]
    public async Task Create_WithBlankTitle_ReturnsValidationProblem()
    {
        var client = _factory.CreateClient();

        var response = await client.PostAsJsonAsync("/tasks", new CreateTaskRequest { Title = "  " });

        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
    }

    [Fact]
    public async Task Get_UnknownId_ReturnsNotFound()
    {
        var client = _factory.CreateClient();

        var response = await client.GetAsync($"/tasks/{Guid.NewGuid()}");

        Assert.Equal(HttpStatusCode.NotFound, response.StatusCode);
    }

    private sealed record HealthResponse(string Status);
}

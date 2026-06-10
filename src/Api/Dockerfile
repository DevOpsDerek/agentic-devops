# syntax=docker/dockerfile:1

# ---- Build stage ----
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src

# Restore as a separate layer for better caching.
COPY ["src/Api/Api.csproj", "src/Api/"]
COPY ["Directory.Build.props", "./"]
RUN dotnet restore "src/Api/Api.csproj"

# Build and publish.
COPY . .
WORKDIR /src/src/Api
RUN dotnet publish "Api.csproj" -c Release -o /app/publish \
    /p:UseAppHost=false

# ---- Runtime stage ----
# Chiseled, non-root, minimal-surface runtime image for a smaller attack surface.
FROM mcr.microsoft.com/dotnet/aspnet:10.0-noble-chiseled AS final
WORKDIR /app
EXPOSE 8080
ENV ASPNETCORE_HTTP_PORTS=8080 \
    DOTNET_EnableDiagnostics=0

COPY --from=build /app/publish .
USER $APP_UID
ENTRYPOINT ["dotnet", "Api.dll"]

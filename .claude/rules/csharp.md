---
paths:
  - "**/*.cs"
  - "**/*.csproj"
  - "**/*.sln"
---

# C# Rules

## Conventions de code

### Nommage

| Element | Convention | Exemple |
|---------|------------|---------|
| Classes | PascalCase | `UserService` |
| Interfaces | PascalCase avec prefix I | `IUserRepository` |
| Methodes | PascalCase | `GetUserById` |
| Proprietes | PascalCase | `FirstName` |
| Variables locales | camelCase | `userName` |
| Parametres | camelCase | `userId` |
| Constantes | PascalCase | `MaxRetryCount` |
| Champs prives | _camelCase | `_userRepository` |

### Structure de classe

```csharp
public class UserService : IUserService
{
    // 1. Constantes
    private const int MaxRetries = 3;

    // 2. Champs prives readonly
    private readonly IUserRepository _userRepository;
    private readonly ILogger<UserService> _logger;

    // 3. Constructeur
    public UserService(IUserRepository userRepository, ILogger<UserService> logger)
    {
        _userRepository = userRepository;
        _logger = logger;
    }

    // 4. Proprietes
    public int RetryCount { get; private set; }

    // 5. Methodes publiques
    public async Task<User?> GetByIdAsync(int id) { ... }

    // 6. Methodes privees
    private void ValidateUser(User user) { ... }
}
```

## Bonnes pratiques

### Nullable reference types

```csharp
// Activer dans le projet
<Nullable>enable</Nullable>

// Utiliser correctement
public User? FindById(int id)  // Peut retourner null
public User GetById(int id)     // Ne retourne jamais null

// Pattern matching
if (user is { Name: var name, Email: var email })
{
    Console.WriteLine($"{name}: {email}");
}
```

### Records (C# 9+)

```csharp
// Record immutable
public record User(int Id, string Name, string Email);

// Record avec proprietes mutables si necessaire
public record User
{
    public int Id { get; init; }
    public string Name { get; init; } = "";
    public string Email { get; init; } = "";
}
```

### Async/Await

```csharp
// Toujours suffixer avec Async
public async Task<User> GetUserAsync(int id)
{
    return await _repository.FindByIdAsync(id)
        ?? throw new UserNotFoundException(id);
}

// Eviter .Result et .Wait()
// Utiliser ConfigureAwait(false) dans les libraries
public async Task<User> GetUserAsync(int id)
{
    return await _repository.FindByIdAsync(id).ConfigureAwait(false);
}
```

### LINQ

```csharp
// Syntaxe fluent preferee
var activeUsers = users
    .Where(u => u.IsActive)
    .OrderBy(u => u.Name)
    .Select(u => new UserDto(u.Id, u.Name))
    .ToList();

// Utiliser Any() au lieu de Count() > 0
if (users.Any(u => u.IsAdmin))
{
    // ...
}
```

### Pattern Matching

```csharp
// Switch expressions (C# 8+)
var message = status switch
{
    Status.Active => "User is active",
    Status.Pending => "User is pending",
    Status.Inactive => "User is inactive",
    _ => throw new ArgumentOutOfRangeException(nameof(status))
};

// Pattern matching avec types
if (result is Success<User> { Value: var user })
{
    return user;
}
```

## ASP.NET Core

### Controllers

```csharp
[ApiController]
[Route("api/[controller]")]
public class UsersController : ControllerBase
{
    private readonly IUserService _userService;

    public UsersController(IUserService userService)
    {
        _userService = userService;
    }

    [HttpGet("{id}")]
    [ProducesResponseType(typeof(UserDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<ActionResult<UserDto>> GetById(int id)
    {
        var user = await _userService.GetByIdAsync(id);
        return user is null ? NotFound() : Ok(user);
    }

    [HttpPost]
    [ProducesResponseType(typeof(UserDto), StatusCodes.Status201Created)]
    public async Task<ActionResult<UserDto>> Create([FromBody] CreateUserRequest request)
    {
        var user = await _userService.CreateAsync(request);
        return CreatedAtAction(nameof(GetById), new { id = user.Id }, user);
    }
}
```

### Dependency Injection

```csharp
// Program.cs
builder.Services.AddScoped<IUserRepository, UserRepository>();
builder.Services.AddScoped<IUserService, UserService>();

// Options pattern
builder.Services.Configure<EmailOptions>(
    builder.Configuration.GetSection("Email"));
```

### Validation

```csharp
public class CreateUserRequest
{
    [Required]
    [StringLength(100, MinimumLength = 2)]
    public string Name { get; init; } = "";

    [Required]
    [EmailAddress]
    public string Email { get; init; } = "";

    [Required]
    [MinLength(8)]
    public string Password { get; init; } = "";
}
```

## Tests

### xUnit + FluentAssertions

```csharp
public class UserServiceTests
{
    private readonly Mock<IUserRepository> _repositoryMock;
    private readonly UserService _sut;

    public UserServiceTests()
    {
        _repositoryMock = new Mock<IUserRepository>();
        _sut = new UserService(_repositoryMock.Object);
    }

    [Fact]
    public async Task GetByIdAsync_WhenUserExists_ReturnsUser()
    {
        // Arrange
        var user = new User(1, "John", "john@example.com");
        _repositoryMock
            .Setup(r => r.FindByIdAsync(1))
            .ReturnsAsync(user);

        // Act
        var result = await _sut.GetByIdAsync(1);

        // Assert
        result.Should().NotBeNull();
        result!.Name.Should().Be("John");
    }

    [Theory]
    [InlineData(null)]
    [InlineData("")]
    [InlineData(" ")]
    public void Validate_WithInvalidName_ThrowsException(string? name)
    {
        // Act & Assert
        var act = () => _sut.Validate(new User(1, name!, "email@test.com"));
        act.Should().Throw<ValidationException>();
    }
}
```

## A eviter

- `dynamic` sauf cas tres specifiques
- `goto`
- Exceptions pour le flow control
- Champs publics (utiliser des proprietes)
- `async void` sauf pour event handlers

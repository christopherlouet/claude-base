---
sidebar_position: 11
title: "java"
description: "// 2. Static fields private static final Logger logger = LoggerFactory.getLogger(UserService.class);"
tags:
  - "rule"
  - "java"
---

# Rules: java

> // 2. Static fields private static final Logger logger = LoggerFactory.getLogger(UserService.class);

## Affected files

These rules apply to files matching the following patterns:

- `**/*.java`
- `**/pom.xml`
- `**/build.gradle`
- `**/build.gradle.kts`

## Detailed rules

# Java Rules

## Code conventions

### Naming

| Element | Convention | Example |
|---------|------------|---------|
| Classes | PascalCase | `UserService` |
| Interfaces | PascalCase (no I prefix) | `UserRepository` |
| Methods | camelCase | `getUserById` |
| Variables | camelCase | `userName` |
| Constants | SCREAMING_SNAKE | `MAX_RETRY_COUNT` |
| Packages | lowercase | `com.example.users` |

### Class structure

```java
public class UserService {
    // 1. Constants
    private static final int MAX_RETRIES = 3;

    // 2. Static fields
    private static final Logger logger = LoggerFactory.getLogger(UserService.class);

    // 3. Instance fields
    private final UserRepository userRepository;
    private final EmailService emailService;

    // 4. Constructors
    public UserService(UserRepository userRepository, EmailService emailService) {
        this.userRepository = userRepository;
        this.emailService = emailService;
    }

    // 5. Public methods
    public User findById(Long id) { ... }

    // 6. Private methods
    private void validateUser(User user) { ... }
}
```

## Best practices

### Immutability

```java
// Prefer immutable classes
public record User(Long id, String name, String email) {}

// Or with Lombok
@Value
public class User {
    Long id;
    String name;
    String email;
}
```

### Optional

```java
// Use Optional for potentially null return values
public Optional<User> findById(Long id) {
    return Optional.ofNullable(userRepository.findById(id));
}

// Never pass Optional as a parameter
// Bad: void process(Optional<User> user)
// Good: void process(User user) with @Nullable if necessary
```

### Streams

```java
// Prefer streams for collections
List<String> names = users.stream()
    .filter(u -> u.isActive())
    .map(User::getName)
    .sorted()
    .collect(Collectors.toList());

// With Java 16+
List<String> names = users.stream()
    .filter(User::isActive)
    .map(User::getName)
    .sorted()
    .toList();
```

### Exceptions

```java
// Domain-specific exceptions
public class UserNotFoundException extends RuntimeException {
    public UserNotFoundException(Long id) {
        super("User not found: " + id);
    }
}

// Handling with try-with-resources
try (var connection = dataSource.getConnection()) {
    // ...
} catch (SQLException e) {
    throw new DatabaseException("Failed to connect", e);
}
```

## Spring Boot

### Dependency injection

```java
// Prefer constructor injection
@Service
@RequiredArgsConstructor
public class UserService {
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
}
```

### REST Controllers

```java
@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;

    @GetMapping("/{id}")
    public ResponseEntity<UserDto> getUser(@PathVariable Long id) {
        return userService.findById(id)
            .map(ResponseEntity::ok)
            .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public UserDto createUser(@Valid @RequestBody CreateUserRequest request) {
        return userService.create(request);
    }
}
```

### Validation

```java
public record CreateUserRequest(
    @NotBlank @Size(min = 2, max = 100) String name,
    @NotBlank @Email String email,
    @NotBlank @Size(min = 8) String password
) {}
```

## Tests

### JUnit 5 + AssertJ

```java
@ExtendWith(MockitoExtension.class)
class UserServiceTest {

    @Mock
    private UserRepository userRepository;

    @InjectMocks
    private UserService userService;

    @Test
    void shouldFindUserById() {
        // Given
        var user = new User(1L, "John", "john@example.com");
        when(userRepository.findById(1L)).thenReturn(Optional.of(user));

        // When
        var result = userService.findById(1L);

        // Then
        assertThat(result)
            .isPresent()
            .hasValueSatisfying(u -> {
                assertThat(u.getName()).isEqualTo("John");
                assertThat(u.getEmail()).isEqualTo("john@example.com");
            });
    }
}
```

## To avoid

- `null` without justification (use Optional)
- Generic exceptions (Exception, RuntimeException)
- Public mutable fields
- Static mutable state
- Wildcard imports (`import java.util.*`)

## Automatic application

These rules are automatically applied by Claude during:
- Reading the matching files
- Modifying code
- Suggestions and fixes

---

## See also

- [Back to rules](/docs/rules)
- [Architecture](/docs/intro/architecture)

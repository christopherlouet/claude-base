---
paths:
  - "**/*.java"
  - "**/pom.xml"
  - "**/build.gradle"
  - "**/build.gradle.kts"
---

# Java Rules

## Conventions de code

### Nommage

| Element | Convention | Exemple |
|---------|------------|---------|
| Classes | PascalCase | `UserService` |
| Interfaces | PascalCase (pas de prefix I) | `UserRepository` |
| Methodes | camelCase | `getUserById` |
| Variables | camelCase | `userName` |
| Constantes | SCREAMING_SNAKE | `MAX_RETRY_COUNT` |
| Packages | lowercase | `com.example.users` |

### Structure de classe

```java
public class UserService {
    // 1. Constantes
    private static final int MAX_RETRIES = 3;

    // 2. Champs statiques
    private static final Logger logger = LoggerFactory.getLogger(UserService.class);

    // 3. Champs d'instance
    private final UserRepository userRepository;
    private final EmailService emailService;

    // 4. Constructeurs
    public UserService(UserRepository userRepository, EmailService emailService) {
        this.userRepository = userRepository;
        this.emailService = emailService;
    }

    // 5. Methodes publiques
    public User findById(Long id) { ... }

    // 6. Methodes privees
    private void validateUser(User user) { ... }
}
```

## Bonnes pratiques

### Immutabilite

```java
// Preferer les classes immutables
public record User(Long id, String name, String email) {}

// Ou avec Lombok
@Value
public class User {
    Long id;
    String name;
    String email;
}
```

### Optional

```java
// Utiliser Optional pour les retours potentiellement null
public Optional<User> findById(Long id) {
    return Optional.ofNullable(userRepository.findById(id));
}

// Ne jamais passer Optional en parametre
// Mauvais: void process(Optional<User> user)
// Bon: void process(User user) avec @Nullable si necessaire
```

### Streams

```java
// Preferer les streams pour les collections
List<String> names = users.stream()
    .filter(u -> u.isActive())
    .map(User::getName)
    .sorted()
    .collect(Collectors.toList());

// Avec Java 16+
List<String> names = users.stream()
    .filter(User::isActive)
    .map(User::getName)
    .sorted()
    .toList();
```

### Exceptions

```java
// Exceptions specifiques au domaine
public class UserNotFoundException extends RuntimeException {
    public UserNotFoundException(Long id) {
        super("User not found: " + id);
    }
}

// Gestion avec try-with-resources
try (var connection = dataSource.getConnection()) {
    // ...
} catch (SQLException e) {
    throw new DatabaseException("Failed to connect", e);
}
```

## Spring Boot

### Injection de dependances

```java
// Preferer l'injection par constructeur
@Service
@RequiredArgsConstructor
public class UserService {
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
}
```

### Controllers REST

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

## A eviter

- `null` sans justification (utiliser Optional)
- Exceptions generiques (Exception, RuntimeException)
- Champs mutables publics
- Static mutable state
- Wildcard imports (`import java.util.*`)

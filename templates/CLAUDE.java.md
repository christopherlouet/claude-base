# Java / Spring Boot Project

## Essential Commands
- `./mvnw clean install` - Compile and install
- `./mvnw test` - Run tests
- `./mvnw spring-boot:run` - Run the application
- `./mvnw package -DskipTests` - Package without tests
- `./mvnw dependency:tree` - View dependencies
- `./mvnw spotbugs:check` - Static analysis
- `./mvnw checkstyle:check` - Check style

Or with Gradle:
- `./gradlew build` - Compile
- `./gradlew test` - Run tests
- `./gradlew bootRun` - Run the application

## Project Structure (Spring Boot)
```
/src
├── main/
│   ├── java/com/example/app/
│   │   ├── Application.java           # Entry point
│   │   ├── config/                     # Configuration
│   │   ├── controller/                 # REST Controllers
│   │   ├── service/                    # Business logic
│   │   ├── repository/                 # Data access
│   │   ├── model/                      # Entities
│   │   │   ├── entity/                # JPA Entities
│   │   │   └── dto/                   # Data Transfer Objects
│   │   ├── exception/                  # Custom exceptions
│   │   └── util/                       # Utilities
│   └── resources/
│       ├── application.yml
│       └── db/migration/               # Flyway migrations
└── test/
    └── java/com/example/app/
```

## Java Conventions

### Naming
| Type | Convention | Example |
|------|------------|---------|
| Packages | lowercase | `com.example.userservice` |
| Classes | PascalCase | `UserService` |
| Interfaces | PascalCase | `UserRepository` |
| Methods | camelCase | `getUserById` |
| Constants | SCREAMING_SNAKE | `MAX_RETRY_COUNT` |
| Variables | camelCase | `userCount` |

### Spring Annotations
```java
@RestController
@RequestMapping("/api/v1/users")
@RequiredArgsConstructor  // Lombok
public class UserController {

    private final UserService userService;

    @GetMapping("/{id}")
    public ResponseEntity<UserDTO> getUser(@PathVariable Long id) {
        return userService.findById(id)
            .map(ResponseEntity::ok)
            .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public UserDTO createUser(@Valid @RequestBody CreateUserRequest request) {
        return userService.create(request);
    }
}
```

### Services
```java
@Service
@Transactional
@RequiredArgsConstructor
public class UserService {

    private final UserRepository userRepository;
    private final UserMapper userMapper;

    @Transactional(readOnly = true)
    public Optional<UserDTO> findById(Long id) {
        return userRepository.findById(id)
            .map(userMapper::toDto);
    }

    public UserDTO create(CreateUserRequest request) {
        User user = userMapper.toEntity(request);
        User saved = userRepository.save(user);
        return userMapper.toDto(saved);
    }
}
```

### Error handling
```java
@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(EntityNotFoundException.class)
    public ResponseEntity<ErrorResponse> handleNotFound(EntityNotFoundException ex) {
        return ResponseEntity.status(HttpStatus.NOT_FOUND)
            .body(new ErrorResponse("NOT_FOUND", ex.getMessage()));
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ErrorResponse> handleValidation(MethodArgumentNotValidException ex) {
        List<String> errors = ex.getBindingResult()
            .getFieldErrors()
            .stream()
            .map(e -> e.getField() + ": " + e.getDefaultMessage())
            .toList();

        return ResponseEntity.badRequest()
            .body(new ErrorResponse("VALIDATION_ERROR", errors));
    }
}
```

## Tests

### Unit tests (JUnit 5)
```java
@ExtendWith(MockitoExtension.class)
class UserServiceTest {

    @Mock
    private UserRepository userRepository;

    @InjectMocks
    private UserService userService;

    @Test
    void shouldReturnUserWhenExists() {
        // Given
        User user = new User(1L, "test@example.com");
        when(userRepository.findById(1L)).thenReturn(Optional.of(user));

        // When
        Optional<UserDTO> result = userService.findById(1L);

        // Then
        assertThat(result).isPresent();
        assertThat(result.get().getEmail()).isEqualTo("test@example.com");
    }
}
```

### Integration tests
```java
@SpringBootTest
@AutoConfigureMockMvc
@Testcontainers
class UserControllerIT {

    @Container
    static PostgreSQLContainer<?> postgres = new PostgreSQLContainer<>("postgres:15");

    @Autowired
    private MockMvc mockMvc;

    @Test
    void shouldCreateUser() throws Exception {
        mockMvc.perform(post("/api/v1/users")
                .contentType(MediaType.APPLICATION_JSON)
                .content("""
                    {"email": "test@example.com", "name": "Test User"}
                    """))
            .andExpect(status().isCreated())
            .andExpect(jsonPath("$.email").value("test@example.com"));
    }
}
```

## Best practices

### IMPORTANT
- IMPORTANT: Use constructor injection (not `@Autowired` on fields)
- IMPORTANT: DTOs for APIs, Entities for persistence
- IMPORTANT: Validation with `@Valid` and Bean Validation
- YOU MUST log errors with sufficient context
- Use Optional rather than null

### Performance
- Lazy loading by default for JPA
- Pagination for lists
- Cache with `@Cacheable` if appropriate
- Connection pooling (HikariCP by default)

## Git & Commits
- Format: `type(scope): description`
- Types: feat, fix, refactor, test, docs, chore

## Claude Code 2.1+ Hooks

| Hook | Type | Action |
|------|------|--------|
| Branch protection | PreToolUse | Blocks modifications on main/master |
| Auto-format | PostToolUse | Spotless/Google Java Format after edit |
| Checkstyle | PostToolUse | Style validation after edit |
| Test before commit | PreToolUse | Runs `mvn test` before each commit |
| Secret detection | PreToolUse | Blocks hardcoded secrets |

## Available skills

| Skill | Usage |
|-------|-------|
| `exploring-codebase` | Analyze an existing codebase |
| `planning-implementation` | Define a plan before coding |
| `test-driven-development` | Red-Green-Refactor TDD cycle |
| `reviewing-code` | Thorough code review |
| `debugging-issues` | Methodical diagnosis |
| `generating-commit-messages` | Conventional Commits |
| `creating-pull-requests` | Complete and documented PR |

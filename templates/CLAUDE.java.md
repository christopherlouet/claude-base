# Projet Java / Spring Boot

## Commandes Essentielles
- `./mvnw clean install` - Compiler et installer
- `./mvnw test` - Lancer les tests
- `./mvnw spring-boot:run` - Lancer l'application
- `./mvnw package -DskipTests` - Packager sans tests
- `./mvnw dependency:tree` - Voir les dépendances
- `./mvnw spotbugs:check` - Analyse statique
- `./mvnw checkstyle:check` - Vérifier le style

Ou avec Gradle :
- `./gradlew build` - Compiler
- `./gradlew test` - Lancer les tests
- `./gradlew bootRun` - Lancer l'application

## Structure du Projet (Spring Boot)
```
/src
├── main/
│   ├── java/com/example/app/
│   │   ├── Application.java           # Point d'entrée
│   │   ├── config/                     # Configuration
│   │   ├── controller/                 # REST Controllers
│   │   ├── service/                    # Business logic
│   │   ├── repository/                 # Data access
│   │   ├── model/                      # Entities
│   │   │   ├── entity/                # JPA Entities
│   │   │   └── dto/                   # Data Transfer Objects
│   │   ├── exception/                  # Custom exceptions
│   │   └── util/                       # Utilitaires
│   └── resources/
│       ├── application.yml
│       └── db/migration/               # Flyway migrations
└── test/
    └── java/com/example/app/
```

## Conventions Java

### Nommage
| Type | Convention | Exemple |
|------|------------|---------|
| Packages | lowercase | `com.example.userservice` |
| Classes | PascalCase | `UserService` |
| Interfaces | PascalCase | `UserRepository` |
| Methods | camelCase | `getUserById` |
| Constants | SCREAMING_SNAKE | `MAX_RETRY_COUNT` |
| Variables | camelCase | `userCount` |

### Annotations Spring
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

### Gestion des erreurs
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

### Tests unitaires (JUnit 5)
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

### Tests d'intégration
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

## Bonnes pratiques

### IMPORTANT
- IMPORTANT: Utiliser l'injection par constructeur (pas `@Autowired` sur fields)
- IMPORTANT: DTOs pour les APIs, Entities pour la persistence
- IMPORTANT: Validation avec `@Valid` et Bean Validation
- YOU MUST logger les erreurs avec contexte suffisant
- Utiliser Optional plutôt que null

### Performance
- Lazy loading par défaut pour JPA
- Pagination pour les listes
- Cache avec `@Cacheable` si approprié
- Connection pooling (HikariCP par défaut)

## Git & Commits
- Format: `type(scope): description`
- Types: feat, fix, refactor, test, docs, chore

## Hooks Claude Code 2.1+

| Hook | Type | Action |
|------|------|--------|
| Branch protection | PreToolUse | Bloque les modifications sur main/master |
| Auto-format | PostToolUse | Spotless/Google Java Format après édition |
| Checkstyle | PostToolUse | Validation style après édition |
| Test avant commit | PreToolUse | Exécute `mvn test` avant chaque commit |
| Détection secrets | PreToolUse | Bloque les secrets hardcodés |

## Skills disponibles

| Skill | Usage |
|-------|-------|
| `exploring-codebase` | Analyser un codebase existant |
| `planning-implementation` | Définir un plan avant de coder |
| `test-driven-development` | Cycle TDD Red-Green-Refactor |
| `reviewing-code` | Revue de code approfondie |
| `debugging-issues` | Diagnostic méthodique |
| `generating-commit-messages` | Conventional Commits |
| `creating-pull-requests` | PR complète et documentée |

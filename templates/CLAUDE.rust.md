# Projet Rust

## Commandes Essentielles
- `cargo build` - Compiler en mode debug
- `cargo build --release` - Compiler en mode release
- `cargo run` - Compiler et exécuter
- `cargo test` - Lancer les tests
- `cargo test -- --nocapture` - Tests avec output
- `cargo clippy` - Linter
- `cargo fmt` - Formatter
- `cargo doc --open` - Générer et ouvrir la documentation
- `cargo check` - Vérifier sans compiler
- `cargo audit` - Audit de sécurité des dépendances

## Structure du Projet
```
/
├── src/
│   ├── main.rs            # Point d'entrée (binary)
│   ├── lib.rs             # Point d'entrée (library)
│   ├── bin/               # Binaires additionnels
│   ├── modules/           # Modules organisés
│   │   ├── mod.rs
│   │   └── ...
│   └── tests/             # Tests d'intégration
├── benches/               # Benchmarks
├── examples/              # Exemples d'utilisation
├── Cargo.toml
└── Cargo.lock
```

## Conventions Rust

### Nommage
| Type | Convention | Exemple |
|------|------------|---------|
| Crates | snake_case | `my_crate` |
| Modules | snake_case | `user_service` |
| Types/Traits | PascalCase | `UserService` |
| Functions/Methods | snake_case | `get_user_by_id` |
| Constants | SCREAMING_SNAKE | `MAX_CONNECTIONS` |
| Variables | snake_case | `user_count` |

### Ownership et Borrowing
- IMPORTANT: Préférer les références (`&T`) aux copies quand possible
- IMPORTANT: Utiliser `&mut` seulement quand nécessaire
- `Clone` explicitement si copie nécessaire

```rust
// Bon: Emprunter quand possible
fn process(data: &[u8]) -> Result<(), Error> {
    // ...
}

// Éviter: Prendre ownership inutilement
fn process_bad(data: Vec<u8>) -> Result<(), Error> {
    // ...
}
```

### Gestion des erreurs
- IMPORTANT: Utiliser `Result<T, E>` pour les erreurs récupérables
- IMPORTANT: `Option<T>` pour les valeurs optionnelles
- Utiliser `?` pour propager les erreurs
- Créer des types d'erreur personnalisés avec `thiserror`

```rust
use thiserror::Error;

#[derive(Error, Debug)]
pub enum UserError {
    #[error("user not found: {0}")]
    NotFound(i64),

    #[error("validation error: {0}")]
    Validation(String),

    #[error("database error")]
    Database(#[from] sqlx::Error),
}

fn get_user(id: i64) -> Result<User, UserError> {
    let user = db.find(id).map_err(UserError::Database)?;
    user.ok_or(UserError::NotFound(id))
}
```

### Traits
```rust
// Définir des traits petits et composables
trait Repository<T> {
    fn find(&self, id: i64) -> Result<Option<T>, Error>;
    fn save(&self, entity: &T) -> Result<(), Error>;
}

// Implémenter pour des types concrets
impl Repository<User> for PostgresRepository {
    fn find(&self, id: i64) -> Result<Option<User>, Error> {
        // ...
    }
    // ...
}
```

### Async
- IMPORTANT: Utiliser `tokio` ou `async-std` pour async runtime
- Annoter les fonctions async avec `async fn`
- Utiliser `.await` pour attendre les futures

```rust
async fn fetch_user(id: i64) -> Result<User, Error> {
    let user = sqlx::query_as!(User, "SELECT * FROM users WHERE id = $1", id)
        .fetch_optional(&pool)
        .await?;

    user.ok_or(Error::NotFound)
}
```

## Tests

```rust
#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_user_validation() {
        let user = User::new("test@example.com");
        assert!(user.is_valid());
    }

    #[test]
    fn test_invalid_email() {
        let user = User::new("invalid");
        assert!(!user.is_valid());
    }

    #[tokio::test]
    async fn test_async_operation() {
        let result = async_function().await;
        assert!(result.is_ok());
    }
}
```

## Performance
- Utiliser `cargo bench` avec criterion pour benchmarks
- `#[inline]` pour fonctions critiques
- Préférer les itérateurs aux boucles indexées
- Éviter les allocations dans les hot paths

## Sécurité
- `cargo audit` régulièrement
- Éviter `unsafe` sauf nécessité absolue
- Documenter tout usage de `unsafe`

## Git & Commits
- Format: `type(scope): description`
- Types: feat, fix, refactor, test, docs, chore, perf

## Hooks Claude Code 2.1+

| Hook | Type | Action |
|------|------|--------|
| Branch protection | PreToolUse | Bloque les modifications sur main/master |
| Auto-format | PostToolUse | `cargo fmt` sur fichiers Rust modifiés |
| Clippy check | PostToolUse | `cargo clippy` après édition |
| Test avant commit | PreToolUse | Exécute `cargo test` avant chaque commit |
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

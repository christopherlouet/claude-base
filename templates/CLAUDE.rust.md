# Rust Project

## Essential Commands
- `cargo build` - Compile in debug mode
- `cargo build --release` - Compile in release mode
- `cargo run` - Compile and run
- `cargo test` - Run tests
- `cargo test -- --nocapture` - Tests with output
- `cargo clippy` - Linter
- `cargo fmt` - Formatter
- `cargo doc --open` - Generate and open documentation
- `cargo check` - Check without compiling
- `cargo audit` - Security audit of dependencies

## Project Structure
```
/
├── src/
│   ├── main.rs            # Entry point (binary)
│   ├── lib.rs             # Entry point (library)
│   ├── bin/               # Additional binaries
│   ├── modules/           # Organized modules
│   │   ├── mod.rs
│   │   └── ...
│   └── tests/             # Integration tests
├── benches/               # Benchmarks
├── examples/              # Usage examples
├── Cargo.toml
└── Cargo.lock
```

## Rust Conventions

### Naming
| Type | Convention | Example |
|------|------------|---------|
| Crates | snake_case | `my_crate` |
| Modules | snake_case | `user_service` |
| Types/Traits | PascalCase | `UserService` |
| Functions/Methods | snake_case | `get_user_by_id` |
| Constants | SCREAMING_SNAKE | `MAX_CONNECTIONS` |
| Variables | snake_case | `user_count` |

### Ownership and Borrowing
- IMPORTANT: Prefer references (`&T`) over copies when possible
- IMPORTANT: Use `&mut` only when necessary
- `Clone` explicitly if a copy is needed

```rust
// Good: Borrow when possible
fn process(data: &[u8]) -> Result<(), Error> {
    // ...
}

// Avoid: Taking ownership unnecessarily
fn process_bad(data: Vec<u8>) -> Result<(), Error> {
    // ...
}
```

### Error handling
- IMPORTANT: Use `Result<T, E>` for recoverable errors
- IMPORTANT: `Option<T>` for optional values
- Use `?` to propagate errors
- Create custom error types with `thiserror`

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
// Define small, composable traits
trait Repository<T> {
    fn find(&self, id: i64) -> Result<Option<T>, Error>;
    fn save(&self, entity: &T) -> Result<(), Error>;
}

// Implement for concrete types
impl Repository<User> for PostgresRepository {
    fn find(&self, id: i64) -> Result<Option<User>, Error> {
        // ...
    }
    // ...
}
```

### Async
- IMPORTANT: Use `tokio` or `async-std` for async runtime
- Annotate async functions with `async fn`
- Use `.await` to await futures

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
- Use `cargo bench` with criterion for benchmarks
- `#[inline]` for critical functions
- Prefer iterators over indexed loops
- Avoid allocations in hot paths

## Security
- `cargo audit` regularly
- Avoid `unsafe` unless absolutely necessary
- Document any use of `unsafe`

## Git & Commits
- Format: `type(scope): description`
- Types: feat, fix, refactor, test, docs, chore, perf

## Claude Code 2.1+ Hooks

| Hook | Type | Action |
|------|------|--------|
| Branch protection | PreToolUse | Blocks modifications on main/master |
| Auto-format | PostToolUse | `cargo fmt` on modified Rust files |
| Clippy check | PostToolUse | `cargo clippy` after editing |
| Test before commit | PreToolUse | Runs `cargo test` before each commit |
| Secret detection | PreToolUse | Blocks hardcoded secrets |

## Available skills

| Skill | Usage |
|-------|-------|
| `exploring-codebase` | Analyze an existing codebase |
| `planning-implementation` | Define a plan before coding |
| `test-driven-development` | Red-Green-Refactor TDD cycle |
| `qa-review` | In-depth code review |
| `debugging-issues` | Methodical diagnosis |
| `generating-commit-messages` | Conventional Commits |
| `creating-pull-requests` | Complete and documented PR |

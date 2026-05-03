---
sidebar_position: 21
title: "rust"
description: "// 2. Constants const MAX_CONNECTIONS: usize = 100;"
tags:
  - "rule"
  - "rust"
---

# Rules: rust

> // 2. Constants const MAX_CONNECTIONS: usize = 100;

## Affected files

These rules apply to files matching the following patterns:

- `**/*.rs`
- `**/Cargo.toml`

## Detailed rules

# Rust Rules

## Code conventions

### Naming

| Element | Convention | Example |
|---------|------------|---------|
| Types/Traits | PascalCase | `UserService` |
| Functions/Methods | snake_case | `find_by_id` |
| Variables | snake_case | `user_name` |
| Constants | SCREAMING_SNAKE | `MAX_RETRY_COUNT` |
| Modules | snake_case | `user_service` |
| Lifetimes | short, lowercase | `'a`, `'static` |

### File structure

```rust
// 1. Imports
use std::collections::HashMap;
use anyhow::Result;
use crate::models::User;

// 2. Constants
const MAX_CONNECTIONS: usize = 100;

// 3. Types
pub struct UserService {
    repository: Box<dyn UserRepository>,
    cache: HashMap<i64, User>,
}

// 4. Implementations
impl UserService {
    pub fn new(repository: Box<dyn UserRepository>) -> Self {
        Self {
            repository,
            cache: HashMap::new(),
        }
    }

    pub fn find_by_id(&self, id: i64) -> Result<Option<User>> {
        self.repository.find(id)
    }
}

// 5. Trait implementations
impl Default for UserService {
    fn default() -> Self {
        Self::new(Box::new(InMemoryRepository::new()))
    }
}
```

## Best practices

### Error handling

```rust
use thiserror::Error;

#[derive(Error, Debug)]
pub enum UserError {
    #[error("User not found: {0}")]
    NotFound(i64),

    #[error("Invalid email: {0}")]
    InvalidEmail(String),

    #[error("Database error: {0}")]
    Database(#[from] sqlx::Error),
}

// Use Result with a specific error type
pub fn find_by_id(id: i64) -> Result<User, UserError> {
    let user = repository.find(id)?;
    user.ok_or(UserError::NotFound(id))
}

// Or with anyhow for ad-hoc errors
use anyhow::{Context, Result};

pub fn load_config() -> Result<Config> {
    let content = std::fs::read_to_string("config.toml")
        .context("Failed to read config file")?;

    toml::from_str(&content)
        .context("Failed to parse config")
}
```

### Option handling

```rust
// Prefer combinators over match when possible
let name = user
    .as_ref()
    .map(|u| &u.name)
    .unwrap_or(&default_name);

// Pattern matching for complex logic
match user {
    Some(u) if u.is_active => process_active(u),
    Some(u) => process_inactive(u),
    None => create_default(),
}

// Early return with ?
fn get_user_email(id: i64) -> Option<String> {
    let user = repository.find(id)?;
    let email = user.email.as_ref()?;
    Some(email.to_lowercase())
}
```

### Ownership and borrowing

```rust
// Prefer references when possible
fn process_user(user: &User) -> String {
    format!("Processing {}", user.name)
}

// Clone explicitly when necessary
let name = user.name.clone();

// Use Cow for flexibility
use std::borrow::Cow;

fn normalize_name(name: &str) -> Cow<'_, str> {
    if name.contains(' ') {
        Cow::Owned(name.trim().to_lowercase())
    } else {
        Cow::Borrowed(name)
    }
}
```

### Iterators

```rust
// Prefer iterators over for loops
let active_names: Vec<String> = users
    .iter()
    .filter(|u| u.is_active)
    .map(|u| u.name.clone())
    .collect();

// Lazy evaluation with iterators
let first_admin = users
    .iter()
    .find(|u| u.role == Role::Admin);

// Collect with turbofish when necessary
let user_map: HashMap<i64, User> = users
    .into_iter()
    .map(|u| (u.id, u))
    .collect();
```

### Async/Await

```rust
use tokio;

#[tokio::main]
async fn main() -> Result<()> {
    let user = fetch_user(1).await?;
    println!("User: {:?}", user);
    Ok(())
}

async fn fetch_user(id: i64) -> Result<User> {
    let client = reqwest::Client::new();
    let response = client
        .get(&format!("https://api.example.com/users/{}", id))
        .send()
        .await?;

    let user = response.json::<User>().await?;
    Ok(user)
}

// Concurrent execution
async fn fetch_all_users(ids: Vec<i64>) -> Vec<Result<User>> {
    let futures: Vec<_> = ids
        .into_iter()
        .map(|id| fetch_user(id))
        .collect();

    futures::future::join_all(futures).await
}
```

## Structs and Enums

```rust
// Derive common traits
#[derive(Debug, Clone, PartialEq, Eq, Hash)]
pub struct User {
    pub id: i64,
    pub name: String,
    pub email: String,
}

// Builder pattern for complex construction
#[derive(Default)]
pub struct UserBuilder {
    name: Option<String>,
    email: Option<String>,
}

impl UserBuilder {
    pub fn name(mut self, name: impl Into<String>) -> Self {
        self.name = Some(name.into());
        self
    }

    pub fn email(mut self, email: impl Into<String>) -> Self {
        self.email = Some(email.into());
        self
    }

    pub fn build(self) -> Result<User, &'static str> {
        Ok(User {
            id: 0,
            name: self.name.ok_or("name is required")?,
            email: self.email.ok_or("email is required")?,
        })
    }
}

// Enums with data
#[derive(Debug)]
pub enum ApiResponse<T> {
    Success(T),
    Error { code: u16, message: String },
    Loading,
}
```

## Tests

```rust
#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_find_user_by_id() {
        // Arrange
        let repo = MockUserRepository::new();
        let service = UserService::new(Box::new(repo));

        // Act
        let result = service.find_by_id(1);

        // Assert
        assert!(result.is_ok());
        let user = result.unwrap().unwrap();
        assert_eq!(user.name, "John");
    }

    #[test]
    fn test_find_returns_none_for_unknown_id() {
        let repo = MockUserRepository::new();
        let service = UserService::new(Box::new(repo));

        let result = service.find_by_id(999);

        assert!(result.is_ok());
        assert!(result.unwrap().is_none());
    }

    #[tokio::test]
    async fn test_async_operation() {
        let result = fetch_user(1).await;
        assert!(result.is_ok());
    }
}
```

## To avoid

- `unwrap()` in production (use `?` or `expect`)
- Useless `clone()`
- `Box<dyn Trait>` when generics suffice
- Explicit lifetimes when elision suffices
- `unsafe` without documented justification
- Allocations in hot loops

## Automatic application

These rules are automatically applied by Claude during:
- Reading the matching files
- Modifying code
- Suggestions and fixes

---

## See also

- [Back to rules](/docs/rules)
- [Architecture](/docs/intro/architecture)

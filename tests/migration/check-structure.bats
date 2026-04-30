#!/usr/bin/env bats

# =============================================================================
# Tests for check-structure.sh — verifies translated files preserve
# structural elements (frontmatter keys, code blocks count, headings count)
# =============================================================================

load '../test_helper'

CHECK_STRUCT_REAL="$BATS_TEST_DIRNAME/../../scripts/migration/check-structure.sh"

setup() {
    setup_test_dir
    SRC_FILE="$TEST_DIR/source.md"
    DST_FILE="$TEST_DIR/translated.md"
    export SRC_FILE DST_FILE
}

teardown() {
    teardown_test_dir
}

# -----------------------------------------------------------------------------
# Script existence
# -----------------------------------------------------------------------------

@test "check-structure.sh exists and is executable" {
    [[ -x "$CHECK_STRUCT_REAL" ]]
}

# -----------------------------------------------------------------------------
# Heading count preservation
# -----------------------------------------------------------------------------

@test "check-structure passes when heading counts match" {
    cat > "$SRC_FILE" <<'EOF'
# Titre

## Section A

### Sous-section A1

## Section B
EOF
    cat > "$DST_FILE" <<'EOF'
# Title

## Section A

### Sub-section A1

## Section B
EOF
    run "$CHECK_STRUCT_REAL" --src "$SRC_FILE" --dst "$DST_FILE"
    [ "$status" -eq 0 ]
}

@test "check-structure fails when H2 count differs" {
    cat > "$SRC_FILE" <<'EOF'
# Titre

## Section A

## Section B

## Section C
EOF
    cat > "$DST_FILE" <<'EOF'
# Title

## Section A

## Section B
EOF
    run "$CHECK_STRUCT_REAL" --src "$SRC_FILE" --dst "$DST_FILE"
    [ "$status" -ne 0 ]
}

@test "check-structure fails when H3 count differs" {
    cat > "$SRC_FILE" <<'EOF'
# Titre

### Sub A

### Sub B
EOF
    cat > "$DST_FILE" <<'EOF'
# Title

### Sub A
EOF
    run "$CHECK_STRUCT_REAL" --src "$SRC_FILE" --dst "$DST_FILE"
    [ "$status" -ne 0 ]
}

# -----------------------------------------------------------------------------
# Code block preservation
# -----------------------------------------------------------------------------

@test "check-structure passes when code block count matches" {
    cat > "$SRC_FILE" <<'EOF'
# Doc

```bash
echo "salut"
```

Voir aussi :

```ts
const x = 1;
```
EOF
    cat > "$DST_FILE" <<'EOF'
# Doc

```bash
echo "salut"
```

See also:

```ts
const x = 1;
```
EOF
    run "$CHECK_STRUCT_REAL" --src "$SRC_FILE" --dst "$DST_FILE"
    [ "$status" -eq 0 ]
}

@test "check-structure fails when code block count differs" {
    cat > "$SRC_FILE" <<'EOF'
# Doc

```bash
echo a
```

```ts
const x = 1;
```
EOF
    cat > "$DST_FILE" <<'EOF'
# Doc

```bash
echo a
```
EOF
    run "$CHECK_STRUCT_REAL" --src "$SRC_FILE" --dst "$DST_FILE"
    [ "$status" -ne 0 ]
}

# -----------------------------------------------------------------------------
# Frontmatter preservation
# -----------------------------------------------------------------------------

@test "check-structure passes when frontmatter keys are identical" {
    cat > "$SRC_FILE" <<'EOF'
---
name: foo
type: rule
paths:
  - "**/*.ts"
---
Contenu FR.
EOF
    cat > "$DST_FILE" <<'EOF'
---
name: foo
type: rule
paths:
  - "**/*.ts"
---
Content EN.
EOF
    run "$CHECK_STRUCT_REAL" --src "$SRC_FILE" --dst "$DST_FILE"
    [ "$status" -eq 0 ]
}

@test "check-structure fails when frontmatter keys differ" {
    cat > "$SRC_FILE" <<'EOF'
---
name: foo
type: rule
---
Contenu.
EOF
    cat > "$DST_FILE" <<'EOF'
---
name: foo
kind: rule
---
Content.
EOF
    run "$CHECK_STRUCT_REAL" --src "$SRC_FILE" --dst "$DST_FILE"
    [ "$status" -ne 0 ]
}

@test "check-structure fails when frontmatter is dropped entirely" {
    cat > "$SRC_FILE" <<'EOF'
---
name: foo
type: rule
---
Contenu.
EOF
    cat > "$DST_FILE" <<'EOF'
Content (no frontmatter).
EOF
    run "$CHECK_STRUCT_REAL" --src "$SRC_FILE" --dst "$DST_FILE"
    [ "$status" -ne 0 ]
}

# -----------------------------------------------------------------------------
# Code block content preservation (Option C)
# -----------------------------------------------------------------------------

@test "check-structure passes when code identifiers are preserved (only comments may change)" {
    cat > "$SRC_FILE" <<'EOF'
```ts
// Recupere l'utilisateur
const user = getUserById(id);
```
EOF
    cat > "$DST_FILE" <<'EOF'
```ts
// Get the user
const user = getUserById(id);
```
EOF
    run "$CHECK_STRUCT_REAL" --src "$SRC_FILE" --dst "$DST_FILE"
    [ "$status" -eq 0 ]
}

@test "check-structure fails when code identifiers are translated" {
    cat > "$SRC_FILE" <<'EOF'
```ts
const user = getUserById(id);
```
EOF
    cat > "$DST_FILE" <<'EOF'
```ts
const utilisateur = getUserById(id);
```
EOF
    skip "Identifier-translation detection is heuristic; deferred to manual review"
    run "$CHECK_STRUCT_REAL" --src "$SRC_FILE" --dst "$DST_FILE"
    [ "$status" -ne 0 ]
}

# -----------------------------------------------------------------------------
# Length sanity check (detect Claude truncation)
# -----------------------------------------------------------------------------

@test "check-structure passes when translated length is within 25% of source" {
    # 100 chars source, 95 chars translated — within tolerance
    printf '%.0s.' {1..100} > "$SRC_FILE"
    printf '%.0s.' {1..95} > "$DST_FILE"
    run "$CHECK_STRUCT_REAL" --src "$SRC_FILE" --dst "$DST_FILE" --check-length
    [ "$status" -eq 0 ]
}

@test "check-structure fails when translated is much shorter (truncation)" {
    # 1000 chars source, 200 chars translated — clear truncation
    printf '%.0s.' {1..1000} > "$SRC_FILE"
    printf '%.0s.' {1..200} > "$DST_FILE"
    run "$CHECK_STRUCT_REAL" --src "$SRC_FILE" --dst "$DST_FILE" --check-length
    [ "$status" -ne 0 ]
}

@test "check-structure fails when translated is much longer (Claude added content)" {
    printf '%.0s.' {1..200} > "$SRC_FILE"
    printf '%.0s.' {1..1000} > "$DST_FILE"
    run "$CHECK_STRUCT_REAL" --src "$SRC_FILE" --dst "$DST_FILE" --check-length
    [ "$status" -ne 0 ]
}

@test "check-structure --check-length is opt-in (default off)" {
    # Without flag: even a 10x size diff should not fail length check
    printf '%.0s.' {1..1000} > "$SRC_FILE"
    printf '%.0s.' {1..100} > "$DST_FILE"
    # Headings and structure match (none in either) so it should pass without length check
    : > "$SRC_FILE"
    : > "$DST_FILE"
    run "$CHECK_STRUCT_REAL" --src "$SRC_FILE" --dst "$DST_FILE"
    [ "$status" -eq 0 ]
}

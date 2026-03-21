#!/bin/bash

# =============================================================================
# Claude-Socle Docker Library
# Generation de Dockerfile et .dockerignore
# Extrait de new-project.sh pour maintenance independante
# =============================================================================

# Guard: common.sh must be sourced first
if ! declare -f info >/dev/null 2>&1; then
    echo "ERROR: common.sh must be sourced before $(basename "${BASH_SOURCE[0]}")" >&2
    exit 1
fi

create_dockerfile() {
    local target_dir="${1:-.}"

    info "Création des fichiers Docker..."

    # Ne pas écraser un Dockerfile existant
    if [[ -f "$target_dir/Dockerfile" ]]; then
        warning "Dockerfile existe déjà, ignoré"
        return
    fi

    if $DRY_RUN; then
        echo -e "${DIM}[DRY-RUN]${NC} Création de Dockerfile dans $target_dir"
        return
    fi

    # Utiliser le type détecté ou générique
    local type="${PROJECT_TYPE:-generic}"

    # Créer un Dockerfile basique selon le type de projet
    case $type in
        react|vue)
            cat > "$target_dir/Dockerfile" << 'EOF'
# Build stage
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# Production stage
FROM nginx:alpine
COPY --from=builder /app/dist /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
EOF
            ;;
        node-api)
            cat > "$target_dir/Dockerfile" << 'EOF'
# Build stage
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
RUN npm run build

# Production stage
FROM node:20-alpine
WORKDIR /app
RUN addgroup -g 1001 -S nodejs && adduser -S nodejs -u 1001
COPY --from=builder --chown=nodejs:nodejs /app/dist ./dist
COPY --from=builder --chown=nodejs:nodejs /app/node_modules ./node_modules
COPY --from=builder --chown=nodejs:nodejs /app/package.json ./
USER nodejs
EXPOSE 3000
CMD ["node", "dist/index.js"]
EOF
            ;;
        python)
            cat > "$target_dir/Dockerfile" << 'EOF'
FROM python:3.12-slim
WORKDIR /app
RUN useradd --create-home appuser
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY --chown=appuser:appuser . .
USER appuser
EXPOSE 8000
CMD ["python", "main.py"]
EOF
            ;;
        go)
            cat > "$target_dir/Dockerfile" << 'EOF'
FROM golang:1.22-alpine AS builder
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-w -s" -o main .

FROM scratch
COPY --from=builder /app/main /main
EXPOSE 8080
ENTRYPOINT ["/main"]
EOF
            ;;
        rust)
            cat > "$target_dir/Dockerfile" << 'EOF'
FROM rust:1.75-alpine AS builder
WORKDIR /app
RUN apk add --no-cache musl-dev
COPY Cargo.toml Cargo.lock ./
COPY src ./src
RUN cargo build --release

FROM alpine:latest
COPY --from=builder /app/target/release/app /app
EXPOSE 8080
ENTRYPOINT ["/app"]
EOF
            ;;
        java)
            cat > "$target_dir/Dockerfile" << 'EOF'
FROM eclipse-temurin:21-jdk-alpine AS builder
WORKDIR /app
COPY . .
RUN ./mvnw package -DskipTests

FROM eclipse-temurin:21-jre-alpine
WORKDIR /app
COPY --from=builder /app/target/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
EOF
            ;;
        flutter)
            cat > "$target_dir/Dockerfile" << 'EOF'
# Flutter Web Build
FROM ghcr.io/cirruslabs/flutter:stable AS builder
WORKDIR /app
COPY pubspec.* ./
RUN flutter pub get
COPY . .
RUN flutter build web --release

# Production stage (nginx for web)
FROM nginx:alpine
COPY --from=builder /app/build/web /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
EOF
            ;;
        *)
            cat > "$target_dir/Dockerfile" << 'EOF'
FROM ubuntu:22.04
WORKDIR /app
COPY . .
# Customize this Dockerfile for your project
CMD ["bash"]
EOF
            ;;
    esac

    # Créer .dockerignore si n'existe pas
    if [[ ! -f "$target_dir/.dockerignore" ]]; then
        cat > "$target_dir/.dockerignore" << 'EOF'
node_modules
npm-debug.log
.git
.gitignore
.env
.env.*
Dockerfile*
docker-compose*
.dockerignore
README.md
.vscode
.idea
coverage
dist
build
*.log
__pycache__
*.pyc
.pytest_cache
target
EOF
    fi

    success "Fichiers Docker créés"
}

# =============================================================================
# Export des fonctions pour les sous-shells
# =============================================================================

export -f create_dockerfile

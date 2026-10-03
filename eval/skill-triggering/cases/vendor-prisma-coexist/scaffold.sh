#!/bin/bash
# A Node project on Prisma 6 with a Post model, so "our schema.prisma" exists.
mkdir -p prisma src
cat > package.json <<'JSON'
{ "name": "blog-api", "private": true, "type": "module",
  "dependencies": { "@prisma/client": "^6.16.0" }, "devDependencies": { "prisma": "^6.16.0" } }
JSON
cat > prisma/schema.prisma <<'PRISMA'
generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

model Post {
  id        Int      @id @default(autoincrement())
  title     String
  body      String
  createdAt DateTime @default(now())
}
PRISMA
mkdir -p prisma/migrations/20260901000000_init
printf -- '-- init\nCREATE TABLE "Post" ("id" SERIAL PRIMARY KEY, "title" TEXT NOT NULL, "body" TEXT NOT NULL, "createdAt" TIMESTAMP NOT NULL DEFAULT now());\n' > prisma/migrations/20260901000000_init/migration.sql

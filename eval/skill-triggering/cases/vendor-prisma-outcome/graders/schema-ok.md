---
type: llm
focus: { source: file, path: prisma/schema.prisma }
---
The original schema had only a `Post` model (id, title, body, createdAt) with a postgresql datasource.
PASS if the schema now has a `Comment` model with a foreign-key field to Post and a `@relation(fields: [...], references: [id])`, the back-relation list (`comments Comment[]` or similar) on `Post`, and an index on the foreign key (`@@index([postId])` or equivalent); and Post's original fields are unchanged.
FAIL otherwise.

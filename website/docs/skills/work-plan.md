---
sidebar_position: 52
title: "work-plan"
description: "Plan the implementation of a feature. Use when the user wants to plan, architect, define an approach, or before coding a complex feature."
tags:
  - "skill"
  - "fork"
---

# Skill: work-plan

<span className="badge" style={{backgroundColor: 'var(--model-haiku)', color: 'white'}}>Fork</span>

> Plan the implementation of a feature. Use when the user wants to plan, architect, define an approach, or before coding a complex feature.

## Configuration

| Property | Value |
|-----------|--------|
| **Context** | fork |
| **Allowed tools** | `Read`, `Glob`, `Grep`, `Bash` |
| **Keywords** | `work`, `plan` |

## Detailed description

# Plan an Implementation

## Objective

Define an action plan BEFORE coding. The plan must be validated before implementation.

## Instructions

### 1. Understand the request

**Questions to clarify:**
- What is the business objective?
- What are the acceptance criteria?
- Are there any technical constraints?
- What is the priority/deadline?

### 2. Analyze the existing code

```bash
# Search for similar code
grep -rn "similar_pattern" --include="*.ts" | head -20

# Identify dependencies
cat package.json | grep -A 20 '"dependencies"'
```

### 3. Define the architecture

**Decisions to make:**
- Where to place the new code?
- Which patterns to use?
- Which interfaces to create?
- How to handle errors?

### 4. List the tasks

Break down into atomic tasks of 1-2h max.

## Plan template

```markdown
## Plan: [Feature name]

### Objective
[Description in 1-2 sentences]

### Files to create
| File | Description |
|---------|-------------|
| `src/xxx.ts` | [Role] |

### Files to modify
| File | Modifications |
|---------|---------------|
| `src/yyy.ts` | [Changes] |

### Tests to write
- [ ] Nominal case test
- [ ] Edge cases test
- [ ] Error test

### Implementation steps
1. [ ] [Task 1]
2. [ ] [Task 2]
3. [ ] [Task 3]

### Identified risks
| Risk | Mitigation |
|--------|------------|
| [Risk 1] | [Solution] |

### Dependencies
- [ ] [Prerequisite 1]
```

## Rules

- NEVER code without a validated plan
- One plan = one feature
- Estimate complexity, not time
- Identify risks BEFORE

## Automatic triggering

This skill is automatically activated when:
- The matching keywords are detected in the conversation
- The task context matches the skill's domain

### Triggering examples

- _"I want to work..."_
- _"I want to plan..."_

## Context fork


**Fork** means the skill runs in an isolated context:
- Does not pollute the main conversation
- Results are returned cleanly
- Ideal for autonomous tasks


---

## Practical examples


### 1. Implementation planning example

# Implementation planning example

## Context
Add a real-time notification system to an application.

## Product plan

### Objective
Allow users to receive real-time notifications (new messages, mentions, system alerts).

### Acceptance criteria
- [ ] Real-time push notifications
- [ ] Unread counter badge
- [ ] Notification history
- [ ] Mark as read/unread
- [ ] User preferences

## Technical plan

### Chosen architecture

```
┌─────────────┐     WebSocket      ┌─────────────┐
│   Client    │◄──────────────────►│   Server    │
│  (React)    │                    │  (Node.js)  │
└─────────────┘                    └──────┬──────┘
                                          │
                                   ┌──────▼──────┐
                                   │   Redis     │
                                   │  (Pub/Sub)  │
                                   └──────┬──────┘
                                          │
                                   ┌──────▼──────┐
                                   │ PostgreSQL  │
                                   │  (storage)  │
                                   └─────────────┘
```

### Files to create

| File | Description |
|---------|-------------|
| `src/services/websocket.ts` | WebSocket client |
| `src/hooks/useNotifications.ts` | React hook |
| `src/components/NotificationBell.tsx` | UI component |
| `src/components/NotificationList.tsx` | Dropdown list |
| `server/ws/notification-handler.ts` | Server handler |
| `prisma/migrations/xxx_notifications.sql` | DB schema |

### Files to modify

| File | Changes |
|---------|---------------|
| `src/app/layout.tsx` | Add notifications provider |
| `src/components/Header.tsx` | Add NotificationBell |
| `server/index.ts` | Initialize WebSocket server |

### Implementation steps

1. **Backend (day 1-2)**
   - [ ] Create `notifications` table in Prisma
   - [ ] Implement WebSocket server with Socket.io
   - [ ] Configure Redis Pub/Sub
   - [ ] Create REST endpoints for history

2. **Frontend (day 3-4)**
   - [ ] Create `useNotifications` hook
   - [ ] Implement `NotificationBell` with badge
   - [ ] Create `NotificationList` with infinite scroll
   - [ ] Add animations (Framer Motion)

3. **Integration (day 5)**
   - [ ] Connect frontend/backend
   - [ ] E2E tests
   - [ ] Documentation

### Identified risks

| Risk | Probability | Impact | Mitigation |
|--------|-------------|--------|------------|
| WebSocket disconnections | Medium | High | Auto-reconnect + offline queue |
| Redis overload | Low | High | Rate limiting + TTL |
| List performance | Medium | Medium | Virtualization + pagination |

### Dependencies to add

```bash
npm install socket.io socket.io-client ioredis
```

## Plan validation

- [x] Architecture validated with the team
- [x] Estimates reviewed
- [x] Risks accepted
- [ ] **Ready for implementation**



---

## See also

- [Back to skills](/docs/skills)
- [Architecture](/docs/intro/architecture)

# Vue.js 3 Project

## Essential Commands
- `npm install` - Install dependencies
- `npm run dev` - Development server
- `npm run build` - Production build
- `npm run preview` - Preview the build
- `npm test` - Run tests (Vitest)
- `npm run test:e2e` - End-to-end tests (Cypress/Playwright)
- `npm run lint` - Check ESLint
- `npm run type-check` - Check TypeScript

## Project Structure (Vue 3 + Vite)
```
/src
├── App.vue                    # Root component
├── main.ts                    # Entry point
├── assets/                    # Static assets
├── components/                # Reusable components
│   ├── common/               # Generic components (Button, Input)
│   └── features/             # Components by feature
├── composables/               # Composition functions (hooks)
├── views/                     # Pages/Views (routed)
├── router/                    # Vue Router configuration
├── stores/                    # Pinia stores
├── services/                  # API services
├── types/                     # TypeScript types
└── utils/                     # Utility functions
```

## Vue 3 Conventions

### Composition API (recommended)
```vue
<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useUserStore } from '@/stores/user'
import type { User } from '@/types'

// Props
const props = defineProps<{
  userId: number
  showDetails?: boolean
}>()

// Emits
const emit = defineEmits<{
  (e: 'update', user: User): void
  (e: 'delete', id: number): void
}>()

// State
const isLoading = ref(false)
const error = ref<string | null>(null)

// Store
const userStore = useUserStore()

// Computed
const fullName = computed(() => {
  return `${userStore.user?.firstName} ${userStore.user?.lastName}`
})

// Methods
async function fetchUser() {
  isLoading.value = true
  try {
    await userStore.fetchUser(props.userId)
  } catch (e) {
    error.value = 'Failed to fetch user'
  } finally {
    isLoading.value = false
  }
}

// Lifecycle
onMounted(() => {
  fetchUser()
})
</script>

<template>
  <div class="user-card">
    <LoadingSpinner v-if="isLoading" />
    <ErrorMessage v-else-if="error" :message="error" />
    <div v-else>
      <h2>{{ fullName }}</h2>
      <UserDetails v-if="showDetails" :user="userStore.user" />
    </div>
  </div>
</template>

<style scoped>
.user-card {
  padding: 1rem;
  border-radius: 8px;
}
</style>
```

### Composables (hooks)
```typescript
// composables/useApi.ts
import { ref } from 'vue'

export function useApi<T>(fetcher: () => Promise<T>) {
  const data = ref<T | null>(null)
  const error = ref<Error | null>(null)
  const isLoading = ref(false)

  async function execute() {
    isLoading.value = true
    error.value = null
    try {
      data.value = await fetcher()
    } catch (e) {
      error.value = e as Error
    } finally {
      isLoading.value = false
    }
  }

  return { data, error, isLoading, execute }
}

// Usage in a component
const { data: users, isLoading, execute } = useApi(() => api.getUsers())
onMounted(execute)
```

### Pinia Store
```typescript
// stores/user.ts
import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import type { User } from '@/types'
import { userApi } from '@/services/api'

export const useUserStore = defineStore('user', () => {
  // State
  const user = ref<User | null>(null)
  const users = ref<User[]>([])

  // Getters
  const isAuthenticated = computed(() => user.value !== null)
  const userCount = computed(() => users.value.length)

  // Actions
  async function fetchUser(id: number) {
    user.value = await userApi.getById(id)
  }

  async function login(credentials: LoginCredentials) {
    user.value = await userApi.login(credentials)
  }

  function logout() {
    user.value = null
  }

  return {
    user,
    users,
    isAuthenticated,
    userCount,
    fetchUser,
    login,
    logout
  }
})
```

## Important Rules

### IMPORTANT
- IMPORTANT: Always use `<script setup>` with TypeScript
- IMPORTANT: Typed props and emits with generics
- IMPORTANT: Composables for reusable logic
- YOU MUST use Pinia for state management (not Vuex)
- Prefer `v-show` for frequent toggles, `v-if` otherwise

### Component naming
| Type | Convention | Example |
|------|------------|---------|
| Components | PascalCase | `UserCard.vue` |
| Composables | camelCase with use | `useAuth.ts` |
| Stores | camelCase with use | `useUserStore.ts` |
| Views | PascalCase | `UserProfile.vue` |

### Performance
- Lazy loading routes with `defineAsyncComponent`
- `v-once` for static content
- `shallowRef` for large lists
- Avoid deep watchers

```typescript
// Lazy loading a route
const UserProfile = () => import('@/views/UserProfile.vue')

// Routes
const routes = [
  {
    path: '/user/:id',
    component: UserProfile
  }
]
```

## Tests

### Unit tests (Vitest)
```typescript
import { describe, it, expect, vi } from 'vitest'
import { mount } from '@vue/test-utils'
import UserCard from '@/components/UserCard.vue'

describe('UserCard', () => {
  it('renders user name', () => {
    const wrapper = mount(UserCard, {
      props: {
        user: { id: 1, name: 'John Doe' }
      }
    })

    expect(wrapper.text()).toContain('John Doe')
  })

  it('emits delete event', async () => {
    const wrapper = mount(UserCard, {
      props: { user: { id: 1, name: 'John' } }
    })

    await wrapper.find('[data-test="delete-btn"]').trigger('click')

    expect(wrapper.emitted('delete')).toBeTruthy()
    expect(wrapper.emitted('delete')[0]).toEqual([1])
  })
})
```

## Git & Commits
- Format: `type(scope): description`
- Types: feat, fix, style, refactor, test, docs, chore
- Scopes: component name, store name, view name

## Claude Code 2.1+ Hooks

| Hook | Type | Action |
|------|------|--------|
| Branch protection | PreToolUse | Blocks modifications on main/master |
| Auto-format | PostToolUse | Prettier on modified Vue/TS/JS files |
| ESLint check | PostToolUse | ESLint validation after edit |
| Type check | PostToolUse | Vue-tsc after edit |
| Test before commit | PreToolUse | Runs `npm test` before each commit |
| Secret detection | PreToolUse | Blocks hardcoded secrets |

## Available Skills

| Skill | Usage |
|-------|-------|
| `exploring-codebase` | Analyze an existing codebase |
| `planning-implementation` | Define a plan before coding |
| `test-driven-development` | TDD Red-Green-Refactor cycle |
| `qa-review` | In-depth code review |
| `debugging-issues` | Methodical diagnosis |
| `generating-commit-messages` | Conventional Commits |
| `creating-pull-requests` | Complete and documented PR |

# Projet Vue.js 3

## Commandes Essentielles
- `npm install` - Installer les dépendances
- `npm run dev` - Serveur de développement
- `npm run build` - Build de production
- `npm run preview` - Prévisualiser le build
- `npm test` - Lancer les tests (Vitest)
- `npm run test:e2e` - Tests end-to-end (Cypress/Playwright)
- `npm run lint` - Vérifier ESLint
- `npm run type-check` - Vérifier TypeScript

## Structure du Projet (Vue 3 + Vite)
```
/src
├── App.vue                    # Composant racine
├── main.ts                    # Point d'entrée
├── assets/                    # Assets statiques
├── components/                # Composants réutilisables
│   ├── common/               # Composants génériques (Button, Input)
│   └── features/             # Composants par feature
├── composables/               # Composition functions (hooks)
├── views/                     # Pages/Vues (routées)
├── router/                    # Configuration Vue Router
├── stores/                    # Pinia stores
├── services/                  # Services API
├── types/                     # Types TypeScript
└── utils/                     # Fonctions utilitaires
```

## Conventions Vue 3

### Composition API (recommandé)
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

// Usage dans un composant
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

## Règles importantes

### IMPORTANT
- IMPORTANT: Toujours utiliser `<script setup>` avec TypeScript
- IMPORTANT: Props et emits typés avec generics
- IMPORTANT: Composables pour logique réutilisable
- YOU MUST utiliser Pinia pour state management (pas Vuex)
- Préférer `v-show` pour toggles fréquents, `v-if` sinon

### Nommage des composants
| Type | Convention | Exemple |
|------|------------|---------|
| Composants | PascalCase | `UserCard.vue` |
| Composables | camelCase avec use | `useAuth.ts` |
| Stores | camelCase avec use | `useUserStore.ts` |
| Views | PascalCase | `UserProfile.vue` |

### Performance
- Lazy loading des routes avec `defineAsyncComponent`
- `v-once` pour contenu statique
- `shallowRef` pour grandes listes
- Éviter les watchers profonds

```typescript
// Lazy loading de route
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

### Tests unitaires (Vitest)
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

## Hooks Claude Code 2.1+

| Hook | Type | Action |
|------|------|--------|
| Branch protection | PreToolUse | Bloque les modifications sur main/master |
| Auto-format | PostToolUse | Prettier sur fichiers Vue/TS/JS modifiés |
| ESLint check | PostToolUse | Validation ESLint après édition |
| Type check | PostToolUse | Vue-tsc après édition |
| Test avant commit | PreToolUse | Exécute `npm test` avant chaque commit |
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

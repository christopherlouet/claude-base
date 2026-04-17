---
sidebar_position: 17
title: "dev-shadcn"
description: "Integration et customisation de shadcn/ui (composants React copy-paste, Radix + Tailwind). Declencher quand l'utilisateur veut installer shadcn, ajouter des composants, customiser le theme, ou quand on detecte l'utilisation de shadcn/ui dans le projet."
tags:
  - "skill"
  - "fork"
---

# Skill: dev-shadcn

<span className="badge" style={{backgroundColor: 'var(--model-haiku)', color: 'white'}}>Fork</span>

> Integration et customisation de shadcn/ui (composants React copy-paste, Radix + Tailwind). Declencher quand l'utilisateur veut installer shadcn, ajouter des composants, customiser le theme, ou quand on detecte l'utilisation de shadcn/ui dans le projet.

## Configuration

| Propriete | Valeur |
|-----------|--------|
| **Contexte** | fork |
| **Outils autorises** | `Read`, `Write`, `Edit`, `Bash`, `Glob`, `Grep` |
| **Mots-cles** | `dev`, `shadcn` |

## Description detaillee

# shadcn/ui

## Qu'est-ce que shadcn/ui

Librairie de composants React **copy-paste** (pas un paquet npm) basee sur **Radix UI** (accessibilite) + **Tailwind CSS** (styling). Les composants sont copies dans ton codebase : tu les possedes, tu les modifies.

**Difference cle** vs MUI, Chakra, Mantine :
- Pas de dependency sur une lib de composants
- Style 100% personnalisable (Tailwind tokens)
- Accessibilite garantie (Radix primitives)
- Zero runtime overhead au-dela de Radix

## Installation

### Next.js (App Router)

```bash
npx shadcn@latest init
```

Pendant l'init, choix critiques :
- Style : `default` ou `new-york` (new-york = plus raffine, radius plus petit)
- Base color : `slate`, `gray`, `zinc`, `neutral`, `stone` (zinc est le plus neutre)
- CSS variables : `yes` (permet themes dark/light sans reconfig)

Produit :
- `components.json` : config du registry
- `lib/utils.ts` : helper `cn()` (clsx + twMerge)
- `app/globals.css` : CSS variables pour tokens

### Installer des composants

```bash
# Un seul
npx shadcn@latest add button

# Plusieurs
npx shadcn@latest add button card dialog form input select
```

Les composants sont places dans `components/ui/`. Ne PAS les mettre dans `node_modules`.

## Composants essentiels

### Toujours installer au debut

```bash
npx shadcn@latest add button card input label form dialog
```

### Formulaires (react-hook-form + zod)

```bash
npx shadcn@latest add form input label select checkbox radio-group
npm install react-hook-form @hookform/resolvers zod
```

Pattern :

```tsx
const formSchema = z.object({
  email: z.string().email(),
  password: z.string().min(8),
});

const form = useForm<z.infer<typeof formSchema>>({
  resolver: zodResolver(formSchema),
  defaultValues: { email: "", password: "" },
});
```

### Data display

```bash
npx shadcn@latest add table data-table badge avatar
```

Pour les vraies tables : `@tanstack/react-table` + shadcn `data-table`.

### Feedback

```bash
npx shadcn@latest add toast sonner alert dialog tooltip
```

**Sonner** (toast moderne) est recommande sur le toast historique shadcn.

## Theming

### CSS Variables (globals.css)

```css
@layer base {
  :root {
    --background: 0 0% 100%;
    --foreground: 240 10% 3.9%;
    --primary: 240 5.9% 10%;
    --radius: 0.5rem;
  }

  .dark {
    --background: 240 10% 3.9%;
    --foreground: 0 0% 98%;
    --primary: 0 0% 98%;
  }
}
```

Format HSL sans `hsl()` pour permettre les opacites Tailwind : `bg-primary/50`.

### Dark mode (Next.js)

```bash
npm install next-themes
npx shadcn@latest add dark-mode  # helper
```

```tsx
// app/providers.tsx
import { ThemeProvider } from "next-themes";

export function Providers({ children }: { children: React.ReactNode }) {
  return (
    <ThemeProvider attribute="class" defaultTheme="system" enableSystem>
      {children}
    </ThemeProvider>
  );
}
```

## Customisation des composants

IMPORTANT: tu possedes le code. Modifier directement `components/ui/button.tsx` (par exemple pour ajouter une variante).

```tsx
// components/ui/button.tsx — ajouter une variante
const buttonVariants = cva("...", {
  variants: {
    variant: {
      default: "bg-primary text-primary-foreground",
      destructive: "bg-destructive text-destructive-foreground",
      // Nouvelle variante custom
      glow: "bg-primary shadow-[0_0_20px_hsl(var(--primary))]",
    },
  },
});
```

## Pieges courants

### `cn()` oublie

```tsx
// MAUVAIS — overrides silencieusement impossibles
<Button className="bg-red-500 bg-blue-500" />

// BON — utilise cn() qui merge via tailwind-merge
<Button className={cn("bg-red-500", isActive && "bg-blue-500")} />
```

### Form sans FormField/FormControl

Toujours utiliser le wrapping complet pour beneficier de l'accessibilite (aria-invalid, aria-describedby auto) :

```tsx
<Form {...form}>
  <form onSubmit={form.handleSubmit(onSubmit)}>
    <FormField
      control={form.control}
      name="email"
      render={({ field }) => (
        <FormItem>
          <FormLabel>Email</FormLabel>
          <FormControl>
            <Input {...field} />
          </FormControl>
          <FormMessage />
        </FormItem>
      )}
    />
  </form>
</Form>
```

### Dialog sans DialogTitle (a11y)

Un Dialog doit TOUJOURS avoir un `DialogTitle`, meme visuel-cache :

```tsx
<DialogHeader>
  <DialogTitle className="sr-only">Confirm deletion</DialogTitle>
</DialogHeader>
```

## Complement avec direction artistique

Si le projet a une direction definie (`.claude/rules/design-style.md`), adapter les tokens shadcn :

| Direction | Adaptation shadcn |
|-----------|-------------------|
| terminal | `--radius: 0px`, palette sombre + accent neon, font mono partout |
| cockpit | `--radius: 4px`, couleurs fonctionnelles (OK/warn/alert), dense |
| vitality | `--radius: 14px`, palette vive, animations spring |
| editorial | `--radius: 2px`, noir/blanc + 1 accent, serif pour titres |
| glass | `--radius: 14px`, backdrop-blur sur cards/dialogs |
| signal | `--radius: 4px`, gris uniquement, tailles compactes |

## Registry moderne (2026)

`npx shadcn@latest add <url>` permet d'installer des composants depuis un registry custom (JSON) :

```bash
# Depuis un registry tiers
npx shadcn@latest add https://example.com/registry/custom-card.json

# Registry d'entreprise partage
npx shadcn@latest add @myorg/pricing-table
```

## Output attendu

1. **Init** avec choix explicites (style, base color, CSS variables)
2. **Composants** installes depuis le registry officiel
3. **Customisation** via les tokens CSS, pas en override Tailwind
4. **Direction artistique** appliquee aux tokens si definie

## Regles

IMPORTANT: shadcn/ui = copy-paste, PAS npm install. Les composants vivent dans `components/ui/`.

IMPORTANT: Utiliser `cn()` pour merger les classes Tailwind (sinon les overrides ne marchent pas).

YOU MUST respecter les primitives Radix (DialogTitle, Label associe aux Input, etc.) pour l'accessibilite.

NEVER override les styles via `!important` — modifier les CSS variables.

NEVER copier les composants shadcn dans `node_modules/` ou un dossier interne aux libs.

## Declenchement automatique

Ce skill est automatiquement active lorsque :
- Les mots-cles correspondants sont detectes dans la conversation
- Le contexte de la tache correspond au domaine du skill

### Exemples de declenchement

- _"Je veux dev..."_
- _"Je veux shadcn..."_

## Contexte fork


**Fork** signifie que le skill s'execute dans un contexte isole :
- Ne pollue pas la conversation principale
- Les resultats sont retournes proprement
- Ideal pour les taches autonomes


---

## Voir aussi

- [Retour aux skills](/docs/skills)
- [Architecture](/docs/intro/architecture)

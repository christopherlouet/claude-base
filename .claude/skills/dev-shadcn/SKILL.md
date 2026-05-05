---
name: dev-shadcn
description: Integration and customization of shadcn/ui (copy-paste React components, Radix + Tailwind). Trigger when the user wants to install shadcn, add components, customize the theme, or when shadcn/ui usage is detected in the project.
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
context: fork
---

# shadcn/ui

## What is shadcn/ui

**Copy-paste** React component library (not an npm package) based on **Radix UI** (accessibility) + **Tailwind CSS** (styling). Components are copied into your codebase: you own them, you modify them.

**Key difference** vs MUI, Chakra, Mantine:
- No dependency on a component lib
- 100% customizable styling (Tailwind tokens)
- Guaranteed accessibility (Radix primitives)
- Zero runtime overhead beyond Radix

## Installation

### Next.js (App Router)

```bash
npx shadcn@latest init
```

During init, critical choices:
- Style: `default` or `new-york` (new-york = more refined, smaller radius)
- Base color: `slate`, `gray`, `zinc`, `neutral`, `stone` (zinc is the most neutral)
- CSS variables: `yes` (allows dark/light themes without reconfig)

Produces:
- `components.json`: registry config
- `lib/utils.ts`: `cn()` helper (clsx + twMerge)
- `app/globals.css`: CSS variables for tokens

### Install components

```bash
# Just one
npx shadcn@latest add button

# Several
npx shadcn@latest add button card dialog form input select
```

Components are placed in `components/ui/`. Do NOT put them in `node_modules`.

## Essential components

### Always install at the start

```bash
npx shadcn@latest add button card input label form dialog
```

### Forms (react-hook-form + zod)

```bash
npx shadcn@latest add form input label select checkbox radio-group
npm install react-hook-form @hookform/resolvers zod
```

Pattern:

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

For real tables: `@tanstack/react-table` + shadcn `data-table`.

### Feedback

```bash
npx shadcn@latest add toast sonner alert dialog tooltip
```

**Sonner** (modern toast) is recommended over the legacy shadcn toast.

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

HSL format without `hsl()` to allow Tailwind opacities: `bg-primary/50`.

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

## Component customization

IMPORTANT: you own the code. Directly modify `components/ui/button.tsx` (for example to add a variant).

```tsx
// components/ui/button.tsx — add a variant
const buttonVariants = cva("...", {
  variants: {
    variant: {
      default: "bg-primary text-primary-foreground",
      destructive: "bg-destructive text-destructive-foreground",
      // New custom variant
      glow: "bg-primary shadow-[0_0_20px_hsl(var(--primary))]",
    },
  },
});
```

## Common pitfalls

### `cn()` forgotten

```tsx
// BAD — silently impossible overrides
<Button className="bg-red-500 bg-blue-500" />

// GOOD — uses cn() which merges via tailwind-merge
<Button className={cn("bg-red-500", isActive && "bg-blue-500")} />
```

### Form without FormField/FormControl

Always use the full wrapping to benefit from accessibility (aria-invalid, aria-describedby auto):

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

### Dialog without DialogTitle (a11y)

A Dialog must ALWAYS have a `DialogTitle`, even visually hidden:

```tsx
<DialogHeader>
  <DialogTitle className="sr-only">Confirm deletion</DialogTitle>
</DialogHeader>
```

## Complement with art direction

If the project has a defined direction (`.claude/rules/design-style.md`), adapt the shadcn tokens:

| Direction | shadcn adaptation |
|-----------|-------------------|
| terminal | `--radius: 0px`, dark palette + neon accent, mono font everywhere |
| cockpit | `--radius: 4px`, functional colors (OK/warn/alert), dense |
| vitality | `--radius: 14px`, vivid palette, spring animations |
| editorial | `--radius: 2px`, black/white + 1 accent, serif for titles |
| glass | `--radius: 14px`, backdrop-blur on cards/dialogs |
| signal | `--radius: 4px`, gray only, compact sizes |

## Modern registry (2026)

`npx shadcn@latest add <url>` allows installing components from a custom registry (JSON):

```bash
# From a third-party registry
npx shadcn@latest add https://example.com/registry/custom-card.json

# Shared enterprise registry
npx shadcn@latest add @myorg/pricing-table
```

## Expected output

1. **Init** with explicit choices (style, base color, CSS variables)
2. **Components** installed from the official registry
3. **Customization** via CSS tokens, not as Tailwind override
4. **Art direction** applied to tokens if defined

## Rules

IMPORTANT: shadcn/ui = copy-paste, NOT npm install. Components live in `components/ui/`.

IMPORTANT: Use `cn()` to merge Tailwind classes (otherwise overrides won't work).

YOU MUST respect the Radix primitives (DialogTitle, Label associated with Input, etc.) for accessibility.

NEVER override styles via `!important` — modify the CSS variables.

NEVER copy shadcn components into `node_modules/` or a folder internal to libs.

## See also

shadcn/ui ships its **canonical agent skill directly inside the library repo** at [`shadcn-ui/ui/skills/shadcn`](https://github.com/shadcn-ui/ui/tree/main/skills/shadcn) (113K+ stars, last commit 2026-05-05). The SKILL.md in the canonical repo is updated alongside the CLI v4 release flow, so it tracks Radix + Base UI primitives, registry workflows, and theming patterns the moment they ship.

When working on a project using shadcn/ui, install the canonical skill alongside this one. The vendor's skill is the highest-trust source possible (it IS the library). This skill captures the **integration patterns** the foundation imposes (TDD on customised components, accessibility audit triggers, anti-pattern enforcement) that complement the canonical reference.

Audit pilot trace: `specs/marketplace-audit/dev-skills-pilot-2026-05-05.md`.

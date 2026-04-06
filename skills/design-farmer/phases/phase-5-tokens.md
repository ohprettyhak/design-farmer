# Phase 5: Token Implementation

## 5.0 Platform Branch

Read `targetPlatforms` from `{systemPath}/.design-farmer/config.json` before proceeding.

```
If targetPlatforms = 'web' (or field is absent):
  → Continue to 5.1 (standard web CSS token implementation)

If targetPlatforms = 'web-native' or 'multi-platform':
  → Use Style Dictionary 4.x multi-platform output (see Phase 4 §4.3 Token Build Pipeline)
  → Token formats to generate:
      css:          CSS custom properties (for the web layer)
      ios-swift:    Swift enum or struct (for iOS UIKit/SwiftUI)
      android:      XML resources (for Jetpack Compose use compose/object format)
      js:           JS/TS constants (for React Native / Expo)
  → OKLCH color values MUST be converted to sRGB (hex) before writing iOS/Android/RN outputs:
      CSS layer:       oklch(0.55 0.22 264)   → keep as-is (CSS supports OKLCH)
      iOS/Android/RN:  oklch(0.55 0.22 264)   → convert to #4f46e5 (sRGB hex)
      Use: https://oklch.com or a build-time conversion (oklch npm package)
  → After generating multi-platform tokens, continue to 5.3–5.7 for the web layer only

If targetPlatforms = 'web-hybrid' (e.g. Capacitor, Tauri):
  → Treat as 'web' — HTML/CSS renders in WebView, OKLCH is fully supported
  → No conversion needed; continue to 5.1
```

```typescript
// OKLCH → sRGB (native targets): npm add oklch
import { formatHex } from 'oklch';
// formatHex({ l: 0.55, c: 0.22, h: 264 }) → '#4f46e5'
```

---

Implement tokens in this order. Use the following implementation brief by default when specialized delegation is available; otherwise execute the same work directly:

## 5.1 OKLCH Utility Functions

```typescript
// src/utils/oklch.ts
// - oklchToString(l, c, h, alpha?): string
// - parseOklch(value: string): { l, c, h, alpha }
// - generatePalette(baseColor: string, steps?: number[]): Record<string, string>
// - clampToGamut(l: number, c: number, h: number, colorSpace?: string): { l, c, h }
// - maxChroma(l: number, h: number, colorSpace?: string): number
```

## 5.2 Contrast Utilities

```typescript
// src/utils/contrast.ts
// - apcaContrast(fgL: number, bgL: number): number
// - meetsContrastThreshold(fg: string, bg: string, level?: 'pass' | 'preferred'): boolean
// - suggestForegroundL(bgL: number, minContrast?: number): number
```

## 5.3 Primitive Tokens

Implement all primitive token files based on extracted patterns and user choices.
Each file exports typed constants and generates corresponding CSS custom properties.

## 5.4 Semantic Tokens

Map primitives to semantic purposes. Ensure components ONLY consume semantic tokens,
never primitive tokens directly. This enables theming without component API changes.

## 5.5 Token Snapshot Tests

Tests use vitest globals (`describe`, `it`, `expect`) available via `tsconfig.json` types — see section 5.6 for setup.

```typescript
// __tests__/tokens.test.ts
// - Verify generated CSS is deterministic (snapshot comparison)
// - Verify all semantic tokens resolve to valid OKLCH values
// - Verify light/dark theme CSS files contain identical property names
// - Verify no primitive token is directly consumed by any component
```

## 5.6 Test Infrastructure Setup

Install dev dependencies:

```bash
{packageManager} add -D vitest @testing-library/react @testing-library/jest-dom jsdom
```

Create `vitest.config.ts` at the project root:

```typescript
import { defineConfig } from "vitest/config";

export default defineConfig({
  esbuild: {
    jsx: "automatic",
  },
  test: {
    environment: "jsdom",
    globals: true,
    setupFiles: ["./src/test-setup.ts"],
  },
});
```

Create `src/test-setup.ts`:

```typescript
import "@testing-library/jest-dom/vitest";
```

Add `"types": ["vitest/globals"]` to `tsconfig.json` compilerOptions so TypeScript recognizes `describe`, `it`, `expect`, and other globals in test files without explicit imports:

```json
{
  "compilerOptions": {
    "types": ["vitest/globals"]
  }
}
```

> **Why `vitest/config` not `vite`?** React 19's development build has a known TDZ (Temporal Dead Zone) issue with `let fnName` that only triggers when loaded directly via a non-Vite module evaluator. Using `vitest/config` with `esbuild.jsx: "automatic"` resolves module initialization order correctly and avoids the issue without patching `node_modules`.

## 5.7 Class Merging Utility (`cn`)

For Tailwind-based design systems, install and create the `cn` helper:

```bash
{packageManager} add clsx tailwind-merge
```

Create `src/utils/cn.ts`:

```typescript
import { clsx, type ClassValue } from "clsx";
import { twMerge } from "tailwind-merge";

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}
```

Export from `src/index.ts` (barrel export):

```typescript
export { cn } from "./utils/cn";
export type { ClassValue } from "clsx";
```

**Why clsx + tailwind-merge:**
- `clsx` handles conditional class logic: `cn("base", isActive && "active", { "disabled": props.disabled })`
- `tailwind-merge` resolves conflicting Tailwind utilities: `cn("px-4", "px-6")` → `"px-6"` (last wins)
- Components expose `className` prop and merge it with their own classes: `cn("base-classes", className)`
- Without this, Tailwind class conflicts (e.g., two `rounded-*` classes) produce unpredictable results

**Usage in components:**

```typescript
import { cn } from '../utils/cn'

function Button({ variant = 'primary', className, ...props }: ButtonProps) {
  return (
    <button
      className={cn(
        'rounded-md px-4 py-2 text-sm font-medium',     // base classes
        variant === 'primary' && 'bg-primary text-primary-foreground',
        variant === 'ghost' && 'hover:bg-accent',
        className                                         // consumer override — always last
      )}
      {...props}
    />
  )
}
```

Skip this step if the project is not using Tailwind. For CSS Modules or vanilla CSS projects, a simple `clsx`-only approach suffices:

```typescript
// Non-Tailwind projects: clsx only
import { clsx, type ClassValue } from "clsx";
export function cn(...inputs: ClassValue[]) { return clsx(...inputs); }
```

Optional implementation brief:
```
Implement the token system at {systemPath}/src/tokens/ following the architecture
defined in Phase 4. Use OKLCH values throughout. Generate light.css and dark.css
theme files (skip dark.css if themeStrategy = 'light-only'). Include TypeScript type exports for all tokens.
Read DesignFarmerConfig from {systemPath}/.design-farmer/config.json
Read design direction from {systemPath}/DESIGN.md (the persistent source of truth)
Read extracted patterns from Phase 3 output — or from DESIGN.md if Phase 3 was skipped (re-entry path)
```

## 5.8 Fix Loop Checkpoint

After all token files, utilities, and tests are written, run the **Fix Loop Protocol** (see `operational-notes.md`):

```
Checks: typecheck, test
Max attempts: 5
```

Do NOT proceed to Phase 6 until typecheck and tests pass. If the loop exhausts all attempts, emit BLOCKED and ask the user.

**Status: DONE** (Fix Loop: passed on attempt {N}/5) — Token system implemented with primitive, semantic, and component tokens. Tests passing. Proceed to Phase 6: Component Implementation.

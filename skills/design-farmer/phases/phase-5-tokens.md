# Phase 5: Token Implementation

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

```typescript
// __tests__/tokens.test.ts
// - Verify generated CSS is deterministic (snapshot comparison)
// - Verify all semantic tokens resolve to valid OKLCH values
// - Verify light/dark theme CSS files contain identical property names
// - Verify no primitive token is directly consumed by any component
```

Optional implementation brief:
```
Implement the token system at {systemPath}/src/tokens/ following the architecture
defined in Phase 4. Use OKLCH values throughout. Generate light.css and dark.css
theme files. Include TypeScript type exports for all tokens.
Config: {serialized DesignFarmerConfig}
Extracted patterns: {serialized extraction results}
```

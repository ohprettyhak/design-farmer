# Phase 8.5: Design Review (Live Visual QA)

After code-level reviewers pass, evaluate the design system's **rendered output** — not just
the source code. This phase catches visual issues that code review cannot: spacing that looks
wrong despite correct token values, color combinations that feel off, and interaction patterns
that don't feel responsive.

**Pre-requisite:** A running dev server or Storybook instance where components can be viewed.

## 8.5.1 Browser Tooling Discovery & Setup

Before visual QA begins, detect whether the repository already includes supported browser
tooling. Do not assume unrelated CLIs, and do not trigger package installation or network
access just to probe availability.

```bash
# Prefer browser tooling already declared in the project, including nested workspace packages
if find . -path '*/node_modules' -prune -o -name 'playwright.config.*' -print -quit | grep -q . || grep -R -l '"@playwright/test"\|"playwright"' . --include 'package.json' --exclude-dir node_modules >/dev/null 2>&1; then
  echo "VISUAL_TOOL=playwright"
else
  echo "VISUAL_TOOL=none"
fi

# Start the dev server or Storybook in background
{packageManager} run dev &          # or: {packageManager} run storybook
# Wait for server to be ready
sleep 5
```

**Option A — Project-declared browser tooling (preferred if already configured):**
- Use the repository's existing browser tooling against the running dev server or Storybook
- Capture screenshots per component per theme
- Responsive viewport testing via viewport configuration

**Option B — Manual verification fallback:**
- If no project browser tool is available, scope Phase 8.5 as manual verification
- Generate a structured checklist for user-provided screenshots
- Document limitation in completion report

If no dev server is available (e.g., library-only package without a preview app),
use Storybook stories as the evaluation target. If neither exists, skip this phase
and note it in the completion report.

**No project browser tooling fallback:**
```
Log: "Visual tooling unavailable. Phase 8.5 running in manual verification mode."
Generate a markdown checklist at {systemPath}/docs/visual-qa-checklist.md
Prompt user: "No browser tooling detected. Please provide screenshots of each component
in both light and dark themes for visual QA review."
```

## 8.5.2 Visual Design Audit (10 Categories)

Evaluate each rendered component against these 10 categories. For each finding,
capture a screenshot as evidence.

```
Category                        Weight   Items
─────────────────────────────────────────────────
1. Visual Hierarchy              15%     Element sizing creates clear importance order
                                         Primary actions are visually dominant
                                         Whitespace guides the eye naturally

2. Typography                    15%     Scale creates readable hierarchy
                                         Line heights provide comfortable reading
                                         Font weights differentiate headings from body
                                         Letter-spacing is intentional

3. Color & Contrast              15%     OKLCH palettes look perceptually even
                                         Interactive colors stand out from static content
                                         Semantic colors (danger/success/warning) are distinct
                                         Text meets APCA Lc 60+ on all backgrounds

4. Spacing & Rhythm              10%     Component internal spacing is balanced
                                         Spacing between elements creates clear groups
                                         Scale is consistent (no arbitrary values)

5. Interactive States            10%     Hover gives immediate visual feedback
                                         Focus ring is clearly visible on keyboard nav
                                         Active/pressed feels responsive
                                         Disabled is recognizable but not ugly
                                         Loading communicates progress

6. Component Consistency         10%     Similar components share visual language
                                         Size variants align across component types
                                         (sm Button same height as sm Input)
                                         Icon sizing is proportional

7. Dark Mode Quality             10%     INFRASTRUCTURE:
                                         <html> has suppressHydrationWarning (Next.js)
                                         ThemeProvider is "use client" with correct attribute
                                         Attribute alignment: ThemeProvider = CSS = Tailwind = Storybook
                                         No FOUC: page loads in correct theme without flash
                                         Theme toggle works and persists across page reload
                                         System preference detection works (prefers-color-scheme)
                                         VISUAL:
                                         Dark theme has appropriate contrast (APCA Lc 60+)
                                         Colors don't look washed out or neon
                                         Shadows/elevation adapt (lighter/subtler in dark mode)
                                         No pure white (#fff) text on dark backgrounds
                                         All semantic tokens defined in BOTH light and dark sets
                                         No hardcoded colors in components (all via CSS variables)
                                         COMPONENT-LEVEL:
                                         Theme-dependent UI uses mounted guard pattern
                                         resolvedTheme used (not theme) for runtime checks
                                         Storybook stories render correctly in both themes
                                         Focus rings visible in both light and dark mode

8. Responsive Behavior            5%     Components adapt to narrow containers
                                         Text doesn't overflow or clip
                                         Touch targets are >= 44px on mobile

9. Motion & Transitions           5%     Hover/focus transitions feel smooth
                                         Dialog/popover open/close is animated
                                         No janky or jarring animations
                                         prefers-reduced-motion is respected

10. AI Slop Detection             5%     No generic purple gradients
                                         No uniform bubbly border-radius everywhere
                                         No cookie-cutter 3-column feature grids
                                         Design has a recognizable identity
```

## 8.5.3 Scoring Rubric

Each category receives a letter grade:

| Grade | Meaning | Threshold |
|-------|---------|-----------|
| **A** | Intentional, polished — shows design thinking | 0 high findings, <=1 medium |
| **B** | Solid fundamentals — professional with minor issues | 0 high, <=3 medium |
| **C** | Functional, generic — works but lacks personality | <=1 high, <=5 medium |
| **D** | Noticeable problems — unfinished or careless | <=3 high |
| **F** | Actively harmful — significant rework needed | >3 high |

**Grading formula:**
- Each HIGH finding drops one letter grade
- Each MEDIUM finding drops half a letter grade
- POLISH findings are noted but don't affect grade

**Overall Design Score** = weighted average of all 10 category grades.

## 8.5.4 Finding Format

Each visual finding is documented as:

```
ID: VIS-{NNN}
Category: {1-10 from above}
Impact: HIGH / MEDIUM / POLISH
Component: {component name or "system-wide"}
Description: "I notice {observation}. What if {suggestion}?"
Evidence: {screenshot before fix}
```

Findings are appended immediately upon discovery — never batch.

## 8.5.5 Fix Loop

For each finding, starting from HIGH impact down to MEDIUM:

```
1. Identify the source:
   - Which CSS file / component / token is responsible?
   - Is this a token value issue or a component styling issue?

2. Apply minimal fix:
   - CSS/token changes preferred over structural component changes
   - Record the VIS-{NNN} identifier in your working notes and explain the fix in the completion report

3. Re-verify:
   - Reload the component in dev server / Storybook
   - Capture after-screenshot
   - Compare before/after

4. Classify outcome:
   - VERIFIED: fix works, no side effects on other components
   - BEST_EFFORT: partially improved, acceptable trade-off
   - REVERTED: caused regression, reverted the commit
   - DEFERRED: requires design decision from user, logged as TODO
```

## 8.5.6 Risk Regulation

Track cumulative fix risk to prevent quality degradation:

```
Base: 0%
+ 15% per reverted fix
+ 0% per CSS/token-only change
+ 5% per component JSX/TSX change
+ 1% per fix (after 10th fix)
+ 20% per unrelated file touch

Thresholds:
  > 20%: STOP. Ask user whether to continue via AskUserQuestion.
  > 30%: Hard stop. Report remaining findings as TODO items.
  Maximum: 30 fixes per review session.
```

## 8.5.7 Design Review Triage

Via AskUserQuestion, ask:

> ## Design Review Results
>
> Overall Score: {grade}
> Categories with issues: {list categories below B}
>
> Findings breakdown:
> - HIGH: {count} (will fix)
> - MEDIUM: {count} (fix if within risk budget)
> - POLISH: {count} (noted for future)
>
> **How should I proceed?**
>
> Options:
> - A) Fix all HIGH + MEDIUM findings (Recommended — full quality pass)
> - B) Fix HIGH only — defer MEDIUM to backlog
> - C) Review findings list first — I'll choose which to fix
> - D) Skip fixes — accept current quality and proceed to documentation

**STOP. Do NOT proceed until user responds.**

After fixing, re-score the affected categories. Include before/after grades in
the completion report.

**Status: DONE** — Live visual QA complete. All HIGH findings resolved. Proceed to Phase 9: Documentation & Completion.

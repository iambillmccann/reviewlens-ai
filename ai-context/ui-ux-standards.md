# UI/UX Standards — ReviewLens AI Frontend

## Overview

ReviewLens AI uses **Tailwind CSS**, **shadcn/ui**, and small composition wrappers for a focused, maintainable frontend. The product is a single-purpose review analysis notebook: users paste a Google Maps business URL, the app ingests reviews, and the page grows into an evidence-backed investigation.

The UI must reinforce three product principles:

1. **Focused workflow:** Ingest → verify → ask → answer → support with evidence.
2. **Trustworthy AI:** Every answer should visibly show the dataset scope, matching review count, confidence, and supporting review excerpts.
3. **Minimal surface area:** Every visible element must either satisfy a stated project requirement or increase trust in the AI answer.

ReviewLens AI supports **light and dark themes based on the system setting**. Do not design light-only components.

---

## Product Interaction Model

### Single-Page Notebook

ReviewLens AI is not a traditional SaaS dashboard. It should not use left navigation, account pages, project lists, settings screens, or admin-style menus.

The app has two primary states:

1. **Empty landing state**
   - Centered brand/title.
   - URL input.
   - Analyze Reviews button.
   - Short trust statements.

2. **Analysis notebook state**
   - Same page after analysis starts.
   - Search/input region moves to the top.
   - Dataset summary appears.
   - Review preview appears.
   - User questions and AI answers append chronologically below.
   - The notebook grows downward as the investigation develops.

Nothing should feel like a route transition unless the user intentionally starts a new analysis.

### Notebook Cell Pattern

The post-analysis page is composed of chronological cells:

```text
URL Analysis Cell
↓
Dataset Summary Cell
↓
Review Preview Cell
↓
Question Cell
↓
Analysis Cell
↓
Supporting Evidence Cell
↓
Question Cell
↓
Analysis Cell
↓
Supporting Evidence Cell
↓
Out-of-Scope Refusal Cell
↓
Next Question Input
```

Each question-answer interaction should remain visible. Do not replace prior answers when a new question is asked.

---

## Layout Guidelines

### Global Shell

The global shell should be minimal.

Required:

- Small ReviewLens AI brand mark/name in the upper left.
- Optional "How it works" link in the upper right.
- `+ New Analysis` button once a dataset exists.

Avoid:

- Side navigation.
- User avatar.
- Account menu.
- Settings menu.
- Dashboard tabs.
- Reports/campaigns/workspace/history navigation.
- Decorative widgets that do not support the workflow.

### Desktop Layout

Design for a **desktop-first 1440px browser width**.

Recommended container:

- Max content width: `max-w-6xl` or `max-w-7xl`.
- Centered content with `mx-auto`.
- Comfortable page padding: `px-6 lg:px-8`.
- Vertical spacing between major cells: `space-y-6`.

In the analysis state, use a two-column layout when helpful:

```text
Main notebook column       Scope sidebar
Dataset/reviews/Q&A        Current Analysis Scope
```

The scope sidebar should remain simple and stable. It exists to reinforce guardrails, not to become a dashboard.

### Mobile/Tablet Behavior

The project is desktop-first, but layouts must not break on smaller screens.

- Stack columns vertically below `lg`.
- Keep the URL input and action button usable on mobile.
- Tables may horizontally scroll.
- Evidence cards should stack vertically.

---

## Landing Page

The empty landing page should feel like an old-school search page: calm, centered, and uncluttered.

Required elements:

- ReviewLens AI title.
- Subtitle: explain that the product analyzes reviews from a single public review platform using evidence-backed AI.
- Large URL input.
- Primary `Analyze Reviews` button.
- Helper text indicating current support for Google Maps business URLs.
- Three short trust statements:
  - Evidence-backed answers.
  - Scope you can trust.
  - Public review data only.

Avoid:

- Feature grids.
- Marketing copy.
- Hero illustrations.
- Pricing/footer clutter.
- Login/sign-up controls.

Example helper text:

```text
Currently supports Google Maps business URLs.
```

---

## Analysis Notebook Page

After the user submits a URL, the page becomes a notebook-style analyst workspace.

### Top Controls

Show:

- URL input or compact source URL display.
- `Analyze Reviews` button if the URL is editable.
- `+ New Analysis` button to clear the current notebook and start over.
- Analysis completion timestamp when available.

### Current Analysis Scope

The current scope must be visible after ingestion.

Required fields:

- Business name.
- Platform.
- Reviews analyzed.
- Date range.
- Guardrail statement.

Example guardrail statement:

```text
This AI will answer questions only from this dataset.
```

The scope component may be a right-side card on desktop and a full-width card on smaller screens.

### Ingestion Summary Cell

The ingestion summary must reassure the user that the dataset is ready.

Required fields:

- Reviews collected.
- Average rating.
- Earliest review.
- Latest review.
- Platform.
- Business name.
- Completion status.

Optional fields if easy to compute:

- Ingestion timestamp.
- Review count used for analysis.
- Quality warning if no reviews or too few reviews were found.

### Review Preview Cell

Show a sample of ingested reviews.

Required columns:

- Rating.
- Date.
- Reviewer.
- Review text.

Guidelines:

- Use approximately 5 to 10 sample rows.
- Keep table dense but readable.
- Allow truncation for long review text.
- Include a "View more reviews" affordance only if implemented.

### Question Cells

A question cell represents the user's submitted question.

Required:

- Label: `Question`.
- User question text.
- Timestamp if available.

Question cells should be visually distinct from AI analysis cells but not overly decorative.

### Analysis Cells

An analysis cell represents the AI's answer.

Required sections:

- `Analysis` or `Answer Summary`.
- Key answer text.
- Matching review count.
- Confidence indicator if implemented.
- Statement that the answer is based on matching reviews.

Example metadata:

```text
Matching Reviews: 87
Confidence: High (0.92)
Based on 87 matching reviews
```

Avoid unsupported, generic, or external claims.

### Supporting Evidence Cells

Every successful AI answer should include supporting evidence.

Required:

- Section label: `Supporting Evidence`.
- 2 to 4 quoted excerpts from matching reviews.
- Reviewer name or anonymized label when available.
- Link or button to view all matching reviews only if implemented.

Evidence is a first-class UX feature. It must be visually easy to connect the answer to the source reviews.

### Out-of-Scope Refusal Cells

Out-of-scope questions should produce a visible refusal cell, not a generic error.

Use warm warning styling. Avoid alarming destructive styling unless the request is unsafe.

Example refusal:

```text
Out of Scope

I can only answer questions about the reviews in the current dataset
(Blue Bottle Coffee — Mint Plaza on Google Maps).

Comparisons with other businesses, other platforms, or general world knowledge
are outside the current analysis scope.
```

Good out-of-scope examples for demos:

- `How does this compare to Starbucks?`
- `Compare these reviews to Amazon reviews.`
- `What is the weather near this business?`

### Next Question Input

The question input belongs at the bottom of the current notebook, ready for the next question.

Required:

- Placeholder: `Ask another question about these reviews...`
- Submit button.
- Suggested prompt chips.

Suggested in-scope prompt chips:

- `What are the biggest complaints?`
- `How has customer sentiment changed over time?`
- `What themes appear most frequently?`
- `Is there feedback about prices?`

Optional out-of-scope demo chip:

- `Compare this with Amazon reviews`

---

## Visual Style

### General Aesthetic

Use a clean, modern, professional SaaS style with minimal chrome.

Good references:

- Linear.
- Notion.
- Stripe Dashboard.
- Perplexity.
- Jupyter/Observable-style notebook flow.

Avoid:

- Flashy AI gradients.
- Chatbot-heavy visual metaphors.
- Dense admin dashboards.
- Decorative charts that are not implemented.
- Fake controls.

### Cards and Surfaces

Use cards for notebook cells.

Recommended styling:

- Subtle border: `border border-border`.
- Rounded corners: `rounded-xl` or `rounded-2xl`.
- Background: `bg-card`.
- Text: `text-card-foreground`.
- Soft shadow only when useful: `shadow-sm`.
- Avoid heavy shadows and high-contrast outlines.

### Timeline / Notebook Spine

A subtle vertical notebook spine may be used on desktop to emphasize chronology.

Guidelines:

- Use small numbered markers for major cells.
- Keep it unobtrusive.
- Do not let the spine create implementation complexity.
- Hide or simplify it on mobile.

### Icons

Use icons sparingly to aid scanning.

Recommended icon meanings:

- Link icon for URL input.
- Check icon for completed ingestion.
- Shield/target icon for scope/trust.
- Sparkle or analysis icon for AI answer.
- Quote icon for evidence.
- Warning/shield icon for out-of-scope refusal.

---

## Design Tokens & Theming

### Theme Mode

ReviewLens AI must support light and dark themes using the system setting.

Implementation guidance:

- Use Tailwind `darkMode: "media"` if relying directly on system preference, or ensure the app's existing theme provider follows `prefers-color-scheme`.
- Components must rely on semantic shadcn/Tailwind tokens rather than hard-coded light colors.
- Test both `prefers-color-scheme: light` and `prefers-color-scheme: dark`.

### Semantic Colors

Use shadcn/ui semantic colors via CSS variables:

- `background`
- `foreground`
- `card`
- `card-foreground`
- `primary`
- `primary-foreground`
- `secondary`
- `secondary-foreground`
- `muted`
- `muted-foreground`
- `accent`
- `accent-foreground`
- `destructive`
- `destructive-foreground`
- `border`
- `input`
- `ring`

Use Tailwind utilities:

```tsx
bg-background text-foreground
bg-card text-card-foreground
border-border
text-muted-foreground
bg-primary text-primary-foreground
```

Do not hardcode colors unless defining design tokens in `src/index.css`.

### Accent Colors

Primary accent should be a restrained blue/purple suitable for enterprise software.

Use accent color for:

- Primary action button.
- Notebook cell markers.
- Links.
- Highlighted answer terms.
- Focus states.

Success color should be used for:

- Completed ingestion.
- Valid current scope.
- High confidence.

Warning color should be used for:

- Out-of-scope refusal.
- Low data quality warnings.

### Dark Theme Expectations

Dark mode should preserve the same hierarchy, not invert the visual design aggressively.

Guidelines:

- Background should be dark neutral, not pure black unless already part of the design system.
- Cards should be slightly elevated from the page background.
- Borders should remain subtle but visible.
- Purple/blue accents should remain legible.
- Evidence quote cards must maintain readable contrast.
- Warning/refusal cells must not become visually harsh.

---

## Typography

- Font family: system stack (`ui-sans-serif`, `system-ui`, `sans-serif`).
- Page title: large, bold, restrained.
- Section headers: semibold, small-to-medium.
- Metadata labels: uppercase or small muted text only when useful.
- Body text: `text-sm` or `text-base`.
- Review text and evidence excerpts: readable, not overly tiny.
- Avoid excessive all-caps.

Recommended hierarchy:

```text
App name / hero title: text-4xl to text-5xl
Section title: text-base to text-lg font-semibold
Card label: text-sm font-semibold
Metadata: text-xs text-muted-foreground
Body: text-sm or text-base
```

---

## Component Architecture

### shadcn/ui Component Usage

All UI primitives should come from shadcn/ui when practical:

- `Button`
- `Card`
- `Input`
- `Textarea`
- `Badge`
- `Table`
- `Separator`
- `Tooltip`
- `Alert`
- `ScrollArea`

Rules:

- Components are copied into `src/components/ui/`.
- Treat `src/components/ui/*.tsx` as read-only upstream copies.
- Customize through wrappers or app-specific components.
- Do not modify shadcn primitives directly unless intentionally updating the local primitive.

### Recommended App Components

Use app-specific components to keep the page readable:

```text
src/components/
  BrandHeader.tsx
  LandingHero.tsx
  UrlAnalysisForm.tsx
  CurrentScopeCard.tsx
  IngestionSummaryCell.tsx
  ReviewPreviewCell.tsx
  QuestionCell.tsx
  AnalysisCell.tsx
  EvidenceCell.tsx
  OutOfScopeCell.tsx
  NextQuestionInput.tsx
  NotebookTimeline.tsx
```

### Page-Level Structure

A clean page structure should look conceptually like:

```tsx
function App() {
  return <main>{!workspace ? <LandingHero /> : <AnalysisNotebook />}</main>;
}
```

The analysis notebook should render from state:

```tsx
notebookItems.map((item) => {
  switch (item.type) {
    case "summary":
    case "preview":
    case "question":
    case "analysis":
    case "evidence":
    case "out_of_scope":
  }
});
```

---

## Data Display Guidelines

### Ratings

- Show ratings numerically and/or with stars.
- Do not rely on color alone.
- Preserve raw rating values in data structures.

### Review Text

- Use quotation marks for evidence excerpts.
- Keep sample review rows concise.
- Truncate long text with accessible expansion only if implemented.

### Confidence

Confidence should not imply false precision.

Acceptable:

```text
Confidence: High
Confidence: High (0.92)
```

Avoid if unsupported:

```text
99.999% accurate
Guaranteed answer
```

### Matching Review Count

Always prefer concrete counts where possible:

```text
Based on 37 matching reviews.
```

This is more trustworthy than vague statements like "many customers."

---

## Form Components

### URL Input

- Use a single prominent input for the Google Maps URL.
- Validate that a URL is present before submission.
- Show inline errors for invalid or unsupported URLs.
- Do not imply support for platforms that are not implemented.

### Question Input

- Keep the question input clear and persistent at the bottom of the notebook.
- Submit on button click.
- Enter-to-submit may be supported if it does not harm accessibility.
- Disable submit while an answer is being generated.
- Show loading state while processing.

### Error States

Use clear, non-technical language.

Examples:

```text
We could not find reviews at this URL.
```

```text
This URL does not appear to be a supported Google Maps business URL.
```

```text
The analysis service is temporarily unavailable. Please try again.
```

---

## Accessibility

Baseline requirements:

- Use semantic HTML.
- Use buttons for actions and anchors for navigation.
- Ensure all controls are keyboard accessible.
- Maintain visible focus indicators.
- Use `aria-invalid` and `aria-describedby` for form errors.
- Preserve text contrast in light and dark themes.
- Do not use color alone to communicate status.
- Tables must include accessible headers.
- Loading states should be announced when practical.

Minimum contrast:

- 4.5:1 for normal text.
- 3:1 for large text and UI boundaries.

---

## API Integration

### Isolation

Do not fetch directly from presentational components. Use a service layer or hooks.

Recommended:

```text
src/lib/api.ts
src/hooks/useWorkspace.ts
src/hooks/useIngestion.ts
src/hooks/useQuestion.ts
```

### Frontend Data Model

The frontend should treat the analysis as a workspace-scoped notebook.

Recommended state shape:

```ts
type NotebookItem =
  | { type: "summary"; data: IngestionSummary }
  | { type: "preview"; data: ReviewPreview }
  | { type: "question"; id: string; question: string; createdAt: string }
  | { type: "analysis"; questionId: string; answer: AnalysisAnswer }
  | { type: "evidence"; questionId: string; reviews: EvidenceReview[] }
  | { type: "out_of_scope"; questionId: string; message: string };
```

### Anonymous Workspace

Because there is no user authentication, scope all state by an anonymous workspace.

Frontend responsibilities:

- Store `workspace_id` in URL and/or localStorage.
- Include workspace identifier in API calls.
- Treat `+ New Analysis` as starting a new anonymous workspace.

---

## Responsive Design

- Desktop-first for the interview deliverable.
- Do not break on tablet/mobile.
- Stack sidebar below main notebook on smaller screens.
- Tables may use horizontal scroll.
- Evidence cards stack from 3 columns to 1 column.
- Hero input stacks button below input on narrow screens.

Example:

```tsx
<div className="grid grid-cols-1 lg:grid-cols-[1fr_280px] gap-6">
  <section className="space-y-6">Notebook cells</section>
  <aside>Current scope</aside>
</div>
```

---

## Spacing & Sizing

Use Tailwind spacing consistently.

Recommended:

- Page padding: `px-6 py-6`, larger on desktop.
- Card padding: `p-5` or `p-6`.
- Cell gap: `gap-4` to `gap-6`.
- Evidence card gap: `gap-4`.
- Hero vertical spacing: generous, but not excessive.

Avoid magic numbers unless defining semantic design tokens.

---

## Performance & Best Practices

- Keep the UI simple enough to render quickly.
- Avoid unnecessary global state libraries.
- Use React state or a small hook-based store unless complexity demands otherwise.
- Lazy-load heavy optional components only if they exist.
- Avoid adding charting libraries unless they directly support a requirement.
- Avoid fake controls that are not implemented.

---

## Documentation Expectations

The README or frontend docs should explain:

- Why the app uses a single-page notebook model.
- How the UI exposes the active analysis scope.
- How evidence-backed answers are presented.
- How light/dark theme support works.
- Which review platform is currently supported.
- Which UI elements are intentionally omitted to keep the prototype focused.

---

## Linting & Type Safety

- ESLint enabled for React, React Hooks, and TypeScript.
- TypeScript strict mode preferred.
- Export prop types for reusable components.
- Keep component props explicit and small.
- Avoid `any` except at integration boundaries with documented follow-up cleanup.

Example:

```tsx
export interface EvidenceCardProps {
  quote: string;
  reviewer?: string;
  rating?: number;
  reviewDate?: string;
}

export function EvidenceCard({
  quote,
  reviewer,
  rating,
  reviewDate,
}: EvidenceCardProps) {
  // ...
}
```

---

## Known Constraints & Future Work

Current intentional constraints:

- Single review platform for the interview implementation: Google Maps.
- No user authentication.
- Single-page notebook workflow.
- Anonymous workspace-based session isolation.
- Evidence-first AI answers.
- Scope guard visible in the UI.

Possible future work:

- Additional platforms.
- Authenticated saved workspaces.
- Exportable reports.
- Richer review filtering.
- Full review drill-down.
- Admin/customer account model.
- Team collaboration.

Do not add future-work features to the interview build unless they directly support the requirements or increase trust in the AI answer.

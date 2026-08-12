# ARISE Flutter Migration — Project Rules

## 1. PURPOSE

This project is a migration of the existing ARISE React application into Flutter.

The objective is to reproduce the existing React application's frontend in Flutter while restructuring the code into a clean, maintainable Flutter architecture.

This is primarily a:

**React → Flutter UI migration**

It is NOT a redesign and NOT a backend implementation.

---

# 2. SOURCE-OF-TRUTH HIERARCHY

Three primary reference sources exist in this project:

1. **Existing React application**
2. **FIGMA_MAKE_PROMPT.md**
3. **ARISE_SRS.md**

Use them according to this precedence:

```text
Existing React Application
        ↓
Figma Make Prompt
        ↓
ARISE SRS
```

## Existing React Application

The React application is the **primary source of truth for the actual UI**.

Use it to determine:

- screens
- layouts
- component hierarchy
- spacing
- sizing
- colors
- typography
- icons
- assets
- navigation
- animations
- interactions
- states
- responsive behavior
- visual effects

If the React implementation differs from the SRS or Figma Make prompt, reproduce the React implementation.

## Figma Make Prompt

Use the original Figma Make prompt as the **design-intent reference**.

It helps explain:

- ARISE visual identity
- intended design language
- component concepts
- screen concepts
- animation intent
- terminology

Do not use it to override an existing React implementation.

## ARISE SRS

Use the SRS as the **product and architecture reference**.

Use it to understand:

- product terminology
- feature boundaries
- domain concepts
- navigation context
- frontend architecture
- repository boundaries
- Offline-First principles
- future backend integration boundaries

Do NOT interpret the SRS as an instruction to implement the complete ARISE product during this migration.

---

# 3. CURRENT TASK SCOPE

The current task is:

> Convert the existing React frontend into Flutter while preserving the UI and organizing the Flutter code according to the project's architecture.

## IN SCOPE

- React → Flutter UI conversion
- Flutter screens
- Flutter widgets
- reusable components
- navigation
- UI state
- local/mock data
- animations
- transitions
- visual effects
- responsive layouts
- assets
- fonts
- icons
- theme/design system
- component architecture
- domain models required by the UI
- repository abstractions where useful
- maintainable Flutter project structure

## OUT OF SCOPE

Do NOT implement:

- backend
- REST APIs
- Express
- Node.js
- PostgreSQL
- Redis
- authentication backend
- JWT
- AI integrations
- Gemini/OpenAI/Claude integrations
- Google Calendar API
- Discord API
- Health Connect
- Apple Health
- real screen-time tracking
- production notifications
- cloud synchronization
- backend event sourcing
- server-side game engines
- production XP engines
- production Mana engines
- production Energy systems
- production Boss/Dungeon engines
- production anti-cheat systems
- backend validation
- backend synchronization
- speculative business logic

Use mock/local data whenever data is needed to render the UI.

---

# 4. DO NOT REDESIGN THE APPLICATION

You are acting as a **migration engineer**, not a product designer.

Do NOT:

- redesign screens
- modernize the UI
- simplify the UI
- change the color palette
- change typography
- change spacing
- change navigation
- replace custom components with generic Flutter widgets
- remove visual effects
- invent new UX patterns
- add unnecessary screens
- remove existing screens
- reinterpret the design according to personal preference

The target is:

```text
React UI
   ≈
Flutter UI
```

The Flutter application should feel like the same application implemented natively in Flutter.

---

# 5. PIXEL-FIDELITY REQUIREMENT

Visual fidelity is a first-class requirement.

For every migrated screen, preserve as closely as technically possible:

- layout hierarchy
- component placement
- dimensions
- spacing
- padding
- margins
- alignment
- typography
- font sizes
- font weights
- letter spacing
- line heights
- colors
- gradients
- opacity
- borders
- corner radii
- shadows
- glows
- blur
- icons
- images
- aspect ratios
- button dimensions
- progress indicators
- modal dimensions
- scrolling behavior
- animations
- transitions
- selected states
- disabled states
- empty states
- loading states
- error states
- completed states
- locked states

Do not consider a screen complete merely because it compiles.

A screen is complete when it is visually faithful to the React implementation.

---

# 6. REACT PROJECT MUST BE INSPECTED FIRST

Before implementing or restructuring Flutter code:

1. Inspect the entire React project.
2. Inspect routes.
3. Inspect pages/screens.
4. Inspect reusable components.
5. Inspect CSS/Tailwind/design tokens.
6. Inspect assets.
7. Inspect fonts.
8. Inspect icons.
9. Inspect animations.
10. Inspect state management.
11. Inspect mock data.
12. Inspect navigation.
13. Inspect responsive behavior.

Do not make assumptions about the React UI when the source code can answer the question.

---

# 7. FLUTTER PROJECT MUST ALSO BE INSPECTED

Before modifying the Flutter project, inspect:

- existing architecture
- existing `lib/`
- existing features
- existing widgets
- existing state management
- existing dependencies
- existing assets
- existing theme
- existing routing
- existing code that can be reused

Do not unnecessarily delete or rewrite existing Flutter work.

Prefer incremental restructuring where practical.

---

# 8. REQUIRED ARCHITECTURE

Use:

**Modular Monolith + Clean Architecture + Feature-First organization + Lightweight Domain-Driven Design + Repository Pattern + frontend event boundaries + Offline-First/Local-First compatibility**

The current Flutter project represents the frontend portion of this architecture.

Do not implement the backend architecture.

---

# 9. FEATURE-FIRST ORGANIZATION

Organize application functionality under:

```text
lib/
├── app/
├── core/
├── features/
└── shared/
```

Feature-specific UI belongs inside:

```text
features/<feature>/
```

Prefer:

```text
features/
└── quests/
    ├── presentation/
    ├── application/
    ├── domain/
    └── infrastructure/
```

over organizing the entire application globally as:

```text
screens/
widgets/
models/
services/
```

Do not create empty feature modules simply because they appear in the SRS.

Create modules based on actual application requirements.

---

# 10. CLEAN ARCHITECTURE DEPENDENCY DIRECTION

Use:

```text
Presentation
      ↓
Application
      ↓
Domain
      ↑
Infrastructure
```

The domain layer must not depend on:

- Flutter UI
- HTTP clients
- databases
- vendor SDKs
- external APIs

Infrastructure may implement domain repository interfaces.

Presentation must not directly depend on infrastructure implementations when an abstraction is appropriate.

---

# 11. FEATURE STRUCTURE

Use this structure when a feature has enough complexity to justify it:

```text
features/<feature>/
│
├── presentation/
│   ├── screens/
│   ├── widgets/
│   └── providers/
│
├── application/
│   ├── use_cases/
│   └── providers/
│
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── value_objects/
│
└── infrastructure/
    ├── repositories/
    ├── datasources/
    └── models/
```

Do not mechanically create every folder for trivial features.

Architecture should improve maintainability, not create ceremony.

---

# 12. STATE MANAGEMENT

Use the project's existing state-management solution if one is already established.

If state management needs to be introduced, prefer **Riverpod**.

Use state management for:

- screen state
- filters
- selections
- forms
- modal state
- local/mock data
- loading states
- error states
- UI state

Do not introduce complex state-management architecture without a real need.

---

# 13. REPOSITORY PATTERN

When a feature requires data abstraction, define the repository contract in the domain layer.

Example:

```dart
abstract interface class QuestRepository {
  Future<List<Quest>> getQuests();
  Future<void> completeQuest(String id);
}
```

Use mock/local implementations for the current migration.

Future remote implementations may later be added without changing presentation code.

Do NOT implement remote repositories during the UI migration.

---

# 14. DOMAIN MODELS

Create framework-independent domain entities when they provide value to the UI architecture.

Examples may include:

- Quest
- Habit
- Character
- Boss
- Dungeon
- GateSession
- Note
- Reminder
- Notification
- CalendarEvent
- AnalyticsReport

Only implement models that are actually needed.

Do not implement the entire SRS domain model simply because it exists in the document.

Do not implement complex business rules unless the existing React UI requires them.

---

# 15. MOCK DATA

Backend functionality is currently out of scope.

Use realistic local/mock data.

Prefer migrating existing React mock data where possible.

Do not replace existing realistic UI content with generic placeholders such as:

```text
Lorem ipsum
Task 1
Task 2
Test User
Example
```

unless those values already exist in the React application.

---

# 16. DESIGN SYSTEM

Centralize repeated visual values.

Prefer dedicated classes/tokens for:

```text
AppColors
AppTypography
AppSpacing
AppRadii
AppShadows
AppAnimations
```

Do not scatter repeated colors, dimensions, radii, and animation durations throughout the codebase.

However, do not force every value into a global token if it is genuinely component-specific.

---

# 17. TYPOGRAPHY

Inspect the React application for its actual fonts.

If custom fonts exist:

- migrate them
- register them in Flutter
- preserve weights
- preserve sizes
- preserve letter spacing
- preserve line height

Do not casually replace custom typography with Material defaults.

---

# 18. ICONS AND ASSETS

Inspect the React application's actual icon and asset implementation.

Prefer:

- migrating existing SVGs
- migrating existing image assets
- using equivalent icon libraries
- preserving custom artwork

Do not replace custom icons with Material icons merely for convenience.

Preserve:

- aspect ratio
- transparency
- cropping
- scaling
- placement
- visual effects

---

# 19. COMPONENT REUSE

If a visual component appears multiple times, create a reusable Flutter widget.

Avoid unnecessary duplication.

For example:

```text
QuestCard
SystemAlert
StatusBar
RankBadge
ProgressBar
GlassPanel
BottomNavigation
```

should generally be shared widgets if they represent the same UI component.

Do not create separate copies of the same component for every screen unless their behavior or appearance genuinely differs.

---

# 20. CUSTOM UI OVER GENERIC FLUTTER UI

Do not automatically use:

```dart
Card
ElevatedButton
AlertDialog
BottomNavigationBar
AppBar
```

when the React implementation uses custom UI.

Generic Flutter widgets may be used internally, but the resulting rendered UI must match the React design.

Build custom widgets when necessary.

---

# 21. GLASSMORPHISM AND EFFECTS

The ARISE design uses a dark futuristic System/HUD visual language.

Where the React UI contains:

- glass panels
- backdrop blur
- cyan glow
- gradients
- holographic effects
- glowing borders
- translucent surfaces
- animated progress
- neon accents

reproduce the actual implementation rather than approximating it with flat containers.

Use appropriate Flutter tools such as:

- `BackdropFilter`
- `ImageFilter`
- gradients
- `ShaderMask`
- `CustomPainter`
- clipping
- opacity
- compositing
- animation controllers

Only use these where the React UI requires them.

---

# 22. ANIMATIONS

Animations are part of the UI and must not be removed merely because they are non-essential.

Inspect the React implementation for:

- transitions
- entrance animations
- exit animations
- hover/press states
- progress animations
- modal transitions
- glow animations
- particle effects
- pulse effects
- screen transitions

Reproduce them in Flutter using appropriate animation APIs.

Do not invent additional animations that are not present in the React UI unless necessary to reproduce an equivalent platform interaction.

---

# 23. NAVIGATION

Reproduce the existing React navigation structure.

Inspect:

- routes
- tabs
- nested navigation
- modals
- bottom sheets
- back behavior
- transitions

The React application determines actual navigation behavior.

The SRS can provide conceptual context, but must not override the existing implementation.

---

# 24. RESPONSIVE DESIGN

The existing ARISE design uses a mobile-first visual baseline.

Preserve the React application's proportions and responsive behavior.

Use:

- `MediaQuery`
- `LayoutBuilder`
- `Expanded`
- `Flexible`
- `AspectRatio`
- constraints

Avoid unnecessarily hardcoding absolute screen coordinates.

Do not allow responsiveness to substantially alter the visual identity.

---

# 25. UI STATES

Inspect and reproduce all meaningful states present in React:

- loading
- populated
- empty
- error
- selected
- disabled
- active
- completed
- overdue
- locked
- expanded
- collapsed
- modal
- confirmation

Do not implement only the default state.

---

# 26. FRONTEND EVENT BOUNDARIES

The SRS describes event-driven communication between modules.

For the current task, only implement lightweight frontend event abstractions when they are genuinely useful.

Examples:

```text
QuestCompletedEvent
LevelUpEvent
GateCompletedEvent
```

Do not implement backend event sourcing.

Do not build a production event bus merely to satisfy the architectural description.

---

# 27. OFFLINE-FIRST COMPATIBILITY

Structure repositories and application services so future local-first and remote synchronization can be added.

However, do NOT implement:

- server synchronization
- conflict resolution
- sync queues
- retry systems
- server reconciliation
- remote persistence

unless such functionality already exists in the project.

The current task is UI migration.

---

# 28. SRS USAGE RULE

The SRS is a reference document, not an implementation checklist.

Do not interpret every SRS requirement as something that must be implemented during this migration.

If the SRS describes backend functionality, integrations, game logic, AI, synchronization, or infrastructure:

**do not implement it unless the existing React frontend already contains corresponding UI behavior that needs to be represented with local/mock Flutter state.**

---

# 29. FIGMA MAKE PROMPT USAGE RULE

The original Figma Make prompt describes the intended ARISE visual identity.

Use it to understand:

- design language
- colors
- typography
- System/HUD aesthetic
- component concepts
- screen intent
- animation intent

But:

**React implementation always wins over the Figma prompt when they differ.**

---

# 30. VALIDATION RULE

After implementing each major screen:

1. Run the Flutter application.
2. Render the screen.
3. Compare it against the React implementation.
4. Identify visual discrepancies.
5. Fix them.
6. Repeat.

Check:

- dimensions
- spacing
- alignment
- typography
- colors
- gradients
- opacity
- borders
- radii
- shadows
- glow
- blur
- icons
- assets
- animation
- interaction
- responsive behavior

Do not declare completion based only on successful compilation.

---

# 31. CODE QUALITY

Flutter code must be:

- idiomatic Dart
- null-safe
- readable
- modular
- maintainable
- reusable
- appropriately abstracted
- testable where meaningful

Avoid:

- giant screen files
- duplicated components
- business logic inside widgets
- magic numbers
- repeated design constants
- unused abstractions
- dead code
- unnecessary packages
- unnecessary architecture
- speculative services
- placeholder modules

---

# 32. DO NOT OVER-ENGINEER

The architecture exists to make the application maintainable.

It does NOT mean every UI element requires:

- entity
- repository
- use case
- service
- event
- datasource

Use the simplest architecture that maintains proper boundaries.

A simple static UI component should remain simple.

A complex feature should receive the appropriate architectural separation.

---

# 33. FILE NAMING

Use idiomatic Dart naming:

```text
snake_case.dart
```

Examples:

```text
quest_card.dart
home_screen.dart
quest_repository.dart
mock_quest_repository.dart
app_theme.dart
app_colors.dart
```

Classes use:

```text
PascalCase
```

Variables and methods use:

```text
camelCase
```

---

# 34. IMPORTANT DECISION RULE

When uncertain, evaluate the problem in this order:

```text
1. What does the React application actually do?
2. What does the React application actually render?
3. How is the UI implemented?
4. What reusable component does this correspond to?
5. What is the cleanest Flutter equivalent?
6. Does the architecture remain maintainable?
```

Do not start with:

```text
"What does Flutter usually do?"
```

or:

```text
"What does the SRS theoretically require?"
```

---

# 35. IMPLEMENTATION PRIORITY

Prioritize in this order:

```text
1. Visual fidelity
2. Functional UI behavior
3. Component reuse
4. Clean architecture
5. Maintainability
6. Future backend compatibility
```

Do not sacrifice visual fidelity for unnecessary architectural purity.

Do not sacrifice maintainability for a quick visual hack when both can reasonably be achieved.

---

# 36. FINAL RULE

The final Flutter application should give the user the impression that:

> **The existing React application was rebuilt natively in Flutter.**

It should NOT feel like:

> "A similar Flutter application was designed from the SRS."

The React application is the visual contract.

The Figma Make prompt explains the design intent.

The SRS explains the product and architecture.

Keep those responsibilities separate.
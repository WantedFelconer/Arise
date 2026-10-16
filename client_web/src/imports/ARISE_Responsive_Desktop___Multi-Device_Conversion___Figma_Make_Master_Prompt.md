# ARISE — RESPONSIVE DESKTOP + MULTI-DEVICE UI CONVERSION
## Master Figma Make Implementation Prompt

You are working on the existing **ARISE** application.

ARISE is currently designed primarily as a **mobile-first iOS experience**, centered around a 390×844 viewport. Your task is to evolve the existing UI into a **fully responsive, production-quality multi-device interface** that supports:

- Mobile phones
- Small phones
- Large phones
- Tablets
- Small laptops
- Standard desktop monitors
- Large desktop / ultrawide monitors
- Different aspect ratios
- Different viewport heights
- Browser zoom
- Touch and mouse/trackpad interaction

The objective is **NOT** to simply stretch the existing mobile UI across a larger screen.

The objective is to create a **responsive ARISE design system and responsive layout architecture** where the interface intelligently transforms between mobile, tablet, and desktop compositions while remaining unmistakably ARISE.

---

# 1. PRIMARY OBJECTIVE

Convert the current mobile-only ARISE interface into a responsive application with:

> **One product, one visual language, multiple intentional layouts.**

The same underlying product, state, navigation, content, terminology, interactions, and visual identity must remain intact.

However, the layout should adapt significantly depending on available viewport space.

### Mobile

Prioritize:

- thumb accessibility
- vertical scrolling
- compact information density
- bottom navigation
- stacked cards
- full-screen sheets
- mobile-safe areas
- touch-friendly controls

### Tablet

Prioritize:

- two-column compositions where useful
- larger cards
- expanded content areas
- more simultaneous information
- hybrid navigation patterns
- touch-friendly controls

### Desktop

Prioritize:

- persistent navigation
- multi-column layouts
- information density
- simultaneous visibility of related information
- larger visual focal areas
- side panels
- dashboards
- desktop-grade dialogs
- mouse/keyboard interaction
- efficient use of horizontal space

### Ultrawide

Do NOT simply stretch content indefinitely.

Use:

- max-width content containers
- balanced whitespace
- multi-column expansion
- optional secondary panels
- centered compositions
- controlled reading widths
- visual hierarchy

The UI must never look like a 390px mobile app sitting in the middle of a giant monitor.

---

# 2. CRITICAL DESIGN PRINCIPLE

## DO NOT DESIGN DESKTOP AS "MOBILE BUT WIDER"

This is the most important requirement.

For example:

### WRONG

390px mobile card:

[ Quest Card ]

becomes:

------------------------------------------------------------
|                      Quest Card                           |
------------------------------------------------------------

on desktop.

That is merely stretching.

### RIGHT

Desktop should reconsider the composition:

------------------------------------------------------------
| Navigation | Main Quest Workspace       | Quest Details |
|            |                            |               |
|            | Quest categories           | Selected Quest|
|            | Quest cards                | Rewards       |
|            |                            | Deadline      |
------------------------------------------------------------

The desktop interface should use the additional space to reveal relationships that are hidden or compressed on mobile.

---

# 3. RESPONSIVE PHILOSOPHY

Create three major layout modes.

## MODE A — MOBILE

Approximate range:

`0–767px`

Do not assume every mobile device has the same aspect ratio.

Examples:

- 320×568
- 360×800
- 375×812
- 390×844
- 393×852
- 412×915
- landscape mobile

Mobile remains optimized for touch.

Use:

- bottom navigation
- compact top HUD
- vertically stacked content
- horizontal carousels where appropriate
- bottom sheets
- full-screen overlays
- large touch targets
- safe-area-aware spacing

---

# 4. TABLET MODE

Approximate range:

`768–1199px`

This is NOT merely enlarged mobile.

Introduce adaptive layouts such as:

- two-column dashboard
- wider quest cards
- side-by-side statistics
- expanded System Log
- split detail views
- larger modal/dialog compositions
- optional side navigation depending on available width

Examples:

### Tablet Home

------------------------------------------------
| Top System HUD                               |
------------------------------------------------
|                                              |
| Main Progress      | Today's Quests          |
| / Hunter Card      |                        |
|                    |                        |
------------------------------------------------
| Gate / Mana / Quick Actions / System Log    |
------------------------------------------------

The exact composition should adapt naturally rather than follow a rigid grid.

---

# 5. DESKTOP MODE

Approximate range:

`1200px+`

Desktop should feel like the **full System command interface**.

Introduce a persistent desktop shell.

Suggested conceptual structure:

```text
┌──────────────────────────────────────────────────────────────┐
│                         SYSTEM HUD                           │
├──────────────┬────────────────────────────────┬──────────────┤
│              │                                │              │
│  SYSTEM      │                                │   CONTEXT    │
│  NAVIGATION  │       PRIMARY WORKSPACE        │   PANEL      │
│              │                                │              │
│  Home        │                                │  Details     │
│  Quests      │                                │  Rewards     │
│  Status      │                                │  Activity    │
│  Journal     │                                │  AI/System   │
│  Roadmap     │                                │              │
│              │                                │              │
├──────────────┴────────────────────────────────┴──────────────┤
│                         OPTIONAL SYSTEM LOG                  │
└──────────────────────────────────────────────────────────────┘
```

This is a conceptual direction, NOT a requirement to reproduce this exact wireframe.

Use your judgment to create the best responsive composition.

---

# 6. RESPONSIVE BREAKPOINTS

Do not hard-code only one breakpoint.

Create a coherent responsive system.

Suggested breakpoints:

```text
xs: < 360px
sm: 360–639px
md: 640–767px
lg: 768–1023px
xl: 1024–1279px
2xl: 1280–1535px
3xl: 1536px+
```

However:

**Do not blindly use these values everywhere.**

Layout changes should happen based on actual content requirements.

If a component needs 900px to remain readable, let it transition based on that requirement.

Favor:

- CSS Grid
- Flexbox
- `minmax()`
- `clamp()`
- fluid spacing
- fluid typography
- max-width containers
- container-query-like thinking where appropriate

Avoid arbitrary pixel positioning.

---

# 7. RESPONSIVE WIDTH STRATEGY

Never allow major content to stretch infinitely.

Use something conceptually similar to:

```css
width: min(100% - 2 * var(--page-padding), var(--content-max-width));
margin-inline: auto;
```

Large screens should have intentional maximum widths.

Example conceptual limits:

```text
Desktop application shell:
1200–1800px depending on composition

Reading-heavy content:
~700–900px

Dashboard workspace:
~1200–1600px

Dialogs:
~480–900px depending on purpose

Side panels:
~280–420px
```

These are guidelines, not rigid numbers.

The final values should be determined by visual balance.

---

# 8. DESKTOP APPLICATION SHELL

Create a responsive application shell.

## Mobile shell

Use:

- top System HUD
- scrollable content
- bottom navigation
- floating actions where necessary

## Tablet shell

Consider:

- compact top HUD
- side navigation OR bottom navigation depending on width
- expanded content columns

## Desktop shell

Use a persistent left-side System navigation.

Suggested structure:

```text
┌──────────────────────┐
│ ARISE                │
│ SYSTEM ONLINE        │
├──────────────────────┤
│                      │
│ ◈ HOME               │
│ ◈ QUESTS             │
│ ◈ STATUS             │
│ ◈ JOURNAL            │
│ ◈ ROADMAP            │
│                      │
├──────────────────────┤
│ SYSTEM               │
│ AI COACH             │
│ GUILD                │
│ ARMORY               │
│                      │
├──────────────────────┤
│ HUNTER PROFILE       │
│ LEVEL / RANK         │
└──────────────────────┘
```

Again, treat this as structural guidance rather than a mandatory visual implementation.

The sidebar should feel like part of the System rather than a conventional SaaS sidebar.

---

# 9. DESKTOP TOP HUD

The existing mobile HUD contains important information:

- HP
- MP
- streak
- level
- mana
- uplink

The old implementation had problems with overflow and notch safety, which were corrected by separating the HUD into two rows. Do not regress those safety principles.

On desktop, the HUD can evolve.

Do not simply retain a mobile two-row HUD at the top of a huge screen.

Instead, consider:

### Desktop

```text
┌──────────────────────────────────────────────────────────────┐
│ SYSTEM ONLINE     HP ████████  MP ██████   LV14 B   ◉ MANA │
└──────────────────────────────────────────────────────────────┘
```

Potentially distribute information across:

- global header
- sidebar profile
- compact top status area

Avoid duplicating the same information unnecessarily.

---

# 10. NAVIGATION TRANSFORMATION

Current primary navigation:

1. Home
2. Quests
3. Status
4. Journal
5. Roadmap

On mobile:

```text
┌────────────────────────────────────┐
│ Home  Quests  Status  Journal  Map│
└────────────────────────────────────┘
```

On desktop:

Move this into persistent navigation.

The user should not have to scroll to the bottom of the page to navigate.

The active section must be extremely clear.

Use:

- active state
- hover state
- focus state
- disabled state
- subtle System animation
- icon + label

Do not rely solely on icons.

---

# 11. DESKTOP HOME REDESIGN

The current Home contains:

- System greeting
- Hunter identity
- level/EXP
- today's quests
- daily reset
- Gate Access
- Mana Core
- quick actions
- System Log

These should become a true desktop command center.

Suggested information architecture:

```text
┌─────────────────────────────────────────────────────────────┐
│ SYSTEM ONLINE                                               │
│ GOOD EVENING, HUNTER                                        │
├──────────────────────────────────┬──────────────────────────┤
│                                  │                          │
│ HUNTER PROGRESSION               │ TODAY'S QUESTS           │
│                                  │                          │
│ LEVEL 14                         │ Quest 01                 │
│ B-RANK                           │ Quest 02                 │
│ EXP ███████████░░                │ Quest 03                 │
│                                  │ Quest 04                 │
├──────────────────────────────────┼──────────────────────────┤
│                                  │                          │
│ GATE ACCESS                      │ MANA CORE                │
│                                  │                          │
│ ENTER FOCUS                      │ Energy                   │
│                                  │ Recovery                 │
├──────────────────────────────────┴──────────────────────────┤
│ QUICK ACTIONS                                               │
├─────────────────────────────────────────────────────────────┤
│ SYSTEM LOG                                                  │
└─────────────────────────────────────────────────────────────┘
```

Do not blindly implement this exact layout.

Instead, use the available viewport to establish a compelling visual hierarchy.

The **Gate Access** experience should remain a major focal point.

---

# 12. QUESTS DESKTOP EXPERIENCE

The current Quest List has:

- Daily
- Main
- Side
- All
- quest cards
- rank
- EXP
- gold
- deadline
- descriptions
- completion state
- Add Quest FAB
- Add Quest bottom sheet

The desktop version should feel substantially more powerful.

Consider a three-region architecture:

```text
┌─────────────┬───────────────────────────────┬──────────────┐
│ QUEST TYPES │ QUEST LIST                    │ QUEST DETAIL │
│             │                               │              │
│ Daily       │ E  Quest                      │ Selected     │
│ Main        │ A  Quest                      │ Quest        │
│ Side        │ B  Quest                      │              │
│ All         │ S  Quest                      │ Rewards      │
│             │                               │ Deadline     │
│ Filters     │                               │ Description  │
│             │                               │ Actions      │
└─────────────┴───────────────────────────────┴──────────────┘
```

On smaller screens, collapse back to the existing mobile interaction model.

### Important

Do not force the three-column layout on screens where it becomes cramped.

Responsive behavior should be:

```text
Mobile:
List → tap quest → detail

Tablet:
List + optional detail

Desktop:
List + persistent detail

Very wide desktop:
Category/filter + list + detail
```

This is the kind of adaptive transformation required throughout the app.

---

# 13. ADD QUEST

Mobile currently uses:

- FAB
- bottom sheet
- backdrop
- drag handle
- scrollable form
- live preview
- sticky CTA

Preserve this interaction on mobile.

On desktop, transform it into a centered System dialog or right-side creation panel.

Example:

```text
┌────────────────────────────────────────────┐
│ REGISTER NEW QUEST                    ×     │
├───────────────────────────┬────────────────┤
│ FORM                      │ LIVE PREVIEW   │
│                           │                │
│ TITLE                     │ [Quest Card]   │
│ DESCRIPTION               │                │
│ TYPE                      │ Rank B         │
│ RANK                      │ +200 EXP       │
│ EXP                       │ +100 GOLD      │
│ GOLD                      │                │
│ DEADLINE                  │                │
│                           │                │
│ [ REGISTER QUEST ]        │                │
└───────────────────────────┴────────────────┘
```

The preview should update live.

The CTA must remain disabled until title is non-empty, matching the existing interaction behavior.

---

# 14. STATUS DESKTOP

Current Status includes:

- identity
- title
- rank
- level
- HP
- MP
- EXP
- stats
- allocatable points
- buffs
- achievements

Desktop should expose the relationships between these systems.

Possible layout:

```text
┌──────────────────────────┬──────────────────────────────────┐
│ HUNTER PROFILE           │ CORE ATTRIBUTES                  │
│                          │                                  │
│ HUNTER                   │ STR       AGI       VIT          │
│ THE AWAKENED             │ 53        38        30           │
│ B-RANK                   │                                  │
│ LEVEL 14                 │ INT       PER                    │
│                          │ 30        32                     │
├──────────────────────────┼──────────────────────────────────┤
│ HP / MP / EXP            │ TITLES / BUFFS                   │
├──────────────────────────┴──────────────────────────────────┤
│ ACHIEVEMENTS                                                │
└─────────────────────────────────────────────────────────────┘
```

Do not sacrifice the System fantasy for a conventional analytics dashboard.

---

# 15. JOURNAL DESKTOP

Current Journal contains:

- Log
- Analytics
- time filters
- daily activity
- EXP
- focus hours
- quest activity
- XP progression
- category breakdown
- mana/energy trend

Desktop is an excellent place to increase information density.

Use:

- charts
- timeline
- activity feed
- KPI cards
- category breakdown
- trend visualization

Potential composition:

```text
┌──────────────────────────────────────────────────────┐
│ JOURNAL                                              │
│ Today / Week / Month                                 │
├─────────────┬─────────────┬─────────────┬────────────┤
│ EXP         │ FOCUS       │ QUESTS      │ STREAK     │
├──────────────────────────────────────────────────────┤
│ XP PROGRESSION                 │ CATEGORY BREAKDOWN  │
│                                │                     │
├────────────────────────────────┼─────────────────────┤
│ ACTIVITY TIMELINE              │ MANA TREND          │
└────────────────────────────────┴─────────────────────┘
```

Ensure charts remain readable and useful at every width.

---

# 16. ROADMAP DESKTOP

The Roadmap is inherently spatial.

Use desktop width to create a more immersive progression map.

Mobile:

```text
│
●
│
●
│
●
│
```

Desktop can become:

```text
        ●────────●────────●
        │        │        │
        │        │        │
      Goal     Goal     Goal
        │
        ●────────●────────●
```

Potentially use:

- horizontal progression
- branching paths
- milestone cards
- side information panel
- zoom-like visual hierarchy

But ensure usability.

Do not create a visually impressive roadmap that becomes impossible to understand.

---

# 17. FOCUS MODE

Focus Mode is a special immersive flow.

Do NOT turn it into a generic desktop modal.

Desktop should potentially use the entire viewport.

Possible structure:

```text
┌──────────────────────────────────────────────────────────┐
│                                                          │
│                     GATE ACTIVE                          │
│                                                          │
│                         ◯                                │
│                      24:37                               │
│                                                          │
│                   FOCUS SESSION                          │
│                                                          │
│                    [ PAUSE ]                             │
│                                                          │
└──────────────────────────────────────────────────────────┘
```

Use the additional desktop space for:

- atmospheric effects
- portal/ring
- System diagnostics
- quest objective
- subtle background motion

The **Gate Collapse** failure moment should remain dramatic where appropriate.

---

# 18. AI COACH DESKTOP

AI Coach is especially suited to desktop.

Mobile:

- chat interface
- full screen
- suggested actions

Desktop:

Use a three-region structure where appropriate:

```text
┌───────────────┬────────────────────────────┬───────────────┐
│ CONTEXT       │ AI COACH                   │ ACTIONS       │
│               │                            │               │
│ Current Stats │ Conversation              │ Deploy Quests │
│ Active Goals  │                            │ Plan Week     │
│ Quests        │                            │ Analyze Stats │
│               │                            │               │
└───────────────┴────────────────────────────┴───────────────┘
```

The AI Coach should feel like an actual System intelligence console.

Preserve:

- idle
- thinking
- streaming
- plan proposed
- accepted

states.

---

# 19. BOSS DETAIL DESKTOP

Boss Detail should benefit strongly from desktop width.

Use:

```text
┌──────────────────────────────┬─────────────────────────────┐
│ BOSS                         │ OBJECTIVES                   │
│                              │                             │
│ SHIP THE APP                 │ ○ Feature X                 │
│ A-RANK                       │ ○ Feature Y                 │
│                              │ ○ QA                         │
│ ███████████░░░               │                             │
│                              ├─────────────────────────────┤
│                              │ ATTACK LOG                  │
│                              │                             │
├──────────────────────────────┴─────────────────────────────┤
│ REWARDS                       [ ENTER GATE ]                │
└────────────────────────────────────────────────────────────┘
```

Maintain the fantasy of fighting a project rather than turning it into a normal project-management screen.

---

# 20. ARMORY

Desktop can use a grid.

Mobile:

```text
2-column cards
```

Desktop:

```text
3–5 columns depending on width
```

Use:

- item cards
- owned state
- price
- category
- rarity
- preview
- current gold

Keep the fantasy and reward psychology visually prominent.

---

# 21. GUILD

Desktop should take advantage of the larger workspace.

Possible layout:

```text
┌─────────────┬─────────────────────────────┬──────────────┐
│ BOARD       │ PARTY / RAID                │ MEMBERS      │
│             │                             │              │
│ Posts       │ Active Objective            │ Online       │
│ Objectives  │ Progress                    │ Rank         │
│             │                             │              │
└─────────────┴─────────────────────────────┴──────────────┘
```

Mobile should remain tabbed/stacked.

---

# 22. SETTINGS

Settings should transform from a long mobile list into a desktop settings workspace.

Possible:

```text
┌──────────────────┬───────────────────────────────────────┐
│ SETTINGS         │ ACCOUNT                               │
│                  │                                       │
│ Account          │                                       │
│ Notifications    │                                       │
│ Penalty          │ Current configuration                 │
│ Integrations     │                                       │
│ Themes           │                                       │
└──────────────────┴───────────────────────────────────────┘
```

Use persistent category navigation on desktop.

---

# 23. OVERLAYS AND DIALOGS

The existing application contains:

- Penalty
- Level Up
- Armory
- Mana Core
- Guild
- Calendar Sync
- Settings
- AI Coach
- Boss Detail
- Notifications

Do not allow these to become awkward mobile-sized windows centered on desktop.

Every overlay must have responsive behavior.

### Mobile

Usually:

- full-screen
- bottom sheet
- immersive overlay

### Tablet

Usually:

- large modal
- centered panel
- split layout

### Desktop

Usually:

- centered dialog
- right-side drawer
- full-screen workspace
- immersive full-screen state

depending on the flow.

---

# 24. PENALTY

Penalty is a high-impact System event.

Desktop should use the full viewport when appropriate.

Maintain:

- danger atmosphere
- red treatment
- consequences
- missed quest
- acknowledgement

The current demo penalty concerns **10KM RUN**.

Do not make the desktop version feel like an ordinary alert dialog.

---

# 25. LEVEL UP

Level Up should remain an immersive celebratory moment.

Desktop can use:

- larger central composition
- radial effects
- stat reveal
- reward cards
- System messaging
- controlled particle/light effects

But avoid excessive visual noise.

The user should immediately understand:

1. old level
2. new level
3. available stat points
4. unlocked rewards
5. Continue

---

# 26. CALENDAR SYNC

Desktop can use a split layout:

```text
┌──────────────────────┬────────────────────────────────┐
│ CALENDAR SOURCES     │ IMPORT PREVIEW                 │
│                      │                                │
│ Google Calendar      │ Event 01                      │
│ Connected             │ Event 02                      │
│                      │ Event 03                      │
│ Discord              │                                │
│                      │ [ SYNC ]                       │
└──────────────────────┴────────────────────────────────┘
```

Mobile should collapse this into a vertical flow.

---

# 27. NOTIFICATIONS

Desktop:

Use a settings-style table/list.

Mobile:

Use stacked notification cards.

Preserve:

- category
- toggle
- schedule
- description
- active/inactive state

---

# 28. RESPONSIVE COMPONENT ARCHITECTURE

Do NOT duplicate entire components for mobile and desktop unless there is a genuine interaction difference.

Prefer:

```tsx
<ResponsiveShell>
  <Navigation />
  <MainWorkspace />
</ResponsiveShell>
```

and responsive CSS/layout behavior.

Use shared components for:

- QuestCard
- RankBadge
- ProgressBar
- SystemLog
- HUD
- StatCard
- RewardChip
- Modal
- Navigation
- SectionHeader
- etc.

The existing reusable System UI components should be reused/refactored where appropriate rather than duplicated screen by screen.

---

# 29. AVOID THIS ANTI-PATTERN

Do NOT create:

```tsx
{isDesktop ? <EntireDesktopApp /> : <EntireMobileApp />}
```

for every screen.

That will create two separate products that drift apart.

Instead, prefer:

```tsx
<div className="grid ...">
```

with responsive layout rules.

Use conditional rendering only when:

- interaction patterns genuinely differ
- desktop needs a persistent panel that mobile should not render
- mobile uses a bottom sheet while desktop uses a dialog
- desktop navigation and mobile navigation are fundamentally different

Even then, reuse the same underlying data and components wherever possible.

---

# 30. CONTAINER QUERIES / COMPONENT RESPONSIVENESS

Where useful, make components respond to their available container width rather than only the viewport width.

For example:

A Quest Card should adapt whether it is inside:

- a 350px mobile column
- a 500px tablet column
- an 800px desktop workspace

Do not assume viewport width equals component width.

This will make the system much more resilient.

---

# 31. ASPECT RATIO SUPPORT

The application must work correctly on:

### Portrait

- 9:16
- 19.5:9
- 20:9
- 21:9

### Landscape

- 16:9
- 16:10
- 3:2
- 4:3
- ultrawide

Never use viewport height as though it is fixed.

Avoid:

```css
height: 844px;
```

Avoid:

```css
top: 76px;
bottom: 84px;
```

unless those values are part of a responsive calculation.

Prefer:

- `min-height`
- `100dvh`
- `100svh`
- safe-area variables
- flex layouts
- sticky positioning
- grid layouts

---

# 32. MOBILE SAFE AREAS

Preserve iOS-safe behavior.

Use:

```css
env(safe-area-inset-top)
env(safe-area-inset-bottom)
env(safe-area-inset-left)
env(safe-area-inset-right)
```

where appropriate.

The interface must never:

- hide under a notch
- overlap the Dynamic Island
- collide with the home indicator
- place buttons beneath unsafe areas

The old implementation already had a history of HUD/notch overflow, so this must be treated as a regression-critical area.

---

# 33. TOUCH TARGETS

Interactive elements should remain comfortably tappable.

Target approximately:

- 44px minimum interactive area on touch devices
- larger where appropriate for important actions

Do not shrink desktop controls so aggressively that they become difficult to use.

---

# 34. MOUSE + KEYBOARD SUPPORT

Desktop must support:

### Hover

Provide meaningful hover states for:

- navigation
- cards
- buttons
- quests
- rewards
- interactive stats

### Focus

Provide clear keyboard focus states.

Never remove outlines without replacing them with a visible focus treatment.

### Keyboard

Where appropriate:

- Enter activates buttons
- Escape closes dialogs
- Tab navigates logically
- arrow keys may navigate tabs/lists when appropriate

Do not over-engineer keyboard shortcuts unless they naturally fit ARISE.

---

# 35. SCROLLING ARCHITECTURE

Avoid nested scrolling whenever possible.

Do not create:

```text
Page scroll
  └── card scroll
      └── panel scroll
          └── content scroll
```

This becomes terrible on touch devices.

Prefer one primary scroll container per workspace.

Exceptions:

- chat transcript
- specialized list
- table
- modal content

Even then, make scrolling intentional.

---

# 36. FIXED ELEMENTS

Any fixed element must account for responsive layout.

Examples:

- desktop sidebar
- mobile bottom navigation
- top HUD
- floating action buttons
- dialogs
- drawers

Never allow:

```text
fixed element
+
scroll content
=
overlap
```

Reserve actual layout space for fixed UI where necessary.

---

# 37. MODAL WIDTHS

Do not use one fixed modal width.

Use fluid constraints such as:

```text
width: min(
  calc(100vw - 32px),
  desired-max-width
)
```

Different dialogs should have different maximum widths based on content.

Examples:

- confirmation: compact
- Add Quest: medium/large
- AI Coach: large
- analytics: large
- immersive events: full viewport

---

# 38. TYPOGRAPHY

Typography must scale responsively.

Do not simply multiply every font size for desktop.

Use intentional hierarchy.

For example:

```css
font-size: clamp(min, fluid, max);
```

Large headings may scale.

Body text should remain readable rather than becoming enormous.

Numbers, timers, EXP, HP, MP and diagnostics should preserve their monospace/System identity.

Existing ARISE typography includes:

- Orbitron for display/System headings
- Rajdhani for body
- Share Tech Mono for numbers, timers and diagnostics

Preserve this typography architecture unless there is a compelling implementation reason to modify it.

---

# 39. VISUAL IDENTITY

The desktop expansion must remain recognizably ARISE.

Do not turn it into:

- generic SaaS dashboard
- generic admin panel
- generic cyberpunk UI
- generic gaming dashboard
- generic productivity app

The System should feel like an operating layer over reality.

The legacy visual identity includes dark-fantasy sci-fi, glass surfaces, cyan System accents, rank-specific colors, System Logs, ornate System elements, and restrained glow/motion. Treat those as existing product DNA unless the current redesign direction has explicitly superseded them.

---

# 40. VISUAL DENSITY

Desktop should contain MORE useful information than mobile, not simply more empty space.

But do not make it cluttered.

Use:

- hierarchy
- grouping
- whitespace
- dividers
- subtle panels
- progressive disclosure
- contextual sidebars

The user should be able to scan the entire desktop screen and understand:

> "Where am I?"
> "What matters right now?"
> "What should I do next?"

within a few seconds.

---

# 41. ULTRAWIDE BEHAVIOR

At 1920px, 2560px, 3440px and similar widths:

Do NOT:

```text
stretch every card across the entire screen
```

Instead:

```text
┌──────────────┐
│ sidebar      │
└──────────────┘

        ┌──────────────────────────────────────────┐
        │              MAIN SYSTEM                 │
        │                                          │
        │                                          │
        └──────────────────────────────────────────┘
```

Potentially introduce:

- secondary context panel
- larger whitespace
- additional dashboard modules
- centered workspace

The interface should feel premium on a large monitor.

---

# 42. SHORT HEIGHT DESKTOPS

You must also support:

- 1366×768
- 1280×720
- small laptop screens

Do not assume desktop means high vertical space.

On short screens:

- reduce vertical gaps
- collapse secondary information
- make panels scrollable
- preserve primary actions
- avoid clipping
- avoid requiring excessive scrolling for critical actions

The UI must remain functional.

---

# 43. LANDSCAPE TABLETS

Landscape tablets should not automatically become desktop.

For example:

1024×768 should be able to use a tablet-appropriate composition.

Do not create a desktop sidebar + three columns if doing so makes every region cramped.

Responsive design should be based on available space, not device labels.

---

# 44. DARK MODE / SYSTEM FANTASY

ARISE is fundamentally dark.

Do not introduce a light theme merely to make desktop conventional.

Maintain:

- dark atmospheric background
- System panels
- controlled cyan energy
- gold progression
- red danger
- green success

Avoid excessive glow.

The UI should feel premium rather than visually noisy.

---

# 45. MOTION RESPONSIVENESS

Desktop has more space for ambient effects, but do not simply increase animation everywhere.

Maintain a hierarchy:

### Routine interaction

Subtle:

- hover
- shimmer
- glow
- transition

### Important feedback

Moderate:

- pulse
- reveal
- slide
- progress animation

### Major System events

High impact:

- level up
- gate entry
- gate collapse
- penalty
- boss defeat

Respect:

```css
prefers-reduced-motion
```

When reduced motion is enabled:

- remove unnecessary transforms
- reduce particle effects
- preserve state transitions through opacity/color where possible

---

# 46. RESPONSIVE ICONOGRAPHY

Do not use emoji as the final icon system.

The legacy prototype contains emoji placeholders; replace them with a coherent icon system or SVG-based icons.

Icons should:

- scale
- align correctly
- have consistent stroke/weight
- support active/inactive states
- remain readable on mobile and desktop

---

# 47. DATA AND STATE MUST NOT CHANGE

This task is primarily a UI/layout transformation.

Do NOT unnecessarily rewrite:

- application state
- player data
- navigation logic
- existing flows
- demo data
- business logic

Preserve:

- auth
- onboarding
- main navigation
- quest completion
- Focus Mode
- EXP
- level-up
- stat allocation
- overlays
- existing interactions

The current app uses local React state and has `auth`, `onboarding`, and `main` phases. Preserve that architecture unless a refactor is genuinely necessary for responsive behavior.

---

# 48. DO NOT CREATE A PARALLEL APP

This is an implementation-critical instruction.

Do NOT:

- create a new app root
- create a second routing system
- create a separate desktop project
- duplicate all screens into `/desktop`
- replace the current application with static mockups
- disconnect existing interactions
- replace working state with fake state

Modify the existing application.

The repository currently uses:

- React 19
- React DOM 19
- TypeScript
- Vite
- Tailwind CSS v4

with the existing entrypoint and app shell. Preserve the working technical baseline.

---

# 49. CODE QUALITY

While implementing the responsive system:

Create reusable responsive primitives where useful.

Potential examples:

```tsx
ResponsiveShell
DesktopSidebar
MobileBottomNav
ResponsiveContainer
PageHeader
SplitPane
ResponsiveDialog
ResponsiveDrawer
SystemPanel
```

Do not create abstractions merely for the sake of abstraction.

Avoid hundreds of one-off inline styles.

Create coherent tokens for:

- spacing
- radii
- elevation
- borders
- typography
- responsive widths
- breakpoints
- panel backgrounds
- glow intensity

---

# 50. INFORMATION HIERARCHY

Every screen should have:

### Level 1 — Primary objective

What is the user supposed to understand/do?

### Level 2 — Primary information

What supports that objective?

### Level 3 — Secondary information

What can be scanned when needed?

### Level 4 — Metadata

Timers, diagnostic information, minor System details.

Desktop should reveal more Level 2 and Level 3 information.

Mobile should prioritize Level 1 and Level 2.

This is the fundamental responsive transformation.

---

# 51. PRESERVE MOBILE QUALITY

Extremely important:

**Do not damage the existing mobile experience while implementing desktop.**

After the responsive implementation:

Test at minimum:

```text
320 × 568
360 × 800
375 × 812
390 × 844
393 × 852
412 × 915
768 × 1024
820 × 1180
1024 × 768
1280 × 720
1366 × 768
1440 × 900
1536 × 864
1920 × 1080
2560 × 1440
3440 × 1440
```

Also test:

- portrait
- landscape
- browser zoom
- short viewport height
- long viewport height

---

# 52. RESPONSIVE QA CHECKLIST

For every screen verify:

## Layout

- No horizontal overflow
- No clipped content
- No accidental overlap
- No giant empty areas
- No stretched cards
- No broken grid
- No broken alignment

## Navigation

- Correct navigation for viewport
- Active state visible
- Touch targets usable
- Keyboard focus visible
- Sidebar doesn't cover content

## Content

- No text clipping
- No unexpected truncation
- Numbers remain readable
- Buttons remain readable
- Cards preserve hierarchy

## Scrolling

- Correct scroll container
- No trapped scrolling
- No nested-scroll nightmare
- Critical actions remain accessible

## Overlays

- Correct size
- Correct positioning
- Correct backdrop
- Correct dismiss behavior
- Escape works on desktop where appropriate
- Mobile sheets respect safe areas

## Visual

- ARISE identity intact
- System atmosphere intact
- No generic SaaS transformation
- No excessive glow
- No inconsistent spacing
- No random component styles

---

# 53. ACCESSIBILITY

Do not sacrifice accessibility for aesthetics.

Ensure:

- sufficient text contrast
- keyboard navigation
- visible focus
- semantic buttons
- semantic navigation
- appropriate labels
- meaningful aria labels for icon-only controls
- reduced motion support
- touch targets
- readable typography

Decorative System effects should not interfere with usability.

---

# 54. PERFORMANCE

Responsive effects should not cause unnecessary performance problems.

Avoid:

- huge DOM duplication
- rendering both desktop and mobile versions of entire screens unnecessarily
- expensive continuous animations
- excessive blur layers
- giant particle systems
- unnecessary re-renders

Prefer CSS transitions and GPU-friendly transforms where possible.

---

# 55. IMPLEMENTATION STRATEGY

Do not immediately rewrite every screen.

Follow this order:

### Phase 1 — Audit

Inspect:

- `src/App.tsx`
- `src/components/SystemUI.tsx`
- `src/index.css`
- `src/screens/Home.tsx`
- `src/screens/QuestList.tsx`
- remaining screen files

Understand:

- layout
- state
- reusable components
- current mobile behavior
- fixed elements
- overlays
- scroll containers

### Phase 2 — Responsive foundation

Establish:

- breakpoints
- spacing tokens
- container widths
- responsive typography
- safe-area handling
- shell architecture
- mobile navigation
- desktop navigation
- responsive overlay primitives

### Phase 3 — Core screens

Convert:

1. Home
2. Quest List
3. Status
4. Journal
5. Roadmap

### Phase 4 — Secondary screens

Convert:

6. Focus Mode
7. Armory
8. Mana Core
9. Guild
10. Calendar Sync
11. Settings
12. AI Coach
13. Boss Detail
14. Notifications

### Phase 5 — Event states

Verify:

- Penalty
- Level Up
- success states
- empty states
- loading states
- error states
- locked states

### Phase 6 — QA

Test all target viewport sizes.

---

# 56. DESKTOP DESIGN QUALITY BAR

The desktop interface should feel like a **real product**, not a responsive exercise.

Imagine ARISE running on:

- a developer's 14" laptop
- a 16" MacBook
- a 27" monitor
- a 32" 4K monitor
- a 34" ultrawide

The UI should feel intentionally designed for each.

A user should be able to leave ARISE open on a desktop monitor and feel like they are looking at a **personal System command center**.

---

# 57. WHAT NOT TO DO

Do NOT:

- stretch mobile cards across desktop
- simply increase font sizes
- simply add a sidebar
- create a generic dashboard
- create excessive empty whitespace
- make every section a card
- use three columns everywhere
- force desktop layouts onto tablets
- force mobile layouts onto desktop
- introduce horizontal scrolling unless intentional
- use fixed heights unnecessarily
- use absolute positioning for primary layout
- duplicate entire screens unnecessarily
- break existing interactions
- replace existing product terminology
- remove ARISE's System identity
- use lorem ipsum
- introduce generic cyberpunk visuals
- turn ARISE into a normal productivity SaaS dashboard

---

# 58. IMPORTANT RESPONSIVE MENTAL MODEL

Think of the transformation as:

```text
MOBILE
Focus
  ↓
One thing at a time

TABLET
Balance
  ↓
Two related things together

DESKTOP
Context
  ↓
Multiple related systems visible simultaneously
```

For example:

```text
Mobile:
Quest → open → detail

Tablet:
Quest list + selected detail

Desktop:
Quest categories + quest list + selected detail
```

Another example:

```text
Mobile:
Stats → scroll

Tablet:
Stats + achievements

Desktop:
Profile + stats + progression + achievements
```

Another:

```text
Mobile:
Journal → choose tab → inspect

Desktop:
KPIs + chart + timeline + category breakdown
```

This is the core design philosophy.

---

# 59. FINAL VISUAL GOAL

ARISE desktop should feel like:

> **The Hunter has unlocked the full System interface.**

Not:

> "The phone app got stretched onto a monitor."

The desktop experience should communicate increased capability.

Mobile feels like accessing the System through a handheld interface.

Desktop feels like entering the System's command center.

Both must still feel like the same product.

---

# 60. FINAL IMPLEMENTATION REQUIREMENTS

Before considering the work complete:

1. Preserve all existing major flows.
2. Preserve the existing application state architecture unless a responsive refactor requires otherwise.
3. Keep mobile fully functional.
4. Add a genuinely designed tablet experience.
5. Add a genuinely designed desktop experience.
6. Add ultrawide behavior.
7. Add short-height desktop behavior.
8. Handle portrait and landscape.
9. Handle safe areas.
10. Handle mouse and keyboard.
11. Handle touch.
12. Handle hover/focus/active states.
13. Handle reduced motion.
14. Prevent horizontal overflow.
15. Prevent fixed-element overlap.
16. Prevent content clipping.
17. Preserve System terminology.
18. Preserve ARISE's visual identity.
19. Reuse/refactor shared components.
20. Avoid creating a parallel desktop application.
21. Do not start a second development server.
22. Validate the result in the live Figma Make preview.

---

# 61. EXECUTION INSTRUCTION

First inspect the existing implementation and understand how the current mobile layouts work.

Then establish the responsive foundation.

Then progressively convert the screens.

Do not rush into changing every screen simultaneously.

After each major group of changes, verify that the application still builds and functions.

Use the existing implementation as the source of truth for:

- functionality
- state
- navigation
- content
- interactions

Use this prompt as the source of truth for:

- responsive architecture
- desktop transformation
- tablet behavior
- multi-device behavior
- aspect-ratio support
- responsive UX

Do not remove existing functionality merely because it is difficult to make responsive.

If a mobile interaction does not translate directly to desktop, **adapt the interaction rather than deleting it**.

The final result should be a cohesive responsive ARISE application, not separate mobile and desktop mockups.
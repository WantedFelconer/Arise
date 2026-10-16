# ARISE old-chat context handoff plan

## Objective

Create a copy-pasteable context brief for a new Figma Make chat that has its own new redesign prompt. The handoff should explain the existing ARISE product, implementation, screens, navigation, visual system, interaction model, recent fixes, and source-of-truth files without prescribing a new visual direction or competing with the user's new prompt.

The new chat should treat the user's new prompt as the authority for the redesign and use this handoff only as legacy product/implementation context.

## Copy-paste context to provide to the new chat

### Product and platform

- Product: **ARISE**, an iOS gamified life/task manager that reskins real life as a Hunter's omniscient “System,” combining the *Solo Leveling* fantasy with Habitica-like habit and progression loops.
- Current target viewport: fixed **390×844** iPhone frame.
- Product model: users are Hunters; tasks are quests; deep-work sessions are Gates; projects can become Bosses; task completion awards EXP and gold; missed obligations can trigger penalties; personal growth is represented through levels, rank, stats, titles, achievements, streaks, mana/energy, armory rewards, guild/social systems, and a System AI coach.
- This handoff describes the old implementation. Follow the **new redesign prompt** for visual decisions. Preserve useful product structure, content, navigation, and interactions unless the new prompt explicitly changes them.

### Repository and technical baseline

- Stack: React 19, React DOM 19, TypeScript 5.7, Vite 8, Tailwind CSS v4 through `@tailwindcss/vite`.
- Formatting: `oxfmt`.
- The Vite dev server is already managed by Figma Make; do not start another server.
- Entrypoint: `src/main.tsx` imports `src/index.css` and mounts `src/App.tsx`.
- Primary app/router/state shell: `src/App.tsx`.
- Reusable legacy UI primitives: `src/components/SystemUI.tsx`.
- Global tokens, fonts, effects, and animations: `src/index.css`.
- Screens live in `src/screens/`.
- No external component library is installed. `recharts` is available, though most current visualizations are handcrafted.
- The prior implementation was reported to build cleanly with zero TypeScript errors.
- Do not replace the app root, entrypoint, or routing/state shell merely for convenience. Extend or refactor in place.

### Existing app state and navigation

`src/App.tsx` uses local React state rather than a router.

App phases:

1. `auth`
2. `onboarding`
3. `main`

Main bottom tabs:

1. Home
2. Quests
3. Status
4. Journal
5. Roadmap

Overlay/special-flow screens:

- Focus Mode
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

Current player shape:

```ts
type PlayerData = {
  name: string
  title: string
  level: number
  rank: string
  hp: number
  maxHp: number
  mp: number
  maxMp: number
  exp: number
  maxExp: number
  gold: number
  streak: number
  str: number
  agi: number
  vit: number
  int: number
  per: number
  remainingPoints: number
}
```

Default demo player:

- Name: HUNTER
- Title: THE AWAKENED
- Level 14, B-rank
- HP 4200/5000
- MP 391/500
- EXP 7340/10000
- Gold 1240
- 14-day streak
- STR 53, AGI 38, VIT 30, INT 30, PER 32
- 3 unspent stat points

Important existing flows:

- Auth completion advances to onboarding.
- Onboarding records name/title, enters the main app, then shows Level Up after an 800 ms delay.
- Allocating a stat point increments the selected stat and reduces remaining points.
- Successful Focus Mode completion awards 200 EXP.
- Main tabs show a persistent top status HUD and five-tab bottom nav.
- Home quick actions open special screens as overlays.
- The top HUD's mana ring opens Mana Core.
- Settings, AI Coach, Notifications, and a demo penalty trigger are currently exposed as tiny top shortcuts.
- Legacy implementation detail not worth preserving: `App.tsx` currently renders AI Coach, Boss Detail, and Notifications twice in overlapping conditional blocks. A redesign/refactor should keep one overlay instance per screen.

### Legacy visual language

Use this as historical context only if the new prompt does not supersede it.

Core aesthetic:

- Dark-fantasy sci-fi “System” interface.
- Void radial background: `#0B1330` center into `#030712` edge.
- Glassmorphism surfaces based on `rgba(10,26,58,0.82)` with 16 px blur.
- Mana cyan is the primary accent: `#3EE6F5`; darker cyan `#1FA9C2`.
- Primary text `#EAF6FF`; secondary `#7FA0C9`; disabled/muted `#3E5578`.
- Terminal/buff green `#39FF88`.
- HP gradient `#FF5A36 → #C4171C`.
- MP gradient `#2E9BFF → #1560C4`.
- EXP/gold gradient `#FFD24C → #C98A1A`.
- Danger/penalty `#FF2E4D`.
- Quest rank colors: E `#8A94A6`, D `#39D98A`, C `#2E9BFF`, B `#B26EFF`, A `#FF9B3E`, S `#FFD24C`.
- 8-point spacing system with legacy half-step 4 px.
- Legacy radii: control 8, card 16, sheet 28, pill 999.
- Cyan borders, restrained glow, scanlines, circuit-grid texture, and occasional portal/energy effects.
- No magenta-heavy generic cyberpunk city treatment and no Matrix-style digital rain.

Typography:

- Orbitron: display headings, ranks, CTAs, navigation, system labels.
- Rajdhani: body copy and descriptions.
- Share Tech Mono: numbers, timers, diagnostics, logs, metadata.
- All three are currently loaded from Google Fonts in `src/index.css`.

Signature old-system details:

- **v1 Art Nouveau filigree corners**, not generic angular cyberpunk brackets: cyan L-border, inner parallel track, corner diamond, horizontal/vertical flourishes, scroll curls, and border tick marks.
- Ornate panels may add a small triangular top crest.
- HP/MP are compact pill bars.
- Rank badges and quest cards use rank-specific color and glow.
- The “System Log” is a bracketed, color-tagged mono activity feed.
- Boot/auth moments use flicker, terminal diagnostics, decrypt/typewriter text, and scanline reveals.
- Motion vocabulary includes shimmer, cyan/gold/danger pulses, portal spin, scan sweep, fade/slide, shake, level flash, node pulse, mana orb breathing, and uplink pulse.
- Keep animation purposeful and readable; major feedback moments get spectacle, routine controls stay restrained.

### Existing reusable components

`src/components/SystemUI.tsx` currently exports:

- `RankBadge`
- `OrnateCorner`
- `TopCrest`
- `OrnatePanel`
- `GlassCard`
- `ProgressBar` with HP/MP/EXP/cyan/green variants
- `SystemAlert`
- `TerminalReadout`
- `UplinkChip`
- `IntegrationCard`
- `SystemLogLine`
- `NavBar`
- `TopStatusBar`
- `DiamondDivider` / `DiamondSep`
- `BuffTag`
- `SectionHeader`
- `RewardChip`
- `ScanlineSweep`
- `DecryptText`
- `HexLabel`

The existing components are a reference for current behavior and content, not a requirement to preserve poor abstractions. Reuse/refactor them where useful instead of duplicating patterns screen by screen.

### Recent fixes that must not regress accidentally

1. **Top status HUD and notch safety**
   - The old single-row status bar overflowed and hid behind the notch.
   - It was fixed by splitting it into two compact rows with explicit safe top padding.
   - Row 1: compact HP and MP pill bars.
   - Row 2: right-aligned streak, level pill, tappable mana ring, and uplink chip.
   - Main screen content starts below the HUD (currently around 76 px top padding).
   - Any redesign may change the form, but must remain notch-safe with no clipped/overlapping controls.

2. **Filigree decorator rollback**
   - Angular/cyberpunk corner replacements were rejected.
   - The accepted legacy ornament is the v1 Art Nouveau filigree described above.
   - If the new redesign retains legacy ornamentation, use the v1 version rather than angular corner brackets.

3. **Add Quest interaction**
   - Quest List has a `+` floating action button above the bottom nav.
   - It opens a floating bottom sheet with dimmed backdrop, drag handle, header, scrollable form, live quest preview, and sticky registration CTA.
   - Fields: title, description, type (Daily/Main/Side), rank (E–S), EXP, gold, deadline.
   - CTA is disabled until title is nonempty.
   - Backdrop and close button dismiss the sheet.
   - Current prototype closes on create but does not persist the new quest; decide whether the redesign remains visual-only or should wire persistence.

### Screen inventory and legacy content/behavior

#### Auth (`src/screens/Auth.tsx`)

- Login, registration, password recovery, and verifying/loading states.
- System boot diagnostics, ARISE wordmark, authentication protocol panel.
- Email/password inputs, Google network and Apple nexus SSO actions.
- Transitions to onboarding after a brief simulated loading state.

#### Onboarding (`src/screens/Onboarding.tsx`)

- Multi-step Hunter setup.
- Designation: Hunter name and title.
- Class assessment: Body (STR/VIT), Mind (INT/PER), Craft (AGI/INT), Discipline (all stats); multi-selection.
- Chronotype: Early Bird, Night Owl, or Custom Window.
- Difficulty mode selection.
- Review/accept designation and boot sequence.
- Returns name, title, selected classes, chronotype, and difficulty.

#### System Access (`src/screens/SystemAccess.tsx`)

- A separate access/authentication concept not currently wired into `App.tsx`.
- Uplink address, authentication key, Hunter designation, inline validation, Google/Apple continuation, and short boot/sync transition.
- Treat it as an available legacy screen/concept, not an active route unless the new prompt asks for it.

#### Home (`src/screens/Home.tsx`)

- System-online greeting and Hunter identity.
- Level/EXP card.
- Today’s quests as horizontally scrolling rank cards with complete toggles, rewards, deadlines, and penalty-imminent treatment.
- Daily reset countdown.
- Gate Access hero/button that launches Focus Mode.
- Mana Core widget.
- Quick actions: Armory, Guild, Calendar, AI Coach, Boss Raid, Alerts.
- Color-coded System Log.
- Current demo quests include 100 Push-Ups, 100 Sit-Ups, Ship Feature v2.4, Read 30 Minutes, and 10km Run.

#### Quest List (`src/screens/QuestList.tsx`)

- Tabs: Daily, Main, Side, All.
- Daily reset/overdue banner.
- Daily and side quests use compact cards with rank badge, reward, deadline, circular progress/complete control, and expandable description.
- Main quests use larger ornate full-width cards with progress bars, rewards, deadlines, and stronger S-rank treatment.
- Empty state uses an ornate System panel.
- Add Quest FAB and bottom sheet as described above.
- Demo quests include fitness dailies, Ship the App, Run a Marathon, Read 12 Books, Call a Parent, Clean Workspace, and Drink 2L Water.

#### Status (`src/screens/StatusPage.tsx`)

- Tabs: Status and Achievements.
- System-style identity window with Hunter name, job, title/rank, and level.
- HP/MP/EXP progression.
- Allocatable STR, AGI, VIT, INT, PER stats.
- Active title collection and buff tags.
- Achievement rarity tiers and locked/unlocked states.
- Titles/achievements include Wolf Slayer, Iron Will, Shadow Monarch, The Awakened, First Blood, Iron Streak, Dungeon Crawler, Scholar, The Sovereign, Code Breaker, and Streakmaster.

#### Journal (`src/screens/Journal.tsx`)

- Tabs: Log and Analytics.
- Time filters such as Today, This Week, This Month.
- Daily activity entries for cleared quests, EXP, penalties, and focus.
- Analytics include total EXP, focus hours, quest activity, XP progression, category breakdown, and mana/energy trend.
- Category language includes Body, Mind, Craft, Discipline, and Social.

#### Roadmap (`src/screens/Roadmap.tsx`)

- Long-term progression path shown as nodes/milestones and tracks.
- “You are here” marker, active/locked states, rank-aware rewards/progress.
- Goal examples: Ship the App, Marathon, Read 12 Books, Study Daily, Master Craft, Ship a Project.

#### Focus Mode (`src/screens/FocusMode.tsx`)

- Gate-entry deep-work flow with `ready`, `active`, `paused`, `complete`, and `collapsed` states.
- Portal/ring presentation, focus timer, pause/resume, exit confirmation, and session outcome.
- Preserve the dramatic **Gate Collapse** failure beat if the new direction includes this flow.
- Successful exit feeds back into player EXP in `App.tsx`.

#### Penalty (`src/screens/Penalty.tsx`)

- Full-screen danger state for a missed quest.
- Red vignette/glow, warning treatment, penalty quest/stat decay consequences, and acknowledgement action.
- Current demo missed quest: 10KM RUN.

#### Level Up (`src/screens/LevelUp.tsx`)

- Full-screen celebratory overlay showing old/new level, stat point reward, and unlocked rewards/titles/skills.
- Current examples include Iron Will and Shadow Step Lv.1.
- Continue action dismisses the overlay.

#### Armory (`src/screens/Armory.tsx`)

- Spend gold on real-life rewards and cosmetic System themes.
- Tabs: All Items, Real Rewards, Cosmetics.
- Owned/purchasable states and current gold balance.
- Examples: Movie Night, Order Takeout, Rest Day Pass, Gold Border Theme, Void Window Skin, Shadow Lord.

#### Mana Core (`src/screens/ManaCore.tsx`)

- Energy/mana overview with a central ring/core, current capacity, depletion/recovery guidance, and daily rhythm visualization.
- The compact top-HUD ring and Home widget both lead here.

#### Guild (`src/screens/Guild.tsx`)

- Social/accountability space with Board, Party, and Raids views.
- Member/party presence, active raids, and group objectives.
- Existing content includes Guild Deep Work and Party Run — 50km Week.

#### Calendar Sync (`src/screens/CalendarSync.tsx`)

- Calendar integration permission/connection flow.
- Calendar/source rows, import preview, all-day/timed events, accept/connect/sync controls.
- Intended behavior: turn calendar events into scheduled quests.

#### Settings (`src/screens/Settings.tsx`)

- Account details.
- Alarms and notifications.
- Penalty protocol severity: Lenient, Standard, Brutal, Ascetic.
- Integrations: Google Calendar and Discord achievements.
- Interface themes: Void Sovereign, Shadow Throne, Gold Monarch.
- App/version footer.

#### AI Coach (`src/screens/AICoach.tsx`)

- System AI chat with idle, thinking, streaming, plan-proposed, and accepted states.
- Decrypt/typewriter response behavior.
- Suggested action chips: Deploy Quests, Plan My Week, Analyze My Stats, Motivate Me, Adjust Difficulty.
- Can propose a ranked weekly plan with quest cards, including Finalize Core Features, QA & Bug Crushing, Launch & Marketing Push, and Daily Vitality Quest.

#### Boss Detail (`src/screens/BossDetail.tsx`)

- A major project represented as an A-rank boss encounter.
- Current boss: Ship the App.
- Boss health/progress, objectives/attacks, attack log, rewards, and an action that enters Focus Mode.
- Defeated state includes rewards, a Deliverer title unlock, and the next boss tease: Expand Userbase.

#### Notifications (`src/screens/Notifications.tsx`)

- Reminder registry with tabs: Productivity, Wellness, Behavioral, System.
- Toggleable scheduled reminders and category explanations.
- Examples: Daily Quest Check-In, Focus Session, Quest Log Review, Hydration, Mindfulness, Sleep Protocol, Streak Guard, Screen Limit, Uplink Check, Penalty Alert, Level Up Broadcast.

### Content and tone rules

- No lorem ipsum.
- Copy should sound like a cold, omniscient System: concise, commanding, occasionally ominous, but still understandable as a productivity app.
- Use ordinary productivity terminology only where clarity requires it; otherwise translate actions into the world: task → quest, project → boss/raid, focus session → gate, user → Hunter, energy → mana, activity feed → System Log.
- Maintain readability over decoration. Dense fantasy styling must not obscure controls, values, or hierarchy.
- Keep rank, EXP, gold, HP, MP, deadlines, penalties, and completion states immediately scannable.
- Do not use emoji as the final production icon system. The legacy prototype contains emoji placeholders; replace them with a coherent icon set or custom SVGs during redesign unless the new prompt explicitly wants emoji.

### Source-of-truth files worth reading in the new chat

Start with:

1. `src/App.tsx` — state, phases, navigation, overlays, demo player.
2. `src/components/SystemUI.tsx` — reusable legacy components and v1 filigree implementation.
3. `src/index.css` — tokens, font imports, rank colors, progress styles, and animation vocabulary.
4. `src/screens/Home.tsx` — main dashboard/product hierarchy.
5. `src/screens/QuestList.tsx` — quest architecture and Add Quest bottom sheet.
6. Then inspect only the screen files relevant to the new prompt.

Legacy creative brief files are available at:

- `src/imports/ARISE_Figma_Master_Prompt_v2-1.md`
- `src/imports/ARISE_Figma_Master_Prompt_v2.md`

`v2-1` is the better legacy reference. It contains a much broader aspirational production brief (including more states/frames than the current React prototype). Use it only for product history or missing content. Do **not** let it override the user's new redesign prompt.

Legacy visual/reference imports also exist under `src/imports/`, including screenshots and moodboard images. Inspect them only if the new prompt asks to preserve prior visual DNA.

### Redesign guardrails for the next chat

- Treat the user's new prompt as the visual authority.
- Preserve the working app shell and useful flows rather than building a disconnected mockup or parallel app root.
- Keep all screens designed for 390×844 and respect iOS safe areas/notch/home indicator.
- Avoid fixed HUD/nav overlap with scrollable content, floating sheets, or FABs.
- Ensure overlay flows have one clear dismiss/back path and do not render duplicate copies.
- Retain meaningful interaction states: selected/unselected, active/inactive, loading, disabled, locked, completed, overdue, penalty, success, empty, and error where relevant.
- Consolidate repeated primitives and tokens; avoid continuing the legacy pattern of many one-off inline styles if the redesign can establish cleaner reusable tokens.
- Keep demo content rich enough that every screen looks production-ready, not like a wireframe.
- Validate the redesigned UI in the live Figma Make preview. Do not start a second dev server.

## Scope of the handoff

This handoff intentionally does not choose a new visual direction, component library, information architecture rewrite, or persistence/backend strategy. Those decisions belong to the user's new prompt and the new Figma Make chat. It captures the old chat's product and implementation context so the redesign can proceed without losing existing flows or repeating prior mistakes.

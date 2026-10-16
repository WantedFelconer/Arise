# ARISE — Figma Make Master Prompt: Missing UI Generation (v2.0)

---

## SYSTEM INSTRUCTIONS FOR FIGMA MAKE AI

You are generating **ONLY the missing UI** for an existing mobile application called **ARISE** — a gamified, AI-assisted, offline-first personal productivity platform ("Life Operating System") inspired by Solo Leveling and futuristic cyberpunk HUD aesthetics.

**An existing Flutter frontend already exists.** You are NOT redesigning it. You are extending it with screens, states, modals, and components that the product specification (SRS) requires but that have not yet been built. The result must look and behave as if designed by the original team. **Existing UI + your generated UI = one coherent product.**

---

## PART 1 — DESIGN SYSTEM TOKENS & ATOMS (MANDATORY)

### 1.1 Color Palette (Exact Hex Values from `AppColors`)

| Token | Hex | Usage |
|---|---|---|
| `voidEdge` (scaffold bg) | `#030712` | App background, all screens |
| `manaCyan` | `#3EE6F5` | Primary accent, active states, CTAs, glowing highlights |
| `terminalGreen` | `#39FF88` | Success states, terminal readouts, positive confirmation |
| `dangerRed` | `#FF4757` | Alarms, errors, penalties, destructive actions, boss rage |
| `textPrimary` | `#E2E8F0` | Main body text and card titles |
| `textSecondary` | `#94A3B8` | Subtitles, descriptions, timestamps |
| `textDisabled` | `#475569` | Inactive labels, placeholders, disabled buttons |
| `glassBorder` | `#1E293B` | Default card borders at rest |
| `glassPanel` | `#0F172A` (0.6α) | Frosted card backgrounds |
| `expFrom` / `expTo` | `#FFD700` / `#F59E0B` | Gold XP bar gradient, gold currency |
| `hpFrom` / `hpTo` | `#EF4444` / `#DC2626` | HP bar gradient, physical stats |
| `mpFrom` / `mpTo` | `#6366F1` / `#4F46E5` | MP/Mana bar gradient, cognitive stats |
| `rankE` / `rankD` / `rankC` | `#9CA3AF` / `#60A5FA` / `#34D399` | Ranks E, D, C |
| `rankB` / `rankA` / `rankS` | `#A78BFA` / `#FBBF24` / `#F87171` | Ranks B, A, S |
| `buffGreen` | `#4ADE80` | Active buffs, positive modifiers |

### 1.2 Typography Hierarchy

| Style | Font | Specifications | Usage |
|---|---|---|---|
| **Headers / Titles** | `Orbitron` | 700–900 weight, letterSpacing: 0.1–0.15em | Screen titles, card headers, stat values, rank badges, CTA buttons |
| **Body / Descriptions** | `Rajdhani` | 400–600 weight, line-height: 1.3 | Descriptions, instructions, narrative briefings |
| **Mono / HUD** | `Share Tech Mono` | 400 weight, letterSpacing: 0.08–0.12em | Terminal readouts, system codes, timestamps, metadata labels, stat numbers |

### 1.3 Core Component Library (Reuse Exactly — Do Not Invent New Patterns)

- **`GlassCard`**: Dark semi-transparent (`#0F172A` @ 60% opacity) rounded rect, 1px `glassBorder` stroke, 12px corner radius. Optional cyan/gold/red `borderColor` override.
- **`OrnatePanel`**: Clipped-corner sci-fi ornate frame with 1px border glow. Inner padding. Used for "System Windows", auth containers, and major alerts.
- **`PressableCard`**: Interactive card with 0.97 pressed-scale tactile response.
- **`DiamondDivider`**: Centered 1px horizontal line with a tiny diamond `◆` in the center (`manaCyan` @ 30% alpha).
- **`RankBadge`**: Capsule badge showing rank letter (E/D/C/B/A/S) with rank-specific glow and color.
- **`RewardChip`**: Capsule pill displaying XP, Gold, or Gem quantities with respective icons.
- **`SystemProgressBar`**: Gradient-filled progress bar with rounded ends. Variants: `hp`, `mp`, `exp`. Displays label + numeric values.
- **`GlowFab`**: Floating action button with `manaCyan` gradient, rounded rect, and glowing box-shadow.
- **`AriseSlidingWindow`**: Bottom-sheet modal with drag-to-dismiss handle and frosted glass background.
- **`ArisePopupWindow`**: Centered modal popup with dark blur backdrop and scale-in entrance.
- **`UplinkChip`**: Status indicator showing connectivity: green = stable, amber = pending/syncing, red = severed/offline.
- **`TerminalReadout`**: Monospace line-by-line terminal status output with status badges (`[INIT]`, `[SYNC]`, `[OK]`).
- **`DecryptText`**: AI/System text that dynamically animates into view.
- **`CustomSwitch`**: Futuristic toggle switch (cyan track when active, dark border when off).

### 1.4 Layout & Voice Guidelines
- **Background**: Strictly `#030712` (voidEdge).
- **Viewport**: Mobile-first 390×844 (iPhone 14 proportions).
- **Voice & Tone**: Solo Leveling System voice. Monospace bracket headers `[ SYSTEM DIRECTIVE ]`, bracketed CTAs `[ INITIALIZE UPLINK ]`, system error warnings `⚠ SYSTEM WARNING`.

---

## PART 2 — EXCLUSION LIST: EXISTING UI (DO NOT RECREATE)

The following 18 screens and flows already exist in the Flutter codebase. **Do NOT generate these**:
1. `HomeScreen` (Today's quests, briefing, mana/energy overview, streak)
2. `QuestListScreen` (Standard list view, active/daily/completed tabs, basic add modal)
3. `StatusScreen` (Stats STR/AGI/VIT/INT/PER, HP/MP/XP bars, title selector, XP ledger, achievements)
4. `JournalScreen` (Daily mood/quest logs, weekly chart)
5. `RoadmapScreen` (Skill node map with connections)
6. `FocusGateScreen` (Focus timer, stability orb, basic gate controls)
7. `ArmoryScreen` (Gold shop, item cards)
8. `ManaCoreScreen` (Screen time breakdown, mana economy)
9. `GuildScreen` (Party members, raid quests)
10. `CalendarScreen` (Basic single-day event list)
11. `SettingsScreen` (Account info, sound/notification toggles, theme selector, export, logout)
12. `AICoachScreen` (Chat interface, plan suggestion card)
13. `BossDetailScreen` (Boss HP, related quests, reward chips)
14. `NotificationsScreen` (Basic reminder list tab view)
15. `AuthScreen` (Login, Register, Recovery forms with terminal boot)
16. `OnboardingScreen` (Class, Chronotype, Difficulty, Hunter name, ARISE awakening)
17. `LevelUpScreen` (Level-up modal celebration)
18. `PenaltyScreen` (Penalty alert popup)

---

## PART 3 — PRIORITY-SPLIT PROMPT SEQUENCES

---

# 🚀 PROMPT 1: PRIORITY 1 — CORE PRODUCTIVITY LOOP & DAILY DRIVERS (MVP FOUNDATION)

> **Copy & Paste the prompt below into Figma Make for Batch 1:**

```text
Act as a Senior UI/UX Designer for ARISE (an offline-first, cyberpunk/RPG Solo Leveling productivity app).
Using the Design System (Background: #030712, Primary Cyan: #3EE6F5, Green: #39FF88, Red: #FF4757, Gold: #FFD700, Fonts: Orbitron for titles/CTAs, Rajdhani for body, Share Tech Mono for HUD/brackets, GlassCard, OrnatePanel, SystemProgressBar, RankBadge):

Generate ONLY the following Priority 1 screens and modals at 390x844:

1. [A1.1] HABIT TRACKER SCREEN (SRS §4.7)
- Header: [ HABIT PROTOCOL ] / HABITS
- Streak Summary Card: "LONGEST: 31 DAYS · ACTIVE: 6 HABITS · TODAY: 3/6"
- Filter tabs: ACTIVE / DAILY / WEEKLY / CUSTOM
- GlassCard Habit Items: Icon, Title (Orbitron 13px), Frequency ("DAILY · 08:00"), Streak pill "🔥 14 DAYS" in gold, 7-dot weekly streak progress bar, circular check button.
- Floating GlowFab "+" to add.
- Empty State variant with icon, "NO HABITS REGISTERED" and [ REGISTER FIRST HABIT ] button.

2. [A1.2 & A1.3] HABIT DETAIL & CONFIGURATION MODAL (AriseSlidingWindow)
- OrnatePanel header: [ HABIT CONFIGURATION ]
- Fields: Habit Name, Category (Body/Mind/Craft/Discipline), Frequency selector, Skip Allowance stepper (grace days before streak resets), Multi-time Reminder picker, Rank selector.
- Streak statistics readout: Current streak, completion rate %, total completions.
- CTA: [ INITIALIZE HABIT PROTOCOL ].

3. [A1.5] STREAK IN DANGER WARNING MODAL (ArisePopupWindow)
- OrnatePanel with red/amber glow: "⚠ STREAK IN DANGER"
- Narrative: "Your [Morning Meditation] streak of 24 days will break at midnight."
- Two actions: [ COMPLETE NOW ] (Cyan) and [ USE SKIP ALLOWANCE (1 Left) ] (Amber GlassCard).

4. [A2.1 & A2.2] INBOX & QUICK CAPTURE SCREEN + CAPTURE MODAL (SRS §4.8)
- Header: [ INBOX — UNSORTED ] / QUICK CAPTURE with badge "◈ 12 UNSORTED"
- Filter tabs: ALL / TEXT / VOICE / PHOTO
- GlassCard items with capture type icons (📝, 🎤, 📸), raw text preview, timestamp, and "[ AI TRIAGE ▶ ]" action button.
- Quick Capture Modal (ArisePopupWindow): Multiline text input, Voice recording wave button, Screenshot attach button, CTA: [ CAPTURE TO INBOX ].
- AI Triage Suggestion Card: DecryptText animation showing AI proposal: "→ CONVERT TO QUEST under Boss: 'Thesis Defense' due Tomorrow 18:00". Buttons: [ APPROVE ] (Green), [ EDIT ] (Cyan), [ DISMISS ].

5. [B1.1 - B1.5] QUEST MULTI-VIEWS (KANBAN, CALENDAR, TIMELINE, AGENDA) (SRS §4.6)
- Top View-Switcher Bar: ☰ LIST | ▦ KANBAN | 📅 CALENDAR | ▬ TIMELINE | 📋 AGENDA
- View 1: KANBAN VIEW — 3 horizontal-scroll columns: [TODO], [DOING], [DONE] with count badges, draggable quest GlassCards showing title, rank badge, estimated minutes, and dependency lock indicator.
- View 2: TIMELINE / AGENDA VIEW — Vertical time blocks (08:00, 10:00, 14:00) with scheduled quest duration capsules and Eisenhower priority tags (Urgent/Important).

6. [B2.1 & B2.2] FULL-SCREEN QUEST DETAIL & DEPENDENCY SYSTEM (SRS §4.6)
- Full-screen view with OrnatePanel header: Quest Title, Rank Badge, Status Pill (Active / Locked / Completed).
- Metadata grid: Estimated vs Actual duration, Eisenhower quadrant tag, Category tags, Parent Boss link.
- Subquests Section: Nested tree of child subquests with checkbox toggles and progress bar.
- Dependency Box: "REQUIRES: [Research Literature] ✓" or Locked State banner: "🔒 LOCKED — PREREQUISITES UNMET" (reduced card opacity, prerequisite blocker list).
- Action bar: [ COMPLETE QUEST ] (Cyan gradient), [ ENTER FOCUS GATE ], [ EDIT ], [ TRASH ].

7. [A10.1] FULL-SCREEN SYSTEM ALARM & WAKE-UP ALERT (SRS §4.15)
- Full-screen high-priority alert on #030712 background with pulsing cyan/red radial glow and rotating radar rings.
- Header: "⚠ PRIORITY SYSTEM DIRECTIVE — TIME REACHED" (Mono blinking).
- Huge digital time display: "06:30 AM" (Orbitron 48px bold).
- Alert Title: "[ AWAKEN HUNTER — DAILY QUEST RESET ]".
- Linked Quest Card: "Morning Workout (100 Push-ups, 100 Sit-ups, 10km Run)" with B-Rank badge and "+200 XP" chip.
- Primary Interaction: Glowing Slider "[ SLIDE TO ARISE / ACCEPT DIRECTIVE >>> ]".
- Secondary Action: "[ SNOOZE 10 MIN (FATIGUE PENALTY: +5) ]".

8. [A10.2] BEHAVIORAL INTERVENTION PROMPT (SRS §4.15 FR-REM-2)
- ArisePopupWindow with amber/cyan HUD border: "[ BEHAVIORAL INTERVENTION — IMPULSE BRAKE ]".
- Message: "Impulse Trigger Detected: 'Check Social Media'. The System requests a 15-minute pause. Does this action serve the Sovereign Hunter?".
- Circular 15-minute countdown dial (00:14:59) with breathing ring animation.
- Action Buttons: [ ENGAGE 15-MIN DELAY ] (Terminal Green) / [ OVERRIDE PROTOCOL ] (Subtle danger red text).
```

---

# ⚔️ PROMPT 2: PRIORITY 2 — DUNGEON PROJECTS, AI PLANNING & KNOWLEDGE ENGINE

> **Copy & Paste the prompt below into Figma Make for Batch 2:**

```text
Act as a Senior UI/UX Designer for ARISE (an offline-first, cyberpunk/RPG Solo Leveling productivity app).
Using the Design System (Background: #030712, Primary Cyan: #3EE6F5, Green: #39FF88, Red: #FF4757, Gold: #FFD700, Fonts: Orbitron for titles/CTAs, Rajdhani for body, Share Tech Mono for HUD/brackets, GlassCard, OrnatePanel, SystemProgressBar, RankBadge):

Generate ONLY the following Priority 2 screens and modals at 390x844:

1. [A3.1 - A3.3] DUNGEON SYSTEM SCREENS (SRS §4.12)
- Dungeon List Screen: Header [ DUNGEON REGISTRY ] / DUNGEONS. GlassCard Dungeons (e.g., "SEMESTER 1 LAUNCH", "STARTUP MVP LAUNCH"), showing Boss Count ("◈ 4 BOSSES · 2 DEFEATED"), overall progress bar (SystemProgressBar exp variant), Rank S badge, and status pill (ACTIVE / CONQUERED). Floating GlowFab "+".
- Dungeon Detail Screen (Overlay): OrnatePanel header with Dungeon stats, active child Bosses list with HP progress bars, XP reward pool, and [ ENTER CAMPAIGN ] button.
- Create Dungeon Modal (AriseSlidingWindow): Dungeon Name, Description, Target Deadline, Boss selection multi-picker.

2. [B4.1 - B4.5] AI QUEST PLANNER WORKFLOW (SRS §4.10)
- Screen 1: Plan Request Input: OrnatePanel with [ AI QUEST PLANNER ], Goal text area, Deadline picker, Available daily hours stepper, Proficiency level selector (Beginner/Intermediate/Advanced), CTA: [ GENERATE MASTER PLAN ].
- Screen 2: Plan Generation Terminal: Animated TerminalReadout displaying: "> ANALYZING GOAL PARAMETERS...", "> COMPUTING DEPENDENCY GRAPH...", "> PLAN GENERATION IN PROGRESS..." with glowing particle field.
- Screen 3: Plan Review & Approval (SRS C-10): Header "[ GENERATED PLAN — PENDING APPROVAL ]", list of proposed editable Quests with duration estimates, priority tags, and dependency connectors. Summary card: "14 Quests · 28 Est. Hours". Two-button footer: [ APPROVE & DEPLOY QUESTS ] (Terminal Green) and [ DISCARD PLAN ] (Red).
- Screen 4: AI Provider Offline Fallback: Banner "⚠ AI PROVIDER OFFLINE — System neural link severed", fallback button [ CREATE MANUALLY ].

3. [A4.1 - A4.4] KNOWLEDGE ARCHIVE & NOTES SYSTEM (SRS §4.17)
- Notes List Screen: Header [ KNOWLEDGE ARCHIVE ] / NOTES. Search bar, Folder tabs (Study, Work, Lore), GlassCard Note items with title, 2-line snippet preview, tag pills, Notion sync indicator (green check if synced), and timestamp.
- Note Editor Screen (Overlay): Header with title input, tag selector, folder picker, rich text toolbar (Bold, Code, List, Heading), Notion sync toggle "[ SYNC TO NOTION ⬡ ]", save status chip.
- Note Sync Conflict Modal (SRS §7.3): Side-by-side comparison "[ LOCAL VERSION ]" vs "[ SERVER VERSION ]" with diff highlights and buttons: [ KEEP LOCAL ], [ KEEP SERVER ], [ MERGE ].

4. [A6.1 & A6.2] ANALYTICS & AI MONTHLY REPORTS (SRS §4.18)
- Analytics Dashboard Screen: Header [ ANALYTICS ENGINE ] / SYSTEM REPORTS. Period tabs: DAILY / WEEKLY / MONTHLY / YEARLY.
- 4 Key Metric Cards: XP Earned (+4,850 XP), Focus Time (34.5 hrs), Quest Clear Rate (92%), Gate Stability (96%).
- Interactive Charts: XP over time line chart, Focus time intraday bar chart, Mana recovery vs drain trend chart.
- AI Narrative Summary Panel (OrnatePanel): Header "[ AI MONTHLY SYSTEM REFLECTION ]", DecryptText report: "Hunter performance elevated by 14%. Peak focus: 09:00-11:00. Distraction down 22%. Recommendation: Increase Gate duration on Tuesdays."

5. [A7.1] GLOBAL SEARCH EVERYWHERE SCREEN (SRS §4.25)
- Full-screen search overlay with large glowing search input: "SEARCH QUESTS, BOSSES, NOTES, HABITS...".
- Categorized live results:
  - QUESTS (3) -> matching Quest GlassCards with status and rank
  - BOSSES (1) -> matching Boss cards with HP bar
  - NOTES (2) -> matching Note cards with folder tags
  - HABITS (1) -> matching Habit streak cards
- Quick-filter chips: [ALL] [QUESTS] [BOSSES] [NOTES] [HABITS].
```

---

# 🛡️ PROMPT 3: PRIORITY 3 — WELLNESS, AUDIO, INTEGRATIONS & POLISH STATES

> **Copy & Paste the prompt below into Figma Make for Batch 3:**

```text
Act as a Senior UI/UX Designer for ARISE (an offline-first, cyberpunk/RPG Solo Leveling productivity app).
Using the Design System (Background: #030712, Primary Cyan: #3EE6F5, Green: #39FF88, Red: #FF4757, Gold: #FFD700, Fonts: Orbitron for titles/CTAs, Rajdhani for body, Share Tech Mono for HUD/brackets, GlassCard, OrnatePanel, SystemProgressBar, RankBadge):

Generate ONLY the following Priority 3 screens, modals, and system states at 390x844:

1. [A5.1 - A5.3] PHYSICAL TRAINING & FITNESS DASHBOARD (SRS §4.19)
- Fitness Dashboard Screen: Header [ PHYSICAL TRAINING LOG ] / FITNESS.
- Today's Vital Cards (Row of 3): Steps ("🏃 8,420 / 10k"), Water ("💧 6 / 8 glasses"), Sleep ("🌙 7.5 hrs").
- Exercise Activity Log: List of training GlassCards (Running, Calisthenics, Weightlifting) showing duration, calories, and computed "+45 STR / +20 VIT" stat gain.
- Health Connect / Apple Health sync card with "[ SYNC VITAL STATS ]" button.
- Log Activity Modal (AriseSlidingWindow): Exercise type picker, duration stepper, intensity rank.

2. [A9.1 & A9.2] FOCUS AUDIO & BRAIN RESET MODE (SRS §4.21)
- Focus Audio Player Screen: Header [ AUDIO SYSTEM ] / FOCUS FREQUENCIES. Tabs: LO-FI / RAIN / WHITE NOISE / NATURE / FANTASY. Track list GlassCards with play state waves, bottom player bar with volume slider and audio wave visualizer.
- Brain Reset Mode Screen: Full-screen relaxation session with breathing ring animation (expanding and contracting glowing cyan orb), 852Hz tone frequency selector, guided breath prompts ("IN-BREATH 4s", "HOLD 4s", "RELEASE 4s"), and [ END RESET ] button.

3. [A8.1 & A8.2] INTEGRATIONS HUB & OAUTH CONNECT (SRS §4.24)
- Integrations Screen: Header [ EXTERNAL UPLINKS ] / INTEGRATIONS.
- 3 Connection GlassCards:
  - 1. NOTION SYNC: Status "[ CONNECTED ✓ ]", Last Synced 12m ago, Target Database picker, [ FORCE SYNC ] button.
  - 2. GOOGLE CALENDAR: Status "[ DISCONNECTED ]", Two-way sync toggle, [ ESTABLISH UPLINK ] button.
  - 3. HEALTH CONNECT / APPLE HEALTH: Status "[ ACTIVE ]", Auto-sync toggle.
- OAuth Connecting Modal: TerminalReadout showing handshake sequence: "> INITIATING OAUTH2 HANDSHAKE...", "> EXCHANGING ENCRYPTED KEYS...", "> UPLINK VERIFIED".

4. [B5.1 & B5.2] AI COACH REVIEWS & NUDGE ALERTS (SRS §4.16)
- Weekly Review Screen: Header [ WEEKLY REVIEW — WEEK 34 ]. 3 prompt cards: "WHAT WENT WELL?", "WHAT WAS BLOCKED?", "GOALS FOR NEXT WEEK?", analytics summary widget, [ TRANSMIT REVIEW ] button.
- Overload Warning Card: Red-bordered GlassCard: "⚠ SYSTEM WARNING: SCHEDULE OVERLOAD DETECTED — 14 hours allocated for 8-hour window", with [ AUTO-REBALANCE SCHEDULE ] button.
- Procrastination Nudge: Amber GlassCard: "◈ SYSTEM NOTICE: Repeated delay on [Project Spec] (Postponed 4x)", with [ BREAK INTO SUBQUESTS ] action.

5. [C1 - C11] SYSTEM STATES, REWARDS & MICRO-INTERACTIONS
- Global Offline Top Banner (SRS §3.2): Amber HUD banner "📡 UPLINK SEVERED — OPERATING IN LOCAL OFFLINE MODE (EVENTS QUEUED)".
- Bulk Actions Bottom Bar: Multi-select mode showing "3 QUESTS SELECTED" with actions: [ COMPLETE ALL ], [ ARCHIVE ], [ DELETE ], [ ASSIGN TO BOSS ].
- Gate Collapse Penalty Result Modal: Red OrnatePanel displaying: "GATE COLLAPSED — STABILITY LOST", XP Penalty: "-80 XP", Mana Drain: "-35 MP", Hardcore Boss Recovery: "+15% Boss HP".
- Gate Success Reward Modal: Cyan OrnatePanel displaying: "GATE CLEARED — FOCUS SUSTAINED", RewardChips: "+250 XP", "+50 MP RECOVERED", "+100 GOLD", "Boss Damage: -450 HP".
- Achievement Unlock Celebration Popup: Glowing gold OrnatePanel, animated badge, Rarity pill "LEGENDARY", Title: "[ SHADOW MONARCH ]", "+500 XP" chip, [ CLAIM REWARD ] button.
- Boss Defeated Cinematic Card: Full-screen victory banner with red-to-gold particle effects, boss name stamped "DEFEATED", reward cascade breakdown.
- Routine Builder Modal (SRS §4.7 FR-HABIT-5): Checklist block builder ("MORNING PROTOCOL" / "EVENING RITUAL") with drag-to-reorder habit sequence and [ START ROUTINE BLOCK ] button.

6. [D1 - D3] SETTINGS DEEP SCREENS (SRS §4.23)
- Circadian Profile Setting: Editable chronotype curves (Early Bird, Night Owl, Custom peak hours slider).
- Data Backup & Import: JSON Export / Import buttons with record counts and integrity verification checkmark.
- Danger Zone Account Deletion Modal: Red alert panel with typed "DELETE" confirmation safeguard.
```

---

*End of Figma Make Master Prompt Suite v2.0*

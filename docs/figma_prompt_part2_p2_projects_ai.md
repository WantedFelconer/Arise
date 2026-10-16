# ⚔️ PROMPT 2 (PRIORITY 2) — DUNGEONS, AI PLANNING & KNOWLEDGE ARCHIVE

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

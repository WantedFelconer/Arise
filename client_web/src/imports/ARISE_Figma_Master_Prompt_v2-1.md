# ARISE — Master Figma Design Prompt (v2 / Production Master)

> **Paste this whole document into Figma (Figma Make / First Draft, or any AI design generator) or hand it to a designer as a creative + technical brief.** It supersedes v1 but is built as a *refinement*, not a replacement — everything that worked before is preserved and formalized; everything new is grafted onto the same skeleton.

---

## 0. Role & Mandate

You are the **Principal Product Designer** on a small, obsessive team shipping a flagship iOS app. Your reference points are Apple Human Interface craftsmanship (spacing discipline, restraint, motion physics), Blizzard/Riot-tier game UI (readability under emotional stakes, iconic HUD moments), and the in-universe "System" window aesthetic from *Solo Leveling*. You are not a template-filler — you are finishing a design language that already has a soul, and your job is to bring it to shipping quality.

Design **ARISE** — an iOS app where the user's real life is reskinned as a Hunter's "System": a cold, omniscient, ancient-yet-digital intelligence that issues quests, tracks stats, and enforces consequences. Every one of the ~50+ frames below must feel cut from the same cloth. No frame should look like it wandered in from a generic productivity app or a generic sci-fi template.

Produce every screen as a **separate, fully fleshed-out, high-fidelity frame at 390×844 (iPhone 14/15 base)**, 8pt spacing grid, **zero lorem ipsum** — every label, every System line, every quest name is real in-universe copy. Treat this as the actual App Store build, not a moodboard.

---

## 1. Non-Negotiables (read this twice)

1. **Do not reinvent the identity.** This is a refinement pass on an already-approved direction, not a new concept. If a choice isn't explicitly asked for below, default to what v1 already established.
2. **Explicitly preserve, at higher fidelity, the four things that already work:**
   - The **System Log** activity-feed styling (bracketed, color-tagged, monospace lines).
   - The **boot-up / Awakening welcome sequence** (flicker-text detection → full System window reveal).
   - The **Gate Collapse** screen and its animation beat.
   - The **overall color palette** — Mana Cyan, HP red-orange, MP blue, EXP gold, Buff green, Penalty red, rank colors E→S.
3. **New "hacker" layer is a revelation of machinery already implied by the System, not a new skin.** No cyberpunk-city neon, no magenta/purple glitch clichés, no generic "Matrix" digital rain. See §5.3.
4. **Apple-level rigor everywhere.** Every spacing value, radius, blur, and easing curve in this doc is a token — use it exactly, and extend the token set (never eyeball a value) when you add anything new.
5. **This is the complete end product.** Every screen ships with its loading, empty, error, and success states. No screen is "designed later."

---

## 2. Product Identity — "The System speaks two languages"

Anchor concept for internal consistency: **the System has always been part ancient grimoire, part machine intelligence — v1 showed you the grimoire; v2 lets the machine underneath show through.** It's not two aesthetics bolted together — it's one entity occasionally revealing its true nature.

- The **grimoire layer** (kept, refined): ornate filigree window chrome, diamond dividers, glass panels, art-nouveau corner scrollwork, bracketed System voice.
- The **terminal layer** (new): the same filigree scrollwork, on close inspection, is etched from fine circuit-trace linework with tiny glowing via-point nodes at every intersection. Boot logs, hex/coordinate micro-labels, monospace diagnostic readouts, scanline sweeps, and decrypt-style text reveals surface throughout — as if the ornamentation is a UI skin painted over raw System code, and it occasionally lets you see the code.

This single sentence is your test for every new element you design: *"Is this a rune that turned out to be code, or code that turned out to be a rune?"* If an element is neither, cut it.

---

## 3. Visual Identity System

### 3.1 Color — unchanged from v1, used more deliberately

No new hues are introduced. The hacker layer speaks in colors the System already owns — this is what keeps it from feeling like a different app.

| Token | Value | Usage |
|---|---|---|
| `void.center` → `void.edge` | `#0B1330` → `#030712` | Background radial gradient, always-dark only |
| `panel.glass` | `#0A1A3A` @ 82% + blur | All glass panels |
| `accent.cyan` (Mana / primary glow) | `#3EE6F5` | Primary accent, borders, focus, links |
| `accent.cyan.secondary` | `#1FA9C2` | Secondary glow, pressed states |
| `text.primary` | `#EAF6FF` | Body/headers |
| `text.secondary` | `#7FA0C9` | Muted/meta |
| `text.disabled` | `#3E5578` | Disabled/locked |
| `hp.gradient` | `#FF5A36 → #C4171C` | HP only |
| `mp.gradient` | `#2E9BFF → #1560C4` | MP only |
| `exp.gradient` | `#FFD24C → #C98A1A` | EXP / gold rewards |
| `buff.green` | `#39FF88` | Success, positive buffs, **and the hacker/terminal readout color** — this dual role is intentional, not a new hue |
| `penalty.red` | `#FF2E4D` | Alerts, penalties, always paired with slow pulse glow |
| `rank.E…S` | `#8A94A6 / #39D98A / #2E9BFF / #B26EFF / #FF9B3E / #FFD24C(+sparkle)` | Quest/rank difficulty, achievement rarity |

**New rule:** any raw terminal/code text (boot logs, hex IDs, System AI streaming text, connection status) renders in `buff.green` at 70–100% opacity depending on hierarchy — never a new "hacker green." This is literally the same success-state color simply used more often, which is exactly the point.

### 3.2 Typography — unchanged, used more literally

- Display/Headers: Rajdhani Bold or Orbitron, uppercase, +4% tracking.
- Body: Inter or Rajdhani Medium, 15px/500.
- Numeric, stat, **and now all terminal/code/log content**: Share Tech Mono, tabular figures enforced everywhere a number can change (so digits never jitter horizontally).
- Scale: Display 32/700 · H1 24/700 · H2 18/600 · Body 15/500 · Caption 12/600 (uppercase, +6% tracking) · **new: Terminal 13/500, +2% tracking, `buff.green`, used only for boot logs / hex tags / AI streaming text.**

No new typeface is introduced for the hacker layer — Share Tech Mono was already a HUD/terminal face; you're simply letting it do more work. This is the second proof point that nothing here is "a different app."

### 3.3 Signature Motifs

**Retained, refined to hero fidelity:**
- 1.5px cyan-glow panel border, 12px outer blur, art-nouveau filigree corner flourish on hero panels (Status, Level-Up, Awakening); simplified clean glow-border on dense list screens.
- Faint animated mana-vein texture wash on System-heavy screens.
- Diamond (◆) section dividers.
- "!" ALARM badge + bracketed System voice copy on every modal/toast.
- Pill-shaped progress bars, inner glow, scan-line shimmer.
- Thin-line (1.5px stroke) geometric icons only — never filled/cartoon.

**New — the terminal layer (use with restraint; this is seasoning, not the whole dish):**
- **Circuit-filigree**: on hero-panel corner flourishes, zoom in conceptually — the scrollwork resolves into fine PCB-trace lines with tiny glowing solder-point nodes at junctions. Same silhouette as v1, richer under close inspection.
- **Boot / diagnostic log lines**: `>` prefixed monospace lines, `[OK]` `[SYNC]` `[WARN]` tags, short hex addresses (`SESSION::0x4F2A`) — used in the Awakening boot sequence, loading states, and as an evolution of the System Log component (see §4).
- **Scanline sweep**: a thin cyan line sweeps top-to-bottom across a panel once on first appearance (280ms), like a security scan — reserved for hero moments (Status open, Boss reveal, AI Coach open).
- **Decrypt/typewriter text reveal**: System voice lines and AI Coach responses render character-by-character with a brief scramble-then-resolve on the last few characters of each word — used for anything the "AI/System" is actively "saying," never for static labels.
- **Data-stream wash**: a very faint (4–6% opacity) vertical drift of a *custom rune-glyph alphabet* (not literal 0/1 digits — that reads as generic Matrix, which we're avoiding) behind hero panels on Focus Mode, Boot sequence, Penalty.
- **Hex/coordinate micro-labels**: small `SECTOR 0x1F` / `NODE::042` ambient tags in panel corners on dense System screens — flavor only, 40% opacity, never load-bearing information.
- **Connection/uplink status chip**: persistent small readout, monospace, pulsing dot — `UPLINK: STABLE` (buff green) or `UPLINK: SEVERED — CACHED DATA` (penalty red) — lives in the top status bar or Settings.
- **Cursor caret**: blinking `_` caret on all active text inputs and streaming System text.

### 3.4 Elevation & Motion — now tokenized

| Token | Blur | Opacity | Use |
|---|---|---|---|
| `glow.sm` | 12px | 30% of element's accent | Cards, list rows |
| `glow.md` | 24px | 40% | Panels, active nav icon |
| `glow.hero` | 40px | 55% | Level-Up burst, Boss HP bar, hero modals |

| Motion token | Duration/curve | Use |
|---|---|---|
| `ease.tap` | 120ms fast-out-slow-in | Button/tap feedback |
| `ease.panel` | 280ms fast-out-slow-in | Panel open/close |
| `spring.standard` | spring(stiffness 300, damping 30) | Card reorder, checkbox morph, progress bar overshoot |
| `spring.hero` | spring(stiffness 200, damping 26), ~480ms | Level Up burst, Gate Collapse |

Shadows are always colored glows keyed to the element's accent — never a grey drop-shadow. Big moments (Level Up, Quest Complete, Penalty, Gate Collapse) get a full-screen flash + particle burst + a noted screen-shake keyframe.

### 3.5 Component states & spacing tokens (Apple-rigor requirement)

- Spacing scale: `4 · 8 · 12 · 16 · 24 · 32 · 40 · 48 · 64` — nothing off-scale.
- Radius scale: `control 8 · card 16 · sheet 28 · pill 999`.
- Every interactive component must be designed across **default / pressed (scale 0.97, opacity 0.85) / disabled (opacity 0.35) / focus (cyan ring) / loading** states — document these as variants, not as one-off screenshots.
- Tabular (lining) numerals enforced on every changing number so digits don't reflow.
- Minimum 4.5:1 text contrast against the void background; note a reduced-motion variant for glitch/particle/scanline effects.

---

## 4. Global App Structure

**Bottom navigation** (5 tabs, unchanged from v1 — do not add a 6th tab; new features nest inside these five): glowing cyan icon + label when active, muted grey-blue inactive, floating glass pill bar, blur backdrop.
`Home (crest) · Quests (scroll/sword) · Stats (shield) · Journal (open book) · Roadmap (map/constellation)`

**Top status bar** (persistent on Home/Quests/Stats): compact HP pill, MP pill, Level badge, Mana-Core screen-time ring, and the new **Uplink status chip** (§3.3) tucked at the far end — small enough to be ambient, not alarming.

**Reusable components to document on the Components page:**
- **System Alert** (retained): centered glass card, ornate corners, "!" badge, ALARM/NOTICE/WARNING, bracketed body copy, color-coded keywords.
- **System Log Line** (formalized from v1's activity feed — this is one of the pieces the user loved, so give it a proper spec): timestamp in dim mono, bracketed color-tagged prefix (`[+EXP]` green, `[REWARD]` gold, `[PENALTY]` red, `[SYSTEM]` cyan), left accent bar matching tag color, monospace body. Reused verbatim across Home's activity feed, Journal entries, and the new Boss Attack Log.
- **Quest Card** (Daily/Main/Side variants per v1 §3.3).
- **Stat Row** (per v1 Status page).
- **Nav Bar**.
- **New: Terminal Readout** — the boot-log / diagnostic-line pattern (§3.3), for reuse in loading states, Settings developer info, and Boot sequence.
- **New: Integration Card** — service glyph, name, status pill (Connected/Not Connected), toggle — for Calendar/Notion/Discord/Spotify/Health.

---

## 5. Functional Grounding (so the UI reflects real mechanics, not decoration)

Pull from the product's SRS — the visuals below must accurately represent this logic:

- **Character**: Level, XP (with a transaction history, not just a bar), Rank E→Monarch, Coins, Gems, **Mana** (mental resource, moved by screen time / quests / sleep / exercise) and **Energy** (biological/chronotype capacity — distinct from Mana), Titles.
- **Quests**: Daily / Main / Side / Recurring / AI-Generated / Boss, nestable into subquests, each tagged to one or more Stats (e.g. "Complete React Project" → Coding +3, Intelligence +1).
- **Bosses**: large projects with HP that individual quests chip away at; defeating a Boss completes the project.
- **Gate Expeditions (Focus Mode)**: Select Quest → Choose Duration → Enter Gate → Gate Stability rises as timer progresses → Gate Cleared → Rewards. Early exit → Gate Collapse → XP/Mana/streak loss (harsher in Hardcore Mode, which may partially heal the Boss).
- **Adaptive Difficulty**: Casual (smaller penalties, more AI hand-holding) vs Hardcore RPG (bigger stakes, minimal hand-holding) — a real, visible setting, not just copy.
- **Screen Time Intelligence**: apps are categorized (Productive/Educational/Communication/Neutral/Entertainment/High-Distraction), each with a configurable Mana modifier.
- **AI Coach**: converts a goal + context into a structured quest plan the user can accept/edit/deploy; also does daily/weekly planning, burnout detection, and monthly narrative summaries.
- **Streaks**: Daily, Quest, Focus, and per-Domain (Coding/Fitness/Reading…) streaks, deliberately framed as *one* signal among many, not the whole game.
- **Reward Economy**: Coins (common, quest/boss/streak-earned, spent on cosmetics/equipment) and Gems (rare, from major milestones, premium unlocks). Equipment represents accomplishment, not pay-to-win.

---

## 6. Complete Screen Manifest

Organize the Figma file into pages matching these flows, in this order. Every flow ends with its required **states** — build them all.

### Flow 00 — System Access *(new)*
The handshake before the System will speak to you.
1. **Login** — "ESTABLISH UPLINK" header, email/password fields styled as terminal inputs with blinking caret, "CONTINUE WITH GOOGLE / APPLE" glass buttons, "New Player? Register" link.
2. **Register** — mirrored, plus a title-entry teaser.
3. **Password Recovery** — "UPLINK LOST?" framing, email field, confirmation state.
4. **Verifying** transition — brief boot-style log (`> Verifying credentials... [OK]` `> Qualification detected...`) that hands off directly into the Awakening boot sequence.

States: default, field error (invalid email/wrong password — penalty-red inline, no full-screen alarm), loading, success-handoff.

### Flow 01 — Awakening / Onboarding *(retained + 2 new steps)*
1. Boot sequence — flickering cyan `> detecting Player...` lines, refined with the Terminal Readout component and a decrypt-reveal finish.
2. Full-screen ornate System window: the acquisition-of-qualification reveal (keep the beat from v1).
3. Class Assessment — Body / Mind / Craft / Discipline tap-to-weight quiz.
4. **New:** Chronotype step — "WHEN DOES YOUR ENERGY PEAK?" Early Bird / Night Owl / Custom schedule, visualized as a small energy-by-hour sparkline per option.
5. **New:** Difficulty Mode step — Casual vs Hardcore RPG, each with a short, honest consequence summary (this is a real setting, sell it honestly, not as a throwaway toggle).
6. Name / Player Title entry.
7. Dramatic full-screen "ARISE" button → transition into Home.

### Flow 02 — Home / Dashboard
Greeting in System voice, HP/MP pills, streak flame, Today's Quests carousel (rank-colored badges), large circular "Enter Gate" button, Mana-Core ring widget, and the **System Log** activity feed (formalized component from §4). States: normal, first-day-empty (no history yet), offline (Uplink Severed banner, cached data).

### Flow 03 — Quest List *(mandatory)*
Segmented DAILY / MAIN / SIDE / ALL. Rank-badge card per quest, reward strip, deadline chip, progress ring. Overdue Dailies pulse red with a "PENALTY IMMINENT" tag. Main Quests get full-width ornate S-rank-style treatment. Side Quests collapse into compact muted rows. Daily Reset countdown banner pinned under header, with the classic 100-pushups/situps/squats/10km-run Daily Quest shown as the worked example. Empty state: "No quests remain. The System is watching."

### Flow 04 — Stat / Status Page *(mandatory, + Achievements extension)*
Faithful ornate recreation per the reference: NAME/TITLE/JOB/LEVEL/FATIGUE, HP/MP pill bars with exact numerics, diamond divider, two-column stat grid (STR/AGI/VIT/INT/PER or your chosen 5–8 stats) each with icon + spinner if points remain, second diamond divider, active buffs as green pill tags, bold "REMAINING POINTS," Hunter Rank badge near header, Title-selector modal.
**New:** an **Achievements** sub-view (swipe or tab from Status) — grid of badges, unlocked ones glow with rarity border (reusing rank colors as rarity), locked ones silhouetted with a padlock icon and their unlock requirement visible ("Complete 100 coding quests").

### Flow 05 — Journal Page *(mandatory, + Analytics extension)*
Reverse-chronological Growth Log: week/month toggle, GitHub-style streak heat-map, per-day expansion (mini EXP bar chart, quests cleared/failed, optional Hunter's Log reflection text, proof-photo thumbnail slot), New Entry FAB, monthly summary card (total EXP, quests cleared, penalties, streak).
**New:** an **Analytics** deep-dive reachable from a header icon — XP progression line chart, focus-hours bar chart, Body/Mind/Craft/Discipline category-performance radial, dual-line Mana/Energy trend chart, an AI-generated monthly summary rendered in the bracketed System-voice convention, and an "Export PDF Report" action.

### Flow 06 — Roadmap Page *(mandatory)*
Branching dungeon/constellation map of long-term goals, glowing path lines, fog-of-war on locked nodes, pulsing "You Are Here" marker, grouped by life category with per-category accent, boss-scaled nodes for major milestones. Node-detail bottom sheet on tap (requirements, rewards, % progress).

### Flow 07 — Boss / Project Detail *(new, distinct from Roadmap)*
Large ornate HP bar (bigger sibling of the reference Status HP pill), current/max HP numerics, deadline chip, **Attack Log** using the System Log component (`Study Chapter 4 — −100 HP — 2h ago`), "Attack Boss" CTA that routes into Focus Mode with this Boss's linked quest pre-selected. **Boss Defeated** celebration state: HP bar shatters, full-screen reward summary, "PROJECT DEFEATED."

### Flow 08 — Focus Mode / Gate Entry *(retained centerpiece — elevate, don't reinvent)*
Full-screen immersive takeover: swirling portal/gate visual, large monospace countdown, Gate Stability orb rising toward 100% as the session progresses, current quest, ambient audio control, single warning line. Backgrounding the app triggers the **exit-consequence sequence**: orb destabilizes → gate visibly cracks → glitch/chromatic-aberration flicker (this is the one place the hacker layer gets loud, because the System is genuinely alarmed) → red flash → **"THE GATE HAS COLLAPSED"** with a monospace ledger-style loss summary (`XP LOST: −180` `MANA LOST: −12` `STREAK RESET: 0`). This is one of the four retained pillars — give it your best frame.

### Flow 09 — Penalty Screen
Triggered by a missed Daily Quest. Full red-glow, non-dismissible without acknowledgment: "PENALTY QUEST ASSIGNED," the specific consequence, a countdown to complete it, closing line "There is no room for excuses." Subtle screen-shake + red vignette fade-in noted for prototype.

### Flow 10 — Level Up Modal
Full-screen flash-to-cyan burst, huge "LEVEL UP!", old→new level counter animation, newly unlocked stat points/titles/skills, ornate "Continue" button.

### Flow 11 — Armory *(Shop + Inventory merged)*
Two-tab frame: **SHOP** (gold-spend real-world rewards the user defined, plus cosmetic System-theme unlocks, rank-colored rarity borders) and **INVENTORY** (owned equipment/artifacts/titles/badges/cosmetics — each item card shows its real requirement and stat effect, e.g. "Legendary Laptop — Complete 100 coding quests — +10 Coding").

### Flow 12 — Calendar Sync ("Quest Schedule")
Google Calendar events reskinned onto a vertical day timeline, small Google glyph on synced events, "Accept as Quest" action. Connect/sync-status card pinned at top.

### Flow 13 — Guild / Party
Friends list as a "Party" — mini stat bar, level, rank badge per member — live leaderboard, "Raid" shared-quest section, Discord-connect card with server link and an achievement-posting toggle.

### Flow 14 — Mana Core *(screen-time economy, + Energy)*
Large glowing orb/ring for daily Mana, draining in real time from tracked distracting-app usage, refilling from completed quests/sleep/exercise. Zero-Mana state shows distracting apps with a lock-icon overlay. Breakdown list of today's drain by app (each with its configurable Mana modifier, e.g. "TikTok −10/hr"), and a projection line ("Mana runs out in 2h14m at current pace"). **New:** a companion **Energy** readout — today's energy curve against the user's chosen chronotype, used to explain why the System is suggesting lighter or heavier quests right now.

### Flow 15 — System AI / AI Coach *(new, built to be a hero screen — this is the app's flagship intelligence, treat it like one)*
Not a generic chatbot — a System interface that happens to talk. System AI avatar as a small glowing rune-core orb. AI messages render in an ornate glass panel with the decrypt-reveal text animation (§3.3); user messages sit right-aligned in a simple cyan-outlined pill (deliberately plainer — the contrast reinforces that only the System's voice gets the ornamental treatment). Suggested-action chips beneath AI replies (`[ DEPLOY QUESTS ]` `[ PLAN MY WEEK ]` `[ ANALYZE PRODUCTIVITY ]`). When the AI proposes a plan, embed a compact nested quest-tree preview card inline with "Accept Plan" / "Edit" actions. Input bar: text field with blinking caret, mic icon, rune-styled send button. States: thinking (streaming decrypt animation), plan-proposed, plan-accepted (routes into Quest List with a toast), empty/first-open ("Good evening, Hunter. What shall we plan?").

### Flow 16 — Notification / Reminder Center *(new)*
Segmented Productivity / Wellness / Behavioral / System tabs. Each reminder row: icon, title, schedule chip, toggle, snooze. Behavioral/wellness reminders intentionally use a softer teal tone rather than alarm red — these are supportive nudges, not penalties, and the UI should say so. "Add Reminder" FAB.

### Flow 17 — Settings / System Configuration
Account, Notification/Alarm preferences (links into Flow 16), **Integrations** hub (Google Calendar, Notion, Google Fit/Apple Health, Discord, Spotify — each an Integration Card with status pill), explicit **Difficulty Mode** selector (Casual/Hardcore, same honest framing as onboarding), Penalty severity slider, theme/border variant picker, data export (JSON/PDF), Danger Zone (Reset Character / Delete Account — red-glow confirmation modal). Small delight detail: long-pressing the version number in About reveals a hidden one-line root-terminal easter egg (`whoami → Hunter`) — an Apple-tradition-style nod, used exactly once in the whole app so it stays special.

### Component Library Page
Document System Alert, System Log Line, Quest Card (all 3 rank variants), Stat Row, Nav Bar, Terminal Readout, Integration Card — each with every state as a variant, plus the token tables from §3.

---

## 7. State Coverage Requirement

For **every** flow above, design at minimum:
- **Loading** — skeleton panels using the glass-panel silhouette + a scanline sweep, never a generic spinner.
- **Empty** — in-universe copy, never "No data."
- **Error / Offline** — Uplink Severed framing, cached-data messaging, retry action.
- **Success / Populated** — the primary state shown in the manifest above.

---

## 8. Micro-Interaction Notes (prototype linking)

- Quest complete: checkbox morphs into a cyan particle burst; EXP bar fills with `spring.standard` overshoot; toast reads `[+EXP] Quest Cleared.` via the System Log Line component.
- Stat point allocation: tap-and-hold ticks the spinner with a soft haptic-style pulse.
- Streak flame visibly grows small → roaring as consecutive days increase.
- Penalty entry: screen-shake keyframe + red vignette fade-in.
- Gate Collapse: destabilize → crack → glitch/chromatic-aberration flicker → red flash → ledger summary (§Flow 08).
- AI Coach reply: decrypt/typewriter reveal, ~2 characters per frame, cursor caret visible until resolved.
- Panel first-appearance on hero screens: one-shot scanline sweep, 280ms.

---

## 9. Figma File Organization (deliverable requirements)

- **Pages**, in order: `Cover` · `Foundations` (color/type/spacing/elevation/motion tokens as the tables in §3) · `Components` · then one page per flow in the §6 order, named `00 – System Access`, `01 – Awakening`, etc.
- Use **Figma variables** for every color and spacing token in §3 — no hard-coded hex or raw pixel values on any layer.
- Every reusable element (§4) built as a **component with documented variants** for its states (§3.5), not duplicated frames.
- **Auto-layout** on every panel/list/card with correct hug/fill resizing so content changes don't break the design.
- Icons as vector (not raster), unified 24px grid, 1.5px stroke.
- A short **redline/spec** annotation on each Foundations token and each Component variant (padding, gaps, exact sizes) — this doc should be usable by an engineer without a follow-up meeting.
- Safe-area (notch + home indicator) respected on every full-bleed frame.
- Export marked at @1x/@2x/@3x for any screenshot-style assets.

---

## 10. Guardrails — what NOT to do

- Don't introduce new hues outside the token table in §3.1 — if something needs a new color, you've misread the brief.
- Don't let the hacker layer dominate — it's a texture and a handful of signature moments (Boot, Gate Collapse, AI Coach), not a new theme on every screen.
- Don't use literal "0/1" Matrix rain, magenta/purple cyberpunk gradients, or glitch-city neon skylines — that's a different, generic aesthetic and explicitly not this one.
- Don't flatten the ornamental filigree into plain rounded rectangles "for cleanliness" — polish means more considered ornamentation, not less.
- Don't add a 6th bottom-nav tab — nest new features (AI Coach, Notifications, Armory, Boss, Calendar, Guild, Mana Core, Settings) as secondary screens off the existing five, exactly as v1 intended.
- Don't ship a screen without its loading/empty/error states — an unfinished state is an unfinished screen.
- Don't use placeholder/lorem copy anywhere, including chart data, log entries, and chat transcripts — write real in-universe content for all of it.

---

## 11. Deliverable Statement

Produce the complete Figma file described above: every flow in §6 as fully designed, fully stated, fully componentized frames, sharing one design system, ready to hand directly to engineering. Prioritize internal consistency and finishing over adding scope beyond what's listed — every panel should look like it was pulled from the same System, whether it's showing you a quest, a boss, or the machinery underneath.

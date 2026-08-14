You are an elite mobile app UI/UX designer specializing in dark-fantasy sci-fi interfaces. Design a complete, high-fidelity, production-ready mobile app UI for an iOS app called ARISE — a gamified life/task manager where the user's real life is reskinned as a Hunter's "System" from the world of Solo Leveling, merged with Habitica's habit-building quest loop. Every screen must feel like it belongs to the same in-universe interface: a mysterious, omniscient "System" that issues quests, tracks stats, and enforces consequences. The design must be jaw-droppingly polished — no generic Material/iOS defaults anywhere. Use frames at 390×844 (iPhone 14/15 base), 8pt spacing grid, and produce every screen as a separate, fully fleshed-out high-fidelity frame (no lorem-ipsum placeholders — write real, in-universe copy for everything).
1. VISUAL IDENTITY & DESIGN SYSTEM
Tone: Ancient magic system meets holographic HUD. Ominous, epic, slightly cold and clinical (the System doesn't care about your feelings) but deeply rewarding when you win.
Color palette
Void background: radial gradient from #0B1330 (center) to #030712 (edges), always-dark theme only
Glass panel fill: #0A1A3A at 82% opacity with background blur (glassmorphism)
Primary glow / accent (Mana Cyan): #3EE6F5, secondary teal #1FA9C2
Text primary: #EAF6FF; text secondary/muted: #7FA0C9; text disabled: #3E5578
HP: gradient #FF5A36 → #C4171C (danger red-orange)
MP: gradient #2E9BFF → #1560C4
EXP / Gold rewards: gradient #FFD24C → #C98A1A
Buff / success green: #39FF88
Penalty / alert red: #FF2E4D, always paired with a slow pulse glow
Rank colors (used for quest difficulty & hunter rank, E→S): E #8A94A6 grey, D #39D98A green, C #2E9BFF blue, B #B26EFF purple, A #FF9B3E orange, S #FFD24C gold-red gradient with sparkle texture
Typography
Display/Headers: a tall, geometric condensed font (Rajdhani Bold or Orbitron), always uppercase, wide letter-spacing (+4%) — used for titles like "STATUS", "QUEST LOG"
Body: Inter or Rajdhani Medium, 15px, for descriptions
Numeric/stat readouts: a monospace/tabular font (Share Tech Mono) so numbers line up
Scale: Display 32/700, H1 24/700, H2 18/600, Body 15/500, Caption 12/600 (uppercase, +6% tracking)
Signature ornamental motifs (use consistently, not decoratively-random)
Thin (1.5px) cyan-glow border with 12px outer blur on every major panel, corners finished with a small Art-Nouveau filigree scroll flourish (matching the reference "System" window chrome) — reserve full ornate corners for hero moments (Status page, Level-Up modal, Onboarding); use a simpler clean glow-border on dense list screens so it stays readable
A faint animated circuit-line/mana-vein texture wash behind panels on System-heavy screens (Status, Focus Mode, Penalty)
Diamond (◆) section dividers, exactly like the reference Status sheet
Every modal/toast opens with a small "!" ALARM badge and bracketed System voice copy, e.g. [ Your rewards have arrived. ]
Progress bars are always pill-shaped, with a soft inner glow and a subtle scan-line shimmer animation
Icons: thin-line (1.5px stroke) geometric icon set — sword, shield, scroll, flame, eye, lightning — never filled/cartoon icons
Elevation & motion
Shadows are glows, not grey drop-shadows: colored blur matching the element's accent
Standard easing: fast-out-slow-in, 280ms for panels, 120ms for taps
Big moments (level up, quest complete, penalty triggered) get a full-screen flash + particle burst + screen-shake note in the prototype description
2. GLOBAL APP STRUCTURE
Bottom navigation (5 tabs, glowing cyan icon + label when active, muted grey-blue when inactive, floating glass pill bar with blur):
Home (crest icon) · Quests (scroll/sword) · Stats (shield) · Journal (open book) · Roadmap (map/constellation)
Top status bar (persistent on Home/Quests/Stats): compact HP pill, MP pill, current Level badge, and a small Mana-Core screen-time indicator, always visible so the user's "vitals" are always on screen.
Reusable "System Alert" component: centered glass card, ornate corners, "!" icon in a circle, bold uppercase title ("ALARM" / "NOTICE" / "WARNING"), body copy wrapped in brackets, color-coded keywords (green = positive/player, gold = reward, red = penalty). Used for every system-driven popup across the app.
3. SCREENS TO GENERATE
3.1 Awakening (Onboarding, 4 frames)
Boot sequence: black screen → flickering cyan text "...detecting Player..." → full-screen ornate System window: "YOU HAVE ACQUIRED THE QUALIFICATION TO BECOME A PLAYER." Then a short "Class Assessment" quiz (goal categories: Body / Mind / Craft / Discipline — user taps which stats matter most to them), then a name/title entry ("NAME:" / "PLAYER TITLE:"), ending on a dramatic "ARISE" full-screen button that transitions into Home.
3.2 Home / Dashboard
Top: greeting in System voice ("Welcome back, Hunter [Name]"), HP/MP pills, streak flame counter. Middle: "Today's Quests" horizontal card carousel (Daily/Main/Side badges by rank color), a large circular Focus Mode "Enter Gate" button, and a Mana-Core screen-time ring widget. Bottom: recent activity feed styled as System log lines ("[+120 EXP] Quest Cleared: Morning Run").
3.3 QUEST LIST (mandatory)
Segmented control at top: DAILY / MAIN / SIDE / ALL. Each quest is a card: left rank badge (E–S color), title in caps, one-line description, reward strip (EXP gem + gold coin + optional item icon), deadline countdown chip, and a circular progress ring / checkbox on the right. Overdue Daily Quests get a pulsing red hairline border and a small "PENALTY IMMINENT" tag. Main Quests are visually heavier (full-width ornate card, "S-RANK" glow) since they represent big life goals. Side Quests are compact, muted, collapsible list rows. Include an empty-state frame ("No quests remain. The System is watching.") and a "Daily Quest Reset" countdown banner pinned under the header (echoing the classic 100 push-ups/sit-ups/squats/10km run Daily Quest format — show one as a real example).
3.4 STAT / STATUS PAGE (mandatory)
Recreate the reference Status window faithfully: ornate cyan-filigree window chrome, "STATUS" display header, NAME / TITLE / JOB / LEVEL / FATIGUE fields, HP and MP pill bars with exact numeric readouts, diamond divider, then a two-column stat grid — STR, AGI, VIT, INT, PER (or SENSE) — each with a small line-icon, current value, and a tiny up/down spinner if unspent points remain. Below another diamond divider: active passive buffs as pill tags in green ("PHYSICAL DAMAGE REDUCTION 20% — ACTIVATING"). Bottom-right: bold "REMAINING POINTS: [n]" — tapping a stat's spinner opens a confirm micro-modal. Include a secondary "Title" selector modal (user unlocks titles like "Wolf Slayer" from completed quest chains) and a Hunter Rank badge (E→S) near the header.
3.5 JOURNAL PAGE (mandatory)
A reverse-chronological "Growth Log." Top: week/month toggle and a GitHub-style streak heat-map calendar (cyan intensity = quests completed that day). Each day expands into an entry: EXP gained that day (mini bar chart), list of quests cleared/failed, an optional mood/reflection text block ("Hunter's Log Entry"), and space for an attached proof photo thumbnail. Include a "New Entry" floating action button and a monthly summary card (total EXP, quests cleared, penalties incurred, current streak).
3.6 ROADMAP PAGE (mandatory)
Visualize long-term goals as a branching dungeon/constellation map: nodes connected by glowing path lines, fog-of-war darkening on locked future nodes, a bright pulsing node marking "You Are Here." Group branches by life category (Body / Mind / Craft / Discipline), each with its own accent color. Nodes unlock as cumulative EXP or quest-chains complete; boss-style larger nodes represent major milestones ("Run a Marathon," "Ship the App"). Include a node-detail bottom sheet showing requirements, rewards, and % progress when a node is tapped.
3.7 Focus Mode — "Gate Entry"
Full-screen immersive takeover: a swirling portal/gate visual, large countdown timer in the monospace stat font, ambient particle drift, and a single warning line: "Leaving the Gate before clearing it will trigger a Penalty." If the user backgrounds the app, show the exit-consequence frame: gate cracking/collapsing animation, red flash, "THE GATE HAS COLLAPSED" with streak/reward loss summary.
3.8 Penalty Screen
Triggered automatically when a Daily Quest is missed. Full red-glow takeover, cannot be dismissed without acknowledging: "PENALTY QUEST ASSIGNED" with the specific consequence (e.g., restricted app access, forced side-quest, stat/EXP deduction), a countdown to complete the penalty, and a grim System line: "There is no room for excuses."
3.9 Level Up Modal
Full-screen flash-to-cyan burst, "LEVEL UP!" in huge display type, old level → new level counter animation, newly unlocked stat points, any new title/skill unlocked, and a "Continue" button that mimics the ornate System window styling.
3.10 Rewards / Armory (Shop)
Spend earned gold on real-world rewards the user defined (e.g. "1hr guilt-free gaming," "Order takeout") shown as equip-able "items," plus cosmetic System-theme unlocks (new border themes, title frames). Grid of item cards with rank-colored rarity borders.
3.11 Calendar Sync ("Quest Schedule")
Google Calendar events reskinned as scheduled quests on a vertical day timeline; synced events show a small Google-calendar glyph and can be "accepted" as a quest (converting a meeting/deadline into EXP-bearing content). Include a connect/sync-status card at the top.
3.12 Guild / Party (Discord integration)
Friends' list restyled as a "Party," each member shown with mini stat bar, level, and rank badge; a live leaderboard; a "Raid" section for shared/group quests; a Discord-connect card showing linked server and a toggle for posting achievements to a Discord channel.
3.13 Mana Core (Screen-Time Economy)
A large glowing orb/ring visualizing daily "Mana" — drains in real time based on tracked screen time in distracting apps, refills from completed quests. When Mana hits zero, distracting apps are restricted (show this as a lock-icon overlay state). Include a breakdown list of today's mana drain by app and a projection line ("Mana runs out in 2h14m at current pace").
3.14 Settings / System Config
Standard-feeling but reskinned as "System Configuration": account, notification/alarm preferences, calendar & Discord connection management, penalty severity slider, theme/border variants, data export.
4. MICRO-INTERACTION NOTES (for prototype linking)
Completing a quest: checkbox morphs into a burst of cyan particles + EXP bar fills with a satisfying overshoot bounce + small toast "[+EXP] Quest Cleared."
Stat point allocation: tap-and-hold on the spinner ticks the number up with a soft haptic-style pulse animation.
Streak flame grows visually (small → roaring) as consecutive days increase.
Penalty entry: subtle screen-shake keyframe + red vignette fade-in.
5. DELIVERABLE
Produce every screen listed in Section 3 as a distinct, fully designed frame using the shared design system above, plus a component page documenting the reusable System Alert, Quest Card, Stat Row, and Nav Bar components. Prioritize polish and internal consistency over quantity — every panel should look like it was ripped from the same in-universe System.
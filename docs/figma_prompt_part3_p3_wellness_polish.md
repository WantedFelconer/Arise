# 🛡️ PROMPT 3 (PRIORITY 3) — WELLNESS, AUDIO, INTEGRATIONS & SYSTEM POLISH

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

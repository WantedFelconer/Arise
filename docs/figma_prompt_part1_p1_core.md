# 🚀 PROMPT 1 (PRIORITY 1) — CORE PRODUCTIVITY LOOP & DAILY DRIVERS

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

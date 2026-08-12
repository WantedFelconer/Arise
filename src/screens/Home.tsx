import { useState } from 'react'
import { GlassCard, RankBadge, RewardChip, SectionHeader, ProgressBar } from '../components/SystemUI'
import type { PlayerData } from '../App'

type Props = {
  player: PlayerData
  onEnterFocus: () => void
  onNavigate: (screen: string) => void
}

const TODAY_QUESTS = [
  { id: 1, rank: 'B', title: '100 PUSH-UPS', type: 'DAILY', exp: 80, deadline: '23:14', done: false },
  { id: 2, rank: 'B', title: '100 SIT-UPS', type: 'DAILY', exp: 80, deadline: '23:14', done: true },
  { id: 3, rank: 'A', title: 'SHIP FEATURE v2.4', type: 'MAIN', exp: 500, deadline: '3D', done: false },
  { id: 4, rank: 'C', title: 'READ 30 MINUTES', type: 'SIDE', exp: 40, deadline: '23:14', done: false },
  { id: 5, rank: 'B', title: '10KM RUN', type: 'DAILY', exp: 120, deadline: '23:14', done: false },
]

const LOG_LINES = [
  { type: 'exp', text: '[+120 EXP] Quest Cleared: Morning Run', time: '08:32' },
  { type: 'gold', text: '[+50 GOLD] Daily Login Bonus', time: '07:00' },
  { type: 'penalty', text: '[−30 EXP] Missed: Evening Meditation', time: 'YESTERDAY' },
  { type: 'exp', text: '[+200 EXP] Quest Cleared: Cold Shower Protocol', time: 'YESTERDAY' },
  { type: 'level', text: '[LEVEL UP] Reached Level 14', time: '2 DAYS AGO' },
]

export default function Home({ player, onEnterFocus, onNavigate }: Props) {
  const [completedIds, setCompletedIds] = useState<number[]>([2])

  function toggleQuest(id: number) {
    setCompletedIds(prev =>
      prev.includes(id) ? prev.filter(i => i !== id) : [...prev, id]
    )
  }

  const doneCount = completedIds.length
  const totalCount = TODAY_QUESTS.length

  return (
    <div className="flex flex-col h-full overflow-y-auto void-bg" style={{ paddingTop: 76, paddingBottom: 80 }}>
      <div className="px-4 space-y-4">

        {/* ── GREETING ── */}
        <div className="pt-3">
          <p className="font-mono-stat" style={{ fontSize: 11, color: '#3E5578' }}>
            [ SYSTEM ONLINE — {new Date().toLocaleDateString('en-US', { weekday: 'short', month: 'short', day: 'numeric' }).toUpperCase()} ]
          </p>
          <h1 className="font-orbitron font-bold uppercase mt-1" style={{ fontSize: 20, color: '#EAF6FF', letterSpacing: '0.05em' }}>
            WELCOME BACK,<br />
            <span style={{ color: '#3EE6F5' }}>HUNTER {player.name.toUpperCase()}</span>
          </h1>
          <p className="font-rajdhani mt-0.5" style={{ fontSize: 13, color: '#7FA0C9' }}>
            {player.title} · Rank {player.rank}
          </p>
        </div>

        {/* ── EXP BAR ── */}
        <GlassCard className="p-3">
          <div className="flex items-center justify-between mb-2">
            <span className="font-orbitron font-bold" style={{ fontSize: 11, color: '#FFD24C', letterSpacing: '0.08em' }}>
              LEVEL {player.level}
            </span>
            <span className="font-mono-stat" style={{ fontSize: 10, color: '#7FA0C9' }}>
              {player.exp.toLocaleString()} / {player.maxExp.toLocaleString()} EXP
            </span>
          </div>
          <ProgressBar value={player.exp} max={player.maxExp} variant="exp" height={8} />
          <p className="font-mono-stat mt-1.5" style={{ fontSize: 9, color: '#3E5578' }}>
            {(player.maxExp - player.exp).toLocaleString()} EXP TO LEVEL {player.level + 1}
          </p>
        </GlassCard>

        {/* ── TODAY'S QUESTS ── */}
        <div>
          <SectionHeader
            title="TODAY'S QUESTS"
            right={
              <div className="flex items-center gap-2">
                <span className="font-mono-stat" style={{ fontSize: 10, color: '#7FA0C9' }}>
                  {doneCount}/{totalCount}
                </span>
                <button onClick={() => onNavigate('quests')} style={{ color: '#3EE6F5', fontSize: 11 }}>
                  VIEW ALL →
                </button>
              </div>
            }
          />

          {/* Daily reset countdown */}
          <div
            className="rounded-lg px-3 py-2 mb-3 flex items-center justify-between"
            style={{ background: 'rgba(62,230,245,0.05)', border: '1px solid rgba(62,230,245,0.15)' }}
          >
            <span className="font-orbitron uppercase tracking-system" style={{ fontSize: 9, color: '#7FA0C9' }}>
              DAILY RESET
            </span>
            <span className="font-mono-stat" style={{ fontSize: 13, color: '#3EE6F5' }}>
              23:14:07
            </span>
          </div>

          {/* Horizontal quest card scroll */}
          <div className="flex gap-3 overflow-x-auto pb-2" style={{ scrollbarWidth: 'none' }}>
            {TODAY_QUESTS.map(q => {
              const done = completedIds.includes(q.id)
              const overdue = q.rank === 'B' && q.id === 5
              return (
                <div
                  key={q.id}
                  className="flex-shrink-0 glass-panel rounded-xl p-3"
                  style={{
                    width: 160, minHeight: 110,
                    border: overdue ? '1px solid rgba(255,46,77,0.6)' : '1px solid rgba(62,230,245,0.15)',
                    boxShadow: overdue ? '0 0 12px rgba(255,46,77,0.2)' : 'none',
                    animation: overdue ? 'pulse-danger 2s infinite' : 'none',
                    opacity: done ? 0.55 : 1,
                  }}
                >
                  <div className="flex items-center justify-between mb-2">
                    <RankBadge rank={q.rank} size="sm" />
                    <span
                      className="font-mono-stat rounded-full px-1.5"
                      style={{
                        fontSize: 8, color: q.type === 'DAILY' ? '#3EE6F5' : q.type === 'MAIN' ? '#FFD24C' : '#B26EFF',
                        background: q.type === 'DAILY' ? 'rgba(62,230,245,0.1)' : q.type === 'MAIN' ? 'rgba(255,210,76,0.1)' : 'rgba(178,110,255,0.1)',
                        border: '1px solid currentColor',
                      }}
                    >
                      {q.type}
                    </span>
                  </div>
                  <p className="font-orbitron font-bold uppercase mb-2" style={{ fontSize: 11, color: done ? '#3E5578' : '#EAF6FF', lineHeight: 1.2 }}>
                    {q.title}
                  </p>
                  {overdue && !done && (
                    <p className="font-mono-stat mb-1" style={{ fontSize: 8, color: '#FF2E4D' }}>⚠ PENALTY IMMINENT</p>
                  )}
                  <div className="flex items-center justify-between mt-auto">
                    <span className="font-mono-stat" style={{ fontSize: 9, color: '#FFD24C' }}>+{q.exp} EXP</span>
                    <button
                      onClick={() => toggleQuest(q.id)}
                      className="w-6 h-6 rounded-full flex items-center justify-center transition-all active:scale-90"
                      style={{
                        border: done ? '2px solid #39FF88' : '2px solid rgba(62,230,245,0.4)',
                        background: done ? 'rgba(57,255,136,0.2)' : 'transparent',
                        color: done ? '#39FF88' : 'transparent',
                      }}
                    >
                      {done && <span style={{ fontSize: 10 }}>✓</span>}
                    </button>
                  </div>
                </div>
              )
            })}
          </div>
        </div>

        {/* ── FOCUS MODE / ENTER GATE ── */}
        <div>
          <SectionHeader title="GATE ACCESS" />
          <button
            onClick={onEnterFocus}
            className="w-full rounded-xl overflow-hidden relative transition-all active:scale-98"
            style={{ height: 120 }}
          >
            <div className="absolute inset-0 void-bg-full circuit-overlay" />
            {/* Rotating rings */}
            <div className="absolute inset-0 flex items-center justify-center">
              {[70, 95].map((s, i) => (
                <div
                  key={i}
                  className="absolute rounded-full"
                  style={{
                    width: s, height: s,
                    border: `1.5px solid rgba(62,230,245,${0.4 - i * 0.15})`,
                    animation: `portal-spin ${6 + i * 4}s linear infinite`,
                    animationDirection: i % 2 === 0 ? 'normal' : 'reverse',
                  }}
                />
              ))}
              <div
                className="w-12 h-12 rounded-full flex items-center justify-center"
                style={{
                  background: 'radial-gradient(circle, rgba(62,230,245,0.4) 0%, rgba(62,230,245,0.05) 70%)',
                  boxShadow: '0 0 24px rgba(62,230,245,0.5)',
                }}
              >
                <span style={{ fontSize: 20 }}>⬡</span>
              </div>
            </div>
            {/* Text overlay */}
            <div className="absolute inset-0 flex flex-col items-end justify-center pr-5">
              <p className="font-mono-stat" style={{ fontSize: 9, color: '#7FA0C9' }}>ENTER THE</p>
              <p className="font-orbitron font-bold uppercase" style={{ fontSize: 18, color: '#3EE6F5', letterSpacing: '0.1em' }}>GATE</p>
              <p className="font-rajdhani" style={{ fontSize: 11, color: '#7FA0C9' }}>Focus Mode · No Escape</p>
            </div>
            {/* Border */}
            <div className="absolute inset-0 rounded-xl" style={{ border: '1px solid rgba(62,230,245,0.3)', boxShadow: '0 0 16px rgba(62,230,245,0.1)' }} />
          </button>
        </div>

        {/* ── MANA CORE WIDGET ── */}
        <GlassCard className="p-4">
          <div className="flex items-center justify-between mb-2">
            <SectionHeader title="MANA CORE" />
            <button onClick={() => onNavigate('manacore')} style={{ color: '#3EE6F5', fontSize: 11 }}>DETAILS →</button>
          </div>
          <div className="flex items-center gap-4">
            <ManaRing value={0.65} size={72} />
            <div className="flex-1">
              <p className="font-orbitron font-bold" style={{ fontSize: 16, color: '#3EE6F5' }}>65%</p>
              <p className="font-rajdhani" style={{ fontSize: 12, color: '#7FA0C9' }}>Mana Remaining</p>
              <p className="font-mono-stat mt-1" style={{ fontSize: 9, color: '#FF9B3E' }}>
                ⚠ Depletes in 2h 14m at current pace
              </p>
            </div>
          </div>
        </GlassCard>

        {/* ── QUICK ACTIONS ── */}
        <div className="grid grid-cols-3 gap-2">
          {[
            { label: 'ARMORY', icon: '⚔', color: '#B26EFF', screen: 'armory' },
            { label: 'GUILD', icon: '◈', color: '#39D98A', screen: 'guild' },
            { label: 'CALENDAR', icon: '◆', color: '#FF9B3E', screen: 'calendar' },
            { label: 'AI COACH', icon: '◈', color: '#3EE6F5', screen: 'aicoach' },
            { label: 'BOSS RAID', icon: '⚔', color: '#FF5A36', screen: 'boss' },
            { label: 'ALERTS', icon: '◉', color: '#FFD24C', screen: 'notifications' },
          ].map(a => (
            <button
              key={a.label}
              onClick={() => onNavigate(a.screen)}
              className="glass-panel rounded-xl py-3 flex flex-col items-center gap-1 transition-all active:scale-95"
              style={{ border: `1px solid ${a.color}25` }}
            >
              <span style={{ fontSize: 20 }}>{a.icon}</span>
              <span className="font-orbitron font-bold tracking-system" style={{ fontSize: 8, color: a.color }}>
                {a.label}
              </span>
            </button>
          ))}
        </div>

        {/* ── SYSTEM LOG ── */}
        <div>
          <SectionHeader title="SYSTEM LOG" />
          <div className="space-y-2">
            {LOG_LINES.map((line, i) => {
              const color = line.type === 'exp' ? '#39FF88' : line.type === 'gold' ? '#FFD24C' : line.type === 'penalty' ? '#FF2E4D' : '#3EE6F5'
              return (
                <div key={i} className="flex items-start gap-2 system-log">
                  <span style={{ color, whiteSpace: 'nowrap', flexShrink: 0 }}>{line.time}</span>
                  <span style={{ color: '#7FA0C9' }}>{line.text}</span>
                </div>
              )
            })}
          </div>
        </div>

      </div>
    </div>
  )
}

function ManaRing({ value, size }: { value: number; size: number }) {
  const r = (size - 8) / 2
  const circ = 2 * Math.PI * r
  return (
    <svg width={size} height={size} className="flex-shrink-0">
      <defs>
        <linearGradient id="mana-grad" x1="0%" y1="0%" x2="100%" y2="0%">
          <stop offset="0%" stopColor="#3EE6F5" />
          <stop offset="100%" stopColor="#1FA9C2" />
        </linearGradient>
      </defs>
      <circle cx={size/2} cy={size/2} r={r} fill="none" stroke="rgba(62,230,245,0.1)" strokeWidth="7" />
      <circle
        cx={size/2} cy={size/2} r={r} fill="none"
        stroke="url(#mana-grad)" strokeWidth="7"
        strokeDasharray={circ} strokeDashoffset={circ * (1 - value)}
        strokeLinecap="round"
        transform={`rotate(-90 ${size/2} ${size/2})`}
        style={{ filter: 'drop-shadow(0 0 4px rgba(62,230,245,0.7))' }}
      />
      <text x={size/2} y={size/2 + 4} textAnchor="middle" fill="#3EE6F5"
        fontFamily="'Share Tech Mono'" fontSize="11" fontWeight="700">
        {Math.round(value * 100)}%
      </text>
    </svg>
  )
}

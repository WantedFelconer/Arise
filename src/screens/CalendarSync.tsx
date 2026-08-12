import { useState } from 'react'
import { GlassCard, RankBadge, DiamondDivider } from '../components/SystemUI'

const EVENTS = [
  { id: 1, title: 'Team Standup', time: '09:00', duration: '30m', type: 'meeting', accepted: true, exp: 40 },
  { id: 2, title: 'Project Deadline: v2.4 Launch', time: '17:00', duration: 'ALL DAY', type: 'deadline', accepted: true, exp: 200 },
  { id: 3, title: 'Doctor Appointment', time: '11:30', duration: '1h', type: 'personal', accepted: false, exp: 60 },
  { id: 4, title: 'Code Review Session', time: '14:00', duration: '1h 30m', type: 'meeting', accepted: true, exp: 80 },
  { id: 5, title: 'Dentist', time: '16:30', duration: '45m', type: 'personal', accepted: false, exp: 50 },
]

const TYPE_RANK: Record<string, string> = { meeting: 'D', deadline: 'A', personal: 'C' }
const TYPE_COLOR: Record<string, string> = { meeting: '#2E9BFF', deadline: '#FF9B3E', personal: '#39D98A' }

export default function CalendarSync() {
  const [connected] = useState(true)
  const [acceptedIds, setAcceptedIds] = useState<number[]>([1, 2, 4])

  function toggleAccept(id: number) {
    setAcceptedIds(prev => prev.includes(id) ? prev.filter(i => i !== id) : [...prev, id])
  }

  const today = new Date().toLocaleDateString('en-US', { weekday: 'long', month: 'long', day: 'numeric' }).toUpperCase()

  return (
    <div className="flex flex-col h-full void-bg overflow-y-auto" style={{ paddingTop: 52, paddingBottom: 20 }}>
      <div className="px-4 pt-3 space-y-4">

        {/* Header */}
        <div>
          <p className="font-mono-stat" style={{ fontSize: 10, color: '#3E5578' }}>[ QUEST SCHEDULE — CALENDAR SYNC ]</p>
          <h1 className="font-orbitron font-bold uppercase" style={{ fontSize: 22, color: '#EAF6FF', letterSpacing: '0.05em' }}>
            SCHEDULE
          </h1>
        </div>

        {/* Sync status card */}
        <GlassCard
          className="p-4"
          style={{ border: `1px solid ${connected ? 'rgba(57,217,138,0.3)' : 'rgba(255,46,77,0.3)'}` }}
        >
          <div className="flex items-center gap-3">
            <div
              className="w-10 h-10 rounded-xl flex items-center justify-center flex-shrink-0"
              style={{ background: connected ? 'rgba(57,217,138,0.1)' : 'rgba(255,46,77,0.1)', border: `1px solid ${connected ? 'rgba(57,217,138,0.3)' : 'rgba(255,46,77,0.3)'}` }}
            >
              <span style={{ fontSize: 20 }}>{connected ? '📅' : '◉'}</span>
            </div>
            <div className="flex-1">
              <p className="font-orbitron font-bold uppercase" style={{ fontSize: 12, color: '#EAF6FF' }}>
                GOOGLE CALENDAR
              </p>
              <p className="font-rajdhani" style={{ fontSize: 11, color: connected ? '#39D98A' : '#FF2E4D' }}>
                {connected ? '● Connected — Last synced 5 minutes ago' : '○ Not connected'}
              </p>
            </div>
            <button
              className="font-orbitron font-bold uppercase tracking-system px-3 py-1.5 rounded-lg transition-all active:scale-95"
              style={{ fontSize: 8, border: `1px solid ${connected ? 'rgba(57,217,138,0.4)' : 'rgba(62,230,245,0.4)'}`, color: connected ? '#39D98A' : '#3EE6F5', background: connected ? 'rgba(57,217,138,0.05)' : 'rgba(62,230,245,0.05)' }}
            >
              {connected ? 'SYNC NOW' : 'CONNECT'}
            </button>
          </div>
        </GlassCard>

        {/* Date header */}
        <div className="flex items-center gap-2">
          <div className="h-px flex-1" style={{ background: 'rgba(62,230,245,0.2)' }} />
          <span className="font-mono-stat" style={{ fontSize: 9, color: '#3EE6F5' }}>{today}</span>
          <div className="h-px flex-1" style={{ background: 'rgba(62,230,245,0.2)' }} />
        </div>

        {/* Time label */}
        <p className="font-rajdhani" style={{ fontSize: 12, color: '#7FA0C9' }}>
          [ Accept calendar events to convert them into EXP-bearing quests. ]
        </p>

        {/* Vertical timeline */}
        <div className="relative">
          {/* Timeline line */}
          <div className="absolute left-8 top-0 bottom-0 w-px" style={{ background: 'rgba(62,230,245,0.15)' }} />

          <div className="space-y-2">
            {EVENTS.map(ev => {
              const accepted = acceptedIds.includes(ev.id)
              const color = TYPE_COLOR[ev.type] ?? '#3EE6F5'
              return (
                <div key={ev.id} className="flex gap-4 relative">
                  {/* Time dot */}
                  <div className="flex flex-col items-center flex-shrink-0 w-12">
                    <span className="font-mono-stat" style={{ fontSize: 9, color: '#7FA0C9' }}>{ev.time}</span>
                    <div
                      className="w-2.5 h-2.5 rounded-full mt-1 flex-shrink-0"
                      style={{
                        background: accepted ? color : 'rgba(62,230,245,0.2)',
                        boxShadow: accepted ? `0 0 6px ${color}` : 'none',
                        border: `1.5px solid ${accepted ? color : 'rgba(62,230,245,0.3)'}`,
                      }}
                    />
                  </div>

                  {/* Event card */}
                  <div
                    className="flex-1 glass-panel rounded-xl p-3 mb-1"
                    style={{
                      border: accepted ? `1px solid ${color}40` : '1px solid rgba(62,230,245,0.1)',
                      background: accepted ? `${color}05` : undefined,
                    }}
                  >
                    <div className="flex items-start justify-between gap-2">
                      <div className="flex-1">
                        <div className="flex items-center gap-2 mb-1">
                          <RankBadge rank={TYPE_RANK[ev.type] ?? 'E'} size="sm" />
                          <span className="font-mono-stat rounded px-1.5"
                            style={{ fontSize: 7, color, background: `${color}10`, border: `1px solid ${color}20` }}>
                            {ev.type.toUpperCase()}
                          </span>
                        </div>
                        <p className="font-orbitron font-bold uppercase" style={{ fontSize: 11, color: '#EAF6FF', lineHeight: 1.3 }}>
                          {ev.title}
                        </p>
                        <div className="flex items-center gap-2 mt-1">
                          <span className="font-mono-stat" style={{ fontSize: 9, color: '#3E5578' }}>⏱ {ev.duration}</span>
                          <span className="font-mono-stat" style={{ fontSize: 9, color: '#FFD24C' }}>+{ev.exp} EXP if cleared</span>
                        </div>
                      </div>

                      {/* Accept toggle */}
                      <button
                        onClick={() => toggleAccept(ev.id)}
                        className="flex-shrink-0 px-2.5 py-1.5 rounded-lg font-orbitron font-bold uppercase tracking-system transition-all active:scale-90"
                        style={{
                          fontSize: 8,
                          background: accepted ? `${color}15` : 'transparent',
                          border: `1px solid ${accepted ? color : 'rgba(62,230,245,0.2)'}`,
                          color: accepted ? color : '#3E5578',
                        }}
                      >
                        {accepted ? '✓ QUEST' : 'ACCEPT'}
                      </button>
                    </div>

                    {/* Google Cal glyph */}
                    <div className="flex items-center gap-1 mt-1.5">
                      <span style={{ fontSize: 8 }}>📅</span>
                      <span className="font-mono-stat" style={{ fontSize: 7, color: '#3E5578' }}>Google Calendar</span>
                    </div>
                  </div>
                </div>
              )
            })}
          </div>
        </div>

        <DiamondDivider />

        <div className="text-center">
          <p className="font-mono-stat" style={{ fontSize: 10, color: '#39D98A' }}>
            {acceptedIds.length} EVENTS CONVERTED TO QUESTS
          </p>
          <p className="font-mono-stat" style={{ fontSize: 9, color: '#3E5578' }}>
            POTENTIAL: +{acceptedIds.reduce((sum, id) => sum + (EVENTS.find(e => e.id === id)?.exp ?? 0), 0)} EXP TODAY
          </p>
        </div>

      </div>
    </div>
  )
}

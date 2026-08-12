import { useState } from 'react'
import { RankBadge, GlassCard, DiamondDivider, SectionHeader } from '../components/SystemUI'

const PARTY_MEMBERS = [
  { id: 1, name: 'KIRA', title: 'The Ironclad', rank: 'B', level: 18, hp: 85, exp: 72, streak: 22, online: true, score: 2840 },
  { id: 2, name: 'JIN-SOO', title: 'Shadow Walker', rank: 'A', level: 23, hp: 92, exp: 88, streak: 31, online: true, score: 4120 },
  { id: 3, name: 'MIRAE', title: 'The Scholar', rank: 'C', level: 12, hp: 60, exp: 45, streak: 8, online: false, score: 1480 },
  { id: 4, name: 'CHUL-SU', title: 'Crimson Blade', rank: 'B', level: 16, hp: 78, exp: 63, streak: 14, online: false, score: 2190 },
]

const RAID_QUESTS = [
  { id: 1, name: 'PARTY RUN — 50KM WEEK', rank: 'A', desc: '4 members must collectively run 50km this week.', progress: 37, target: 50, unit: 'km', reward: 800 },
  { id: 2, name: 'GUILD DEEP WORK', rank: 'B', desc: 'Each member completes 4 focused sessions this week.', progress: 10, target: 16, unit: 'sessions', reward: 500 },
]

export default function Guild() {
  const [tab, setTab] = useState<'party' | 'leaderboard' | 'raids'>('party')
  const [discordConnected] = useState(true)

  const sorted = [...PARTY_MEMBERS].sort((a, b) => b.score - a.score)

  return (
    <div className="flex flex-col h-full void-bg overflow-y-auto" style={{ paddingTop: 52, paddingBottom: 20 }}>
      <div className="px-4 pt-3 space-y-3">

        {/* Header */}
        <div className="flex items-start justify-between">
          <div>
            <p className="font-mono-stat" style={{ fontSize: 10, color: '#3E5578' }}>[ PARTY INTERFACE ]</p>
            <h1 className="font-orbitron font-bold uppercase" style={{ fontSize: 22, color: '#EAF6FF', letterSpacing: '0.05em' }}>
              GUILD
            </h1>
          </div>
          {/* Discord connect card */}
          <div
            className="glass-panel rounded-xl px-3 py-2"
            style={{ border: `1px solid ${discordConnected ? 'rgba(57,217,138,0.3)' : 'rgba(62,230,245,0.2)'}` }}
          >
            <p className="font-mono-stat" style={{ fontSize: 7, color: '#7FA0C9' }}>DISCORD</p>
            <p className="font-orbitron font-bold" style={{ fontSize: 9, color: discordConnected ? '#39D98A' : '#3E5578' }}>
              {discordConnected ? '● LINKED' : '○ CONNECT'}
            </p>
          </div>
        </div>

        {/* Discord server info */}
        {discordConnected && (
          <div className="glass-panel rounded-xl p-3 flex items-center gap-3" style={{ border: '1px solid rgba(57,217,138,0.2)' }}>
            <div className="w-10 h-10 rounded-xl flex items-center justify-center flex-shrink-0" style={{ background: 'rgba(57,217,138,0.15)', border: '1px solid rgba(57,217,138,0.3)' }}>
              <span style={{ fontSize: 18 }}>◆</span>
            </div>
            <div className="flex-1">
              <p className="font-orbitron font-bold uppercase" style={{ fontSize: 11, color: '#EAF6FF' }}>
                ARISE HUNTERS #general
              </p>
              <p className="font-rajdhani" style={{ fontSize: 11, color: '#7FA0C9' }}>4 members · Achievements posted automatically</p>
            </div>
            <div className="w-2 h-2 rounded-full animate-pulse-cyan" style={{ background: '#39FF88' }} />
          </div>
        )}

        {/* Tabs */}
        <div className="flex glass-panel rounded-xl overflow-hidden" style={{ border: '1px solid rgba(62,230,245,0.15)' }}>
          {(['party', 'leaderboard', 'raids'] as const).map(t => (
            <button key={t} onClick={() => setTab(t)}
              className="flex-1 py-2 font-orbitron font-bold uppercase tracking-system transition-all"
              style={{ fontSize: 8, color: tab === t ? '#3EE6F5' : '#3E5578', background: tab === t ? 'rgba(62,230,245,0.1)' : 'transparent', borderBottom: tab === t ? '2px solid #3EE6F5' : '2px solid transparent' }}>
              {t === 'raids' ? 'RAIDS' : t === 'party' ? 'PARTY' : 'BOARD'}
            </button>
          ))}
        </div>

        {/* PARTY TAB */}
        {tab === 'party' && (
          <div className="space-y-2">
            {PARTY_MEMBERS.map(m => (
              <GlassCard key={m.id} className="p-3" style={{ border: `1px solid ${m.online ? 'rgba(62,230,245,0.2)' : 'rgba(62,230,245,0.08)'}` }}>
                <div className="flex items-center gap-3">
                  {/* Avatar */}
                  <div className="relative flex-shrink-0">
                    <div
                      className="w-10 h-10 rounded-xl flex items-center justify-center font-orbitron font-bold"
                      style={{ background: 'rgba(62,230,245,0.1)', border: '1px solid rgba(62,230,245,0.25)', fontSize: 14, color: '#3EE6F5' }}
                    >
                      {m.name[0]}
                    </div>
                    <div
                      className="absolute bottom-0 right-0 w-3 h-3 rounded-full"
                      style={{ background: m.online ? '#39FF88' : '#3E5578', border: '2px solid #030712', boxShadow: m.online ? '0 0 4px #39FF88' : 'none' }}
                    />
                  </div>

                  {/* Info */}
                  <div className="flex-1 min-w-0">
                    <div className="flex items-center gap-1.5 mb-0.5">
                      <span className="font-orbitron font-bold uppercase" style={{ fontSize: 12, color: '#EAF6FF' }}>{m.name}</span>
                      <RankBadge rank={m.rank} size="sm" />
                    </div>
                    <p className="font-rajdhani" style={{ fontSize: 10, color: '#7FA0C9' }}>{m.title} · LV.{m.level}</p>
                    <div className="flex items-center gap-2 mt-1">
                      {/* HP mini bar */}
                      <div className="flex items-center gap-1">
                        <span className="font-mono-stat" style={{ fontSize: 7, color: '#FF5A36' }}>HP</span>
                        <div className="w-14 h-1.5 rounded-full overflow-hidden" style={{ background: 'rgba(0,0,0,0.4)' }}>
                          <div className="h-full rounded-full" style={{ width: `${m.hp}%`, background: 'linear-gradient(90deg, #FF5A36, #C4171C)' }} />
                        </div>
                      </div>
                      <div className="flex items-center gap-1">
                        <span style={{ fontSize: 10 }}>🔥</span>
                        <span className="font-mono-stat" style={{ fontSize: 9, color: '#FF9B3E' }}>{m.streak}</span>
                      </div>
                    </div>
                  </div>

                  <div className="text-right flex-shrink-0">
                    <p className="font-mono-stat" style={{ fontSize: 12, color: '#FFD24C' }}>{m.score.toLocaleString()}</p>
                    <p className="font-mono-stat" style={{ fontSize: 7, color: '#3E5578' }}>SCORE</p>
                  </div>
                </div>
              </GlassCard>
            ))}
          </div>
        )}

        {/* LEADERBOARD TAB */}
        {tab === 'leaderboard' && (
          <div className="space-y-2">
            <p className="font-mono-stat text-center" style={{ fontSize: 9, color: '#3E5578' }}>[ WEEKLY RANKING — RESETS MON 00:00 ]</p>
            {sorted.map((m, i) => (
              <GlassCard key={m.id} className="p-3"
                style={{
                  border: i === 0 ? '1px solid rgba(255,210,76,0.4)' : '1px solid rgba(62,230,245,0.1)',
                  background: i === 0 ? 'rgba(255,210,76,0.04)' : undefined,
                }}
              >
                <div className="flex items-center gap-3">
                  <div className="w-8 h-8 rounded-lg flex items-center justify-center font-orbitron font-black flex-shrink-0"
                    style={{ background: i === 0 ? 'rgba(255,210,76,0.15)' : 'rgba(62,230,245,0.05)', color: i === 0 ? '#FFD24C' : i === 1 ? '#C0C0C0' : '#CD7F32', fontSize: i < 3 ? 16 : 13, border: `1px solid ${i === 0 ? 'rgba(255,210,76,0.4)' : 'rgba(62,230,245,0.1)'}` }}>
                    {i + 1}
                  </div>
                  <div className="flex-1">
                    <p className="font-orbitron font-bold uppercase" style={{ fontSize: 12, color: '#EAF6FF' }}>{m.name}</p>
                    <p className="font-mono-stat" style={{ fontSize: 9, color: '#7FA0C9' }}>{m.title}</p>
                  </div>
                  <div className="text-right">
                    <p className="font-mono-stat" style={{ fontSize: 14, color: i === 0 ? '#FFD24C' : '#EAF6FF' }}>
                      {m.score.toLocaleString()}
                    </p>
                    <RankBadge rank={m.rank} size="sm" />
                  </div>
                </div>
              </GlassCard>
            ))}
          </div>
        )}

        {/* RAIDS TAB */}
        {tab === 'raids' && (
          <div className="space-y-3">
            <SectionHeader title="ACTIVE RAIDS" />
            {RAID_QUESTS.map(r => {
              const pct = (r.progress / r.target) * 100
              return (
                <GlassCard key={r.id} className="p-4" style={{ border: '1px solid rgba(178,110,255,0.25)' }}>
                  <div className="flex items-center gap-2 mb-2">
                    <RankBadge rank={r.rank} size="sm" />
                    <p className="font-orbitron font-bold uppercase" style={{ fontSize: 12, color: '#EAF6FF' }}>{r.name}</p>
                  </div>
                  <p className="font-rajdhani mb-3" style={{ fontSize: 12, color: '#7FA0C9' }}>{r.desc}</p>
                  <div className="mb-1 flex justify-between">
                    <span className="font-mono-stat" style={{ fontSize: 9, color: '#7FA0C9' }}>PARTY PROGRESS</span>
                    <span className="font-mono-stat" style={{ fontSize: 9, color: '#EAF6FF' }}>
                      {r.progress} / {r.target} {r.unit}
                    </span>
                  </div>
                  <div className="h-2 rounded-full overflow-hidden mb-2" style={{ background: 'rgba(10,26,58,0.8)' }}>
                    <div className="h-full rounded-full" style={{ width: `${pct}%`, background: 'linear-gradient(90deg, #B26EFF, #7044CC)' }} />
                  </div>
                  <DiamondDivider />
                  <div className="flex items-center justify-between">
                    <p className="font-mono-stat" style={{ fontSize: 9, color: '#7FA0C9' }}>PARTY REWARD</p>
                    <p className="font-mono-stat" style={{ fontSize: 12, color: '#FFD24C' }}>+{r.reward} EXP EACH</p>
                  </div>
                </GlassCard>
              )
            })}
            <button className="w-full py-3 rounded-xl font-orbitron font-bold uppercase tracking-system transition-all active:scale-95"
              style={{ fontSize: 10, background: 'rgba(178,110,255,0.1)', border: '1px solid rgba(178,110,255,0.3)', color: '#B26EFF' }}>
              + PROPOSE NEW RAID
            </button>
          </div>
        )}

      </div>
    </div>
  )
}

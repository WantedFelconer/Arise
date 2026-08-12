import { GlassCard, DiamondDivider } from '../components/SystemUI'

const APP_BREAKDOWN = [
  { name: 'Instagram', drain: 48, limit: 30, icon: '📸', color: '#FF9B3E' },
  { name: 'YouTube', drain: 34, limit: 20, icon: '▶', color: '#FF2E4D' },
  { name: 'Reddit', drain: 22, limit: 15, icon: '◈', color: '#FF9B3E' },
  { name: 'Twitter/X', drain: 18, limit: 15, icon: '⚡', color: '#FFD24C' },
  { name: 'Discord', drain: 10, limit: 60, icon: '◆', color: '#39D98A' },
  { name: 'Notion (work)', drain: 35, limit: 120, icon: '◉', color: '#39FF88' },
]

const TOTAL_MANA = 100
const DRAINED = 35
const REMAINING = TOTAL_MANA - DRAINED

export default function ManaCore() {
  const SIZE = 200
  const R = 82
  const CIRC = 2 * Math.PI * R

  return (
    <div className="flex flex-col h-full void-bg overflow-y-auto" style={{ paddingTop: 52, paddingBottom: 20 }}>
      <div className="px-4 pt-3 space-y-4">

        {/* Header */}
        <div>
          <p className="font-mono-stat" style={{ fontSize: 10, color: '#3E5578' }}>[ MANA ECONOMY — SCREEN TIME ]</p>
          <h1 className="font-orbitron font-bold uppercase" style={{ fontSize: 22, color: '#EAF6FF', letterSpacing: '0.05em' }}>
            MANA CORE
          </h1>
        </div>

        {/* Main ring */}
        <GlassCard className="p-4 flex flex-col items-center">
          <div className="relative flex items-center justify-center" style={{ width: SIZE, height: SIZE }}>
            {/* Rotating decorator ring */}
            <div className="absolute rounded-full" style={{
              width: SIZE - 10, height: SIZE - 10,
              border: '1px solid rgba(62,230,245,0.1)',
              animation: 'portal-spin 20s linear infinite',
            }} />

            <svg width={SIZE} height={SIZE} className="absolute">
              <defs>
                <linearGradient id="mana-core-grad" x1="0%" y1="0%" x2="100%" y2="0%">
                  <stop offset="0%" stopColor="#3EE6F5" />
                  <stop offset="100%" stopColor="#1FA9C2" />
                </linearGradient>
                <linearGradient id="mana-drain-grad" x1="0%" y1="0%" x2="100%" y2="0%">
                  <stop offset="0%" stopColor="#FF5A36" />
                  <stop offset="100%" stopColor="#C4171C" />
                </linearGradient>
              </defs>
              {/* Background track */}
              <circle cx={SIZE/2} cy={SIZE/2} r={R} fill="none" stroke="rgba(62,230,245,0.06)" strokeWidth="12" />
              {/* Drained portion */}
              <circle cx={SIZE/2} cy={SIZE/2} r={R} fill="none"
                stroke="url(#mana-drain-grad)" strokeWidth="12"
                strokeDasharray={CIRC} strokeDashoffset={CIRC * (1 - DRAINED / TOTAL_MANA)}
                strokeLinecap="round"
                transform={`rotate(-90 ${SIZE/2} ${SIZE/2})`}
                opacity="0.5"
              />
              {/* Remaining */}
              <circle cx={SIZE/2} cy={SIZE/2} r={R} fill="none"
                stroke="url(#mana-core-grad)" strokeWidth="12"
                strokeDasharray={CIRC * (REMAINING / TOTAL_MANA)} strokeDashoffset={0}
                strokeLinecap="round"
                transform={`rotate(-90 ${SIZE/2} ${SIZE/2})`}
                style={{ filter: 'drop-shadow(0 0 8px rgba(62,230,245,0.8))' }}
              />
            </svg>

            {/* Center text */}
            <div className="relative z-10 text-center">
              <p className="font-mono-stat" style={{ fontSize: 36, color: '#3EE6F5', textShadow: '0 0 20px rgba(62,230,245,0.6)' }}>
                {REMAINING}%
              </p>
              <p className="font-orbitron uppercase tracking-system" style={{ fontSize: 8, color: '#7FA0C9' }}>
                MANA REMAINING
              </p>
            </div>
          </div>

          <div className="flex gap-6 mt-2">
            <div className="text-center">
              <p className="font-mono-stat" style={{ fontSize: 16, color: '#3EE6F5' }}>{REMAINING}%</p>
              <p className="font-mono-stat" style={{ fontSize: 8, color: '#7FA0C9' }}>AVAILABLE</p>
            </div>
            <div className="w-px" style={{ background: 'rgba(62,230,245,0.2)' }} />
            <div className="text-center">
              <p className="font-mono-stat" style={{ fontSize: 16, color: '#FF5A36' }}>{DRAINED}%</p>
              <p className="font-mono-stat" style={{ fontSize: 8, color: '#7FA0C9' }}>CONSUMED</p>
            </div>
          </div>
        </GlassCard>

        {/* Warning projection */}
        <div
          className="rounded-xl px-4 py-3 flex items-center gap-3"
          style={{ background: 'rgba(255,155,62,0.08)', border: '1px solid rgba(255,155,62,0.3)' }}
        >
          <span style={{ fontSize: 20 }}>⚠</span>
          <div>
            <p className="font-orbitron font-bold uppercase" style={{ fontSize: 11, color: '#FF9B3E' }}>
              MANA DEPLETES IN 2H 14M
            </p>
            <p className="font-rajdhani" style={{ fontSize: 12, color: '#7FA0C9' }}>
              At current consumption rate. Reduce drain to preserve focus.
            </p>
          </div>
        </div>

        <DiamondDivider />

        {/* App breakdown */}
        <div>
          <p className="font-orbitron font-bold uppercase tracking-wide-2 mb-3" style={{ fontSize: 12, color: '#EAF6FF' }}>
            MANA DRAIN BY APP
          </p>
          <div className="space-y-2">
            {APP_BREAKDOWN.map((app, i) => {
              const overLimit = app.drain > app.limit
              const drainPct = Math.min(100, (app.drain / app.limit) * 100)
              return (
                <div key={i} className="glass-panel rounded-xl p-3" style={{ border: `1px solid ${overLimit ? 'rgba(255,46,77,0.3)' : 'rgba(62,230,245,0.1)'}` }}>
                  <div className="flex items-center justify-between mb-1.5">
                    <div className="flex items-center gap-2">
                      <span style={{ fontSize: 16 }}>{app.icon}</span>
                      <span className="font-rajdhani font-semibold" style={{ fontSize: 13, color: '#EAF6FF' }}>{app.name}</span>
                      {overLimit && (
                        <span className="font-mono-stat rounded px-1" style={{ fontSize: 7, color: '#FF2E4D', background: 'rgba(255,46,77,0.1)', border: '1px solid rgba(255,46,77,0.3)' }}>
                          OVER LIMIT
                        </span>
                      )}
                    </div>
                    <div className="text-right">
                      <span className="font-mono-stat" style={{ fontSize: 11, color: overLimit ? '#FF2E4D' : '#EAF6FF' }}>
                        {app.drain}m
                      </span>
                      <span className="font-mono-stat" style={{ fontSize: 9, color: '#3E5578' }}>/{app.limit}m</span>
                    </div>
                  </div>
                  <div className="h-1.5 rounded-full overflow-hidden" style={{ background: 'rgba(10,26,58,0.8)' }}>
                    <div
                      className="h-full rounded-full"
                      style={{
                        width: `${drainPct}%`,
                        background: overLimit
                          ? 'linear-gradient(90deg, #FF5A36, #C4171C)'
                          : app.drain < app.limit * 0.5
                          ? 'linear-gradient(90deg, #39FF88, #1aa855)'
                          : 'linear-gradient(90deg, #FFD24C, #C98A1A)',
                        transition: 'width 0.6s ease',
                      }}
                    />
                  </div>
                </div>
              )
            })}
          </div>
        </div>

        {/* Zero mana locked state info */}
        <GlassCard className="p-4" style={{ border: '1px solid rgba(255,46,77,0.2)' }}>
          <p className="font-orbitron font-bold uppercase mb-2" style={{ fontSize: 11, color: '#FF2E4D' }}>
            ⚠ MANA DEPLETION PROTOCOL
          </p>
          <p className="font-rajdhani" style={{ fontSize: 12, color: '#7FA0C9', lineHeight: 1.6 }}>
            When Mana reaches 0%, distracting applications are restricted by the System. Complete quests to restore Mana reserves.
          </p>
          <div className="mt-3 flex items-center gap-2 p-2 rounded-lg" style={{ background: 'rgba(255,46,77,0.05)', border: '1px solid rgba(255,46,77,0.15)' }}>
            <span style={{ fontSize: 16 }}>🔒</span>
            <span className="font-mono-stat" style={{ fontSize: 10, color: '#FF2E4D' }}>LOCK OVERLAY — ACTIVATES AT 0% MANA</span>
          </div>
        </GlassCard>

      </div>
    </div>
  )
}

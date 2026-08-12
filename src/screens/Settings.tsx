import { useState } from 'react'
import { GlassCard, DiamondDivider } from '../components/SystemUI'

export default function Settings({ onClose }: { onClose: () => void }) {
  const [notifications, setNotifications] = useState(true)
  const [penaltySeverity, setPenaltySeverity] = useState(2)
  const [discordPost, setDiscordPost] = useState(true)
  const [calSync, setCalSync] = useState(true)
  const [sound, setSound] = useState(true)
  const [theme, setTheme] = useState('void')

  const THEMES = [
    { id: 'void', label: 'VOID SOVEREIGN', color: '#3EE6F5' },
    { id: 'gold', label: 'GOLD MONARCH', color: '#FFD24C' },
    { id: 'shadow', label: 'SHADOW THRONE', color: '#B26EFF' },
  ]

  const SEVERITY_LABELS = ['LENIENT', 'STANDARD', 'BRUTAL', 'ASCETIC']

  return (
    <div className="flex flex-col h-full void-bg overflow-y-auto" style={{ paddingTop: 52, paddingBottom: 20 }}>
      <div className="px-4 pt-3 space-y-4">

        {/* Header */}
        <div className="flex items-center justify-between">
          <div>
            <p className="font-mono-stat" style={{ fontSize: 10, color: '#3E5578' }}>[ SYSTEM CONFIGURATION ]</p>
            <h1 className="font-orbitron font-bold uppercase" style={{ fontSize: 22, color: '#EAF6FF', letterSpacing: '0.05em' }}>
              SETTINGS
            </h1>
          </div>
          <button onClick={onClose} className="glass-panel rounded-full w-8 h-8 flex items-center justify-center transition-all active:scale-90"
            style={{ border: '1px solid rgba(62,230,245,0.2)', color: '#7FA0C9', fontSize: 16 }}>
            ✕
          </button>
        </div>

        {/* Account */}
        <Section title="ACCOUNT">
          <InfoRow label="HUNTER NAME" value="PLAYER ONE" />
          <InfoRow label="ACTIVE TITLE" value="WOLF SLAYER" />
          <InfoRow label="HUNTER RANK" value="B-RANK" valueColor="#B26EFF" />
          <InfoRow label="ACCOUNT ID" value="#4891-ARISE" valueColor="#3E5578" />
        </Section>

        {/* Notifications */}
        <Section title="ALARMS & NOTIFICATIONS">
          <ToggleRow label="QUEST REMINDERS" desc="Alert before daily reset" value={notifications} onChange={setNotifications} />
          <ToggleRow label="LEVEL UP ALERTS" desc="Full-screen notification" value={true} onChange={() => {}} />
          <ToggleRow label="PENALTY WARNINGS" desc="30 min before penalty triggers" value={true} onChange={() => {}} />
          <ToggleRow label="SYSTEM SOUNDS" desc="EXP gain & quest completion" value={sound} onChange={setSound} />
        </Section>

        {/* Penalty severity */}
        <Section title="PENALTY PROTOCOL">
          <div className="px-1">
            <div className="flex items-center justify-between mb-2">
              <span className="font-rajdhani" style={{ fontSize: 13, color: '#EAF6FF' }}>SEVERITY LEVEL</span>
              <span className="font-orbitron font-bold" style={{ fontSize: 12, color: penaltySeverity < 2 ? '#39D98A' : penaltySeverity === 2 ? '#FF9B3E' : '#FF2E4D' }}>
                {SEVERITY_LABELS[penaltySeverity]}
              </span>
            </div>
            <input
              type="range" min={0} max={3} value={penaltySeverity}
              onChange={e => setPenaltySeverity(Number(e.target.value))}
              className="w-full"
              style={{ accentColor: '#FF2E4D' }}
            />
            <div className="flex justify-between mt-1">
              {SEVERITY_LABELS.map((l, i) => (
                <span key={i} className="font-mono-stat" style={{ fontSize: 7, color: i === penaltySeverity ? '#FF2E4D' : '#3E5578' }}>
                  {l[0]}
                </span>
              ))}
            </div>
            <p className="font-rajdhani mt-2" style={{ fontSize: 11, color: '#7FA0C9' }}>
              {penaltySeverity === 0 && '[ Minimal consequences for missed quests. The System is merciful. ]'}
              {penaltySeverity === 1 && '[ Standard EXP deductions and penalty quests. The System is fair. ]'}
              {penaltySeverity === 2 && '[ Heavy penalties. Stat decay. App restrictions. The System is merciless. ]'}
              {penaltySeverity === 3 && '[ Maximum protocol. Full streak reset. The System shows no mercy. ]'}
            </p>
          </div>
        </Section>

        {/* Integrations */}
        <Section title="INTEGRATIONS">
          <ToggleRow label="GOOGLE CALENDAR SYNC" desc="Import events as scheduled quests" value={calSync} onChange={setCalSync} />
          <ToggleRow label="DISCORD ACHIEVEMENTS" desc="Post level-ups to linked server" value={discordPost} onChange={setDiscordPost} />
        </Section>

        {/* Theme */}
        <Section title="INTERFACE THEME">
          <div className="flex flex-col gap-2">
            {THEMES.map(t => (
              <button
                key={t.id}
                onClick={() => setTheme(t.id)}
                className="flex items-center gap-3 p-2 rounded-lg transition-all active:scale-98"
                style={{
                  background: theme === t.id ? `${t.color}10` : 'transparent',
                  border: `1px solid ${theme === t.id ? `${t.color}50` : 'rgba(62,230,245,0.08)'}`,
                }}
              >
                <div className="w-5 h-5 rounded flex items-center justify-center flex-shrink-0"
                  style={{ background: theme === t.id ? t.color : 'transparent', border: `2px solid ${t.color}` }}>
                  {theme === t.id && <span style={{ color: '#000', fontSize: 10 }}>✓</span>}
                </div>
                <span className="font-orbitron font-bold uppercase" style={{ fontSize: 10, color: theme === t.id ? t.color : '#7FA0C9' }}>
                  {t.label}
                </span>
              </button>
            ))}
          </div>
        </Section>

        <DiamondDivider />

        {/* Data export */}
        <GlassCard className="p-3" style={{ border: '1px solid rgba(62,230,245,0.1)' }}>
          <button className="w-full font-orbitron font-bold uppercase tracking-system transition-all active:scale-95"
            style={{ fontSize: 10, color: '#7FA0C9' }}>
            EXPORT HUNTER DATA →
          </button>
        </GlassCard>

        {/* Danger zone */}
        <GlassCard className="p-3" style={{ border: '1px solid rgba(255,46,77,0.2)' }}>
          <p className="font-mono-stat mb-2" style={{ fontSize: 9, color: '#3E5578' }}>[ DANGER ZONE ]</p>
          <button className="w-full font-orbitron font-bold uppercase tracking-system transition-all active:scale-95"
            style={{ fontSize: 10, color: '#FF2E4D' }}>
            RESET ALL DATA — PERMANENT
          </button>
        </GlassCard>

        <p className="font-mono-stat text-center" style={{ fontSize: 9, color: '#3E5578' }}>
          ARISE SYSTEM v2.4.1 · [ The System watches. Always. ]
        </p>
      </div>
    </div>
  )
}

function Section({ title, children }: { title: string; children: React.ReactNode }) {
  return (
    <div>
      <p className="font-orbitron uppercase tracking-system mb-2" style={{ fontSize: 9, color: '#3EE6F5', letterSpacing: '0.12em' }}>
        — {title}
      </p>
      <div className="glass-panel rounded-xl overflow-hidden" style={{ border: '1px solid rgba(62,230,245,0.12)' }}>
        {children}
      </div>
    </div>
  )
}

function ToggleRow({ label, desc, value, onChange }: { label: string; desc: string; value: boolean; onChange: (v: boolean) => void }) {
  return (
    <div className="flex items-center justify-between px-4 py-3">
      <div>
        <p className="font-rajdhani font-semibold" style={{ fontSize: 13, color: '#EAF6FF' }}>{label}</p>
        <p className="font-rajdhani" style={{ fontSize: 11, color: '#7FA0C9' }}>{desc}</p>
      </div>
      <button
        onClick={() => onChange(!value)}
        className="flex-shrink-0 w-11 h-6 rounded-full relative transition-all"
        style={{ background: value ? 'rgba(62,230,245,0.3)' : 'rgba(62,230,245,0.08)', border: `1px solid ${value ? 'rgba(62,230,245,0.5)' : 'rgba(62,230,245,0.15)'}` }}
      >
        <div
          className="absolute top-0.5 w-5 h-5 rounded-full transition-all"
          style={{
            left: value ? '22px' : '2px',
            background: value ? '#3EE6F5' : '#3E5578',
            boxShadow: value ? '0 0 8px rgba(62,230,245,0.6)' : 'none',
          }}
        />
      </button>
    </div>
  )
}

function InfoRow({ label, value, valueColor }: { label: string; value: string; valueColor?: string }) {
  return (
    <div className="flex items-center justify-between px-4 py-2.5">
      <span className="font-rajdhani" style={{ fontSize: 12, color: '#7FA0C9' }}>{label}</span>
      <span className="font-orbitron font-bold uppercase" style={{ fontSize: 11, color: valueColor ?? '#EAF6FF' }}>{value}</span>
    </div>
  )
}

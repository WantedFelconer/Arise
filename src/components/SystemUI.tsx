import { type ReactNode, useState, useEffect } from 'react'

/* ─────────────────────────────────────────────
   RANK BADGE
───────────────────────────────────────────── */
export const RANK_COLORS: Record<string, { bg: string; text: string; glow: string }> = {
  E: { bg: 'rgba(138,148,166,0.15)', text: '#8A94A6', glow: 'rgba(138,148,166,0.3)' },
  D: { bg: 'rgba(57,217,138,0.12)',  text: '#39D98A', glow: 'rgba(57,217,138,0.35)' },
  C: { bg: 'rgba(46,155,255,0.12)',  text: '#2E9BFF', glow: 'rgba(46,155,255,0.35)' },
  B: { bg: 'rgba(178,110,255,0.12)', text: '#B26EFF', glow: 'rgba(178,110,255,0.4)'  },
  A: { bg: 'rgba(255,155,62,0.12)',  text: '#FF9B3E', glow: 'rgba(255,155,62,0.4)'   },
  S: { bg: 'rgba(255,210,76,0.15)',  text: '#FFD24C', glow: 'rgba(255,210,76,0.5)'   },
}

export function RankBadge({ rank, size = 'md' }: { rank: string; size?: 'sm' | 'md' | 'lg' }) {
  const c = RANK_COLORS[rank] ?? RANK_COLORS['E']
  const sz = size === 'sm' ? 'w-6 h-6 text-xs' : size === 'lg' ? 'w-10 h-10 text-lg' : 'w-8 h-8 text-sm'
  return (
    <div className={`${sz} flex items-center justify-center rounded font-orbitron font-bold flex-shrink-0`}
      style={{ background: c.bg, color: c.text, boxShadow: `0 0 8px ${c.glow}`, border: `1px solid ${c.text}` }}>
      {rank}
    </div>
  )
}

/* ─────────────────────────────────────────────
   ORNATE CORNER — v1 Art Nouveau filigree
───────────────────────────────────────────── */
export function OrnateCorner({ flipX, flipY, size = 40 }: { flipX?: boolean; flipY?: boolean; size?: number }) {
  return (
    <svg width={size} height={size} viewBox="0 0 40 40" fill="none"
      style={{ transform: `scale(${flipX ? -1 : 1},${flipY ? -1 : 1})`, flexShrink: 0 }}>
      {/* Main L-border */}
      <path d="M2 20 L2 2 L20 2" stroke="#3EE6F5" strokeWidth="1.5" strokeLinecap="round" opacity=".9"/>
      {/* Inner parallel track */}
      <path d="M5 18 L5 5 L18 5" stroke="#3EE6F5" strokeWidth=".6" strokeLinecap="round" opacity=".4"/>
      {/* Corner diamond */}
      <rect x="0" y="0" width="5" height="5" rx=".5" fill="rgba(62,230,245,.15)" stroke="#3EE6F5" strokeWidth=".8"/>
      <rect x="1.5" y="1.5" width="2" height="2" fill="#3EE6F5" opacity=".8"/>
      {/* Horizontal flourish */}
      <path d="M22 2 C26 2 28 4 30 2" stroke="#3EE6F5" strokeWidth=".8" strokeLinecap="round" opacity=".55"/>
      <path d="M30 2 C33 2 34 3.5 36 2" stroke="#3EE6F5" strokeWidth=".6" strokeLinecap="round" opacity=".3"/>
      <circle cx="36" cy="2" r="1" fill="#3EE6F5" opacity=".4"/>
      {/* Vertical flourish */}
      <path d="M2 22 C2 26 4 28 2 30" stroke="#3EE6F5" strokeWidth=".8" strokeLinecap="round" opacity=".55"/>
      <path d="M2 30 C2 33 3.5 34 2 36" stroke="#3EE6F5" strokeWidth=".6" strokeLinecap="round" opacity=".3"/>
      <circle cx="2" cy="36" r="1" fill="#3EE6F5" opacity=".4"/>
      {/* Scroll curl horizontal */}
      <path d="M22 5 C24 5 25 7 23 8 C21 9 20 7 22 6.5" stroke="#3EE6F5" strokeWidth=".7" strokeLinecap="round" fill="none" opacity=".5"/>
      {/* Scroll curl vertical */}
      <path d="M5 22 C5 24 7 25 8 23 C9 21 7 20 6.5 22" stroke="#3EE6F5" strokeWidth=".7" strokeLinecap="round" fill="none" opacity=".5"/>
      {/* Tick marks on border */}
      <line x1="12" y1="2" x2="12" y2="4.5" stroke="#3EE6F5" strokeWidth=".8" opacity=".5"/>
      <line x1="2" y1="12" x2="4.5" y2="12" stroke="#3EE6F5" strokeWidth=".8" opacity=".5"/>
    </svg>
  )
}

/* ─────────────────────────────────────────────
   TOP CREST — ornate triangle crown
───────────────────────────────────────────── */
export function TopCrest({ width = 60 }: { width?: number }) {
  const cx = width / 2
  return (
    <svg width={width} height={16} viewBox={`0 0 ${width} 16`} fill="none">
      <path d={`M${cx-18} 16 L${cx-10} 4 L${cx} 1 L${cx+10} 4 L${cx+18} 16`}
        fill="rgba(10,26,58,.95)" stroke="#3EE6F5" strokeWidth="1.2" opacity=".75"/>
      <circle cx={cx} cy="4" r="2" fill="#3EE6F5" opacity=".9"/>
      <circle cx={cx} cy="4" r="3.5" stroke="#3EE6F5" strokeWidth=".6" opacity=".4"/>
      <line x1={cx-8} y1="9" x2={cx-5} y2="6" stroke="#3EE6F5" strokeWidth=".7" opacity=".4"/>
      <line x1={cx+8} y1="9" x2={cx+5} y2="6" stroke="#3EE6F5" strokeWidth=".7" opacity=".4"/>
    </svg>
  )
}

/* ─────────────────────────────────────────────
   ORNATE PANEL
───────────────────────────────────────────── */
export function OrnatePanel({ children, className = '', cornerSize = 36, noCrest, style }: {
  children: ReactNode; className?: string; cornerSize?: number; noCrest?: boolean; style?: React.CSSProperties
}) {
  return (
    <div className={`relative glass-panel ${className}`}
      style={{ border:'1px solid rgba(62,230,245,.45)', boxShadow:'0 0 20px rgba(62,230,245,.15),inset 0 0 30px rgba(10,26,58,.5)', ...style }}>
      <div className="absolute top-0 left-0"><OrnateCorner size={cornerSize}/></div>
      <div className="absolute top-0 right-0"><OrnateCorner flipX size={cornerSize}/></div>
      <div className="absolute bottom-0 left-0"><OrnateCorner flipY size={cornerSize}/></div>
      <div className="absolute bottom-0 right-0"><OrnateCorner flipX flipY size={cornerSize}/></div>
      {!noCrest && <div className="absolute top-0 left-1/2 -translate-x-1/2 -translate-y-px"><TopCrest/></div>}
      {children}
    </div>
  )
}

/* ─────────────────────────────────────────────
   GLASS CARD
───────────────────────────────────────────── */
export function GlassCard({ children, className = '', style }: { children: ReactNode; className?: string; style?: React.CSSProperties }) {
  return (
    <div className={`glass-panel rounded-2xl ${className}`}
      style={{ border:'1px solid rgba(62,230,245,.18)', ...style }}>
      {children}
    </div>
  )
}

/* ═══════════════════════════════════════════
   PROGRESS BAR
───────────────────────────────────────────── */
export function ProgressBar({ value, max, variant = 'cyan', showNumbers, label, height = 10 }: {
  value: number; max: number; variant?: 'hp'|'mp'|'exp'|'cyan'|'green'
  showNumbers?: boolean; label?: string; height?: number
}) {
  const pct = Math.max(0, Math.min(100, (value / max) * 100))
  const cls = { hp:'progress-bar-hp', mp:'progress-bar-mp', exp:'progress-bar-exp', cyan:'progress-bar-cyan', green:'progress-bar-green' }[variant]
  return (
    <div className="w-full">
      {(label||showNumbers) && (
        <div className="flex justify-between items-center mb-1">
          {label && <span className="font-mono-stat text-xs" style={{ color:'#7FA0C9' }}>{label}</span>}
          {showNumbers && <span className="font-mono-stat text-xs" style={{ color:'#EAF6FF' }}>{value.toLocaleString()} / {max.toLocaleString()}</span>}
        </div>
      )}
      <div className="relative rounded-full overflow-hidden" style={{ height, background:'rgba(10,26,58,.8)', boxShadow:'inset 0 1px 3px rgba(0,0,0,.5)', border:'1px solid rgba(62,230,245,.08)' }}>
        <div className={`h-full rounded-full progress-shimmer ${cls}`} style={{ width:`${pct}%`, transition:'width .6s cubic-bezier(.16,1,.3,1)' }}/>
      </div>
    </div>
  )
}

/* ─────────────────────────────────────────────
   SYSTEM ALERT
───────────────────────────────────────────── */
export function SystemAlert({ type = 'notice', title, children, onDismiss }: {
  type?: 'alarm'|'notice'|'warning'; title: string; children: ReactNode; onDismiss?: () => void
}) {
  const colors = {
    alarm:   { accent:'#FF2E4D', bg:'rgba(255,46,77,.08)',   border:'rgba(255,46,77,.5)'   },
    notice:  { accent:'#3EE6F5', bg:'rgba(62,230,245,.05)',  border:'rgba(62,230,245,.4)'  },
    warning: { accent:'#FFD24C', bg:'rgba(255,210,76,.06)',  border:'rgba(255,210,76,.4)'  },
  }[type]
  return (
    <OrnatePanel cornerSize={28} style={{ background: colors.bg }}>
      <div className="p-4 pt-6">
        <div className="flex items-center gap-2 mb-3">
          <div className="w-6 h-6 rounded-full flex items-center justify-center font-orbitron font-bold text-xs flex-shrink-0"
            style={{ background: colors.accent, color:'#000', boxShadow:`0 0 10px ${colors.accent}` }}>!</div>
          <span className="font-orbitron font-bold tracking-system uppercase text-xs" style={{ color: colors.accent }}>{type.toUpperCase()}</span>
          <div className="flex-1 h-px" style={{ background:`linear-gradient(to right,${colors.accent}60,transparent)` }}/>
        </div>
        <p className="font-orbitron font-bold uppercase tracking-wide-2 text-sm mb-2" style={{ color:'#EAF6FF' }}>{title}</p>
        <div className="font-rajdhani text-sm leading-relaxed" style={{ color:'#7FA0C9' }}>{children}</div>
        {onDismiss && (
          <button onClick={onDismiss} className="mt-4 w-full py-2 rounded font-orbitron font-bold tracking-system text-xs uppercase transition-all active:scale-95"
            style={{ background:`linear-gradient(135deg,${colors.accent}20,${colors.accent}08)`, border:`1px solid ${colors.accent}60`, color:colors.accent }}>
            [ ACKNOWLEDGE ]
          </button>
        )}
      </div>
    </OrnatePanel>
  )
}

/* ─────────────────────────────────────────────
   TERMINAL READOUT — boot-log / diagnostic lines
───────────────────────────────────────────── */
type LogStatus = 'OK' | 'SYNC' | 'WARN' | 'ERR' | 'INIT' | '...'
export interface TerminalLine { text: string; status?: LogStatus; dim?: boolean }

const STATUS_COLORS: Record<string, string> = {
  OK: '#39FF88', SYNC: '#3EE6F5', WARN: '#FFD24C', ERR: '#FF2E4D', INIT: '#7FA0C9', '...': '#3E5578'
}

export function TerminalReadout({ lines, className = '' }: { lines: TerminalLine[]; className?: string }) {
  return (
    <div className={`space-y-1 ${className}`}>
      {lines.map((l, i) => (
        <div key={i} className="flex items-center gap-2">
          <span className="terminal-dim flex-shrink-0">{'>'}</span>
          <span className={l.dim ? 'terminal-dim flex-1' : 'terminal-text flex-1'} style={{ fontSize:12 }}>{l.text}</span>
          {l.status && (
            <span className="font-mono-stat rounded px-1.5 py-0.5 flex-shrink-0"
              style={{ fontSize:9, color: STATUS_COLORS[l.status] ?? '#7FA0C9', background:`${STATUS_COLORS[l.status] ?? '#7FA0C9'}15`, border:`1px solid ${STATUS_COLORS[l.status] ?? '#7FA0C9'}35` }}>
              [{l.status}]
            </span>
          )}
        </div>
      ))}
    </div>
  )
}

/* ─────────────────────────────────────────────
   UPLINK STATUS CHIP
───────────────────────────────────────────── */
export function UplinkChip({ stable = true }: { stable?: boolean }) {
  return (
    <div className="flex items-center gap-1.5 glass-panel rounded-full px-2 py-1"
      style={{ border:`1px solid ${stable ? 'rgba(57,255,136,.25)' : 'rgba(255,46,77,.3)'}` }}>
      <div className="w-1.5 h-1.5 rounded-full flex-shrink-0"
        style={{ background: stable ? '#39FF88' : '#FF2E4D', boxShadow:`0 0 4px ${stable ? '#39FF88' : '#FF2E4D'}`, animation:`uplink-pulse 2s ease-in-out infinite` }}/>
      <span className="font-mono-stat" style={{ fontSize:8, color: stable ? '#39FF88' : '#FF2E4D', letterSpacing:'.04em' }}>
        {stable ? 'UPLINK: STABLE' : 'UPLINK: SEVERED'}
      </span>
    </div>
  )
}

/* ─────────────────────────────────────────────
   INTEGRATION CARD
───────────────────────────────────────────── */
interface IntegrationCardProps {
  icon: string; name: string; description: string; connected: boolean; onToggle?: () => void
}
export function IntegrationCard({ icon, name, description, connected, onToggle }: IntegrationCardProps) {
  return (
    <div className="glass-panel rounded-2xl p-4 flex items-center gap-3"
      style={{ border:`1px solid ${connected ? 'rgba(57,255,136,.25)' : 'rgba(62,230,245,.12)'}` }}>
      <div className="w-10 h-10 rounded-xl flex items-center justify-center flex-shrink-0 text-xl"
        style={{ background: connected ? 'rgba(57,255,136,.1)' : 'rgba(62,230,245,.06)', border:`1px solid ${connected ? 'rgba(57,255,136,.3)' : 'rgba(62,230,245,.15)'}` }}>
        {icon}
      </div>
      <div className="flex-1 min-w-0">
        <p className="font-orbitron font-bold uppercase" style={{ fontSize:11, color:'#EAF6FF' }}>{name}</p>
        <p className="font-rajdhani" style={{ fontSize:11, color:'#7FA0C9' }}>{description}</p>
        <span className="font-mono-stat rounded-full px-2 py-0.5 mt-0.5 inline-block"
          style={{ fontSize:8, color: connected ? '#39FF88' : '#3E5578', background: connected ? 'rgba(57,255,136,.1)' : 'rgba(62,230,245,.05)', border:`1px solid ${connected ? 'rgba(57,255,136,.3)' : 'rgba(62,230,245,.1)'}` }}>
          {connected ? '● CONNECTED' : '○ NOT CONNECTED'}
        </span>
      </div>
      <button onClick={onToggle} className="flex-shrink-0 w-12 h-6 rounded-full relative transition-all"
        style={{ background: connected ? 'rgba(57,255,136,.25)' : 'rgba(62,230,245,.08)', border:`1px solid ${connected ? 'rgba(57,255,136,.5)' : 'rgba(62,230,245,.2)'}` }}>
        <div className="absolute top-0.5 w-5 h-5 rounded-full transition-all"
          style={{ left: connected ? '24px' : '2px', background: connected ? '#39FF88' : '#3E5578', boxShadow: connected ? '0 0 8px rgba(57,255,136,.6)' : 'none' }}/>
      </button>
    </div>
  )
}

/* ─────────────────────────────────────────────
   SYSTEM LOG LINE (formalized component)
───────────────────────────────────────────── */
type LogTagType = 'exp'|'penalty'|'reward'|'system'|'warn'
const TAG_COLORS: Record<LogTagType, string> = {
  exp:     '#39FF88',
  penalty: '#FF2E4D',
  reward:  '#FFD24C',
  system:  '#3EE6F5',
  warn:    '#FF9B3E',
}
interface LogLine { tag: LogTagType; tagLabel: string; text: string; time: string }

export function SystemLogLine({ line }: { line: LogLine }) {
  const c = TAG_COLORS[line.tag] ?? '#3EE6F5'
  return (
    <div className="flex items-start gap-2 py-1.5" style={{ borderLeft:`2px solid ${c}40`, paddingLeft:8 }}>
      <span className="font-mono-stat flex-shrink-0" style={{ fontSize:9, color:'#3E5578', minWidth:36, marginTop:1 }}>{line.time}</span>
      <span className="font-mono-stat rounded px-1.5 flex-shrink-0"
        style={{ fontSize:9, color:c, background:`${c}12`, border:`1px solid ${c}30`, marginTop:1 }}>
        [{line.tagLabel}]
      </span>
      <span className="font-mono-stat flex-1" style={{ fontSize:11, color:'#7FA0C9', lineHeight:1.4 }}>{line.text}</span>
    </div>
  )
}

/* ═══════════════════════════════════════════
   NAV BAR
───────────────────────────────────────────── */
const NAV_ITEMS = [
  { id:'home',    label:'HOME',    Icon: HomeIcon    },
  { id:'quests',  label:'QUESTS',  Icon: QuestIcon   },
  { id:'status',  label:'STATUS',  Icon: StatusIcon  },
  { id:'journal', label:'JOURNAL', Icon: JournalIcon },
  { id:'roadmap', label:'ROADMAP', Icon: RoadmapIcon },
]
export function NavBar({ active, onNavigate }: { active:string; onNavigate:(id:string)=>void }) {
  return (
    <div className="absolute bottom-0 left-0 right-0 z-40 px-3 pb-2">
      <div className="glass-panel rounded-2xl px-2 py-2"
        style={{ border:'1px solid rgba(62,230,245,.22)', boxShadow:'0 -4px 24px rgba(0,0,0,.5),0 0 16px rgba(62,230,245,.06)' }}>
        <div className="flex items-center justify-around">
          {NAV_ITEMS.map(({ id, label, Icon }) => {
            const isActive = active === id
            return (
              <button key={id} onClick={() => onNavigate(id)}
                className="flex flex-col items-center gap-0.5 py-1 px-2 rounded-xl transition-all active:scale-90"
                style={{ color: isActive ? '#3EE6F5' : '#3E5578', background: isActive ? 'rgba(62,230,245,.08)' : 'transparent' }}>
                <Icon size={20} active={isActive}/>
                <span className="font-orbitron tracking-system" style={{ fontSize:8 }}>{label}</span>
              </button>
            )
          })}
        </div>
      </div>
    </div>
  )
}

/* ─────────────────────────────────────────────
   TOP STATUS BAR
───────────────────────────────────────────── */
export function TopStatusBar({ hp, maxHp, mp, maxMp, level, streak, uplinkStable, onManaCoreClick }: {
  hp: number; maxHp: number; mp: number; maxMp: number
  level: number; streak: number; uplinkStable?: boolean; onManaCoreClick: () => void
}) {
  return (
    <div className="absolute top-0 left-0 right-0 z-30"
      style={{ background:'linear-gradient(to bottom,rgba(3,7,18,.98) 0%,rgba(3,7,18,.6) 80%,rgba(3,7,18,0) 100%)', paddingTop: 10, paddingBottom: 6, paddingLeft: 10, paddingRight: 10 }}>
      {/* Row 1: HP + MP bars */}
      <div className="flex items-center gap-2 mb-1">
        <StatPill value={hp} max={maxHp} label="HP" color="#FF5A36" barClass="progress-bar-hp"/>
        <StatPill value={mp} max={maxMp} label="MP" color="#2E9BFF" barClass="progress-bar-mp"/>
      </div>
      {/* Row 2: level · streak · mana ring · uplink */}
      <div className="flex items-center justify-end gap-1.5">
        <div className="flex items-center gap-1" style={{ color:'#FF9B3E' }}>
          <span style={{ fontSize:11 }}>🔥</span>
          <span className="font-orbitron font-bold" style={{ fontSize:9 }}>{streak}</span>
        </div>
        <div className="glass-panel rounded-full px-2 py-0.5 font-orbitron font-bold"
          style={{ fontSize:9, color:'#FFD24C', border:'1px solid rgba(255,210,76,.3)' }}>
          LV.{level}
        </div>
        <button onClick={onManaCoreClick} className="active:scale-90 transition-transform">
          <MiniManaRing pct={0.65}/>
        </button>
        <UplinkChip stable={uplinkStable ?? true}/>
      </div>
    </div>
  )
}

function StatPill({ value, max, label, color, barClass }: { value:number; max:number; label:string; color:string; barClass:string }) {
  return (
    <div className="flex items-center gap-1 glass-panel rounded-full px-2 py-0.5" style={{ border:`1px solid ${color}30`, minWidth:0 }}>
      <span className="font-mono-stat flex-shrink-0" style={{ fontSize:8, color }}>{label}</span>
      <div className="w-16 h-1.5 rounded-full overflow-hidden flex-shrink-0" style={{ background:'rgba(0,0,0,.5)' }}>
        <div className={`h-full ${barClass} progress-shimmer`} style={{ width:`${(value/max)*100}%` }}/>
      </div>
      <span className="font-mono-stat flex-shrink-0" style={{ fontSize:7, color:'rgba(234,246,255,.7)' }}>{value}</span>
    </div>
  )
}

function MiniManaRing({ pct }: { pct: number }) {
  const s = 22; const r = (s-5)/2; const c = 2*Math.PI*r
  return (
    <svg width={s} height={s}>
      <circle cx={s/2} cy={s/2} r={r} fill="none" stroke="rgba(62,230,245,.12)" strokeWidth="2.5"/>
      <circle cx={s/2} cy={s/2} r={r} fill="none" stroke="#3EE6F5" strokeWidth="2.5"
        strokeDasharray={c} strokeDashoffset={c*(1-pct)} strokeLinecap="round"
        transform={`rotate(-90 ${s/2} ${s/2})`}
        style={{ filter:'drop-shadow(0 0 3px #3EE6F5)' }}/>
    </svg>
  )
}

/* ─────────────────────────────────────────────
   MISC ATOMS
───────────────────────────────────────────── */
export function DiamondDivider() {
  return (
    <div className="flex items-center gap-2 my-3">
      <div className="flex-1 h-px" style={{ background:'linear-gradient(to right,transparent,rgba(62,230,245,.3))' }}/>
      <span style={{ color:'#3EE6F5', fontSize:10, opacity:.8 }}>◆</span>
      <div className="flex-1 h-px" style={{ background:'linear-gradient(to left,transparent,rgba(62,230,245,.3))' }}/>
    </div>
  )
}

export function DiamondSep() { return <span style={{ color:'#3EE6F5', opacity:.6, fontSize:10 }}>◆</span> }

export function BuffTag({ label }: { label: string }) {
  return (
    <span className="inline-flex items-center px-2 py-0.5 rounded font-rajdhani font-semibold uppercase"
      style={{ fontSize:9, color:'#39FF88', letterSpacing:'.08em', background:'rgba(57,255,136,.1)', border:'1px solid rgba(57,255,136,.3)', boxShadow:'0 0 6px rgba(57,255,136,.15)' }}>
      {label}
    </span>
  )
}

export function SectionHeader({ title, right }: { title: string; right?: ReactNode }) {
  return (
    <div className="flex items-center justify-between mb-3">
      <div className="flex items-center gap-2">
        <div className="w-1 h-4 rounded-full" style={{ background:'linear-gradient(to bottom,#3EE6F5,#1FA9C2)' }}/>
        <h2 className="font-orbitron font-bold uppercase tracking-wide-2" style={{ fontSize:13, color:'#EAF6FF' }}>{title}</h2>
      </div>
      {right}
    </div>
  )
}

export function RewardChip({ exp, gold }: { exp?: number; gold?: number }) {
  return (
    <div className="flex items-center gap-1.5">
      {exp !== undefined && (
        <span className="flex items-center gap-1 font-mono-stat rounded-full px-2 py-0.5"
          style={{ fontSize:10, color:'#FFD24C', background:'rgba(255,210,76,.1)', border:'1px solid rgba(255,210,76,.25)' }}>
          ◆ {exp} EXP
        </span>
      )}
      {gold !== undefined && (
        <span className="flex items-center gap-1 font-mono-stat rounded-full px-2 py-0.5"
          style={{ fontSize:10, color:'#C98A1A', background:'rgba(201,138,26,.1)', border:'1px solid rgba(201,138,26,.25)' }}>
          ⬡ {gold}G
        </span>
      )}
    </div>
  )
}

/* ─────────────────────────────────────────────
   SCANLINE SWEEP (hero moment, one-shot)
───────────────────────────────────────────── */
export function ScanlineSweep() {
  const [visible, setVisible] = useState(true)
  useEffect(() => { const t = setTimeout(() => setVisible(false), 1000); return () => clearTimeout(t) }, [])
  if (!visible) return null
  return <div className="scanline-hero"/>
}

/* ─────────────────────────────────────────────
   DECRYPT TEXT (typewriter + scramble reveal)
───────────────────────────────────────────── */
export function DecryptText({ text, delay = 0, speed = 40, className = '' }: {
  text: string; delay?: number; speed?: number; className?: string
}) {
  const [displayed, setDisplayed] = useState('')
  const [done, setDone] = useState(false)
  useEffect(() => {
    let i = 0; let t: ReturnType<typeof setTimeout>
    const start = setTimeout(() => {
      const tick = () => {
        i++; setDisplayed(text.slice(0, i))
        if (i < text.length) t = setTimeout(tick, speed)
        else setDone(true)
      }
      tick()
    }, delay)
    return () => { clearTimeout(start); clearTimeout(t) }
  }, [text, delay, speed])
  return (
    <span className={className}>
      {displayed}
      {!done && <span className="ai-cursor"/>}
    </span>
  )
}

/* ─────────────────────────────────────────────
   HEX MICRO LABEL
───────────────────────────────────────────── */
export function HexLabel({ text }: { text: string }) {
  return (
    <span className="font-mono-stat absolute" style={{ fontSize:7, color:'rgba(62,230,245,.35)', letterSpacing:'.04em' }}>
      {text}
    </span>
  )
}

/* ─────────────────────────────────────────────
   NAV ICONS
───────────────────────────────────────────── */
function HomeIcon({ size, active }: { size:number; active:boolean }) {
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke={active?'#3EE6F5':'#3E5578'} strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round">
      <path d="M3 12L12 3l9 9"/><path d="M5 10v9a1 1 0 001 1h4v-5h4v5h4a1 1 0 001-1v-9"/>
    </svg>
  )
}
function QuestIcon({ size, active }: { size:number; active:boolean }) {
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke={active?'#3EE6F5':'#3E5578'} strokeWidth="1.5" strokeLinecap="round">
      <path d="M14.5 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V7.5L14.5 2z"/>
      <polyline points="14 2 14 8 20 8"/><line x1="9" y1="13" x2="15" y2="13"/><line x1="9" y1="17" x2="12" y2="17"/>
    </svg>
  )
}
function StatusIcon({ size, active }: { size:number; active:boolean }) {
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke={active?'#3EE6F5':'#3E5578'} strokeWidth="1.5" strokeLinecap="round">
      <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/>
    </svg>
  )
}
function JournalIcon({ size, active }: { size:number; active:boolean }) {
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke={active?'#3EE6F5':'#3E5578'} strokeWidth="1.5" strokeLinecap="round">
      <path d="M4 19.5A2.5 2.5 0 016.5 17H20"/><path d="M6.5 2H20v20H6.5A2.5 2.5 0 014 19.5v-15A2.5 2.5 0 016.5 2z"/>
      <line x1="10" y1="8" x2="16" y2="8"/><line x1="10" y1="12" x2="14" y2="12"/>
    </svg>
  )
}
function RoadmapIcon({ size, active }: { size:number; active:boolean }) {
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke={active?'#3EE6F5':'#3E5578'} strokeWidth="1.5" strokeLinecap="round">
      <circle cx="6" cy="6" r="2"/><circle cx="18" cy="12" r="2"/><circle cx="6" cy="18" r="2"/>
      <path d="M8 6h6a2 2 0 012 2v2"/><path d="M16 14v2a2 2 0 01-2 2H8"/>
    </svg>
  )
}

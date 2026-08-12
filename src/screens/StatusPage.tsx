import { useState } from 'react'
import { OrnatePanel, ProgressBar, DiamondDivider, RankBadge, BuffTag, GlassCard } from '../components/SystemUI'
import type { PlayerData } from '../App'

type Props = { player: PlayerData; onStatUp: (stat: string) => void }
type StatusTab = 'stats' | 'achievements'

const STAT_ICONS: Record<string, string> = { STR:'⚡', AGI:'◈', VIT:'♦', INT:'◎', PER:'◉' }

const TITLES = [
  { id:'wolf',   name:'WOLF SLAYER',    desc:'Defeated 10+ dungeon bosses',  active:true  },
  { id:'iron',   name:'IRON WILL',      desc:'Maintained a 30-day streak',   active:true  },
  { id:'shadow', name:'SHADOW MONARCH', desc:'Complete 500 quests [LOCKED]', active:false },
  { id:'arise',  name:'THE AWAKENED',   desc:'Default title upon awakening', active:true  },
]

const BUFF_TAGS = [
  'PHYSICAL DMG REDUCTION 15% — ACTIVE',
  'EXP GAIN BONUS 10% — ACTIVE',
  'DAILY QUEST COMPLETION +STREAK',
]

const RARITY_COLORS: Record<string, string> = {
  common: '#8A94A6', uncommon: '#39D98A', rare: '#2E9BFF', epic: '#B26EFF', legendary: '#FFD24C'
}

const ACHIEVEMENTS = [
  { id:'a1', name:'FIRST BLOOD',      rarity:'common',    icon:'⚔', desc:'Complete your first quest', unlocked:true,  req:'' },
  { id:'a2', name:'IRON STREAK',      rarity:'uncommon',  icon:'🔥', desc:'14-day streak achieved',   unlocked:true,  req:'' },
  { id:'a3', name:'DUNGEON CRAWLER',  rarity:'rare',      icon:'🏛', desc:'Enter 50 Focus Gates',     unlocked:true,  req:'' },
  { id:'a4', name:'SCHOLAR',          rarity:'rare',      icon:'📚', desc:'Complete 100 Mind quests',  unlocked:false, req:'64 / 100 quests' },
  { id:'a5', name:'THE SOVEREIGN',    rarity:'epic',      icon:'👑', desc:'Reach Rank A',              unlocked:false, req:'Current: B-Rank' },
  { id:'a6', name:'CODE BREAKER',     rarity:'epic',      icon:'💻', desc:'100 Craft quests cleared',  unlocked:false, req:'38 / 100 quests' },
  { id:'a7', name:'SHADOW MONARCH',   rarity:'legendary', icon:'💀', desc:'Complete 500 total quests', unlocked:false, req:'214 / 500 quests' },
  { id:'a8', name:'STREAKMASTER',     rarity:'legendary', icon:'⚡', desc:'Maintain 100-day streak',   unlocked:false, req:'Current: 14 days'  },
]

export default function StatusPage({ player, onStatUp }: Props) {
  const [tab, setTab] = useState<StatusTab>('stats')
  const [showTitles, setShowTitles] = useState(false)
  const [activeTitle, setActiveTitle] = useState('wolf')
  const [confirmStat, setConfirmStat] = useState<string|null>(null)
  const stats = { STR:player.str, AGI:player.agi, VIT:player.vit, INT:player.int, PER:player.per }
  const displayTitle = TITLES.find(t => t.id === activeTitle)?.name ?? 'WOLF SLAYER'

  function handleStatUp(stat: string) { if (player.remainingPoints > 0) setConfirmStat(stat) }
  function confirmUp() { if (confirmStat) { onStatUp(confirmStat); setConfirmStat(null) } }

  return (
    <div className="flex flex-col h-full void-bg circuit-overlay overflow-y-auto" style={{ paddingTop:64, paddingBottom:80 }}>
      <div className="px-4 pt-3">

        {/* Tab switcher */}
        <div className="flex glass-panel rounded-xl overflow-hidden mb-4" style={{ border:'1px solid rgba(62,230,245,.15)' }}>
          {(['stats','achievements'] as StatusTab[]).map(t => (
            <button key={t} onClick={() => setTab(t)}
              className="flex-1 py-2 font-orbitron font-bold uppercase tracking-system transition-all"
              style={{ fontSize:10, color: tab===t ? '#3EE6F5' : '#3E5578', background: tab===t ? 'rgba(62,230,245,.1)' : 'transparent', borderBottom: tab===t ? '2px solid #3EE6F5' : '2px solid transparent' }}>
              {t === 'stats' ? 'STATUS' : 'ACHIEVEMENTS'}
            </button>
          ))}
        </div>

        {tab === 'stats' && (
          <>
            {/* SYSTEM WINDOW */}
            <OrnatePanel className="mb-4">
              <div className="p-5 pt-8">
                <div className="text-center mb-4">
                  <h1 className="font-orbitron font-black uppercase tracking-system"
                    style={{ fontSize:24, color:'#EAF6FF', textShadow:'0 0 20px rgba(62,230,245,0.5)' }}>STATUS</h1>
                  <div className="flex justify-center mt-1">
                    <div className="h-px w-32" style={{ background:'linear-gradient(to right,transparent,#3EE6F5,transparent)' }}/>
                  </div>
                </div>

                <div className="space-y-1.5 mb-3">
                  <div className="flex items-center justify-between">
                    <div>
                      <FieldRow label="NAME" value={player.name.toUpperCase()}/>
                      <FieldRow label="JOB" value="HUNTER"/>
                      <div className="flex items-center gap-2">
                        <span className="font-orbitron uppercase" style={{ fontSize:11, color:'#7FA0C9', letterSpacing:'.08em', minWidth:40 }}>TITLE</span>
                        <button onClick={() => setShowTitles(true)}
                          className="font-orbitron font-bold uppercase transition-all active:scale-95"
                          style={{ fontSize:13, color:'#FFD24C', textShadow:'0 0 10px rgba(255,210,76,0.4)' }}>
                          {displayTitle} ▼
                        </button>
                      </div>
                    </div>
                    <div className="text-right">
                      <div className="flex items-center gap-2 justify-end"><RankBadge rank={player.rank} size="md"/></div>
                      <p className="font-orbitron font-bold mt-1" style={{ fontSize:13, color:'#EAF6FF' }}>LEVEL: <span style={{ color:'#FFD24C' }}>{player.level}</span></p>
                      <p className="font-orbitron" style={{ fontSize:11, color:'#7FA0C9' }}>FATIGUE: <span style={{ color:'#39FF88' }}>0</span></p>
                    </div>
                  </div>
                </div>

                <div className="h-px mb-3" style={{ background:'rgba(62,230,245,0.25)' }}/>

                {/* HP */}
                <div className="mb-2">
                  <div className="flex items-center justify-between mb-1">
                    <span className="font-orbitron font-bold" style={{ fontSize:13, color:'#FF5A36' }}>HP</span>
                    <span className="font-mono-stat" style={{ fontSize:13, color:'#EAF6FF' }}>{player.hp.toLocaleString()} / {player.maxHp.toLocaleString()}</span>
                  </div>
                  <div className="h-3 rounded-sm overflow-hidden" style={{ background:'rgba(0,0,0,0.5)', border:'1px solid rgba(255,90,54,0.3)' }}>
                    <div className="h-full progress-shimmer" style={{ width:`${(player.hp/player.maxHp)*100}%`, background:'linear-gradient(90deg,#FF5A36,#C4171C)', boxShadow:'0 0 8px rgba(255,90,54,0.6)' }}/>
                  </div>
                </div>
                {/* MP */}
                <div className="mb-3">
                  <div className="flex items-center justify-between mb-1">
                    <span className="font-orbitron font-bold" style={{ fontSize:13, color:'#2E9BFF' }}>MP</span>
                    <span className="font-mono-stat" style={{ fontSize:13, color:'#EAF6FF' }}>{player.mp} / {player.maxMp}</span>
                  </div>
                  <div className="h-3 rounded-sm overflow-hidden" style={{ background:'rgba(0,0,0,0.5)', border:'1px solid rgba(46,155,255,0.3)' }}>
                    <div className="h-full progress-shimmer" style={{ width:`${(player.mp/player.maxMp)*100}%`, background:'linear-gradient(90deg,#2E9BFF,#1560C4)', boxShadow:'0 0 8px rgba(46,155,255,0.6)' }}/>
                  </div>
                </div>

                <DiamondDivider/>

                {/* Stats grid */}
                <div className="grid grid-cols-2 gap-x-6 gap-y-3">
                  {Object.entries(stats).map(([stat, val]) => (
                    <div key={stat} className="flex items-center justify-between">
                      <div className="flex items-center gap-1.5">
                        <span style={{ fontSize:12, opacity:.7 }}>{STAT_ICONS[stat]}</span>
                        <span className="font-orbitron uppercase" style={{ fontSize:11, color:'#7FA0C9', letterSpacing:'.05em' }}>{stat}:</span>
                      </div>
                      <div className="flex items-center gap-1.5">
                        <span className="font-mono-stat" style={{ fontSize:14, color:'#EAF6FF' }}>{val}</span>
                        {player.remainingPoints > 0 && (
                          <button onClick={() => handleStatUp(stat)}
                            className="w-4 h-4 rounded flex items-center justify-center font-bold transition-all active:scale-90"
                            style={{ background:'rgba(62,230,245,0.15)', border:'1px solid rgba(62,230,245,0.4)', color:'#3EE6F5', fontSize:10 }}>+</button>
                        )}
                      </div>
                    </div>
                  ))}
                </div>

                <DiamondDivider/>
                <div className="text-right">
                  <p className="font-orbitron font-bold uppercase" style={{ fontSize:12, color:'#FFD24C', letterSpacing:'.08em' }}>
                    REMAINING POINTS: <span style={{ fontSize:18 }}>{player.remainingPoints}</span>
                  </p>
                </div>
              </div>
            </OrnatePanel>

            {/* Buffs */}
            <div className="mb-4">
              <p className="font-orbitron uppercase tracking-system mb-2" style={{ fontSize:10, color:'#7FA0C9' }}>[ PASSIVE SKILLS — ACTIVATING ]</p>
              <div className="flex flex-wrap gap-1.5">{BUFF_TAGS.map((b,i) => <BuffTag key={i} label={b}/>)}</div>
            </div>

            {/* EXP */}
            <div className="glass-panel rounded-xl p-4 mb-4" style={{ border:'1px solid rgba(255,210,76,0.2)' }}>
              <div className="flex items-center justify-between mb-2">
                <span className="font-orbitron font-bold" style={{ fontSize:11, color:'#FFD24C' }}>EXPERIENCE</span>
                <span className="font-mono-stat" style={{ fontSize:10, color:'#7FA0C9' }}>{player.exp.toLocaleString()} / {player.maxExp.toLocaleString()}</span>
              </div>
              <ProgressBar value={player.exp} max={player.maxExp} variant="exp" height={10}/>
              <p className="font-mono-stat mt-1.5 text-right" style={{ fontSize:9, color:'#3E5578' }}>
                TO LEVEL {player.level+1}: {(player.maxExp-player.exp).toLocaleString()} EXP
              </p>
            </div>

            {/* Gold */}
            <div className="glass-panel rounded-xl p-3 mb-2" style={{ border:'1px solid rgba(201,138,26,0.25)' }}>
              <div className="flex items-center justify-between">
                <span className="font-orbitron uppercase tracking-system" style={{ fontSize:10, color:'#C98A1A' }}>GOLD RESERVES</span>
                <span className="font-mono-stat" style={{ fontSize:18, color:'#FFD24C' }}>⬡ {player.gold.toLocaleString()}</span>
              </div>
            </div>
          </>
        )}

        {tab === 'achievements' && (
          <div>
            <div className="flex items-center justify-between mb-3">
              <p className="font-mono-stat" style={{ fontSize:9, color:'#3E5578' }}>[ ACHIEVEMENT REGISTRY ]</p>
              <span className="font-mono-stat" style={{ fontSize:10, color:'#FFD24C' }}>
                {ACHIEVEMENTS.filter(a => a.unlocked).length} / {ACHIEVEMENTS.length} UNLOCKED
              </span>
            </div>

            <div className="grid grid-cols-2 gap-3">
              {ACHIEVEMENTS.map(ach => {
                const rc = RARITY_COLORS[ach.rarity] ?? '#8A94A6'
                return (
                  <GlassCard key={ach.id} className="p-3 flex flex-col items-center text-center relative overflow-hidden"
                    style={{ border:`1px solid ${ach.unlocked ? `${rc}45` : 'rgba(62,230,245,.08)'}`, boxShadow: ach.unlocked ? `0 0 12px ${rc}20` : 'none', opacity: ach.unlocked ? 1 : 0.55 }}>
                    {/* Rarity glow line */}
                    <div className="absolute top-0 left-0 right-0 h-0.5" style={{ background: ach.unlocked ? rc : 'transparent' }}/>

                    <div className="w-12 h-12 rounded-full flex items-center justify-center mb-2 text-2xl"
                      style={{ background: ach.unlocked ? `${rc}15` : 'rgba(62,230,245,.04)', border:`1.5px solid ${ach.unlocked ? `${rc}45` : 'rgba(62,230,245,.1)'}`, filter: ach.unlocked ? 'none' : 'grayscale(1) brightness(.4)' }}>
                      {ach.unlocked ? ach.icon : '🔒'}
                    </div>

                    <p className="font-orbitron font-bold uppercase leading-tight mb-0.5"
                      style={{ fontSize:9, color: ach.unlocked ? rc : '#3E5578', lineHeight:1.2 }}>
                      {ach.name}
                    </p>
                    <p className="font-rajdhani" style={{ fontSize:10, color:'#7FA0C9', lineHeight:1.3 }}>{ach.desc}</p>

                    {!ach.unlocked && (
                      <p className="font-mono-stat mt-1" style={{ fontSize:8, color:'#3E5578' }}>{ach.req}</p>
                    )}
                    {ach.unlocked && (
                      <span className="font-mono-stat mt-1 rounded-full px-1.5"
                        style={{ fontSize:8, color:rc, background:`${rc}15`, border:`1px solid ${rc}30` }}>
                        {ach.rarity.toUpperCase()}
                      </span>
                    )}
                  </GlassCard>
                )
              })}
            </div>
          </div>
        )}
      </div>

      {/* Title modal */}
      {showTitles && (
        <div className="absolute inset-0 z-50 flex items-end" style={{ background:'rgba(3,7,18,.85)' }} onClick={() => setShowTitles(false)}>
          <div className="w-full animate-slide-up glass-panel rounded-t-2xl p-5" style={{ border:'1px solid rgba(62,230,245,.3)', borderBottom:'none' }} onClick={e => e.stopPropagation()}>
            <div className="w-10 h-1 rounded-full mx-auto mb-4" style={{ background:'rgba(62,230,245,.3)' }}/>
            <p className="font-orbitron font-bold uppercase tracking-system mb-4" style={{ fontSize:13, color:'#EAF6FF' }}>SELECT TITLE</p>
            <div className="space-y-2">
              {TITLES.map(t => (
                <button key={t.id} disabled={!t.active} onClick={() => { setActiveTitle(t.id); setShowTitles(false) }}
                  className="w-full text-left rounded-lg px-3 py-2 transition-all active:scale-98"
                  style={{ background: activeTitle===t.id ? 'rgba(255,210,76,.1)' : 'rgba(10,26,58,.6)', border: activeTitle===t.id ? '1px solid rgba(255,210,76,.4)' : '1px solid rgba(62,230,245,.1)', opacity: t.active ? 1 : 0.4 }}>
                  <p className="font-orbitron font-bold uppercase" style={{ fontSize:12, color: t.active ? (activeTitle===t.id ? '#FFD24C' : '#EAF6FF') : '#3E5578' }}>
                    {t.name}{activeTitle===t.id && <span style={{ color:'#3EE6F5', marginLeft:8, fontSize:10 }}>● ACTIVE</span>}
                  </p>
                  <p className="font-rajdhani" style={{ fontSize:11, color:'#7FA0C9' }}>{t.desc}</p>
                </button>
              ))}
            </div>
          </div>
        </div>
      )}

      {/* Stat confirm */}
      {confirmStat && (
        <div className="absolute inset-0 z-50 flex items-center justify-center px-8" style={{ background:'rgba(3,7,18,.85)' }}>
          <OrnatePanel cornerSize={24} className="animate-level-flash">
            <div className="p-5 pt-7 text-center">
              <p className="font-mono-stat mb-2" style={{ fontSize:10, color:'#7FA0C9' }}>[ STAT ALLOCATION ]</p>
              <p className="font-orbitron font-bold uppercase" style={{ fontSize:16, color:'#EAF6FF' }}>INVEST 1 POINT</p>
              <p className="font-orbitron font-bold" style={{ fontSize:28, color:'#3EE6F5', margin:'8px 0' }}>{STAT_ICONS[confirmStat]} {confirmStat}</p>
              <p className="font-mono-stat" style={{ fontSize:12, color:'#7FA0C9' }}>
                {stats[confirmStat as keyof typeof stats]} → <span style={{ color:'#39FF88' }}>{(stats[confirmStat as keyof typeof stats] ?? 0) + 1}</span>
              </p>
              <DiamondDivider/>
              <div className="flex gap-3 mt-2">
                <button onClick={() => setConfirmStat(null)} className="flex-1 py-2.5 rounded-lg font-orbitron font-bold uppercase tracking-system transition-all active:scale-95"
                  style={{ fontSize:10, border:'1px solid rgba(62,230,245,.2)', color:'#3E5578' }}>CANCEL</button>
                <button onClick={confirmUp} className="flex-1 py-2.5 rounded-lg font-orbitron font-bold uppercase tracking-system transition-all active:scale-95"
                  style={{ fontSize:10, background:'linear-gradient(135deg,#3EE6F5,#1FA9C2)', color:'#030712' }}>CONFIRM</button>
              </div>
            </div>
          </OrnatePanel>
        </div>
      )}
    </div>
  )
}

function FieldRow({ label, value }: { label: string; value: string }) {
  return (
    <div className="flex items-center gap-2 mb-1">
      <span className="font-orbitron uppercase" style={{ fontSize:11, color:'#7FA0C9', letterSpacing:'.08em', minWidth:40 }}>{label}</span>
      <span className="font-orbitron font-bold uppercase" style={{ fontSize:13, color:'#EAF6FF' }}>{value}</span>
    </div>
  )
}

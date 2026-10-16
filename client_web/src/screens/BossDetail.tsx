import { useState, useEffect } from 'react'
import { OrnatePanel, DiamondDivider, RankBadge, RewardChip, ScanlineSweep } from '../components/SystemUI'
import { services } from '../api/services'

interface Props { onBack: () => void; onFocusMode: () => void }

const DEFAULT_BOSS = {
  name: 'SHIP THE APP',
  subtitle: 'A-RANK BOSS · PROJECT',
  rank: 'A',
  hp: 6500, maxHp: 10000,
  deadline: '14D 06H',
  exp: 2000, gold: 500,
}

const DEFAULT_ATTACK_LOG = [
  { id: '1', action: 'Completed API integration', dmg: -850, time: '2h ago', rank: 'A' },
  { id: '2', action: 'Wrote test suite (32 specs)', dmg: -400, time: '5h ago', rank: 'B' },
  { id: '3', action: 'Design handoff finalized', dmg: -600, time: '1d ago', rank: 'A' },
  { id: '4', action: 'Auth flow implemented', dmg: -700, time: '2d ago', rank: 'A' },
  { id: '5', action: 'DB schema locked', dmg: -950, time: '3d ago', rank: 'S' },
]

export default function BossDetail({ onBack, onFocusMode }: Props) {
  const [boss, setBoss] = useState(DEFAULT_BOSS)
  const [attackLog, setAttackLog] = useState(DEFAULT_ATTACK_LOG)
  const [isDefeated, setIsDefeated] = useState(false)

  useEffect(() => {
    let mounted = true
    async function loadBoss() {
      try {
        const bosses = await services.bosses.listBosses()
        if (!mounted) return
        if (bosses && bosses.length > 0) {
          const active = bosses.find(b => b.status === 'active') || bosses[0]
          setBoss({
            name: active.title.toUpperCase(),
            subtitle: `${active.rank}-RANK BOSS · PROJECT`,
            rank: active.rank,
            hp: active.currentHp,
            maxHp: active.maxHp,
            deadline: active.deadline ? `${Math.max(1, Math.ceil((new Date(active.deadline).getTime() - Date.now()) / (1000 * 60 * 60 * 24)))}D` : '14D 06H',
            exp: active.expReward || 2000,
            gold: active.goldReward || 500,
          })
          if (active.status === 'defeated' || active.currentHp <= 0) {
            setIsDefeated(true)
          }
        }
        const history = await services.bosses.getBossHistory()
        if (mounted && history && history.length > 0) {
          setAttackLog(history.map((h, i) => ({
            id: h.id || String(i),
            action: h.action || 'Completed quest objective',
            dmg: -Math.abs(h.damage),
            time: 'Recently',
            rank: h.rank || 'A',
          })))
        }
      } catch {
        // Fallback to baseline
      }
    }
    loadBoss()
    return () => { mounted = false }
  }, [])

  const hpPct = Math.max(0, Math.min(1, boss.hp / boss.maxHp))

  if (isDefeated) return <BossDefeated onBack={onBack}/>

  return (
    <main className="special-workspace boss-screen absolute inset-0 z-40 flex flex-col void-bg circuit-overlay animate-slide-up overflow-y-auto">
      {/* Header */}
      <div className="flex items-center justify-between px-4 pt-6 pb-3 flex-shrink-0"
        style={{ borderBottom:'1px solid rgba(62,230,245,.12)' }}>
        <button onClick={onBack} className="font-orbitron uppercase tracking-system transition-all active:opacity-60"
          style={{ fontSize:10, color:'#3E5578' }}>← BACK</button>
        <p className="font-mono-stat" style={{ fontSize:9, color:'#FF9B3E' }}>[ BOSS ENCOUNTER ]</p>
        <RankBadge rank={boss.rank} size="sm"/>
      </div>

      <div className="px-4 pt-4 space-y-4 pb-32">
        {/* Boss Identity */}
        <OrnatePanel>
          <div className="p-5 pt-8">
            <div className="text-center mb-4">
              {/* Boss icon */}
              <div className="w-20 h-20 rounded-full mx-auto mb-3 flex items-center justify-center relative"
                style={{ background:'radial-gradient(ellipse at 35% 35%,rgba(255,155,62,.2),rgba(10,26,58,.9))', border:'2px solid #FF9B3E', boxShadow:'0 0 32px rgba(255,155,62,.35),0 0 64px rgba(255,155,62,.1)' }}>
                <span className="system-glyph system-glyph-hero">╳</span>
                <div className="absolute -top-1 -right-1 w-5 h-5 rounded-full flex items-center justify-center"
                  style={{ background:'#FF9B3E', boxShadow:'0 0 8px rgba(255,155,62,.6)' }}>
                  <span className="font-orbitron font-bold" style={{ fontSize:9, color:'#030712' }}>{boss.rank}</span>
                </div>
              </div>
              <h1 className="font-orbitron font-black uppercase tracking-system"
                style={{ fontSize:20, color:'#EAF6FF', textShadow:'0 0 20px rgba(255,155,62,.3)' }}>
                {boss.name}
              </h1>
              <p className="font-mono-stat mt-1" style={{ fontSize:9, color:'#7FA0C9' }}>{boss.subtitle}</p>
            </div>

            {/* HP BAR — oversized, ornate */}
            <div className="mb-2">
              <div className="flex items-center justify-between mb-2">
                <div className="flex items-center gap-2">
                  <span className="font-orbitron font-bold" style={{ fontSize:16, color:'#FF5A36' }}>HP</span>
                  <span className="font-mono-stat" style={{ fontSize:11, color:'#FF9B3E' }}>BOSS</span>
                </div>
                <span className="font-mono-stat" style={{ fontSize:16, color:'#EAF6FF' }}>
                  {boss.hp.toLocaleString()} <span style={{ color:'#3E5578' }}>/ {boss.maxHp.toLocaleString()}</span>
                </span>
              </div>
              {/* Thick bar with segments */}
              <div className="relative h-5 rounded-sm overflow-hidden"
                style={{ background:'rgba(0,0,0,.6)', border:'1px solid rgba(255,90,54,.35)', boxShadow:'0 0 12px rgba(255,90,54,.15)' }}>
                <div className="h-full progress-shimmer"
                  style={{ width:`${hpPct*100}%`, background:'linear-gradient(90deg,#FF5A36,#FF9B3E)', boxShadow:'0 0 12px rgba(255,90,54,.5)', transition:'width .8s cubic-bezier(.16,1,.3,1)' }}/>
                {/* Segment ticks */}
                {[20,40,60,80].map(pct => (
                  <div key={pct} className="absolute top-0 bottom-0 w-px" style={{ left:`${pct}%`, background:'rgba(3,7,18,.6)' }}/>
                ))}
              </div>
              <div className="flex justify-between mt-1">
                <span className="font-mono-stat" style={{ fontSize:8, color:'#3E5578' }}>0x0000</span>
                <span className="font-mono-stat" style={{ fontSize:8, color:'#FF5A36', animation:'uplink-pulse 2s ease-in-out infinite' }}>
                  {Math.round(hpPct*100)}% REMAINING
                </span>
                <span className="font-mono-stat" style={{ fontSize:8, color:'#3E5578' }}>MAX</span>
              </div>
            </div>

            <DiamondDivider/>

            {/* Meta chips */}
            <div className="flex items-center justify-between">
              <RewardChip exp={boss.exp} gold={boss.gold}/>
              <div className="flex items-center gap-1 glass-panel rounded-full px-2 py-1"
                style={{ border:'1px solid rgba(255,46,77,.3)' }}>
                <span style={{ fontSize:10 }}>⏱</span>
                <span className="font-mono-stat" style={{ fontSize:10, color:'#FF2E4D' }}>{boss.deadline}</span>
              </div>
            </div>
          </div>
        </OrnatePanel>

        {/* Attack Log */}
        <div>
          <div className="flex items-center gap-2 mb-2">
            <div className="w-1 h-4 rounded-full" style={{ background:'linear-gradient(to bottom,#FF9B3E,#FF5A36)' }}/>
            <h2 className="font-orbitron font-bold uppercase tracking-wide-2" style={{ fontSize:13, color:'#EAF6FF' }}>ATTACK LOG</h2>
          </div>
          <div className="glass-panel rounded-2xl overflow-hidden" style={{ border:'1px solid rgba(62,230,245,.12)' }}>
            {attackLog.map((log, i) => (
              <div key={log.id} className="flex items-center gap-3 px-3 py-2.5"
                style={{ borderBottom: i < attackLog.length-1 ? '1px solid rgba(62,230,245,.07)' : 'none' }}>
                <RankBadge rank={log.rank} size="sm"/>
                <div className="flex-1 min-w-0">
                  <p className="font-rajdhani font-semibold truncate" style={{ fontSize:12, color:'#EAF6FF' }}>{log.action}</p>
                  <p className="font-mono-stat" style={{ fontSize:9, color:'#3E5578' }}>{log.time}</p>
                </div>
                <span className="font-mono-stat flex-shrink-0" style={{ fontSize:12, color:'#FF5A36', fontWeight:700 }}>
                  {log.dmg.toLocaleString()} HP
                </span>
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* Attack CTA */}
      <div className="absolute bottom-0 left-0 right-0 px-4 pb-6 pt-3"
        style={{ background:'linear-gradient(to top,rgba(3,7,18,.95) 0%,transparent 100%)' }}>
        <button onClick={onFocusMode}
          className="w-full py-4 rounded-2xl font-orbitron font-black uppercase tracking-system transition-all active:scale-95"
          style={{ fontSize:15, background:'linear-gradient(135deg,#FF9B3E,#C4171C)', color:'#fff', boxShadow:'0 0 30px rgba(255,155,62,.5),0 0 60px rgba(255,155,62,.2)' }}>
          ╳ ATTACK BOSS
        </button>
      </div>
    </main>
  )
}

function BossDefeated({ onBack }: { onBack: () => void }) {
  return (
    <div className="absolute inset-0 z-40 flex flex-col items-center justify-center void-bg circuit-overlay animate-fade-in px-5">
      <ScanlineSweep/>
      <div className="absolute inset-0"
        style={{ background:'radial-gradient(ellipse at center,rgba(255,210,76,.08) 0%,transparent 70%)' }}/>

      <div className="text-center mb-8">
        <div className="w-24 h-24 rounded-full mx-auto mb-4 flex items-center justify-center"
          style={{ background:'rgba(255,210,76,.15)', border:'2px solid #FFD24C', boxShadow:'0 0 48px rgba(255,210,76,.5)' }}>
          <span className="system-glyph system-glyph-hero">◈</span>
        </div>
        <p className="font-mono-stat mb-2" style={{ fontSize:10, color:'#FFD24C', letterSpacing:'.2em' }}>[ BOSS DEFEATED ]</p>
        <h1 className="font-orbitron font-black uppercase tracking-system"
          style={{ fontSize:22, color:'#FFD24C', textShadow:'0 0 30px rgba(255,210,76,.6)' }}>
          PROJECT DEFEATED
        </h1>
        <p className="font-rajdhani mt-2" style={{ fontSize:14, color:'#7FA0C9' }}>
          SHIP THE APP has been conquered. The System acknowledges your victory.
        </p>
      </div>

      <OrnatePanel className="w-full mb-6">
        <div className="p-5 pt-8">
          <p className="font-mono-stat text-center mb-4" style={{ fontSize:10, color:'#7FA0C9' }}>[ REWARDS DISTRIBUTED ]</p>
          <div className="flex justify-center gap-4 mb-3">
            <RewardChip exp={2000} gold={500}/>
          </div>
          <DiamondDivider/>
          <div className="space-y-1.5">
            {['TITLE UNLOCKED: DELIVERER', 'NEW BOSS AVAILABLE: EXPAND USERBASE', 'STAT BONUS: +3 INT, +2 PER'].map((r, i) => (
              <p key={i} className="font-mono-stat" style={{ fontSize:11, color:'#39FF88' }}>{'>'} {r}</p>
            ))}
          </div>
        </div>
      </OrnatePanel>

      <button onClick={onBack}
        className="w-full py-3 rounded-2xl font-orbitron font-bold uppercase tracking-system transition-all active:scale-95"
        style={{ fontSize:12, background:'linear-gradient(135deg,#FFD24C,#C98A1A)', color:'#030712' }}>
        CONTINUE →
      </button>
    </div>
  )
}

import { useState, useEffect } from 'react'
import { OrnatePanel, DiamondDivider, GlassCard } from '../components/SystemUI'

type PlayerSetup = { name: string; title: string; classes: string[]; chronotype: string; difficulty: string }
type Props = { onComplete: (setup: PlayerSetup) => void }

const STAT_CLASSES = [
  { id:'body',       label:'BODY',       stat:'STR / VIT',    desc:'Physical training. The body is the vessel of the hunter.',  color:'#FF5A36', icon:'⚡' },
  { id:'mind',       label:'MIND',       stat:'INT / PER',    desc:'Cognition and awareness. Knowledge is the sharpest blade.', color:'#2E9BFF', icon:'◈'  },
  { id:'craft',      label:'CRAFT',      stat:'AGI / INT',    desc:'Creation and mastery of skills. The forge of power.',       color:'#B26EFF', icon:'⚙'  },
  { id:'discipline', label:'DISCIPLINE', stat:'ALL STATS',    desc:'Consistency forges legends. The System rewards dedication.',color:'#FFD24C', icon:'◆'  },
]

const CHRONOTYPES = [
  {
    id:'early', label:'EARLY BIRD', subtitle:'PEAK: 06:00–10:00',
    desc:'Dawn is your gate. Clarity, raw power, uncontested hours.',
    color:'#FFD24C', icon:'☀',
    sparkline:[20,60,100,95,80,60,40,30,25,20,18,15],
  },
  {
    id:'night', label:'NIGHT OWL', subtitle:'PEAK: 22:00–02:00',
    desc:'Darkness is your dungeon. Deep focus, zero interruptions, infinite hours.',
    color:'#B26EFF', icon:'🌙',
    sparkline:[15,10,8,12,20,30,40,50,55,75,95,100],
  },
  {
    id:'custom', label:'CUSTOM WINDOW', subtitle:'SET YOUR OWN PEAK',
    desc:'The System adapts. Define your own optimal gate hours.',
    color:'#3EE6F5', icon:'◈',
    sparkline:[30,50,70,60,80,100,90,70,55,40,30,20],
  },
]

const BOOT_LINES = [
  '> SYSTEM INITIALIZING...',
  '> SCANNING FOR DIMENSIONAL RIFT...',
  '> DETECTING LIFE SIGNATURE...',
  '> NEURAL INTERFACE CALIBRATION: 100%',
  '> ANOMALY DETECTED — IRREGULAR SOUL DETECTED',
  '> EVALUATING QUALIFICATION...',
  '> ...',
]

export default function Onboarding({ onComplete }: Props) {
  const [step, setStep] = useState(0)
  const [bootLine, setBootLine] = useState(0)
  const [showWindow, setShowWindow] = useState(false)
  const [selectedClasses, setSelectedClasses] = useState<string[]>([])
  const [chronotype, setChronotype] = useState('')
  const [difficulty, setDifficulty] = useState('')
  const [name, setName] = useState('')
  const [title, setTitle] = useState('')
  const [ariseReady, setAriseReady] = useState(false)

  /* Boot sequence lines */
  useEffect(() => {
    if (step !== 0) return
    let i = 0
    const interval = setInterval(() => {
      if (i < BOOT_LINES.length - 1) { setBootLine(prev => prev + 1); i++ }
      else { clearInterval(interval); setTimeout(() => setShowWindow(true), 600) }
    }, 340)
    return () => clearInterval(interval)
  }, [step])

  /* ARISE button reveal delay */
  useEffect(() => {
    if (step === 5) { const t = setTimeout(() => setAriseReady(true), 800); return () => clearTimeout(t) }
  }, [step])

  function toggleClass(id: string) {
    setSelectedClasses(prev => prev.includes(id) ? prev.filter(c => c !== id) : [...prev, id])
  }

  function handleArise() {
    onComplete({
      name: name.trim() || 'HUNTER',
      title: title.trim() || 'THE AWAKENED',
      classes: selectedClasses.length > 0 ? selectedClasses : ['discipline'],
      chronotype: chronotype || 'early',
      difficulty: difficulty || 'casual',
    })
  }

  /* ── STEP 0: BOOT SEQUENCE ── */
  if (step === 0) {
    return (
      <div className="flex flex-col justify-center h-full px-6 py-12 void-bg-full circuit-overlay">
        <div className="mb-8 space-y-2">
          {BOOT_LINES.slice(0, bootLine + 1).map((line, i) => (
            <p key={i} className="font-mono-stat animate-boot"
              style={{ fontSize:13, color: i === bootLine ? '#3EE6F5' : '#3E5578', animationDelay:`${i * 0.05}s` }}>
              {line}{i === bootLine && <span className="animate-flicker">█</span>}
            </p>
          ))}
        </div>
        {showWindow && (
          <OrnatePanel className="animate-level-flash p-6 pt-8">
            <div className="text-center">
              <p className="font-orbitron font-bold tracking-system uppercase mb-4" style={{ fontSize:11, color:'#3EE6F5' }}>
                ⚠ SYSTEM MESSAGE
              </p>
              <DiamondDivider/>
              <p className="font-orbitron font-bold uppercase leading-tight mt-4"
                style={{ fontSize:18, color:'#EAF6FF', letterSpacing:'0.06em', lineHeight:1.3 }}>
                YOU HAVE ACQUIRED THE QUALIFICATION TO BECOME A PLAYER.
              </p>
              <DiamondDivider/>
              <p className="font-rajdhani mt-3 leading-relaxed" style={{ fontSize:13, color:'#7FA0C9' }}>
                [ The System has recognized your potential. <br/>
                From this moment forward, your life will be<br/>
                measured, scored, and judged accordingly. ]
              </p>
              <button onClick={() => setStep(1)}
                className="mt-6 w-full py-3 rounded font-orbitron font-bold tracking-system uppercase transition-all active:scale-95"
                style={{ fontSize:12, background:'linear-gradient(135deg,rgba(62,230,245,0.15),rgba(62,230,245,0.05))', border:'1px solid rgba(62,230,245,0.5)', color:'#3EE6F5', boxShadow:'0 0 16px rgba(62,230,245,0.2)' }}>
                [ ACCEPT DESIGNATION ]
              </button>
            </div>
          </OrnatePanel>
        )}
      </div>
    )
  }

  /* ── STEP 1: CLASS ASSESSMENT ── */
  if (step === 1) {
    return (
      <div className="flex flex-col h-full px-4 py-12 void-bg-full overflow-y-auto">
        <StepHeader current={1} total={5} label="CLASS ASSESSMENT" sub="Choose the domains you wish to conquer."/>
        <div className="space-y-3 flex-1">
          {STAT_CLASSES.map(cls => {
            const selected = selectedClasses.includes(cls.id)
            return (
              <button key={cls.id} onClick={() => toggleClass(cls.id)} className="w-full text-left transition-all active:scale-98">
                <div className="glass-panel rounded-xl p-4"
                  style={{ border:`1px solid ${selected ? cls.color : 'rgba(62,230,245,0.15)'}`, boxShadow: selected ? `0 0 20px ${cls.color}30` : 'none', transition:'all 0.2s ease' }}>
                  <div className="flex items-center gap-3">
                    <div className="w-10 h-10 rounded-lg flex items-center justify-center text-xl flex-shrink-0"
                      style={{ background:`${cls.color}15`, border:`1px solid ${cls.color}40` }}>{cls.icon}</div>
                    <div className="flex-1">
                      <div className="flex items-center gap-2 mb-0.5">
                        <span className="font-orbitron font-bold uppercase" style={{ fontSize:14, color: selected ? cls.color : '#EAF6FF' }}>{cls.label}</span>
                        <span className="font-mono-stat" style={{ fontSize:10, color:'#3E5578' }}>+{cls.stat}</span>
                      </div>
                      <p className="font-rajdhani" style={{ fontSize:12, color:'#7FA0C9' }}>{cls.desc}</p>
                    </div>
                    <div className="w-5 h-5 rounded flex items-center justify-center flex-shrink-0"
                      style={{ background: selected ? cls.color : 'transparent', border:`1.5px solid ${selected ? cls.color : '#3E5578'}` }}>
                      {selected && <span style={{ color:'#000', fontSize:10, fontWeight:700 }}>✓</span>}
                    </div>
                  </div>
                </div>
              </button>
            )
          })}
        </div>
        <button onClick={() => setStep(2)} disabled={selectedClasses.length === 0}
          className="mt-4 w-full py-3.5 rounded-xl font-orbitron font-bold tracking-system uppercase transition-all active:scale-95"
          style={{ fontSize:13, background: selectedClasses.length > 0 ? 'linear-gradient(135deg,#3EE6F5,#1FA9C2)' : 'rgba(62,230,245,0.05)', color: selectedClasses.length > 0 ? '#000' : '#3E5578', border:'1px solid rgba(62,230,245,0.3)', boxShadow: selectedClasses.length > 0 ? '0 0 24px rgba(62,230,245,0.4)' : 'none' }}>
          CONFIRM ASSESSMENT →
        </button>
      </div>
    )
  }

  /* ── STEP 2: CHRONOTYPE ── */
  if (step === 2) {
    return (
      <div className="flex flex-col h-full px-4 py-10 void-bg-full overflow-y-auto">
        <StepHeader current={2} total={5} label="CHRONOTYPE SCAN" sub="WHEN DOES YOUR ENERGY PEAK?"/>
        <div className="space-y-3 flex-1">
          {CHRONOTYPES.map(ct => {
            const selected = chronotype === ct.id
            return (
              <button key={ct.id} onClick={() => setChronotype(ct.id)} className="w-full text-left transition-all active:scale-98">
                <GlassCard className="p-4"
                  style={{ border:`1px solid ${selected ? ct.color : 'rgba(62,230,245,.15)'}`, boxShadow: selected ? `0 0 20px ${ct.color}25` : 'none' }}>
                  <div className="flex items-start gap-3 mb-3">
                    <div className="w-10 h-10 rounded-lg flex items-center justify-center text-xl flex-shrink-0"
                      style={{ background:`${ct.color}12`, border:`1px solid ${ct.color}35` }}>{ct.icon}</div>
                    <div className="flex-1">
                      <p className="font-orbitron font-bold uppercase" style={{ fontSize:13, color: selected ? ct.color : '#EAF6FF' }}>{ct.label}</p>
                      <p className="font-mono-stat" style={{ fontSize:9, color:'#7FA0C9' }}>{ct.subtitle}</p>
                      <p className="font-rajdhani mt-1" style={{ fontSize:11, color:'#7FA0C9' }}>{ct.desc}</p>
                    </div>
                    <div className="w-5 h-5 rounded flex-shrink-0 flex items-center justify-center"
                      style={{ background: selected ? ct.color : 'transparent', border:`1.5px solid ${selected ? ct.color : '#3E5578'}` }}>
                      {selected && <span style={{ color:'#000', fontSize:10, fontWeight:700 }}>✓</span>}
                    </div>
                  </div>
                  {/* Sparkline */}
                  <div className="relative h-8 flex items-end gap-px">
                    {ct.sparkline.map((v, i) => (
                      <div key={i} className="flex-1 rounded-t-sm"
                        style={{ height:`${v}%`, background: selected ? `${ct.color}${Math.round(40 + v * 0.6).toString(16)}` : 'rgba(62,230,245,.15)', transition:'all .3s ease' }}/>
                    ))}
                  </div>
                  <div className="flex justify-between mt-1">
                    <span className="font-mono-stat" style={{ fontSize:7, color:'#3E5578' }}>00:00</span>
                    <span className="font-mono-stat" style={{ fontSize:7, color:'#3E5578' }}>ENERGY CURVE</span>
                    <span className="font-mono-stat" style={{ fontSize:7, color:'#3E5578' }}>24:00</span>
                  </div>
                </GlassCard>
              </button>
            )
          })}
        </div>
        <button onClick={() => setStep(3)} disabled={!chronotype}
          className="mt-4 w-full py-3.5 rounded-xl font-orbitron font-bold tracking-system uppercase transition-all active:scale-95"
          style={{ fontSize:13, background: chronotype ? 'linear-gradient(135deg,#3EE6F5,#1FA9C2)' : 'rgba(62,230,245,.05)', color: chronotype ? '#000' : '#3E5578', border:'1px solid rgba(62,230,245,.3)', boxShadow: chronotype ? '0 0 24px rgba(62,230,245,.4)' : 'none' }}>
          SYNC CHRONOTYPE →
        </button>
      </div>
    )
  }

  /* ── STEP 3: DIFFICULTY MODE ── */
  if (step === 3) {
    return (
      <div className="flex flex-col h-full px-4 py-10 void-bg-full overflow-y-auto">
        <StepHeader current={3} total={5} label="DIFFICULTY MODE" sub="Choose your terms with the System."/>
        <div className="space-y-4 flex-1">

          {/* CASUAL */}
          <button onClick={() => setDifficulty('casual')} className="w-full text-left transition-all active:scale-98">
            <GlassCard className="p-4"
              style={{ border: difficulty === 'casual' ? '1px solid #39FF88' : '1px solid rgba(62,230,245,.15)', boxShadow: difficulty === 'casual' ? '0 0 20px rgba(57,255,136,.2)' : 'none' }}>
              <div className="flex items-start gap-3 mb-3">
                <div className="w-10 h-10 rounded-lg flex items-center justify-center text-2xl flex-shrink-0"
                  style={{ background:'rgba(57,255,136,.1)', border:'1px solid rgba(57,255,136,.3)' }}>🛡</div>
                <div className="flex-1">
                  <p className="font-orbitron font-bold uppercase" style={{ fontSize:15, color: difficulty === 'casual' ? '#39FF88' : '#EAF6FF' }}>CASUAL</p>
                  <p className="font-mono-stat mb-2" style={{ fontSize:9, color:'#39FF88' }}>FOR THE AWAKENING HUNTER</p>
                  <p className="font-rajdhani" style={{ fontSize:12, color:'#7FA0C9' }}>
                    The System is forgiving. Miss a quest — lose XP, no stat decay. Penalties are soft. Great for building habits without fear.
                  </p>
                </div>
                {difficulty === 'casual' && <span style={{ color:'#39FF88', fontSize:18 }}>✓</span>}
              </div>
              <div className="space-y-1">
                {['Missed quests: EXP loss only', 'No stat decay', 'Penalties: optional', 'Encouragement over punishment'].map((t, i) => (
                  <p key={i} className="font-mono-stat" style={{ fontSize:10, color:'#39FF88' }}>{'>'} {t}</p>
                ))}
              </div>
            </GlassCard>
          </button>

          {/* HARDCORE */}
          <button onClick={() => setDifficulty('hardcore')} className="w-full text-left transition-all active:scale-98">
            <GlassCard className="p-4"
              style={{ border: difficulty === 'hardcore' ? '1px solid #FF2E4D' : '1px solid rgba(62,230,245,.15)', boxShadow: difficulty === 'hardcore' ? '0 0 20px rgba(255,46,77,.2)' : 'none' }}>
              <div className="flex items-start gap-3 mb-3">
                <div className="w-10 h-10 rounded-lg flex items-center justify-center text-2xl flex-shrink-0"
                  style={{ background:'rgba(255,46,77,.1)', border:'1px solid rgba(255,46,77,.3)' }}>⚔</div>
                <div className="flex-1">
                  <p className="font-orbitron font-bold uppercase" style={{ fontSize:15, color: difficulty === 'hardcore' ? '#FF2E4D' : '#EAF6FF' }}>HARDCORE RPG</p>
                  <p className="font-mono-stat mb-2" style={{ fontSize:9, color:'#FF2E4D' }}>FOR THE SOVEREIGN HUNTER</p>
                  <p className="font-rajdhani" style={{ fontSize:12, color:'#7FA0C9' }}>
                    No mercy. Miss a quest — stat decay, penalty assignments, dungeon lockout. The System forges or breaks you.
                  </p>
                </div>
                {difficulty === 'hardcore' && <span style={{ color:'#FF2E4D', fontSize:18 }}>⚠</span>}
              </div>
              <div className="space-y-1">
                {['Missed quests: stat decay + penalty quest', 'Full penalty protocol active', 'Dungeon lockout on 3-day miss', 'No compromises. No excuses.'].map((t, i) => (
                  <p key={i} className="font-mono-stat" style={{ fontSize:10, color:'#FF2E4D' }}>{'!'} {t}</p>
                ))}
              </div>
            </GlassCard>
          </button>

        </div>
        <button onClick={() => setStep(4)} disabled={!difficulty}
          className="mt-4 w-full py-3.5 rounded-xl font-orbitron font-bold tracking-system uppercase transition-all active:scale-95"
          style={{ fontSize:13, background: difficulty ? 'linear-gradient(135deg,#3EE6F5,#1FA9C2)' : 'rgba(62,230,245,.05)', color: difficulty ? '#000' : '#3E5578', border:'1px solid rgba(62,230,245,.3)', boxShadow: difficulty ? '0 0 24px rgba(62,230,245,.4)' : 'none' }}>
          LOCK IN MODE →
        </button>
      </div>
    )
  }

  /* ── STEP 4: NAME ENTRY ── */
  if (step === 4) {
    return (
      <div className="flex flex-col justify-center h-full px-4 void-bg-full">
        <StepHeader current={4} total={5} label="DESIGNATION" sub="Your name will be recorded in the System."/>
        <OrnatePanel className="p-6 pt-8">
          <div className="space-y-5">
            <div>
              <label className="font-orbitron uppercase tracking-system block mb-2" style={{ fontSize:10, color:'#7FA0C9' }}>NAME:</label>
              <input type="text" value={name} onChange={e => setName(e.target.value)} placeholder="ENTER HUNTER NAME"
                maxLength={20} className="terminal-input-cyan"
                style={{ fontFamily:"'Orbitron', sans-serif", fontSize:14, fontWeight:700, letterSpacing:'.08em', textTransform:'uppercase' }}/>
            </div>
            <DiamondDivider/>
            <div>
              <label className="font-orbitron uppercase tracking-system block mb-2" style={{ fontSize:10, color:'#7FA0C9' }}>PLAYER TITLE:</label>
              <input type="text" value={title} onChange={e => setTitle(e.target.value)} placeholder="THE AWAKENED"
                maxLength={24} className="w-full px-3 py-3 rounded-lg font-orbitron uppercase outline-none transition-all"
                style={{ background:'rgba(10,26,58,0.8)', fontSize:13, color:'#FFD24C', border:'1px solid rgba(255,210,76,0.35)', letterSpacing:'.08em', caretColor:'#FFD24C' }}/>
            </div>
            <p className="font-rajdhani text-center" style={{ fontSize:11, color:'#3E5578' }}>
              [ This designation will be recorded permanently<br/>in the System's registry. ]
            </p>
          </div>
        </OrnatePanel>
        <button onClick={() => setStep(5)}
          className="mt-6 w-full py-3.5 rounded-xl font-orbitron font-bold tracking-system uppercase transition-all active:scale-95"
          style={{ fontSize:13, background:'linear-gradient(135deg,rgba(62,230,245,0.15),rgba(62,230,245,0.05))', border:'1px solid rgba(62,230,245,0.5)', color:'#3EE6F5', boxShadow:'0 0 16px rgba(62,230,245,0.2)' }}>
          REGISTER IDENTITY →
        </button>
      </div>
    )
  }

  /* ── STEP 5: ARISE ── */
  return (
    <div className="flex flex-col items-center justify-center h-full void-bg-full circuit-overlay relative overflow-hidden">
      {Array.from({ length: 12 }).map((_, i) => (
        <div key={i} className="absolute w-0.5 h-0.5 rounded-full"
          style={{ background:'#3EE6F5', left:`${10+(i*7)}%`, bottom:'10%', animation:`float-particle ${2+(i%3)}s ${i*0.3}s linear infinite`, '--drift':`${(i%2===0?1:-1)*(10+i*4)}px` } as React.CSSProperties}/>
      ))}
      <div className="absolute inset-0 flex items-center justify-center pointer-events-none">
        {[160,220,280].map((size, i) => (
          <div key={i} className="absolute rounded-full"
            style={{ width:size, height:size, border:`1px solid rgba(62,230,245,${0.15-i*0.04})`, animation:`portal-spin ${12+i*4}s linear infinite`, animationDirection: i%2===0 ? 'normal' : 'reverse' }}/>
        ))}
      </div>
      <div className="relative z-10 text-center px-8">
        <p className="font-mono-stat mb-4 animate-flicker" style={{ fontSize:11, color:'#7FA0C9' }}>[ THE SYSTEM IS READY ]</p>
        <h1 className="font-orbitron font-black uppercase mb-2"
          style={{ fontSize:48, color:'#EAF6FF', letterSpacing:'0.15em', textShadow:'0 0 40px rgba(62,230,245,0.6)' }}>ARISE</h1>
        <p className="font-rajdhani mb-8" style={{ fontSize:15, color:'#7FA0C9', letterSpacing:'.05em' }}>
          {name.trim() ? `Hunter ${name.toUpperCase()}` : 'Hunter'} — your journey begins.
        </p>
        {ariseReady && (
          <button onClick={handleArise}
            className="animate-level-flash px-12 py-5 rounded-xl font-orbitron font-bold uppercase tracking-system transition-all active:scale-95"
            style={{ fontSize:16, background:'linear-gradient(135deg,#3EE6F5 0%,#1FA9C2 100%)', color:'#030712', boxShadow:'0 0 32px rgba(62,230,245,0.6),0 0 64px rgba(62,230,245,0.2)', border:'2px solid #3EE6F5' }}>
            ENTER THE SYSTEM
          </button>
        )}
      </div>
    </div>
  )
}

function StepHeader({ current, total, label, sub }: { current:number; total:number; label:string; sub:string }) {
  return (
    <div className="text-center mb-5">
      <p className="font-mono-stat" style={{ fontSize:9, color:'#3E5578' }}>STEP {current} OF {total}</p>
      <p className="font-mono-stat mb-1 animate-flicker" style={{ fontSize:11, color:'#3EE6F5' }}>[ {label} ]</p>
      <h1 className="font-orbitron font-bold uppercase tracking-system" style={{ fontSize:18, color:'#EAF6FF' }}>{sub}</h1>
    </div>
  )
}

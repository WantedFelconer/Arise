import { useState, useEffect } from 'react'
import { OrnatePanel, DiamondDivider } from '../components/SystemUI'

type Props = { oldLevel: number; newLevel: number; newPoints: number; onContinue: () => void }

export default function LevelUp({ oldLevel, newLevel, newPoints, onContinue }: Props) {
  const [phase, setPhase] = useState<'flash' | 'reveal' | 'done'>('flash')

  useEffect(() => {
    const t1 = setTimeout(() => setPhase('reveal'), 600)
    const t2 = setTimeout(() => setPhase('done'), 1400)
    return () => { clearTimeout(t1); clearTimeout(t2) }
  }, [])

  const UNLOCKED_SKILL = newLevel % 5 === 0 ? 'SHADOW STEP LV.1' : null
  const UNLOCKED_TITLE = newLevel === 15 ? 'IRON WILL' : null

  return (
    <div className="absolute inset-0 z-50 flex flex-col items-center justify-center overflow-hidden" style={{ background: '#030712' }}>
      {/* Flash overlay */}
      {phase === 'flash' && (
        <div className="absolute inset-0 animate-fade-in" style={{ background: 'rgba(62,230,245,0.3)' }} />
      )}

      {/* Particles */}
      {phase !== 'flash' && Array.from({ length: 20 }).map((_, i) => (
        <div key={i} className="absolute rounded-full" style={{
          width: Math.random() > 0.5 ? 3 : 2,
          height: Math.random() > 0.5 ? 3 : 2,
          background: i % 3 === 0 ? '#FFD24C' : i % 3 === 1 ? '#3EE6F5' : '#39FF88',
          left: `${10 + (i * 4.5) % 80}%`,
          bottom: `${15 + (i * 3) % 50}%`,
          animation: `float-particle ${1.5 + (i % 4) * 0.5}s ${i * 0.1}s ease-out forwards`,
          '--drift': `${(i % 2 === 0 ? 1 : -1) * (15 + i * 8)}px`,
          filter: `drop-shadow(0 0 4px currentColor)`,
        } as React.CSSProperties} />
      ))}

      {/* Rotating rings */}
      <div className="absolute inset-0 flex items-center justify-center pointer-events-none">
        {[180, 240, 300].map((s, i) => (
          <div key={i} className="absolute rounded-full" style={{
            width: s, height: s,
            border: `1.5px solid rgba(62,230,245,${0.2 - i * 0.05})`,
            animation: `portal-spin ${6 + i * 3}s linear infinite`,
            animationDirection: i % 2 === 0 ? 'normal' : 'reverse',
          }} />
        ))}
      </div>

      {phase !== 'flash' && (
        <OrnatePanel cornerSize={32} className="animate-level-flash mx-6 relative z-10">
          <div className="p-6 pt-10 text-center">
            {/* LEVEL UP header */}
            <p className="font-mono-stat mb-2 animate-flicker" style={{ fontSize: 11, color: '#7FA0C9' }}>
              [ SYSTEM NOTIFICATION ]
            </p>
            <h1
              className="font-orbitron font-black uppercase"
              style={{ fontSize: 32, color: '#3EE6F5', letterSpacing: '0.1em', textShadow: '0 0 40px rgba(62,230,245,0.8)' }}
            >
              LEVEL UP!
            </h1>

            <DiamondDivider />

            {/* Level counter */}
            <div className="flex items-center justify-center gap-4 my-4">
              <div className="text-center">
                <p className="font-orbitron font-black" style={{ fontSize: 36, color: '#3E5578' }}>{oldLevel}</p>
                <p className="font-mono-stat" style={{ fontSize: 9, color: '#3E5578' }}>PREVIOUS</p>
              </div>
              <div className="text-center">
                <p className="font-orbitron font-bold" style={{ fontSize: 22, color: '#3EE6F5' }}>→</p>
              </div>
              <div className="text-center">
                <p
                  className="font-orbitron font-black"
                  style={{ fontSize: 52, color: '#FFD24C', textShadow: '0 0 30px rgba(255,210,76,0.7)', lineHeight: 1 }}
                >
                  {newLevel}
                </p>
                <p className="font-mono-stat" style={{ fontSize: 9, color: '#FFD24C' }}>NEW LEVEL</p>
              </div>
            </div>

            <DiamondDivider />

            {/* Stat points */}
            <div className="glass-panel rounded-xl p-3 mb-3" style={{ border: '1px solid rgba(62,230,245,0.3)' }}>
              <p className="font-mono-stat" style={{ fontSize: 9, color: '#7FA0C9', marginBottom: 4 }}>STAT POINTS AWARDED</p>
              <p className="font-orbitron font-bold" style={{ fontSize: 22, color: '#3EE6F5' }}>+{newPoints} POINTS</p>
              <p className="font-mono-stat" style={{ fontSize: 9, color: '#7FA0C9' }}>Allocate via STATUS screen</p>
            </div>

            {/* Unlocked items */}
            {UNLOCKED_SKILL && (
              <div className="glass-panel rounded-xl p-3 mb-3" style={{ border: '1px solid rgba(178,110,255,0.4)' }}>
                <p className="font-mono-stat mb-1" style={{ fontSize: 9, color: '#B26EFF' }}>NEW SKILL UNLOCKED</p>
                <p className="font-orbitron font-bold uppercase" style={{ fontSize: 13, color: '#EAF6FF' }}>
                  ⚡ {UNLOCKED_SKILL}
                </p>
              </div>
            )}

            {UNLOCKED_TITLE && (
              <div className="glass-panel rounded-xl p-3 mb-3" style={{ border: '1px solid rgba(255,210,76,0.4)' }}>
                <p className="font-mono-stat mb-1" style={{ fontSize: 9, color: '#FFD24C' }}>TITLE UNLOCKED</p>
                <p className="font-orbitron font-bold uppercase" style={{ fontSize: 13, color: '#FFD24C' }}>
                  ◆ {UNLOCKED_TITLE}
                </p>
              </div>
            )}

            {/* Continue */}
            {phase === 'done' && (
              <button
                onClick={onContinue}
                className="w-full py-3.5 rounded-xl font-orbitron font-bold uppercase tracking-system transition-all active:scale-95"
                style={{
                  fontSize: 12, background: 'linear-gradient(135deg, #3EE6F5, #1FA9C2)',
                  color: '#030712', boxShadow: '0 0 24px rgba(62,230,245,0.4)',
                }}
              >
                CONTINUE
              </button>
            )}
          </div>
        </OrnatePanel>
      )}
    </div>
  )
}

import { useState, useEffect } from 'react'
import { DiamondDivider } from '../components/SystemUI'

type Props = { onAcknowledge: () => void; missedQuest?: string }

export default function Penalty({ onAcknowledge, missedQuest = '10KM RUN' }: Props) {
  const [acknowledged, setAcknowledged] = useState(false)
  const [countdown, setCountdown] = useState(23 * 3600 + 59 * 60 + 47)
  const [shake, setShake] = useState(true)

  useEffect(() => {
    const t = setTimeout(() => setShake(false), 600)
    return () => clearTimeout(t)
  }, [])

  useEffect(() => {
    const interval = setInterval(() => setCountdown(s => Math.max(0, s - 1)), 1000)
    return () => clearInterval(interval)
  }, [])

  const hh = String(Math.floor(countdown / 3600)).padStart(2, '0')
  const mm = String(Math.floor((countdown % 3600) / 60)).padStart(2, '0')
  const ss = String(countdown % 60).padStart(2, '0')

  return (
    <div className={`absolute inset-0 z-50 flex flex-col ${shake ? 'animate-shake' : ''}`}
      style={{ background: 'radial-gradient(ellipse at center, #1a0008 0%, #030712 100%)' }}
    >
      {/* Red vignette */}
      <div className="absolute inset-0 pointer-events-none penalty-vignette" />

      {/* Scan line effect */}
      <div className="absolute inset-0 overflow-hidden pointer-events-none">
        <div className="w-full h-8 animate-scan" style={{
          background: 'linear-gradient(to bottom, transparent, rgba(255,46,77,0.06), transparent)',
        }} />
      </div>

      <div className="flex-1 flex flex-col items-center justify-center px-6 relative">

        {/* Warning indicator */}
        <div className="flex items-center gap-2 mb-6">
          <div className="w-3 h-3 rounded-full animate-pulse-danger" style={{ background: '#FF2E4D' }} />
          <span className="font-mono-stat tracking-system" style={{ fontSize: 11, color: '#FF2E4D' }}>
            SYSTEM ALERT — PENALTY PROTOCOL INITIATED
          </span>
          <div className="w-3 h-3 rounded-full animate-pulse-danger" style={{ background: '#FF2E4D' }} />
        </div>

        {/* Main header */}
        <p
          className="font-orbitron font-black uppercase text-center mb-2"
          style={{ fontSize: 28, color: '#FF2E4D', letterSpacing: '0.08em', textShadow: '0 0 40px rgba(255,46,77,0.8), 0 0 80px rgba(255,46,77,0.2)' }}
        >
          PENALTY QUEST ASSIGNED
        </p>

        <div className="flex items-center gap-3 mb-6">
          <div className="h-px flex-1" style={{ background: 'rgba(255,46,77,0.4)' }} />
          <span style={{ color: '#FF2E4D', fontSize: 12 }}>◆</span>
          <div className="h-px flex-1" style={{ background: 'rgba(255,46,77,0.4)' }} />
        </div>

        {/* Missed quest */}
        <div className="w-full glass-panel rounded-xl p-4 mb-4"
          style={{ border: '1px solid rgba(255,46,77,0.4)', background: 'rgba(255,46,77,0.05)' }}
        >
          <p className="font-mono-stat mb-1" style={{ fontSize: 9, color: '#7FA0C9' }}>FAILED QUEST</p>
          <p className="font-orbitron font-bold uppercase" style={{ fontSize: 16, color: '#EAF6FF' }}>{missedQuest}</p>
          <p className="font-rajdhani mt-1" style={{ fontSize: 12, color: '#FF2E4D' }}>
            Daily quota not met. The System does not tolerate inaction.
          </p>
        </div>

        {/* Penalty consequence */}
        <div className="w-full glass-panel rounded-xl p-4 mb-6"
          style={{ border: '1px solid rgba(255,46,77,0.3)', background: 'rgba(255,46,77,0.03)' }}
        >
          <p className="font-mono-stat mb-2" style={{ fontSize: 9, color: '#7FA0C9' }}>CONSEQUENCE ISSUED</p>
          <div className="space-y-2">
            {[
              { icon: '−', label: '−150 EXP', desc: 'Immediate deduction', color: '#FF2E4D' },
              { icon: '○', label: 'PENALTY QUEST', desc: '200 Squats — complete within 24H', color: '#FF9B3E' },
              { icon: '⚡', label: 'STAT DECAY', desc: 'STR −1 if quest not cleared', color: '#FF2E4D' },
            ].map((item, i) => (
              <div key={i} className="flex items-center gap-3">
                <div className="w-6 h-6 rounded flex items-center justify-center flex-shrink-0"
                  style={{ background: `${item.color}15`, border: `1px solid ${item.color}40` }}>
                  <span style={{ color: item.color, fontSize: 12 }}>{item.icon}</span>
                </div>
                <div>
                  <p className="font-orbitron font-bold uppercase" style={{ fontSize: 11, color: item.color }}>{item.label}</p>
                  <p className="font-rajdhani" style={{ fontSize: 11, color: '#7FA0C9' }}>{item.desc}</p>
                </div>
              </div>
            ))}
          </div>
        </div>

        <DiamondDivider />

        {/* Countdown */}
        <div className="text-center mb-6">
          <p className="font-mono-stat mb-1" style={{ fontSize: 10, color: '#7FA0C9' }}>TIME REMAINING TO CLEAR PENALTY</p>
          <p className="font-mono-stat" style={{ fontSize: 36, color: '#FF2E4D', textShadow: '0 0 20px rgba(255,46,77,0.6)' }}>
            {hh}:{mm}:{ss}
          </p>
        </div>

        {/* System line */}
        <p
          className="font-orbitron uppercase text-center mb-8"
          style={{ fontSize: 11, color: '#3E5578', letterSpacing: '0.08em', lineHeight: 1.6 }}
        >
          "There is no room for excuses."<br />
          <span style={{ color: '#FF2E4D' }}>— THE SYSTEM</span>
        </p>

        {/* Acknowledge button */}
        <button
          onClick={() => { setAcknowledged(true); setTimeout(onAcknowledge, 300) }}
          disabled={acknowledged}
          className="w-full py-4 rounded-xl font-orbitron font-bold uppercase tracking-system transition-all active:scale-95"
          style={{
            fontSize: 13,
            background: acknowledged ? 'rgba(255,46,77,0.1)' : 'rgba(255,46,77,0.15)',
            border: '1px solid rgba(255,46,77,0.5)',
            color: '#FF2E4D',
            boxShadow: '0 0 20px rgba(255,46,77,0.2)',
          }}
        >
          [ I UNDERSTAND. I WILL NOT FAIL AGAIN. ]
        </button>
      </div>
    </div>
  )
}

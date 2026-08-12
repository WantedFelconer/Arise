import { useState, useEffect, useRef } from 'react'
import { BackendBridge } from '../services/backendBridge'

type Props = { onExit: (success: boolean) => void }

export default function FocusMode({ onExit }: Props) {
  const [seconds, setSeconds] = useState(25 * 60) // 25 minutes default
  const [running, setRunning] = useState(false)
  const [collapsed, setCollapsed] = useState(false)
  const [showExitWarning, setShowExitWarning] = useState(false)
  const [sessionDone, setSessionDone] = useState(false)
  const intervalRef = useRef<ReturnType<typeof setInterval> | null>(null)

  useEffect(() => {
    if (running && seconds > 0) {
      intervalRef.current = setInterval(() => setSeconds(s => s - 1), 1000)
    } else if (seconds === 0) {
      setRunning(false)
      setSessionDone(true)

      // Evaluate Gate Expedition outcome via backend GateEngine
      const outcome = BackendBridge.evaluateGateSession(25 * 60, 25 * 60, 0, false)
      console.log('[Backend Bridge] Gate Completed:', outcome)
    }
    return () => { if (intervalRef.current) clearInterval(intervalRef.current) }
  }, [running, seconds])


  const totalSeconds = 25 * 60
  const pct = seconds / totalSeconds
  const radius = 110
  const circ = 2 * Math.PI * radius
  const mm = String(Math.floor(seconds / 60)).padStart(2, '0')
  const ss = String(seconds % 60).padStart(2, '0')

  if (sessionDone) {
    return (
      <div className="absolute inset-0 z-50 flex flex-col items-center justify-center void-bg-full circuit-overlay">
        <div className="text-center px-8">
          <p className="font-mono-stat mb-2" style={{ fontSize: 11, color: '#39FF88' }}>[ GATE CLEARED ]</p>
          <p className="font-orbitron font-black uppercase" style={{ fontSize: 36, color: '#3EE6F5', textShadow: '0 0 40px rgba(62,230,245,0.8)' }}>
            VICTORY
          </p>
          <p className="font-rajdhani mt-2" style={{ fontSize: 14, color: '#7FA0C9' }}>
            You have returned from the Gate.<br />The System has recorded your effort.
          </p>
          <div className="mt-4 glass-panel rounded-xl p-3" style={{ border: '1px solid rgba(57,255,136,0.3)' }}>
            <p className="font-mono-stat" style={{ fontSize: 12, color: '#39FF88' }}>+200 EXP · Gate Complete</p>
          </div>
          <button
            onClick={() => onExit(true)}
            className="mt-6 px-10 py-3 rounded-xl font-orbitron font-bold uppercase tracking-system transition-all active:scale-95"
            style={{ fontSize: 12, background: 'linear-gradient(135deg, #3EE6F5, #1FA9C2)', color: '#030712' }}
          >
            RETURN TO BASE
          </button>
        </div>
      </div>
    )
  }

  if (collapsed) {
    return (
      <div className="absolute inset-0 z-50 flex flex-col items-center justify-center animate-fade-in" style={{ background: 'rgba(3,7,18,0.97)' }}>
        <div className="animate-shake text-center px-8">
          {/* Gate collapse visual */}
          <div className="w-32 h-32 mx-auto mb-6 relative flex items-center justify-center">
            {[80, 100, 120].map((s, i) => (
              <div key={i} className="absolute rounded-full" style={{
                width: s, height: s,
                border: '2px solid rgba(255,46,77,0.4)',
                animation: `portal-spin ${3 + i}s linear infinite`,
                animationDirection: i % 2 === 0 ? 'normal' : 'reverse',
                filter: 'drop-shadow(0 0 6px rgba(255,46,77,0.5))',
              }} />
            ))}
            <span style={{ fontSize: 32, filter: 'grayscale(1)' }}>⬡</span>
          </div>
          <p className="font-orbitron font-black uppercase mb-3" style={{ fontSize: 24, color: '#FF2E4D', textShadow: '0 0 30px rgba(255,46,77,0.8)' }}>
            THE GATE HAS COLLAPSED
          </p>
          <p className="font-rajdhani mb-4" style={{ fontSize: 13, color: '#7FA0C9' }}>
            [ You abandoned the Gate before clearing it. ]<br />
            The System has registered your failure.
          </p>
          <div className="glass-panel rounded-xl p-4 mb-6" style={{ border: '1px solid rgba(255,46,77,0.4)' }}>
            <p className="font-mono-stat" style={{ fontSize: 11, color: '#FF2E4D' }}>
              −150 EXP · Gate Abandoned<br />
              STREAK RESET TO 0<br />
              PENALTY QUEST ASSIGNED
            </p>
          </div>
          <button
            onClick={() => onExit(false)}
            className="px-8 py-3 rounded-xl font-orbitron font-bold uppercase tracking-system transition-all active:scale-95"
            style={{ fontSize: 11, border: '1px solid rgba(255,46,77,0.4)', color: '#FF2E4D' }}
          >
            ACKNOWLEDGE FAILURE
          </button>
        </div>
      </div>
    )
  }

  return (
    <div className="absolute inset-0 z-50 flex flex-col void-bg-full circuit-overlay overflow-hidden">
      {/* Ambient particles */}
      {Array.from({ length: 16 }).map((_, i) => (
        <div key={i} className="absolute w-px h-px rounded-full" style={{
          background: '#3EE6F5',
          left: `${5 + (i * 6) % 90}%`,
          bottom: '5%',
          animation: `float-particle ${3 + (i % 4)}s ${i * 0.25}s linear infinite`,
          '--drift': `${(i % 2 === 0 ? 1 : -1) * (8 + i * 5)}px`,
        } as React.CSSProperties} />
      ))}

      {/* Top bar */}
      <div className="flex items-center justify-between px-5 pt-10 pb-4">
        <div>
          <p className="font-mono-stat" style={{ fontSize: 10, color: '#3E5578' }}>[ GATE ENTRY — FOCUS MODE ]</p>
          <p className="font-orbitron font-bold uppercase" style={{ fontSize: 14, color: '#EAF6FF' }}>
            DEEP WORK SESSION
          </p>
        </div>
        <button
          onClick={() => setShowExitWarning(true)}
          className="font-mono-stat transition-all active:scale-90"
          style={{ fontSize: 10, color: '#3E5578', border: '1px solid rgba(62,230,245,0.1)', padding: '4px 8px', borderRadius: 6 }}
        >
          EXIT
        </button>
      </div>

      {/* Portal visual + timer */}
      <div className="flex-1 flex flex-col items-center justify-center">
        {/* Rotating rings */}
        <div className="relative flex items-center justify-center" style={{ width: 280, height: 280 }}>
          {[200, 230, 250].map((s, i) => (
            <div key={i} className="absolute rounded-full" style={{
              width: s, height: s,
              border: `${2 - i * 0.5}px solid rgba(62,230,245,${0.3 - i * 0.08})`,
              animation: `portal-spin ${8 + i * 4}s linear infinite`,
              animationDirection: i % 2 === 0 ? 'normal' : 'reverse',
            }} />
          ))}

          {/* Progress ring */}
          <svg width="260" height="260" className="absolute">
            <defs>
              <linearGradient id="timer-grad" x1="0%" y1="0%" x2="100%" y2="0%">
                <stop offset="0%" stopColor="#3EE6F5" />
                <stop offset="100%" stopColor="#1FA9C2" />
              </linearGradient>
            </defs>
            <circle cx="130" cy="130" r={radius} fill="none" stroke="rgba(62,230,245,0.06)" strokeWidth="4" />
            <circle
              cx="130" cy="130" r={radius}
              fill="none" stroke="url(#timer-grad)" strokeWidth="4"
              strokeDasharray={circ} strokeDashoffset={circ * (1 - pct)}
              strokeLinecap="round"
              transform="rotate(-90 130 130)"
              style={{ filter: 'drop-shadow(0 0 8px rgba(62,230,245,0.8))', transition: 'stroke-dashoffset 1s linear' }}
            />
          </svg>

          {/* Center portal glow */}
          <div className="absolute rounded-full animate-portal-pulse"
            style={{ width: 120, height: 120, background: 'radial-gradient(circle, rgba(62,230,245,0.2) 0%, rgba(62,230,245,0.02) 70%)', boxShadow: '0 0 40px rgba(62,230,245,0.3)' }}
          />

          {/* Timer display */}
          <div className="relative z-10 text-center">
            <p className="font-mono-stat" style={{ fontSize: 52, color: '#EAF6FF', letterSpacing: '0.05em', textShadow: '0 0 20px rgba(62,230,245,0.5)' }}>
              {mm}:{ss}
            </p>
            <p className="font-orbitron uppercase tracking-system" style={{ fontSize: 9, color: '#7FA0C9' }}>
              {running ? 'INSIDE THE GATE' : 'READY TO ENTER'}
            </p>
          </div>
        </div>

        {/* Warning text */}
        <p className="font-mono-stat mt-6 text-center px-8" style={{ fontSize: 10, color: '#3E5578', lineHeight: 1.6 }}>
          [ Leaving the Gate before clearing it<br />will trigger a Penalty. ]
        </p>
      </div>

      {/* Controls */}
      <div className="px-6 pb-10 space-y-3">
        {/* Duration selector */}
        {!running && (
          <div className="flex gap-2 justify-center">
            {[15, 25, 45, 60].map(min => (
              <button
                key={min}
                onClick={() => setSeconds(min * 60)}
                className="px-3 py-1.5 rounded-lg font-orbitron font-bold transition-all active:scale-95"
                style={{
                  fontSize: 10,
                  background: seconds === min * 60 ? 'rgba(62,230,245,0.15)' : 'transparent',
                  border: `1px solid ${seconds === min * 60 ? 'rgba(62,230,245,0.5)' : 'rgba(62,230,245,0.1)'}`,
                  color: seconds === min * 60 ? '#3EE6F5' : '#3E5578',
                }}
              >
                {min}M
              </button>
            ))}
          </div>
        )}

        <button
          onClick={() => setRunning(r => !r)}
          className="w-full py-4 rounded-xl font-orbitron font-bold uppercase tracking-system transition-all active:scale-95"
          style={{
            fontSize: 14,
            background: running
              ? 'rgba(255,46,77,0.1)'
              : 'linear-gradient(135deg, #3EE6F5, #1FA9C2)',
            color: running ? '#FF2E4D' : '#030712',
            border: running ? '1px solid rgba(255,46,77,0.4)' : 'none',
            boxShadow: running ? '0 0 16px rgba(255,46,77,0.2)' : '0 0 24px rgba(62,230,245,0.4)',
          }}
        >
          {running ? '⏸ PAUSE SESSION' : '⚡ ENTER THE GATE'}
        </button>
      </div>

      {/* Exit warning modal */}
      {showExitWarning && (
        <div className="absolute inset-0 z-60 flex items-center justify-center px-8" style={{ background: 'rgba(3,7,18,0.9)' }}>
          <div className="glass-panel rounded-2xl p-6 w-full" style={{ border: '1px solid rgba(255,46,77,0.4)' }}>
            <p className="font-orbitron font-bold uppercase tracking-system text-center mb-3" style={{ fontSize: 13, color: '#FF2E4D' }}>
              ⚠ ABANDON GATE?
            </p>
            <p className="font-rajdhani text-center mb-4" style={{ fontSize: 12, color: '#7FA0C9' }}>
              [ Exiting now will trigger the Penalty Protocol.<br />
              Your streak will be compromised.<br />
              The System does not forgive. ]
            </p>
            <div className="flex gap-3">
              <button onClick={() => setShowExitWarning(false)} className="flex-1 py-2.5 rounded-lg font-orbitron font-bold uppercase tracking-system transition-all active:scale-95" style={{ fontSize: 10, background: 'linear-gradient(135deg, rgba(62,230,245,0.15), rgba(62,230,245,0.05))', border: '1px solid rgba(62,230,245,0.3)', color: '#3EE6F5' }}>
                CONTINUE
              </button>
              <button onClick={() => setCollapsed(true)} className="flex-1 py-2.5 rounded-lg font-orbitron font-bold uppercase tracking-system transition-all active:scale-95" style={{ fontSize: 10, border: '1px solid rgba(255,46,77,0.4)', color: '#FF2E4D' }}>
                FLEE
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}

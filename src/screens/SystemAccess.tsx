import { useState, useEffect, useRef } from 'react'
import { OrnatePanel, TerminalReadout, DecryptText, DiamondDivider } from '../components/SystemUI'

type View = 'login' | 'register' | 'recovery' | 'verifying'
type Props = { onComplete: () => void }

const VERIFY_LINES = [
  { text: 'Establishing uplink to System core...' },
  { text: 'Scanning neural signature...', status: 'SYNC' as const },
  { text: 'Checking hunter registry... SESSION::0x4F2A', status: 'OK' as const },
  { text: 'Qualification flag detected — IRREGULAR SOUL', status: 'SYNC' as const },
  { text: 'Mana signature confirmed.', status: 'OK' as const },
  { text: 'Access granted. Initiating Awakening protocol...', status: 'OK' as const },
]

export default function SystemAccess({ onComplete }: Props) {
  const [view, setView] = useState<View>('login')
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [name, setName] = useState('')
  const [recoveryEmail, setRecoveryEmail] = useState('')
  const [errors, setErrors] = useState<Record<string, string>>({})
  const [verifyStep, setVerifyStep] = useState(0)
  const [loading, setLoading] = useState(false)
  const [recoveryDone, setRecoveryDone] = useState(false)

  /* ── Verifying auto-advance ── */
  useEffect(() => {
    if (view !== 'verifying') return
    let idx = 0
    const timers = VERIFY_LINES.map((_, i) =>
      setTimeout(() => { setVerifyStep(s => s + 1); idx++ }, i * 420 + 200)
    )
    const done = setTimeout(onComplete, 3200)
    return () => { timers.forEach(clearTimeout); clearTimeout(done) }
  }, [view])

  function validate() {
    const e: Record<string, string> = {}
    if (!email.trim()) e.email = 'UPLINK TARGET REQUIRED'
    else if (!email.includes('@')) e.email = 'INVALID UPLINK ADDRESS'
    if (!password.trim()) e.password = 'AUTHENTICATION KEY REQUIRED'
    else if (password.length < 6) e.password = 'KEY TOO SHORT — MIN 6 CHARS'
    setErrors(e)
    return Object.keys(e).length === 0
  }

  function handleLogin() {
    if (!validate()) return
    setLoading(true)
    setTimeout(() => { setLoading(false); setView('verifying') }, 900)
  }
  function handleRegister() {
    if (!validate()) return
    setLoading(true)
    setTimeout(() => { setLoading(false); setView('verifying') }, 900)
  }
  function handleRecovery() {
    if (!recoveryEmail.includes('@')) {
      setErrors({ recoveryEmail: 'INVALID UPLINK ADDRESS' }); return
    }
    setRecoveryDone(true)
  }

  /* ════════════════════ VERIFYING ════════════════════ */
  if (view === 'verifying') {
    return (
      <div className="flex flex-col justify-center h-full void-bg-full circuit-overlay px-6">
        {/* Hex label */}
        <p className="font-mono mb-6" style={{ fontSize: 10, color: 'rgba(57,255,136,.4)' }}>
          SESSION::0x4F2A · SECTOR 0x1F · NODE::042
        </p>
        <div className="space-y-2">
          <TerminalReadout lines={VERIFY_LINES.slice(0, verifyStep)}/>
          {verifyStep < VERIFY_LINES.length && (
            <div className="flex items-center gap-2">
              <span className="font-mono" style={{ fontSize: 12, color: 'rgba(57,255,136,.55)' }}>{'>'}</span>
              <span className="font-mono anim-cursor" style={{ fontSize: 12, color: 'rgba(57,255,136,.8)' }}>_</span>
            </div>
          )}
        </div>
      </div>
    )
  }

  /* ════════════════════ RECOVERY ════════════════════ */
  if (view === 'recovery') {
    return (
      <AccessShell>
        <p className="font-mono text-center mb-2" style={{ fontSize: 10, color: 'rgba(57,255,136,.6)' }}>
          SESSION::RECOVERY · NODE::AUTH
        </p>
        <p className="font-orbitron font-bold uppercase text-center mb-1 ls-system" style={{ fontSize: 11, color: '#7FA0C9' }}>
          UPLINK LOST?
        </p>
        {!recoveryDone ? (
          <>
            <h1 className="font-orbitron font-black uppercase text-center mb-6" style={{ fontSize: 24, color: '#EAF6FF' }}>
              RESTORE ACCESS
            </h1>
            <SystemInput
              label="UPLINK ADDRESS"
              value={recoveryEmail} onChange={setRecoveryEmail}
              placeholder="hunter@system.net"
              error={errors.recoveryEmail} type="email"
            />
            <ActionButton onClick={handleRecovery} loading={false}>TRANSMIT RECOVERY KEY</ActionButton>
            <p className="font-mono text-center mt-4" style={{ fontSize: 11, color: '#3E5578' }}>
              [ Remember your key? ]
              <button onClick={() => setView('login')} className="ml-1" style={{ color: '#3EE6F5' }}>
                ESTABLISH UPLINK
              </button>
            </p>
          </>
        ) : (
          <div className="text-center mt-4">
            <p className="font-orbitron font-bold uppercase" style={{ fontSize: 14, color: '#39FF88' }}>
              ✓ RECOVERY KEY TRANSMITTED
            </p>
            <p className="font-mono mt-2" style={{ fontSize: 11, color: '#7FA0C9' }}>
              [ Check your uplink address.<br />The System will contact you. ]
            </p>
            <button onClick={() => setView('login')} className="mt-6 font-orbitron font-bold uppercase ls-system"
              style={{ fontSize: 11, color: '#3EE6F5' }}>
              RETURN TO LOGIN →
            </button>
          </div>
        )}
      </AccessShell>
    )
  }

  /* ════════════════════ REGISTER ════════════════════ */
  if (view === 'register') {
    return (
      <AccessShell>
        <p className="font-mono text-center mb-2" style={{ fontSize: 10, color: 'rgba(57,255,136,.6)' }}>
          SESSION::NEW · NODE::REGISTER
        </p>
        <h1 className="font-orbitron font-black uppercase text-center mb-6" style={{ fontSize: 24, color: '#EAF6FF' }}>
          REGISTER PLAYER
        </h1>
        <SystemInput label="HUNTER DESIGNATION" value={name} onChange={setName}
          placeholder="Enter your name" error={errors.name} type="text" />
        <SystemInput label="UPLINK ADDRESS" value={email} onChange={setEmail}
          placeholder="hunter@system.net" error={errors.email} type="email" />
        <SystemInput label="AUTHENTICATION KEY" value={password} onChange={setPassword}
          placeholder="Min 6 characters" error={errors.password} type="password" />

        <div className="rounded-xl p-3 mb-4" style={{ background: 'rgba(57,255,136,.05)', border: '1px solid rgba(57,255,136,.15)' }}>
          <p className="font-mono text-center" style={{ fontSize: 10, color: 'rgba(57,255,136,.7)' }}>
            [ A title shall be chosen during Awakening. ]
          </p>
        </div>

        <ActionButton onClick={handleRegister} loading={loading}>ESTABLISH NEW UPLINK</ActionButton>

        <SocialRow />

        <p className="font-mono text-center mt-4" style={{ fontSize: 11, color: '#3E5578' }}>
          Already a hunter?
          <button onClick={() => setView('login')} className="ml-1" style={{ color: '#3EE6F5' }}>
            SIGN IN
          </button>
        </p>
      </AccessShell>
    )
  }

  /* ════════════════════ LOGIN (default) ════════════════════ */
  return (
    <AccessShell>
      {/* Hex micro-labels */}
      <p className="font-mono text-center mb-2" style={{ fontSize: 10, color: 'rgba(57,255,136,.6)' }}>
        SESSION::AUTH · NODE::PRIMARY
      </p>
      <h1 className="font-orbitron font-black uppercase text-center mb-1"
        style={{ fontSize: 28, color: '#EAF6FF', letterSpacing: '0.08em', textShadow: '0 0 24px rgba(62,230,245,.45)' }}>
        ESTABLISH UPLINK
      </h1>
      <p className="font-rajdhani text-center mb-6" style={{ fontSize: 13, color: '#7FA0C9' }}>
        The System awaits your connection.
      </p>

      <SystemInput label="UPLINK ADDRESS" value={email} onChange={setEmail}
        placeholder="hunter@system.net" error={errors.email} type="email" />
      <SystemInput label="AUTHENTICATION KEY" value={password} onChange={setPassword}
        placeholder="••••••••" error={errors.password} type="password" />

      <button onClick={() => setView('recovery')} className="text-right w-full mb-4 font-mono"
        style={{ fontSize: 10, color: '#3E5578' }}>
        [ UPLINK LOST? ] →
      </button>

      <ActionButton onClick={handleLogin} loading={loading}>CONNECT TO SYSTEM</ActionButton>

      <SocialRow />

      <p className="font-mono text-center mt-5" style={{ fontSize: 11, color: '#3E5578' }}>
        New to the System?
        <button onClick={() => setView('register')} className="ml-1" style={{ color: '#3EE6F5' }}>
          REGISTER PLAYER
        </button>
      </p>
    </AccessShell>
  )
}

/* ── Sub-components ── */

function AccessShell({ children }: { children: React.ReactNode }) {
  return (
    <div className="flex flex-col justify-center h-full void-bg-full px-5 py-8">
      {/* Decorative ambient rings */}
      <div className="absolute inset-0 flex items-center justify-center pointer-events-none">
        {[260, 320, 380].map((s, i) => (
          <div key={i} className="absolute rounded-full"
            style={{ width: s, height: s, border: `1px solid rgba(62,230,245,${0.04 - i * 0.01})`,
              animation: `portal-spin ${18 + i * 6}s linear infinite`,
              animationDirection: i % 2 === 0 ? 'normal' : 'reverse' }} />
        ))}
      </div>
      <OrnatePanel cornerSize={32} className="relative z-10 p-6 pt-10">
        {children}
      </OrnatePanel>
    </div>
  )
}

function SystemInput({ label, value, onChange, placeholder, error, type }: {
  label: string; value: string; onChange: (v: string) => void
  placeholder?: string; error?: string; type?: string
}) {
  const ref = useRef<HTMLInputElement>(null)
  const [focused, setFocused] = useState(false)
  return (
    <div className="mb-4">
      <label className="font-orbitron uppercase ls-system block mb-1.5" style={{ fontSize: 9, color: '#7FA0C9' }}>
        {label}:
      </label>
      <div className="relative">
        <span className="absolute left-3 top-1/2 -translate-y-1/2 font-mono" style={{ fontSize: 12, color: 'rgba(57,255,136,.5)' }}>{'>'}</span>
        <input ref={ref} type={type ?? 'text'} value={value}
          onChange={e => onChange(e.target.value)}
          onFocus={() => setFocused(true)} onBlur={() => setFocused(false)}
          placeholder={placeholder}
          className="w-full pl-7 pr-3 py-3 rounded-xl font-mono outline-none transition-all"
          style={{
            background: 'rgba(10,26,58,.8)', fontSize: 13, color: '#EAF6FF',
            border: `1px solid ${error ? 'rgba(255,46,77,.6)' : focused ? 'rgba(62,230,245,.5)' : 'rgba(62,230,245,.2)'}`,
            caretColor: '#3EE6F5',
            boxShadow: focused ? '0 0 12px rgba(62,230,245,.1)' : 'none',
          }} />
        {focused && !value && (
          <span className="absolute right-3 top-1/2 -translate-y-1/2 font-mono anim-cursor"
            style={{ fontSize: 14, color: '#3EE6F5' }}>_</span>
        )}
      </div>
      {error && (
        <p className="font-mono mt-1" style={{ fontSize: 9, color: '#FF2E4D' }}>⚠ {error}</p>
      )}
    </div>
  )
}

function ActionButton({ children, onClick, loading }: {
  children: React.ReactNode; onClick: () => void; loading: boolean
}) {
  return (
    <button onClick={onClick} disabled={loading}
      className="w-full py-4 rounded-xl font-orbitron font-bold uppercase ls-system transition-all active:scale-95 mb-4"
      style={{
        fontSize: 13,
        background: loading ? 'rgba(62,230,245,.08)' : 'linear-gradient(135deg,#3EE6F5,#1FA9C2)',
        color: loading ? '#3EE6F5' : '#030712',
        boxShadow: loading ? 'none' : '0 0 28px rgba(62,230,245,.45)',
        border: loading ? '1px solid rgba(62,230,245,.3)' : 'none',
      }}>
      {loading ? (
        <span className="flex items-center justify-center gap-2">
          <span className="font-mono anim-cursor">_</span>
          <span>AUTHENTICATING...</span>
        </span>
      ) : children}
    </button>
  )
}

function SocialRow() {
  return (
    <div className="space-y-2">
      <DiamondDivider />
      {[
        { icon: 'G', label: 'CONTINUE WITH GOOGLE', color: 'rgba(255,155,62,.7)' },
        { icon: '⌘', label: 'CONTINUE WITH APPLE', color: 'rgba(62,230,245,.7)' },
      ].map(({ icon, label, color }) => (
        <button key={label}
          className="w-full py-3 rounded-xl font-orbitron font-bold uppercase ls-system transition-all active:scale-95"
          style={{ fontSize: 10, background: 'rgba(10,26,58,.6)', border: '1px solid rgba(62,230,245,.15)', color: '#7FA0C9' }}>
          <span style={{ color }}>{icon} </span>{label}
        </button>
      ))}
    </div>
  )
}

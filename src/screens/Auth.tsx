import { useState } from 'react'
import { OrnatePanel, TerminalReadout, UplinkChip, DiamondDivider, ScanlineSweep, DecryptText } from '../components/SystemUI'
import { BackendBridge } from '../services/backendBridge'

type AuthScreen = 'login' | 'register' | 'recovery' | 'verifying'
interface Props { onComplete: () => void }

const BOOT_LINES = [
  { text: 'ARISE SYSTEM v2.0 — INITIALIZING...', status: 'INIT' as const },
  { text: 'Scanning dimensional frequency...', status: '...' as const },
  { text: 'Hunter database: ONLINE', status: 'OK' as const },
  { text: 'Uplink established', status: 'SYNC' as const },
]

export default function Auth({ onComplete }: Props) {
  const [screen, setScreen] = useState<AuthScreen>('login')
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [name, setName] = useState('')
  const [loading, setLoading] = useState(false)

  async function handleLogin() {
    setLoading(true)
    setScreen('verifying')
    try {
      await BackendBridge.login(email || 'hunter@arise.sys', password)
    } catch (e) {
      console.warn('Backend login fallback used', e)
    }
    setTimeout(() => { setLoading(false); onComplete() }, 2200)
  }

  async function handleRegister() {
    setLoading(true)
    setScreen('verifying')
    try {
      await BackendBridge.signup(email || 'hunter@arise.sys', name || 'HUNTER', 'casual')
    } catch (e) {
      console.warn('Backend signup fallback used', e)
    }
    setTimeout(() => { setLoading(false); onComplete() }, 2200)
  }


  function handleRecovery() {
    setScreen('verifying')
    setTimeout(() => setScreen('login'), 2500)
  }

  if (screen === 'verifying') return <VerifyingScreen isRecovery={loading === false}/>

  return (
    <div className="relative w-full h-full void-bg circuit-overlay flex flex-col items-center justify-center px-5 overflow-hidden">
      <ScanlineSweep/>

      {/* Ambient glow */}
      <div className="absolute top-1/4 left-1/2 -translate-x-1/2 -translate-y-1/2 w-64 h-64 rounded-full pointer-events-none"
        style={{ background:'radial-gradient(ellipse,rgba(62,230,245,.08) 0%,transparent 70%)' }}/>

      {/* Logo/Title */}
      <div className="text-center mb-8">
        <div className="mb-3 flex justify-center">
          <UplinkChip stable/>
        </div>
        <h1 className="font-orbitron font-black tracking-system animate-fade-in"
          style={{ fontSize:38, color:'#EAF6FF', textShadow:'0 0 30px rgba(62,230,245,.5),0 0 60px rgba(62,230,245,.2)', letterSpacing:'.2em' }}>
          ARISE
        </h1>
        <p className="font-mono-stat" style={{ fontSize:10, color:'#3EE6F5', letterSpacing:'.18em', marginTop:4 }}>
          HUNTER SYSTEM v2.0
        </p>
      </div>

      {/* Boot terminal */}
      <div className="w-full glass-panel rounded-xl p-3 mb-6" style={{ border:'1px solid rgba(62,230,245,.12)' }}>
        <TerminalReadout lines={BOOT_LINES}/>
      </div>

      {screen === 'login' && (
        <LoginForm email={email} setEmail={setEmail} password={password} setPassword={setPassword}
          onLogin={handleLogin} onGoRegister={() => setScreen('register')} onGoRecovery={() => setScreen('recovery')}/>
      )}
      {screen === 'register' && (
        <RegisterForm email={email} setEmail={setEmail} password={password} setPassword={setPassword}
          name={name} setName={setName} onRegister={handleRegister} onGoLogin={() => setScreen('login')}/>
      )}
      {screen === 'recovery' && (
        <RecoveryForm email={email} setEmail={setEmail} onSend={handleRecovery} onGoLogin={() => setScreen('login')}/>
      )}
    </div>
  )
}

function LoginForm({ email, setEmail, password, setPassword, onLogin, onGoRegister, onGoRecovery }: {
  email: string; setEmail: (v:string)=>void; password: string; setPassword: (v:string)=>void
  onLogin: ()=>void; onGoRegister: ()=>void; onGoRecovery: ()=>void
}) {
  return (
    <OrnatePanel cornerSize={28} className="w-full">
      <div className="p-5 pt-8">
        <div className="text-center mb-5">
          <p className="font-mono-stat" style={{ fontSize:9, color:'#7FA0C9' }}>[ AUTHENTICATION PROTOCOL ]</p>
          <h2 className="font-orbitron font-bold uppercase tracking-system mt-1" style={{ fontSize:16, color:'#EAF6FF' }}>
            ESTABLISH UPLINK
          </h2>
        </div>

        <div className="space-y-3 mb-4">
          <div>
            <label className="terminal-dim block mb-1" style={{ fontSize:10 }}>&gt; HUNTER ID (EMAIL)</label>
            <input className="terminal-input" type="email" placeholder="hunter@arise.sys" value={email} onChange={e => setEmail(e.target.value)}/>
          </div>
          <div>
            <label className="terminal-dim block mb-1" style={{ fontSize:10 }}>&gt; ACCESS CODE</label>
            <input className="terminal-input" type="password" placeholder="••••••••" value={password} onChange={e => setPassword(e.target.value)}/>
          </div>
        </div>

        <button onClick={onLogin}
          className="w-full py-3 rounded-lg font-orbitron font-bold uppercase tracking-system transition-all active:scale-95 mb-3"
          style={{ fontSize:12, background:'linear-gradient(135deg,#3EE6F5,#1FA9C2)', color:'#030712', boxShadow:'0 0 20px rgba(62,230,245,.35)' }}>
          [ INITIATE UPLINK ]
        </button>

        <DiamondDivider/>

        <div className="space-y-2 mb-4">
          <SSOButton icon="G" label="CONTINUE VIA GOOGLE NETWORK"/>
          <SSOButton icon="⬡" label="CONTINUE VIA APPLE NEXUS"/>
        </div>

        <div className="flex items-center justify-between">
          <button onClick={onGoRecovery} className="font-mono-stat transition-all active:opacity-60" style={{ fontSize:10, color:'#3E5578' }}>
            UPLINK LOST?
          </button>
          <button onClick={onGoRegister} className="font-mono-stat transition-all active:opacity-60" style={{ fontSize:10, color:'#3EE6F5' }}>
            NEW HUNTER →
          </button>
        </div>
      </div>
    </OrnatePanel>
  )
}

function RegisterForm({ email, setEmail, password, setPassword, name, setName, onRegister, onGoLogin }: {
  email: string; setEmail: (v:string)=>void; password: string; setPassword: (v:string)=>void
  name: string; setName: (v:string)=>void; onRegister: ()=>void; onGoLogin: ()=>void
}) {
  return (
    <OrnatePanel cornerSize={28} className="w-full">
      <div className="p-5 pt-8">
        <div className="text-center mb-5">
          <p className="font-mono-stat" style={{ fontSize:9, color:'#7FA0C9' }}>[ NEW ENTITY DETECTED ]</p>
          <h2 className="font-orbitron font-bold uppercase tracking-system mt-1" style={{ fontSize:16, color:'#EAF6FF' }}>
            REGISTER HUNTER
          </h2>
          <p className="font-rajdhani mt-1" style={{ fontSize:11, color:'#3E5578' }}>
            Your title awaits. Begin the awakening.
          </p>
        </div>

        <div className="space-y-3 mb-4">
          <div>
            <label className="terminal-dim block mb-1" style={{ fontSize:10 }}>&gt; HUNTER DESIGNATION</label>
            <input className="terminal-input-cyan" type="text" placeholder="SHADOW MONARCH" value={name} onChange={e => setName(e.target.value)}/>
          </div>
          <div>
            <label className="terminal-dim block mb-1" style={{ fontSize:10 }}>&gt; UPLINK ADDRESS (EMAIL)</label>
            <input className="terminal-input" type="email" placeholder="hunter@arise.sys" value={email} onChange={e => setEmail(e.target.value)}/>
          </div>
          <div>
            <label className="terminal-dim block mb-1" style={{ fontSize:10 }}>&gt; ENCRYPTION KEY (PASSWORD)</label>
            <input className="terminal-input" type="password" placeholder="min 8 characters" value={password} onChange={e => setPassword(e.target.value)}/>
          </div>
        </div>

        <button onClick={onRegister}
          className="w-full py-3 rounded-lg font-orbitron font-bold uppercase tracking-system transition-all active:scale-95 mb-3"
          style={{ fontSize:12, background:'linear-gradient(135deg,#39FF88,#1aa855)', color:'#030712', boxShadow:'0 0 20px rgba(57,255,136,.3)' }}>
          [ INITIALIZE AWAKENING ]
        </button>

        <button onClick={onGoLogin} className="w-full text-center font-mono-stat transition-all active:opacity-60" style={{ fontSize:10, color:'#3E5578' }}>
          ← RETURNING HUNTER
        </button>
      </div>
    </OrnatePanel>
  )
}

function RecoveryForm({ email, setEmail, onSend, onGoLogin }: {
  email: string; setEmail: (v:string)=>void; onSend: ()=>void; onGoLogin: ()=>void
}) {
  return (
    <OrnatePanel cornerSize={28} className="w-full">
      <div className="p-5 pt-8">
        <div className="text-center mb-5">
          <p className="font-mono-stat" style={{ fontSize:9, color:'#FF9B3E' }}>[ UPLINK SEVERED ]</p>
          <h2 className="font-orbitron font-bold uppercase tracking-system mt-1" style={{ fontSize:16, color:'#EAF6FF' }}>
            UPLINK LOST?
          </h2>
          <p className="font-rajdhani mt-1" style={{ fontSize:11, color:'#7FA0C9' }}>
            Transmit your registered frequency. The System will reestablish contact.
          </p>
        </div>

        <div className="mb-4">
          <label className="terminal-dim block mb-1" style={{ fontSize:10 }}>&gt; REGISTERED FREQUENCY (EMAIL)</label>
          <input className="terminal-input" type="email" placeholder="hunter@arise.sys" value={email} onChange={e => setEmail(e.target.value)}/>
        </div>

        <button onClick={onSend}
          className="w-full py-3 rounded-lg font-orbitron font-bold uppercase tracking-system transition-all active:scale-95 mb-3"
          style={{ fontSize:12, background:'rgba(255,155,62,.15)', color:'#FF9B3E', border:'1px solid rgba(255,155,62,.4)', boxShadow:'0 0 16px rgba(255,155,62,.2)' }}>
          [ TRANSMIT RECOVERY SIGNAL ]
        </button>

        <button onClick={onGoLogin} className="w-full text-center font-mono-stat transition-all active:opacity-60" style={{ fontSize:10, color:'#3E5578' }}>
          ← ABORT — RETURN TO UPLINK
        </button>
      </div>
    </OrnatePanel>
  )
}

function SSOButton({ icon, label }: { icon: string; label: string }) {
  return (
    <button className="w-full flex items-center gap-3 glass-panel rounded-lg px-4 py-2.5 transition-all active:scale-95"
      style={{ border:'1px solid rgba(62,230,245,.15)' }}>
      <span className="font-orbitron font-bold text-base w-6 text-center" style={{ color:'#3EE6F5' }}>{icon}</span>
      <span className="font-orbitron uppercase tracking-system flex-1 text-left" style={{ fontSize:9, color:'#7FA0C9' }}>{label}</span>
    </button>
  )
}

function VerifyingScreen({ isRecovery }: { isRecovery: boolean }) {
  const lines = isRecovery ? [
    { text: 'Recovery signal transmitted', status: 'OK' as const },
    { text: 'Awaiting System response...', status: '...' as const },
  ] : [
    { text: 'Verifying credentials...', status: '...' as const },
    { text: 'Cross-referencing Hunter registry...', status: '...' as const },
    { text: 'Dimensional sync: ESTABLISHED', status: 'SYNC' as const },
    { text: 'Identity confirmed', status: 'OK' as const },
    { text: 'Loading Hunter profile...', status: 'OK' as const },
  ]

  return (
    <div className="relative w-full h-full void-bg flex flex-col items-center justify-center px-6 overflow-hidden">
      <ScanlineSweep/>
      <div className="absolute top-1/3 left-1/2 -translate-x-1/2 -translate-y-1/2 w-48 h-48 rounded-full"
        style={{ background:'radial-gradient(ellipse,rgba(62,230,245,.1) 0%,transparent 70%)', animation:'orb-breathe 3s ease-in-out infinite' }}/>

      <div className="text-center mb-8">
        <div className="w-16 h-16 rounded-full mx-auto mb-4 flex items-center justify-center"
          style={{ background:'rgba(62,230,245,.1)', border:'2px solid #3EE6F5', boxShadow:'0 0 30px rgba(62,230,245,.4)', animation:'orb-breathe 2s ease-in-out infinite' }}>
          <span className="font-orbitron font-bold" style={{ fontSize:22, color:'#3EE6F5' }}>◈</span>
        </div>
        <span className="font-orbitron font-bold uppercase tracking-system" style={{ fontSize:18, color:'#EAF6FF' }}><DecryptText text={isRecovery ? 'SIGNAL SENT' : 'UPLINK ESTABLISHED'}/></span>
      </div>

      <div className="w-full glass-panel rounded-xl p-4" style={{ border:'1px solid rgba(62,230,245,.2)' }}>
        <TerminalReadout lines={lines}/>
      </div>
    </div>
  )
}

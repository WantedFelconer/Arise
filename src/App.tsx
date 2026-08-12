import { useState } from 'react'
import { NavBar, TopStatusBar } from './components/SystemUI'
import Auth from './screens/Auth'
import Onboarding from './screens/Onboarding'
import Home from './screens/Home'
import QuestList from './screens/QuestList'
import StatusPage from './screens/StatusPage'
import Journal from './screens/Journal'
import Roadmap from './screens/Roadmap'
import FocusMode from './screens/FocusMode'
import Penalty from './screens/Penalty'
import LevelUp from './screens/LevelUp'
import Armory from './screens/Armory'
import ManaCore from './screens/ManaCore'
import Guild from './screens/Guild'
import CalendarSync from './screens/CalendarSync'
import Settings from './screens/Settings'
import AICoach from './screens/AICoach'
import BossDetail from './screens/BossDetail'
import Notifications from './screens/Notifications'

export type PlayerData = {
  name: string; title: string; level: number; rank: string
  hp: number; maxHp: number; mp: number; maxMp: number
  exp: number; maxExp: number; gold: number; streak: number
  str: number; agi: number; vit: number; int: number; per: number
  remainingPoints: number
}

type AppPhase = 'auth' | 'onboarding' | 'main'
type MainTab = 'home' | 'quests' | 'status' | 'journal' | 'roadmap'
type Overlay = 'focus' | 'penalty' | 'levelup' | 'armory' | 'manacore' | 'guild' | 'calendar' | 'settings' | 'aicoach' | 'boss' | 'notifications' | null

const DEFAULT_PLAYER: PlayerData = {
  name: 'HUNTER', title: 'THE AWAKENED',
  level: 14, rank: 'B',
  hp: 4200, maxHp: 5000,
  mp: 391, maxMp: 500,
  exp: 7340, maxExp: 10000,
  gold: 1240, streak: 14,
  str: 53, agi: 38, vit: 30, int: 30, per: 32,
  remainingPoints: 3,
}

export default function App() {
  const [phase, setPhase] = useState<AppPhase>('auth')
  const [player, setPlayer] = useState<PlayerData>(DEFAULT_PLAYER)
  const [activeTab, setActiveTab] = useState<MainTab>('home')
  const [overlay, setOverlay] = useState<Overlay>(null)
  const [showLevelUp, setShowLevelUp] = useState(false)
  const [showPenalty, setShowPenalty] = useState(false)

  function handleAuthComplete() {
    setPhase('onboarding')
  }

  function handleOnboardingComplete(setup: { name: string; title: string; classes: string[]; chronotype?: string; difficulty?: string }) {
    setPlayer(p => ({ ...p, name: setup.name, title: setup.title }))
    setPhase('main')
    setTimeout(() => setShowLevelUp(true), 800)
  }

  function handleStatUp(stat: string) {
    if (player.remainingPoints <= 0) return
    setPlayer(p => ({
      ...p,
      remainingPoints: p.remainingPoints - 1,
      str: stat === 'STR' ? p.str + 1 : p.str,
      agi: stat === 'AGI' ? p.agi + 1 : p.agi,
      vit: stat === 'VIT' ? p.vit + 1 : p.vit,
      int: stat === 'INT' ? p.int + 1 : p.int,
      per: stat === 'PER' ? p.per + 1 : p.per,
    }))
  }

  function handleFocusExit(success: boolean) {
    setOverlay(null)
    if (success) setPlayer(p => ({ ...p, exp: Math.min(p.maxExp, p.exp + 200) }))
  }

  function handlePenaltyAck() { setShowPenalty(false); setOverlay(null) }
  function handleLevelUpContinue() { setShowLevelUp(false) }

  function navigateTo(screen: string) {
    if (['home','quests','status','journal','roadmap'].includes(screen)) {
      setActiveTab(screen as MainTab)
      setOverlay(null)
    } else {
      setOverlay(screen as Overlay)
    }
  }

  /* ── AUTH ── */
  if (phase === 'auth') {
    return (
      <PhoneShell>
        <Auth onComplete={handleAuthComplete}/>
      </PhoneShell>
    )
  }

  /* ── ONBOARDING ── */
  if (phase === 'onboarding') {
    return (
      <PhoneShell>
        <Onboarding onComplete={handleOnboardingComplete}/>
      </PhoneShell>
    )
  }

  /* ── MAIN APP ── */
  const showTopBar = ['home','quests','status','journal','roadmap'].includes(activeTab)

  return (
    <PhoneShell>
      {showTopBar && overlay === null && !showLevelUp && !showPenalty && (
        <TopStatusBar
          hp={player.hp} maxHp={player.maxHp}
          mp={player.mp} maxMp={player.maxMp}
          level={player.level} streak={player.streak}
          uplinkStable={true}
          onManaCoreClick={() => setOverlay('manacore')}
        />
      )}

      {overlay === null && !showLevelUp && !showPenalty && (
        <>
          {activeTab === 'home'    && <Home player={player} onEnterFocus={() => setOverlay('focus')} onNavigate={navigateTo}/>}
          {activeTab === 'quests'  && <QuestList/>}
          {activeTab === 'status'  && <StatusPage player={player} onStatUp={handleStatUp}/>}
          {activeTab === 'journal' && <Journal/>}
          {activeTab === 'roadmap' && <Roadmap/>}
        </>
      )}

      {overlay === null && !showLevelUp && !showPenalty && (
        <NavBar active={activeTab} onNavigate={navigateTo}/>
      )}

      {/* Settings gear */}
      {overlay === null && !showLevelUp && !showPenalty && (
        <button onClick={() => setOverlay('settings')}
          className="absolute top-2.5 right-14 z-40 w-7 h-7 flex items-center justify-center rounded-full transition-all active:scale-90"
          style={{ color:'#3E5578', fontSize:14 }}>⚙</button>
      )}

      {/* AI Coach shortcut */}
      {overlay === null && !showLevelUp && !showPenalty && (
        <button onClick={() => setOverlay('aicoach')}
          className="absolute top-2.5 right-22 z-40 w-7 h-7 flex items-center justify-center rounded-full transition-all active:scale-90"
          style={{ color:'#3EE6F5', fontSize:14 }}>◈</button>
      )}

      {/* Notifications shortcut */}
      {overlay === null && !showLevelUp && !showPenalty && (
        <button onClick={() => setOverlay('notifications')}
          className="absolute top-2.5 right-30 z-40 font-mono-stat transition-all active:scale-90"
          style={{ fontSize:13, color:'#3E5578' }}>🔔</button>
      )}

      {/* Penalty trigger demo */}
      {overlay === null && !showLevelUp && !showPenalty && (
        <button onClick={() => setShowPenalty(true)}
          className="absolute top-2.5 left-4 z-40 font-mono-stat transition-all active:scale-90"
          style={{ fontSize:7, color:'#FF2E4D', opacity:.5 }} title="Demo: Trigger Penalty">⚠</button>
      )}

      {/* ── OVERLAYS ── */}
      {overlay === 'focus' && <FocusMode onExit={handleFocusExit}/>}

      {overlay === 'armory' && (
        <OverlayScreen onBack={() => setOverlay(null)}><Armory gold={player.gold}/></OverlayScreen>
      )}
      {overlay === 'manacore' && (
        <OverlayScreen onBack={() => setOverlay(null)}><ManaCore/></OverlayScreen>
      )}
      {overlay === 'guild' && (
        <OverlayScreen onBack={() => setOverlay(null)}><Guild/></OverlayScreen>
      )}
      {overlay === 'calendar' && (
        <OverlayScreen onBack={() => setOverlay(null)}><CalendarSync/></OverlayScreen>
      )}
      {overlay === 'settings' && (
        <OverlayScreen onBack={() => setOverlay(null)}><Settings onClose={() => setOverlay(null)}/></OverlayScreen>
      )}
      {overlay === 'aicoach' && (
        <OverlayScreen onBack={() => setOverlay(null)}>
          <AICoach onBack={() => setOverlay(null)} />
        </OverlayScreen>
      )}
      {overlay === 'boss' && (
        <OverlayScreen onBack={() => setOverlay(null)}>
          <BossDetail onBack={() => setOverlay(null)} onFocusMode={() => setOverlay('focus')} />
        </OverlayScreen>
      )}
      {overlay === 'notifications' && (
        <OverlayScreen onBack={() => setOverlay(null)}>
          <Notifications onBack={() => setOverlay(null)} />
        </OverlayScreen>
      )}

      {/* New v2 overlays — full-screen with own back button */}
      {overlay === 'aicoach' && <AICoach onBack={() => setOverlay(null)}/>}
      {overlay === 'boss' && <BossDetail onBack={() => setOverlay(null)} onFocusMode={() => setOverlay('focus')}/>}
      {overlay === 'notifications' && <Notifications onBack={() => setOverlay(null)}/>}

      {showPenalty && <Penalty onAcknowledge={handlePenaltyAck} missedQuest="10KM RUN"/>}
      {showLevelUp && <LevelUp oldLevel={player.level-1} newLevel={player.level} newPoints={5} onContinue={handleLevelUpContinue}/>}
    </PhoneShell>
  )
}

function PhoneShell({ children }: { children: React.ReactNode }) {
  return (
    <div className="min-h-screen flex items-center justify-center" style={{ background:'#000' }}>
      <div className="relative overflow-hidden"
        style={{ width:390, height:844, background:'radial-gradient(ellipse at 50% 30%,#0B1330 0%,#030712 100%)', boxShadow:'0 0 80px rgba(62,230,245,0.08),0 40px 120px rgba(0,0,0,0.9)', borderRadius:44, border:'1px solid rgba(62,230,245,0.12)' }}>
        <div className="absolute top-0 left-0 right-0 h-12 z-50 pointer-events-none"
          style={{ background:'linear-gradient(to bottom,rgba(3,7,18,.6) 0%,transparent 100%)' }}/>
        <div className="absolute bottom-0 left-0 right-0 h-6 z-50 pointer-events-none"
          style={{ background:'linear-gradient(to top,rgba(3,7,18,.8) 0%,transparent 100%)' }}/>
        <div className="absolute inset-0 overflow-hidden">{children}</div>
      </div>
    </div>
  )
}

function OverlayScreen({ children, onBack }: { children: React.ReactNode; onBack: () => void }) {
  return (
    <div className="absolute inset-0 z-40 void-bg animate-slide-up">
      <button onClick={onBack}
        className="absolute top-2.5 left-4 z-50 glass-panel rounded-full flex items-center gap-1 px-2.5 py-1.5 font-orbitron font-bold uppercase tracking-system transition-all active:scale-90"
        style={{ fontSize:9, color:'#3EE6F5', border:'1px solid rgba(62,230,245,0.25)' }}>
        ← BACK
      </button>
      {children}
    </div>
  )
}

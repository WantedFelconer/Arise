import { useEffect, useState } from 'react'
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
import { AppProvider, useApp, type PlayerData } from './context/AppContext'
import { services } from './api/services'

export type { PlayerData }

type MainTab = 'home' | 'quests' | 'status' | 'journal' | 'roadmap'
type Overlay = 'focus' | 'penalty' | 'levelup' | 'armory' | 'manacore' | 'guild' | 'calendar' | 'settings' | 'aicoach' | 'boss' | 'notifications' | null

function AppContent() {
  const {
    phase,
    setPhase,
    player,
    refreshPlayer,
    showLevelUp,
    setShowLevelUp,
    showPenalty,
    setShowPenalty,
    levelUpData,
    penaltyMissedQuest,
  } = useApp()

  const [activeTab, setActiveTab] = useState<MainTab>('home')
  const [overlay, setOverlay] = useState<Overlay>(null)

  useEffect(() => {
    if (!overlay && !showLevelUp && !showPenalty) return
    const handleEscape = (event: KeyboardEvent) => {
      if (event.key !== 'Escape') return
      if (showLevelUp) setShowLevelUp(false)
      else if (showPenalty) setShowPenalty(false)
      else if (overlay && overlay !== 'focus') setOverlay(null)
    }
    window.addEventListener('keydown', handleEscape)
    return () => window.removeEventListener('keydown', handleEscape)
  }, [overlay, showLevelUp, showPenalty, setShowLevelUp, setShowPenalty])

  function handleAuthComplete() {
    setPhase('onboarding')
  }

  function handleOnboardingComplete(setup: { name: string; title: string; classes: string[]; chronotype?: string; difficulty?: string }) {
    if (setup.difficulty) {
      services.settings.setDifficultyMode(setup.difficulty as any).catch(() => {})
    }
    refreshPlayer().then(() => {
      setPhase('main')
      setTimeout(() => setShowLevelUp(true), 800)
    })
  }

  function handleStatUp(_stat: string) {
    // Stat allocations
  }

  function handleFocusExit(success: boolean) {
    setOverlay(null)
    if (success) {
      refreshPlayer().catch(() => {})
    }
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
    <PhoneShell main>
      <DesktopSidebar
        active={activeTab}
        player={player}
        onNavigate={navigateTo}
      />
      <div className="app-workspace">
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

      {/* Compact mobile utilities */}
      {overlay === null && !showLevelUp && !showPenalty && (
        <button onClick={() => setOverlay('settings')}
          aria-label="Open settings"
          className="mobile-utility mobile-utility-settings absolute top-2.5 right-14 z-40 w-7 h-7 flex items-center justify-center rounded-full transition-all active:scale-90"
          style={{ color:'#3E5578', fontSize:14 }}>◇</button>
      )}

      {overlay === null && !showLevelUp && !showPenalty && (
        <button onClick={() => setOverlay('aicoach')}
          aria-label="Open AI Coach"
          className="mobile-utility mobile-utility-coach absolute top-2.5 right-22 z-40 w-7 h-7 flex items-center justify-center rounded-full transition-all active:scale-90"
          style={{ color:'#3EE6F5', fontSize:14 }}>◈</button>
      )}

      {overlay === null && !showLevelUp && !showPenalty && (
        <button onClick={() => setOverlay('notifications')}
          aria-label="Open notifications"
          className="mobile-utility mobile-utility-alerts absolute top-2.5 right-30 z-40 font-mono-stat transition-all active:scale-90"
          style={{ fontSize:13, color:'#3E5578' }}>◉</button>
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
        <OverlayScreen onBack={() => setOverlay(null)} showBack={false}><Settings onClose={() => setOverlay(null)}/></OverlayScreen>
      )}
      {overlay === 'aicoach' && (
        <OverlayScreen onBack={() => setOverlay(null)} showBack={false}>
          <AICoach onBack={() => setOverlay(null)} />
        </OverlayScreen>
      )}
      {overlay === 'boss' && (
        <OverlayScreen onBack={() => setOverlay(null)} showBack={false}>
          <BossDetail onBack={() => setOverlay(null)} onFocusMode={() => setOverlay('focus')} />
        </OverlayScreen>
      )}
      {overlay === 'notifications' && (
        <OverlayScreen onBack={() => setOverlay(null)} showBack={false}>
          <Notifications onBack={() => setOverlay(null)} />
        </OverlayScreen>
      )}

      {showPenalty && <Penalty onAcknowledge={handlePenaltyAck} missedQuest={penaltyMissedQuest || '10KM RUN'}/>}
      {showLevelUp && <LevelUp oldLevel={levelUpData.oldLevel} newLevel={levelUpData.newLevel} newPoints={levelUpData.newPoints} onContinue={handleLevelUpContinue}/>}
      </div>
    </PhoneShell>
  )
}

export default function App() {
  return (
    <AppProvider>
      <AppContent />
    </AppProvider>
  )
}

function PhoneShell({ children, main = false }: { children: React.ReactNode; main?: boolean }) {
  return (
    <div className="app-shell">
      <div className={`app-viewport ${main ? 'app-viewport-main' : 'app-viewport-entry'}`}>
        <div className="safe-fade safe-fade-top"/>
        <div className="safe-fade safe-fade-bottom"/>
        {children}
      </div>
    </div>
  )
}

function DesktopSidebar({ active, player, onNavigate }: {
  active: MainTab
  player: PlayerData
  onNavigate: (screen: string) => void
}) {
  const primary: Array<{ id: MainTab; label: string; code: string }> = [
    { id:'home', label:'Home', code:'01' },
    { id:'quests', label:'Quests', code:'02' },
    { id:'status', label:'Status', code:'03' },
    { id:'journal', label:'Journal', code:'04' },
    { id:'roadmap', label:'Roadmap', code:'05' },
  ]
  const system = [
    { id:'aicoach', label:'AI Coach', code:'AI' },
    { id:'guild', label:'Guild', code:'GD' },
    { id:'armory', label:'Armory', code:'AR' },
    { id:'notifications', label:'Alerts', code:'NT' },
    { id:'settings', label:'Settings', code:'CF' },
  ]
  return (
    <aside className="desktop-sidebar" aria-label="System navigation">
      <div className="desktop-brand">
        <div className="desktop-brand-mark">A</div>
        <div>
          <p className="desktop-brand-name">ARISE</p>
          <p className="desktop-online"><span/> SYSTEM ONLINE</p>
        </div>
      </div>
      <nav className="desktop-nav">
        <p className="desktop-nav-label">PRIMARY SYSTEM</p>
        {primary.map(item => (
          <button
            key={item.id}
            onClick={() => onNavigate(item.id)}
            className={`desktop-nav-item ${active === item.id ? 'is-active' : ''}`}
            aria-current={active === item.id ? 'page' : undefined}
          >
            <span className="desktop-nav-code">{item.code}</span>
            <span>{item.label}</span>
          </button>
        ))}
        <div className="desktop-nav-divider"/>
        <p className="desktop-nav-label">SYSTEM ACCESS</p>
        {system.map(item => (
          <button key={item.id} onClick={() => onNavigate(item.id)} className="desktop-nav-item">
            <span className="desktop-nav-code">{item.code}</span>
            <span>{item.label}</span>
          </button>
        ))}
      </nav>
      <div className="desktop-profile">
        <div className="desktop-profile-rank">{player.rank}</div>
        <div className="desktop-profile-copy">
          <strong>{player.name}</strong>
          <span>LV.{player.level} · {player.title}</span>
        </div>
        <span className="desktop-profile-signal">◈</span>
      </div>
    </aside>
  )
}

function OverlayScreen({ children, onBack, showBack = true }: {
  children: React.ReactNode
  onBack: () => void
  showBack?: boolean
}) {
  return (
    <div className="responsive-overlay absolute inset-0 z-40 void-bg animate-slide-up">
      {showBack && (
        <button onClick={onBack}
          aria-label="Return to previous screen"
          className="overlay-back absolute top-2.5 left-4 z-50 glass-panel rounded-full flex items-center gap-1 px-2.5 py-1.5 font-orbitron font-bold uppercase tracking-system transition-all active:scale-90"
          style={{ fontSize:9, color:'#3EE6F5', border:'1px solid rgba(62,230,245,0.25)' }}>
          ← BACK
        </button>
      )}
      {children}
    </div>
  )
}

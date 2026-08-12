import { useState } from 'react'
import { GlassCard, SectionHeader, DiamondDivider } from '../components/SystemUI'

interface Props { onBack: () => void }

type NotifTab = 'PRODUCTIVITY' | 'WELLNESS' | 'BEHAVIORAL' | 'SYSTEM'

interface Reminder {
  id: number; icon: string; title: string; schedule: string
  active: boolean; tab: NotifTab; color: string; snoozed?: boolean
}

const ALL_REMINDERS: Reminder[] = [
  { id:1,  icon:'⚔', title:'DAILY QUEST CHECK-IN',    schedule:'08:00 · DAILY',    active:true,  tab:'PRODUCTIVITY', color:'#3EE6F5' },
  { id:2,  icon:'🏆', title:'FOCUS SESSION — NOON',    schedule:'12:00 · MON-FRI',  active:true,  tab:'PRODUCTIVITY', color:'#3EE6F5' },
  { id:3,  icon:'📋', title:'QUEST LOG REVIEW',        schedule:'20:00 · DAILY',    active:false, tab:'PRODUCTIVITY', color:'#3EE6F5' },
  { id:4,  icon:'💧', title:'HYDRATION REMINDER',      schedule:'EVERY 2H',         active:true,  tab:'WELLNESS',     color:'#2E9BFF' },
  { id:5,  icon:'🧘', title:'MINDFULNESS WINDOW',      schedule:'07:30 · DAILY',    active:true,  tab:'WELLNESS',     color:'#2E9BFF' },
  { id:6,  icon:'🌙', title:'SLEEP PROTOCOL INIT',     schedule:'22:30 · DAILY',    active:true,  tab:'WELLNESS',     color:'#2E9BFF' },
  { id:7,  icon:'🔥', title:'STREAK GUARD',            schedule:'21:00 · DAILY',    active:true,  tab:'BEHAVIORAL',   color:'#39D98A' },
  { id:8,  icon:'📵', title:'SCREEN LIMIT ENFORCE',    schedule:'23:00 · DAILY',    active:false, tab:'BEHAVIORAL',   color:'#39D98A' },
  { id:9,  icon:'◈',  title:'SYSTEM UPLINK CHECK',     schedule:'ON APP OPEN',      active:true,  tab:'SYSTEM',       color:'#B26EFF' },
  { id:10, icon:'⚠',  title:'PENALTY ALERT',           schedule:'OVERDUE TRIGGER',  active:true,  tab:'SYSTEM',       color:'#FF9B3E' },
  { id:11, icon:'🏅', title:'LEVEL UP BROADCAST',      schedule:'ON ACHIEVEMENT',   active:true,  tab:'SYSTEM',       color:'#B26EFF' },
]

const TAB_COLORS: Record<NotifTab, string> = {
  PRODUCTIVITY: '#3EE6F5',
  WELLNESS:     '#2E9BFF',
  BEHAVIORAL:   '#39D98A',
  SYSTEM:       '#B26EFF',
}

export default function Notifications({ onBack }: Props) {
  const [activeTab, setActiveTab] = useState<NotifTab>('PRODUCTIVITY')
  const [reminders, setReminders] = useState<Reminder[]>(ALL_REMINDERS)
  const [snoozedIds, setSnoozedIds] = useState<number[]>([])

  const filtered = reminders.filter(r => r.tab === activeTab)
  const activeColor = TAB_COLORS[activeTab]

  function toggleReminder(id: number) {
    setReminders(prev => prev.map(r => r.id === id ? { ...r, active: !r.active } : r))
  }

  function snooze(id: number) {
    setSnoozedIds(prev => [...prev, id])
    setTimeout(() => setSnoozedIds(prev => prev.filter(x => x !== id)), 3000)
  }

  return (
    <div className="absolute inset-0 z-40 flex flex-col void-bg circuit-overlay animate-slide-up">
      {/* Header */}
      <div className="flex items-center justify-between px-4 pt-6 pb-3 flex-shrink-0"
        style={{ borderBottom:'1px solid rgba(62,230,245,.12)' }}>
        <button onClick={onBack} className="font-orbitron uppercase tracking-system transition-all active:opacity-60"
          style={{ fontSize:10, color:'#3E5578' }}>← BACK</button>
        <div className="text-center">
          <p className="font-mono-stat" style={{ fontSize:8, color:'#7FA0C9' }}>[ ALERT REGISTRY ]</p>
          <h1 className="font-orbitron font-bold uppercase tracking-system" style={{ fontSize:13, color:'#EAF6FF' }}>
            NOTIFICATIONS
          </h1>
        </div>
        <span className="font-mono-stat rounded-full px-2 py-0.5"
          style={{ fontSize:9, color:activeColor, background:`${activeColor}15`, border:`1px solid ${activeColor}30` }}>
          {filtered.filter(r => r.active).length}/{filtered.length}
        </span>
      </div>

      {/* Segmented tabs */}
      <div className="px-4 pt-3 pb-2 flex-shrink-0">
        <div className="grid grid-cols-4 glass-panel rounded-xl overflow-hidden"
          style={{ border:'1px solid rgba(62,230,245,.15)' }}>
          {(['PRODUCTIVITY','WELLNESS','BEHAVIORAL','SYSTEM'] as NotifTab[]).map(tab => {
            const col = TAB_COLORS[tab]
            const isActive = activeTab === tab
            return (
              <button key={tab} onClick={() => setActiveTab(tab)}
                className="py-2 font-orbitron font-bold uppercase transition-all"
                style={{ fontSize:7, letterSpacing:'.08em', color: isActive ? col : '#3E5578', background: isActive ? `${col}12` : 'transparent', borderBottom: isActive ? `2px solid ${col}` : '2px solid transparent' }}>
                {tab === 'PRODUCTIVITY' ? 'PROD' : tab === 'BEHAVIORAL' ? 'BEHAV' : tab}
              </button>
            )
          })}
        </div>
      </div>

      {/* Tab description */}
      <div className="px-4 mb-2 flex-shrink-0">
        <p className="font-mono-stat" style={{ fontSize:9, color:'#3E5578' }}>
          {activeTab === 'PRODUCTIVITY' && '> Quest timers, focus sessions, review windows'}
          {activeTab === 'WELLNESS' && '> Health checks, hydration, sleep protocol'}
          {activeTab === 'BEHAVIORAL' && '> Streak guards, screen limits, habit loops'}
          {activeTab === 'SYSTEM' && '> Core alerts, uplink status, achievement triggers'}
        </p>
      </div>

      {/* Reminder list */}
      <div className="flex-1 overflow-y-auto px-4 space-y-2 pb-24">
        {filtered.length === 0 && (
          <div className="text-center py-12">
            <p className="font-orbitron uppercase tracking-system" style={{ fontSize:12, color:'#3E5578' }}>NO ALERTS CONFIGURED</p>
          </div>
        )}
        {filtered.map(reminder => {
          const isSnoozed = snoozedIds.includes(reminder.id)
          return (
            <GlassCard key={reminder.id} className="p-3"
              style={{ border:`1px solid ${reminder.active ? `${reminder.color}25` : 'rgba(62,230,245,.08)'}`, opacity: isSnoozed ? 0.5 : 1 }}>
              <div className="flex items-center gap-3">
                <div className="w-9 h-9 rounded-xl flex items-center justify-center flex-shrink-0 text-xl"
                  style={{ background:`${reminder.color}10`, border:`1px solid ${reminder.color}25` }}>
                  {reminder.icon}
                </div>
                <div className="flex-1 min-w-0">
                  <div className="flex items-center gap-2 mb-0.5">
                    <p className="font-orbitron font-bold uppercase truncate" style={{ fontSize:11, color: reminder.active ? '#EAF6FF' : '#3E5578' }}>
                      {reminder.title}
                    </p>
                    {isSnoozed && (
                      <span className="font-mono-stat flex-shrink-0" style={{ fontSize:8, color:'#FF9B3E' }}>[SNOOZED]</span>
                    )}
                  </div>
                  <div className="flex items-center gap-2">
                    <span className="font-mono-stat rounded-full px-2 py-0.5"
                      style={{ fontSize:8, color:reminder.color, background:`${reminder.color}12`, border:`1px solid ${reminder.color}25` }}>
                      ⏱ {reminder.schedule}
                    </span>
                  </div>
                </div>
                <div className="flex items-center gap-2 flex-shrink-0">
                  {reminder.active && !isSnoozed && (
                    <button onClick={() => snooze(reminder.id)}
                      className="font-mono-stat rounded px-1.5 py-0.5 transition-all active:scale-90"
                      style={{ fontSize:8, color:'#FF9B3E', background:'rgba(255,155,62,.08)', border:'1px solid rgba(255,155,62,.25)' }}>
                      ZZZ
                    </button>
                  )}
                  {/* Toggle */}
                  <button onClick={() => toggleReminder(reminder.id)}
                    className="w-10 h-5 rounded-full relative transition-all"
                    style={{ background: reminder.active ? `${reminder.color}25` : 'rgba(62,230,245,.08)', border:`1px solid ${reminder.active ? `${reminder.color}50` : 'rgba(62,230,245,.2)'}` }}>
                    <div className="absolute top-0.5 w-4 h-4 rounded-full transition-all"
                      style={{ left: reminder.active ? '20px' : '2px', background: reminder.active ? reminder.color : '#3E5578', boxShadow: reminder.active ? `0 0 8px ${reminder.color}80` : 'none' }}/>
                  </button>
                </div>
              </div>
            </GlassCard>
          )
        })}
      </div>

      {/* Add Reminder FAB */}
      <button className="absolute bottom-6 right-4 w-12 h-12 rounded-full flex items-center justify-center font-orbitron font-bold transition-all active:scale-90 z-10"
        style={{ background:`linear-gradient(135deg,${activeColor},${activeColor}99)`, color:'#030712', fontSize:20, boxShadow:`0 0 20px ${activeColor}50` }}>
        +
      </button>
    </div>
  )
}

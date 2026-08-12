import { useState } from 'react'
import { GlassCard, SectionHeader, DiamondDivider, OrnatePanel } from '../components/SystemUI'
import { LineChart, Line, BarChart, Bar, XAxis, YAxis, Tooltip, ResponsiveContainer, RadarChart, Radar, PolarGrid, PolarAngleAxis } from 'recharts'

type ViewMode = 'week' | 'month'
type JournalTab = 'log' | 'analytics'

function generateHeatData() {
  return Array.from({ length: 28 }, (_, i) => ({ day:i, count:Math.floor(Math.random()*6) }))
}
const HEAT_DATA = generateHeatData()

const ENTRIES = [
  {
    date:'TODAY — JUL 31', exp:480, maxExp:600,
    quests:[ { title:'Morning Run', status:'cleared', exp:120 }, { title:'100 Push-ups', status:'cleared', exp:80 }, { title:'100 Sit-ups', status:'cleared', exp:80 }, { title:'Deep Work Session', status:'cleared', exp:200 }, { title:'Evening Meditation', status:'failed', exp:0 } ],
    mood:4, log:"Pushed through the afternoon slump. The System doesn't sleep, and neither will I. Still need to fix the meditation streak.",
  },
  {
    date:'JUL 30', exp:600, maxExp:600,
    quests:[ { title:'Morning Run', status:'cleared', exp:120 }, { title:'100 Push-ups', status:'cleared', exp:80 }, { title:'Ship Module v2.3', status:'cleared', exp:300 }, { title:'Evening Meditation', status:'cleared', exp:100 } ],
    mood:5, log:"Perfect quota achieved. Level ceiling breaking soon. The System rewards relentlessness.",
  },
  {
    date:'JUL 29', exp:320, maxExp:600,
    quests:[ { title:'Morning Run', status:'failed', exp:0 }, { title:'100 Sit-ups', status:'cleared', exp:80 }, { title:'Read 30 Min', status:'cleared', exp:40 }, { title:'Cold Shower', status:'cleared', exp:200 } ],
    mood:2, log:"Weak start. Missed the run — body wanted to quit. Weakness is temporary, regret lasts longer.",
  },
]

const MONTHLY_SUMMARY = { totalExp:14820, questsCleared:94, penalties:7, streak:14, avgDaily:480 }

/* Analytics data */
const XP_TREND = [
  { day:'M', xp:480 }, { day:'T', xp:600 }, { day:'W', xp:320 }, { day:'T', xp:550 },
  { day:'F', xp:700 }, { day:'S', xp:280 }, { day:'S', xp:600 },
]
const FOCUS_HOURS = [
  { day:'Mon', hours:3.5 }, { day:'Tue', hours:5.0 }, { day:'Wed', hours:2.0 },
  { day:'Thu', hours:4.5 }, { day:'Fri', hours:6.0 }, { day:'Sat', hours:1.5 }, { day:'Sun', hours:3.0 },
]
const CATEGORY_RADAR = [
  { subject:'BODY',  A:78 }, { subject:'MIND',  A:62 }, { subject:'CRAFT', A:85 },
  { subject:'DISC',  A:70 }, { subject:'SOCIAL',A:35 },
]
const DUAL_TREND = [
  { day:'M', mana:80, energy:65 }, { day:'T', mana:75, energy:78 }, { day:'W', mana:60, energy:55 },
  { day:'T', mana:85, energy:72 }, { day:'F', mana:90, energy:88 }, { day:'S', mana:50, energy:45 }, { day:'S', mana:72, energy:80 },
]

const CHART_THEME = {
  grid: 'rgba(62,230,245,.08)',
  tick: { fill:'#3E5578', fontSize:9, fontFamily:"'Share Tech Mono',monospace" },
  tooltip: { background:'rgba(10,26,58,.95)', border:'1px solid rgba(62,230,245,.3)', fontFamily:"'Share Tech Mono',monospace", fontSize:10 },
}

export default function Journal() {
  const [view, setView] = useState<ViewMode>('week')
  const [activeTab, setActiveTab] = useState<JournalTab>('log')
  const [expandedEntry, setExpandedEntry] = useState<number|null>(0)

  return (
    <div className="flex flex-col h-full void-bg overflow-y-auto" style={{ paddingTop:64, paddingBottom:80 }}>
      <div className="px-4 pt-3 space-y-4">

        {/* Header */}
        <div>
          <p className="font-mono-stat" style={{ fontSize:10, color:'#3E5578' }}>[ GROWTH LOG ]</p>
          <h1 className="font-orbitron font-bold uppercase" style={{ fontSize:22, color:'#EAF6FF', letterSpacing:'.05em' }}>JOURNAL</h1>
        </div>

        {/* Tabs */}
        <div className="flex glass-panel rounded-xl overflow-hidden" style={{ border:'1px solid rgba(62,230,245,.15)' }}>
          {(['log','analytics'] as JournalTab[]).map(t => (
            <button key={t} onClick={() => setActiveTab(t)}
              className="flex-1 py-2 font-orbitron font-bold uppercase tracking-system transition-all"
              style={{ fontSize:10, color: activeTab===t ? '#3EE6F5' : '#3E5578', background: activeTab===t ? 'rgba(62,230,245,.1)' : 'transparent', borderBottom: activeTab===t ? '2px solid #3EE6F5' : '2px solid transparent' }}>
              {t === 'log' ? "HUNTER'S LOG" : 'ANALYTICS'}
            </button>
          ))}
        </div>

        {activeTab === 'log' && (
          <>
            {/* View toggle */}
            <div className="flex glass-panel rounded-xl overflow-hidden" style={{ border:'1px solid rgba(62,230,245,.12)' }}>
              {(['week','month'] as ViewMode[]).map(v => (
                <button key={v} onClick={() => setView(v)}
                  className="flex-1 py-1.5 font-orbitron font-bold uppercase tracking-system transition-all"
                  style={{ fontSize:9, color: view===v ? '#3EE6F5' : '#3E5578', background: view===v ? 'rgba(62,230,245,.1)' : 'transparent', borderBottom: view===v ? '2px solid #3EE6F5' : '2px solid transparent' }}>
                  {v === 'week' ? 'THIS WEEK' : 'THIS MONTH'}
                </button>
              ))}
            </div>

            {/* Heatmap */}
            <GlassCard className="p-4">
              <SectionHeader title="QUEST ACTIVITY"/>
              <div className="flex gap-1 flex-wrap">
                {HEAT_DATA.slice(view==='week' ? 21 : 0).map(({ day, count }) => {
                  const intensity = count===0?0:count<=1?0.2:count<=2?0.4:count<=3?0.6:count<=4?0.8:1
                  const isToday = day===27
                  return (
                    <div key={day} className="rounded-sm flex-shrink-0"
                      style={{ width: view==='week'?36:22, height: view==='week'?36:22, background: count===0?'rgba(62,230,245,.06)':`rgba(62,230,245,${intensity})`, border: isToday?'1.5px solid #3EE6F5':'1px solid rgba(62,230,245,.1)', animation: isToday?'heat-pulse 2s ease-in-out infinite':'none' }}
                      title={`${count} quests`}/>
                  )
                })}
              </div>
              <div className="flex items-center gap-2 mt-2 justify-end">
                <span className="font-mono-stat" style={{ fontSize:8, color:'#3E5578' }}>LESS</span>
                {[0.06,0.25,0.45,0.65,0.9].map((op,i) => (
                  <div key={i} className="w-3 h-3 rounded-sm" style={{ background:`rgba(62,230,245,${op})` }}/>
                ))}
                <span className="font-mono-stat" style={{ fontSize:8, color:'#3E5578' }}>MORE</span>
              </div>
            </GlassCard>

            {/* Month summary */}
            <GlassCard className="p-4" style={{ border:'1px solid rgba(255,210,76,.2)' }}>
              <SectionHeader title="MONTH REPORT — JULY"/>
              <div className="grid grid-cols-3 gap-3">
                <StatTile label="TOTAL EXP" value={MONTHLY_SUMMARY.totalExp.toLocaleString()} color="#FFD24C"/>
                <StatTile label="CLEARED" value={`${MONTHLY_SUMMARY.questsCleared}`} color="#39FF88"/>
                <StatTile label="PENALTIES" value={`${MONTHLY_SUMMARY.penalties}`} color="#FF2E4D"/>
              </div>
              <DiamondDivider/>
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-2">
                  <span style={{ fontSize:18 }}>🔥</span>
                  <div>
                    <p className="font-orbitron font-bold" style={{ fontSize:14, color:'#FF9B3E' }}>{MONTHLY_SUMMARY.streak} DAY STREAK</p>
                    <p className="font-mono-stat" style={{ fontSize:9, color:'#7FA0C9' }}>CURRENT RUN</p>
                  </div>
                </div>
                <div className="text-right">
                  <p className="font-mono-stat" style={{ fontSize:13, color:'#3EE6F5' }}>{MONTHLY_SUMMARY.avgDaily} EXP/DAY</p>
                  <p className="font-mono-stat" style={{ fontSize:9, color:'#7FA0C9' }}>AVERAGE</p>
                </div>
              </div>
            </GlassCard>

            {/* Entries */}
            <SectionHeader title="HUNTER'S LOG"/>
            <div className="space-y-3">
              {ENTRIES.map((entry, idx) => {
                const expanded = expandedEntry === idx
                return (
                  <div key={idx} className="glass-panel rounded-xl overflow-hidden" style={{ border:'1px solid rgba(62,230,245,.15)' }}>
                    <button onClick={() => setExpandedEntry(expanded ? null : idx)}
                      className="w-full text-left px-4 py-3 flex items-center justify-between active:bg-white/5">
                      <div>
                        <p className="font-orbitron font-bold uppercase" style={{ fontSize:11, color: idx===0?'#3EE6F5':'#EAF6FF' }}>{entry.date}</p>
                        <div className="flex items-center gap-2 mt-0.5">
                          <span className="font-mono-stat" style={{ fontSize:10, color:'#FFD24C' }}>+{entry.exp} EXP</span>
                          <MoodDots value={entry.mood}/>
                        </div>
                      </div>
                      <ExpMiniBar value={entry.exp} max={entry.maxExp}/>
                    </button>
                    {expanded && (
                      <div className="px-4 pb-4" style={{ borderTop:'1px solid rgba(62,230,245,.08)' }}>
                        <div className="mt-3 space-y-1">
                          {entry.quests.map((q, qi) => (
                            <div key={qi} className="flex items-center justify-between">
                              <div className="flex items-center gap-2">
                                <span style={{ fontSize:10, color: q.status==='cleared'?'#39FF88':'#FF2E4D' }}>{q.status==='cleared'?'✓':'✗'}</span>
                                <span className="font-rajdhani" style={{ fontSize:12, color: q.status==='cleared'?'#EAF6FF':'#7FA0C9', textDecoration: q.status==='failed'?'line-through':'none' }}>{q.title}</span>
                              </div>
                              {q.exp > 0 && <span className="font-mono-stat" style={{ fontSize:10, color:'#FFD24C' }}>+{q.exp}</span>}
                            </div>
                          ))}
                        </div>
                        <DiamondDivider/>
                        <p className="font-mono-stat" style={{ fontSize:9, color:'#3E5578', letterSpacing:'.04em', marginBottom:4 }}>[ HUNTER'S LOG ENTRY ]</p>
                        <p className="font-rajdhani leading-relaxed" style={{ fontSize:12, color:'#7FA0C9' }}>"{entry.log}"</p>
                        <div className="mt-3 rounded-lg flex items-center justify-center" style={{ height:64, background:'rgba(10,26,58,.6)', border:'1px dashed rgba(62,230,245,.2)' }}>
                          <span className="font-mono-stat" style={{ fontSize:9, color:'#3E5578' }}>[ ATTACH PROOF PHOTO ]</span>
                        </div>
                      </div>
                    )}
                  </div>
                )
              })}
            </div>
          </>
        )}

        {activeTab === 'analytics' && (
          <>
            <p className="font-mono-stat" style={{ fontSize:9, color:'#3E5578' }}>[ PERFORMANCE ANALYTICS — JULY 2025 ]</p>

            {/* XP Trend */}
            <GlassCard className="p-4">
              <SectionHeader title="XP PROGRESSION"/>
              <div style={{ height:100 }}>
                <ResponsiveContainer width="100%" height="100%">
                  <LineChart data={XP_TREND}>
                    <XAxis dataKey="day" tick={CHART_THEME.tick} axisLine={false} tickLine={false}/>
                    <YAxis tick={CHART_THEME.tick} axisLine={false} tickLine={false} width={30}/>
                    <Tooltip contentStyle={CHART_THEME.tooltip} labelStyle={{ color:'#3EE6F5' }}/>
                    <Line type="monotone" dataKey="xp" stroke="#3EE6F5" strokeWidth={2} dot={{ fill:'#3EE6F5', r:3 }} activeDot={{ r:5, fill:'#3EE6F5', stroke:'#030712' }}/>
                  </LineChart>
                </ResponsiveContainer>
              </div>
            </GlassCard>

            {/* Focus Hours Bar */}
            <GlassCard className="p-4">
              <SectionHeader title="FOCUS HOURS"/>
              <div style={{ height:90 }}>
                <ResponsiveContainer width="100%" height="100%">
                  <BarChart data={FOCUS_HOURS} barCategoryGap="35%">
                    <XAxis dataKey="day" tick={CHART_THEME.tick} axisLine={false} tickLine={false}/>
                    <YAxis tick={CHART_THEME.tick} axisLine={false} tickLine={false} width={24}/>
                    <Tooltip contentStyle={CHART_THEME.tooltip} labelStyle={{ color:'#FFD24C' }}/>
                    <Bar dataKey="hours" fill="rgba(62,230,245,.35)" radius={[3,3,0,0]}
                      style={{ stroke:'#3EE6F5', strokeWidth:.5 }}/>
                  </BarChart>
                </ResponsiveContainer>
              </div>
            </GlassCard>

            {/* Category Radar */}
            <GlassCard className="p-4">
              <SectionHeader title="CATEGORY BREAKDOWN"/>
              <div style={{ height:140 }}>
                <ResponsiveContainer width="100%" height="100%">
                  <RadarChart data={CATEGORY_RADAR}>
                    <PolarGrid stroke="rgba(62,230,245,.12)"/>
                    <PolarAngleAxis dataKey="subject" tick={CHART_THEME.tick}/>
                    <Radar name="stats" dataKey="A" stroke="#3EE6F5" fill="rgba(62,230,245,.15)" strokeWidth={1.5}/>
                  </RadarChart>
                </ResponsiveContainer>
              </div>
            </GlassCard>

            {/* Mana/Energy dual */}
            <GlassCard className="p-4">
              <SectionHeader title="MANA & ENERGY TREND"/>
              <div style={{ height:90 }}>
                <ResponsiveContainer width="100%" height="100%">
                  <LineChart data={DUAL_TREND}>
                    <XAxis dataKey="day" tick={CHART_THEME.tick} axisLine={false} tickLine={false}/>
                    <YAxis tick={CHART_THEME.tick} axisLine={false} tickLine={false} width={24}/>
                    <Tooltip contentStyle={CHART_THEME.tooltip}/>
                    <Line type="monotone" dataKey="mana" stroke="#2E9BFF" strokeWidth={1.5} dot={false}/>
                    <Line type="monotone" dataKey="energy" stroke="#39FF88" strokeWidth={1.5} dot={false}/>
                  </LineChart>
                </ResponsiveContainer>
              </div>
              <div className="flex gap-4 mt-1">
                <div className="flex items-center gap-1"><div className="w-3 h-0.5 rounded" style={{ background:'#2E9BFF' }}/><span className="font-mono-stat" style={{ fontSize:8, color:'#7FA0C9' }}>MANA</span></div>
                <div className="flex items-center gap-1"><div className="w-3 h-0.5 rounded" style={{ background:'#39FF88' }}/><span className="font-mono-stat" style={{ fontSize:8, color:'#7FA0C9' }}>ENERGY</span></div>
              </div>
            </GlassCard>

            {/* AI Monthly Summary */}
            <OrnatePanel cornerSize={22} noCrest>
              <div className="p-4 pt-6">
                <p className="font-mono-stat mb-2" style={{ fontSize:9, color:'#7FA0C9' }}>[ SYSTEM AI — MONTHLY ANALYSIS ]</p>
                <p className="font-rajdhani leading-relaxed" style={{ fontSize:12, color:'#EAF6FF' }}>
                  "Hunter, July was a decisive month. Your Craft stat surged to 85% efficiency while Social tasks remain critically underinvested at 35%. You averaged 480 EXP/day — 20% below your theoretical peak. The System recommends: increase Mind quest allocation by 15%, add one Social quest per week. You are 7 penalties away from automatic dungeon lock — recalibrate immediately."
                </p>
                <DiamondDivider/>
                <button className="w-full py-2 rounded-lg font-orbitron font-bold uppercase tracking-system transition-all active:scale-95"
                  style={{ fontSize:10, color:'#3EE6F5', border:'1px solid rgba(62,230,245,.25)', background:'rgba(62,230,245,.05)' }}>
                  [ EXPORT REPORT AS PDF ]
                </button>
              </div>
            </OrnatePanel>
          </>
        )}
      </div>

      {/* FAB */}
      {activeTab === 'log' && (
        <button className="absolute bottom-24 right-4 w-12 h-12 rounded-full flex items-center justify-center font-orbitron font-bold transition-all active:scale-90 z-30"
          style={{ background:'linear-gradient(135deg,#3EE6F5,#1FA9C2)', color:'#030712', fontSize:20, boxShadow:'0 0 20px rgba(62,230,245,0.5)' }}>
          +
        </button>
      )}
    </div>
  )
}

function StatTile({ label, value, color }: { label:string; value:string; color:string }) {
  return (
    <div className="text-center">
      <p className="font-mono-stat" style={{ fontSize:18, color }}>{value}</p>
      <p className="font-orbitron uppercase tracking-system" style={{ fontSize:7, color:'#3E5578' }}>{label}</p>
    </div>
  )
}
function MoodDots({ value }: { value:number }) {
  return (
    <div className="flex gap-0.5">
      {Array.from({ length:5 }).map((_,i) => (
        <div key={i} className="w-1.5 h-1.5 rounded-full" style={{ background: i<value?'#FFD24C':'rgba(62,230,245,.15)' }}/>
      ))}
    </div>
  )
}
function ExpMiniBar({ value, max }: { value:number; max:number }) {
  const pct = (value/max)*100
  return (
    <div className="flex flex-col items-end gap-0.5">
      <div className="w-20 h-2 rounded-full overflow-hidden" style={{ background:'rgba(10,26,58,.8)' }}>
        <div className="h-full rounded-full" style={{ width:`${pct}%`, background: pct>=100?'linear-gradient(90deg,#39FF88,#1aa855)':'linear-gradient(90deg,#FFD24C,#C98A1A)' }}/>
      </div>
      <span className="font-mono-stat" style={{ fontSize:8, color:'#3E5578' }}>{pct.toFixed(0)}% QUOTA</span>
    </div>
  )
}

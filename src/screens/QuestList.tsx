import { useState } from 'react'
import { RankBadge, RewardChip, GlassCard, OrnatePanel, DiamondDivider } from '../components/SystemUI'
import { BackendBridge } from '../services/backendBridge'

type Tab = 'DAILY' | 'MAIN' | 'SIDE' | 'ALL'
type QuestType = 'DAILY' | 'MAIN' | 'SIDE'
type QuestRank = 'E' | 'D' | 'C' | 'B' | 'A' | 'S'

interface NewQuest { title: string; desc: string; type: QuestType; rank: QuestRank; exp: number; gold: number; deadline: string }

const ALL_QUESTS = [
  /* DAILY */
  {
    id: 1, rank: 'B', type: 'DAILY', title: '100 PUSH-UPS',
    desc: 'Complete 100 consecutive push-ups. No breaks. No excuses.',
    exp: 80, gold: 20, overdue: false, done: false, deadline: '23:14:07', progress: 60,
  },
  {
    id: 2, rank: 'B', type: 'DAILY', title: '100 SIT-UPS',
    desc: 'Core training mandatory by System decree.',
    exp: 80, gold: 20, overdue: false, done: true, deadline: '23:14:07', progress: 100,
  },
  {
    id: 3, rank: 'B', type: 'DAILY', title: '100 SQUATS',
    desc: 'Lower body reinforcement. Essential for dungeon mobility.',
    exp: 80, gold: 20, overdue: false, done: false, deadline: '23:14:07', progress: 0,
  },
  {
    id: 4, rank: 'A', type: 'DAILY', title: '10KM RUN',
    desc: 'Complete the daily distance requirement. Weather is not an excuse.',
    exp: 120, gold: 40, overdue: true, done: false, deadline: 'OVERDUE', progress: 40,
  },
  /* MAIN */
  {
    id: 5, rank: 'S', type: 'MAIN', title: 'SHIP THE APP',
    desc: 'Launch the production build. The System awaits your greatest work.',
    exp: 2000, gold: 500, overdue: false, done: false, deadline: '14D', progress: 35,
  },
  {
    id: 6, rank: 'A', type: 'MAIN', title: 'RUN A MARATHON',
    desc: 'Complete 42.195km. Prove the body knows no limits.',
    exp: 1500, gold: 300, overdue: false, done: false, deadline: '60D', progress: 20,
  },
  {
    id: 7, rank: 'B', type: 'MAIN', title: 'READ 12 BOOKS',
    desc: 'Annual mind cultivation quota. Current: 3/12.',
    exp: 800, gold: 150, overdue: false, done: false, deadline: '180D', progress: 25,
  },
  /* SIDE */
  {
    id: 8, rank: 'D', type: 'SIDE', title: 'CALL A PARENT',
    desc: 'Maintain bonds outside the dungeon. The System rewards perspective.',
    exp: 30, gold: 10, overdue: false, done: false, deadline: 'TONIGHT', progress: 0,
  },
  {
    id: 9, rank: 'C', type: 'SIDE', title: 'CLEAN WORKSPACE',
    desc: 'A cluttered environment is a cluttered mind.',
    exp: 50, gold: 15, overdue: false, done: true, deadline: 'DONE', progress: 100,
  },
  {
    id: 10, rank: 'E', type: 'SIDE', title: 'DRINK 2L WATER',
    desc: 'Baseline vitals maintenance. Non-negotiable.',
    exp: 20, gold: 5, overdue: false, done: false, deadline: '23:14:07', progress: 75,
  },
]

export default function QuestList() {
  const [activeTab, setActiveTab] = useState<Tab>('DAILY')
  const [completedIds, setCompletedIds] = useState<number[]>([2, 9])
  const [expandedId, setExpandedId] = useState<number | null>(null)
  const [showAddQuest, setShowAddQuest] = useState(false)

  function toggleDone(id: number) {
    const isNowDone = !completedIds.includes(id)
    if (isNowDone) {
      // Execute backend XP Engine & Boss damage calculation authoritatively
      const outcome = BackendBridge.completeQuest(String(id), 3, 30)
      console.log(`[Backend Bridge] Quest ${id} completed authoritatively:`, outcome)
    }
    setCompletedIds(prev => prev.includes(id) ? prev.filter(i => i !== id) : [...prev, id])
  }


  const filtered = activeTab === 'ALL' ? ALL_QUESTS : ALL_QUESTS.filter(q => q.type === activeTab)
  const dailyQuests = ALL_QUESTS.filter(q => q.type === 'DAILY')
  const overdueCount = dailyQuests.filter(q => q.overdue && !completedIds.includes(q.id)).length

  return (
    <div className="flex flex-col h-full void-bg" style={{ paddingTop: 76, paddingBottom: 80 }}>

      {/* Header */}
      <div className="px-4 pt-3 pb-2">
        <p className="font-mono-stat" style={{ fontSize: 10, color: '#3E5578' }}>[ QUEST REGISTRY ]</p>
        <h1 className="font-orbitron font-bold uppercase" style={{ fontSize: 22, color: '#EAF6FF', letterSpacing: '0.05em' }}>
          QUEST LOG
        </h1>
      </div>

      {/* Daily Reset Banner */}
      <div
        className="mx-4 rounded-lg px-3 py-2 mb-2 flex items-center justify-between"
        style={{ background: 'rgba(62,230,245,0.06)', border: '1px solid rgba(62,230,245,0.2)' }}
      >
        <div>
          <p className="font-orbitron uppercase tracking-system" style={{ fontSize: 8, color: '#7FA0C9' }}>DAILY QUEST RESET</p>
          {overdueCount > 0 && (
            <p className="font-mono-stat" style={{ fontSize: 9, color: '#FF2E4D' }}>
              ⚠ {overdueCount} OVERDUE — PENALTY PENDING
            </p>
          )}
        </div>
        <span className="font-mono-stat" style={{ fontSize: 16, color: '#3EE6F5' }}>23:14:07</span>
      </div>

      {/* Tab selector */}
      <div className="px-4 mb-3">
        <div className="flex glass-panel rounded-xl overflow-hidden" style={{ border: '1px solid rgba(62,230,245,0.15)' }}>
          {(['DAILY', 'MAIN', 'SIDE', 'ALL'] as Tab[]).map(tab => (
            <button
              key={tab}
              onClick={() => setActiveTab(tab)}
              className="flex-1 py-2 font-orbitron font-bold uppercase tracking-system transition-all"
              style={{
                fontSize: 9,
                color: activeTab === tab ? '#3EE6F5' : '#3E5578',
                background: activeTab === tab ? 'rgba(62,230,245,0.1)' : 'transparent',
                borderBottom: activeTab === tab ? '2px solid #3EE6F5' : '2px solid transparent',
              }}
            >
              {tab}
            </button>
          ))}
        </div>
      </div>

      {/* Quest list */}
      <div className="flex-1 overflow-y-auto px-4 space-y-2 pb-2">
        {filtered.length === 0 && (
          <div className="flex flex-col items-center justify-center py-16">
            <OrnatePanel cornerSize={24} className="p-6 text-center">
              <p className="font-orbitron font-bold uppercase mb-2" style={{ fontSize: 13, color: '#EAF6FF' }}>
                NO QUESTS REMAIN.
              </p>
              <DiamondDivider />
              <p className="font-rajdhani" style={{ fontSize: 12, color: '#7FA0C9' }}>
                [ The System is watching. ]
              </p>
            </OrnatePanel>
          </div>
        )}

        {filtered.map(q => {
          const done = completedIds.includes(q.id)
          const expanded = expandedId === q.id
          const isMain = q.type === 'MAIN'
          const rankColors: Record<string, string> = {
            E: '#8A94A6', D: '#39D98A', C: '#2E9BFF', B: '#B26EFF', A: '#FF9B3E', S: '#FFD24C'
          }
          const rankColor = rankColors[q.rank] ?? '#8A94A6'

          if (isMain) {
            /* ── MAIN QUEST — ornate full-width card ── */
            return (
              <OrnatePanel
                key={q.id}
                cornerSize={24}
                noCrest={q.rank !== 'S'}
                style={{
                  opacity: done ? 0.55 : 1,
                  boxShadow: q.rank === 'S' ? `0 0 24px rgba(255,210,76,0.25), inset 0 0 30px rgba(10,26,58,0.5)` : undefined,
                }}
              >
                <div className="p-4 pt-6">
                  <div className="flex items-start gap-3">
                    <RankBadge rank={q.rank} size="lg" />
                    <div className="flex-1">
                      <div className="flex items-center gap-2 mb-1">
                        <span
                          className="font-mono-stat rounded px-1.5 py-0.5"
                          style={{ fontSize: 8, color: rankColor, background: `${rankColor}15`, border: `1px solid ${rankColor}30` }}
                        >
                          {q.rank}-RANK QUEST
                        </span>
                      </div>
                      <p className="font-orbitron font-bold uppercase" style={{ fontSize: 15, color: '#EAF6FF', lineHeight: 1.2 }}>
                        {q.title}
                      </p>
                      <p className="font-rajdhani mt-1" style={{ fontSize: 12, color: '#7FA0C9' }}>{q.desc}</p>
                    </div>
                  </div>

                  <DiamondDivider />

                  {/* Progress bar */}
                  <div className="mb-3">
                    <div className="flex justify-between mb-1">
                      <span className="font-mono-stat" style={{ fontSize: 9, color: '#7FA0C9' }}>PROGRESS</span>
                      <span className="font-mono-stat" style={{ fontSize: 9, color: '#EAF6FF' }}>{q.progress}%</span>
                    </div>
                    <div className="h-2 rounded-full overflow-hidden" style={{ background: 'rgba(10,26,58,0.8)', border: '1px solid rgba(62,230,245,0.1)' }}>
                      <div
                        className="h-full rounded-full progress-shimmer"
                        style={{
                          width: `${q.progress}%`,
                          background: q.rank === 'S' ? 'linear-gradient(90deg, #FFD24C, #C98A1A)' : `linear-gradient(90deg, ${rankColor}99, ${rankColor})`,
                        }}
                      />
                    </div>
                  </div>

                  <div className="flex items-center justify-between">
                    <RewardChip exp={q.exp} gold={q.gold} />
                    <span className="font-mono-stat" style={{ fontSize: 10, color: '#7FA0C9' }}>⏱ {q.deadline}</span>
                  </div>
                </div>
              </OrnatePanel>
            )
          }

          /* ── DAILY / SIDE QUEST card ── */
          return (
            <div key={q.id}>
              <div
                className="w-full text-left glass-panel rounded-xl p-3 cursor-pointer select-none"
                onClick={() => setExpandedId(expanded ? null : q.id)}
                style={{
                  border: q.overdue && !done
                    ? '1px solid rgba(255,46,77,0.5)'
                    : `1px solid ${rankColors[q.rank]}25`,
                  animation: q.overdue && !done ? 'pulse-danger 2s infinite' : 'none',
                  opacity: done ? 0.55 : 1,
                }}
              >
                <div className="flex items-center gap-3">
                  <RankBadge rank={q.rank} size="sm" />
                  <div className="flex-1 min-w-0">
                    <div className="flex items-center gap-2 mb-0.5">
                      <p className="font-orbitron font-bold uppercase truncate" style={{ fontSize: 12, color: '#EAF6FF' }}>
                        {q.title}
                      </p>
                      {q.overdue && !done && (
                        <span className="font-mono-stat rounded px-1 flex-shrink-0" style={{ fontSize: 8, color: '#FF2E4D', background: 'rgba(255,46,77,0.1)' }}>
                          PENALTY IMMINENT
                        </span>
                      )}
                    </div>
                    <div className="flex items-center gap-2">
                      <RewardChip exp={q.exp} />
                      <span className="font-mono-stat" style={{ fontSize: 9, color: '#3E5578' }}>⏱ {q.deadline}</span>
                    </div>
                  </div>
                  {/* Progress circle */}
                  <ProgressCircle value={done ? 100 : q.progress} onTap={() => toggleDone(q.id)} done={done} />
                </div>

                {/* Expanded detail */}
                {expanded && (
                  <div className="mt-2 pt-2" style={{ borderTop: '1px solid rgba(62,230,245,0.1)' }}>
                    <p className="font-rajdhani" style={{ fontSize: 12, color: '#7FA0C9' }}>{q.desc}</p>
                    <div className="flex items-center justify-between mt-2">
                      <RewardChip exp={q.exp} gold={q.gold} />
                    </div>
                  </div>
                )}
              </div>
            </div>
          )
        })}
      </div>

      {/* Add Quest FAB */}
      <button
        onClick={() => setShowAddQuest(true)}
        className="absolute bottom-24 right-4 w-12 h-12 rounded-full flex items-center justify-center font-orbitron font-bold transition-all active:scale-90 z-30"
        style={{
          background: 'linear-gradient(135deg, #3EE6F5, #1FA9C2)',
          color: '#030712', fontSize: 20,
          boxShadow: '0 0 20px rgba(62,230,245,0.5)',
        }}
      >
        +
      </button>

      {/* Add Quest Sheet */}
      {showAddQuest && <AddQuestSheet onClose={() => setShowAddQuest(false)}/>}
    </div>
  )
}

function ProgressCircle({ value, onTap, done }: { value: number; onTap: () => void; done: boolean }) {
  const size = 32
  const r = 12
  const circ = 2 * Math.PI * r
  return (
    <button onClick={e => { e.stopPropagation(); onTap() }} className="flex-shrink-0 active:scale-90 transition-transform">
      <svg width={size} height={size}>
        <circle cx={size/2} cy={size/2} r={r} fill="none" stroke="rgba(62,230,245,0.1)" strokeWidth="2.5" />
        <circle
          cx={size/2} cy={size/2} r={r} fill="none"
          stroke={done ? '#39FF88' : '#3EE6F5'} strokeWidth="2.5"
          strokeDasharray={circ} strokeDashoffset={circ * (1 - value / 100)}
          strokeLinecap="round"
          transform={`rotate(-90 ${size/2} ${size/2})`}
          style={{ transition: 'stroke-dashoffset 0.4s ease' }}
        />
        {done && (
          <text x={size/2} y={size/2 + 4} textAnchor="middle" fill="#39FF88"
            fontFamily="'Share Tech Mono'" fontSize="9">✓</text>
        )}
      </svg>
    </button>
  )
}

/* ─────────────────────────────────────────────
   ADD QUEST SHEET
───────────────────────────────────────────── */
const RANKS: QuestRank[] = ['E','D','C','B','A','S']
const RANK_COLORS_MAP: Record<QuestRank, string> = { E:'#8A94A6', D:'#39D98A', C:'#2E9BFF', B:'#B26EFF', A:'#FF9B3E', S:'#FFD24C' }
const TYPES: QuestType[] = ['DAILY','MAIN','SIDE']

function AddQuestSheet({ onClose }: { onClose: () => void }) {
  const [form, setForm] = useState<NewQuest>({
    title:'', desc:'', type:'DAILY', rank:'B', exp:100, gold:25, deadline:'23:59'
  })

  function set<K extends keyof NewQuest>(key: K, val: NewQuest[K]) {
    setForm(f => ({ ...f, [key]: val }))
  }

  function handleCreate() {
    if (!form.title.trim()) return
    onClose()
  }

  return (
    <div className="absolute inset-0 z-50 flex items-end" style={{ background:'rgba(3,7,18,.8)' }}
      onClick={onClose}>
      <div className="w-full animate-slide-up glass-panel rounded-t-3xl overflow-hidden"
        style={{ border:'1px solid rgba(62,230,245,.25)', borderBottom:'none', maxHeight:'88%' }}
        onClick={e => e.stopPropagation()}>

        {/* Handle + header */}
        <div className="px-5 pt-4 pb-3 flex-shrink-0" style={{ borderBottom:'1px solid rgba(62,230,245,.1)' }}>
          <div className="w-10 h-1 rounded-full mx-auto mb-4" style={{ background:'rgba(62,230,245,.3)' }}/>
          <div className="flex items-center justify-between">
            <div>
              <p className="font-mono-stat" style={{ fontSize:9, color:'#3E5578' }}>[ NEW OBJECTIVE ]</p>
              <h2 className="font-orbitron font-bold uppercase tracking-system" style={{ fontSize:15, color:'#EAF6FF' }}>
                REGISTER QUEST
              </h2>
            </div>
            <button onClick={onClose} className="font-mono-stat transition-all active:opacity-60"
              style={{ fontSize:18, color:'#3E5578', lineHeight:1 }}>✕</button>
          </div>
        </div>

        {/* Scrollable form body */}
        <div className="overflow-y-auto px-5 py-4 space-y-4" style={{ maxHeight:'70vh' }}>

          {/* Title */}
          <div>
            <label className="font-orbitron uppercase tracking-system block mb-1.5" style={{ fontSize:9, color:'#7FA0C9' }}>
              QUEST TITLE
            </label>
            <input
              className="terminal-input-cyan"
              type="text"
              placeholder="NAME YOUR OBJECTIVE"
              maxLength={40}
              value={form.title}
              onChange={e => set('title', e.target.value)}
            />
          </div>

          {/* Description */}
          <div>
            <label className="font-orbitron uppercase tracking-system block mb-1.5" style={{ fontSize:9, color:'#7FA0C9' }}>
              DESCRIPTION
            </label>
            <textarea
              rows={2}
              placeholder="What must be done. No excuses."
              value={form.desc}
              onChange={e => set('desc', e.target.value)}
              className="w-full rounded-lg px-3 py-2.5 font-rajdhani outline-none resize-none"
              style={{ background:'rgba(10,26,58,.8)', border:'1px solid rgba(62,230,245,.25)', color:'#EAF6FF', fontSize:13, caretColor:'#3EE6F5' }}
            />
          </div>

          {/* Type + Rank row */}
          <div className="grid grid-cols-2 gap-3">
            <div>
              <label className="font-orbitron uppercase tracking-system block mb-1.5" style={{ fontSize:9, color:'#7FA0C9' }}>
                TYPE
              </label>
              <div className="flex glass-panel rounded-lg overflow-hidden" style={{ border:'1px solid rgba(62,230,245,.15)' }}>
                {TYPES.map(t => (
                  <button key={t} onClick={() => set('type', t)}
                    className="flex-1 py-1.5 font-orbitron uppercase transition-all"
                    style={{ fontSize:8, color: form.type===t ? '#3EE6F5' : '#3E5578', background: form.type===t ? 'rgba(62,230,245,.12)' : 'transparent', letterSpacing:'.06em' }}>
                    {t}
                  </button>
                ))}
              </div>
            </div>
            <div>
              <label className="font-orbitron uppercase tracking-system block mb-1.5" style={{ fontSize:9, color:'#7FA0C9' }}>
                RANK
              </label>
              <div className="flex glass-panel rounded-lg overflow-hidden" style={{ border:'1px solid rgba(62,230,245,.15)' }}>
                {RANKS.map(r => (
                  <button key={r} onClick={() => set('rank', r)}
                    className="flex-1 py-1.5 font-orbitron font-bold transition-all"
                    style={{ fontSize:9, color: form.rank===r ? RANK_COLORS_MAP[r] : '#3E5578', background: form.rank===r ? `${RANK_COLORS_MAP[r]}15` : 'transparent' }}>
                    {r}
                  </button>
                ))}
              </div>
            </div>
          </div>

          {/* EXP + Gold + Deadline row */}
          <div className="grid grid-cols-3 gap-3">
            <div>
              <label className="font-orbitron uppercase tracking-system block mb-1.5" style={{ fontSize:9, color:'#7FA0C9' }}>EXP</label>
              <input type="number" min={0} max={9999} value={form.exp}
                onChange={e => set('exp', Number(e.target.value))}
                className="w-full rounded-lg px-2 py-2 font-mono-stat outline-none text-center"
                style={{ background:'rgba(10,26,58,.8)', border:'1px solid rgba(255,210,76,.25)', color:'#FFD24C', fontSize:13, caretColor:'#FFD24C' }}/>
            </div>
            <div>
              <label className="font-orbitron uppercase tracking-system block mb-1.5" style={{ fontSize:9, color:'#7FA0C9' }}>GOLD</label>
              <input type="number" min={0} max={9999} value={form.gold}
                onChange={e => set('gold', Number(e.target.value))}
                className="w-full rounded-lg px-2 py-2 font-mono-stat outline-none text-center"
                style={{ background:'rgba(10,26,58,.8)', border:'1px solid rgba(201,138,26,.25)', color:'#C98A1A', fontSize:13, caretColor:'#C98A1A' }}/>
            </div>
            <div>
              <label className="font-orbitron uppercase tracking-system block mb-1.5" style={{ fontSize:9, color:'#7FA0C9' }}>DEADLINE</label>
              <input type="text" placeholder="23:59" value={form.deadline}
                onChange={e => set('deadline', e.target.value)}
                className="w-full rounded-lg px-2 py-2 font-mono-stat outline-none text-center"
                style={{ background:'rgba(10,26,58,.8)', border:'1px solid rgba(62,230,245,.2)', color:'#3EE6F5', fontSize:11, caretColor:'#3EE6F5' }}/>
            </div>
          </div>

          <DiamondDivider/>

          {/* Preview chip */}
          <div className="glass-panel rounded-xl px-4 py-3" style={{ border:`1px solid ${RANK_COLORS_MAP[form.rank]}30` }}>
            <div className="flex items-center gap-3">
              <div className="w-8 h-8 rounded flex items-center justify-center font-orbitron font-bold"
                style={{ background:`${RANK_COLORS_MAP[form.rank]}15`, border:`1px solid ${RANK_COLORS_MAP[form.rank]}40`, color:RANK_COLORS_MAP[form.rank], fontSize:12 }}>
                {form.rank}
              </div>
              <div className="flex-1 min-w-0">
                <p className="font-orbitron font-bold uppercase truncate" style={{ fontSize:12, color: form.title ? '#EAF6FF' : '#3E5578' }}>
                  {form.title || 'QUEST TITLE...'}
                </p>
                <p className="font-mono-stat" style={{ fontSize:9, color:'#3E5578' }}>{form.type} · +{form.exp} EXP · ⬡{form.gold}G</p>
              </div>
            </div>
          </div>
        </div>

        {/* Footer CTA */}
        <div className="px-5 pb-6 pt-3 flex-shrink-0" style={{ borderTop:'1px solid rgba(62,230,245,.08)' }}>
          <button
            onClick={handleCreate}
            disabled={!form.title.trim()}
            className="w-full py-3.5 rounded-xl font-orbitron font-bold uppercase tracking-system transition-all active:scale-95"
            style={{ fontSize:13, background: form.title.trim() ? 'linear-gradient(135deg,#3EE6F5,#1FA9C2)' : 'rgba(62,230,245,.06)', color: form.title.trim() ? '#030712' : '#3E5578', border:'1px solid rgba(62,230,245,.3)', boxShadow: form.title.trim() ? '0 0 20px rgba(62,230,245,.3)' : 'none' }}>
            [ REGISTER QUEST ]
          </button>
        </div>
      </div>
    </div>
  )
}

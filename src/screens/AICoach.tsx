import { useState, useRef, useEffect } from 'react'
import { OrnatePanel, GlassCard, DiamondDivider, DecryptText, ScanlineSweep, UplinkChip } from '../components/SystemUI'
import { BackendBridge } from '../services/backendBridge'

interface Props { onBack: () => void }

type AIState = 'idle' | 'thinking' | 'streaming' | 'plan_proposed' | 'accepted'

interface Message { id: number; from: 'ai' | 'user'; text: string; timestamp: string }

const INITIAL_MESSAGES: Message[] = [
  {
    id: 1, from: 'ai',
    text: 'UPLINK ESTABLISHED. I am the System. Your growth is my directive. Today\'s analysis is ready. You\'ve completed 62% of your weekly objectives — strong, but your Vitality stack is underperforming. Shall I recalibrate your quest load?',
    timestamp: '09:14',
  },
  {
    id: 2, from: 'user',
    text: 'Yes. Plan my week around shipping the app.',
    timestamp: '09:15',
  },
]

const PROPOSED_PLAN = [
  { id: 'p1', rank: 'S', title: 'FINALIZE CORE FEATURES', exp: 400, time: '4h/day', days: 'MON–WED' },
  { id: 'p2', rank: 'A', title: 'QA & BUG CRUSHING', exp: 250, time: '3h/day', days: 'THU' },
  { id: 'p3', rank: 'A', title: 'LAUNCH & MARKETING PUSH', exp: 300, time: 'ALL DAY', days: 'FRI' },
  { id: 'p4', rank: 'B', title: 'DAILY VITALITY QUEST', exp: 80, time: '1h/day', days: 'DAILY' },
]

const ACTION_CHIPS = [
  '[ DEPLOY QUESTS ]', '[ PLAN MY WEEK ]', '[ ANALYZE MY STATS ]', '[ MOTIVATE ME ]', '[ ADJUST DIFFICULTY ]'
]

const RANK_COLORS: Record<string, string> = {
  S:'#FFD24C', A:'#FF9B3E', B:'#B26EFF', C:'#2E9BFF'
}

export default function AICoach({ onBack }: Props) {
  const [messages, setMessages] = useState<Message[]>(INITIAL_MESSAGES)
  const [input, setInput] = useState('')
  const [aiState, setAIState] = useState<AIState>('idle')
  const [planVisible, setPlanVisible] = useState(false)
  const [planAccepted, setPlanAccepted] = useState(false)
  const [activeJobId, setActiveJobId] = useState<string | null>(null)
  const scrollRef = useRef<HTMLDivElement>(null)

  useEffect(() => {
    setTimeout(() => scrollRef.current?.scrollTo({ top: 9999, behavior:'smooth' }), 100)
  }, [messages, planVisible])

  async function sendMessage(text: string) {
    if (!text.trim()) return
    const userMsg: Message = { id: Date.now(), from:'user', text: text.trim(), timestamp: new Date().toLocaleTimeString('en', { hour:'2-digit', minute:'2-digit' }) }
    setMessages(prev => [...prev, userMsg])
    setInput('')
    setAIState('thinking')

    const isPlanReq = text.toLowerCase().includes('plan') || text.toLowerCase().includes('week')

    if (isPlanReq) {
      try {
        const { jobId } = await BackendBridge.createAIPlan('hunter_1', text)
        setActiveJobId(jobId)
      } catch (e) {
        console.warn('AI Plan creation fallback', e)
      }
    }

    setTimeout(() => {
      setAIState('streaming')
      const aiMsg: Message = {
        id: Date.now()+1, from:'ai',
        text: isPlanReq
          ? 'Acknowledged. Processing optimal quest allocation based on your chronotype, streak data, and deadline proximity. Tactical briefing incoming...'
          : 'Understood, Hunter. The System has processed your directive. Your next objective has been recalibrated. Push forward.',
        timestamp: new Date().toLocaleTimeString('en', { hour:'2-digit', minute:'2-digit' }),
      }
      setMessages(prev => [...prev, aiMsg])
      if (isPlanReq) {
        setTimeout(() => { setPlanVisible(true); setAIState('plan_proposed') }, 2000)
      } else {
        setTimeout(() => setAIState('idle'), 1500)
      }
    }, 1400)
  }

  function acceptPlan() {
    setPlanAccepted(true)
    setAIState('accepted')

    if (activeJobId) {
      try {
        BackendBridge.approveAIPlan(activeJobId, 'hunter_1')
      } catch (e) {
        console.warn('AI Plan approval fallback', e)
      }
    }

    const msg: Message = {
      id: Date.now(), from:'ai',
      text: 'QUEST TREE DEPLOYED. Five objectives locked into your registry. Daily vitality stack is running. The week belongs to you, Hunter. Do not squander it.',
      timestamp: new Date().toLocaleTimeString('en', { hour:'2-digit', minute:'2-digit' }),
    }
    setMessages(prev => [...prev, msg])
    setPlanVisible(false)
  }


  return (
    <div className="absolute inset-0 z-40 flex flex-col void-bg circuit-overlay animate-slide-up">
      <ScanlineSweep/>

      {/* Ambient orb glow */}
      <div className="absolute top-20 left-1/2 -translate-x-1/2 w-48 h-48 rounded-full pointer-events-none"
        style={{ background:'radial-gradient(ellipse,rgba(62,230,245,.07) 0%,transparent 70%)' }}/>

      {/* Header */}
      <div className="flex items-center justify-between px-4 pt-6 pb-3 flex-shrink-0"
        style={{ borderBottom:'1px solid rgba(62,230,245,.12)' }}>
        <button onClick={onBack} className="font-orbitron uppercase tracking-system transition-all active:opacity-60"
          style={{ fontSize:10, color:'#3E5578' }}>← BACK</button>
        <div className="flex flex-col items-center">
          <p className="font-mono-stat" style={{ fontSize:8, color:'#7FA0C9' }}>[ SYSTEM AI ]</p>
          <h1 className="font-orbitron font-bold uppercase tracking-system" style={{ fontSize:13, color:'#EAF6FF' }}>
            AI COACH
          </h1>
        </div>
        <UplinkChip stable/>
      </div>

      {/* Orb Avatar */}
      <div className="flex justify-center pt-4 pb-2 flex-shrink-0">
        <div className="relative">
          {/* Orbit rings */}
          <div className="absolute inset-0 rounded-full" style={{ width:72, height:72, left:'50%', top:'50%', transform:'translate(-50%,-50%)', border:'1px solid rgba(62,230,245,.15)', animation:'portal-spin 12s linear infinite', borderRadius:'50%', padding:8 }}/>
          <div className="absolute inset-0 rounded-full" style={{ width:88, height:88, left:'50%', top:'50%', transform:'translate(-50%,-50%)', border:'1px solid rgba(57,255,136,.08)', animation:'portal-spin-rev 18s linear infinite', borderRadius:'50%' }}/>
          {/* Core orb */}
          <div className="w-14 h-14 rounded-full flex items-center justify-center"
            style={{ background:'radial-gradient(ellipse at 35% 35%,rgba(62,230,245,.3),rgba(10,26,58,.9))', border:'2px solid #3EE6F5', boxShadow:'0 0 24px rgba(62,230,245,.5),0 0 48px rgba(62,230,245,.15),inset 0 0 16px rgba(62,230,245,.2)', animation:'orb-breathe 3s ease-in-out infinite' }}>
            <span style={{ fontSize:22 }}>◈</span>
          </div>
        </div>
      </div>
      <p className="text-center font-mono-stat mb-3" style={{ fontSize:9, color:'#3EE6F5', letterSpacing:'.12em' }}>
        {aiState === 'thinking' ? '[ PROCESSING... ]' : aiState === 'streaming' ? '[ TRANSMITTING... ]' : aiState === 'accepted' ? '[ QUEST TREE DEPLOYED ]' : '[ SYSTEM ONLINE ]'}
      </p>

      {/* Chat scroll area */}
      <div ref={scrollRef} className="flex-1 overflow-y-auto px-4 space-y-3 pb-2">
        {messages.map(msg => (
          msg.from === 'ai'
            ? <AIMessage key={msg.id} msg={msg} streaming={aiState === 'streaming' && msg.id === messages[messages.length-1]?.id && msg.from === 'ai'}/>
            : <UserMessage key={msg.id} msg={msg}/>
        ))}

        {/* Plan Card */}
        {planVisible && !planAccepted && (
          <OrnatePanel cornerSize={22} className="animate-fade-in">
            <div className="p-4 pt-6">
              <p className="font-mono-stat mb-1" style={{ fontSize:9, color:'#7FA0C9' }}>[ TACTICAL BRIEF — WEEK PLAN ]</p>
              <p className="font-orbitron font-bold uppercase tracking-system mb-3" style={{ fontSize:12, color:'#EAF6FF' }}>
                OPTIMAL QUEST SEQUENCE
              </p>
              <div className="space-y-2 mb-3">
                {PROPOSED_PLAN.map(q => (
                  <div key={q.id} className="flex items-center gap-2 glass-panel rounded-lg px-3 py-2"
                    style={{ border:`1px solid ${RANK_COLORS[q.rank]}25` }}>
                    <span className="w-5 h-5 rounded flex items-center justify-center font-orbitron font-bold flex-shrink-0"
                      style={{ fontSize:9, color:RANK_COLORS[q.rank], background:`${RANK_COLORS[q.rank]}15`, border:`1px solid ${RANK_COLORS[q.rank]}30` }}>{q.rank}</span>
                    <div className="flex-1 min-w-0">
                      <p className="font-orbitron uppercase truncate" style={{ fontSize:10, color:'#EAF6FF' }}>{q.title}</p>
                      <p className="font-mono-stat" style={{ fontSize:9, color:'#7FA0C9' }}>{q.days} · {q.time}</p>
                    </div>
                    <span className="font-mono-stat flex-shrink-0" style={{ fontSize:9, color:'#FFD24C' }}>+{q.exp}</span>
                  </div>
                ))}
              </div>
              <DiamondDivider/>
              <div className="flex gap-2 mt-2">
                <button onClick={() => setPlanVisible(false)}
                  className="flex-1 py-2 rounded-lg font-orbitron uppercase tracking-system transition-all active:scale-95"
                  style={{ fontSize:9, border:'1px solid rgba(62,230,245,.2)', color:'#3E5578' }}>EDIT</button>
                <button onClick={acceptPlan}
                  className="flex-1 py-2 rounded-lg font-orbitron uppercase tracking-system transition-all active:scale-95"
                  style={{ fontSize:9, background:'linear-gradient(135deg,#3EE6F5,#1FA9C2)', color:'#030712' }}>ACCEPT & DEPLOY</button>
              </div>
            </div>
          </OrnatePanel>
        )}

        {/* Thinking indicator */}
        {aiState === 'thinking' && (
          <div className="flex items-center gap-2">
            <div className="w-7 h-7 rounded-full flex items-center justify-center flex-shrink-0"
              style={{ background:'rgba(62,230,245,.1)', border:'1px solid rgba(62,230,245,.3)' }}>
              <span style={{ fontSize:12 }}>◈</span>
            </div>
            <div className="glass-panel rounded-2xl rounded-tl-sm px-4 py-2"
              style={{ border:'1px solid rgba(62,230,245,.2)' }}>
              <div className="flex gap-1">
                {[0,1,2].map(i => (
                  <div key={i} className="w-1.5 h-1.5 rounded-full"
                    style={{ background:'#3EE6F5', animation:`uplink-pulse 1.2s ease-in-out ${i*0.2}s infinite` }}/>
                ))}
              </div>
            </div>
          </div>
        )}
      </div>

      {/* Action chips */}
      <div className="flex gap-2 overflow-x-auto px-4 py-2 flex-shrink-0" style={{ scrollbarWidth:'none' }}>
        {ACTION_CHIPS.map((chip, i) => (
          <button key={i} onClick={() => sendMessage(chip.replace(/[\[\]]/g,'').trim())}
            className="flex-shrink-0 glass-panel rounded-full px-3 py-1.5 font-mono-stat transition-all active:scale-90"
            style={{ fontSize:9, color:'#3EE6F5', border:'1px solid rgba(62,230,245,.2)', whiteSpace:'nowrap' }}>
            {chip}
          </button>
        ))}
      </div>

      {/* Input bar */}
      <div className="px-4 pb-4 pt-1 flex-shrink-0">
        <div className="flex gap-2 glass-panel rounded-2xl p-2"
          style={{ border:'1px solid rgba(62,230,245,.2)' }}>
          <input
            className="flex-1 bg-transparent outline-none font-mono-stat"
            style={{ fontSize:13, color:'#EAF6FF', caretColor:'#39FF88' }}
            placeholder="> Enter directive..."
            value={input}
            onChange={e => setInput(e.target.value)}
            onKeyDown={e => e.key === 'Enter' && sendMessage(input)}
          />
          <button onClick={() => sendMessage(input)} disabled={!input.trim()}
            className="w-9 h-9 rounded-xl flex items-center justify-center transition-all active:scale-90 flex-shrink-0"
            style={{ background: input.trim() ? 'linear-gradient(135deg,#3EE6F5,#1FA9C2)' : 'rgba(62,230,245,.08)', color: input.trim() ? '#030712' : '#3E5578' }}>
            ↑
          </button>
        </div>
      </div>
    </div>
  )
}

function AIMessage({ msg, streaming }: { msg: Message; streaming: boolean }) {
  return (
    <div className="flex items-start gap-2">
      <div className="w-7 h-7 rounded-full flex items-center justify-center flex-shrink-0 mt-0.5"
        style={{ background:'rgba(62,230,245,.1)', border:'1px solid rgba(62,230,245,.3)' }}>
        <span style={{ fontSize:12 }}>◈</span>
      </div>
      <div className="flex-1">
        <OrnatePanel cornerSize={18} noCrest>
          <div className="px-3 py-2.5 pt-4">
            {streaming
              ? <span className="font-mono-stat" style={{ fontSize:12, color:'#EAF6FF', lineHeight:1.5 }}><DecryptText text={msg.text} speed={25}/></span>
              : <p className="font-mono-stat" style={{ fontSize:12, color:'#EAF6FF', lineHeight:1.5 }}>{msg.text}</p>
            }
          </div>
        </OrnatePanel>
        <p className="font-mono-stat mt-1 ml-2" style={{ fontSize:8, color:'#3E5578' }}>{msg.timestamp}</p>
      </div>
    </div>
  )
}

function UserMessage({ msg }: { msg: Message }) {
  return (
    <div className="flex justify-end">
      <div>
        <div className="rounded-2xl rounded-tr-sm px-4 py-2.5"
          style={{ background:'transparent', border:'1px solid rgba(62,230,245,.35)', maxWidth:240 }}>
          <p className="font-rajdhani" style={{ fontSize:13, color:'#EAF6FF' }}>{msg.text}</p>
        </div>
        <p className="font-mono-stat mt-1 text-right mr-2" style={{ fontSize:8, color:'#3E5578' }}>{msg.timestamp}</p>
      </div>
    </div>
  )
}

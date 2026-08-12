import { useState } from 'react'
import { RankBadge, DiamondDivider, OrnatePanel } from '../components/SystemUI'

type Item = { id: number; name: string; desc: string; cost: number; rank: string; type: 'reward' | 'cosmetic'; owned: boolean; icon: string }

const ITEMS: Item[] = [
  { id: 1, name: '1HR GUILT-FREE GAMING', desc: 'Grant yourself one hour of gaming without the System judging you.', cost: 200, rank: 'D', type: 'reward', owned: false, icon: '🎮' },
  { id: 2, name: 'ORDER TAKEOUT', desc: 'Summon sustenance from the outside world. You have earned it.', cost: 150, rank: 'D', type: 'reward', owned: false, icon: '🍜' },
  { id: 3, name: 'REST DAY PASS', desc: 'One sanctioned recovery day. The System permits it — once.', cost: 500, rank: 'B', type: 'reward', owned: false, icon: '💤' },
  { id: 4, name: 'NEW EQUIPMENT', desc: 'Allocate gold toward real-world gear: shoes, weights, tools.', cost: 1000, rank: 'A', type: 'reward', owned: false, icon: '⚔' },
  { id: 5, name: 'MOVIE NIGHT', desc: 'An evening of cinematic entertainment. System-approved leisure.', cost: 100, rank: 'E', type: 'reward', owned: false, icon: '🎬' },
  { id: 6, name: 'GOLD BORDER THEME', desc: 'Unlock the S-Rank gold interface overlay. Cosmetic only.', cost: 800, rank: 'S', type: 'cosmetic', owned: true, icon: '✨' },
  { id: 7, name: 'VOID WINDOW SKIN', desc: 'Alter the System window to pure black-void aesthetic.', cost: 600, rank: 'A', type: 'cosmetic', owned: false, icon: '◈' },
  { id: 8, name: '"SHADOW LORD" FRAME', desc: 'Equip the Shadow Monarch title frame around your profile.', cost: 1200, rank: 'S', type: 'cosmetic', owned: false, icon: '◆' },
]

const RANK_COLORS: Record<string, string> = {
  E: '#8A94A6', D: '#39D98A', C: '#2E9BFF', B: '#B26EFF', A: '#FF9B3E', S: '#FFD24C'
}

export default function Armory({ gold = 1240 }: { gold?: number }) {
  const [filter, setFilter] = useState<'all' | 'reward' | 'cosmetic'>('all')
  const [ownedIds, setOwnedIds] = useState<number[]>([6])
  const [currentGold, setCurrentGold] = useState(gold)
  const [selectedItem, setSelectedItem] = useState<Item | null>(null)
  const [buying, setBuying] = useState(false)

  const filtered = filter === 'all' ? ITEMS : ITEMS.filter(i => i.type === filter)

  function handleBuy(item: Item) {
    if (currentGold < item.cost || ownedIds.includes(item.id)) return
    setCurrentGold(g => g - item.cost)
    setOwnedIds(ids => [...ids, item.id])
    setBuying(false)
    setSelectedItem(null)
  }

  return (
    <div className="flex flex-col h-full void-bg overflow-y-auto" style={{ paddingTop: 52, paddingBottom: 20 }}>
      <div className="px-4 pt-3 space-y-3">
        {/* Header */}
        <div className="flex items-start justify-between">
          <div>
            <p className="font-mono-stat" style={{ fontSize: 10, color: '#3E5578' }}>[ REWARDS VAULT ]</p>
            <h1 className="font-orbitron font-bold uppercase" style={{ fontSize: 22, color: '#EAF6FF', letterSpacing: '0.05em' }}>
              ARMORY
            </h1>
          </div>
          <div className="glass-panel rounded-xl px-3 py-2" style={{ border: '1px solid rgba(255,210,76,0.3)' }}>
            <p className="font-mono-stat" style={{ fontSize: 9, color: '#7FA0C9' }}>GOLD</p>
            <p className="font-mono-stat" style={{ fontSize: 16, color: '#FFD24C' }}>⬡ {currentGold.toLocaleString()}</p>
          </div>
        </div>

        {/* Filter tabs */}
        <div className="flex glass-panel rounded-xl overflow-hidden" style={{ border: '1px solid rgba(62,230,245,0.15)' }}>
          {(['all', 'reward', 'cosmetic'] as const).map(f => (
            <button key={f} onClick={() => setFilter(f)}
              className="flex-1 py-2 font-orbitron font-bold uppercase tracking-system transition-all"
              style={{
                fontSize: 8, color: filter === f ? '#3EE6F5' : '#3E5578',
                background: filter === f ? 'rgba(62,230,245,0.1)' : 'transparent',
                borderBottom: filter === f ? '2px solid #3EE6F5' : '2px solid transparent',
              }}>
              {f === 'all' ? 'ALL ITEMS' : f === 'reward' ? 'REAL REWARDS' : 'COSMETICS'}
            </button>
          ))}
        </div>

        {/* Grid */}
        <div className="grid grid-cols-2 gap-3">
          {filtered.map(item => {
            const owned = ownedIds.includes(item.id)
            const canAfford = currentGold >= item.cost
            const rankColor = RANK_COLORS[item.rank] ?? '#8A94A6'
            return (
              <button
                key={item.id}
                onClick={() => setSelectedItem(item)}
                className="glass-panel rounded-xl overflow-hidden text-left transition-all active:scale-95"
                style={{
                  border: owned ? `1px solid ${rankColor}60` : `1px solid ${rankColor}20`,
                  boxShadow: owned ? `0 0 10px ${rankColor}20` : 'none',
                }}
              >
                {/* Item image area */}
                <div
                  className="w-full flex items-center justify-center"
                  style={{ height: 80, background: `${rankColor}08` }}
                >
                  <span style={{ fontSize: 36 }}>{item.icon}</span>
                </div>

                <div className="p-2.5">
                  <div className="flex items-center gap-1.5 mb-1">
                    <RankBadge rank={item.rank} size="sm" />
                    {owned && (
                      <span className="font-mono-stat rounded px-1" style={{ fontSize: 7, color: '#39FF88', background: 'rgba(57,255,136,0.1)', border: '1px solid rgba(57,255,136,0.3)' }}>
                        OWNED
                      </span>
                    )}
                  </div>
                  <p className="font-orbitron font-bold uppercase" style={{ fontSize: 9, color: '#EAF6FF', lineHeight: 1.3, marginBottom: 4 }}>
                    {item.name}
                  </p>
                  <div className="flex items-center justify-between">
                    <span className="font-mono-stat" style={{ fontSize: 10, color: owned ? '#39FF88' : (canAfford ? '#FFD24C' : '#FF2E4D') }}>
                      {owned ? '✓ ACQUIRED' : `⬡ ${item.cost}`}
                    </span>
                    <span className="font-mono-stat" style={{ fontSize: 7, color: '#3E5578' }}>
                      {item.type === 'reward' ? 'REAL' : 'COSM'}
                    </span>
                  </div>
                </div>
              </button>
            )
          })}
        </div>
      </div>

      {/* Item detail modal */}
      {selectedItem && (
        <div className="absolute inset-0 z-40 flex items-end" style={{ background: 'rgba(3,7,18,0.85)' }} onClick={() => { setSelectedItem(null); setBuying(false) }}>
          <div className="w-full animate-slide-up" onClick={e => e.stopPropagation()}>
            <OrnatePanel cornerSize={24} className="rounded-none rounded-t-2xl">
              <div className="p-5 pt-8">
                <div className="w-10 h-1 rounded-full mx-auto mb-4" style={{ background: 'rgba(62,230,245,0.3)' }} />
                <div className="flex items-start gap-4 mb-4">
                  <div className="w-16 h-16 rounded-xl flex items-center justify-center flex-shrink-0" style={{ background: `${RANK_COLORS[selectedItem.rank]}10`, border: `1px solid ${RANK_COLORS[selectedItem.rank]}30` }}>
                    <span style={{ fontSize: 32 }}>{selectedItem.icon}</span>
                  </div>
                  <div className="flex-1">
                    <div className="flex items-center gap-2 mb-1">
                      <RankBadge rank={selectedItem.rank} size="sm" />
                      <span className="font-mono-stat" style={{ fontSize: 8, color: '#7FA0C9' }}>
                        {selectedItem.type === 'reward' ? 'REAL REWARD' : 'COSMETIC ITEM'}
                      </span>
                    </div>
                    <p className="font-orbitron font-bold uppercase" style={{ fontSize: 14, color: '#EAF6FF' }}>
                      {selectedItem.name}
                    </p>
                  </div>
                </div>

                <p className="font-rajdhani mb-4" style={{ fontSize: 13, color: '#7FA0C9' }}>
                  [ {selectedItem.desc} ]
                </p>

                <DiamondDivider />

                <div className="flex items-center justify-between mb-4">
                  <div>
                    <p className="font-mono-stat" style={{ fontSize: 9, color: '#7FA0C9' }}>COST</p>
                    <p className="font-mono-stat" style={{ fontSize: 20, color: '#FFD24C' }}>⬡ {selectedItem.cost}</p>
                  </div>
                  <div className="text-right">
                    <p className="font-mono-stat" style={{ fontSize: 9, color: '#7FA0C9' }}>YOUR GOLD</p>
                    <p className="font-mono-stat" style={{ fontSize: 16, color: currentGold >= selectedItem.cost ? '#39FF88' : '#FF2E4D' }}>
                      ⬡ {currentGold.toLocaleString()}
                    </p>
                  </div>
                </div>

                {ownedIds.includes(selectedItem.id) ? (
                  <button disabled className="w-full py-3.5 rounded-xl font-orbitron font-bold uppercase tracking-system" style={{ fontSize: 12, background: 'rgba(57,255,136,0.1)', border: '1px solid rgba(57,255,136,0.3)', color: '#39FF88' }}>
                    ✓ ITEM ACQUIRED
                  </button>
                ) : currentGold < selectedItem.cost ? (
                  <button disabled className="w-full py-3.5 rounded-xl font-orbitron font-bold uppercase tracking-system" style={{ fontSize: 12, background: 'rgba(255,46,77,0.05)', border: '1px solid rgba(255,46,77,0.2)', color: '#FF2E4D' }}>
                    INSUFFICIENT GOLD
                  </button>
                ) : (
                  <button onClick={() => handleBuy(selectedItem)} className="w-full py-3.5 rounded-xl font-orbitron font-bold uppercase tracking-system transition-all active:scale-95" style={{ fontSize: 12, background: 'linear-gradient(135deg, rgba(255,210,76,0.2), rgba(201,138,26,0.1))', border: '1px solid rgba(255,210,76,0.5)', color: '#FFD24C', boxShadow: '0 0 16px rgba(255,210,76,0.2)' }}>
                    ⬡ ACQUIRE FOR {selectedItem.cost} GOLD
                  </button>
                )}
              </div>
            </OrnatePanel>
          </div>
        </div>
      )}
    </div>
  )
}

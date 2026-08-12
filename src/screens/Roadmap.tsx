import { useState } from 'react'
import { GlassCard, RankBadge, DiamondDivider } from '../components/SystemUI'

type NodeStatus = 'complete' | 'active' | 'available' | 'locked'
interface MapNode {
  id: string; x: number; y: number; label: string
  rank: string; category: string; status: NodeStatus
  exp: number; progress: number; desc: string
  requires?: string
}

const CATEGORY_COLORS: Record<string, string> = {
  body: '#FF5A36',
  mind: '#2E9BFF',
  craft: '#B26EFF',
  discipline: '#FFD24C',
}

const NODES: MapNode[] = [
  /* BODY branch */
  { id: 'b1', x: 60, y: 300, label: '30-DAY RUN', rank: 'D', category: 'body', status: 'complete', exp: 300, progress: 100, desc: 'Complete 30 consecutive days of running.' },
  { id: 'b2', x: 60, y: 200, label: '10KM DAILY', rank: 'C', category: 'body', status: 'active', exp: 600, progress: 65, desc: 'Maintain 10km daily run for 30 days.', requires: 'b1' },
  { id: 'b3', x: 60, y: 100, label: 'MARATHON', rank: 'A', category: 'body', status: 'locked', exp: 1500, progress: 0, desc: 'Complete a full 42.195km marathon.', requires: 'b2' },
  /* MIND branch */
  { id: 'm1', x: 175, y: 320, label: 'READ 12 BOOKS', rank: 'C', category: 'mind', status: 'active', exp: 800, progress: 25, desc: 'Read 12 books in a calendar year.' },
  { id: 'm2', x: 175, y: 210, label: 'STUDY DAILY', rank: 'B', category: 'mind', status: 'available', exp: 1000, progress: 0, desc: 'Study 1 hour daily for 60 days.', requires: 'm1' },
  { id: 'm3', x: 175, y: 100, label: 'MASTER CRAFT', rank: 'S', category: 'mind', status: 'locked', exp: 2500, progress: 0, desc: 'Achieve mastery in your chosen domain.', requires: 'm2' },
  /* CRAFT branch */
  { id: 'c1', x: 290, y: 310, label: 'SHIP A PROJECT', rank: 'C', category: 'craft', status: 'active', exp: 1000, progress: 35, desc: 'Release a project to the public.' },
  { id: 'c2', x: 290, y: 200, label: 'SHIP THE APP', rank: 'A', category: 'craft', status: 'locked', exp: 2000, progress: 0, desc: 'Launch your main project in production.', requires: 'c1' },
  /* DISCIPLINE branch */
  { id: 'd1', x: 80, y: 420, label: '30-DAY STREAK', rank: 'D', category: 'discipline', status: 'complete', exp: 200, progress: 100, desc: 'Maintain a 30-day daily quest streak.' },
  { id: 'd2', x: 175, y: 450, label: '90-DAY STREAK', rank: 'B', category: 'discipline', status: 'active', exp: 600, progress: 47, desc: 'Maintain a 90-day quest streak.', requires: 'd1' },
  { id: 'd3', x: 280, y: 420, label: '1-YEAR STREAK', rank: 'S', category: 'discipline', status: 'locked', exp: 5000, progress: 0, desc: 'One year. No breaks. Unbroken.', requires: 'd2' },
  /* Center you-are-here node */
  { id: 'you', x: 175, y: 370, label: 'YOU ARE HERE', rank: 'E', category: 'discipline', status: 'active', exp: 0, progress: 0, desc: 'Current position.' },
]

const CONNECTIONS = [
  ['b1', 'b2'], ['b2', 'b3'],
  ['m1', 'm2'], ['m2', 'm3'],
  ['c1', 'c2'],
  ['d1', 'you'], ['d1', 'd2'], ['d2', 'd3'],
  ['you', 'b1'], ['you', 'm1'], ['you', 'c1'],
]

const STATUS_LABELS: Record<NodeStatus, string> = {
  complete: '✓ CLEARED', active: '● IN PROGRESS', available: '○ AVAILABLE', locked: '🔒 LOCKED'
}

export default function Roadmap() {
  const [selectedNode, setSelectedNode] = useState<MapNode | null>(null)

  const NODE_MAP = Object.fromEntries(NODES.map(n => [n.id, n]))
  const VIEW_W = 350
  const VIEW_H = 500

  return (
    <div className="flex flex-col h-full void-bg" style={{ paddingTop: 76, paddingBottom: 80 }}>

      {/* Header */}
      <div className="px-4 pt-3 pb-2">
        <p className="font-mono-stat" style={{ fontSize: 10, color: '#3E5578' }}>[ DUNGEON MAP — LONG TERM OBJECTIVES ]</p>
        <h1 className="font-orbitron font-bold uppercase" style={{ fontSize: 22, color: '#EAF6FF', letterSpacing: '0.05em' }}>
          ROADMAP
        </h1>
      </div>

      {/* Category legend */}
      <div className="px-4 mb-2">
        <div className="flex gap-3">
          {Object.entries(CATEGORY_COLORS).map(([cat, color]) => (
            <div key={cat} className="flex items-center gap-1">
              <div className="w-2 h-2 rounded-full" style={{ background: color }} />
              <span className="font-orbitron uppercase tracking-system" style={{ fontSize: 7, color: '#7FA0C9' }}>
                {cat}
              </span>
            </div>
          ))}
        </div>
      </div>

      {/* SVG Constellation Map */}
      <div className="flex-1 relative overflow-hidden" style={{ background: 'radial-gradient(ellipse at center, #0B1330 0%, #030712 100%)' }}>
        {/* Circuit overlay */}
        <div className="absolute inset-0 circuit-overlay opacity-40 pointer-events-none" />

        <svg
          width="100%"
          height="100%"
          viewBox={`0 0 ${VIEW_W} ${VIEW_H}`}
          style={{ overflow: 'visible' }}
        >
          <defs>
            <radialGradient id="fog" cx="50%" cy="50%" r="50%">
              <stop offset="60%" stopColor="transparent" />
              <stop offset="100%" stopColor="rgba(3,7,18,0.7)" />
            </radialGradient>
            <filter id="node-glow">
              <feGaussianBlur in="SourceGraphic" stdDeviation="3" result="blur" />
              <feMerge><feMergeNode in="blur" /><feMergeNode in="SourceGraphic" /></feMerge>
            </filter>
            <filter id="line-glow">
              <feGaussianBlur in="SourceGraphic" stdDeviation="1.5" result="blur" />
              <feMerge><feMergeNode in="blur" /><feMergeNode in="SourceGraphic" /></feMerge>
            </filter>
          </defs>

          {/* Connection lines */}
          {CONNECTIONS.map(([fromId, toId]) => {
            const from = NODE_MAP[fromId]
            const to = NODE_MAP[toId]
            if (!from || !to) return null
            const isActive = from.status !== 'locked' && to.status !== 'locked'
            return (
              <line
                key={`${fromId}-${toId}`}
                x1={from.x} y1={from.y} x2={to.x} y2={to.y}
                stroke={isActive ? `rgba(62,230,245,0.4)` : 'rgba(62,230,245,0.08)'}
                strokeWidth={isActive ? 1.5 : 1}
                strokeDasharray={to.status === 'locked' ? '4 4' : 'none'}
                filter={isActive ? 'url(#line-glow)' : undefined}
              />
            )
          })}

          {/* Nodes */}
          {NODES.map(node => {
            if (node.id === 'you') {
              /* YOU ARE HERE node */
              return (
                <g key={node.id} style={{ cursor: 'pointer' }} onClick={() => setSelectedNode(node)}>
                  <circle cx={node.x} cy={node.y} r={18} fill="rgba(62,230,245,0.1)"
                    style={{ animation: 'node-pulse 2.5s ease-in-out infinite' }} />
                  <circle cx={node.x} cy={node.y} r={12} fill="rgba(62,230,245,0.2)" stroke="#3EE6F5" strokeWidth="2" filter="url(#node-glow)" />
                  <circle cx={node.x} cy={node.y} r={5} fill="#3EE6F5" />
                  <text x={node.x} y={node.y + 26} textAnchor="middle" fill="#3EE6F5"
                    fontFamily="'Orbitron'" fontSize="6" fontWeight="700" letterSpacing="0.06em">
                    ▲ YOU
                  </text>
                </g>
              )
            }

            const color = CATEGORY_COLORS[node.category] ?? '#8A94A6'
            const isBoss = node.rank === 'S'
            const isDone = node.status === 'complete'
            const isLocked = node.status === 'locked'
            const nodeRadius = isBoss ? 16 : 11
            const selected = selectedNode?.id === node.id

            return (
              <g key={node.id} style={{ cursor: 'pointer' }} onClick={() => setSelectedNode(node)}>
                {/* Glow ring for active/boss */}
                {(node.status === 'active' || isBoss) && !isLocked && (
                  <circle cx={node.x} cy={node.y} r={nodeRadius + 6}
                    fill="none" stroke={color} strokeWidth="1"
                    opacity="0.25"
                    style={{ animation: `node-pulse ${isBoss ? '2s' : '3s'} ease-in-out infinite` }}
                  />
                )}

                {/* Main circle */}
                <circle
                  cx={node.x} cy={node.y} r={nodeRadius}
                  fill={isDone ? `${color}30` : isLocked ? 'rgba(10,26,58,0.8)' : `${color}18`}
                  stroke={isLocked ? 'rgba(62,230,245,0.1)' : color}
                  strokeWidth={isBoss ? 2.5 : selected ? 2 : 1.5}
                  filter={!isLocked ? 'url(#node-glow)' : undefined}
                />

                {/* Inner indicator */}
                {isDone && <circle cx={node.x} cy={node.y} r={4} fill={color} opacity="0.9" />}
                {node.status === 'active' && !isDone && (
                  <circle cx={node.x} cy={node.y} r={4} fill={color} opacity="0.5"
                    style={{ animation: 'heat-pulse 2s ease-in-out infinite' }}
                  />
                )}
                {isLocked && (
                  <text x={node.x} y={node.y + 4} textAnchor="middle" fill="rgba(62,230,245,0.3)"
                    fontFamily="'Share Tech Mono'" fontSize={nodeRadius * 0.9}>
                    🔒
                  </text>
                )}
                {isBoss && !isLocked && (
                  <text x={node.x} y={node.y + 4} textAnchor="middle" fill={color}
                    fontFamily="'Orbitron'" fontSize="9" fontWeight="900">
                    S
                  </text>
                )}

                {/* Label */}
                <text
                  x={node.x} y={node.y + nodeRadius + 12}
                  textAnchor="middle"
                  fill={isLocked ? 'rgba(62,230,245,0.2)' : '#EAF6FF'}
                  fontFamily="'Orbitron'" fontSize="6.5" fontWeight="700"
                  letterSpacing="0.04em"
                >
                  {node.label.length > 10 ? node.label.slice(0, 9) + '…' : node.label}
                </text>
              </g>
            )
          })}

          {/* Fog of war at edges */}
          <rect x="0" y="0" width={VIEW_W} height={VIEW_H} fill="url(#fog)" pointerEvents="none" />
        </svg>
      </div>

      {/* ── NODE DETAIL BOTTOM SHEET ── */}
      {selectedNode && (
        <div
          className="absolute inset-0 z-40 flex items-end"
          style={{ background: 'rgba(3,7,18,0.6)' }}
          onClick={() => setSelectedNode(null)}
        >
          <div
            className="w-full animate-slide-up glass-panel rounded-t-2xl"
            style={{ border: '1px solid rgba(62,230,245,0.25)', borderBottom: 'none', maxHeight: '55%', overflowY: 'auto' }}
            onClick={e => e.stopPropagation()}
          >
            <div className="p-5">
              <div className="w-10 h-1 rounded-full mx-auto mb-4" style={{ background: 'rgba(62,230,245,0.3)' }} />

              <div className="flex items-center gap-3 mb-3">
                <RankBadge rank={selectedNode.rank} size="md" />
                <div>
                  <p className="font-orbitron font-bold uppercase" style={{ fontSize: 15, color: '#EAF6FF' }}>
                    {selectedNode.label}
                  </p>
                  <p className="font-mono-stat" style={{ fontSize: 10, color: CATEGORY_COLORS[selectedNode.category] }}>
                    {selectedNode.category.toUpperCase()} BRANCH — {STATUS_LABELS[selectedNode.status]}
                  </p>
                </div>
              </div>

              <p className="font-rajdhani mb-3" style={{ fontSize: 13, color: '#7FA0C9' }}>
                {selectedNode.desc}
              </p>

              {selectedNode.progress > 0 && (
                <div className="mb-3">
                  <div className="flex justify-between mb-1">
                    <span className="font-mono-stat" style={{ fontSize: 9, color: '#7FA0C9' }}>PROGRESS</span>
                    <span className="font-mono-stat" style={{ fontSize: 9, color: '#EAF6FF' }}>{selectedNode.progress}%</span>
                  </div>
                  <div className="h-2 rounded-full overflow-hidden" style={{ background: 'rgba(10,26,58,0.8)' }}>
                    <div
                      className="h-full rounded-full"
                      style={{
                        width: `${selectedNode.progress}%`,
                        background: `linear-gradient(90deg, ${CATEGORY_COLORS[selectedNode.category]}99, ${CATEGORY_COLORS[selectedNode.category]})`,
                      }}
                    />
                  </div>
                </div>
              )}

              <DiamondDivider />

              <div className="flex items-center justify-between">
                <div>
                  <p className="font-mono-stat" style={{ fontSize: 9, color: '#7FA0C9' }}>REWARD</p>
                  <p className="font-mono-stat" style={{ fontSize: 14, color: '#FFD24C' }}>+{selectedNode.exp.toLocaleString()} EXP</p>
                </div>
                {selectedNode.requires && (
                  <div className="text-right">
                    <p className="font-mono-stat" style={{ fontSize: 9, color: '#7FA0C9' }}>REQUIRES</p>
                    <p className="font-orbitron" style={{ fontSize: 10, color: '#3E5578' }}>
                      {NODES.find(n => n.id === selectedNode.requires)?.label ?? '—'}
                    </p>
                  </div>
                )}
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}

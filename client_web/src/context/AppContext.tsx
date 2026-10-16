import React, { createContext, useContext, useState, useEffect, useCallback } from 'react'
import { services } from '../api/services'
import { apiClient } from '../api/client'
import type { CharacterResponse, User, CompleteQuestResult } from '../api/types'

export type PlayerData = {
  name: string
  title: string
  level: number
  rank: string
  hp: number
  maxHp: number
  mp: number
  maxMp: number
  exp: number
  maxExp: number
  gold: number
  streak: number
  str: number
  agi: number
  vit: number
  int: number
  per: number
  remainingPoints: number
}

export const DEFAULT_PLAYER: PlayerData = {
  name: 'HUNTER',
  title: 'THE AWAKENED',
  level: 1,
  rank: 'E',
  hp: 2000,
  maxHp: 5000,
  mp: 100,
  maxMp: 100,
  exp: 0,
  maxExp: 100,
  gold: 0,
  streak: 1,
  str: 10,
  agi: 10,
  vit: 10,
  int: 10,
  per: 10,
  remainingPoints: 0,
}

export type AppPhase = 'auth' | 'onboarding' | 'main'

interface AppContextValue {
  phase: AppPhase
  setPhase: (phase: AppPhase) => void
  user: User | null
  player: PlayerData
  isLoadingAuth: boolean
  authError: string | null
  refreshPlayer: () => Promise<PlayerData | null>
  handleLogin: (email: string, pass: string) => Promise<boolean>
  handleSignup: (email: string, pass: string, name?: string) => Promise<boolean>
  handleLogout: () => Promise<void>
  handleQuestCompleted: (result: CompleteQuestResult) => Promise<void>
  showLevelUp: boolean
  setShowLevelUp: (show: boolean) => void
  showPenalty: boolean
  setShowPenalty: (show: boolean) => void
  levelUpData: { oldLevel: number; newLevel: number; newPoints: number }
  penaltyMissedQuest: string
  setPenaltyMissedQuest: (quest: string) => void
}

const AppContext = createContext<AppContextValue | null>(null)

export function mapCharacterToPlayer(char: CharacterResponse, user?: User | null): PlayerData {
  const userName = user?.email ? user.email.split('@')[0].toUpperCase() : 'HUNTER'
  const title = char.activeTitleId || 'THE AWAKENED'
  const str = char.stats?.fitness ?? 10
  const agi = char.stats?.creativity ?? 10
  const vit = char.stats?.health ?? 10
  const intVal = char.stats?.intelligence ?? 10
  const per = char.stats?.discipline ?? 10
  const maxHp = 5000
  const hp = Math.min(maxHp, Math.max(1000, vit * 150))
  const maxExp = char.totalXp + (char.xpToNextLevel || 100)

  return {
    name: userName,
    title,
    level: char.level || 1,
    rank: char.rank || 'E',
    hp,
    maxHp,
    mp: char.currentMana ?? 100,
    maxMp: char.maxMana ?? 100,
    exp: char.totalXp || 0,
    maxExp: maxExp > char.totalXp ? maxExp : char.totalXp + 100,
    gold: char.coins || 0,
    streak: Math.max(1, Math.floor((char.totalXp || 0) / 100) + 1),
    str,
    agi,
    vit,
    int: intVal,
    per,
    remainingPoints: 0,
  }
}

export const AppProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [phase, setPhase] = useState<AppPhase>('auth')
  const [user, setUser] = useState<User | null>(null)
  const [player, setPlayer] = useState<PlayerData>(DEFAULT_PLAYER)
  const [isLoadingAuth, setIsLoadingAuth] = useState(true)
  const [authError, setAuthError] = useState<string | null>(null)
  const [showLevelUp, setShowLevelUp] = useState(false)
  const [showPenalty, setShowPenalty] = useState(false)
  const [penaltyMissedQuest, setPenaltyMissedQuest] = useState('10KM RUN')
  const [levelUpData, setLevelUpData] = useState({ oldLevel: 1, newLevel: 2, newPoints: 5 })

  const refreshPlayer = useCallback(async (): Promise<PlayerData | null> => {
    try {
      const char = await services.character.getCharacter()
      const updated = mapCharacterToPlayer(char, user)
      setPlayer(updated)
      return updated
    } catch {
      return null
    }
  }, [user])

  // Initialize session on mount
  useEffect(() => {
    async function initSession() {
      setIsLoadingAuth(true)
      try {
        if (apiClient.isAuthenticated()) {
          const char = await services.character.getCharacter()
          const updated = mapCharacterToPlayer(char, user)
          setPlayer(updated)
          setPhase('main')
        } else {
          setPhase('auth')
        }
      } catch {
        apiClient.clearSession()
        setPhase('auth')
      } finally {
        setIsLoadingAuth(false)
      }
    }
    initSession()
  }, [])

  apiClient.setOnAuthFailure(() => {
    setUser(null)
    setPhase('auth')
  })

  const handleLogin = async (email: string, pass: string): Promise<boolean> => {
    setAuthError(null)
    try {
      const res = await services.auth.login({ email, password: pass })
      setUser(res.user)
      if (res.character) {
        setPlayer(mapCharacterToPlayer(res.character, res.user))
      } else {
        await refreshPlayer()
      }
      setPhase('main')
      return true
    } catch (err: unknown) {
      const msg = err instanceof Error ? err.message : 'Authentication failed'
      setAuthError(msg)
      return false
    }
  }

  const handleSignup = async (email: string, pass: string, name?: string): Promise<boolean> => {
    setAuthError(null)
    try {
      const res = await services.auth.signup({
        email,
        password: pass,
        difficultyMode: 'casual',
        chronotype: 'early_bird',
      })
      setUser(res.user)
      if (res.character) {
        const p = mapCharacterToPlayer(res.character, res.user)
        if (name) p.name = name.toUpperCase()
        setPlayer(p)
      }
      setPhase('onboarding')
      return true
    } catch (err: unknown) {
      const msg = err instanceof Error ? err.message : 'Registration failed'
      setAuthError(msg)
      return false
    }
  }

  const handleLogout = async () => {
    try {
      await services.auth.logout()
    } catch {
      apiClient.clearSession()
    } finally {
      setUser(null)
      setPlayer(DEFAULT_PLAYER)
      setPhase('auth')
    }
  }

  const handleQuestCompleted = async (result: CompleteQuestResult) => {
    const prevLevel = player.level
    const updated = await refreshPlayer()
    if (updated && updated.level > prevLevel) {
      setLevelUpData({
        oldLevel: prevLevel,
        newLevel: updated.level,
        newPoints: (updated.level - prevLevel) * 5,
      })
      setShowLevelUp(true)
    }
  }

  return (
    <AppContext.Provider
      value={{
        phase,
        setPhase,
        user,
        player,
        isLoadingAuth,
        authError,
        refreshPlayer,
        handleLogin,
        handleSignup,
        handleLogout,
        handleQuestCompleted,
        showLevelUp,
        setShowLevelUp,
        showPenalty,
        setShowPenalty,
        levelUpData,
        penaltyMissedQuest,
        setPenaltyMissedQuest,
      }}
    >
      {children}
    </AppContext.Provider>
  )
}

export function useApp() {
  const context = useContext(AppContext)
  if (!context) {
    throw new Error('useApp must be used within an AppProvider')
  }
  return context
}

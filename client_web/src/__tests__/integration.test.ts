import { describe, it, expect, beforeAll } from 'vitest'
import { ApiClient } from '../api/client'
import { createServices } from '../api/services'
import { mapCharacterToPlayer, DEFAULT_PLAYER } from '../context/AppContext'
import type { CharacterResponse } from '../api/types'

describe('ARISE Frontend Integration & Contract Test Suite', () => {
  const baseUrl = 'http://localhost:3000/api/v1'
  let client: ApiClient
  let services: ReturnType<typeof createServices>

  const testEmail = `hunter_test_${Date.now()}@arise.system`
  const testPassword = 'Password123!'
  let authToken: string
  let testQuestId: string

  beforeAll(() => {
    const testIp = `10.42.${Math.floor(Math.random() * 200) + 1}.${Math.floor(Math.random() * 200) + 1}`
    client = new ApiClient({
      baseUrl,
      defaultHeaders: { 'x-forwarded-for': testIp },
    })
    services = createServices(client)
  })

  describe('1. ApiClient & Networking Core', () => {
    it('initializes with custom base URL and unauthenticated state', () => {
      expect(client.getBaseUrl()).toBe(baseUrl)
      expect(client.isAuthenticated()).toBe(false)
      expect(client.getToken()).toBeNull()
    })

    it('manages auth tokens and session state', () => {
      client.setSession('sample-token', 'sample-refresh')
      expect(client.isAuthenticated()).toBe(true)
      expect(client.getToken()).toBe('sample-token')
      client.clearSession()
      expect(client.isAuthenticated()).toBe(false)
      expect(client.getToken()).toBeNull()
    })

    it('reaches health endpoint without authentication', async () => {
      const res = await fetch('http://localhost:3000/health')
      expect(res.status).toBe(200)
      const data = await res.json()
      expect(data.status).toBe('ok')
    })
  })

  describe('2. Authentication & Session Integration', () => {
    it('registers a new Hunter account via services.auth.signup', async () => {
      const res = await services.auth.signup({
        email: testEmail,
        password: testPassword,
        difficultyMode: 'casual',
        chronotype: 'early_bird',
      })

      expect(res).toBeDefined()
      expect(res.user).toBeDefined()
      expect(res.user.email).toBe(testEmail)
      expect(res.tokens.accessToken).toBeDefined()
      expect(client.isAuthenticated()).toBe(true)
      authToken = res.tokens.accessToken
    })

    it('rejects duplicate registration with 409 conflict error', async () => {
      await expect(
        services.auth.signup({
          email: testEmail,
          password: testPassword,
        })
      ).rejects.toThrow()
    })

    it('authenticates Hunter via services.auth.login', async () => {
      client.clearSession()
      expect(client.isAuthenticated()).toBe(false)

      const res = await services.auth.login({
        email: testEmail,
        password: testPassword,
      })

      expect(res.tokens.accessToken).toBeDefined()
      expect(res.user.email).toBe(testEmail)
      expect(client.isAuthenticated()).toBe(true)
    })

    it('rejects invalid password with 401 Unauthorized', async () => {
      const unauthClient = new ApiClient({
        baseUrl,
        defaultHeaders: { 'x-forwarded-for': '10.99.1.1' },
      })
      const unauthServices = createServices(unauthClient)
      await expect(
        unauthServices.auth.login({
          email: testEmail,
          password: 'WrongPassword!',
        })
      ).rejects.toThrow()
    })
  })

  describe('3. Character & Authoritative RPG State', () => {
    it('retrieves Hunter character details', async () => {
      const char = await services.character.getCharacter()
      expect(char).toBeDefined()
      expect(char.level).toBeGreaterThanOrEqual(1)
      expect(char.rank).toBeDefined()
      expect(char.totalXp).toBeDefined()
    })

    it('maps backend CharacterResponse to UI PlayerData model accurately', () => {
      const mockChar: CharacterResponse = {
        id: 'char-123',
        userId: 'user-123',
        level: 5,
        totalXp: 1250,
        xpToNextLevel: 250,
        currentMana: 80,
        maxMana: 100,
        coins: 450,
        gems: 10,
        rank: 'D',
        activeTitleId: 'SHADOW SLAYER',
        stats: {
          fitness: 20,
          creativity: 15,
          health: 18,
          intelligence: 22,
          discipline: 16,
          coding: 10,
          business: 10,
        },
      }

      const player = mapCharacterToPlayer(mockChar, { id: 'u1', email: 'sung.jinwoo@arise.system', difficultyMode: 'casual' })
      expect(player.name).toBe('SUNG.JINWOO')
      expect(player.title).toBe('SHADOW SLAYER')
      expect(player.level).toBe(5)
      expect(player.rank).toBe('D')
      expect(player.gold).toBe(450)
      expect(player.mp).toBe(80)
      expect(player.maxMp).toBe(100)
      expect(player.exp).toBe(1250)
      expect(player.str).toBe(20)
      expect(player.agi).toBe(15)
      expect(player.vit).toBe(18)
      expect(player.int).toBe(22)
      expect(player.per).toBe(16)
    })
  })

  describe('4. Quest Management Lifecycle & Idempotency', () => {
    it('creates a new quest via services.quests.createQuest', async () => {
      const quest = await services.quests.createQuest({
        title: 'Complete 100 Push-ups & System Integration',
        description: 'Verify end-to-end quest flow from React UI to NestJS backend',
        questType: 'daily',
        priority: 'high',
        difficulty: 'hard',
      })

      expect(quest).toBeDefined()
      expect(quest.id).toBeDefined()
      testQuestId = quest.id
      expect(quest.title).toBe('Complete 100 Push-ups & System Integration')
      expect(['pending', 'active']).toContain(quest.status)
    })

    it('lists quests including the created quest', async () => {
      const list = await services.quests.listQuests()
      expect(Array.isArray(list)).toBe(true)
      const found = list.find(q => q.id === testQuestId)
      expect(found).toBeDefined()
      expect(found?.title).toBe('Complete 100 Push-ups & System Integration')
    })

    it('completes the quest and receives authoritative XP reward', async () => {
      const charBefore = await services.character.getCharacter()
      const result = await services.quests.completeQuest(testQuestId)

      expect(result).toBeDefined()
      expect(result.quest.status).toBe('completed')
      expect(result.xpAwarded).toBeGreaterThan(0)

      const charAfter = await services.character.getCharacter()
      expect(charAfter.totalXp).toBeGreaterThanOrEqual(charBefore.totalXp + result.xpAwarded)
    })

    it('prevents duplicate completion and rejects with already completed error', async () => {
      await expect(services.quests.completeQuest(testQuestId)).rejects.toThrow(
        /already been completed/
      )
    })
  })

  describe('5. Focus Gate Sessions', () => {
    it('exercises gate session lifecycle, pause, and server-authoritative validation', async () => {
      const session = await services.gates.startSession({
        plannedDurationSeconds: 1500,
        questId: null,
      })

      expect(session).toBeDefined()
      expect(session.id).toBeDefined()
      expect(['active', 'in_progress']).toContain(session.status)

      // Pause session
      const paused = await services.gates.pauseSession(session.id)
      expect(paused.status).toBe('paused')

      // Resume session
      const resumed = await services.gates.resumeSession(session.id)
      expect(resumed.status).toBe('active')

      // Attempting to complete before duration has elapsed must be rejected by backend
      await expect(services.gates.completeSession(session.id)).rejects.toThrow()

      // Early exit collapses session cleanly
      const collapsed = await services.gates.collapseSession(session.id, { exitReason: 'manual_exit' })
      expect(collapsed).toBeDefined()
    })
  })

  describe('6. Bosses, Settings & Reminders', () => {
    it('lists available bosses', async () => {
      const bosses = await services.bosses.listBosses()
      expect(Array.isArray(bosses)).toBe(true)
    })

    it('retrieves and updates user settings', async () => {
      const settings = await services.settings.getSettings()
      expect(settings).toBeDefined()

      const updated = await services.settings.updateSettings({
        soundEnabled: false,
      })
      expect(updated.soundEnabled).toBe(false)

      // Restore
      await services.settings.updateSettings({ soundEnabled: true })
    })

    it('sets difficulty mode', async () => {
      const res = await services.settings.setDifficultyMode('hardcore')
      expect(res.difficultyMode).toBe('hardcore')
      await services.settings.setDifficultyMode('casual')
    })

    it('lists system reminders', async () => {
      const reminders = await services.reminders.list()
      expect(Array.isArray(reminders)).toBe(true)
    })

    it('exports hunter data', async () => {
      const exported = await services.settings.exportData()
      expect(exported).toBeDefined()
    })
  })
})

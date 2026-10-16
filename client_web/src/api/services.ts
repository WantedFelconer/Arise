import { apiClient, ApiClient } from './client'
import type {
  AuthResponse,
  CharacterResponse,
  CharacterStats,
  Quest,
  CreateQuestInput,
  UpdateQuestInput,
  CompleteQuestResult,
  Boss,
  BossDamageHistory,
  Dungeon,
  GateSession,
  GateStats,
  AiQuotaStatus,
  AiPlanProposal,
  Achievement,
  Reminder,
  NotificationItem,
  UserSettings,
  Note,
  NoteFolder,
  LifetimeStats,
  ScreenTimeInsights,
} from './types'

export function createServices(client: ApiClient = apiClient) {
  return {
    auth: {
      async signup(dto: {
        email: string
        password: string
        difficultyMode?: string
        chronotype?: string
      }): Promise<AuthResponse> {
        const res = await client.post<AuthResponse>('auth/signup', dto, { requiresAuth: false })
        if (res.tokens) {
          client.setTokens(res.tokens)
        }
        return res
      },

      async login(dto: { email: string; password: string }): Promise<AuthResponse> {
        const res = await client.post<AuthResponse>('auth/login', dto, { requiresAuth: false })
        if (res.tokens) {
          client.setTokens(res.tokens)
        }
        return res
      },

      async refresh(refreshToken: string): Promise<AuthResponse> {
        const res = await client.post<AuthResponse>('auth/refresh', { refreshToken }, { requiresAuth: false })
        if (res.tokens) {
          client.setTokens(res.tokens)
        }
        return res
      },

      async logout(refreshToken?: string): Promise<{ success: boolean }> {
        try {
          return await client.post<{ success: boolean }>('auth/logout', { refreshToken })
        } finally {
          client.clearSession()
        }
      },

      async requestPasswordReset(email: string): Promise<{ success: boolean; message: string }> {
        return client.post('auth/password-reset/request', { email }, { requiresAuth: false })
      },

      async deleteAccount(): Promise<{ success: boolean }> {
        const res = await client.delete<{ success: boolean }>('auth/account')
        client.clearSession()
        return res
      },
    },

    character: {
      getCharacter(): Promise<CharacterResponse> {
        return client.get<CharacterResponse>('character')
      },

      getStats(): Promise<CharacterStats> {
        return client.get<CharacterStats>('character/stats')
      },

      getHistory(): Promise<Array<{ id: string; amount: number; sourceType: string; reason?: string; createdAt: string }>> {
        return client.get('character/history')
      },

      getAggregates(): Promise<{ today: number; thisWeek: number; thisMonth: number; lifetime: number }> {
        return client.get('character/aggregates')
      },

      equipTitle(titleId: string): Promise<CharacterResponse> {
        return client.patch<CharacterResponse>('character/title', { titleId })
      },
    },

    quests: {
      listQuests(params?: {
        status?: string
        priority?: string
        difficulty?: string
        tag?: string
        bossId?: string
        search?: string
        sortBy?: string
        sortOrder?: string
      }): Promise<Quest[]> {
        const query = new URLSearchParams()
        if (params) {
          for (const [key, value] of Object.entries(params)) {
            if (value !== undefined && value !== '') {
              query.append(key, String(value))
            }
          }
        }
        const qs = query.toString()
        return client.get<Quest[]>(`quests${qs ? `?${qs}` : ''}`)
      },

      getQuest(id: string): Promise<Quest> {
        return client.get<Quest>(`quests/${id}`)
      },

      createQuest(input: CreateQuestInput, idempotencyKey?: string): Promise<Quest> {
        const payload = {
          ...input,
          questType: input.questType ? input.questType.toLowerCase() : undefined,
          priority: input.priority ? input.priority.toLowerCase() : undefined,
          difficulty: input.difficulty ? input.difficulty.toLowerCase() : undefined,
        }
        return client.post<Quest>('quests', payload, { idempotencyKey })
      },

      updateQuest(id: string, input: UpdateQuestInput): Promise<Quest> {
        const payload = {
          ...input,
          questType: input.questType ? input.questType.toLowerCase() : undefined,
          priority: input.priority ? input.priority.toLowerCase() : undefined,
          difficulty: input.difficulty ? input.difficulty.toLowerCase() : undefined,
        }
        return client.patch<Quest>(`quests/${id}`, payload)
      },

      completeQuest(id: string, idempotencyKey?: string): Promise<CompleteQuestResult> {
        return client.post<CompleteQuestResult>(`quests/${id}/complete`, undefined, { idempotencyKey })
      },

      startQuest(id: string): Promise<Quest> {
        return client.post<Quest>(`quests/${id}/start`)
      },

      pauseQuest(id: string): Promise<Quest> {
        return client.post<Quest>(`quests/${id}/pause`)
      },

      archiveQuest(id: string): Promise<Quest> {
        return client.post<Quest>(`quests/${id}/archive`)
      },

      restoreQuest(id: string): Promise<Quest> {
        return client.post<Quest>(`quests/${id}/restore`)
      },

      undoQuest(id: string): Promise<Quest> {
        return client.post<Quest>(`quests/${id}/undo`)
      },

      failQuest(id: string): Promise<Quest> {
        return client.post<Quest>(`quests/${id}/fail`)
      },

      deleteQuest(id: string): Promise<{ success: boolean }> {
        return client.delete<{ success: boolean }>(`quests/${id}`)
      },
    },

    bosses: {
      listBosses(params?: { status?: string; dungeonId?: string }): Promise<Boss[]> {
        const query = new URLSearchParams()
        if (params?.status) query.append('status', params.status)
        if (params?.dungeonId) query.append('dungeonId', params.dungeonId)
        const qs = query.toString()
        return client.get<Boss[]>(`bosses${qs ? `?${qs}` : ''}`)
      },

      getBoss(id: string): Promise<Boss> {
        return client.get<Boss>(`bosses/${id}`)
      },

      getBossHistory(): Promise<BossDamageHistory[]> {
        return client.get<BossDamageHistory[]>('bosses/history')
      },

      createBoss(input: {
        title: string
        totalHp: number
        rank?: string
        deadline?: string
        dungeonId?: string
      }): Promise<Boss> {
        return client.post<Boss>('bosses', input)
      },

      abandonBoss(id: string): Promise<Boss> {
        return client.post<Boss>(`bosses/${id}/abandon`)
      },

      reactivateBoss(id: string): Promise<Boss> {
        return client.post<Boss>(`bosses/${id}/reactivate`)
      },
    },

    dungeons: {
      listDungeons(): Promise<Dungeon[]> {
        return client.get<Dungeon[]>('dungeons')
      },

      getDungeon(id: string): Promise<Dungeon> {
        return client.get<Dungeon>(`dungeons/${id}`)
      },
    },

    gates: {
      startSession(
        input: { plannedDurationSeconds: number; questId?: string | null },
        idempotencyKey?: string
      ): Promise<GateSession> {
        return client.post<GateSession>('gates/sessions', input, { idempotencyKey })
      },

      getSession(id: string): Promise<GateSession> {
        return client.get<GateSession>(`gates/sessions/${id}`)
      },

      pauseSession(id: string): Promise<GateSession> {
        return client.post<GateSession>(`gates/sessions/${id}/pause`)
      },

      resumeSession(id: string): Promise<GateSession> {
        return client.post<GateSession>(`gates/sessions/${id}/resume`)
      },

      completeSession(
        id: string,
        idempotencyKey?: string
      ): Promise<{ session: GateSession; reward: { xpAwarded: number; manaAwarded: number } }> {
        return client.post(`gates/sessions/${id}/complete`, undefined, { idempotencyKey })
      },

      collapseSession(
        id: string,
        input: { exitReason?: string },
        idempotencyKey?: string
      ): Promise<{ session: GateSession; penalty: { xpDeducted: number; manaDeducted: number } }> {
        return client.post(`gates/sessions/${id}/collapse`, input, { idempotencyKey })
      },

      getStats(): Promise<GateStats> {
        return client.get<GateStats>('gates/stats')
      },
    },

    ai: {
      chat(message: string, conversationId?: string): Promise<{ response: string; conversationId?: string }> {
        return client.post('ai/coach/chat', { message, conversationId })
      },

      generatePlan(input: {
        goal: string
        timeframe?: string
        availableHoursPerDay?: number
        focusAreas?: string[]
      }): Promise<AiPlanProposal> {
        return client.post<AiPlanProposal>('ai/plan', input)
      },

      getPlan(id: string): Promise<AiPlanProposal> {
        return client.get<AiPlanProposal>(`ai/plan/${id}`)
      },

      approvePlan(id: string, feedback?: string): Promise<{ plan: AiPlanProposal; questsCreated: Quest[] }> {
        return client.post(`ai/plan/${id}/approve`, { feedback })
      },

      rejectPlan(id: string): Promise<AiPlanProposal> {
        return client.post(`ai/plan/${id}/reject`)
      },

      getQuota(): Promise<AiQuotaStatus> {
        return client.get<AiQuotaStatus>('ai/quota')
      },
    },

    achievements: {
      listAchievements(): Promise<Achievement[]> {
        return client.get<Achievement[]>('achievements')
      },

      listUnlocked(): Promise<Array<{ achievementId: string; unlockedAt: string; achievement: Achievement }>> {
        return client.get('achievements/unlocked')
      },
    },

    notifications: {
      list(filter?: { status?: string; category?: string; limit?: number; offset?: number }): Promise<{
        notifications: NotificationItem[]
        total: number
        unreadCount: number
      }> {
        const query = new URLSearchParams()
        if (filter?.status) query.append('status', filter.status)
        if (filter?.category) query.append('category', filter.category)
        if (filter?.limit) query.append('limit', String(filter.limit))
        if (filter?.offset) query.append('offset', String(filter.offset))
        const qs = query.toString()
        return client.get(`notifications${qs ? `?${qs}` : ''}`)
      },

      getUnreadCount(): Promise<{ count: number }> {
        return client.get('notifications/unread-count')
      },

      markAsRead(id: string): Promise<NotificationItem> {
        return client.patch(`notifications/${id}/read`)
      },

      markAllAsRead(): Promise<{ success: boolean }> {
        return client.post('notifications/read-all')
      },

      delete(id: string): Promise<void> {
        return client.delete(`notifications/${id}`)
      },
    },

    reminders: {
      list(activeOnly?: boolean): Promise<Reminder[]> {
        const qs = activeOnly ? '?activeOnly=true' : ''
        return client.get<Reminder[]>(`reminders${qs}`)
      },

      create(dto: {
        title: string
        scheduleTime: string
        reminderType: string
        repeatInterval?: string | null
      }): Promise<Reminder> {
        return client.post<Reminder>('reminders', dto)
      },

      update(id: string, dto: Partial<{ title: string; scheduleTime: string; isActive: boolean }>): Promise<Reminder> {
        return client.patch<Reminder>(`reminders/${id}`, dto)
      },

      snooze(id: string, snoozeMinutes: number): Promise<Reminder> {
        return client.post<Reminder>(`reminders/${id}/snooze`, { snoozeMinutes })
      },

      delete(id: string): Promise<void> {
        return client.delete(`reminders/${id}`)
      },
    },

    settings: {
      getSettings(): Promise<UserSettings> {
        return client.get<UserSettings>('settings')
      },

      updateSettings(dto: Partial<UserSettings>): Promise<UserSettings> {
        return client.patch<UserSettings>('settings', dto)
      },

      getDifficultyMode(): Promise<{ difficultyMode: 'casual' | 'hardcore' }> {
        return client.get('settings/difficulty-mode')
      },

      setDifficultyMode(difficultyMode: 'casual' | 'hardcore'): Promise<{ difficultyMode: string }> {
        return client.put('settings/difficulty-mode', { difficultyMode })
      },

      exportData(): Promise<unknown> {
        return client.get('settings/export')
      },
    },

    screenTime: {
      getInsights(): Promise<ScreenTimeInsights> {
        return client.get<ScreenTimeInsights>('screen-time/insights')
      },

      getCategories(): Promise<Array<{ appPackage: string; category: string; dailyLimitMinutes?: number }>> {
        return client.get('screen-time/categories')
      },

      ingestSessions(sessions: Array<{ appPackage: string; category?: string; durationS: number }>): Promise<unknown> {
        return client.post('screen-time/sessions', { sessions })
      },
    },

    notes: {
      listNotes(filter?: { folderId?: string; tag?: string; search?: string }): Promise<Note[]> {
        const query = new URLSearchParams()
        if (filter?.folderId) query.append('folderId', filter.folderId)
        if (filter?.tag) query.append('tag', filter.tag)
        if (filter?.search) query.append('search', filter.search)
        const qs = query.toString()
        return client.get<Note[]>(`notes${qs ? `?${qs}` : ''}`)
      },

      getNote(id: string): Promise<Note> {
        return client.get<Note>(`notes/${id}`)
      },

      createNote(dto: {
        title: string
        content: string
        folderId?: string | null
        tags?: string[]
      }): Promise<Note> {
        return client.post<Note>('notes', dto)
      },

      updateNote(
        id: string,
        dto: { title?: string; content?: string; tags?: string[]; isPinned?: boolean; isArchived?: boolean }
      ): Promise<Note> {
        return client.patch<Note>(`notes/${id}`, dto)
      },

      deleteNote(id: string): Promise<void> {
        return client.delete(`notes/${id}`)
      },

      listFolders(): Promise<NoteFolder[]> {
        return client.get<NoteFolder[]>('notes/folders')
      },

      createFolder(dto: { name: string; color?: string }): Promise<NoteFolder> {
        return client.post<NoteFolder>('notes/folders', dto)
      },
    },

    analytics: {
      getDaily(date?: string): Promise<unknown> {
        const qs = date ? `?date=${encodeURIComponent(date)}` : ''
        return client.get(`analytics/daily${qs}`)
      },

      getWeekly(startDate?: string): Promise<unknown> {
        const qs = startDate ? `?startDate=${encodeURIComponent(startDate)}` : ''
        return client.get(`analytics/weekly${qs}`)
      },

      getMonthly(year?: string, month?: string): Promise<unknown> {
        const query = new URLSearchParams()
        if (year) query.append('year', year)
        if (month) query.append('month', month)
        const qs = query.toString()
        return client.get(`analytics/monthly${qs ? `?${qs}` : ''}`)
      },

      getLifetimeStats(): Promise<LifetimeStats> {
        return client.get<LifetimeStats>('stats')
      },
    },
  }
}

export const services = createServices(apiClient)

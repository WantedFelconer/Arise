// AI Provider Abstraction Interface (Section 3.9 & 11.1)

export interface PlanningContext {
  userId: string;
  goal: string;
  deadline?: string;
  availableHoursPerDay?: number;
  currentProficiency?: string;
  difficultyMode?: 'casual' | 'hardcore';
}

export interface AIPlanDraftItem {
  id: string;
  title: string;
  description?: string;
  estimatedMinutes: number;
  priority: number;
  difficulty: number;
  questType: 'main' | 'side' | 'daily' | 'boss';
  parentTempId?: string; // For nested subquests
  dependsOnTempIds?: string[]; // For prerequisite links
}

export interface AIPlanDraft {
  jobId: string;
  goal: string;
  items: AIPlanDraftItem[];
  status: 'pending_approval' | 'approved' | 'rejected';
  createdAt: string;
}

export interface ParsedQuestDraft {
  title: string;
  estimatedMinutes: number;
  priority: number;
  difficulty: number;
  deadline?: string;
  tags?: string[];
}

export interface TriageSuggestion {
  inboxItemId: string;
  suggestedDestination: 'quest' | 'note' | 'boss_subtask' | 'calendar_item';
  title: string;
  description?: string;
  estimatedMinutes?: number;
  suggestedDate?: string;
}

export interface AIProvider {
  generatePlan(context: PlanningContext): Promise<AIPlanDraft>;
  triageInboxItem(inboxItemId: string, rawContent: string): Promise<TriageSuggestion>;
  parseNaturalLanguageQuest(text: string): Promise<ParsedQuestDraft>;
  summarizeReflection(context: { period: string; logs: any[] }): Promise<string>;
}

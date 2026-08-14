export interface AiMessageResponse {
  id: string;
  conversationId: string;
  role: 'user' | 'assistant' | 'system' | 'tool';
  content: string;
  toolCalls?: Array<{ id: string; name: string; arguments: Record<string, unknown> }>;
  toolCallId?: string;
  createdAt: string;
}

export interface AiConversationResponse {
  id: string;
  userId: string;
  title: string;
  contextType: string;
  messages?: AiMessageResponse[];
  createdAt: string;
  updatedAt: string;
}

export interface ChatResponse {
  conversationId: string;
  message: AiMessageResponse;
  toolExecutions?: Array<{
    toolName: string;
    arguments: Record<string, unknown>;
    result: string;
  }>;
}

export interface NudgeItem {
  id: string;
  type: 'overload' | 'procrastination' | 'energy_alignment' | 'boss_momentum';
  title: string;
  message: string;
  actionableSuggestion: string;
  relatedQuestId?: string;
  relatedBossId?: string;
}

import { Injectable } from '@nestjs/common';
import { AIProvider, ToolDefinition, ToolCall } from './ai-provider.interface';

@Injectable()
export class MockAIProvider implements AIProvider {
  readonly name = 'mock';

  private structuredResponsesQueue: unknown[] = [];
  private chatResponsesQueue: Array<{ content: string; toolCalls?: ToolCall[] }> = [];
  public lastSystemPrompt?: string;
  public lastUserPrompt?: string;
  public lastConversation?: Array<{
    role: 'user' | 'assistant' | 'system' | 'tool';
    content: string;
  }>;
  public lastTools?: ToolDefinition[];
  public generateCallCount = 0;
  public chatCallCount = 0;

  /**
   * Queue a response for generateStructured.
   */
  queueStructuredResponse(response: unknown): void {
    this.structuredResponsesQueue.push(response);
  }

  /**
   * Queue a response for chat.
   */
  queueChatResponse(response: { content: string; toolCalls?: ToolCall[] }): void {
    this.chatResponsesQueue.push(response);
  }

  /**
   * Clear all queues and history.
   */
  reset(): void {
    this.structuredResponsesQueue = [];
    this.chatResponsesQueue = [];
    this.lastSystemPrompt = undefined;
    this.lastUserPrompt = undefined;
    this.lastConversation = undefined;
    this.lastTools = undefined;
    this.generateCallCount = 0;
    this.chatCallCount = 0;
  }

  async generateStructured<T>(params: {
    systemPrompt: string;
    userPrompt: string;
    jsonSchema: object;
    maxTokens?: number;
  }): Promise<T> {
    this.generateCallCount++;
    this.lastSystemPrompt = params.systemPrompt;
    this.lastUserPrompt = params.userPrompt;

    if (this.structuredResponsesQueue.length > 0) {
      const response = this.structuredResponsesQueue.shift();
      if (typeof response === 'function') {
        return (response as () => T)();
      }
      if (response instanceof Error) {
        throw response;
      }
      return response as T;
    }

    // Default mock response conforming to §10.3 AI Quest Plan schema
    const defaultPlan = {
      mainQuest: {
        title: 'Master TypeScript & Clean Architecture',
        description: 'Complete comprehensive study plan with hands-on practice',
        difficulty: 'medium',
        deadline: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000).toISOString(),
        xpReward: 150,
        subquests: [
          {
            title: 'Read Clean Architecture chapters 1-4',
            description: 'Study dependency inversion and modular boundaries',
            estimatedMinutes: 60,
            priority: 'high',
            difficulty: 'medium',
            xpReward: 50,
          },
          {
            title: 'Implement repository pattern test suite',
            description: 'Write unit tests validating storage abstraction',
            estimatedMinutes: 90,
            priority: 'medium',
            difficulty: 'hard',
            xpReward: 75,
            dependsOnIndex: 0,
          },
          {
            title: 'Refactor controllers to use DTOs and validation pipes',
            description: 'Ensure boundary inputs are strictly validated',
            estimatedMinutes: 45,
            priority: 'low',
            difficulty: 'easy',
            xpReward: 25,
            dependsOnIndex: 1,
          },
        ],
      },
      suggestedSchedule: [
        {
          date: new Date().toISOString().split('T')[0],
          questIndex: 0,
          notes: 'Focus on core principles first',
        },
        {
          date: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString().split('T')[0],
          questIndex: 1,
          notes: 'Implement test fixtures during high energy window',
        },
      ],
    };

    return defaultPlan as unknown as T;
  }

  async chat(params: {
    conversation: { role: 'user' | 'assistant' | 'system' | 'tool'; content: string }[];
    tools?: ToolDefinition[];
  }): Promise<{ content: string; toolCalls?: ToolCall[] }> {
    this.chatCallCount++;
    this.lastConversation = params.conversation;
    this.lastTools = params.tools;

    if (this.chatResponsesQueue.length > 0) {
      const response = this.chatResponsesQueue.shift()!;
      if (typeof response === 'function') {
        return (response as () => { content: string; toolCalls?: ToolCall[] })();
      }
      if (response instanceof Error) {
        throw response;
      }
      return response;
    }

    const lastMessage = params.conversation[params.conversation.length - 1];

    // If the conversation just received tool results, formulate the final answer
    if (lastMessage && lastMessage.role === 'tool') {
      return {
        content: `Based on your recent productivity data: ${lastMessage.content}. Keep up the great work on your active quests!`,
      };
    }

    // If user message mentions quests or progress and tools are available, simulate tool calling
    if (
      params.tools &&
      params.tools.length > 0 &&
      lastMessage &&
      (lastMessage.content.toLowerCase().includes('quest') ||
        lastMessage.content.toLowerCase().includes('recent') ||
        lastMessage.content.toLowerCase().includes('progress'))
    ) {
      return {
        content: '',
        toolCalls: [
          {
            id: 'call_mock_recent_quests',
            name: 'get_recent_quests',
            arguments: { status: 'active', limit: 5 },
          },
        ],
      };
    }

    return {
      content:
        'Hello! I am your ARISE AI Coach. I am here to assist your daily planning, review productivity habits, and help manage your RPG progression safely.',
    };
  }
}

export interface ToolDefinition {
  name: string;
  description: string;
  parameters: Record<string, unknown>;
}

export interface ToolCall {
  id: string;
  name: string;
  arguments: Record<string, unknown>;
}

export interface AIProvider {
  name?: string;

  generateStructured<T>(params: {
    systemPrompt: string;
    userPrompt: string;
    jsonSchema: object;
    maxTokens?: number;
  }): Promise<T>;

  chat(params: {
    conversation: { role: 'user' | 'assistant' | 'system' | 'tool'; content: string }[];
    tools?: ToolDefinition[];
  }): Promise<{ content: string; toolCalls?: ToolCall[] }>;
}

export const AI_PROVIDER_TOKEN = 'AI_PROVIDER_TOKEN';

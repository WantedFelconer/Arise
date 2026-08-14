import { Injectable, ServiceUnavailableException } from '@nestjs/common';
import { AIProvider, ToolDefinition, ToolCall } from './ai-provider.interface';

@Injectable()
export class OpenAIAdapter implements AIProvider {
  readonly name = 'openai';
  private readonly apiKey: string;
  private readonly modelName: string;

  constructor(apiKey?: string, modelName?: string) {
    this.apiKey = apiKey || process.env.OPENAI_API_KEY || '';
    this.modelName = modelName || process.env.AI_MODEL || 'gpt-4o-mini';
  }

  async generateStructured<T>(params: {
    systemPrompt: string;
    userPrompt: string;
    jsonSchema: object;
    maxTokens?: number;
  }): Promise<T> {
    if (!this.apiKey) {
      throw new ServiceUnavailableException('OPENAI_API_KEY is not configured on the server');
    }

    const endpoint = 'https://api.openai.com/v1/chat/completions';

    const body = {
      model: this.modelName,
      messages: [
        { role: 'system', content: params.systemPrompt },
        { role: 'user', content: params.userPrompt },
      ],
      response_format: {
        type: 'json_schema',
        json_schema: {
          name: 'structured_plan',
          schema: params.jsonSchema,
          strict: false,
        },
      },
      max_tokens: params.maxTokens || 4096,
    };

    try {
      const res = await fetch(endpoint, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${this.apiKey}`,
        },
        body: JSON.stringify(body),
      });

      if (!res.ok) {
        const errorText = await res.text();
        throw new ServiceUnavailableException(`OpenAI API error (${res.status}): ${errorText}`);
      }

      const json = (await res.json()) as {
        choices?: Array<{
          message?: {
            content?: string;
          };
        }>;
      };

      const content = json.choices?.[0]?.message?.content;
      if (!content) {
        throw new ServiceUnavailableException('OpenAI returned an empty response');
      }

      return JSON.parse(content) as T;
    } catch (err: unknown) {
      if (err instanceof ServiceUnavailableException) {
        throw err;
      }
      throw new ServiceUnavailableException(
        `Failed to reach OpenAI provider: ${err instanceof Error ? err.message : String(err)}`,
      );
    }
  }

  async chat(params: {
    conversation: { role: 'user' | 'assistant' | 'system' | 'tool'; content: string }[];
    tools?: ToolDefinition[];
  }): Promise<{ content: string; toolCalls?: ToolCall[] }> {
    if (!this.apiKey) {
      throw new ServiceUnavailableException('OPENAI_API_KEY is not configured on the server');
    }

    const endpoint = 'https://api.openai.com/v1/chat/completions';

    const messages = params.conversation.map((msg) => ({
      role: msg.role,
      content: msg.content,
    }));

    const body: Record<string, unknown> = {
      model: this.modelName,
      messages,
    };

    if (params.tools && params.tools.length > 0) {
      body.tools = params.tools.map((t) => ({
        type: 'function',
        function: {
          name: t.name,
          description: t.description,
          parameters: t.parameters,
        },
      }));
    }

    try {
      const res = await fetch(endpoint, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${this.apiKey}`,
        },
        body: JSON.stringify(body),
      });

      if (!res.ok) {
        const errorText = await res.text();
        throw new ServiceUnavailableException(`OpenAI API error (${res.status}): ${errorText}`);
      }

      const json = (await res.json()) as {
        choices?: Array<{
          message?: {
            content?: string | null;
            tool_calls?: Array<{
              id: string;
              type: string;
              function: {
                name: string;
                arguments: string;
              };
            }>;
          };
        }>;
      };

      const message = json.choices?.[0]?.message;
      if (!message) {
        return { content: '' };
      }

      const toolCalls: ToolCall[] = [];
      if (message.tool_calls) {
        for (const tc of message.tool_calls) {
          let parsedArgs = {};
          try {
            parsedArgs = JSON.parse(tc.function.arguments);
          } catch {
            parsedArgs = {};
          }
          toolCalls.push({
            id: tc.id,
            name: tc.function.name,
            arguments: parsedArgs,
          });
        }
      }

      return {
        content: message.content || '',
        toolCalls: toolCalls.length > 0 ? toolCalls : undefined,
      };
    } catch (err: unknown) {
      if (err instanceof ServiceUnavailableException) {
        throw err;
      }
      throw new ServiceUnavailableException(
        `Failed to reach OpenAI provider: ${err instanceof Error ? err.message : String(err)}`,
      );
    }
  }
}

import { Injectable, ServiceUnavailableException } from '@nestjs/common';
import { AIProvider, ToolDefinition, ToolCall } from './ai-provider.interface';

@Injectable()
export class ClaudeAdapter implements AIProvider {
  readonly name = 'claude';
  private readonly apiKey: string;
  private readonly modelName: string;

  constructor(apiKey?: string, modelName?: string) {
    this.apiKey = apiKey || process.env.ANTHROPIC_API_KEY || '';
    this.modelName = modelName || process.env.AI_MODEL || 'claude-3-5-sonnet-20241022';
  }

  async generateStructured<T>(params: {
    systemPrompt: string;
    userPrompt: string;
    jsonSchema: object;
    maxTokens?: number;
  }): Promise<T> {
    if (!this.apiKey) {
      throw new ServiceUnavailableException('ANTHROPIC_API_KEY is not configured on the server');
    }

    const endpoint = 'https://api.anthropic.com/v1/messages';

    const systemInstruction = `${params.systemPrompt}\n\nYou MUST respond strictly in valid JSON matching the following schema. Do NOT include markdown code blocks, backticks, or prose outside the JSON object.\nJSON Schema:\n${JSON.stringify(params.jsonSchema)}`;

    const body = {
      model: this.modelName,
      max_tokens: params.maxTokens || 4096,
      system: systemInstruction,
      messages: [{ role: 'user', content: params.userPrompt }],
    };

    try {
      const res = await fetch(endpoint, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': this.apiKey,
          'anthropic-version': '2023-06-01',
        },
        body: JSON.stringify(body),
      });

      if (!res.ok) {
        const errorText = await res.text();
        throw new ServiceUnavailableException(`Claude API error (${res.status}): ${errorText}`);
      }

      const json = (await res.json()) as {
        content?: Array<{
          type: string;
          text?: string;
        }>;
      };

      const textBlock = json.content?.find((c) => c.type === 'text');
      if (!textBlock || !textBlock.text) {
        throw new ServiceUnavailableException('Claude returned an empty response');
      }

      // Clean any potential markdown wrapper
      let cleaned = textBlock.text.trim();
      if (cleaned.startsWith('```json')) {
        cleaned = cleaned.substring(7);
      } else if (cleaned.startsWith('```')) {
        cleaned = cleaned.substring(3);
      }
      if (cleaned.endsWith('```')) {
        cleaned = cleaned.substring(0, cleaned.length - 3);
      }
      cleaned = cleaned.trim();

      return JSON.parse(cleaned) as T;
    } catch (err: unknown) {
      if (err instanceof ServiceUnavailableException) {
        throw err;
      }
      throw new ServiceUnavailableException(
        `Failed to reach Claude provider: ${err instanceof Error ? err.message : String(err)}`,
      );
    }
  }

  async chat(params: {
    conversation: { role: 'user' | 'assistant' | 'system' | 'tool'; content: string }[];
    tools?: ToolDefinition[];
  }): Promise<{ content: string; toolCalls?: ToolCall[] }> {
    if (!this.apiKey) {
      throw new ServiceUnavailableException('ANTHROPIC_API_KEY is not configured on the server');
    }

    const endpoint = 'https://api.anthropic.com/v1/messages';

    const systemMessages = params.conversation.filter((m) => m.role === 'system');
    const systemPrompt = systemMessages.map((m) => m.content).join('\n\n');

    const nonSystemMessages = params.conversation.filter((m) => m.role !== 'system');
    const messages = nonSystemMessages.map((msg) => {
      if (msg.role === 'tool') {
        return {
          role: 'user',
          content: [
            {
              type: 'tool_result',
              tool_use_id: 'tool_call',
              content: msg.content,
            },
          ],
        };
      }
      return {
        role: msg.role === 'assistant' ? 'assistant' : 'user',
        content: msg.content,
      };
    });

    const body: Record<string, unknown> = {
      model: this.modelName,
      max_tokens: 4096,
      messages,
    };

    if (systemPrompt) {
      body.system = systemPrompt;
    }

    if (params.tools && params.tools.length > 0) {
      body.tools = params.tools.map((t) => ({
        name: t.name,
        description: t.description,
        input_schema: t.parameters,
      }));
    }

    try {
      const res = await fetch(endpoint, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': this.apiKey,
          'anthropic-version': '2023-06-01',
        },
        body: JSON.stringify(body),
      });

      if (!res.ok) {
        const errorText = await res.text();
        throw new ServiceUnavailableException(`Claude API error (${res.status}): ${errorText}`);
      }

      const json = (await res.json()) as {
        content?: Array<{
          type: string;
          text?: string;
          id?: string;
          name?: string;
          input?: Record<string, unknown>;
        }>;
      };

      let content = '';
      const toolCalls: ToolCall[] = [];

      if (json.content) {
        for (const block of json.content) {
          if (block.type === 'text' && block.text) {
            content += block.text;
          }
          if (block.type === 'tool_use' && block.name) {
            toolCalls.push({
              id: block.id || `claude_call_${Date.now()}_${toolCalls.length}`,
              name: block.name,
              arguments: block.input || {},
            });
          }
        }
      }

      return {
        content,
        toolCalls: toolCalls.length > 0 ? toolCalls : undefined,
      };
    } catch (err: unknown) {
      if (err instanceof ServiceUnavailableException) {
        throw err;
      }
      throw new ServiceUnavailableException(
        `Failed to reach Claude provider: ${err instanceof Error ? err.message : String(err)}`,
      );
    }
  }
}

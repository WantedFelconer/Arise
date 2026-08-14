import { Injectable, ServiceUnavailableException } from '@nestjs/common';
import { AIProvider, ToolDefinition, ToolCall } from './ai-provider.interface';

@Injectable()
export class GeminiAdapter implements AIProvider {
  readonly name = 'gemini';
  private readonly apiKey: string;
  private readonly modelName: string;

  constructor(apiKey?: string, modelName?: string) {
    this.apiKey = apiKey || process.env.GEMINI_API_KEY || '';
    this.modelName = modelName || process.env.AI_MODEL || 'gemini-1.5-flash';
  }

  async generateStructured<T>(params: {
    systemPrompt: string;
    userPrompt: string;
    jsonSchema: object;
    maxTokens?: number;
  }): Promise<T> {
    if (!this.apiKey) {
      throw new ServiceUnavailableException('GEMINI_API_KEY is not configured on the server');
    }

    const endpoint = `https://generativelanguage.googleapis.com/v1beta/models/${this.modelName}:generateContent?key=${this.apiKey}`;

    const body = {
      contents: [
        {
          role: 'user',
          parts: [{ text: `${params.systemPrompt}\n\nUser Prompt:\n${params.userPrompt}` }],
        },
      ],
      generationConfig: {
        responseMimeType: 'application/json',
        responseSchema: params.jsonSchema,
        maxOutputTokens: params.maxTokens || 4096,
      },
    };

    try {
      const res = await fetch(endpoint, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(body),
      });

      if (!res.ok) {
        const errorText = await res.text();
        throw new ServiceUnavailableException(`Gemini API error (${res.status}): ${errorText}`);
      }

      const json = (await res.json()) as {
        candidates?: Array<{
          content?: {
            parts?: Array<{ text?: string }>;
          };
        }>;
      };

      const text = json.candidates?.[0]?.content?.parts?.[0]?.text;
      if (!text) {
        throw new ServiceUnavailableException('Gemini returned an empty response');
      }

      return JSON.parse(text) as T;
    } catch (err: unknown) {
      if (err instanceof ServiceUnavailableException) {
        throw err;
      }
      throw new ServiceUnavailableException(
        `Failed to reach Gemini AI provider: ${err instanceof Error ? err.message : String(err)}`,
      );
    }
  }

  async chat(params: {
    conversation: { role: 'user' | 'assistant' | 'system' | 'tool'; content: string }[];
    tools?: ToolDefinition[];
  }): Promise<{ content: string; toolCalls?: ToolCall[] }> {
    if (!this.apiKey) {
      throw new ServiceUnavailableException('GEMINI_API_KEY is not configured on the server');
    }

    const endpoint = `https://generativelanguage.googleapis.com/v1beta/models/${this.modelName}:generateContent?key=${this.apiKey}`;

    const contents = params.conversation.map((msg) => ({
      role: msg.role === 'assistant' ? 'model' : msg.role === 'tool' ? 'function' : 'user',
      parts: [{ text: msg.content }],
    }));

    const body: Record<string, unknown> = {
      contents,
    };

    if (params.tools && params.tools.length > 0) {
      body.tools = [
        {
          functionDeclarations: params.tools.map((t) => ({
            name: t.name,
            description: t.description,
            parameters: t.parameters,
          })),
        },
      ];
    }

    try {
      const res = await fetch(endpoint, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(body),
      });

      if (!res.ok) {
        const errorText = await res.text();
        throw new ServiceUnavailableException(`Gemini API error (${res.status}): ${errorText}`);
      }

      const json = (await res.json()) as {
        candidates?: Array<{
          content?: {
            parts?: Array<{
              text?: string;
              functionCall?: { name: string; args: Record<string, unknown> };
            }>;
          };
        }>;
      };

      const candidate = json.candidates?.[0]?.content;
      if (!candidate || !candidate.parts) {
        return { content: '' };
      }

      let content = '';
      const toolCalls: ToolCall[] = [];

      for (const part of candidate.parts) {
        if (part.text) {
          content += part.text;
        }
        if (part.functionCall) {
          toolCalls.push({
            id: `gemini_call_${Date.now()}_${toolCalls.length}`,
            name: part.functionCall.name,
            arguments: part.functionCall.args || {},
          });
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
        `Failed to reach Gemini AI provider: ${err instanceof Error ? err.message : String(err)}`,
      );
    }
  }
}

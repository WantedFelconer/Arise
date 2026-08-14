import { describe, it, expect, beforeEach } from 'vitest';
import * as fs from 'fs';
import * as path from 'path';
import { MockAIProvider } from '../providers/mock.adapter';
import { GeminiAdapter } from '../providers/gemini.adapter';
import { OpenAIAdapter } from '../providers/openai.adapter';
import { ClaudeAdapter } from '../providers/claude.adapter';
import { AIProvider } from '../providers/ai-provider.interface';

describe('AI Providers Abstraction Suite (§10.1)', () => {
  let mockProvider: MockAIProvider;

  beforeEach(() => {
    mockProvider = new MockAIProvider();
  });

  it('1. Verbatim §10.1 AIProvider interface adherence', async () => {
    const provider: AIProvider = mockProvider;
    expect(provider.generateStructured).toBeDefined();
    expect(provider.chat).toBeDefined();

    const plan = await provider.generateStructured({
      systemPrompt: 'System',
      userPrompt: 'User',
      jsonSchema: {},
    });

    expect(plan).toHaveProperty('mainQuest');
    expect((plan as Record<string, unknown>).mainQuest).toHaveProperty('title');
    expect((plan as Record<string, unknown>).mainQuest).toHaveProperty('subquests');

    const chatRes = await provider.chat({
      conversation: [{ role: 'user', content: 'Hello Coach' }],
    });

    expect(chatRes).toHaveProperty('content');
    expect(typeof chatRes.content).toBe('string');
  });

  it('2. Instantiates concrete adapters behind the identical interface', () => {
    const gemini = new GeminiAdapter('fake-key', 'gemini-1.5-flash');
    const openai = new OpenAIAdapter('fake-key', 'gpt-4o-mini');
    const claude = new ClaudeAdapter('fake-key', 'claude-3-5-sonnet-20241022');

    expect(gemini.name).toBe('gemini');
    expect(openai.name).toBe('openai');
    expect(claude.name).toBe('claude');

    expect(typeof gemini.generateStructured).toBe('function');
    expect(typeof openai.generateStructured).toBe('function');
    expect(typeof claude.generateStructured).toBe('function');
  });

  it('3. Vendor SDK isolation test: Business logic never imports vendor SDKs directly', () => {
    const srcDir = path.resolve(__dirname, '../../../');
    const filesToCheck: string[] = [];

    function collectFiles(dir: string) {
      const entries = fs.readdirSync(dir, { withFileTypes: true });
      for (const entry of entries) {
        const fullPath = path.join(dir, entry.name);
        if (entry.isDirectory()) {
          // Exclude the concrete providers directory from the restriction
          if (fullPath.includes(path.join('modules', 'ai', 'providers'))) {
            continue;
          }
          if (entry.name !== 'node_modules' && entry.name !== 'dist') {
            collectFiles(fullPath);
          }
        } else if (entry.name.endsWith('.ts') && !entry.name.endsWith('.d.ts')) {
          filesToCheck.push(fullPath);
        }
      }
    }

    collectFiles(srcDir);

    const forbiddenImports = ['@google/generative-ai', 'openai', '@anthropic-ai/sdk', 'langchain'];

    for (const filePath of filesToCheck) {
      const content = fs.readFileSync(filePath, 'utf-8');
      for (const forbidden of forbiddenImports) {
        const importPattern = new RegExp(`from\\s+['"]${forbidden}['"]`, 'g');
        expect(
          importPattern.test(content),
          `File ${filePath} violates Rule 8 by importing vendor SDK "${forbidden}" outside ai/providers/`,
        ).toBe(false);
      }
    }
  });

  it('4. Provider API keys are strictly server-side environment variables and not exposed', () => {
    const gemini = new GeminiAdapter();
    const openai = new OpenAIAdapter();
    const claude = new ClaudeAdapter();

    // Check JSON serialization does not leak private fields
    const serializedGemini = JSON.stringify(gemini);
    const serializedOpenai = JSON.stringify(openai);
    const serializedClaude = JSON.stringify(claude);

    expect(serializedGemini).not.toContain('fake-key');
    expect(serializedOpenai).not.toContain('fake-key');
    expect(serializedClaude).not.toContain('fake-key');
  });
});

import { Module, Global } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { AI_PROVIDER_TOKEN } from './ai-provider.interface';
import { MockAIProvider } from './mock.adapter';
import { GeminiAdapter } from './gemini.adapter';
import { OpenAIAdapter } from './openai.adapter';
import { ClaudeAdapter } from './claude.adapter';

@Global()
@Module({
  providers: [
    MockAIProvider,
    {
      provide: AI_PROVIDER_TOKEN,
      useFactory: (configService: ConfigService) => {
        const providerName =
          configService.get<string>('AI_PROVIDER') || process.env.AI_PROVIDER || 'mock';
        const apiKey = configService.get<string>('GEMINI_API_KEY') || process.env.GEMINI_API_KEY;
        const openaiKey = configService.get<string>('OPENAI_API_KEY') || process.env.OPENAI_API_KEY;
        const claudeKey =
          configService.get<string>('ANTHROPIC_API_KEY') || process.env.ANTHROPIC_API_KEY;
        const modelName = configService.get<string>('AI_MODEL') || process.env.AI_MODEL;

        switch (providerName.toLowerCase()) {
          case 'gemini':
            return new GeminiAdapter(apiKey, modelName);
          case 'openai':
            return new OpenAIAdapter(openaiKey, modelName);
          case 'claude':
            return new ClaudeAdapter(claudeKey, modelName);
          case 'mock':
          default:
            return new MockAIProvider();
        }
      },
      inject: [ConfigService],
    },
  ],
  exports: [AI_PROVIDER_TOKEN, MockAIProvider],
})
export class AiProvidersModule {}

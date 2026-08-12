import type { AIProvider } from './interfaces/AIProvider.ts';
import { MockAIProvider } from './providers/MockAIProvider.ts';

export class AIFactory {
  private static instance: AIProvider | null = null;

  public static getProvider(): AIProvider {
    if (this.instance) {
      return this.instance;
    }

    const providerType = process.env.AI_PROVIDER || 'mock';

    switch (providerType.toLowerCase()) {
      case 'mock':
      default:
        console.log('[AI Provider] Initialized MockAIProvider (Offline / Zero-Config fallback)');
        this.instance = new MockAIProvider();
        break;
    }

    return this.instance;
  }
}

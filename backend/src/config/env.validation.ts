import { z } from 'zod';

export const envSchema = z.object({
  NODE_ENV: z.enum(['development', 'production', 'test']).default('development'),
  PORT: z.coerce.number().default(3000),
  DATABASE_URL: z
    .string()
    .default('postgresql://postgres:postgres@localhost:5432/arise?schema=public'),
  REDIS_URL: z.string().default('redis://localhost:6379'),
  JWT_PRIVATE_KEY: z.string().optional(),
  JWT_PUBLIC_KEY: z.string().optional(),
  JWT_ACCESS_EXPIRATION: z.string().default('15m'),
  JWT_REFRESH_EXPIRATION: z.string().default('30d'),
  CORS_ORIGIN: z.string().default('http://localhost:8443,http://localhost:3000'),
  RATE_LIMIT_TTL: z.coerce.number().default(900), // 15 minutes in seconds
  RATE_LIMIT_LIMIT: z.coerce.number().default(10), // 10 attempts
  AI_PROVIDER: z.enum(['mock', 'gemini', 'openai', 'claude']).default('mock'),
  AI_DAILY_QUOTA: z.coerce.number().default(50),
  GEMINI_API_KEY: z.string().optional(),
  OPENAI_API_KEY: z.string().optional(),
  ANTHROPIC_API_KEY: z.string().optional(),
  AI_MODEL: z.string().optional(),
});

export type EnvConfig = z.infer<typeof envSchema>;

export function validateEnv(config: Record<string, unknown>): EnvConfig {
  const result = envSchema.safeParse(config);
  if (!result.success) {
    throw new Error(`Environment validation error: ${JSON.stringify(result.error.format())}`);
  }
  return result.data;
}

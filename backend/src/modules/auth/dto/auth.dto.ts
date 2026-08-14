import { z } from 'zod';
import {
  signupSchema,
  loginSchema,
  refreshSchema,
  logoutSchema,
  passwordResetRequestSchema,
  passwordResetConfirmSchema,
  registerDeviceSchema,
} from '../validation/auth.schema';
import { CharacterStats } from '../../../core/rpg-engine';

export type SignupDto = z.infer<typeof signupSchema>;
export type LoginDto = z.infer<typeof loginSchema>;
export type RefreshDto = z.infer<typeof refreshSchema>;
export type LogoutDto = z.infer<typeof logoutSchema>;
export type PasswordResetRequestDto = z.infer<typeof passwordResetRequestSchema>;
export type PasswordResetConfirmDto = z.infer<typeof passwordResetConfirmSchema>;
export type RegisterDeviceDto = z.infer<typeof registerDeviceSchema>;

export interface AuthTokens {
  accessToken: string;
  refreshToken: string;
}

export interface AuthResponse {
  user: {
    id: string;
    email: string;
    difficultyMode: string;
  };
  character?: {
    id: string;
    level: number;
    totalXp: number;
    currentMana: number;
    maxMana: number;
    rank: string;
    stats: CharacterStats;
  };
  tokens: AuthTokens;
}

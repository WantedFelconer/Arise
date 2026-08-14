# Auth Module (`modules/auth`)

## 1. Purpose & Responsibilities
Provides complete, security-hardened authentication and identity management for ARISE:
- User registration (`POST /api/v1/auth/signup`) with **Argon2id** password hashing.
- Auto-provisioning of `Character`, `Settings`, and `CircadianProfile` on registration (FR-AUTH-007, FR-AUTH-008).
- User login (`POST /api/v1/auth/login`) issuing short-lived RS256 JWT access tokens (15 min) and single-use rotating refresh tokens (30 days).
- Single-use token refresh (`POST /api/v1/auth/refresh`) with strict **reuse detection** that automatically revokes all sessions for the user upon reuse attempt (AC-AUTH-004).
- User logout (`POST /api/v1/auth/logout`) and account soft-deletion (`DELETE /api/v1/auth/account`).
- Rate limiting protection (10 attempts / 15 mins) via `RateLimitGuard`.

## 2. Public API
- `AuthService.signup(dto: SignupDto): Promise<AuthResponse>`
- `AuthService.login(dto: LoginDto): Promise<AuthResponse>`
- `AuthService.refresh(dto: RefreshDto): Promise<AuthTokens>`
- `AuthService.logout(userId: string, dto: LogoutDto): Promise<{ message: string }>`
- `AuthService.deleteAccount(userId: string): Promise<{ message: string }>`

## 3. Dependencies
- `@nestjs/common`, `@nestjs/core`, `@nestjs/config`
- `argon2` (argon2id type)
- `jsonwebtoken` (RS256 algorithm)
- `PrismaService` (`db/prisma/prisma.service.ts`)
- `JwtTokenService` (`core/auth/jwt-token.service.ts`)

## 4. Database Tables
- `users`
- `refresh_tokens`
- `characters` (auto-created on signup)
- `settings` (auto-created on signup)
- `circadian_profiles` (auto-created on signup)
- `devices` (scaffolded)

## 5. Domain Events Emitted / Consumed
- Emits: `UserRegistered`, `UserLoggedIn`, `UserLoggedOut`, `UserSessionRevoked`

## 6. Extension Points & Future Work
- OAuth 2.0 / OpenID Connect (Google Sign-In, Apple Sign-In) providers in Sprint 4.
- Email verification service provider integration in Sprint 4.
- Multi-device active session listing and remote push revocation (FR-AUTH-010).

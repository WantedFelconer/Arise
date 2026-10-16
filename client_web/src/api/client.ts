import type { AuthTokens } from './types'

export class ApiError extends Error {
  code: string
  statusCode: number
  details?: unknown

  constructor(message: string, statusCode: number, code: string = 'API_ERROR', details?: unknown) {
    super(message)
    this.name = 'ApiError'
    this.statusCode = statusCode
    this.code = code
    this.details = details
  }
}

const STORAGE_KEY_TOKENS = 'arise_auth_tokens'

export class ApiClient {
  private baseUrl: string
  private tokens: AuthTokens | null = null
  private defaultHeaders: Record<string, string> = {}
  private refreshPromise: Promise<string | null> | null = null
  private onAuthFailureCallback?: () => void

  constructor(config?: string | { baseUrl?: string; defaultHeaders?: Record<string, string> }) {
    if (typeof config === 'string') {
      this.baseUrl = config
    } else if (config?.baseUrl) {
      this.baseUrl = config.baseUrl
      if (config.defaultHeaders) this.defaultHeaders = config.defaultHeaders
    } else {
      this.baseUrl = (import.meta.env?.VITE_API_BASE_URL as string) || 'http://localhost:3000/api/v1'
    }
    this.loadTokens()
  }

  public setBaseUrl(url: string) {
    this.baseUrl = url
  }

  public getBaseUrl(): string {
    return this.baseUrl
  }

  public setSession(accessToken: string, refreshToken?: string) {
    this.setTokens({ accessToken, refreshToken: refreshToken || '' })
  }

  public getToken(): string | null {
    return this.getAccessToken()
  }

  public setOnAuthFailure(callback: () => void) {
    this.onAuthFailureCallback = callback
  }

  private loadTokens() {
    try {
      const stored = sessionStorage.getItem(STORAGE_KEY_TOKENS)
      if (stored) {
        this.tokens = JSON.parse(stored)
      }
    } catch {
      this.tokens = null
    }
  }

  public setTokens(tokens: AuthTokens | null) {
    this.tokens = tokens
    try {
      if (tokens) {
        sessionStorage.setItem(STORAGE_KEY_TOKENS, JSON.stringify(tokens))
      } else {
        sessionStorage.removeItem(STORAGE_KEY_TOKENS)
      }
    } catch {
      // ignore storage failure in private mode
    }
  }

  public getTokens(): AuthTokens | null {
    return this.tokens
  }

  public getAccessToken(): string | null {
    return this.tokens?.accessToken || null
  }

  public isAuthenticated(): boolean {
    return !!this.tokens?.accessToken
  }

  public clearSession() {
    this.setTokens(null)
  }

  private async refreshAccessToken(): Promise<string | null> {
    if (!this.tokens?.refreshToken) {
      return null
    }

    if (this.refreshPromise) {
      return this.refreshPromise
    }

    this.refreshPromise = (async () => {
      try {
        const response = await fetch(`${this.baseUrl}/auth/refresh`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ refreshToken: this.tokens!.refreshToken }),
        })

        if (!response.ok) {
          this.clearSession()
          this.onAuthFailureCallback?.()
          return null
        }

        const json = await response.json()
        const newTokens = json.data?.tokens || json.data
        if (newTokens?.accessToken) {
          const updated: AuthTokens = {
            accessToken: newTokens.accessToken,
            refreshToken: newTokens.refreshToken || this.tokens!.refreshToken,
          }
          this.setTokens(updated)
          return updated.accessToken
        }
        return null
      } catch {
        this.clearSession()
        return null
      } finally {
        this.refreshPromise = null
      }
    })()

    return this.refreshPromise
  }

  public async request<T>(
    endpoint: string,
    options: RequestInit & { timeoutMs?: number; requiresAuth?: boolean; idempotencyKey?: string } = {}
  ): Promise<T> {
    const {
      timeoutMs = 15000,
      requiresAuth = true,
      idempotencyKey,
      headers: customHeaders = {},
      ...fetchOptions
    } = options

    const cleanEndpoint = endpoint.startsWith('/') ? endpoint : `/${endpoint}`
    const url = `${this.baseUrl}${cleanEndpoint}`

    const controller = new AbortController()
    const timeout = setTimeout(() => controller.abort(), timeoutMs)

    const headers: Record<string, string> = {
      'Content-Type': 'application/json',
      Accept: 'application/json',
      ...this.defaultHeaders,
      ...(customHeaders as Record<string, string>),
    }

    if (idempotencyKey) {
      headers['idempotency-key'] = idempotencyKey
    }

    if (requiresAuth && this.tokens?.accessToken) {
      headers['Authorization'] = `Bearer ${this.tokens.accessToken}`
    }

    let response: Response
    try {
      response = await fetch(url, {
        ...fetchOptions,
        headers,
        signal: controller.signal,
      })
    } catch (err: unknown) {
      clearTimeout(timeout)
      if (err instanceof Error && err.name === 'AbortError') {
        throw new ApiError(`Request timed out after ${timeoutMs}ms`, 408, 'TIMEOUT')
      }
      throw new ApiError(
        err instanceof Error ? err.message : 'Network request failed',
        0,
        'NETWORK_ERROR'
      )
    } finally {
      clearTimeout(timeout)
    }

    // Auto-refresh token on 401 if authorized
    if (response.status === 401 && requiresAuth && this.tokens?.refreshToken) {
      const refreshedToken = await this.refreshAccessToken()
      if (refreshedToken) {
        headers['Authorization'] = `Bearer ${refreshedToken}`
        const retryResponse = await fetch(url, {
          ...fetchOptions,
          headers,
        })
        return this.handleResponse<T>(retryResponse)
      }
    }

    return this.handleResponse<T>(response)
  }

  private async handleResponse<T>(response: Response): Promise<T> {
    const contentType = response.headers.get('content-type')
    const isJson = contentType && contentType.includes('application/json')
    const body = isJson ? await response.json() : await response.text()

    if (!response.ok) {
      const errorPayload = typeof body === 'object' && body !== null && 'error' in body ? (body as { error: { code?: string; message?: string; details?: unknown } }).error : null
      let message = errorPayload?.message
      let code = errorPayload?.code
      const details = errorPayload?.details

      if (details && typeof details === 'object' && 'error' in details) {
        const nested = (details as { error: { code?: string; message?: string } }).error
        if (!message || message === 'Http Exception') message = nested.message || message
        if (!code || code === 'HTTP_EXCEPTION') code = nested.code || code
      }

      if (!message || message === 'Http Exception') {
        message = typeof body === 'string' ? body : response.statusText || 'Request failed'
      }
      if (!code) {
        code = `HTTP_${response.status}`
      }

      if (response.status === 401) {
        this.clearSession()
        this.onAuthFailureCallback?.()
      }

      throw new ApiError(message, response.status, code, details)
    }

    // If backend wraps in { data: ... }, unwrap it; otherwise return body
    if (typeof body === 'object' && body !== null && 'data' in body) {
      return (body as { data: T }).data
    }

    return body as T
  }

  // Convenience methods
  public get<T>(endpoint: string, options?: { timeoutMs?: number; requiresAuth?: boolean; headers?: HeadersInit }) {
    return this.request<T>(endpoint, { method: 'GET', ...options })
  }

  public post<T>(
    endpoint: string,
    body?: unknown,
    options?: { timeoutMs?: number; requiresAuth?: boolean; idempotencyKey?: string; headers?: HeadersInit }
  ) {
    return this.request<T>(endpoint, {
      method: 'POST',
      body: body !== undefined ? JSON.stringify(body) : undefined,
      ...options,
    })
  }

  public patch<T>(
    endpoint: string,
    body?: unknown,
    options?: { timeoutMs?: number; requiresAuth?: boolean; headers?: HeadersInit }
  ) {
    return this.request<T>(endpoint, {
      method: 'PATCH',
      body: body !== undefined ? JSON.stringify(body) : undefined,
      ...options,
    })
  }

  public put<T>(
    endpoint: string,
    body?: unknown,
    options?: { timeoutMs?: number; requiresAuth?: boolean; headers?: HeadersInit }
  ) {
    return this.request<T>(endpoint, {
      method: 'PUT',
      body: body !== undefined ? JSON.stringify(body) : undefined,
      ...options,
    })
  }

  public delete<T>(endpoint: string, options?: { timeoutMs?: number; requiresAuth?: boolean; headers?: HeadersInit }) {
    return this.request<T>(endpoint, { method: 'DELETE', ...options })
  }
}

export const apiClient = new ApiClient()

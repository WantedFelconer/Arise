// Standardized Response Envelope Helper for ARISE REST API (Section 8)

export interface ApiEnvelope<T = any> {
  success: boolean;
  data?: T;
  error?: string;
  meta: {
    correlationId: string;
    serverTimestamp: string;
  };
}

export class Envelope {
  public static success<T>(data: T, correlationId = 'sys_gen'): ApiEnvelope<T> {
    return {
      success: true,
      data,
      meta: {
        correlationId,
        serverTimestamp: new Date().toISOString(),
      },
    };
  }

  public static error(message: string, correlationId = 'sys_gen'): ApiEnvelope<null> {
    return {
      success: false,
      error: message,
      meta: {
        correlationId,
        serverTimestamp: new Date().toISOString(),
      },
    };
  }
}

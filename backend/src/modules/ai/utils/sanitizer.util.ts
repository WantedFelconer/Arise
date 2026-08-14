/**
 * Sanitizes untrusted text strings from user input or AI output to prevent Stored XSS (§10.5, §13.4).
 * Strips script tags, HTML event handlers, javascript: URIs, and dangerous elements.
 */
export function sanitizeText(input?: string | null): string {
  if (!input) return '';

  let sanitized = input;

  // Remove <script>...</script> tags and contents
  sanitized = sanitized.replace(/<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>/gi, '');

  // Remove <style>...</style> tags and contents
  sanitized = sanitized.replace(/<style\b[^<]*(?:(?!<\/style>)<[^<]*)*<\/style>/gi, '');

  // Remove <iframe>, <object>, <embed>, <applet>, <meta>, <link>, <form> tags
  sanitized = sanitized.replace(/<\/?(?:iframe|object|embed|applet|meta|link|form)\b[^>]*>/gi, '');

  // Remove inline event handlers (e.g., onload=, onclick=, onerror=)
  sanitized = sanitized.replace(/\son\w+\s*=\s*(?:'[^']*'|"[^"]*"|[^\s>]+)/gi, '');

  // Remove javascript: and vbscript: URIs
  sanitized = sanitized.replace(/(?:javascript|vbscript):[^\s"'>]*/gi, '');

  // Strip generic HTML tags but preserve clean text
  sanitized = sanitized.replace(/<[^>]*>?/gm, '');

  return sanitized.trim();
}

/**
 * Recursively sanitizes all string fields in an object.
 */
export function sanitizeObject<T>(obj: T): T {
  if (typeof obj === 'string') {
    return sanitizeText(obj) as unknown as T;
  }
  if (Array.isArray(obj)) {
    return obj.map((item) => sanitizeObject(item)) as unknown as T;
  }
  if (obj !== null && typeof obj === 'object') {
    const result: Record<string, unknown> = {};
    for (const [key, value] of Object.entries(obj)) {
      result[key] = sanitizeObject(value);
    }
    return result as T;
  }
  return obj;
}

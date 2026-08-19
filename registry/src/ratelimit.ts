interface RateLimitEntry {
  count: number;
  windowStart: number;
}

type RateLimitTier = 'auth' | 'read' | 'write';

const TIER_LIMITS: Record<RateLimitTier, { max: number; windowMs: number }> = {
  auth: { max: 10, windowMs: 60_000 },
  read: { max: 60, windowMs: 60_000 },
  write: { max: 10, windowMs: 60_000 },
};

const store = new Map<string, RateLimitEntry>();

function getIp(request: Request): string {
  return (
    request.headers.get('CF-Connecting-IP') ||
    request.headers.get('X-Forwarded-For')?.split(',')[0]?.trim() ||
    'unknown'
  );
}

function makeKey(tier: RateLimitTier, ip: string, userId?: number): string {
  return userId !== undefined ? `${tier}:${userId}` : `${tier}:${ip}`;
}

function checkLimit(
  key: string,
  max: number,
  windowMs: number
): { allowed: boolean; retryAfter: number } {
  const now = Date.now();
  const entry = store.get(key);

  if (!entry || now - entry.windowStart > windowMs) {
    store.set(key, { count: 1, windowStart: now });
    return { allowed: true, retryAfter: 0 };
  }

  if (entry.count >= max) {
    const retryAfter = Math.ceil((entry.windowStart + windowMs - now) / 1000);
    return { allowed: false, retryAfter: Math.max(1, retryAfter) };
  }

  entry.count++;
  return { allowed: true, retryAfter: 0 };
}

export interface RateLimitResult {
  allowed: boolean;
  retryAfter: number;
}

export function checkRateLimit(
  tier: RateLimitTier,
  request: Request,
  userId?: number
): RateLimitResult {
  const ip = getIp(request);
  const { max, windowMs } = TIER_LIMITS[tier];
  const key = makeKey(tier, ip, userId);
  return checkLimit(key, max, windowMs);
}

export function rateLimitResponse(retryAfter: number): Response {
  return new Response(
    JSON.stringify({
      error: {
        code: 'RATE_LIMITED',
        message: `Too many requests. Retry after ${retryAfter}s.`,
      },
    }),
    {
      status: 429,
      headers: {
        'Content-Type': 'application/json',
        'Retry-After': String(retryAfter),
        'Access-Control-Allow-Origin': '*',
      },
    }
  );
}

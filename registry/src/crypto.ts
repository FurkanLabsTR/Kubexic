export async function sha256(data: string | ArrayBuffer): Promise<string> {
  const buffer =
    typeof data === 'string' ? new TextEncoder().encode(data) : new Uint8Array(data);
  const hashBuffer = await crypto.subtle.digest('SHA-256', buffer);
  return arrayBufferToHex(hashBuffer);
}

export function generateSalt(): string {
  const bytes = crypto.getRandomValues(new Uint8Array(16));
  return arrayBufferToHex(bytes.buffer);
}

export async function hashPassword(password: string, salt: string): Promise<string> {
  return sha256(salt + password);
}

export async function verifyPassword(
  password: string,
  salt: string,
  storedHash: string
): Promise<boolean> {
  const hash = await hashPassword(password, salt);
  return hash === storedHash;
}

export function generateApiToken(): string {
  const bytes = crypto.getRandomValues(new Uint8Array(32));
  return arrayBufferToHex(bytes.buffer);
}

function arrayBufferToHex(buffer: ArrayBuffer): string {
  return Array.from(new Uint8Array(buffer))
    .map((b) => b.toString(16).padStart(2, '0'))
    .join('');
}

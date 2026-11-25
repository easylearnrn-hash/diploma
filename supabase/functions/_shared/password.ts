// Password helpers shared by the portal-auth and admin-auth Edge Functions.

const enc = new TextEncoder()
const ITERATIONS = 100_000
const KEY_BYTES = 32

function toHex(bytes: Uint8Array): string {
  return Array.from(bytes).map((b) => b.toString(16).padStart(2, '0')).join('')
}

export async function sha256Hex(text: string): Promise<string> {
  return toHex(new Uint8Array(await crypto.subtle.digest('SHA-256', enc.encode(text))))
}

export function sameText(a: string, b: string): boolean {
  if (a.length !== b.length) return false
  let diff = 0
  for (let i = 0; i < a.length; i++) diff |= a.charCodeAt(i) ^ b.charCodeAt(i)
  return diff === 0
}

async function pbkdf2(password: string, salt: Uint8Array<ArrayBuffer>): Promise<string> {
  const key = await crypto.subtle.importKey('raw', enc.encode(password), 'PBKDF2', false, ['deriveBits'])
  const bits = await crypto.subtle.deriveBits({ name: 'PBKDF2', hash: 'SHA-256', salt, iterations: ITERATIONS }, key, KEY_BYTES * 8)
  return toHex(new Uint8Array(bits))
}

// Same format as the hash-password function: "pbkdf2:<salt hex>:<hash hex>"
export async function pbkdf2Hash(password: string): Promise<string> {
  const salt = crypto.getRandomValues(new Uint8Array(16))
  return `pbkdf2:${toHex(salt)}:${await pbkdf2(password, salt)}`
}

// Verifies against a stored teacher password: PBKDF2 string, or the legacy plain text some accounts still have
export async function verifyStoredPassword(password: string, stored: string): Promise<boolean> {
  if (!stored) return false
  if (!stored.startsWith('pbkdf2:')) return sameText(password, stored)
  const parts = stored.split(':')
  if (parts.length !== 3 || !/^[0-9a-f]{32}$/i.test(parts[1])) return false
  const salt = new Uint8Array(parts[1].match(/.{2}/g)!.map((h) => parseInt(h, 16)))
  return sameText(await pbkdf2(password, salt), parts[2])
}

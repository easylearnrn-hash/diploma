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
  if (stored.startsWith('p2:')) return verifySecret(password, stored)
  if (!stored.startsWith('pbkdf2:')) return sameText(password, stored)
  const parts = stored.split(':')
  if (parts.length !== 3 || !/^[0-9a-f]{32}$/i.test(parts[1])) return false
  const salt = new Uint8Array(parts[1].match(/.{2}/g)!.map((h) => parseInt(h, 16)))
  return sameText(await pbkdf2(password, salt), parts[2])
}

/* ───────────── salted, slow storage for the SHA-256 values the pages send ─────────────
   The pages still send sha256(password) as before. What is STORED is "p2:<iterations>:<salt hex>:<PBKDF2-SHA256 hex>" computed over that
   value, so a copy of the database needs a full PBKDF2 run per guess. Old rows (a bare 64-character SHA-256) keep working and are
   converted the first time the owner signs in. */
const SLOW_ITERATIONS = 210_000

export const isSlowHash = (stored: string): boolean => stored.startsWith('p2:')

export async function hashSecret(input: string): Promise<string> {
  const salt = crypto.getRandomValues(new Uint8Array(16))
  return `p2:${SLOW_ITERATIONS}:${toHex(salt)}:${await pbkdf2With(input, salt, SLOW_ITERATIONS)}`
}

async function pbkdf2With(password: string, salt: Uint8Array<ArrayBuffer>, iterations: number): Promise<string> {
  const key = await crypto.subtle.importKey('raw', enc.encode(password), 'PBKDF2', false, ['deriveBits'])
  const bits = await crypto.subtle.deriveBits({ name: 'PBKDF2', hash: 'SHA-256', salt, iterations }, key, KEY_BYTES * 8)
  return toHex(new Uint8Array(bits))
}

export async function verifySecret(input: string, stored: string): Promise<boolean> {
  const parts = stored.split(':')
  if (parts.length !== 4 || parts[0] !== 'p2') return false
  const iterations = Number(parts[1])
  if (!Number.isInteger(iterations) || iterations < 10_000 || iterations > 2_000_000 || !/^[0-9a-f]{32}$/i.test(parts[2])) return false
  const salt = new Uint8Array(parts[2].match(/.{2}/g)!.map((h) => parseInt(h, 16)))
  return sameText(await pbkdf2With(input, salt, iterations), parts[3])
}

// Compares a sha256-hex the page sent against what is stored (slow hash, or the old bare SHA-256).
// `legacy` tells the caller to store a slow hash now that the password is known to be right.
export async function checkPrehashed(givenSha256Hex: string, stored: string): Promise<{ match: boolean; legacy: boolean }> {
  const given = givenSha256Hex.trim().toLowerCase()
  if (isSlowHash(stored)) return { match: await verifySecret(given, stored), legacy: false }
  if (/^[0-9a-f]{64}$/i.test(stored)) return { match: sameText(stored.toLowerCase(), given), legacy: true }
  return { match: false, legacy: false }
}

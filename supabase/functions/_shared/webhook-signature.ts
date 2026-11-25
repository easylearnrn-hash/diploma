// Verifies a Resend (Svix) webhook signature: HMAC-SHA256 over "<svix-id>.<svix-timestamp>.<raw body>" with the base64 secret
// that follows "whsec_" in the Resend dashboard. The timestamp must be within five minutes.

const enc = new TextEncoder()

export async function verifySvixSignature(
  secret: string,
  headers: { id: string | null; timestamp: string | null; signature: string | null },
  rawBody: string,
  nowMs = Date.now(),
): Promise<boolean> {
  try {
    if (!headers.id || !headers.timestamp || !headers.signature) return false
    const ts = Number(headers.timestamp)
    if (!Number.isFinite(ts) || Math.abs(nowMs / 1000 - ts) > 5 * 60) return false
    const raw = secret.startsWith('whsec_') ? secret.slice(6) : secret
    const keyBytes = Uint8Array.from(atob(raw), (c) => c.charCodeAt(0))
    const key = await crypto.subtle.importKey('raw', keyBytes, { name: 'HMAC', hash: 'SHA-256' }, false, ['sign'])
    const mac = new Uint8Array(await crypto.subtle.sign('HMAC', key, enc.encode(`${headers.id}.${headers.timestamp}.${rawBody}`)))
    const expected = btoa(String.fromCharCode(...mac))
    // header looks like "v1,<base64> v1,<base64>" (several signatures while a secret is being rotated)
    return headers.signature.split(' ').some((part) => {
      const [version, sig] = part.split(',')
      if (version !== 'v1' || !sig || sig.length !== expected.length) return false
      let diff = 0
      for (let i = 0; i < sig.length; i++) diff |= sig.charCodeAt(i) ^ expected.charCodeAt(i)
      return diff === 0
    })
  } catch (_e) {
    return false
  }
}

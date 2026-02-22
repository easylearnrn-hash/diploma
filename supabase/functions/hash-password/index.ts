// Supabase Edge Function: hash-password
// Hashes and verifies passwords using PBKDF2-SHA256 (Web Crypto API — no external deps)
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

const ITERATIONS = 100_000;
const KEY_LENGTH = 32; // bytes → 64 hex chars

/** Derive a PBKDF2-SHA256 hash. Returns "pbkdf2:<salt_hex>:<hash_hex>" */
async function pbkdf2Hash(password: string, salt?: Uint8Array): Promise<string> {
  const enc = new TextEncoder();
  const saltBytes = salt ?? crypto.getRandomValues(new Uint8Array(16));
  const keyMaterial = await crypto.subtle.importKey(
    "raw", enc.encode(password), "PBKDF2", false, ["deriveBits"]
  );
  const bits = await crypto.subtle.deriveBits(
    { name: "PBKDF2", hash: "SHA-256", salt: saltBytes, iterations: ITERATIONS },
    keyMaterial,
    KEY_LENGTH * 8
  );
  const hashHex = Array.from(new Uint8Array(bits)).map(b => b.toString(16).padStart(2, '0')).join('');
  const saltHex = Array.from(saltBytes).map(b => b.toString(16).padStart(2, '0')).join('');
  return `pbkdf2:${saltHex}:${hashHex}`;
}

/** Verify a password against a stored hash string (supports legacy plain-text fallback) */
async function pbkdf2Verify(password: string, stored: string): Promise<boolean> {
  if (!stored.startsWith('pbkdf2:')) {
    // Legacy: password was stored as plain text before hashing was deployed
    return password === stored;
  }
  const parts = stored.split(':');
  if (parts.length !== 3) return false;
  const saltBytes = new Uint8Array(parts[1].match(/.{2}/g)!.map(h => parseInt(h, 16)));
  const candidate = await pbkdf2Hash(password, saltBytes);
  return candidate === stored;
}

serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const body = await req.json();
    const { password, action = 'hash' } = body;

    if (!password) {
      return new Response(
        JSON.stringify({ error: 'Password is required' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    if (action === 'hash') {
      const hash = await pbkdf2Hash(password);
      return new Response(
        JSON.stringify({ hash }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );

    } else if (action === 'verify') {
      const { hash } = body;
      if (!hash) {
        return new Response(
          JSON.stringify({ error: 'Hash is required for verification' }),
          { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        );
      }
      const match = await pbkdf2Verify(password, hash);
      return new Response(
        JSON.stringify({ match }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );

    } else {
      return new Response(
        JSON.stringify({ error: 'Invalid action. Use "hash" or "verify"' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

  } catch (err) {
    const message = err instanceof Error ? err.message : String(err);
    console.error('Error:', message);
    return new Response(
      JSON.stringify({ error: message }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    );
  }
});

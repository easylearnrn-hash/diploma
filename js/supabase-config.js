// Supabase Configuration for ACNHS Transcript System
// This file contains the public configuration for client-side Supabase access

const SUPABASE_CONFIG = {
  // Your Supabase project URL
  url: 'https://eyhksbiceueoiamwnqpr.supabase.co',
  
  // Your Supabase anonymous (public) key - safe for client-side use
  anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImV5aGtzYmljZXVlb2lhbXducXByIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njg4NTIwOTAsImV4cCI6MjA4NDQyODA5MH0.1G3RZLKLJvIR8U9Cvmner3kUIxDtUfFYkHpzUUbnbq8',
  
  // Optional: Additional configuration
  options: {
    auth: {
      persistSession: true,
      autoRefreshToken: true,
      detectSessionInUrl: false,
      storage: typeof window !== 'undefined' ? window.localStorage : undefined,
      storageKey: 'acnhs-admin-auth',
      // Prevent Navigator LockManager timeout when multiple admin tabs are open.
      // Instead of blocking for 10s waiting to acquire an exclusive lock, we
      // use a non-exclusive relaxed lock that resolves immediately.
      lock: typeof navigator !== 'undefined' && navigator.locks
        ? async (name, acquireTimeout, fn) => {
            return navigator.locks.request(
              name,
              { mode: 'exclusive', ifAvailable: true },
              async (lock) => {
                // If lock isn't available (another tab holds it), run anyway
                return fn(lock);
              }
            );
          }
        : undefined
    }
  }
};

// Initialize Supabase client
let supabaseClient = null;

function setSupabaseOwnerHeader(ownerId, ownerRole) {
  if (!ownerId) return;
  SUPABASE_CONFIG.options.global = SUPABASE_CONFIG.options.global || {};
  SUPABASE_CONFIG.options.global.headers = SUPABASE_CONFIG.options.global.headers || {};

  const role = (ownerRole || 'student').toLowerCase().trim();

  // Prevent rebuilding the client if both headers are already correctly set
  if (
    SUPABASE_CONFIG.options.global.headers['x-owner-id']   === ownerId &&
    SUPABASE_CONFIG.options.global.headers['x-owner-role'] === role
  ) {
    return;
  }

  SUPABASE_CONFIG.options.global.headers['x-owner-id']   = ownerId;
  SUPABASE_CONFIG.options.global.headers['x-owner-role'] = role;

  // If a client already exists, rebuild so new headers apply immediately.
  if (supabaseClient && typeof window !== 'undefined' && window.supabase) {
    supabaseClient = window.supabase.createClient(
      SUPABASE_CONFIG.url,
      SUPABASE_CONFIG.anonKey,
      SUPABASE_CONFIG.options
    );
  }
}

function initSupabase() {
  if (typeof window.supabase === 'undefined' || !window.supabase) {
    console.error('Supabase library not loaded. Please include the Supabase CDN script.');
    return null;
  }
  
  if (!supabaseClient) {
    supabaseClient = window.supabase.createClient(
      SUPABASE_CONFIG.url,
      SUPABASE_CONFIG.anonKey,
      SUPABASE_CONFIG.options
    );
  }
  
  return supabaseClient;
}

// Export for use in other scripts
if (typeof module !== 'undefined' && module.exports) {
  module.exports = { SUPABASE_CONFIG, initSupabase, setSupabaseOwnerHeader };
}

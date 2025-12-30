// Supabase Configuration for ACNHS Transcript System
// This file contains the public configuration for client-side Supabase access

const SUPABASE_CONFIG = {
  // Your Supabase project URL
  url: 'https://zlvnxvrzotamhpezqedr.supabase.co',
  
  // Your Supabase anonymous (public) key - safe for client-side use
  anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inpsdm54dnJ6b3RhbWhwZXpxZWRyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI4MTEzMTcsImV4cCI6MjA3ODM4NzMxN30.-IoSqKhDrA9NuG4j3GufIbfmodWqCoppEklE1nTmw38',
  
  // Optional: Additional configuration
  options: {
    auth: {
      persistSession: false,
      autoRefreshToken: false
    }
  }
};

// Initialize Supabase client
let supabaseClient = null;

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
  module.exports = { SUPABASE_CONFIG, initSupabase };
}

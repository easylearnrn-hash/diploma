// Transcript Verification Service
// Handles unique code generation and database operations

/**
 * Generate a unique verification code
 * Format: TR-YYYY-STUDENTID-HASH
 * Example: TR-2025-ACNHS001-A7F3
 */
function generateVerificationCode(studentId) {
  const year = new Date().getFullYear();
  const randomHash = Math.random().toString(36).substring(2, 6).toUpperCase();
  return `TR-${year}-${studentId}-${randomHash}`;
}

/**
 * Generate a cryptographically secure random code
 * Uses 8 hex chars (32-bit entropy) to make collisions astronomically unlikely.
 */
function generateSecureVerificationCode(studentId) {
  const year = new Date().getFullYear();
  const array = new Uint8Array(4);
  crypto.getRandomValues(array);
  const hash = Array.from(array, byte => byte.toString(16).padStart(2, '0')).join('').toUpperCase();
  return `TR-${year}-${studentId}-${hash}`;
}

/**
 * Save transcript to database
 * @param {Object} transcriptData - Transcript information
 * @returns {Promise<Object>} - Saved transcript with verification code
 */
async function saveTranscriptToDatabase(transcriptData) {
  const client = initSupabase();
  if (!client) {
    throw new Error('Supabase client not initialized');
  }

  const MAX_RETRIES = 5;

  for (let attempt = 1; attempt <= MAX_RETRIES; attempt++) {
    // Generate a fresh code on every attempt
    const verificationCode = generateSecureVerificationCode(transcriptData.student_id);

    const transcriptRecord = {
      verification_code: verificationCode,
      student_id: transcriptData.student_id,
      student_name: transcriptData.student_name,
      date_of_birth: transcriptData.date_of_birth,
      program: transcriptData.program,
      transcript_type: transcriptData.transcript_type || 'standard',
      status: 'valid',
      cumulative_gpa: transcriptData.cumulative_gpa,
      total_credits: transcriptData.total_credits,
      issue_date: new Date().toISOString().split('T')[0],
      metadata: transcriptData.metadata || {}
    };

    const { data, error } = await client
      .from('transcripts')
      .insert([transcriptRecord])
      .select()
      .single();

    if (!error) return data;

    // Duplicate verification_code — retry with a new code
    if (error.code === '23505' && attempt < MAX_RETRIES) {
      console.warn(`Transcript verification code collision on attempt ${attempt}, retrying...`);
      continue;
    }

    console.error('Error saving transcript:', error);
    throw error;
  }
}

/**
 * Verify a transcript by code
 * @param {string} verificationCode - The code to verify
 * @returns {Promise<Object>} - Transcript data or null if not found
 */
async function verifyTranscriptCode(verificationCode) {
  const client = initSupabase();
  if (!client) {
    throw new Error('Supabase client not initialized');
  }
  
  const { data, error } = await client
    .from('transcripts')
    .select('*')
    .eq('verification_code', verificationCode)
    .single();
  
  if (error) {
    if (error.code === 'PGRST116') {
      // No rows returned - code doesn't exist
      return null;
    }
    console.error('Error verifying transcript:', error);
    throw error;
  }
  
  return data;
}

/**
 * Update transcript status (e.g., revoke)
 * @param {string} verificationCode - The code to update
 * @param {string} newStatus - New status: 'valid', 'invalid', or 'revoked'
 * @returns {Promise<Object>} - Updated transcript
 */
async function updateTranscriptStatus(verificationCode, newStatus) {
  const client = initSupabase();
  if (!client) {
    throw new Error('Supabase client not initialized');
  }
  
  const { data, error } = await client
    .from('transcripts')
    .update({ status: newStatus })
    .eq('verification_code', verificationCode)
    .select()
    .single();
  
  if (error) {
    console.error('Error updating transcript status:', error);
    throw error;
  }
  
  return data;
}

/**
 * Get all transcripts for a student
 * @param {string} studentId - Student ID
 * @returns {Promise<Array>} - Array of transcripts
 */
async function getStudentTranscripts(studentId) {
  const client = initSupabase();
  if (!client) {
    throw new Error('Supabase client not initialized');
  }
  
  const { data, error } = await client
    .from('transcripts')
    .select('*')
    .eq('student_id', studentId)
    .order('created_at', { ascending: false });
  
  if (error) {
    console.error('Error fetching student transcripts:', error);
    throw error;
  }
  
  return data;
}

// Export functions
if (typeof module !== 'undefined' && module.exports) {
  module.exports = {
    generateVerificationCode,
    generateSecureVerificationCode,
    saveTranscriptToDatabase,
    verifyTranscriptCode,
    updateTranscriptStatus,
    getStudentTranscripts
  };
}

/**
 * SMS Service Client for Twilio + Supabase Edge Functions
 * Armenian College of Nursing - DIPLOMA Project
 */

class SMSService {
  constructor(supabaseUrl, supabaseKey) {
    this.supabaseUrl = supabaseUrl;
    this.supabaseKey = supabaseKey;
    this.baseUrl = `${supabaseUrl}/functions/v1`;
  }

  /**
   * Send a general SMS message
   * @param {string} phoneNumber - US phone number in format +1XXXXXXXXXX
   * @param {string} message - Message content (max 1600 characters)
   * @param {string} type - Type of message (admission, notification, verification, reminder)
   * @returns {Promise<Object>} Response with success status and message details
   */
  async sendSMS(phoneNumber, message, type = 'notification') {
    try {
      // Validate phone number format
      if (!this.validateUSPhoneNumber(phoneNumber)) {
        throw new Error('Invalid phone number format. Use +1XXXXXXXXXX');
      }

      const response = await fetch(`${this.baseUrl}/send-sms`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${this.supabaseKey}`,
          'apikey': this.supabaseKey,
        },
        body: JSON.stringify({
          to: phoneNumber,
          message: message,
          type: type,
        }),
      });

      const data = await response.json();

      if (!response.ok) {
        throw new Error(data.error || 'Failed to send SMS');
      }

      return {
        success: true,
        messageSid: data.messageSid,
        status: data.status,
        to: data.to,
      };
    } catch (error) {
      console.error('SMS Service Error:', error);
      return {
        success: false,
        error: error.message,
      };
    }
  }

  /**
   * Send verification code via SMS
   * @param {string} phoneNumber - US phone number in format +1XXXXXXXXXX
   * @param {string} purpose - Purpose of verification (admission, login, password-reset)
   * @returns {Promise<Object>} Response with success status
   */
  async sendVerificationCode(phoneNumber, purpose = 'admission') {
    try {
      if (!this.validateUSPhoneNumber(phoneNumber)) {
        throw new Error('Invalid phone number format. Use +1XXXXXXXXXX');
      }

      const response = await fetch(`${this.baseUrl}/send-verification-sms`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${this.supabaseKey}`,
          'apikey': this.supabaseKey,
        },
        body: JSON.stringify({
          phoneNumber: phoneNumber,
          purpose: purpose,
        }),
      });

      const data = await response.json();

      if (!response.ok) {
        throw new Error(data.error || 'Failed to send verification code');
      }

      return {
        success: true,
        messageSid: data.messageSid,
        expiresAt: data.expiresAt,
      };
    } catch (error) {
      console.error('Verification SMS Error:', error);
      return {
        success: false,
        error: error.message,
      };
    }
  }

  /**
   * Verify SMS code
   * @param {string} phoneNumber - US phone number in format +1XXXXXXXXXX
   * @param {string} code - 6-digit verification code
   * @param {string} purpose - Purpose of verification (admission, login, password-reset)
   * @returns {Promise<Object>} Response with verification status
   */
  async verifyCode(phoneNumber, code, purpose = 'admission') {
    try {
      if (!this.validateUSPhoneNumber(phoneNumber)) {
        throw new Error('Invalid phone number format. Use +1XXXXXXXXXX');
      }

      if (!/^\d{6}$/.test(code)) {
        throw new Error('Invalid code format. Must be 6 digits');
      }

      const response = await fetch(`${this.baseUrl}/verify-sms-code`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${this.supabaseKey}`,
          'apikey': this.supabaseKey,
        },
        body: JSON.stringify({
          phoneNumber: phoneNumber,
          code: code,
          purpose: purpose,
        }),
      });

      const data = await response.json();

      if (!response.ok) {
        throw new Error(data.error || 'Failed to verify code');
      }

      return {
        success: true,
        verified: data.verified,
        phoneNumber: data.phoneNumber,
      };
    } catch (error) {
      console.error('Code Verification Error:', error);
      return {
        success: false,
        error: error.message,
      };
    }
  }

  /**
   * Validate US phone number format
   * @param {string} phoneNumber - Phone number to validate
   * @returns {boolean} True if valid
   */
  validateUSPhoneNumber(phoneNumber) {
    const regex = /^\+1[2-9]\d{9}$/;
    return regex.test(phoneNumber);
  }

  /**
   * Format phone number to US format
   * @param {string} phoneNumber - Phone number (various formats accepted)
   * @returns {string} Formatted phone number +1XXXXXXXXXX
   */
  formatUSPhoneNumber(phoneNumber) {
    // Remove all non-digit characters
    const digits = phoneNumber.replace(/\D/g, '');
    
    // If starts with 1 and has 11 digits, add +
    if (digits.length === 11 && digits[0] === '1') {
      return `+${digits}`;
    }
    
    // If has 10 digits, add +1
    if (digits.length === 10) {
      return `+1${digits}`;
    }
    
    // If already has +1
    if (phoneNumber.startsWith('+1') && digits.length === 11) {
      return phoneNumber;
    }
    
    throw new Error('Invalid phone number. Must be 10 or 11 digits');
  }

  /**
   * Format phone number for display (x xxx xxx xxxx)
   * @param {string} phoneNumber - Phone number in any format
   * @returns {string} Formatted phone number for display
   */
  formatPhoneForDisplay(phoneNumber) {
    if (!phoneNumber) return '—';
    
    // Remove all non-digit characters
    const digits = phoneNumber.replace(/\D/g, '');
    
    // Handle 11 digits (with country code 1)
    if (digits.length === 11 && digits[0] === '1') {
      return `${digits[0]} ${digits.slice(1, 4)} ${digits.slice(4, 7)} ${digits.slice(7)}`;
    }
    
    // Handle 10 digits (without country code)
    if (digits.length === 10) {
      return `1 ${digits.slice(0, 3)} ${digits.slice(3, 6)} ${digits.slice(6)}`;
    }
    
    // Return as-is if format doesn't match
    return phoneNumber;
  }

  /**
   * Send admission notification SMS
   * @param {string} phoneNumber - Student's phone number
   * @param {string} studentName - Student's name
   * @param {string} status - Admission status
   * @returns {Promise<Object>} Response with success status
   */
  async sendAdmissionNotification(phoneNumber, studentName, status) {
    const messages = {
      accepted: `Congratulations ${studentName}! You've been accepted to Armenian College of Nursing. Check your email for next steps.`,
      pending: `Hi ${studentName}, your application to Armenian College of Nursing is under review. We'll notify you soon.`,
      interview: `Hi ${studentName}, you've been selected for an interview at Armenian College of Nursing. Check your email for details.`,
    };

    const message = messages[status] || `Hi ${studentName}, update on your Armenian College of Nursing application. Check your email.`;
    
    return await this.sendSMS(phoneNumber, message, 'admission');
  }

  /**
   * Send class reminder SMS
   * @param {string} phoneNumber - Student's phone number
   * @param {string} className - Class name
   * @param {string} time - Class time
   * @returns {Promise<Object>} Response with success status
   */
  async sendClassReminder(phoneNumber, className, time) {
    const message = `Reminder: Your ${className} class is scheduled for ${time}. Armenian College of Nursing.`;
    return await this.sendSMS(phoneNumber, message, 'reminder');
  }

  /**
   * Send exam reminder SMS
   * @param {string} phoneNumber - Student's phone number
   * @param {string} examName - Exam name
   * @param {string} date - Exam date
   * @returns {Promise<Object>} Response with success status
   */
  async sendExamReminder(phoneNumber, examName, date) {
    const message = `Reminder: ${examName} is scheduled for ${date}. Good luck! - Armenian College of Nursing`;
    return await this.sendSMS(phoneNumber, message, 'reminder');
  }
}

// Export for use in other files
if (typeof module !== 'undefined' && module.exports) {
  module.exports = SMSService;
}

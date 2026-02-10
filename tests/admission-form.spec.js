// @ts-check
const { test, expect } = require('@playwright/test');

test.describe('Admission Form', () => {
  test.beforeEach(async ({ page }) => {
    const response = await page.goto('/admission-form.html', { 
      waitUntil: 'domcontentloaded',
      timeout: 30000 
    });
    expect(response?.status()).toBe(200);
  });

  test('should load the admission form page', async ({ page }) => {
    await expect(page).toHaveTitle(/Admission Form|Armenian College/i);
    
    // Check for main form elements
    await expect(page.locator('form')).toBeVisible();
  });

  test('should display all required sections', async ({ page }) => {
    // Personal Information
    await expect(page.locator('input[name="first_name"], input[id*="first"], input[placeholder*="First"]')).toBeVisible();
    await expect(page.locator('input[name="last_name"], input[id*="last"], input[placeholder*="Last"]')).toBeVisible();
    await expect(page.locator('input[name="email"], input[type="email"]')).toBeVisible();
    
    // Date of Birth
    await expect(page.locator('input[type="date"], input[name*="birth"], input[id*="birth"]')).toBeVisible();
  });

  test('should validate required fields on submit', async ({ page }) => {
    // Try to submit empty form
    const submitButton = page.locator('button[type="submit"], input[type="submit"]');
    await submitButton.click();
    
    // Check for validation messages (HTML5 or custom)
    const firstNameInput = page.locator('input[name="first_name"], input[id*="first"]').first();
    const isInvalid = await firstNameInput.evaluate(el => !/** @type {HTMLInputElement} */(el).checkValidity());
    expect(isInvalid).toBeTruthy();
  });

  test('should accept valid email format', async ({ page }) => {
    const emailInput = page.locator('input[type="email"]').first();
    await emailInput.fill('test@example.com');
    
    const isValid = await emailInput.evaluate(el => /** @type {HTMLInputElement} */(el).checkValidity());
    expect(isValid).toBeTruthy();
  });

  test('should reject invalid email format', async ({ page }) => {
    const emailInput = page.locator('input[type="email"]').first();
    await emailInput.fill('invalid-email');
    
    const isValid = await emailInput.evaluate(el => /** @type {HTMLInputElement} */(el).checkValidity());
    expect(isValid).toBeFalsy();
  });

  test('should allow date selection for date of birth', async ({ page }) => {
    const dateInput = page.locator('input[type="date"]').first();
    await dateInput.fill('2000-01-15');
    
    const value = await dateInput.inputValue();
    expect(value).toBe('2000-01-15');
  });

  test('should have phone number input', async ({ page }) => {
    const phoneInput = page.locator('input[type="tel"], input[name*="phone"], input[placeholder*="phone" i]');
    await expect(phoneInput.first()).toBeVisible();
  });

  test('should be responsive on mobile', async ({ page, isMobile }) => {
    if (isMobile) {
      // Check that form is visible and usable on mobile
      await expect(page.locator('form')).toBeVisible();
      
      // Verify no horizontal scroll
      const hasHorizontalScroll = await page.evaluate(() => {
        return document.documentElement.scrollWidth > document.documentElement.clientWidth;
      });
      expect(hasHorizontalScroll).toBeFalsy();
    }
  });
});

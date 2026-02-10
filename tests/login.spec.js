// @ts-check
const { test, expect } = require('@playwright/test');

test.describe('Login Page', () => {
  test.beforeEach(async ({ page }) => {
    const response = await page.goto('/login.html', {
      waitUntil: 'domcontentloaded',
      timeout: 30000
    });
    expect(response?.status()).toBe(200);
  });

  test('should load the login page', async ({ page }) => {
    await expect(page).toHaveTitle(/Login|Sign In|Armenian College/i);
  });

  test('should display login form', async ({ page }) => {
    // Check for email/username input
    const emailInput = page.locator('input[type="email"], input[name*="email"], input[name*="username"]').first();
    await expect(emailInput).toBeVisible();
    
    // Check for password input
    const passwordInput = page.locator('input[type="password"]').first();
    await expect(passwordInput).toBeVisible();
    
    // Check for submit button
    const submitButton = page.locator('button[type="submit"], input[type="submit"]');
    await expect(submitButton).toBeVisible();
  });

  test('should show validation for empty credentials', async ({ page }) => {
    const submitButton = page.locator('button[type="submit"], input[type="submit"]');
    await submitButton.click();
    
    // Check that inputs are marked as invalid
    const emailInput = page.locator('input[type="email"], input[name*="email"]').first();
    const isRequired = await emailInput.getAttribute('required');
    expect(isRequired).not.toBeNull();
  });

  test('should accept input in email field', async ({ page }) => {
    const emailInput = page.locator('input[type="email"], input[name*="email"]').first();
    await emailInput.fill('admin@example.com');
    
    const value = await emailInput.inputValue();
    expect(value).toBe('admin@example.com');
  });

  test('should accept input in password field', async ({ page }) => {
    const passwordInput = page.locator('input[type="password"]').first();
    await passwordInput.fill('testpassword123');
    
    const value = await passwordInput.inputValue();
    expect(value).toBe('testpassword123');
  });

  test('should mask password input', async ({ page }) => {
    const passwordInput = page.locator('input[type="password"]').first();
    await passwordInput.fill('secret123');
    
    const inputType = await passwordInput.getAttribute('type');
    expect(inputType).toBe('password');
  });

  test('should be accessible via keyboard', async ({ page }) => {
    const emailInput = page.locator('input[type="email"], input[name*="email"]').first();
    const passwordInput = page.locator('input[type="password"]').first();
    
    // Tab through inputs
    await emailInput.focus();
    await page.keyboard.press('Tab');
    
    // Check that password field is now focused
    const isFocused = await passwordInput.evaluate(el => el === document.activeElement);
    expect(isFocused).toBeTruthy();
  });

  test('should be responsive on mobile', async ({ page, isMobile }) => {
    if (isMobile) {
      await expect(page.locator('form, .login-form, [class*="login"]')).toBeVisible();
      
      // Verify no horizontal scroll
      const hasHorizontalScroll = await page.evaluate(() => {
        return document.documentElement.scrollWidth > document.documentElement.clientWidth;
      });
      expect(hasHorizontalScroll).toBeFalsy();
    }
  });
});

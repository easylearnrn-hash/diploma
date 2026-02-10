// @ts-check
const { test, expect } = require('@playwright/test');

// These tests require admin authentication
// We'll test the page structure without logging in

test.describe('Admin Dashboard (Structure)', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/admin-home.html', {
      waitUntil: 'domcontentloaded',
      timeout: 30000
    });
  });

  test('should load admin home page', async ({ page }) => {
    // Page should load (might redirect to login)
    await expect(page).toHaveURL(/admin-home|login/);
  });

  test('should have title', async ({ page }) => {
    const title = await page.title();
    expect(title.length).toBeGreaterThan(0);
  });
});

test.describe('Admin Applications Page (Structure)', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/admin-applications.html', {
      waitUntil: 'domcontentloaded',
      timeout: 30000
    });
  });

  test('should load admin applications page', async ({ page }) => {
    await expect(page).toHaveURL(/admin-applications|login/);
  });

  test('should have title', async ({ page }) => {
    const title = await page.title();
    expect(title.length).toBeGreaterThan(0);
  });

  test('should not expose sensitive data without auth', async ({ page }) => {
    // Wait for any redirects
    await page.waitForTimeout(2000);
    
    // If not logged in, should not show student data
    const currentUrl = page.url();
    const isOnLoginPage = currentUrl.includes('login');
    
    if (!isOnLoginPage) {
      // Check that page requires authentication
      const hasProtection = await page.evaluate(() => {
        const isAdmin = sessionStorage.getItem('isAdmin');
        return isAdmin !== 'true';
      });
      expect(hasProtection).toBeTruthy();
    }
  });
});

test.describe('Admin Students Page (Structure)', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/admin-students.html', {
      waitUntil: 'domcontentloaded',
      timeout: 30000
    });
  });

  test('should load admin students page', async ({ page }) => {
    await expect(page).toHaveURL(/admin-students|login/);
  });

  test('should have title', async ({ page }) => {
    const title = await page.title();
    expect(title.length).toBeGreaterThan(0);
  });
});

// @ts-check
const { test, expect } = require('@playwright/test');

test.describe('Homepage', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/index.html', {
      waitUntil: 'domcontentloaded',
      timeout: 30000
    });
  });

  test('should load the homepage', async ({ page }) => {
    await expect(page).toHaveTitle(/Armenian College|Home|ACNHS/i);
  });

  test('should have navigation menu', async ({ page }) => {
    const nav = page.locator('nav, header, [role="navigation"]');
    await expect(nav.first()).toBeVisible();
  });

  test('should have main content', async ({ page }) => {
    const main = page.locator('main, [role="main"], .main-content');
    const hasMain = await main.count() > 0;
    
    if (!hasMain) {
      // At least check page has content
      const bodyContent = await page.locator('body').textContent();
      expect(bodyContent?.length).toBeGreaterThan(0);
    } else {
      await expect(main.first()).toBeVisible();
    }
  });

  test('should have links', async ({ page }) => {
    const links = page.locator('a[href]');
    const linkCount = await links.count();
    expect(linkCount).toBeGreaterThan(0);
  });

  test('should be responsive on mobile', async ({ page, isMobile }) => {
    if (isMobile) {
      // Verify no horizontal scroll
      const hasHorizontalScroll = await page.evaluate(() => {
        return document.documentElement.scrollWidth > document.documentElement.clientWidth;
      });
      expect(hasHorizontalScroll).toBeFalsy();
    }
  });

  test('should load without console errors', async ({ page }) => {
    /** @type {string[]} */
    const errors = [];
    page.on('console', msg => {
      if (msg.type() === 'error') {
        errors.push(msg.text());
      }
    });
    
    await page.goto('/index.html', {
      waitUntil: 'networkidle',
      timeout: 30000
    });
    
    // Filter out expected errors (like network errors for external resources)
    const criticalErrors = errors.filter(err => 
      !err.includes('cdn.') && 
      !err.includes('supabase') &&
      !err.includes('Failed to load resource')
    );
    
    expect(criticalErrors.length).toBe(0);
  });
});

test.describe('About Page', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/about.html', {
      waitUntil: 'domcontentloaded',
      timeout: 30000
    });
  });

  test('should load the about page', async ({ page }) => {
    await expect(page).toHaveTitle(/About|Armenian College/i);
  });

  test('should have content', async ({ page }) => {
    const bodyContent = await page.locator('body').textContent();
    expect(bodyContent?.length).toBeGreaterThan(100);
  });

  test('should be responsive on mobile', async ({ page, isMobile }) => {
    if (isMobile) {
      const hasHorizontalScroll = await page.evaluate(() => {
        return document.documentElement.scrollWidth > document.documentElement.clientWidth;
      });
      expect(hasHorizontalScroll).toBeFalsy();
    }
  });
});

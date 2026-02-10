// @ts-check
const { test, expect } = require('@playwright/test');

test.describe('Enrollment Questionnaire (Final Form)', () => {
  test.beforeEach(async ({ page }) => {
    const response = await page.goto('/final-form.html', {
      waitUntil: 'domcontentloaded',
      timeout: 30000
    });
    expect(response?.status()).toBe(200);
  });

  test('should load the enrollment questionnaire page', async ({ page }) => {
    await expect(page).toHaveTitle(/Enrollment|Questionnaire|Final Form|Armenian College/i);
  });

  test('should display personal information section', async ({ page }) => {
    await expect(page.locator('form')).toBeVisible();
    
    // Check for basic input fields
    const inputs = page.locator('input[type="text"], input[type="email"], input[type="tel"]');
    await expect(inputs.first()).toBeVisible();
  });

  test('should have residency information section', async ({ page }) => {
    // Look for permanent departure date
    const departureDate = page.locator('input[type="date"]');
    await expect(departureDate.first()).toBeVisible();
  });

  test('should show travel history YES/NO control', async ({ page }) => {
    // Check for the new visited_armenia_after_leaving radio buttons
    const visitedYes = page.locator('input[type="radio"][value="yes"], input[type="radio"][name*="visited"]');
    const visitedNo = page.locator('input[type="radio"][value="no"], input[type="radio"][name*="visited"]');
    
    // At least one should exist
    const yesExists = await visitedYes.count() > 0;
    const noExists = await visitedNo.count() > 0;
    expect(yesExists || noExists).toBeTruthy();
  });

  test('should conditionally show travel history section based on YES/NO', async ({ page }) => {
    // Find the YES radio button for visiting Armenia
    const visitedYes = page.locator('input[type="radio"][value="yes"]').first();
    const visitedNo = page.locator('input[type="radio"][value="no"]').first();
    
    if (await visitedYes.isVisible()) {
      // Click NO - travel history should be hidden
      await visitedNo.click();
      
      // Wait a bit for any transitions
      await page.waitForTimeout(500);
      
      // Travel history section should be hidden
      const travelSection = page.locator('.conditional-section, [id*="travel"], [class*="travel-history"]').first();
      if (await travelSection.count() > 0) {
        const isHidden = await travelSection.evaluate(el => {
          const style = window.getComputedStyle(el);
          const elem = /** @type {HTMLElement} */(el);
          return style.display === 'none' || style.visibility === 'hidden' || elem.hidden;
        });
        expect(isHidden).toBeTruthy();
      }
      
      // Click YES - travel history should be visible
      await visitedYes.click();
      await page.waitForTimeout(500);
      
      if (await travelSection.count() > 0) {
        const isVisible = await travelSection.evaluate(el => {
          const style = window.getComputedStyle(el);
          const elem = /** @type {HTMLElement} */(el);
          return style.display !== 'none' && style.visibility !== 'hidden' && !elem.hidden;
        });
        expect(isVisible).toBeTruthy();
      }
    }
  });

  test('should have emergency contact section', async ({ page }) => {
    // Look for emergency contact fields
    const emergencyInputs = page.locator('input[name*="emergency"], input[placeholder*="emergency" i]');
    const contactInputs = page.locator('input[name*="contact"], input[placeholder*="contact" i]');
    
    const hasEmergency = await emergencyInputs.count() > 0;
    const hasContact = await contactInputs.count() > 0;
    expect(hasEmergency || hasContact).toBeTruthy();
  });

  test('should have attestation/signature section', async ({ page }) => {
    // Scroll to bottom
    await page.evaluate(() => window.scrollTo(0, document.body.scrollHeight));
    
    // Look for signature or attestation fields
    const signature = page.locator('input[type="text"][name*="signature"], canvas, [class*="signature"]');
    const checkbox = page.locator('input[type="checkbox"]');
    
    const hasSignature = await signature.count() > 0;
    const hasCheckbox = await checkbox.count() > 0;
    expect(hasSignature || hasCheckbox).toBeTruthy();
  });

  test('should have submit button', async ({ page }) => {
    const submitButton = page.locator('button[type="submit"], input[type="submit"]');
    await expect(submitButton).toBeVisible();
  });

  test('should be responsive on mobile', async ({ page, isMobile }) => {
    if (isMobile) {
      await expect(page.locator('form')).toBeVisible();
      
      // Verify no horizontal scroll
      const hasHorizontalScroll = await page.evaluate(() => {
        return document.documentElement.scrollWidth > document.documentElement.clientWidth;
      });
      expect(hasHorizontalScroll).toBeFalsy();
    }
  });
});

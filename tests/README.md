# Playwright Tests for Armenian College of Nurses

## Overview
This directory contains automated end-to-end tests using Playwright Test for the Armenian College of Nurses admission system.

## Test Files

### `admission-form.spec.js`
Tests for the student admission form (`admission-form.html`):
- Form loading and visibility
- Required field validation
- Email format validation
- Date input functionality
- Mobile responsiveness

### `final-form.spec.js`
Tests for the enrollment questionnaire (`final-form.html`):
- Form sections display
- **NEW:** Travel history YES/NO control and conditional visibility
- Emergency contact section
- Attestation/signature section
- Mobile responsiveness

### `login.spec.js`
Tests for the login page (`login.html`):
- Login form display
- Input validation
- Password masking
- Keyboard accessibility
- Mobile responsiveness

### `admin-pages.spec.js`
Tests for admin dashboard pages:
- Page loading (structure tests without authentication)
- Security checks (no data exposure without auth)
- Title and basic structure

### `public-pages.spec.js`
Tests for public pages (homepage, about):
- Page loading
- Content display
- Navigation
- Console error detection
- Mobile responsiveness

## Running Tests

### Run all tests
```bash
npm test
```

### Run tests in UI mode (interactive)
```bash
npm run test:ui
```

### Run tests in headed mode (see browser)
```bash
npm run test:headed
```

### Run tests in debug mode
```bash
npm run test:debug
```

### Run specific test file
```bash
npx playwright test admission-form.spec.js
```

### Run specific test by name
```bash
npx playwright test -g "should show travel history"
```

### View test report
```bash
npm run test:report
```

## VS Code Integration

With the **Playwright Test for VSCode** extension installed, you can:

1. **Run tests from the sidebar**
   - Click the Testing icon (beaker) in VS Code sidebar
   - See all test files and individual tests
   - Click the play button next to any test to run it

2. **Run tests inline**
   - Green play buttons appear next to each test in your code
   - Click to run that specific test

3. **Debug tests**
   - Set breakpoints in your test code
   - Right-click on a test and select "Debug Test"

4. **View test results**
   - See pass/fail status in the sidebar
   - Click failed tests to see error details
   - View screenshots and videos for failures

## Test Configuration

The tests are configured in `playwright.config.js`:

- **Base URL**: `http://localhost:8000` (auto-starts Python server)
- **Browsers**: Chrome, Firefox, Safari, Mobile Chrome, Mobile Safari
- **Screenshots**: Captured on failure
- **Videos**: Retained on failure
- **Traces**: Captured on first retry

## Local Development Server

Tests automatically start the development server using `start-server.py` on port 8000. If you need to run the server manually:

```bash
python3 start-server.py
```

Or use the quick-start script:
```bash
./quick-start.sh
```

## Writing New Tests

Example test structure:

```javascript
const { test, expect } = require('@playwright/test');

test.describe('My Feature', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/my-page.html');
  });

  test('should do something', async ({ page }) => {
    await expect(page.locator('#my-element')).toBeVisible();
  });
});
```

## Key Features Tested

### ✅ Admission Form
- Form validation
- Email and phone input
- Date of birth selection

### ✅ Enrollment Questionnaire
- **Travel History Control**: Tests the new YES/NO checkbox that controls whether travel history section is shown
- Conditional section visibility
- Emergency contacts
- Digital signature

### ✅ Login System
- Authentication form
- Input validation
- Security checks

### ✅ Admin Dashboard
- Page structure
- Auth protection
- No data leaks

### ✅ Responsive Design
- Mobile viewport testing
- No horizontal scroll
- Touch-friendly interfaces

## Troubleshooting

### Tests fail with "ERR_CONNECTION_REFUSED"
- Make sure port 8000 is available
- Check if `start-server.py` runs successfully
- Try running the server manually first

### "Timeout waiting for..." errors
- Increase timeout in test: `test.setTimeout(60000)`
- Check if page loads slowly due to external resources
- Verify Supabase connection is working

### Browser not found
- Run `npx playwright install` to download browsers
- Specific browser: `npx playwright install chromium`

## CI/CD Integration

For GitHub Actions or other CI systems:

```yaml
- name: Install dependencies
  run: npm ci
  
- name: Install Playwright Browsers
  run: npx playwright install --with-deps
  
- name: Run Playwright tests
  run: npm test
```

## Resources

- [Playwright Documentation](https://playwright.dev)
- [Playwright Best Practices](https://playwright.dev/docs/best-practices)
- [VS Code Extension](https://marketplace.visualstudio.com/items?itemName=ms-playwright.playwright)

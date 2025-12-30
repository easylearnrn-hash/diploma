# Armenian College of Nurses - Diploma Project

Official website for the Armenian College of Nurses showcasing nursing education programs, curriculum, and admissions information.

## Project Structure

```
DIPLOMA/
├── index.html          # Homepage
├── login.html          # Login page
├── css/
│   └── style.css      # Main stylesheet
├── js/
│   └── main.js        # Main JavaScript file
├── assets/
│   ├── images/        # Image files
│   └── fonts/         # Custom fonts (if any)
└── README.md          # This file
```

## Features

- **Homepage with embedded styles** - Modern, responsive design for Armenian College of Nurses
- **Sections included:**
  - Hero section with call-to-action
  - Statistics showcase (98% NCLEX Readiness, 500+ Graduates)
  - Programs overview (Associate, BSN, NCLEX Preparation)
  - System-based curriculum display
  - Simulation & Clinical Training info
  - Faculty & Leadership showcase
  - Admissions CTA section
- **Login page** - Secure authentication interface
- **SMS Integration** - Twilio + Supabase Edge Functions for notifications
  - Admission notifications
  - Class reminders
  - Phone verification
  - Exam alerts
- **Responsive design** - Mobile-friendly layout
- **Modern glassmorphism UI** - Backdrop blur effects and gradient backgrounds

## Getting Started

### Prerequisites

- A modern web browser (Chrome, Firefox, Safari, Edge)
- Optional: Live Server extension for VS Code for local development

### Running the Project

1. **Simple Method**: Open `index.html` directly in your web browser

2. **Using Live Server** (Recommended for development):
   - Install the "Live Server" extension in VS Code
   - Right-click on `index.html`
   - Select "Open with Live Server"

## Development

### File Organization

- **HTML Files**: Keep all HTML files in the root directory
- **CSS**: Place all stylesheets in the `css/` folder
- **JavaScript**: Place all scripts in the `js/` folder
- **Assets**: Place images, fonts, and other media in the `assets/` folder

### Customization

1. **Styling**: Edit `css/style.css` to modify the appearance
2. **Functionality**: Edit `js/main.js` to add interactive features
3. **Content**: Edit HTML files to change page content

## SMS Integration

This project includes a complete SMS notification system using Twilio and Supabase Edge Functions.

### Quick Start
1. See `QUICKSTART-SMS.md` for 5-minute setup
2. Complete guide in `TWILIO-SMS-SETUP.md`
3. Test with `sms-demo.html`

### Features
- ✅ Send SMS to US phone numbers
- ✅ Phone verification with codes
- ✅ Admission notifications
- ✅ Class and exam reminders
- ✅ Serverless backend (Supabase Edge Functions)
- ✅ Secure credential management

### Usage
```javascript
const smsService = new SMSService(SUPABASE_URL, SUPABASE_ANON_KEY);
await smsService.sendSMS('+15551234567', 'Welcome!', 'notification');
```

See `SMS-INTEGRATION-SUMMARY.md` for complete documentation.

## TODO

- [x] SMS notification system (Twilio + Supabase)
- [ ] Complete login page functionality
- [ ] Add backend API integration
- [ ] Implement user authentication system
- [ ] Add application form pages with SMS verification
- [ ] Create program detail pages
- [ ] Add faculty profiles
- [ ] Implement contact form
- [ ] Add news/announcements section
- [ ] Integrate SMS with admission workflow

## Technologies Used

- HTML5 with embedded CSS
- Modern CSS (CSS Grid, Flexbox, Custom Properties)
- Glassmorphism design techniques
- Google Fonts (Inter)
- Vanilla JavaScript
- **Supabase** - Backend-as-a-Service & Edge Functions
- **Twilio** - SMS API
- **TypeScript/Deno** - Edge Function runtime

## Design Features

- **Color Scheme**: Dark blue gradient (#0a2540, #020617) with teal accent (#2dd4bf)
- **Typography**: Inter font family (Google Fonts)
- **UI Style**: Glassmorphism with backdrop blur effects
- **Responsive**: Mobile-first design with media queries

## License

This project is part of a diploma/thesis work.

## Author

Your Name - Diploma Project 2025

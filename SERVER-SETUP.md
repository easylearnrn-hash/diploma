# How to Fix PDF Download Security Errors

## Problem
When opening HTML files directly with `file://` protocol, browsers block:
- Loading local resources (images, scripts)
- Generating PDFs with html2pdf
- Cross-origin requests (CORS)

**Error**: `SecurityError: The operation is insecure`

## Solution: Run a Local Web Server

### Quick Start (Recommended)

1. **Open Terminal** in the project folder
2. **Run the server**:
   ```bash
   python3 start-server.py
   ```
3. **Open in browser**: http://localhost:8000/Student-page.html

### Alternative Methods

#### Option 1: Python Simple Server
```bash
# Python 3
python3 -m http.server 8000

# Python 2
python -m SimpleHTTPServer 8000
```

#### Option 2: Node.js (if installed)
```bash
# Install http-server globally (one time)
npm install -g http-server

# Run server
http-server -p 8000
```

#### Option 3: VS Code Live Server Extension
1. Install "Live Server" extension in VS Code
2. Right-click any HTML file
3. Select "Open with Live Server"

### Access Your Pages

Once the server is running:
- Student Page: http://localhost:8000/Student-page.html
- Index: http://localhost:8000/index.html
- Login: http://localhost:8000/login.html

### Stop the Server

Press `Ctrl+C` in the terminal

## Why This Works

- Serves files over `http://` instead of `file://`
- Enables CORS headers for cross-origin resources
- Allows html2pdf to access images and generate PDFs securely
- Mimics production environment behavior

## Troubleshooting

**Port already in use?**
```bash
python3 start-server.py 3000  # Use different port
```

**Python not found?**
- Install Python 3 from https://www.python.org/downloads/
- Or use VS Code Live Server extension instead

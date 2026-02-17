#!/usr/bin/env python3
"""
Simple HTTP server for serving the DIPLOMA project locally.
This resolves CORS and file:// protocol security issues with html2pdf.

Usage: python3 start-server.py [port]
Default port: 8000

Example:
    python3 start-server.py
    python3 start-server.py 3000
"""

import http.server
import socketserver
import sys
import os

# Change to script directory
os.chdir(os.path.dirname(os.path.abspath(__file__)))

# Get port from command line or use default
PORT = int(sys.argv[1]) if len(sys.argv) > 1 else 8000

class MyHTTPRequestHandler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        if self.path == '/favicon.ico':
            self.send_response(204)
            self.end_headers()
            return
        super().do_GET()

    def end_headers(self):
        # Add CORS headers to allow cross-origin requests
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
        self.send_header('Cache-Control', 'no-store, no-cache, must-revalidate')
        super().end_headers()

    def log_message(self, format, *args):
        # Custom logging format
        print(f"[{self.log_date_time_string()}] {format % args}")

with socketserver.TCPServer(("", PORT), MyHTTPRequestHandler) as httpd:
    # Get local IP address (not localhost)
    import socket
    import subprocess
    try:
        # Get WiFi IP on macOS
        result = subprocess.run(['ipconfig', 'getifaddr', 'en0'], 
                                capture_output=True, text=True, timeout=2)
        local_ip = result.stdout.strip()
        if not local_ip:
            # Fallback to ethernet
            result = subprocess.run(['ipconfig', 'getifaddr', 'en1'], 
                                    capture_output=True, text=True, timeout=2)
            local_ip = result.stdout.strip()
        if not local_ip:
            local_ip = "Unable to detect - check WiFi connection"
    except Exception:
        local_ip = "Unable to detect - check WiFi connection"
    
    print("=" * 70)
    print(f"🚀 DIPLOMA Project Server Starting...")
    print("=" * 70)
    print(f"\n📂 Serving directory: {os.getcwd()}")
    print(f"\n🖥️  LOCAL ACCESS (This Computer):")
    print(f"   http://localhost:{PORT}/")
    print(f"\n📱 MOBILE ACCESS (iPhone/iPad on same WiFi):")
    print(f"   http://{local_ip}:{PORT}/")
    print(f"\n✨ Access VID from iPhone:")
    print(f"   http://{local_ip}:{PORT}/VID.html")
    print(f"\n📄 Other pages:")
    print(f"   • Student Page:  http://{local_ip}:{PORT}/Student-page.html")
    print(f"   • Admin Hub:     http://{local_ip}:{PORT}/admin-hub.html")
    print(f"   • Login:         http://{local_ip}:{PORT}/login.html")
    print(f"\n⚠️  Press Ctrl+C to stop the server")
    print("=" * 70 + "\n")
    
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        print("\n\n🛑 Server stopped by user")
        sys.exit(0)

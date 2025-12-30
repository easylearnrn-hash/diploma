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
    print("=" * 60)
    print(f"🚀 DIPLOMA Project Server Starting...")
    print("=" * 60)
    print(f"\n📂 Serving directory: {os.getcwd()}")
    print(f"🌐 Server running at: http://localhost:{PORT}/")
    print(f"\n📄 Access pages:")
    print(f"   • Student Page:  http://localhost:{PORT}/Student-page.html")
    print(f"   • Index:         http://localhost:{PORT}/index.html")
    print(f"   • Login:         http://localhost:{PORT}/login.html")
    print(f"\n⚠️  Press Ctrl+C to stop the server")
    print("=" * 60 + "\n")
    
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        print("\n\n🛑 Server stopped by user")
        sys.exit(0)

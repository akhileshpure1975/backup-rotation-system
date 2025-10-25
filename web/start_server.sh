#!/bin/bash
cd "$(dirname "$0")"
echo "🌐 Starting Backup System Dashboard..."
echo "📍 Open: http://localhost:8080"
echo "Press Ctrl+C to stop"
python3 -m http.server 8080

#!/bin/bash

cd ~/Projects/backup-rotation-system/web
echo "Starting web server on http://localhost:8080"
echo "Press Ctrl+C to stop"
python3 -m http.server 8080

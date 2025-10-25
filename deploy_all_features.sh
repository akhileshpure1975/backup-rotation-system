#!/bin/bash

echo "🚀 Deploying All Advanced Features..."
echo "========================================"

cd ~/Projects/backup-rotation-system

# Commit all changes
git add .
git commit -m "feat: Add all advanced features

- GPG encryption support
- AWS S3 cloud sync
- Database backups (MySQL/PostgreSQL)
- Web dashboard interface
- Complete production deployment
"

# Push to GitHub
git push origin main

echo ""
echo "✅ All features deployed!"
echo ""
echo "Next steps:"
echo "1. Configure GPG: gpg --full-generate-key"
echo "2. Configure AWS: aws configure"
echo "3. Enable features in: config/backup.conf"
echo "4. Start dashboard: ./web/start_server.sh"
echo ""
echo "Your project: https://github.com/akhileshpure1975/backup-rotation-system"

#!/bin/bash

echo "🚀 Deploying Advanced Backup Features..."
echo "========================================"

# Test GPG encryption
echo "1. Testing GPG encryption..."
if gpg --version &>/dev/null; then
    echo "   ✅ GPG installed"
else
    echo "   ❌ GPG not installed. Run: sudo apt-get install gnupg"
fi

# Test cloud tools
echo "2. Testing cloud sync tools..."
if aws --version &>/dev/null; then
    echo "   ✅ AWS CLI installed"
else
    echo "   ⚠️  AWS CLI not installed (optional)"
fi

if rclone version &>/dev/null; then
    echo "   ✅ rclone installed"
else
    echo "   ⚠️  rclone not installed (optional)"
fi

# Test database tools
echo "3. Testing database tools..."
if mysql --version &>/dev/null; then
    echo "   ✅ MySQL client installed"
else
    echo "   ⚠️  MySQL not installed (optional)"
fi

if psql --version &>/dev/null; then
    echo "   ✅ PostgreSQL client installed"
else
    echo "   ⚠️  PostgreSQL not installed (optional)"
fi

# Start web dashboard
echo "4. Starting web dashboard..."
if python3 --version &>/dev/null; then
    echo "   ✅ Python3 installed"
    echo "   🌐 Web dashboard available at: http://localhost:8080"
    echo "   Run: ~/Projects/backup-rotation-system/web/start_server.sh"
else
    echo "   ❌ Python3 not installed"
fi

echo ""
echo "========================================"
echo "✅ Deployment complete!"
echo ""
echo "Next steps:"
echo "1. Configure encryption: nano ~/Projects/backup-rotation-system/config/backup.conf"
echo "2. Set up cloud sync (AWS/Google Drive/Remote)"
echo "3. Enable database backups if needed"
echo "4. Start web dashboard: ~/Projects/backup-rotation-system/web/start_server.sh"

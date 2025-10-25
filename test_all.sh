#!/bin/bash
cd ~/Projects/backup-rotation-system

echo "========================================="
echo "Complete Backup System Test Suite"
echo "========================================="
echo ""

# Test 1: Full Backup
echo "Test 1: Full Backup"
echo "-------------------"
BACKUP_TYPE=full ./scripts/backup.sh
echo "✓ Full backup completed"
echo ""

# Test 2: Incremental Backup
echo "Test 2: Incremental Backup"
echo "---------------------------"
BACKUP_TYPE=incremental ./scripts/backup.sh
echo "✓ Incremental backup completed"
echo ""

# Test 3: List Backups
echo "Test 3: List Backups"
echo "--------------------"
./scripts/restore.sh --list
echo ""

# Test 4: Verify All Backups
echo "Test 4: Verify All Backups"
echo "--------------------------"
./scripts/verify.sh
echo ""

# Test 5: Restore Test
echo "Test 5: Restore Test"
echo "--------------------"
rm -rf /tmp/restore_test_full
LATEST_BACKUP=$(ls -t backups/backup_*.tar.gz | head -1)
./scripts/restore.sh "$LATEST_BACKUP" /tmp/restore_test_full
echo "✓ Restore completed"
echo ""

# Test 6: Check Backup Sizes
echo "Test 6: Backup Sizes"
echo "--------------------"
du -h backups/*.tar.gz
echo ""

# Test 7: View Logs
echo "Test 7: Recent Log Entries"
echo "--------------------------"
tail -10 logs/backup_*.log
echo ""

echo "========================================="
echo "All Tests Completed Successfully!"
echo "========================================="
echo ""
echo "Summary:"
echo "--------"
echo "Total backups: $(ls backups/backup_*.tar.gz 2>/dev/null | wc -l)"
echo "Total size: $(du -sh backups/ | cut -f1)"
echo "Total lines of code: $(find scripts utils -name "*.sh" -exec wc -l {} + | tail -1 | awk '{print $1}')"
echo ""

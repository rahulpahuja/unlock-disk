#!/bin/bash

# fix_disk_lock.sh
# Fixes stuck disk locks on macOS after accidental drive removal
# Usage: sudo bash fix_disk_lock.sh

echo "🔍 Scanning for stuck disk processes..."

# Kill fskitd (filesystem kit daemon - main culprit)
FSKITD_PID=$(pgrep fskitd)
if [ -n "$FSKITD_PID" ]; then
    echo "⚡ Killing fskitd (PID: $FSKITD_PID)..."
    sudo kill -9 $FSKITD_PID
else
    echo "✅ fskitd is not stuck"
fi

# Kill any process holding a lock on rdisk (raw disk devices)
RDISK_PIDS=$(sudo lsof 2>/dev/null | grep '/dev/rdisk' | awk '{print $2}' | sort -u)
if [ -n "$RDISK_PIDS" ]; then
    echo "⚡ Killing processes with raw disk locks: $RDISK_PIDS"
    for PID in $RDISK_PIDS; do
        sudo kill -9 $PID 2>/dev/null
        echo "   Killed PID $PID"
    done
else
    echo "✅ No raw disk locks found"
fi

# Restart diskarbitrationd to re-enumerate all disks
echo "🔄 Restarting diskarbitrationd..."
sudo launchctl stop com.apple.diskarbitrationd
sleep 1
sudo launchctl start com.apple.diskarbitrationd

echo ""
echo "✅ Done. Now run: diskutil list"
echo "   Or reopen Disk Utility — your drives should show up."

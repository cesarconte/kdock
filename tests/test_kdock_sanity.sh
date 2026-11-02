#!/usr/bin/env bash
set -euo pipefail

echo "=== [1/3] Testing Mathematical Magnification Engine ==="
python3 /home/cesar/antigravity/kdock/tests/test_magnification.py

echo "=== [2/3] Validating KPackage Metadata for Plasma 6 ==="
kpackagetool6 --type Plasma/Applet --show /home/cesar/antigravity/kdock > /dev/null
echo "✓ KPackage metadata structure valid."

echo "=== [3/3] Testing Plasmoid Runtime Initialization ==="
timeout 2s plasmoidviewer -a /home/cesar/antigravity/kdock > /tmp/plasmoidviewer_test.log 2>&1 || true
if grep -E -i "Unable to assign|ReferenceError|TypeError.*kdock" /tmp/plasmoidviewer_test.log; then
    echo "✗ Runtime QML error detected in kDock!"
    cat /tmp/plasmoidviewer_test.log
    exit 1
else
    echo "✓ Plasmoid loaded cleanly without QML errors."
fi

echo "=== ALL KDOCK TESTS PASSED ==="

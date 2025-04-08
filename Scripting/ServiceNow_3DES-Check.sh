#!/bin/bash

# ==============================================================================
# ServiceNow 3DES Compliance Check Script
# ------------------------------------------------------------------------------
# This script checks for compatibility with ServiceNow's Xanadu update, which 
# deprecates the use of 3DES encryption in SSH communications.
#
# It performs the following checks:
#  - Retrieves the current SSH cipher configuration.
#  - Searches the filesystem for .pem files.
#  - Scans each .pem file for "DES-EDE3-CBC" to detect 3DES-encrypted keys.
#  - Generates a summary report of findings.
#
# Output:
#  - Report saved to ~/servicenow_3des_check_report.txt
#  - Printed to the console.
#
# Usage:
#   chmod +x check_servicenow_3des.sh
#   ./check_servicenow_3des.sh
# ==============================================================================

REPORT_FILE=~/servicenow_3des_check_report.txt
echo "ServiceNow 3DES Compliance Report - $(date)" > "$REPORT_FILE"
echo "============================================" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# Check SSH server ciphers
echo "🔐 SSH Server Cipher Configuration:" >> "$REPORT_FILE"
sshd -T | grep -i ciphers >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# Find and check all .pem files
echo "🔎 Scanning for .pem files containing DES-EDE3-CBC..." >> "$REPORT_FILE"
FOUND=false
find / -type f -name "*.pem" 2>/dev/null | while read -r file; do
  if grep -q "DES-EDE3-CBC" "$file"; then
    echo "❌  3DES encryption found in: $file" >> "$REPORT_FILE"
    FOUND=true
  fi
done

if ! $FOUND; then
  echo "✅  No PEM files using 3DES encryption found." >> "$REPORT_FILE"
fi

echo "" >> "$REPORT_FILE"
echo "✅ Compliance check complete." >> "$REPORT_FILE"
echo "Results saved to: $REPORT_FILE"

# Output the report to console
cat "$REPORT_FILE"

#!/bin/bash
# Configuration
COMBINED_TMP="[temp-file]"                       #usually /tmp/combained-ip.txt
TARGET_DIR="[your-target-dir]"

OUTPUT_IP="$TARGET_DIR/zblacklist.txt"           #ip address only
OUTPUT_ADDR_LIST="$TARGET_DIR/zblacklist.rsc"    #mikrotik /ip firewall address-list

# Source list 
URLS=(
    "https://joshaven.com/genlist.php?lists=spamhaus,dshield,bruteforce&prefix="
    "https://cinsscore.com/list/ci-badguys.txt"
    "https://raw.githubusercontent.com/stamparm/ipsum/refs/heads/master/levels/6.txt"
    "https://raw.githubusercontent.com/stamparm/ipsum/refs/heads/master/levels/7.txt"
    "https://raw.githubusercontent.com/stamparm/ipsum/refs/heads/master/levels/8.txt"
)

# Prepare dir 
mkdir -p "$TARGET_DIR"
> "$COMBINED_TMP"

# echo "Download is starting..."
# Loop source list 
for URL in "${URLS[@]}"; do
    # echo "Downloading $URL"
    http_status=$(curl -s -w "%{http_code}" "$URL" >> "$COMBINED_TMP")
    sleep 1
done

# If tmp file not empty 
if [ -s "$COMBINED_TMP" ]; then
    # Output unique ip address only 
    awk '/^[0-9]/ {print $1}' "$COMBINED_TMP" | sort -u | awk "{print $1}" >> "$OUTPUT_IP"

    # Output Router OS /ip firewall address-list format
    ## 1. Add comment and header
    echo "# Sources:" > "$OUTPUT_ADDR_LIST"
    echo "# -  https://joshaven.com/genlist.php?lists=spamhaus,dshield,bruteforce&prefix=" >> "$OUTPUT_ADDR_LIST"
    echo "# -  https://cinsscore.com/list/ci-badguys.txt" >> "$OUTPUT_ADDR_LIST"
    echo "# -  https://raw.githubusercontent.com/stamparm/ipsum/refs/heads/master/levels/6.txt" >> "$OUTPUT_ADDR_LIST"
    echo "# -  https://raw.githubusercontent.com/stamparm/ipsum/refs/heads/master/levels/7.txt" >> "$OUTPUT_ADDR_LIST"
    echo "# -  https://raw.githubusercontent.com/stamparm/ipsum/refs/heads/master/levels/8.txt" >> "$OUTPUT_ADDR_LIST"
    echo "# (updated every 24 hours)" >> "$OUTPUT_ADDR_LIST"
    echo "/ip firewall address-list remove [find list=ZBlacklist && comment!=manual]" >> "$OUTPUT_ADDR_LIST"
    echo "/ip firewall address-list" >> "$OUTPUT_ADDR_LIST"

    ## 2. Print unique ip address 
    awk '/^[0-9]/ {print $1}' "$COMBINED_TMP" | sort -u | awk '{print "add address=" $1 " list=ZBlacklist"}' >> "$OUTPUT_ADDR_LIST"

    # Give access
    chmod 644 "$OUTPUT_IP"
    chmod 644 "$OUTPUT_ADDR_LIST"

    # Log success 
    echo "$(date '+%Y-%m-%d %H:%M:%S') - [Success] File zblacklist.rsc dan zblacklist.txt berhasil dibuat."
else
    # Log error
    echo "$(date '+%Y-%m-%d %H:%M:%S') - [Error] Gagal mengunduh atau semua file."
fi

# Remove tmp file
rm -f "$COMBINED_TMP"

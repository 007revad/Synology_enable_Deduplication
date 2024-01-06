#!/bin/bash

strgmgr=/var/packages/StorageManager/target/ui/storage_panel.js
#strgmgr=/volume1/temp/__test4/storage_panel.js

string1="return!(!this.isSsd||!this.isSynoDrive||e)"
string2="return(this.isSsd)"

if [[ ! -f "${strgmgr}.1.0.0-0017" ]]; then
    echo "storage_panel.js is NOT backed up!"
    #exit
fi

if grep -o "$string1" "${strgmgr}" >/dev/null; then
    sed -i "s/${string1}/${string2}/g" "$strgmgr"
    chmod 644 "$strgmgr"
    if grep -o "$string2" "${strgmgr}" >/dev/null; then
        echo "Successfully edited storage_panel.js"
        echo "  string: $string2"
    fi
elif grep -o "$string2" "${strgmgr}" >/dev/null; then
    echo "storage_panel.js is already edited"
    echo "  string: $string2"
else
    echo "strings not found in $strgmgr"
    echo "  string1: $string1"
    echo "  string2: $string2"
fi

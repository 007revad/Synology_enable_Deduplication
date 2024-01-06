#!/bin/bash

check(){ 
# Warn if script located on M.2 drive
scriptvol=$(echo "$scriptpath" | cut -d"/" -f2)

echo "scriptvol: $scriptvol"  # debug

vg=$(lvdisplay | grep /volume_"${scriptvol#volume}" | cut -d"/" -f3)

echo "vg: $vg"  # debug

md=$(pvdisplay | grep -B 1 "$vg" | grep /dev/ | cut -d"/" -f3)

echo "md: $md"  # debug

if cat /proc/mdstat | grep "$md" | grep nvme >/dev/null; then
    echo -e "${Yellow}WARNING${Off} Don't store this script on an NVMe volume!"
fi
}

# Get list of mounted volumes
volumes=( )
for volume in /volume*; do
    # Ignore /volumeUSB# and /volume0
    if [[ $volume =~ /volume[1-9][0-9]?$ ]]; then
        # Ignore unmounted volumes
        if df -h | grep "$volume" >/dev/null ; then
            scriptpath="${volume}/scripts/test.sh"
            echo "$scriptpath"
            check
            echo ""
        fi
    fi
done

exit


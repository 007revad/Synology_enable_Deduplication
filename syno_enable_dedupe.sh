#!/usr/bin/env bash
#-------------------------------------------------------------------------------
# Enables data deduplication with non-Synology drives and unsupported NAS models
#
# Github: https://github.com/007revad/Synology_enable_Deduplication
# Script verified at https://www.shellcheck.net/
#
# To run in a shell (replace /volume1/scripts/ with path to script):
# sudo /volume1/scripts/syno_enable_dedupe.sh
#-------------------------------------------------------------------------------

scriptver="v1.3.23"
script=Synology_enable_Deduplication
repo="007revad/Synology_enable_Deduplication"
scriptname=syno_enable_dedupe

# Check BASH variable is bash
if [ ! "$(basename "$BASH")" = bash ]; then
    echo "This is a bash script. Do not run it with $(basename "$BASH")"
    printf \\a
    exit 1
fi

# Check script is running on a Synology NAS
if ! /usr/bin/uname -a | grep -i synology >/dev/null; then
    echo "This script is NOT running on a Synology NAS!"
    echo "Copy the script to a folder on the Synology"
    echo "and run it from there."
    exit 1
fi

ding(){ 
    printf \\a
}

usage(){ 
    cat <<EOF
$script $scriptver - by 007revad

Usage: $(basename "$0") [options]

Options:
  -c, --check           Check value in file and backup file
  -r, --restore         Undo all changes made by the script
  -t, --tiny            Enable tiny data deduplication (only needs 4GB RAM)
                          DSM 7.2.1 and later only
      --hdd             Enable data deduplication for HDDs (dangerous)
  -e, --email           Disable colored text in output for scheduler emails
      --autoupdate=AGE  Auto update script (useful when script is scheduled)
                          AGE is how many days old a release must be before
                          auto-updating. AGE must be a number: 0 or greater
  -s, --skip            Skip memory amount check (for testing)
  -h, --help            Show this help message
  -v, --version         Show the script version

EOF
    exit 0
}


scriptversion(){ 
    cat <<EOF
$script $scriptver - by 007revad

See https://github.com/$repo
EOF
    exit 0
}


# Save options used
args=("$@")


autoupdate=""

# Check for flags with getopt
if options="$(getopt -o abcdefghijklmnopqrstuvwxyz0123456789 -l \
    skip,check,restore,help,version,tiny,hdd,email,autoupdate:,log,debug -- "$@")"; then
    eval set -- "$options"
    while true; do
        case "${1,,}" in
            -h|--help)          # Show usage options
                usage
                ;;
            -v|--version)       # Show script version
                scriptversion
                ;;
            -t|--tiny)          # Enable tiny deduplication
                tiny=yes
                ;;
            --hdd)              # Enable deduplication for HDDs (dangerous)
                hdd=yes
                ;;
            -s|--skip)          # Skip memory amount check (for testing)
                skip=yes
                ;;
            -l|--log)           # Log
                #log=yes
                ;;
            -d|--debug)         # Show and log debug info
                debug=yes
                ;;
            -c|--check)         # Check value in file and backup file
                check=yes
                break
                ;;
            -r|--restore)       # Restore from backups to undo changes
                restore=yes
                break
                ;;
            -e|--email)         # Disable colour text in task scheduler emails
                color=no
                ;;
            --autoupdate)       # Auto update script
                autoupdate=yes
                if [[ $2 =~ ^[0-9]+$ ]]; then
                    delay="$2"
                    shift
                else
                    delay="0"
                fi
                ;;
            --)
                shift
                break
                ;;
            *)                  # Show usage options
                echo -e "Invalid option '$1'\n"
                usage "$1"
                ;;
        esac
        shift
    done
else
    echo
    usage
fi


if [[ $debug == "yes" ]]; then
    set -x
    export PS4='`[[ $? == 0 ]] || echo "\e[1;31;40m($?)\e[m\n "`:.$LINENO:'
fi


# Shell Colors
if [[ $color != "no" ]]; then
    #Black='\e[0;30m'   # ${Black}
    Red='\e[0;31m'      # ${Red}
    #Green='\e[0;32m'   # ${Green}
    Yellow='\e[0;33m'   # ${Yellow}
    #Blue='\e[0;34m'    # ${Blue}
    #Purple='\e[0;35m'  # ${Purple}
    Cyan='\e[0;36m'     # ${Cyan}
    #White='\e[0;37m'   # ${White}
    Error='\e[41m'      # ${Error}
    Off='\e[0m'         # ${Off}
else
    echo ""  # For task scheduler email readability
fi


# Check script is running as root
if [[ $( whoami ) != "root" ]]; then
    ding
    echo -e "${Error}ERROR${Off} This script must be run as sudo or root!"
    exit 1
fi

# Get DSM major, minor and micro versions
major=$(get_key_value /etc.defaults/VERSION majorversion)
minor=$(get_key_value /etc.defaults/VERSION minorversion)
micro=$(get_key_value /etc.defaults/VERSION micro)

# Get NAS model
model=$(cat /proc/sys/kernel/syno_hw_version)
#modelname="$model"


# Show script version
#echo -e "$script $scriptver\ngithub.com/$repo\n"
echo "$script $scriptver"

# Get DSM full version
productversion=$(get_key_value /etc.defaults/VERSION productversion)
buildphase=$(get_key_value /etc.defaults/VERSION buildphase)
buildnumber=$(get_key_value /etc.defaults/VERSION buildnumber)
smallfixnumber=$(get_key_value /etc.defaults/VERSION smallfixnumber)

# Show DSM full version and model
if [[ $buildphase == GM ]]; then buildphase=""; fi
if [[ $smallfixnumber -gt "0" ]]; then smallfix="-$smallfixnumber"; fi
echo -e "$model DSM $productversion-$buildnumber$smallfix $buildphase\n"


# Get StorageManager version
storagemgrver=$(synopkg version StorageManager)
# Show StorageManager version
if [[ $storagemgrver ]]; then echo -e "StorageManager $storagemgrver \n"; fi


# Show options used
if [[ ${#args[@]} -gt "0" ]]; then
    #echo -e "Using options: ${args[*]}\n"
    echo -e "Using options: ${args[*]}"
fi

if [[ $major$minor$micro -lt "701" ]]; then
    ding
    #echo "This script only works for DSM 7.0.1 and later."
    echo "Btrfs Data Deduplication only works in DSM 7.0.1 and later."
    exit 1
fi

# Check model (and DSM version for that model) supports dedupe
 if [[ ! -f /usr/syno/sbin/synobtrfsdedupe ]]; then
    arch=$(synogetkeyvalue /etc.defaults/synoinfo.conf platform_name)
    echo "Models with $arch CPUs do not support Btrfs Data Deduplication."
    echo "Only models with V1000, R1000, Geminilake, Broadwellnkv2, "
    echo "Broadwellnk, Broadwell, Purley and Epyc7002 CPUs are supported."
    exit
fi


#------------------------------------------------------------------------------
# Check latest release with GitHub API

syslog_set(){ 
    if [[ ${1,,} == "info" ]] || [[ ${1,,} == "warn" ]] || [[ ${1,,} == "err" ]]; then
        if [[ $autoupdate == "yes" ]]; then
            # Add entry to Synology system log
            synologset1 sys "$1" 0x11100000 "$2"
        fi
    fi
}


# Get latest release info
# Curl timeout options:
# https://unix.stackexchange.com/questions/94604/does-curl-have-a-timeout
release=$(curl --silent -m 10 --connect-timeout 5 \
    "https://api.github.com/repos/$repo/releases/latest")

# Release version
tag=$(echo "$release" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
shorttag="${tag:1}"

# Release published date
published=$(echo "$release" | grep '"published_at":' | sed -E 's/.*"([^"]+)".*/\1/')
published="${published:0:10}"
published=$(date -d "$published" '+%s')

# Today's date
now=$(date '+%s')

# Days since release published
age=$(((now - published)/(60*60*24)))


# Get script location
# https://stackoverflow.com/questions/59895/
source=${BASH_SOURCE[0]}
while [ -L "$source" ]; do # Resolve $source until the file is no longer a symlink
    scriptpath=$( cd -P "$( dirname "$source" )" >/dev/null 2>&1 && pwd )
    source=$(readlink "$source")
    # If $source was a relative symlink, we need to resolve it
    # relative to the path where the symlink file was located
    [[ $source != /* ]] && source=$scriptpath/$source
done
scriptpath=$( cd -P "$( dirname "$source" )" >/dev/null 2>&1 && pwd )
scriptfile=$( basename -- "$source" )
echo "Running from: ${scriptpath}/$scriptfile"

# Warn if script located on M.2 drive
scriptvol=$(echo "$scriptpath" | cut -d"/" -f2)
vg=$(lvdisplay | grep /volume_"${scriptvol#volume}" | cut -d"/" -f3)
md=$(pvdisplay | grep -B 1 -E '[ ]'"$vg" | grep /dev/ | cut -d"/" -f3)
if cat /proc/mdstat | grep "$md" | grep nvme >/dev/null; then
    echo -e "${Yellow}WARNING${Off} Don't store this script on an NVMe volume!"
fi


cleanup_tmp(){ 
    cleanup_err=

    # Delete downloaded .tar.gz file
    if [[ -f "/tmp/$script-$shorttag.tar.gz" ]]; then
        if ! rm "/tmp/$script-$shorttag.tar.gz"; then
            echo -e "${Error}ERROR${Off} Failed to delete"\
                "downloaded /tmp/$script-$shorttag.tar.gz!" >&2
            cleanup_err=1
        fi
    fi

    # Delete extracted tmp files
    if [[ -d "/tmp/$script-$shorttag" ]]; then
        if ! rm -r "/tmp/$script-$shorttag"; then
            echo -e "${Error}ERROR${Off} Failed to delete"\
                "downloaded /tmp/$script-$shorttag!" >&2
            cleanup_err=1
        fi
    fi

    # Add warning to DSM log
    if [[ -z $cleanup_err ]]; then
        syslog_set warn "$script update failed to delete tmp files"
    fi
}


if ! printf "%s\n%s\n" "$tag" "$scriptver" |
        sort --check=quiet --version-sort >/dev/null ; then
    echo -e "\n${Cyan}There is a newer version of this script available.${Off}"
    echo -e "Current version: ${scriptver}\nLatest version:  $tag"
    scriptdl="$scriptpath/$script-$shorttag"
    if [[ -f ${scriptdl}.tar.gz ]] || [[ -f ${scriptdl}.zip ]]; then
        # They have the latest version tar.gz downloaded but are using older version
        echo "You have the latest version downloaded but are using an older version"
        sleep 10
    elif [[ -d $scriptdl ]]; then
        # They have the latest version extracted but are using older version
        echo "You have the latest version extracted but are using an older version"
        sleep 10
    else
        if [[ $autoupdate == "yes" ]]; then
            if [[ $age -gt "$delay" ]] || [[ $age -eq "$delay" ]]; then
                echo "Downloading $tag"
                reply=y
            else
                echo "Skipping as $tag is less than $delay days old."
            fi
        else
            echo -e "${Cyan}Do you want to download $tag now?${Off} [y/n]"
            read -r -t 30 reply
        fi

        if [[ ${reply,,} == "y" ]]; then
            # Delete previously downloaded .tar.gz file and extracted tmp files
            cleanup_tmp

            if cd /tmp; then
                url="https://github.com/$repo/archive/refs/tags/$tag.tar.gz"
                if ! curl -JLO -m 30 --connect-timeout 5 "$url"; then
                    echo -e "${Error}ERROR${Off} Failed to download"\
                        "$script-$shorttag.tar.gz!"
                    syslog_set warn "$script $tag failed to download"
                else
                    if [[ -f /tmp/$script-$shorttag.tar.gz ]]; then
                        # Extract tar file to /tmp/<script-name>
                        if ! tar -xf "/tmp/$script-$shorttag.tar.gz" -C "/tmp"; then
                            echo -e "${Error}ERROR${Off} Failed to"\
                                "extract $script-$shorttag.tar.gz!"
                            syslog_set warn "$script failed to extract $script-$shorttag.tar.gz!"
                        else
                            # Set script sh files as executable
                            if ! chmod a+x "/tmp/$script-$shorttag/"*.sh ; then
                                permerr=1
                                echo -e "${Error}ERROR${Off} Failed to set executable permissions"
                                syslog_set warn "$script failed to set permissions on $tag"
                            fi

                            # Copy new script sh file to script location
                            if ! cp -p "/tmp/$script-$shorttag/${scriptname}.sh" "${scriptpath}/${scriptfile}";
                            then
                                copyerr=1
                                echo -e "${Error}ERROR${Off} Failed to copy"\
                                    "$script-$shorttag sh file(s) to:\n $scriptpath/${scriptfile}"
                                syslog_set warn "$script failed to copy $tag to script location"
                            fi

                            # Copy new CHANGES.txt file to script location (if script on a volume)
                            if [[ $scriptpath =~ /volume* ]]; then
                                # Set permissions on CHANGES.txt
                                if ! chmod 664 "/tmp/$script-$shorttag/CHANGES.txt"; then
                                    permerr=1
                                    echo -e "${Error}ERROR${Off} Failed to set permissions on:"
                                    echo "$scriptpath/CHANGES.txt"
                                fi

                                # Copy new CHANGES.txt file to script location
                                if ! cp -p "/tmp/$script-$shorttag/CHANGES.txt"\
                                    "${scriptpath}/${scriptname}_CHANGES.txt";
                                then
                                    if [[ $autoupdate != "yes" ]]; then copyerr=1; fi
                                    echo -e "${Error}ERROR${Off} Failed to copy"\
                                        "$script-$shorttag/CHANGES.txt to:\n $scriptpath"
                                else
                                    changestxt=" and changes.txt"
                                fi
                            fi

                            # Delete downloaded tmp files
                            cleanup_tmp

                            # Notify of success (if there were no errors)
                            if [[ $copyerr != 1 ]] && [[ $permerr != 1 ]]; then
                                echo -e "\n$tag ${scriptfile}$changestxt downloaded to: ${scriptpath}\n"
                                syslog_set info "$script successfully updated to $tag"

                                # Reload script
                                printf -- '-%.0s' {1..79}; echo  # print 79 -
                                exec "${scriptpath}/$scriptfile" "${args[@]}"
                            else
                                syslog_set warn "$script update to $tag had errors"
                            fi
                        fi
                    else
                        echo -e "${Error}ERROR${Off}"\
                            "/tmp/$script-$shorttag.tar.gz not found!"
                        #ls /tmp | grep "$script"  # debug
                        syslog_set warn "/tmp/$script-$shorttag.tar.gz not found"
                    fi
                fi
                cd "$scriptpath" || echo -e "${Error}ERROR${Off} Failed to cd to script location!"
            else
                echo -e "${Error}ERROR${Off} Failed to cd to /tmp!"
                syslog_set warn "$script update failed to cd to /tmp"
            fi
        fi
    fi
fi


#------------------------------------------------------------------------------
# Set file variables

synoinfo="/etc.defaults/synoinfo.conf"
synoinfo2="/etc/synoinfo.conf"
strgmgr="/var/packages/StorageManager/target/ui/storage_panel.js"
libhw="/usr/lib/libhwcontrol.so.1"

if [[ ! -f ${libhw} ]]; then
    ding
    echo -e "${Error}ERROR${Off} $(basename -- $libhw) not found!"
    exit 1
fi


rebootmsg(){ 
    # Reboot prompt
    echo -e "\n${Cyan}The Synology needs to restart.${Off}"
    echo -e "Type ${Cyan}yes${Off} to reboot now."
    echo -e "Type anything else to quit (if you will restart it yourself)."
    read -r -t 10 answer
    if [[ ${answer,,} != "yes" ]]; then exit; fi

#    # Reboot in the background so user can see DSM's "going down" message
#    reboot &
    if [[ -x /usr/syno/sbin/synopoweroff ]]; then
        /usr/syno/sbin/synopoweroff -r || reboot
    else
        reboot
    fi
}

reloadmsg(){ 
    # Reload browser prompt
    echo -e "\nFinished"
    echo -e "\nIf you have DSM open in a browser you need to"
    echo "refresh the browser window or tab."
    exit
}


#----------------------------------------------------------
# Restore changes from backup file

compare_md5(){ 
    # $1 is file 1
    # $2 is file 2
    if [[ -f "$1" ]] && [[ -f "$2" ]]; then
        if [[ $(md5sum -b "$1" | awk '{print $1}') == $(md5sum -b "$2" | awk '{print $1}') ]];
        then
            return 0
        else
            return 1
        fi
    else
        restoreerr=$((restoreerr+1))
        return 2
    fi
}

if [[ $restore == "yes" ]]; then
    echo ""
    if [[ -f ${synoinfo}.bak ]] || [[ -f ${libhw}.bak ]] ||\
        [[ -f ${strgmgr}.${storagemgrver} ]]; then

        # Restore synoinfo.conf from backup
        if [[ -f ${synoinfo}.bak ]]; then
            keyvalues=("support_btrfs_dedupe" "support_tiny_btrfs_dedupe")
            for v in "${!keyvalues[@]}"; do
                defaultval="$(get_key_value ${synoinfo}.bak "${keyvalues[v]}")"
                if [[ -z $defaultval ]]; then defaultval="no"; fi
                currentval="$(get_key_value ${synoinfo} "${keyvalues[v]}")"
                if [[ $currentval != "$defaultval" ]]; then
                    if synosetkeyvalue "$synoinfo" "${keyvalues[v]}" "$defaultval";
                    then
                        restored="yes"
                        echo "Restored ${keyvalues[v]} = $defaultval"
                    fi
                fi
                synosetkeyvalue "$synoinfo2" "${keyvalues[v]}" "$defaultval"
            done
        fi

        # Restore storage_panel.js from backup
        if [[ -f "${strgmgr}.$storagemgrver" ]]; then
            string1="(SYNO.SDS.StorageUtils.supportBtrfsDedupe)"
            string2="(SYNO.SDS.StorageUtils.supportBtrfsDedupe&&e.dedup_info.show_config_btn)"

            if grep -o "$string1" "${strgmgr}" >/dev/null; then
                # Restore string in file
                sed -i "s/${string1}/${string2/&&/\\&\\&}/g" "$strgmgr"

                # Check we restored string in file
                if grep -o "string2" "${strgmgr}" >/dev/null; then
                    restored="yes"
                    echo "Restored $(basename -- "$strgmgr")"
                else
                    restoreerr=1
                    echo -e "${Error}ERROR${Off} Failed to restore $(basename -- "$strgmgr")!"
                fi
            fi
        else
            echo "No backup of $(basename -- "$strgmgr") found."
        fi

        if [[ -f "${libhw}.bak" ]]; then
            # Check if backup libhwcontrol size matches
            # in case backup is from previous DSM version
            filesize=$(wc -c "${libhw}" | awk '{print $1}')
            filebaksize=$(wc -c "${libhw}.bak" | awk '{print $1}')
            if [[ ! $filesize -eq "$filebaksize" ]]; then
                echo -e "${Yellow}WARNING Backup file size is different to file!${Off}"
                echo "Do you want to restore this backup? [yes/no]:"
                read -r -t 20 answer
                if [[ $answer != "yes" ]]; then
                    exit
                fi
            fi
            # Restore from backup
            if ! compare_md5 "$libhw".bak "$libhw"; then
                if cp -p "$libhw".bak "$libhw" ; then
                    restored="yes"
                    reboot="yes"
                    echo "Restored $(basename -- "$libhw")"
                else
                    restoreerr=1
                    echo -e "${Error}ERROR${Off} Failed to restore $(basename -- "$libhw")!"
                fi
            fi
        else
            echo "No backup of $(basename -- "$libhw") found."
        fi

        if [[ -z $restoreerr ]]; then
            if [[ $restored == "yes" ]]; then
                echo -e "\nRestore successful."
                reloadmsg
            else
                echo -e "Nothing to restore."
            fi
        fi

        if [[ $reboot == "yes" ]]; then
            rebootmsg
        fi
    else
        echo -e "No backups to restore from."
    fi
    exit
fi



#----------------------------------------------------------
# Check NAS has enough memory

if [[ $restore != "yes" ]] && [[ $skip != "yes" ]]; then
    IFS=$'\n' read -r -d '' -a array < <(dmidecode -t memory | grep -E "[Ss]ize: [0-9]+ [MG]{1}[B]{1}$")
    if [[ ${#array[@]} -gt "0" ]]; then
        num="0"
        while [[ $num -lt "${#array[@]}" ]]; do
            memcheck=$(printf %s "${array[num]}" | awk '{print $1}')
            if [[ ${memcheck,,} == "size:" ]]; then
                ramsize=$(printf %s "${array[num]}" | awk '{print $2}')
                bytes=$(printf %s "${array[num]}" | awk '{print $3}')
                if [[ $ramsize =~ ^[0-9]+$ ]]; then  # Check $ramsize is numeric
                    if [[ $bytes == "GB" ]]; then    # DSM 7.2 dmidecode returned GB
                        ramsize=$((ramsize * 1024))  # Convert to MB
                    fi
                    if [[ $ramtotal ]]; then
                        ramtotal=$((ramtotal +ramsize))
                    else
                        ramtotal="$ramsize"
                    fi
                fi
            fi
            num=$((num +1))
        done

        ramgb=$((ramtotal / 1024))

        if [[ $storagemgrver ]]; then
            # Only DSM 7.2.1 and later supports tiny dedupe
            if [[ $tiny == "yes" ]] || [[ $ramtotal -lt 16384 ]]; then
                ramneeded="4096"  # Tiny dedupe only needs 4GB ram
                tiny="yes"
            else
                ramneeded="16384"  # Needs 16GB ram
                tiny=""
            fi
        else
            ramneeded="16384"  # Needs 16GB ram
            tiny=""
        fi

        if [[ $ramtotal -lt "$ramneeded" ]]; then
            ding
            echo -e "\n${Error}ERROR${Off} Not enough memory installed for deduplication: $ramgb GB"
            exit 1
        else
            echo -e "\nNAS has $ramgb GB of memory."
        fi
    else
        ding
        echo -e "\n${Error}ERROR${Off} Unable to determine the amount of installed memory!"
        exit 1
    fi
fi


#----------------------------------------------------------
# Edit libhwcontrol.so.1

findbytes(){ 
    # Get decimal position of matching hex string
    match=$(od -v -t x1 "$1" |
    sed 's/[^ ]* *//' |
    tr '\012' ' ' |
    grep -b -i -o "$hexstring" |
    #grep -b -i -o "$hexstring ".. |
    cut -d ':' -f 1 |
    xargs -I % expr % / 3)

    # Convert decimal position of matching hex string to hex
    array=("$match")
    if [[ ${#array[@]} -gt "1" ]]; then
        num="0"
        while [[ $num -lt "${#array[@]}" ]]; do
            poshex=$(printf "%x" "${array[$num]}")
            if [[ $debug == "yes" ]]; then
                echo "${array[$num]} = $poshex"  # debug
            fi

            seek="${array[$num]}"
            xxd=$(xxd -u -l 12 -s "$seek" "$1")
            #echo "$xxd"  # debug
            if [[ $debug == "yes" ]]; then
                printf %s "$xxd" | cut -d" " -f1-7
            else
                printf %s "$xxd" | cut -d" " -f1-7 >/dev/null
            fi
            bytes=$(printf %s "$xxd" | cut -d" " -f6)
            #echo "$bytes"  # debug

            num=$((num +1))
        done
    elif [[ -n $match ]]; then
        poshex=$(printf "%x" "$match")
        if [[ $debug == "yes" ]]; then
            echo "$match = $poshex"  # debug
        fi

        seek="$match"
        xxd=$(xxd -u -l 12 -s "$seek" "$1")
        #echo "$xxd"  # debug
        if [[ $debug == "yes" ]]; then
            printf %s "$xxd" | cut -d" " -f1-7
        else
            printf %s "$xxd" | cut -d" " -f1-7 >/dev/null
        fi
        bytes=$(printf %s "$xxd" | cut -d" " -f6)
        #echo "$bytes"  # debug
    else
        bytes=""
    fi
}


# Check value in file and backup file
if [[ $check == "yes" ]]; then
    err=0

    # Check if deduplication enabled in synoinfo.conf
    sbd=support_btrfs_dedupe
    stbd=support_tiny_btrfs_dedupe
    setting="$(get_key_value "$synoinfo" ${sbd})"
    setting2="$(get_key_value "$synoinfo" ${stbd})"
#    if [[ $tiny != "yes" ]] || [[ $ramtotal -lt 16384 ]]; then
        if [[ $setting == "yes" ]]; then
            echo -e "\nBtrfs Data Deduplication is ${Cyan}enabled${Off}."
        else
            echo -e "\nBtrfs Data Deduplication is ${Cyan}not${Off} enabled."
        fi
#    else
        if [[ $setting2 == "yes" ]]; then
            echo -e "\nTiny Btrfs Data Deduplication is ${Cyan}enabled${Off}."
        else
            echo -e "\nTiny Btrfs Data Deduplication is ${Cyan}not${Off} enabled."
        fi
#    fi

    # DSM 7.2.1 only and only if --hdd option used
    # Dedupe config button for HDDs and 2.5 inch SSDs in DSM 7.2.1
    if [[ -f "$strgmgr" ]] && [[ $hdd == "yes" ]]; then
        # StorageManager package is installed and --hdd option used
        if ! grep '&&e.dedup_info.show_config_btn' "$strgmgr" >/dev/null; then
            echo -e "\nDedupe config menu for HDDs and 2.5\" SSDs already enabled."
        else
            echo -e "\nDedupe config menu for HDDs and 2.5\" SSDs is ${Cyan}not${Off} enabled."
        fi
    fi

    # Check value in file
    echo -e "\nChecking non-Synology drive supported."
    hexstring="80 3E 00 B8 01 00 00 00 90 90 48 8B"
    findbytes "$libhw"
    if [[ $bytes == "9090" ]]; then
        echo -e "File is already edited."
    else
        hexstring="80 3E 00 B8 01 00 00 00 75 2. 48 8B"
        findbytes "$libhw"
        if [[ $bytes =~ "752"[0-9] ]]; then
            echo -e "File is ${Cyan}not${Off} edited."
        else
            echo -e "${Red}hex string not found!${Off}"
            err=1
        fi
    fi

    # Check value in backup file
    if [[ -f ${libhw}.bak ]]; then
        echo -e "\nChecking value in backup file."
        hexstring="80 3E 00 B8 01 00 00 00 75 2. 48 8B"
        findbytes "${libhw}.bak"
        if [[ $bytes =~ "752"[0-9] ]]; then
            echo -e "Backup file is okay."
        else
            hexstring="80 3E 00 B8 01 00 00 00 90 90 48 8B"
            findbytes "${libhw}.bak"
            if [[ $bytes == "9090" ]]; then
                echo -e "${Red}Backup file has been edited!${Off}"
            else
                echo -e "${Red}hex string not found!${Off}"
                err=1
            fi
        fi
    else
        echo "No backup file found."
    fi

    exit "$err"
fi


#----------------------------------------------------------
# Backup libhwcontrol

if [[ ! -f ${libhw}.bak ]]; then
    if cp -p "$libhw" "$libhw".bak ; then
        echo "Backup successful."
    else
        ding
        echo -e "${Error}ERROR${Off} Backup failed!"
        exit 1
    fi
else
    # Check if backup size matches file size
    filesize=$(wc -c "$libhw" | awk '{print $1}')
    filebaksize=$(wc -c "${libhw}.bak" | awk '{print $1}')
    if [[ ! $filesize -eq "$filebaksize" ]]; then
        echo -e "${Yellow}WARNING Backup file size is different to file!${Off}"
        echo "Maybe you've updated DSM since last running this script?"
        echo "Renaming file.bak to file.bak.old"
        mv "${libhw}.bak" "$libhw".bak.old
        if cp -p "$libhw" "$libhw".bak ; then
            echo "Backup successful."
        else
            ding
            echo -e "${Error}ERROR${Off} Backup failed!"
            exit 1
        fi
    #else
    #    echo "$(basename -- "$libhw") already backed up."
    fi
fi


#----------------------------------------------------------
# Edit libhwcontrol

#echo -e "\nChecking $(basename -- "$libhw")."

# Check if the file is already edited
hexstring="80 3E 00 B8 01 00 00 00 90 90 48 8B"
findbytes "$libhw"
if [[ $bytes == "9090" ]]; then
    #echo -e "\n$(basename -- "$libhw") already edited."
    echo -e "\nNon-Synology drive support already enabled."
else
    # Check if the file is okay for editing
    hexstring="80 3E 00 B8 01 00 00 00 75 2. 48 8B"
    findbytes "$libhw"
    if ! [[ $bytes =~ "752"[0-9] ]]; then
        ding
        echo -e "\n${Red}hex string not found!${Off}"
        exit 1
    fi

    # Replace bytes in file
    posrep=$(printf "%x\n" $((0x${poshex}+8)))
    if ! printf %s "${posrep}: 9090" | xxd -r - "$libhw"; then
        ding
        echo -e "${Error}ERROR${Off} Failed to edit $(basename -- "$libhw")!"
        exit 1
    else
        # Check if libhwcontrol.so.1 was successfully edited
        #echo -e "\nChecking if file was successfully edited."
        hexstring="80 3E 00 B8 01 00 00 00 90 90 48 8B"
        findbytes "$libhw"
        if [[ $bytes == "9090" ]]; then
            #echo -e "File successfully edited."
            echo -e "\nEnabled non-Synology drive support."
            #echo -e "\n${Cyan}You can now enable data deduplication"\
            #    "pool in Storage Manager.${Off}"
            reboot="yes"
        fi
    fi
fi


#------------------------------------------------------------------------------
# Edit /etc.defaults/synoinfo.conf

# Backup synoinfo.conf if needed
if [[ ! -f ${synoinfo}.bak ]]; then
    if cp -p "$synoinfo" "$synoinfo.bak"; then
        echo -e "\nBacked up $(basename -- "$synoinfo")" >&2
    else
        ding
        echo -e "\n${Error}ERROR 5${Off} Failed to backup $(basename -- "$synoinfo")!"
        exit 1
    fi
fi

enabled=""
sbd=support_btrfs_dedupe
stbd=support_tiny_btrfs_dedupe

# Enable dedupe support if needed
setting="$(get_key_value "$synoinfo" ${sbd})"
if [[ $tiny != "yes" ]]; then
    if [[ ! $setting ]] || [[ $setting == "no" ]]; then
        if [[ -n $sbd ]]; then
            synosetkeyvalue "$synoinfo" "$sbd" yes
            synosetkeyvalue "$synoinfo2" "$sbd" yes
            enabled="yes"
        fi
    elif [[ $setting == "yes" ]]; then
        echo -e "\nBtrfs Data Deduplication already enabled."
    fi

    # Disable support_tiny_btrfs_dedupe
    if [[ $enabled == "yes" ]]; then
        if grep "$stbd" "$synoinfo" >/dev/null; then
            synosetkeyvalue "$synoinfo" "$stbd" no
        fi
        if grep "$stbd" "$synoinfo2" >/dev/null; then
            synosetkeyvalue "$synoinfo2" "$stbd" no
        fi
    fi
fi

# Enable tiny dedupe support if needed
setting="$(get_key_value "$synoinfo" ${stbd})"
if [[ $tiny == "yes" ]]; then
    if [[ ! $setting ]] || [[ $setting == "no" ]]; then
        if [[ -n $stbd ]]; then
            synosetkeyvalue "$synoinfo" "$stbd" yes
            synosetkeyvalue "$synoinfo2" "$stbd" yes
            enabled="yes"
        fi
    elif [[ $setting == "yes" ]]; then
        echo -e "\nTiny Btrfs Data Deduplication already enabled."
    fi

    # Disable support_btrfs_dedupe
    if [[ $enabled == "yes" ]]; then
        if grep "$sbd" "$synoinfo" >/dev/null; then
            synosetkeyvalue "$synoinfo" "$sbd" no
        fi
        if grep "$sbd" "$synoinfo2" >/dev/null; then
            synosetkeyvalue "$synoinfo2" "$sbd" no
        fi
    fi
fi


# Check if we enabled deduplication
setting="$(get_key_value "$synoinfo" ${sbd})"
setting2="$(get_key_value "$synoinfo" ${stbd})"
if [[ $enabled == "yes" ]]; then
    if [[ $tiny != "yes" ]]; then
        if [[ $setting == "yes" ]]; then
            echo -e "\nEnabled Btrfs Data Deduplication."
            reload="yes"
        else
            ding
            echo -e "\n${Error}ERROR${Off} Failed to enable Btrfs Data Deduplication!"
        fi
    else
        if [[ $setting2 == "yes" ]]; then
            echo -e "\nEnabled Tiny Btrfs Data Deduplication."
            reload="yes"
        else
            ding
            echo -e "\n${Error}ERROR${Off} Failed to enable Tiny Btrfs Data Deduplication!"
        fi
    fi
fi


#------------------------------------------------------------------------------
# Edit /var/packages/StorageManager/target/ui/storage_panel.js

# Enable dedupe config button for HDDs in DSM 7.2.1
if [[ -f "$strgmgr" ]] && [[ $hdd == "yes" ]]; then
    # StorageManager package is installed
    if grep '&&e.dedup_info.show_config_btn' "$strgmgr" >/dev/null; then
        # Backup storage_panel.js"
        storagemgrver="$(synopkg version StorageManager)"
        echo ""
        if [[ ! -f "${strgmgr}.$storagemgrver" ]]; then
            if cp -p "$strgmgr" "${strgmgr}.$storagemgrver"; then
                echo -e "Backed up $(basename -- "$strgmgr")"
            else
                ding
                echo -e "${Error}ERROR${Off} Failed to backup $(basename -- "$strgmgr")!"
            fi
        fi

        sed -i 's/&&e.dedup_info.show_config_btn//g' "$strgmgr"
        # Check if we edited file
        if ! grep '&&e.dedup_info.show_config_btn' "$strgmgr" >/dev/null; then
            echo -e "Enabled dedupe config menu for HDDs and 2.5\" SSDs."
            reload="yes"
        else
            ding
            echo -e "${Error}ERROR${Off} Failed to enable dedupe config menu for HDDs and 2.5\" SSDs!"
        fi
    else
        echo -e "\nDedupe config menu for HDDs and 2.5\" SSDs already enabled."
    fi
fi


#----------------------------------------------------------
# Finished

if [[ $reboot == "yes" ]]; then
    rebootmsg
elif [[ $reload == "yes" ]]; then
    reloadmsg
else
    echo -e "\nFinished"
fi

exit


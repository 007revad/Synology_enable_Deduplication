#!/usr/bin/env bash
#------------------------------------------------------------------------------
# Enables data deduplication with non-Synology SSDs and unsupported NAS models
#
# Github: https://github.com/007revad/Synology_enable_Deduplication
# Script verified at https://www.shellcheck.net/
# Tested on DSM 7.2 beta and 7.1.1
#
# To run in a shell (replace /volume1/scripts/ with path to script):
# sudo /volume1/scripts/syno_dedupe.sh
#------------------------------------------------------------------------------

scriptver="v1.0.9"
script=Synology_enable_Deduplication
repo="007revad/Synology_enable_Deduplication"

# Check BASH variable is is non-empty and posix mode is off, else abort with error.
[ "$BASH" ] && ! shopt -qo posix || {
    printf \\a
    printf >&2 "This is a bash script, don't run it with sh\n"
    exit 1
}

#echo -e "bash version: $(bash --version | head -1 | cut -d' ' -f4)\n"  # debug

# Shell Colors
#Black='\e[0;30m'   # ${Black}
Red='\e[0;31m'      # ${Red}
#Green='\e[0;32m'    # ${Green}
Yellow='\e[0;33m'   # ${Yellow}
#Blue='\e[0;34m'    # ${Blue}
#Purple='\e[0;35m'  # ${Purple}
Cyan='\e[0;36m'     # ${Cyan}
#White='\e[0;37m'   # ${White}
Error='\e[41m'      # ${Error}
Off='\e[0m'         # ${Off}

ding(){
    printf \\a
}

usage(){
    cat <<EOF
$script $scriptver - by 007revad

Usage: $(basename "$0") [options]

Options:
  -c, --check      Check value in file and backup file
  -r, --restore    Restore backup to undo changes
  -h, --help       Show this help message
  -v, --version    Show the script version
  
EOF
}


scriptversion(){
    cat <<EOF
$script $scriptver - by 007revad

See https://github.com/$repo
EOF
}


# Save options used
#args="$@"


# Check for flags with getopt
if options="$(getopt -o abcdefghijklmnopqrstuvwxyz0123456789 -a \
    -l check,restore,help,version,log,debug -- "$@")"; then
    eval set -- "$options"
    while true; do
        case "${1,,}" in
            -c|--check)         # Check value in file and backup file
                check=yes
                ;;
            -r|--restore)       # Restore backup to undo changes
                restore=yes
                ;;
            -h|--help)          # Show usage options
                usage
                exit
                ;;
            -v|--version)       # Show script version
                scriptversion
                exit
                ;;
            -l|--log)           # Log
                log=yes
                ;;
            -d|--debug)         # Show and log debug info
                debug=yes
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


# Check script is running as root
if [[ $( whoami ) != "root" ]]; then
    ding
    echo -e "${Error}ERROR${Off} This script must be run as root or sudo!"
    exit 1
fi

# Get DSM major version
dsm=$(get_key_value /etc.defaults/VERSION majorversion)
if [[ $dsm -lt "7" ]]; then
    ding
    echo "This script only works for DSM 7."
    exit 1
fi


# Check bc command exists
if ! which bc >/dev/null ; then
    echo -e "${Error}ERROR ${Off} bc command not found!\n"
    #echo -e "This script needs the bc command, which is not included in DSM."
    echo -e "Please install ${Cyan}SynoCli misc. Tools${Off} from SynoCommunity."
    echo -e "  1. Package Center > Settings > Package Sources > Add"
    echo -e "  2. Name: ${Cyan}SynoCommunity${Off}"
    echo -e "  3. Location: ${Cyan}https://packages.synocommunity.com/${Off}"
    echo -e "  4. Click OK and OK again."
    echo -e "  5. Click Community on the left."
    echo -e "  6. Install ${Cyan}SynoCli misc. Tools${Off}\n"
    exit
fi


# Show script version
#echo -e "$script $scriptver\ngithub.com/$repo\n"
echo "$script $scriptver"

# Get NAS model
model=$(cat /proc/sys/kernel/syno_hw_version)

# Get DSM full version
productversion=$(get_key_value /etc.defaults/VERSION productversion)
buildphase=$(get_key_value /etc.defaults/VERSION buildphase)
buildnumber=$(get_key_value /etc.defaults/VERSION buildnumber)
smallfixnumber=$(get_key_value /etc.defaults/VERSION smallfixnumber)

# Show DSM full version and model
if [[ $buildphase == GM ]]; then buildphase=""; fi
if [[ $smallfixnumber -gt "0" ]]; then smallfix="-$smallfixnumber"; fi
echo -e "$model DSM $productversion-$buildnumber$smallfix $buildphase\n"

# Show options used
#echo "Using options: $args"


#------------------------------------------------------------------------------
# Check latest release with GitHub API

get_latest_release() {
    # Curl timeout options:
    # https://unix.stackexchange.com/questions/94604/does-curl-have-a-timeout
    curl --silent -m 10 --connect-timeout 5 \
        "https://api.github.com/repos/$1/releases/latest" |
    grep '"tag_name":' |          # Get tag line
    sed -E 's/.*"([^"]+)".*/\1/'  # Pluck JSON value
}

tag=$(get_latest_release "$repo")
shorttag="${tag:1}"
#scriptpath=$(dirname -- "$0")

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
#echo "Script location: $scriptpath"  # debug


if ! printf "%s\n%s\n" "$tag" "$scriptver" |
        sort --check --version-sort &> /dev/null ; then
    echo -e "${Cyan}There is a newer version of this script available.${Off}"
    echo -e "Current version: ${scriptver}\nLatest version:  $tag"
    if [[ -f $scriptpath/$script-$shorttag.tar.gz ]]; then
        # They have the latest version tar.gz downloaded but are using older version
        echo "https://github.com/$repo/releases/latest"
        sleep 10
    elif [[ -d $scriptpath/$script-$shorttag ]]; then
        # They have the latest version extracted but are using older version
        echo "https://github.com/$repo/releases/latest"
        sleep 10
    else
        echo -e "${Cyan}Do you want to download $tag now?${Off} [y/n]"
        read -r -t 30 reply
        if [[ ${reply,,} == "y" ]]; then
            if cd /tmp; then
                url="https://github.com/$repo/archive/refs/tags/$tag.tar.gz"
                if ! curl -LJO -m 30 --connect-timeout 5 "$url";
                then
                    echo -e "${Error}ERROR ${Off} Failed to download"\
                        "$script-$shorttag.tar.gz!"
                else
                    if [[ -f /tmp/$script-$shorttag.tar.gz ]]; then
                        # Extract tar file to /tmp/<script-name>
                        if ! tar -xf "/tmp/$script-$shorttag.tar.gz" -C "/tmp"; then
                            echo -e "${Error}ERROR ${Off} Failed to"\
                                "extract $script-$shorttag.tar.gz!"
                        else
                            # Copy new script sh files to script location
                            if ! cp -p "/tmp/$script-$shorttag/"*.sh "$scriptpath"; then
                                copyerr=1
                                echo -e "${Error}ERROR ${Off} Failed to copy"\
                                    "$script-$shorttag .sh file(s) to:\n $scriptpath"
                            else                   
                                # Set permsissions on CHANGES.txt
                                if ! chmod 744 "$scriptpath/"*.sh ; then
                                    permerr=1
                                    echo -e "${Error}ERROR ${Off} Failed to set permissions on:"
                                    echo "$scriptpath *.sh file(s)"
                                fi
                            fi

                            # Copy new CHANGES.txt file to script location
                            if ! cp -p "/tmp/$script-$shorttag/CHANGES.txt" "$scriptpath"; then
                                copyerr=1
                                echo -e "${Error}ERROR ${Off} Failed to copy"\
                                    "$script-$shorttag/CHANGES.txt to:\n $scriptpath"
                            else                   
                                # Set permsissions on CHANGES.txt
                                if ! chmod 744 "$scriptpath/CHANGES.txt"; then
                                    permerr=1
                                    echo -e "${Error}ERROR ${Off} Failed to set permissions on:"
                                    echo "$scriptpath/CHANGES.txt"
                                fi
                            fi

                            # Delete downloaded .tar.gz file
                            if ! rm "/tmp/$script-$shorttag.tar.gz"; then
                                #delerr=1
                                echo -e "${Error}ERROR ${Off} Failed to delete"\
                                    "downloaded /tmp/$script-$shorttag.tar.gz!"
                            fi

                            # Delete extracted tmp files
                            if ! rm -r "/tmp/$script-$shorttag"; then
                                #delerr=1
                                echo -e "${Error}ERROR ${Off} Failed to delete"\
                                    "downloaded /tmp/$script-$shorttag!"
                            fi

                            # Notify of success (if there were no errors)
                            if [[ $copyerr != 1 ]] && [[ $permerr != 1 ]]; then
                                echo -e "\n$tag and changes.txt downloaded to:"\
                                    "$scriptpath"
                                echo -e "${Cyan}Do you want to stop this script"\
                                    "so you can run the new one?${Off} [y/n]"
                                read -r reply
                                if [[ ${reply,,} == "y" ]]; then exit; fi
                            fi
                        fi
                    else
                        echo -e "${Error}ERROR ${Off}"\
                            "/tmp/$script-$shorttag.tar.gz not found!"
                        #ls /tmp | grep "$script"  # debug
                    fi
                fi
            else
                echo -e "${Error}ERROR ${Off} Failed to cd to /tmp!"
            fi
        fi
    fi
fi

rebootmsg(){
    # Reboot prompt
    echo -e "\n${Cyan}The Synology needs to restart.${Off}"
    echo -e "Type ${Cyan}yes${Off} to reboot now."
    echo -e "Type anything else to quit (if you will restart it yourself)."
    read -r -t 10 answer
    if [[ ${answer,,} != "yes" ]]; then exit; fi

    # Reboot in the background so user can see DSM's "going down" message
    reboot &
}


#----------------------------------------------------------
# Check NAS has enough memory

IFS=$'\n' read -r -d '' -a array < <(dmidecode -t memory | grep -i 'size')
if [[ ${#array[@]} -gt "0" ]]; then
    num="0"
    while [[ $num -lt "${#array[@]}" ]]; do
        #ram=$(printf %s "${array[num]}" | cut -d" " -f2)
        ram=$(printf %s "${array[num]}" | awk '{print $2}')
        bytes=$(printf %s "${array[num]}" | awk '{print $3}')
        if [[ $ramtotal ]]; then
            ramtotal=$((ramtotal +ram))
        else
            ramtotal="$ram"
        fi
        num=$((num +1))
    done
    if [[ $bytes == GB ]]; then
        if [[ $ramtotal -lt 16 ]]; then
            ding
            echo -e "${Error}ERROR ${Off} Not enough memory installed for deduplication: $ramtotal GB!"
            exit 1
        fi
    elif [[ $bytes == MB ]]; then
        if [[ $ramtotal -lt 16384 ]]; then
            ding
            echo -e "${Error}ERROR ${Off} Not enough memory installed for deduplication: $ramtotal MB!"
            exit 1
        fi
    else
        ding
        echo -e "${Error}ERROR ${Off} Unable to determine the $bytes of installed memory!"
        exit 1
    fi
else
    ding
    echo -e "${Error}ERROR ${Off} Unable to determine the amount of installed memory!"
    exit 1
fi


#----------------------------------------------------------
# Check file exists

file="/usr/lib/libhwcontrol.so.1"

if [[ ! -f ${file} ]]; then
    ding
    echo -e "${Error}ERROR ${Off} File not found!"
    exit 1
fi


#----------------------------------------------------------
# Restore from backup file

if [[ $restore == "yes" ]]; then
    if [[ -f ${file}.bak ]]; then

        # Check if backup size matches file size
        filesize=$(wc -c "${file}" | awk '{print $1}')
        filebaksize=$(wc -c "${file}.bak" | awk '{print $1}')
        if [[ ! $filesize -eq "$filebaksize" ]]; then
            echo -e "${Yellow}WARNING Backup file size is different to file!${Off}"
            echo "Do you want to restore this backup? [yes/no]:"
            read -r answer
            if [[ $answer != "yes" ]]; then
                exit
            fi
        fi

        # Restore from backup
        if cp "$file".bak "$file" ; then
            echo "Successfully restored from backup."
            rebootmsg
            exit
        else
            ding
            echo -e "${Error}ERROR ${Off} Backup failed!"
            exit 1
        fi
    else
        ding
        echo -e "${Error}ERROR ${Off} Backup file not found!"
        exit 1
    fi
fi


#----------------------------------------------------------
# Backup file

if [[ ! -f ${file}.bak ]]; then
    if cp "$file" "$file".bak ; then
        echo "Backup successful."
    else
        ding
        echo -e "${Error}ERROR ${Off} Backup failed!"
        exit 1
    fi
else
    # Check if backup size matches file size
    filesize=$(wc -c "${file}" | awk '{print $1}')
    filebaksize=$(wc -c "${file}.bak" | awk '{print $1}')
    if [[ ! $filesize -eq "$filebaksize" ]]; then
        echo -e "${Yellow}WARNING Backup file size is different to file!${Off}"
        echo "Maybe you've updated DSM since last running this script?"
        echo "Renaming file.bak to file.bak.old"
        mv "${file}.bak" "$file".bak.old
        if cp "$file" "$file".bak ; then
            echo "Backup successful."
        else
            ding
            echo -e "${Error}ERROR ${Off} Backup failed!"
            exit 1
        fi
    else
        echo "File already backed up."
    fi
fi


#----------------------------------------------------------
# Edit file

findbytes(){
    # Get decimal position of matching hex string
    match=$(od -v -t x1 "$1" |
    sed 's/[^ ]* *//' |
    tr '\012' ' ' |
    grep -b -i -o "$hexstring" |
    #grep -b -i -o "$hexstring ".. |
    sed 's/:.*/\/3/' |
    bc)

    # Convert decimal position of matching hex string to hex
    array=("$match")
    if [[ ${#array[@]} -gt "1" ]]; then
        num="0"
        while [[ $num -lt "${#array[@]}" ]]; do
            poshex=$(printf "%x" "${array[$num]}")
            echo "${array[$num]} = $poshex"  # debug

            seek="${array[$num]}"
            xxd=$(xxd -u -l 12 -s "$seek" "$1")
            #echo "$xxd"  # debug
            printf %s "$xxd" | cut -d" " -f1-7
            bytes=$(printf %s "$xxd" | cut -d" " -f6)
            #echo "$bytes"  # debug

            num=$((num +1))
        done
    elif [[ -n $match ]]; then
        poshex=$(printf "%x" "$match")
        echo "$match = $poshex"  # debug

        seek="$match"
        xxd=$(xxd -u -l 12 -s "$seek" "$1")
        #echo "$xxd"  # debug
        printf %s "$xxd" | cut -d" " -f1-7
        bytes=$(printf %s "$xxd" | cut -d" " -f6)
        #echo "$bytes"  # debug
    else
        bytes=""
    fi
}


# Check value in file and backup file
if [[ $check == "yes" ]]; then
    err=0

    # Check value in file
    echo -e "\nChecking value in file."
    hexstring="80 3E 00 B8 01 00 00 00 90 90 48 8B"
    findbytes "$file"
    if [[ $bytes == "9090" ]]; then
        echo -e "\n${Cyan}File already edited.${Off}"
    else
        hexstring="80 3E 00 B8 01 00 00 00 75 2. 48 8B"
        findbytes "$file"
        if [[ $bytes =~ "752"[0-9] ]]; then
            echo -e "\n${Cyan}File is unedited.${Off}"
        else
            echo -e "\n${Red}hex string not found!${Off}"
            err=1
        fi
    fi

    # Check value in backup file
    if [[ -f ${file}.bak ]]; then
        echo -e "\nChecking value in backup file."
        hexstring="80 3E 00 B8 01 00 00 00 75 2. 48 8B"
        findbytes "${file}.bak"
        if [[ $bytes =~ "752"[0-9] ]]; then
            echo -e "\n${Cyan}Backup file is unedited.${Off}"
        else
            hexstring="80 3E 00 B8 01 00 00 00 90 90 48 8B"
            findbytes "${file}.bak"
            if [[ $bytes == "9090" ]]; then
                echo -e "\n${Red}Backup file has been edited!${Off}"
            else
                echo -e "\n${Red}hex string not found!${Off}"
                err=1
            fi
        fi
    else
        echo "No backup file found."
    fi

    exit "$err"
fi


echo -e "\nChecking file."


# Check if the file is already edited
hexstring="80 3E 00 B8 01 00 00 00 90 90 48 8B"
findbytes "$file"
if [[ $bytes == "9090" ]]; then
    echo -e "\n${Cyan}File already edited.${Off}"
    exit
else

    # Check if the file is okay for editing
    hexstring="80 3E 00 B8 01 00 00 00 75 2. 48 8B"
    findbytes "$file"
    if [[ $bytes =~ "752"[0-9] ]]; then
        echo -e "\nEditing file."
    else
        ding
        echo -e "\n${Red}hex string not found!${Off}"
        exit 1
    fi
fi


# Replace bytes in file
posrep=$(printf "%x\n" $((0x${poshex}+8)))
if ! printf %s "${posrep}: 9090" | xxd -r - "$file"; then
    ding
    echo -e "${Error}ERROR ${Off} Failed to edit file!"
    exit 1
fi


#----------------------------------------------------------
# Check if file was successfully edited

echo -e "\nChecking if file was successfully edited."
hexstring="80 3E 00 B8 01 00 00 00 90 90 48 8B"
findbytes "$file"
if [[ $bytes == "9090" ]]; then
    echo -e "File successfully edited."
    echo -e "\n${Cyan}You can now enabled data deduplication"\
        "pool in Storage Manager.${Off}"
else
    ding
    echo -e "${Error}ERROR ${Off} Failed to edit file!"
    exit 1
fi


#------------------------------------------------------------------------------
# Edit /etc.defaults/synoinfo.conf

# Backup synoinfo.conf if needed
synoinfo="/etc.defaults/synoinfo.conf"
if [[ ! -f ${synoinfo}.bak ]]; then
    if cp "$synoinfo" "$synoinfo.bak"; then
        echo -e "\nBacked up $(basename -- "$synoinfo")" >&2
    else
        ding
        echo -e "\n${Error}ERROR 5${Off} Failed to backup $(basename -- "$synoinfo")!"
        exit 1
    fi
fi


# Enable deduplication support
# Check if dedupe support is enabled
sbd=support_btrfs_dedupe
setting="$(get_key_value "$synoinfo" ${sbd})"
enabled=""
if [[ ! $setting ]]; then
    # Add support_btrfs_dedupe="yes"
    #echo 'support_btrfs_dedupe="yes"' >> "$synoinfo"
    synosetkeyvalue "$synoinfo" "$sbd" yes
    enabled="yes"
elif [[ $setting == "no" ]]; then
    # Change support_btrfs_dedupe="no" to "yes"
    #sed -i "s/${sbd}=\"no\"/${sbd}=\"yes\"/" "$synoinfo"
    synosetkeyvalue "$synoinfo" "$sbd" yes
    enabled="yes"
elif [[ $setting == "yes" ]]; then
    echo -e "\nData Deduplication already enabled."
fi

# Check if we enabled deduplication
setting="$(get_key_value "$synoinfo" ${sbd})"
if [[ $enabled == "yes" ]]; then
    if [[ $setting == "yes" ]]; then
        echo -e "\nEnabled Data Deduplication."
    else
        echo -e "\n${Error}ERROR${Off} Failed to enable Data Deduplication!"
    fi
fi


#----------------------------------------------------------
# Reboot

rebootmsg

exit


# Synology enable Deduplication

<a href="https://github.com/007revad/Synology_enable_Deduplication/releases"><img src="https://img.shields.io/github/release/007revad/Synology_enable_Deduplication.svg"></a>
<a href="https://hits.seeyoufarm.com"><img src="https://hits.seeyoufarm.com/api/count/incr/badge.svg?url=https%3A%2F%2Fgithub.com%2F007revad%2FSynology_enable_Deduplicationh&count_bg=%2379C83D&title_bg=%23555555&icon=&icon_color=%23E7E7E7&title=hits&edge_flat=false"/></a>

### Description

Enable deduplication with non-Synology SSDs and unsupported NAS models

This script will enable creating M.2 storage pools and volumes all from within Storage Manager.

It will work for DSM 7.2 beta and DSM 7.1.1 (and possibly DSM 7.1 and maybe even DSM 7.0). As for which models it will work with, I don't know yet. I do know it does work on models listed by Synology as supported for creating M.2 volumes... but I suspect it will work with any Synology model that has M.2 slots or a PCIe card with M.2 slots.

**Confirmed working on:**

| Model        | DSM version              |
| ------------ |--------------------------|
| RS4021xs+    | DSM 7.1.1-42962 Update 2 |
| DS1821+      | DSM 7.2-64216 Beta       |
| DS1821+      | DSM 7.2-64213 Beta       |
| DS1821+      | DSM 7.1.1-42962 Update 4 |

## Known issues in DSM 7.2-64213 Beta

***DSM 7.2-64216 Beta is okay***

1. You **MUST** let the script reboot the NAS. If you don't then you won't be able to restart the NAS from the DSM UI (it just continues showing "Restarting..." and never actually reboots).
    - If you exit the shell window without letting the script reboot the NAS you can either press the power button on the Synology or log back in via SSH, type **reboot** and press enter.
2. If you go into "Control Panel > Shared Folders" before you've rebooted the Synology the Shared Folders window will be blank.

## Requirements

Because the bc command is not included in DSM you need to install **SynoCli misc. Tools** from SynoCommunity for this script to work.

1. Package Center > Settings > Package Sources > Add
2. Name: SynoCommunity
3. Location: `https://packages.synocommunity.com/`
4. Click OK and OK again.
5. Click Community on the left.
6. Install **SynoCli misc. Tools**

## To run the script
**Note:** Replace /volume1/scripts/ with the path to where the script is located.
Run the script then reboot the Synology:
```YAML
sudo -i /volume1/scripts/syno_enable_dedupe.sh
```

**Options:**
```YAML
  -c, --check      Check value in file and backup file
  -r, --restore    Restore backup to undo changes
  -h, --help       Show this help message
  -v, --version    Show the script version
```

## Screenshots

Here's the result after running the script and rebooting. Note that the DS1821+ is not officially listed as supporting deduplication, and non-Synology SSDs are being used.

<p align="center">After reboot I got some notifications saying the M.2 drives can be managed</p>
<p align="center"><img src="/images/1b-after-reboot.png"></p>

<p align="center">No M2 Storage Pool or Volume yet</p>
<p align="center"><img src="/images/2-no-m2-volume-yet.png"></p>

<p align="center">Non-Synology M.2 drives</p>
<p align="center"><img src="/images/3-non-synology-m2-drives-2.png"></p>

<p align="center">Create Storage Pool 2</p>
<p align="center"><img src="/images/4-create-storage-pool-3.png"></p>

<p align="center">I wonder if RAID 5 and SHR-2 would be available if I had four M.2 drives.</p>

<p align="center">RAID choices including SHR and JBOD</p>
<p align="center"><img src="/images/5-raid-choices-2.png"></p>

<p align="center">Select my non-Synology M.2 drives</p>
<p align="center"><img src="/images/7-select-non-synology-drives-2.png"></p>

<p align="center">We have an SHR M.2 storage pool</p>
<p align="center"><img src="/images/10-we-have-a-m2.storage-pool-2.png"></p>

<p align="center">Create Volume 2</p>
<p align="center"><img src="/images/11-create-volume-3.png"></p>

<p align="center">Finished Creating Volume 2</p>
<p align="center"><img src="/images/13-finished-3.png"></p>


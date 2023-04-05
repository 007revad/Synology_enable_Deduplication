# Synology enable Deduplication

<a href="https://github.com/007revad/Synology_enable_Deduplication/releases"><img src="https://img.shields.io/github/release/007revad/Synology_enable_Deduplication.svg"></a>
<a href="https://hits.seeyoufarm.com"><img src="https://hits.seeyoufarm.com/api/count/incr/badge.svg?url=https%3A%2F%2Fgithub.com%2F007revad%2FSynology_enable_Deduplicationh&count_bg=%2379C83D&title_bg=%23555555&icon=&icon_color=%23E7E7E7&title=hits&edge_flat=false"/></a>

### Description

Enable data deduplication with non-Synology SSDs and unsupported NAS models

It will work for DSM 7.2 beta and DSM 7.1.1 (and possibly DSM 7.1 and maybe even DSM 7.0). As for which models it will work with, I don't know yet. I do know it does work on models not listed by Synology as supported for data deduplication.

**Confirmed working on:**

| Model        | DSM version              |
| ------------ |--------------------------|
| DS3622xs+    | DSM 7.2-64216 Beta       |
| RS4021xs+    | DSM 7.1.1-42962 Update 2 |
| DS1821+      | DSM 7.2-64216 Beta       |
| DS1821+      | <a href=known_issues.md>DSM 7.2-64213 Beta *</a>  |
| DS1821+      | DSM 7.1.1-42962 Update 4 |


## Requirements

- Deduplication requires 16GB of memory or more.
- Deduplication only works on SSD volumes that are formatted in Btrfs.

Because the bc command is not included in DSM you need to install **SynoCli misc. Tools** from SynoCommunity for this script to work.

1. Package Center > Settings > Package Sources > Add
2. Name: SynoCommunity
3. Location: `https://packages.synocommunity.com/`
4. Click OK and OK again.
5. Click Community on the left.
6. Install **SynoCli misc. Tools**

## How to run the script

### Running the script via SSH

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

**Extra Steps:**

To get rid of <a href="images/notification.png">drive database outdated</a> notifications and <a href=images/before_running_syno_hdd_db.png>unrecognised firmware</a> warnings run <a href=https://github.com/007revad/Synology_HDD_db>Synology_HDD_db</a> which will add your drives to DSM's compatibile drive databases, and prevent the drive compatability databases being updated between DSM updates.

```YAML
sudo -i /path-to-script/syno_hdd_db.sh --noupdate
```

### What about DSM updates?

After any DSM update you will need to run this script, and the Synology_HDD_db script again. 

### Schedule the script to run at shutdown

Or you can schedule both Synology_enable_Deduplication and Synology_HDD_db to run when the Synology shuts down, to avoid having to remember to run both scripts after a DSM update.

See <a href=how_to_schedule.md/>How to schedule a script in Synology Task Manager</a>

## Screenshots

Here's the result after running the script and rebooting. Note that the DS1821+ is not officially listed as supporting deduplication, and non-Synology SSDs are being used.

<p align="center">Unsupported NAS model with enough memory</p>
<p align="center"><img src="/images/0_ds1821+.png"></p>

<p align="center">Non-Synology SSDs setup as a volume</p>
<p align="center"><img src="/images/1_ds1821+_dedupe_nvmes.png"></p>

<p align="center">Enable Data Deduplication option available after running this script and rebooting</p>
<p align="center"><img src="/images/3_ds1821+_dedupe_option_enabled.png"></p>

<p align="center">Configure Data Deduplication</p>
<p align="center"><img src="/images/4_ds1821+_dedupe_configure.png"></p>

<p align="center">Deduplication finished notification</p>
<p align="center"><img src="/images/5b_ds1821+_dedupe_notification.png"></p>

<p align="center">Deduplications works.</p>
<p align="center"><img src="/images/6b_ds1821+_dedupe_works.png"></p>


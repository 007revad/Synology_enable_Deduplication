# Synology enable Deduplication

<a href="https://github.com/007revad/Synology_enable_Deduplication/releases"><img src="https://img.shields.io/github/release/007revad/Synology_enable_Deduplication.svg"></a>
<a href="https://hits.seeyoufarm.com"><img src="https://hits.seeyoufarm.com/api/count/incr/badge.svg?url=https%3A%2F%2Fgithub.com%2F007revad%2FSynology_enable_Deduplicationh&count_bg=%2379C83D&title_bg=%23555555&icon=&icon_color=%23E7E7E7&title=views&edge_flat=false"/></a>
[![](https://img.shields.io/static/v1?label=Sponsor&message=%E2%9D%A4&logo=GitHub&color=%23fe8e86)](https://github.com/sponsors/007revad)
[![committers.top badge](https://user-badge.committers.top/australia/007revad.svg)](https://user-badge.committers.top/australia/007revad)

### Description

Enable data deduplication with non-Synology SSDs and unsupported NAS models

- Works for any brand SATA SSD, SAS SSD and M.2 SSD drives.
- Now works for HDDs too.
- Now works for M.2 drives in a PCIe adapter card (E10M20-T1, M2D20, M2D18 or M2D17).
- Works for DSM from 7.01 and later.

It works on [Synology models that do offically support data deduplication](https://kb.synology.com/en-global/DSM/tutorial/Which_models_support_data_deduplication).

It works on other models with one of following [CPU architectures](https://kb.synology.com/en-global/DSM/tutorial/What_kind_of_CPU_does_my_NAS_have): R1000, Geminilake, V1000, Apollolake and some Broadwellnk.

It may work for other Synology NAS models.

Please [leave a comment in this discussion](https://github.com/007revad/Synology_enable_Deduplication/discussions/31) if it works, or doesn't work, for you.

### Confirmed working on

| Model      | CPU Arch    | DSM version                       | Works  | Notes |
|------------|-------------|-----------------------------------|--------|-------|
| DS923+     | R1000       | DSM 7.2-64570 Update 1, 2 and 3   | yes    | |
| DS923+     | R1000       | DSM 7.2-64570                     | yes    | |
| DS3622xs+  | Broadwellnk | DSM 7.2-64570                     | **No** | |
| DS3622xs+  | Broadwellnk | DSM 7.2-64561                     | yes    | |
| DS3622xs+  | Broadwellnk | DSM 7.1.1-42962 Update 1          | **No** | |
| RS4021xs+  | Broadwellnk | DSM 7.2-64570                     | **No** | |
| RS4021xs+  | Broadwellnk | DSM 7.1.1-42962 Update 2          | yes    | |
| DS1821+    | V1000       | DSM 7.2.1-69057 Update 1, 2 and 3 | yes    | |
| DS1821+    | V1000       | DSM 7.2.1-69057                   | yes    | |
| DS1821+    | V1000       | DSM 7.2-64570 Update 1, 2 and 3   | yes    | |
| DS1821+    | V1000       | DSM 7.2-64570                     | yes    | |
| DS1821+    | V1000       | DSM 7.2-64561                     | yes    | |
| DS1821+    | V1000       | DSM 7.1.1-42962 Update 4          | yes    | |
| DS1621xs+  | Broadwellnk | DSM 7.2-64570 Update 3            | yes    | |
| DS1621xs+  | Broadwellnk | DSM 7.2-64570                     | yes    | |
| DS920+     | Geminilake  | DSM 7.2-64570 Update 1, 2 and 3   | yes    | |
| DS920+     | Geminilake  | DSM 7.2-64570                     | yes    | |
| DS720+     | Geminilake  | DSM 7.2-64570 Update 1, 2 and 3   | yes    | |
| DS720+     | Geminilake  | DSM 7.2-64570                     | yes    | |
| DS1019+    | Apollolake  | DSM 7.2-64570 Update 1, 2 and 3   | yes    | |
| DS1019+    | Apollolake  | DSM 7.2-64570                     | yes    | |
| DS1618+    | Denverton   |                                   | **No** | Denverton not supported |
| DS918+     | Apollolake  | DSM 7.2-64570 Update 1, 2 and 3   | yes    | |
| DS918+     | Apollolake  | DSM 7.2-64570                     | yes    | |
| DS3617xs   | Broadwell   |                                   | **No** | Broadwell not supported |

## Requirements

- Deduplication requires 16GB of memory or more.
- Deduplication only works on SSD volumes that are formatted in Btrfs.
- The SSD volume needs **usage detail analysis** enabled. See [Enable and View Usage Details](https://kb.synology.com/en-global/DSM/help/DSM/StorageManager/volume_view_usage?version=7).
- SSD drive(s) in drive bays or internal M.2 slot(s).

## Download the script

See <a href=images/how_to_download_generic.png/>How to download the script</a> for the easiest way to download the script.

Do ***NOT*** save the script to a M.2 volume. After a DSM or Storage Manager update the M.2 volume won't be available until after the script has run.

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

See <a href=how_to_schedule.md/>How to schedule a script in Synology Task Scheduler</a>

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


# Synology enable Deduplication

<a href="https://github.com/007revad/Synology_enable_Deduplication/releases"><img src="https://img.shields.io/github/release/007revad/Synology_enable_Deduplication.svg"></a>
<a href="https://hits.seeyoufarm.com"><img src="https://hits.seeyoufarm.com/api/count/incr/badge.svg?url=https%3A%2F%2Fgithub.com%2F007revad%2FSynology_enable_Deduplicationh&count_bg=%2379C83D&title_bg=%23555555&icon=&icon_color=%23E7E7E7&title=views&edge_flat=false"/></a>
[![](https://img.shields.io/static/v1?label=Sponsor&message=%E2%9D%A4&logo=GitHub&color=%23fe8e86)](https://github.com/sponsors/007revad)
[![committers.top badge](https://user-badge.committers.top/australia/007revad.svg)](https://user-badge.committers.top/australia/007revad)

### Description

Enable data deduplication with non-Synology SSDs and unsupported NAS models

- Works for any brand SATA SSD, SAS SSD and M.2 SSD drives in DSM 7.01 and later.
- Now works for HDDs in DSM 7.2.1 and later.
- Now works for M.2 drives in a PCIe adapter card (E10M20-T1, M2D20, M2D18 or M2D17) in DSM 7.2.1 and later.

It works on [Synology models that do offically support data deduplication](https://kb.synology.com/en-global/DSM/tutorial/Which_models_support_data_deduplication).

It works in DSM 7.2.1 on models with one of following [CPU architectures](https://kb.synology.com/en-global/DSM/tutorial/What_kind_of_CPU_does_my_NAS_have): V1000, R1000, Geminilake, Broadwellnkv2, Broadwellnk, Broadwell, Purley and Epyc7002.

It works in DSM 7.0.1 to 7.2 on models with one of following [CPU architectures](https://kb.synology.com/en-global/DSM/tutorial/What_kind_of_CPU_does_my_NAS_have): V1000, R1000, Geminilake, Apollolake and some Broadwellnk.

Please [leave a comment in this discussion](https://github.com/007revad/Synology_enable_Deduplication/discussions/31) if it works, or doesn't work, for you.

### Requirements

- Btrfs Tiny Data Deduplication requires 4GB of memory or more.
- Btrfs Data Deduplication requires 16GB of memory or more.
- The volume needs **Usage detail analysis** enabled. See [Enable and View Usage Details](https://kb.synology.com/en-global/DSM/help/DSM/StorageManager/volume_view_usage?version=7).


### Works in DSM 7.2.1 for the following models

<details>
  <summary>Click here to see list</summary>

| Model      | CPU Arch      | DSM version                   | Works  | Notes |
|------------|---------------|-------------------------------|--------|-------|
| DS224+     | Geminilake    | DSM 7.2.1-69057 Update 1 to 3 | yes    | Use v1.2.14 or later |
| DS1823xs+  | V1000         | DSM 7.2.1-69057 Update 1 to 4 | yes    | Use v1.2.14 or later |
| DS923+     | R1000         | DSM 7.2.1-69057 Update 1 to 3 | yes    | Use v1.2.14 or later |
| DS723+     | R1000         | DSM 7.2.1-69057 Update 1 to 3 | yes    | Use v1.2.14 or later |
| DS423+     | Geminilake    | DSM 7.2.1-69057 Update 1 to 3 | yes    | Use v1.2.14 or later |
| DS3622xs+  | Broadwellnk   | DSM 7.2.1-69057 Update 1 to 4 | yes    | Use v1.2.14 or later |
| DS2422xs+  | V1000         | DSM 7.2.1-69057 Update 1 to 4 | yes    | Use v1.2.14 or later |
| DS1821+    | V1000         | DSM 7.2.1-69057 Update 1 to 3 | yes    | Use v1.2.14 or later |
| DS1621+    | V1000         | DSM 7.2.1-69057 Update 1 to 3 | yes    | Use v1.2.14 or later |
| DS1621xs+  | Broadwellnk   | DSM 7.2.1-69057 Update 1 to 3 | yes    | Use v1.2.14 or later |
| DS1522+    | R1000         | DSM 7.2.1-69057 Update 1 to 3 | yes    | Use v1.2.14 or later |
| DS1520+    | Geminilake    | DSM 7.2.1-69057 Update 1 to 3 | yes    | Use v1.2.14 or later |
| DS420+     | Geminilake    | DSM 7.2.1-69057 Update 1 to 3 | yes    | Use v1.2.14 or later |
| DS220+     | Geminilake    | DSM 7.2.1-69057 Update 1 to 3 | yes    | Use v1.2.14 or later |
| DS3018xs   | Broadwellnk   | DSM 7.2.1-69057 Update 1 to 3 | yes    | Use v1.2.14 or later |
| DS3017xsII | Broadwell     | DSM 7.2.1-69057 Update 1 to 3 | yes    | Use v1.2.14 or later |
| DS3017xs   | Broadwell     | DSM 7.2.1-69057 Update 1 to 3 | yes    | Use v1.2.14 or later |
| | | | | |
| DVA1622    | Geminilake    | DSM 7.2.1-69057 Update 1 to 3 | yes    | Use v1.2.14 or later |
| | | | | |
| RS2423xs+  | V1000         | DSM 7.2.1-69057 Update 1 to 3 | yes    | Use v1.2.14 or later |
| RS822xs+   | V1000         | DSM 7.2.1-69057 Update 1 to 3 | yes    | Use v1.2.14 or later |
| RS422xs+   | R1000         | DSM 7.2.1-69057 Update 1 to 3 | yes    | Use v1.2.14 or later |
| RS4021xs+  | Broadwellnk   | DSM 7.2.1-69057 Update 1 to 3 | yes    | Use v1.2.14 or later |
| RS3621RPxs | Broadwellnk   | DSM 7.2.1-69057 Update 1 to 3 | yes    | Use v1.2.14 or later |
| RS3621xs+  | Broadwellnk   | DSM 7.2.1-69057 Update 1 to 3 | yes    | Use v1.2.14 or later |
| RS2821RPxs+ | V1000        | DSM 7.2.1-69057 Update 1 to 3 | yes    | Use v1.2.14 or later |
| RS2421xs+  | V1000         | DSM 7.2.1-69057 Update 1 to 3 | yes    | Use v1.2.14 or later |
| RS1221xs+  | V1000         | DSM 7.2.1-69057 Update 1 to 3 | yes    | Use v1.2.14 or later |
| RS1619xs+  | Broadwellnk   | DSM 7.2.1-69057 Update 1 to 3 | yes    | Use v1.2.14 or later |
| RS3618xs   | Broadwell     | DSM 7.2.1-69057 Update 1 to 3 | yes    | Use v1.2.14 or later |
| RS3617xs+  | Broadwell     | DSM 7.2.1-69057 Update 1 to 3 | yes    | Use v1.2.14 or later |
| RS3617RPxs | Broadwell     | DSM 7.2.1-69057 Update 1 to 3 | yes    | Use v1.2.14 or later |
| RS18017xs+ | Broadwell     | DSM 7.2.1-69057 Update 1 to 3 | yes    | Use v1.2.14 or later |
| RS4017xs+  | Broadwell     | DSM 7.2.1-69057 Update 1 to 3 | yes    | Use v1.2.14 or later |
| | | | | |
| FS6400     | Purley        | DSM 7.2.1-69057 Update 1 to 3 | yes    | Use v1.2.14 or later |
| FS3600     | Broadwellnk   | DSM 7.2.1-69057 Update 1 to 3 | yes    | Use v1.2.14 or later |
| FS3410     | Broadwellnkv2 | DSM 7.2.1-69057 Update 1 to 3 | yes    | Use v1.2.14 or later |
| FS3400     | Broadwell     | DSM 7.2.1-69057 Update 1 to 3 | yes    | Use v1.2.14 or later |
| FS2500     | V1000         | DSM 7.2.1-69057 Update 1 to 3 | yes    | Use v1.2.14 or later |
| FS2017     | Broadwell     | DSM 7.2.1-69057 Update 1 to 3 | yes    | Use v1.2.14 or later |
| FS1018     | Broadwellnk   | DSM 7.2.1-69057 Update 1 to 3 | yes    | Use v1.2.14 or later |
| | | | | |
| HD6500     | Purley        | DSM 7.2.1-69057 Update 1 to 3 | yes    | Use v1.2.14 or later |
| | | | | |
| SA6400     | Epyc7002      | DSM 7.2.1-69057 Update 1 to 3 | yes    | Use v1.2.14 or later |
| SA3610     | Broadwellnkv2 | DSM 7.2.1-69057 Update 1 to 3 | yes    | Use v1.2.14 or later |
| SA3600     | Broadwellnk   | DSM 7.2.1-69057 Update 1 to 3 | yes    | Use v1.2.14 or later |
| SA3410     | Broadwellnkv2 | DSM 7.2.1-69057 Update 1 to 3 | yes    | Use v1.2.14 or later |
| SA3400     | Broadwellnk   | DSM 7.2.1-69057 Update 1 to 3 | yes    | Use v1.2.14 or later |

</details>


### Models confirmed working with older DSM versions

<details>
  <summary>Click here to see list</summary>

| Model      | CPU Arch      | DSM version                   | Works  | Notes |
|------------|---------------|-------------------------------|--------|-------|
| DS923+     | R1000         | DSM 7.2-64570 Update 1 to 3   | yes    | |
| DS923+     | R1000         | DSM 7.2-64570                 | yes    | |
| DS3622xs+  | Broadwellnk   | DSM 7.2-64570                 | **No** | Update to DSM 7.2.1 |
| DS3622xs+  | Broadwellnk   | DSM 7.2-64561                 | yes    | |
| DS3622xs+  | Broadwellnk   | DSM 7.1.1-42962 Update 1      | **No** | Update to DSM 7.2.1 |
| RS4021xs+  | Broadwellnk   | DSM 7.2-64570                 | **No** | Update to DSM 7.2.1 |
| RS4021xs+  | Broadwellnk   | DSM 7.1.1-42962 Update 2      | yes    | |
| DS1821+    | V1000         | DSM 7.2-64570 Update 1 to 3   | yes    | |
| DS1821+    | V1000         | DSM 7.2-64570                 | yes    | |
| DS1821+    | V1000         | DSM 7.2-64561                 | yes    | |
| DS1821+    | V1000         | DSM 7.1.1-42962 Update 4      | yes    | |
| DS1621xs+  | Broadwellnk   | DSM 7.2-64570 Update 3        | yes    | |
| DS1621xs+  | Broadwellnk   | DSM 7.2-64570                 | yes    | |
| DS920+     | Geminilake    | DSM 7.2-64570 Update 1 to 3   | yes    | |
| DS920+     | Geminilake    | DSM 7.2-64570                 | yes    | |
| DS720+     | Geminilake    | DSM 7.2-64570 Update 1 to 3   | yes    | |
| DS720+     | Geminilake    | DSM 7.2-64570                 | yes    | |
| DS3617xs   | Broadwell     |                               | **No** | Update to DSM 7.2.1 |
| | | | | |
|            | Apollolake    |                               | **No** | DSM missing many required files |
|            | Avoton        |                               | **No** | DSM missing many required files |
|            | Denverton     |                               | **No** | DSM missing many required files |

</details>


## Download the script

1. Download the latest version _Source code (zip)_ from https://github.com/007revad/Synology_enable_Deduplication/releases
2. Save the download zip file to a folder on the Synology.
3. Unzip the zip file.

## How to run the script

### Running the script via SSH

[How to enable SSH and login to DSM via SSH](https://kb.synology.com/en-global/DSM/tutorial/How_to_login_to_DSM_with_root_permission_via_SSH_Telnet)

**Note:** Replace /volume1/scripts/ with the path to where the script is located.
Run the script then reboot the Synology:
```YAML
sudo -s /volume1/scripts/syno_enable_dedupe.sh
```

**Options:**
```YAML
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
```

**Extra Steps:**

To get rid of <a href="images/notification.png">drive database outdated</a> notifications and <a href=images/before_running_syno_hdd_db.png>unrecognised firmware</a> warnings run <a href=https://github.com/007revad/Synology_HDD_db>Synology_HDD_db</a> which will add your drives to DSM's compatibile drive databases, and prevent the drive compatability databases being updated between DSM updates.

```YAML
sudo -s /path-to-script/syno_hdd_db.sh --noupdate
```

### What about DSM updates?

After any DSM update you will need to run this script, and the Synology_HDD_db script again. 

### Schedule the script to run at shutdown

Or you can schedule both Synology_enable_Deduplication and Synology_HDD_db to run when the Synology shuts down, to avoid having to remember to run both scripts after a DSM update.

See <a href=how_to_schedule.md/>How to schedule a script in Synology Task Scheduler</a>

<br>

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

<p align="center">Deduplication for HDDs too.</p>
<p align="center"><img src="/images/hdd_dedupe.png"></p>

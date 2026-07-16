# PaperS3 partition scheme (16MB flash)

Data lives on the SD card, so no `storage`/spiffs partition is reserved —
all the flash beyond system partitions goes to three equal-size OTA app
slots.

| Partition | Type | Offset | Size | Contents |
|---|---|---|---|---|
| nvs | data/nvs | 0x9000 | 20KB | system config |
| otadata | data/ota | 0xE000 | 8KB | active-boot-partition pointer |
| ota_0 | app | 0x10000 | 5.25MB | CrossInk (boot default, main menu) |
| ota_1 | app | 0x550000 | 5.25MB | MicroSlate |
| ota_2 | app | 0xA90000 | 5.25MB | PaperBoy |
| coredump | data | 0xFD0000 | 64KB | crash debug |
| shared_nvs | data/nvs | 0xFE0000 | 128KB | cross-app state (last app opened, shared prefs) |

Ends exactly at 0x1000000 (16MB). All `app` partition offsets are multiples
of 0x10000 (64KB), required for the ESP32-S3 instruction cache.

## Boot switching

CrossInk is the permanent boot partition (`ota_0`) and acts as the launcher.
Selecting MicroSlate or PaperBoy from its main menu doesn't run them in the
same binary — it writes the target OTA partition as active
(`esp_ota_set_boot_partition()`) and calls `esp_restart()`. Each app is a
fully independent firmware image with its own display driver — this matters
because PaperBoy bypasses the normal e-ink waveform renderer for its
row/column fast-refresh trick, which would conflict with CrossInk/MicroSlate's
shared `HalDisplay` if they ran in the same address space.

Each app needs its own way back to `ota_0` + reboot — this is already true
of MicroSlate's Home header-zone (see the MicroSlate patch); PaperBoy needs
the same treatment, not yet done.

This mirrors the `OtaBootSwitch` dual-boot pattern already used between
CrossInk and MicroSlate on the X4/X3, extended from 2 to 3 partitions.
`esp_ota_set_boot_partition()`'s hardware bug on the X4/X3 that
`OtaBootSwitch` works around may or may not exist on the S3 — worth testing
unpatched first before assuming the workaround is needed here too.

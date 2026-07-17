# Flashing the PaperS3

## 1. Back up the factory firmware first

The PaperS3 ships with a simple pre-installed e-book reader. Before flashing
anything, dump the entire flash so it can be restored later — this is a
full-chip read, not just the app partition, so it captures the bootloader,
partition table, NVS, and app exactly as they came from the factory.

Install esptool if you don't have it:

```bash
pip3 install esptool
```

Find the device's serial port (plug in via USB-C first):

```bash
ls /dev/cu.usbmodem*
```

Read the full 16MB flash to a file (takes a few minutes):

```bash
esptool.py --chip esp32s3 --port /dev/cu.usbmodemXXXX --baud 921600 \
  read_flash 0x0 0x1000000 papers3-factory-backup.bin
```

Keep `papers3-factory-backup.bin` somewhere safe. To restore the factory
firmware later, reverse the operation:

```bash
esptool.py --chip esp32s3 --port /dev/cu.usbmodemXXXX --baud 921600 \
  write_flash 0x0 papers3-factory-backup.bin
```

## 2. Flash the CrossPoint-PaperS3 launcher

Download the `crosspoint-papers3-firmware` artifact from the GitHub Actions
run (Actions tab → the workflow run → Artifacts), unzip it — you'll have
`bootloader.bin`, `partitions.bin`, and `firmware.bin`.

```bash
esptool.py --chip esp32s3 --port /dev/cu.usbmodemXXXX --baud 921600 write_flash \
  0x0     bootloader.bin \
  0x8000  partitions.bin \
  0x10000 firmware.bin
```

These are the standard Arduino-ESP32 offsets and match this project's
`board_upload.offset_address = 0x10000` for the app partition.

An M5Stack-specific alternative is
[M5Burner](https://docs.m5stack.com/en/download), M5Stack's own GUI
flashing tool — same three files, same offsets, if you'd rather not use the
command line.

## Notes

- First flash after a factory backup: do a full-chip read (`read_flash 0x0
  0x1000000 ...`) as above, not just the app partition — the goal is a
  complete, restorable image.
- `esptool.py` vs `esptool` as the command name depends on how pip installed
  it; if `esptool.py` isn't found, try `esptool` or `python3 -m esptool`.
- Once MicroSlate and PaperBoy are integrated as OTA partitions (see
  `docs/partition-table.md`), reflashing from scratch will use different
  partition offsets — this doc will need an update alongside that switch.

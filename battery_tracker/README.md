# Battery Reporter

A tiny Arch Linux utility that reports your battery level to a remote API in the background.

Once installed, it runs continuously as a **systemd user service** and sends battery data at regular intervals so you can track battery levels over time.

---

## What it does

- Reads battery percentage from `/sys/class/power_supply`
- Sends battery level + charging status to your API via `curl`
- Runs silently in the background
- Starts automatically on login/boot

---

## Requirements

- Arch Linux (or any system with systemd)
- `bash`
- `curl`
- A battery device (e.g. `BAT0`)

---

## Installation

Clone the repo and run:

```bash
make
````

That’s it. The service will be installed, enabled, and started automatically.

---

## Useful commands

Check service status:

```bash
make status
```

View live logs:

```bash
make logs
```

Uninstall completely:

```bash
make uninstall
```

---

## Configuration

Edit `battery_tracker.sh` to change:

* API endpoint
* Report interval
* Battery device name

After changes, restart the service:

```bash
systemctl --user restart battery-tracker
```

---

## Notes

If your battery is not `BAT0`, check:

```bash
ls /sys/class/power_supply/
```


# Clipboard‑Feedback Manager  

A tiny background service that watches the KDE clipboard (Klipper) and shows a visual on‑screen‑display (OSD) notification every time the clipboard contents change.  

The project consists of  

* **`clipboard-change-manager.py`** – a Python script that connects to the KDE D‑Bus, listens for the `clipboardHistoryUpdated` signal and calls the KDE OSD service.  
* **`install.sh`** – creates a *systemd user* service, starts/enables it and adds convenient shell aliases (`clipon`, `clipoff`).  
* **`Makefile`** – handy shortcuts for common actions (run directly, install, start/stop/restart the service).  

---

## Table of Contents  

1. [Features](#features)  
2. [Prerequisites](#prerequisites)  
3. [Installation](#installation)  
4. [Configuration & Aliases](#configuration--aliases)  
5. [Usage](#usage)  
6. [Development / Testing](#development--testing)  
7. [Troubleshooting](#troubleshooting)  
8. [Uninstall / Clean‑up](#uninstall--clean‑up)  
9. [License](#license)  

---

## Features  

* **Zero‑configuration** – once installed the service starts automatically on login.  
* **Lightweight** – runs as a simple Python script under `systemd --user`.  
* **KDE native OSD** – uses KDE’s built‑in OSD service (`org.kde.osdService`) to show a non‑intrusive “Clipboard contents changed” badge.  
* **Debounce** – a configurable time‑threshold prevents spamming when multiple rapid clipboard events fire.  
* **Convenient CLI aliases** – `clipon` / `clipoff` to toggle the service without typing the full `systemctl` command.  

---

## Prerequisites  

| Dependency | Why it’s needed | Install command (Debian/Ubuntu) |
|------------|----------------|---------------------------------|
| `python3`  | Interpreter for the script | `sudo apt install python3` |
| `python3-dbus` | D‑Bus bindings for Python | `sudo apt install python3-dbus` |
| `gir1.2-gtk-3.0` (or `python3-gi`) | GLib main loop (`gi.repository.GLib`) | `sudo apt install python3-gi` |
| `systemd` (user instance) | Manages the background service | Already present on most modern distros |
| (optional) `PyQt5` | Alternative popup implementation (currently commented out) | `sudo apt install python3-pyqt5` |
| KDE Plasma (including **Klipper**) | The clipboard daemon that emits the signal | Already part of KDE |

> **Tip:** On non‑KDE desktops the script will still start, but the D‑Bus interface it listens to (`org.kde.klipper.klipper`) will not exist, so nothing will happen.

---

## Installation  

1. **Clone the repository** (or copy the files into a folder of your choice)

   ```bash
   git clone https://github.com/your‑username/clipboard-feedback.git
   cd clipboard-feedback
   ```

2. **Run the installer script**

   ```bash
   bash install.sh
   ```

   The script will:

   * Verify that `clipboard-change-manager.py` exists.  
   * Create the user‑level systemd unit file `~/.config/systemd/user/clipboard-feedback.service`.  
   * Reload the user daemon, start the service, and enable it to launch on login.  
   * Append the `clipon` / `clipoff` aliases to `~/.bashrc` (if they are not already present).  

   After the script finishes you should see something like:

   ```
   ● clipboard-feedback.service - Clipboard Feedback Manager
        Loaded: loaded (/home/you/.config/systemd/user/clipboard-feedback.service; enabled; vendor preset: enabled)
        Active: active (running) …
   ```

3. **(Optional) Use the Makefile**

   ```bash
   make install        # same as running install.sh
   make service-start  # start the service manually
   make service-stop   # stop it
   make service-restart
   make run            # run the script directly (no systemd)
   ```

---

## Configuration & Aliases  

### Systemd Service  

The generated unit file (`~/.config/systemd/user/clipboard-feedback.service`) looks like:

```ini
[Unit]
Description=Clipboard Feedback Manager
After=default.target

[Service]
Type=simple
ExecStart=/usr/bin/python3 /full/path/to/clipboard-change-manager.py
Restart=always
WorkingDirectory=/full/path/to   # directory that contains the script

[Install]
WantedBy=default.target
```

If you need to tweak the Python interpreter path, working directory, or add extra environment variables, edit this file and then reload the daemon:

```bash
systemctl --user daemon-reload
systemctl --user restart clipboard-feedback.service
```

### Aliases  

* `clipon` – `systemctl --user start clipboard-feedback.service`  
* `clipoff` – `systemctl --user stop clipboard-feedback.service`  

These are automatically appended to `~/.bashrc`. Open a new terminal (or `source ~/.bashrc`) to make them available.

---

## Usage  

Once installed, the service runs in the background and automatically shows an OSD whenever you copy something new.

| Command | What it does |
|---------|--------------|
| `clipon` | Starts the service (if it was stopped). |
| `clipoff` | Stops the service – no more OSD pop‑ups. |
| `systemctl --user status clipboard-feedback.service` | Inspect the current status / logs. |
| `journalctl --user -u clipboard-feedback.service -f` | Follow the service’s log output in real time. |
| `make run` | Run the script directly (useful for debugging). |

**Example** – copy some text in any application, then watch the OSD appear at the centre of the screen (the default KDE OSD location).  

---

## Development / Testing  

If you want to modify the script or test it without systemd:

```bash
# 1. Run the script directly
python3 clipboard-change-manager.py
# or with the Makefile shortcut
make run
```

You can also change the **debounce threshold** (seconds) by editing the `SignalHandler` instantiation at the bottom of `clipboard-change-manager.py`:

```python
handler = SignalHandler(threshold=0.2)   # ignore events < 200 ms apart
```

### Adding a custom popup  

The code already contains a commented‑out Qt‑based popup implementation. To use it:

1. Install PyQt5 (`sudo apt install python3-pyqt5`).  
2. Uncomment the relevant import lines and the `show_popup` function.  
3. Replace `self.show_osd()` in `on_clipboard_history_updated` with `self.show_popup("Clipboard contents changed")`.  

Make sure you have an X11 session (`QT_QPA_PLATFORM=xcb`) if you run under Wayland.

---

## Troubleshooting  

| Symptom | Likely cause | Fix |
|---------|--------------|-----|
| No OSD appears when copying | Service not running | `systemctl --user status clipboard-feedback.service` |
| `systemctl: command not found` | Using a distribution without user‑systemd (e.g., very old Ubuntu) | Install a recent systemd version or run the script manually (`make run`). |
| “Failed to connect to socket /run/user/1000/bus” | DBus session not available (e.g., running script with `sudo`) | Run as normal user, not with `sudo`. |
| “org.kde.osdService not found” | Not running KDE Plasma or OSD service disabled | The script is KDE‑specific; it will silently do nothing on other desktops. |
| “clipboardHistoryUpdated” never received | Klipper not emitting the signal (maybe disabled) | Ensure Klipper is running (`ps aux | grep klipper`) and that clipboard history is enabled. |
| Alias not available after install | `.bashrc` not re‑sourced | Run `source ~/.bashrc` or open a new terminal. |

To view the service logs for more details:

```bash
journalctl --user -u clipboard-feedback.service --no-pager
```

---

## Uninstall / Clean‑up  

```bash
# Stop and disable the service
systemctl --user stop clipboard-feedback.service
systemctl --user disable clipboard-feedback.service

# Remove the unit file
rm -f ~/.config/systemd/user/clipboard-feedback.service
systemctl --user daemon-reload

# Remove the aliases from .bashrc (edit manually or run:)
sed -i '/alias clipon=/d' ~/.bashrc
sed -i '/alias clipoff=/d' ~/.bashrc
source ~/.bashrc   # or open a new terminal
```

Delete the repository folder if you no longer need the script.

---

## License  

This project is released under the **MIT License** – see the `LICENSE` file in the repository for the full text.  

Feel free to fork, improve, or adapt it to your own desktop environment!  

---  

*Happy copying!*  



---  

**Quick Reference Cheat‑Sheet**

```bash
# Install (once)
bash install.sh          # or `make install`

# Control the service
clipon                    # start
clipoff                   # stop
systemctl --user restart clipboard-feedback.service

# Debug / run manually
make run                  # python clipboard-change-manager.py
journalctl --user -u clipboard-feedback.service -f   # view logs
```

---  

# mark – Quick directory bookmarking for the terminal  

A tiny Bash utility that lets you **mark** directories, list them, and jump back to them (with optional fuzzy search). All data is stored in `~/.local/share/mark/marks.csv` and no external database is required.

---

## 📦 Installation  

```bash
# One‑liner (replace the URL with the raw link to mark.sh)
curl -fsSL https://example.com/mark.sh | bash -s https://example.com/mark.sh
```

or manually:

```bash
git clone <repo> && cd <repo>
./install_mark.sh https://raw.githubusercontent.com/…/mark.sh
```

The installer will:

1. Create `~/.local/share/mark/`.
2. Download `mark.sh` there and make it executable.
3. Add the alias `mark` to your `~/.bashrc` or `~/.zshrc` (restart or `source` the file).

### Dependencies  

* `bash` (standard)
* `curl` – used by the installer
* `fzf` – optional, required only for `mark fzf`

---

## 🛠️ How it works  

| Command | What it does |
|---------|--------------|
| `mark` | Save the current directory with a timestamp (`marked`). |
| `mark jump <query>` | Jump to a directory whose path matches `<query>`. If more than one match, you’ll be prompted to pick one. The jump is recorded as `selected`. |
| `mark ls` | List all stored marks (`path  (timestamp, event)`). |
| `mark fzf` | Open an **fzf** picker that ranks entries by recency and frequency of use, then jump to the chosen directory. |

All actions are appended to `marks.csv` in the format:

```
"path","YYYY-MM-DD HH:MM:SS","event"
```

---

## 🚀 Quick usage examples  

```bash
# Inside a project directory
mark                 # → stores /home/user/project

# Later, from anywhere
mark jump proj      # → fuzzy match “project”, change cd to it

# List everything you’ve marked
mark ls

# Use fzf for an interactive picker (requires fzf)
mark fzf
```

---

## 🗂️ Files  

| File | Purpose |
|------|---------|
| `mark.sh` | Core script implementing `add_mark`, `jump_mark`, `list_marks`, and `fzf_jump`. |
| `install_mark.sh` | Helper to download `mark.sh`, set it up, and create a convenient `mark` alias. |

---

## ⚙️ Configuration  

* Override the storage location by setting `XDG_DATA_HOME` before running the script.  
* The script respects the `$SHELL` variable to decide which rc file to modify; add the alias manually for other shells.

---

## 🙏 License  

Public domain / MIT‑style – feel free to copy, modify, and share.

---  

**Enjoy fast navigation!** 🎯

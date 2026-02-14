# 📦 Pacman Package Inventory

A tiny utility to **extract** the list of installed packages on an Arch‑based system, **transform** the raw `pacman -Qi` output into clean JSON, and store the results for later analysis.

---

## ✨ What it does

| Step | Script | Output |
|------|--------|--------|
| **01 – Extract** | `01_extract.sh` (run via `make 01 extract`) | Two text files in `./packages_data/` containing the full `pacman -Qi` dump for all installed packages and for explicitly installed packages. |
| **02 – Transform** | `02_transform.py` (run via `make 02 transform`) | Corresponding JSON files (`*_installed_packages.json`) with one object per package, keys normalized (e.g., `install_date`, `size`). |
| **02b – Transform (bash)** | `02_transform.sh` (optional) | Same JSON output using a Bash‑based helper. |

---

## 📦 Installation

1. **Clone the repo**  

   ```bash
   git clone <repo-url>
   cd <repo-directory>
   ```

2. **Dependencies**  
   - **pacman** (already present on Arch Linux)  
   - **Python 3** (≥3.6) – only the standard library is used.  
   - **Make** (optional, for convenient shortcuts).

   ```bash
   sudo pacman -S make python
   ```

3. **Make the scripts executable**  

   ```bash
   chmod +x 01_extract.sh  # (the Makefile will call it via bash)
   ```

---

## 🚀 Usage

### Via Make (recommended)

```bash
# 1️⃣ Extract package data
make 01 extract

# 2️⃣ Convert to JSON
make 02 transform
```

### Directly

```bash
# Extract
bash 01_extract.sh

# Transform (Python)
python 02_transform.py
```

The resulting files are placed in `./packages_data/`:

- `extracted_all_installed_packages.txt`
- `extracted_explicitly_installed_packages.txt`
- `transformed_all_installed_packages.json`
- `transformed_explicitly_installed_packages.json`

---

## 📂 Project structure

```
├─ 01_extract.sh          # Calls pacman to dump package info
├─ 02_transform.py        # Parses the dump and writes JSON
├─ 02_transform.sh        # (optional) Bash version of the transformer
├─ Makefile               # Convenience shortcuts
└─ packages_data/         # Output folder (auto‑created on first run)
```

---

## 🛠️ Customisation

- **Change output locations** – edit the paths in `02_transform.py` or the Makefile targets.  
- **Add more fields** – the parser splits on `"  : "`; any additional `pacman -Qi` lines will be automatically captured and lower‑cased with underscores.

---

## 📜 License

Feel free to copy, modify, and distribute. No external libraries are used.

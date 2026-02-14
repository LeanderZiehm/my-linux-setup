# 🤖 LLM‑CLI & README Generator  

A tiny collection of Bash utilities that let you talk to a remote LLM endpoint directly from the terminal, automatically create helpful **README.md** files for any project, and install convenient shell aliases with a single command.

---

## Table of Contents  

| Section | Description |
|---------|-------------|
| [Overview](#overview) | What the scripts do |
| [Features](#features) |
| [Prerequisites](#prerequisites) |
| [Installation](#installation) |
| [Usage](#usage) |
| [Configuration & Customisation](#configuration--customisation) |
| [How It Works Internally](#how-it-works-internally) |
| [Limitations & Gotchas](#limitations--gotchas) |
| [Contributing](#contributing) |
| [License](#license) |
| [Acknowledgements](#acknowledgements) |

---

## Overview  

| Script | Purpose |
|--------|---------|
| **`llm.sh`** | Minimal CLI wrapper around the public LLM API (`https://llm.leanderziehm.com/chat/auto`). Sends a user message (and optional system prompt) and prints the response. |
| **`generate_readme.sh`** | Scans the current project, collects all text files (≤ 200 KB, non‑binary, respecting several ignore patterns), sends their contents to the LLM and prints a full‑blown `README.md`. |
| **`install.sh`** | Adds shell aliases (`llm`, `generate_readme`) to `~/.bashrc` (or the shell’s rc file) for one‑click execution. |
| **`Makefile`** | Convenience targets (`run`, `install`, `generate-readme`). |

All three scripts are pure Bash (no external runtime beyond the usual GNU tools) and are designed to be **portable**, **fast**, and **self‑documenting**.

---

## Features  

- **Zero‑install client** – just copy the scripts, make them executable and you’re ready.  
- **Automatic alias creation** – run `install.sh` once and call `llm` or `generate_readme` like native commands.  
- **Clipboard integration** – results are automatically copied to the clipboard via `wl-copy` (Wayland) or `xclip` (X11) when those utilities are present.  
- **Smart JSON handling** – both scripts escape user input correctly and use `jq` (for the README generator) to build safe JSON payloads.  
- **File‑size & binary filtering** – the README generator skips binaries and huge files to keep the request payload small.  
- **Custom system prompts** – you can override the default system prompt for each call.  

---

## Prerequisites  

| Tool | Why it’s needed | Install (examples) |
|------|-----------------|--------------------|
| `bash` (≥ 4) | Script interpreter | Usually pre‑installed on Linux/macOS |
| `curl` | HTTP calls to the LLM endpoint | `sudo apt install curl` / `sudo pacman -S curl` |
| `jq` *(only for `generate_readme.sh`)* | Safe JSON construction & response parsing | `sudo apt install jq` / `sudo pacman -S jq` |
| `file` | Detect binary files | `sudo apt install file` / `sudo pacman -S file` |
| `wl-copy` **or** `xclip` *(optional)* | Clipboard copying | `sudo apt install wl-clipboard` or `sudo apt install xclip` |
| `realpath` (part of `coreutils`) | Resolve script paths in `install.sh` | Usually already present |

---

## Installation  

1. **Clone the repository** (or copy the three `.sh` files into a folder of your choice)  

   ```bash
   git clone https://github.com/yourname/llm-cli.git
   cd llm-cli
   ```

2. **Make the scripts executable**  

   ```bash
   chmod +x llm.sh generate_readme.sh install.sh
   ```

3. **Run the installer** – this will append the appropriate alias definitions to `~/.bashrc`.  

   ```bash
   ./install.sh
   ```

4. **Activate the new aliases** (or open a new terminal)  

   ```bash
   source ~/.bashrc
   ```

5. **Optional:** Install the optional clipboard utilities if you want results automatically copied.  

   ```bash
   # Wayland (most modern distros)
   sudo pacman -S wl-clipboard   # Arch/Manjaro
   # or X11
   sudo apt install xclip       # Debian/Ubuntu
   ```

You’re now ready to use `llm` and `generate_readme` as regular commands.

---

## Usage  

### 1. Quick LLM chat (`llm`)  

```bash
llm "Explain Linux namespaces briefly" "Be concise."
```

*Arguments*  

| Position | Meaning |
|----------|---------|
| `1` | **Message** – the user query you want the LLM to answer (required). |
| `2` | **System prompt** – overrides the default “You are a helpful assistant …” (optional). |

The script prints the answer to `stdout` and, if a clipboard program is found, copies it automatically.

### 2. Generate a full README for the current directory  

```bash
generate_readme
```

The script:

1. Finds all regular text files under the current directory (excluding `.git`, `node_modules`, `dist`, `build`, `.idea`, `.vscode`, and any file larger than **200 KB**).  
2. Skips binary files (detected via `file --mime`).  
3. Sends the collected file contents to the LLM with a system prompt that instructs the model to produce a comprehensive `README.md`.  
4. Prints the generated markdown and copies it to the clipboard.

You can pipe the output straight to a file:

```bash
generate_readme > README.md
```

### 3. Using the Makefile  

| Target | What it does |
|--------|--------------|
| `make run` | Executes `llm.sh` with a sample request (feel free to edit the command). |
| `make install` | Calls `install.sh`. |
| `make generate-readme` | Calls `generate_readme.sh`. |

---

## Configuration & Customisation  

- **Default system prompt** (used by `llm.sh`) is stored in `DEFAULT_SYSTEM_PROMPT` at the top of the script. Change it if you want a different baseline personality.  
- **Maximum file size** for the README generator can be tweaked by editing `MAX_FILE_SIZE_KB` in `generate_readme.sh`.  
- **Exclusion patterns** are listed in the `EXCLUDES` array – add or remove glob patterns to fine‑tune what gets sent to the LLM.  
- **API endpoint** is hard‑coded as `https://llm.leanderziehm.com/chat/auto`. If you have your own endpoint, replace the `API_URL` variable in both scripts.  

All configurable values are defined near the top of each script for easy discovery.

---

## How It Works Internally  

### `llm.sh`  

1. **Argument parsing** – ensures at least a message is supplied.  
2. **JSON escaping** – a tiny `json_escape` function replaces backslashes, double quotes, and newlines.  
3. **POST request** – `curl` sends a JSON payload `{ "message": "...", "system_prompt": "..." }`.  
4. **Response extraction** – uses `sed` to pull either a `"message"` or `"response"` field from the returned JSON (the API is a bit flexible).  
5. **Unescaping** – reverts escaped characters (`\"`, `\\`, `\n`).  
6. **Clipboard** – detects `wl-copy` or `xclip` and pipes the answer to them if available.  

### `generate_readme.sh`  

1. **Dependency checks** – aborts if `jq` or `file` are missing.  
2. **File collection** – builds a `find` command respecting the `EXCLUDES` array and `MAX_FILE_SIZE_KB`.  
3. **Binary detection** – skips any file whose MIME type reports `charset=binary`.  
4. **Message composition** – concatenates each file with a markdown header (`# path/to/file`) and fenced code block.  
5. **JSON construction** – `jq -n` creates a safe JSON object with two fields: `message` (the file dump) and `system_prompt`.  
6. **API call** – `curl` sends the payload, appending the HTTP status code for easy checking.  
7. **Robust parsing** – `jq -r` extracts the answer from several possible response shapes (`.message`, `.response`, `.data.message`, `.choices[0].message.content`).  
8. **Output & clipboard** – prints the markdown and copies it to the clipboard if possible.  

Both scripts use **strict Bash settings** (`set -euo pipefail`) to abort on errors and avoid subtle bugs.

---

## Limitations & Gotchas  

| Issue | Explanation | Mitigation |
|-------|-------------|------------|
| **No authentication** | The public endpoint does not require a token. If you switch to a private API, you’ll need to add `-H "Authorization: Bearer …"` to the `curl` commands. | Modify `API_URL` and add the header in both scripts. |
| **Payload size** | `generate_readme.sh` limits each file to 200 KB and skips binaries, but the overall request may still become large for huge projects. | Adjust `MAX_FILE_SIZE_KB` or add more exclusion patterns. |
| **Response format variability** | The script looks for several possible JSON fields; if the API changes, you may need to update the extraction logic. | Keep the extraction block (`jq -r …`) up‑to‑date with the API docs. |
| **Shell compatibility** | Tested on Bash 4+. `realpath` is part of GNU coreutils; on macOS you may need `brew install coreutils` and use `grealpath` (or replace with `readlink -f`). | Edit `install.sh` to use a cross‑platform path resolver. |
| **Clipboard tools** | Clipboard copying only works if either `wl-copy` or `xclip` is installed. | Install one of them, or ignore the feature. |

---

## Contributing  

Contributions are welcome!  

1. Fork the repository.  
2. Create a feature branch (`git checkout -b feat/awesome‑thing`).  
3. Make your changes, add tests or documentation if appropriate.  
4. Submit a Pull Request with a clear description of what you changed and why.  

Please keep the scripts **POSIX‑compatible where possible**, **document any new flags**, and **preserve the strict error handling** (`set -euo pipefail`).

---

## License  

This project is released under the **MIT License** – see the `LICENSE` file for the full text.  

---

## Acknowledgements  

- **LLM API** – `https://llm.leanderziehm.com` provides the free endpoint used in this demo.  
- **Bash** – The power of a simple shell makes these utilities tiny yet effective.  
- **`jq`** – The JSON processor that keeps our payload building safe and readable.  

---

*Happy hacking! 🎉*  



---  

**Quick reference**  

```bash
# Install (adds aliases)
./install.sh && source ~/.bashrc

# Ask the LLM a question
llm "What is a Unix socket?" "Answer in one sentence."

# Generate a README for the current project
generate_readme > README.md

# Or use the Makefile shortcuts
make install
make run
make generate-readme
```
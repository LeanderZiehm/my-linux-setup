# 📢 Speech‑to‑Audio Makefile Project  

A tiny utility that turns plain‑text into spoken audio using **eSpeak NG** and then (optionally) converts the resulting WAV file to MP3 with **FFmpeg**. All the heavy lifting is done by two simple `make` targets, so you can generate speech assets with a single command.

---  

## Table of Contents  

1. [Description](#description)  
2. [Prerequisites](#prerequisites)  
3. [Installation](#installation)  
4. [Project Structure](#project-structure)  
5. [Usage](#usage)  
6. [Customisation](#customisation)  
7. [Troubleshooting](#troubleshooting)  
8. [Contributing](#contributing)  
9. [License](#license)  

---  

## Description  

- **`gen`** – reads the contents of `1.txt`, synthesises speech with **eSpeak NG**, and writes the output to `output.wav`.  
- **`mp3`** – converts `output.wav` to `output.mp3` using **FFmpeg**.  

This is perfect for quickly generating spoken prompts, audiobooks, voice‑overs for demos, or any workflow where you need text‑to‑speech in an automated script.

---  

## Prerequisites  

| Tool | Why it’s needed | Installation command (Ubuntu/Debian) |
|------|-----------------|--------------------------------------|
| **GNU Make** | Executes the `Makefile` targets | `sudo apt-get install make` (usually pre‑installed) |
| **eSpeak NG** | Text‑to‑speech engine | `sudo apt-get install espeak-ng` |
| **FFmpeg** | Audio conversion (WAV → MP3) | `sudo apt-get install ffmpeg` |
| **Optional – libmp3lame** | MP3 encoder (often bundled with FFmpeg) | `sudo apt-get install libmp3lame0` |

On macOS you can use Homebrew:  

```bash
brew install make espeak ffmpeg
```

On Windows you can install the Windows Subsystem for Linux (WSL) and follow the Linux steps, or use the native Windows builds of eSpeak NG and FFmpeg and add them to your `PATH`.

---  

## Installation  

1. **Clone the repository** (or copy the files into a new directory):  

   ```bash
   git clone https://github.com/your‑username/speech-makefile.git
   cd speech-makefile
   ```

2. **Verify dependencies** (make sure the commands below return a version string):  

   ```bash
   make --version
   espeak-ng --version
   ffmpeg -version
   ```

3. **Make the Makefile executable** – no extra step is required; `make` will read the file automatically.

---  

## Project Structure  

```
├── Makefile      # Build definitions (gen, mp3)
├── 1.txt         # Input text file – create or edit this
└── README.md     # You’re reading it right now!
```

> **Note:** If `1.txt` does not exist, the `gen` target will fail. Create it before running any target.

---  

## Usage  

### 1️⃣ Prepare your text  

Create or edit `1.txt` with the exact text you want spoken. Example:

```text
Hello, world! This is a test of the eSpeak NG text‑to‑speech system.
```

### 2️⃣ Generate a WAV file  

```bash
make gen
```

- **What happens:**  
  - `espeak-ng -f 1.txt -v en -w output.wav`  
  - The text is spoken in English (`-v en`) and saved as `output.wav`.

### 3️⃣ (Optional) Convert to MP3  

```bash
make mp3
```

- **What happens:**  
  - `ffmpeg -i output.wav output.mp3`  
  - The WAV file is re‑encoded to MP3 (default bitrate).  

### 4️⃣ Verify the output  

- Play the WAV: `aplay output.wav` (Linux) or use any media player.  
- Play the MP3: `mpv output.mp3`, `ffplay output.mp3`, etc.

### 5️⃣ Clean up (if you want a fresh start)  

```bash
rm -f output.wav output.mp3
```

---  

## Customisation  

| Parameter | How to change | Example |
|-----------|----------------|---------|
| **Language / voice** | Change the `-v` flag in the `gen` target. eSpeak NG supports many languages (`en-us`, `de`, `fr`, `es`, …). | `espeak-ng -f 1.txt -v de -w output.wav` |
| **Speech speed** | Add `-s <words‑per‑minute>` (default 175). | `-s 120` for slower speech. |
| **Pitch** | Add `-p <0‑99>` (default 50). | `-p 70` for higher pitch. |
| **MP3 bitrate** | Add `-b:a <bitrate>` to the `ffmpeg` command. | `ffmpeg -i output.wav -b:a 192k output.mp3` |
| **Output filenames** | Edit `output.wav` / `output.mp3` in the Makefile. | `-w speech.wav` / `-i speech.wav speech.mp3` |

You can edit the `Makefile` directly, or override variables on the command line:

```bash
make gen VOICE=en-us SPEED=120
```

*(You would need to modify the Makefile to use those variables.)*

---  

## Troubleshooting  

| Symptom | Likely cause | Fix |
|---------|--------------|-----|
| `make: *** [gen] Error 1` | `espeak-ng` not found or `1.txt` missing | Install eSpeak NG and ensure `1.txt` exists in the working directory. |
| `ffmpeg: No such file or directory` | `ffmpeg` not installed or not in `PATH` | Install FFmpeg and verify with `ffmpeg -version`. |
| Output audio is garbled or silent | Wrong voice/encoding options, or the input text contains unsupported characters | Use a different voice (`-v en-us`) or strip special Unicode characters. |
| MP3 file is huge | Default bitrate is high | Add `-b:a 128k` to the FFmpeg command in the Makefile. |
| `make: *** No targets specified and no makefile found` | Running `make` in the wrong folder | `cd` into the directory that contains the `Makefile`. |

---  

## Contributing  

Contributions are welcome! Feel free to:

1. Fork the repo.  
2. Create a new branch (`git checkout -b feature/your‑feature`).  
3. Make your changes (e.g., add more language options, improve the Makefile).  
4. Run `make gen && make mp3` to test.  
5. Open a Pull Request with a clear description of what you added or fixed.

Please follow the existing coding style (simple Bash commands inside the Makefile) and keep the README up‑to‑date.

---  

## License  

This project is released under the **MIT License** – see the `LICENSE` file for details.  

---  

### Quick start cheat sheet  

```bash
# 1. Install dependencies (Ubuntu/Debian)
sudo apt-get update
sudo apt-get install -y make espeak-ng ffmpeg

# 2. Create your text
echo "Hello, this is an example." > 1.txt

# 3. Build audio
make gen          # creates output.wav
make mp3          # creates output.mp3 (optional)

# 4. Play the result
ffplay output.wav   # or any player you prefer
```

Enjoy generating speech on the fly! 🚀

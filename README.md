# NquRack - Intelligent File Tracker
Nqurack is a powerful and flexible CLI tool built with Dart 3 that organizes your files based on customizable rules such as file type, size, creation/modification date or custom mappings.

## Features
- Smart file organization by type, date or size
- YAML/JSON custom rule support
- Preview mode before changes are applied
- Undo feature for recovery
- Interactive file by file confirmation
- Clear loggin and verbose mode


## Installation
```bash
git clone https://github.com/neuroquarkk/NquRack
cd NquRack
dart pub get
dart compile exe bin/nqurack.dart -o nqurack
```
## Quick Usage
- **Preview Mode (safe dry run)**
    ```bash
        ./nqurack organize --path <filepath>
    ```
- **Apply Mode**
    ```bash
        ./nqurack organize --path <filepath> --mode apply
    ```
- **Undo Last Change**
    ```bash
        ./nqurack undo
    ```

## CLI Commands and Options
1. `Organzie` - Organzie files in a directory
    | Flag                | Description                                 |
    | ------------------- | ------------------------------------------- |
    | `-p, --path`        | Path to organize (required)                 |
    | `-m, --mode`        | `preview` or `apply` (default: preview)     |
    | `-a, --action`      | `move`, `copy`, or `rename` (default: move) |
    | `-c, --config`      | Path to custom config file                  |
    | `-i, --interactive` | Ask before each operation                   |
    | `-v, --verbose`     | Show detailed logs                          |

2. `Undo` - Reverts the last file operation(s)
    | Flag            | Description                               |
    | --------------- | ----------------------------------------- |
    | `-s, --steps`   | Number of operations to undo (default: 1) |
    | `-f, --force`   | Bypass confirmation prompts               |
    | `-v, --verbose` | Show undo logs                            |

## Default Rules
    If no config file is provided, the following smart classification is used:

| Category     | Extensions                                |
| ------------ | ---------------------------------------- |
| 📄 Documents | `pdf`, `doc`, `docx`, `txt`, `rtf`      |
| 🖼️ Images   | `jpg`, `jpeg`, `png`, `gif`, `bmp`, `svg` |
| 🎥 Videos    | `mp4`, `avi`, `mkv`, `mov`, `wmv`       |
| 🎵 Audio     | `mp3`, `wav`, `flac`, `aac`, `m4a`      |
| 🗜️ Archives | `zip`, `rar`, `7z`, `tar`, `gz`         |
| 📦 Others    | Files that don’t match any known category |

    These are placed in respective folders (e.g., Documents, Images, Videos, etc)

## Custom Rules (YAML/JSON)
Create a config file to define your own rule like `rules.yaml`
```yaml
defaultDir: "Others"
createDir: true
excludePatterns:
  - "^\\..*"  # Exclude hidden files

rules:
  documents:
    extensions: ["pdf", "docx", "txt"]
    targetDir: "Docs"

  screenshots:
    extensions: ["png"]
    namePattern: "screenshot"
    targetDir: "Screenshots"

  recent:
    extensions: ["jpg", "png", "mp4"]
    newerThan: "2024-01-01T00:00:00Z"
    targetDir: "RecentFiles"
```
Use with:
```bash
    ./nqurack organize --path <filepath> --config rules.yaml --mode apply
```

## Logs & Undo
Every time you apply changes a log is created. To undo:
```bash
    ./nqurack undo
```
You can undo multiple steps or suppress confirmation:
```bash
    ./nqurack undo --steps 3 --force
```

## Project Structure
```
nqurack/
├── bin/                # CLI Entry
├── lib/
│   ├── cli/            # Command handling
│   ├── core/           # Organize & Undo logic
│   ├── models/         # Config and operation schemas
│   └── utils/          # Logger & helpers
├── config/             # Sample rules
├── logs/               # Operation logs
```

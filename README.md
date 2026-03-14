# jenaMemory

A macOS menu bar app for real-time memory monitoring and optimization.

![Swift](https://img.shields.io/badge/Swift-5.9-orange) ![Platform](https://img.shields.io/badge/platform-macOS-lightgrey) ![License](https://img.shields.io/badge/license-MIT-blue)

## Features

- **Real-time monitoring** — Displays free memory percentage in the menu bar, updated every 2 seconds
- **One-click optimization** — Flushes inactive cache via `purge` with automatic administrator prompt
- **Auto-optimization** — Triggers automatically when free memory drops below a configurable threshold (60-second cooldown)
- **Detailed stats** — Shows Used / Cached / Free / Wired / Active / Inactive / Compressed
- **Multi-language** — Korean / English / Japanese / Chinese
- **No Dock icon** — Pure menu bar app (`LSUIElement = true`)

## Preview

The menu bar icon renders a RAM stick gauge that fills based on current memory usage.

```
[RAM gauge] 63% free
├── Optimize Memory     ⌘P
├── Settings            ⌘,
├── About               ⌘I
├─────────────────────────
├── Total     16.0 GB
├── Used       8.2 GB (51%)
├── Cached     3.1 GB
├── Free       4.7 GB
├─────────────────────────
├── Details
│   ├── Wired       2.0 GB
│   ├── Active      4.1 GB
│   ├── Inactive    3.1 GB
│   └── Compressed  2.1 GB
└── Quit               ⌘Q
```

## Requirements

- macOS 13 Ventura or later
- Xcode Command Line Tools (`xcode-select --install`)

## Build & Install

```bash
make run        # Build and launch immediately
make build      # Build .app bundle only  →  .build/jenaMemory.app
make install    # Install to ~/Applications
make pkg        # Create a .pkg installer
make clean      # Remove build artifacts
```

### Manual compile

```bash
swiftc -framework AppKit -O Sources/*.swift -o jenaMemory
```

## Architecture

```
Sources/
├── main.swift                      # Entry point: setActivationPolicy(.accessory)
├── AppDelegate.swift               # App lifecycle, MenuBarController init
├── MenuBarController.swift         # NSStatusItem, 2-second timer, menu layout
├── MemoryMonitor.swift             # Memory stats via vm_statistics64 Mach API
├── PrivilegedExecutor.swift        # Runs purge via NSAppleScript (admin prompt)
├── SettingsWindowController.swift  # Auto-optimize settings, language picker
├── AboutWindowController.swift     # About panel with app icon and version
└── Localization.swift              # Multi-language string management

Resources/
├── Info.plist                      # LSUIElement=true, CFBundleIconFile
└── jenaMemory.icns                 # App icon (all resolutions from 1024px source)
```

## Memory Calculation

Matches the values shown in macOS Activity Monitor.

| Field | Formula |
|-------|---------|
| Used | Wired + Active + Compressed |
| Cached | Inactive (reclaimable on demand) |
| Free | Free + Inactive (actually available) |
| Usage % | Used / Total × 100 |

## Settings

| Option | Default | Description |
|--------|---------|-------------|
| Auto-optimize | Off | Runs purge when free memory falls below threshold |
| Threshold | 1024 MB | Free memory level that triggers auto-optimize |
| Language | System | Korean / English / Japanese / Chinese |

## License

MIT License — © 2026 JenaLab

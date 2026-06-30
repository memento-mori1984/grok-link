# Grok Link v0.4.0

Bridge between **Grok Build** (IDE agent) and **SuperGrok** (browser).

## Highlights

- **System tray** — closing the window hides to tray; bridge keeps running on port 3877
- **Single-instance lock** — only one Grok Link process; relaunch focuses the existing window
- Tray menu: Show Grok Link / Quit; left-click tray icon to restore
- All v0.3.0 features: seamless Tampermonkey sync, handoff scripts, local bridge

## Downloads

| File | Description |
|------|-------------|
| `Grok-Link-0.4.0-win64.zip` | Full release (portable exe, installer, docs, scripts) |
| `Grok-Link-0.4.0-win64.zip.sha256` | Zip checksum |

Inside the zip:
- `Grok Link 0.4.0.exe` — portable app
- `Grok Link_0.4.0_x64-setup.exe` — NSIS installer (if built)
- `browser/grok-link-bridge.user.js` — Tampermonkey script for auto-sync

## Quick start

1. Verify SHA-256 (see `INSTALL.txt`)
2. Run installer or portable exe
3. Install browser bridge (Tampermonkey) for seamless reply sync
4. Close the window anytime — Grok Link stays in the tray with the bridge alive

## Requirements

- Windows 10+ (64-bit)
- WebView2 runtime
- Tampermonkey (optional, recommended)

## Security

Executables are **unsigned**. Prefer building from source if you need full transparency. All handoff data stays local in `%USERPROFILE%\.grok-link\`.

## Full changelog

See [CHANGELOG.md](CHANGELOG.md).
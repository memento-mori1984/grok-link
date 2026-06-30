# Grok Link v0.5.7

Bridge between **Grok Build** (IDE coding agent) and **SuperGrok** (browser).

## Highlights

- **Reliable tray workflow** — minimize and close send Grok Link to the system tray (not the taskbar)
- **Live status** — hero shows "Grok Link is running" and pending handoff counts (no stuck "Starting…")
- **One-click browser bridge** — Tampermonkey installs/updates from the app (no copy-paste)
- **Bridge auto-recovery** — scripts restart Grok Link if the bridge drops during handoffs
- **Userscript v0.4.0** — `GM_xmlhttpRequest` for reliable reply sync from grok.com
- **Plain-English setup guide** — step-by-step onboarding (v0.5+)

## Downloads

| File | Description |
|------|-------------|
| `Grok-Link-0.5.7-win64.zip` | Full release (portable exe, installer, docs, scripts) |
| `Grok-Link-0.5.7-win64.zip.sha256` | Zip checksum |

Inside the zip:

- `Grok Link 0.5.7.exe` — portable app
- `Grok Link_0.5.7_x64-setup.exe` — NSIS installer
- `browser/grok-link-bridge.user.js` — Tampermonkey script (v0.4.0)
- `scripts/` — handoff, poll, bridge test, install helpers

## Quick start

1. Verify SHA-256 (see `INSTALL.txt`)
2. Run installer or portable exe
3. Follow the in-app **setup guide** — install Tampermonkey, click **Install browser bridge**
4. Keep Grok Link running (tray is fine). Minimize or close hides to tray; click the tray icon to restore.

## Requirements

- Windows 10+ (64-bit)
- WebView2 runtime
- Tampermonkey (recommended for automatic reply sync)

## Security

Executables are **unsigned**. Prefer building from source if you need full transparency. All handoff data stays local in `%USERPROFILE%\.grok-link\`.

## Full changelog

See [CHANGELOG.md](CHANGELOG.md).
# Grok Build ↔ SuperGrok integration

Grok Link is the local bridge between **Grok Build** (IDE agent) and **SuperGrok** (browser).

## Seamless flow (v0.3+)

1. **One-time:** Install the **browser bridge** (Tampermonkey userscript).
2. **Grok Build** runs `handoff-and-wait.ps1` (or `handoff.ps1` + `poll-handoff.ps1`).
3. SuperGrok opens with `?q=` prefill and `#grok-link-id=...` in the URL.
4. The browser bridge **auto-syncs** SuperGrok's reply to the local API.
5. **Grok Build** receives the response and continues — no manual paste.

```
Grok Build ──handoff──► Grok Link bridge ◄──auto POST── Browser (grok.com)
     ▲                           │
     └──── poll / handoff-and-wait ────┘
```

## One-time setup: browser bridge

In Grok Link app: **Install browser bridge** (opens Tampermonkey + userscript file).

Or:

```powershell
cd C:\Users\Ranzh\grok-link
.\scripts\Install-BrowserBridge.ps1
```

Copy the script into Tampermonkey, save, and ensure it runs on `grok.com`.

## Grok Build: send and wait (recommended)

```powershell
& "C:\Users\Ranzh\grok-link\scripts\handoff-and-wait.ps1" `
  -Message "Your question for SuperGrok" `
  -Task "short-label" `
  -Context "Project paths, constraints, code summary"
```

This creates the handoff, opens SuperGrok, and blocks until the reply is synced (default 10 min timeout).

## Grok Build: send only

```powershell
& "C:\Users\Ranzh\grok-link\scripts\handoff.ps1" `
  -Message "Your question" -Task "short-label" -Context "extra context"
```

Then open SuperGrok:

```powershell
& "C:\Users\Ranzh\grok-link\scripts\open-supergrok.ps1" -Id "{handoff-id}"
```

Poll until answered:

```powershell
& "C:\Users\Ranzh\grok-link\scripts\poll-handoff.ps1" -Id "{handoff-id}"
```

## Manual fallback

If the browser bridge is not installed, paste SuperGrok's reply in Grok Link → **Save response for Grok Build**.

## Requirements

- Grok Link app running (bridge on `http://127.0.0.1:3877`).
- Browser bridge installed for seamless auto-sync.
- Signed in at `grok.com`.

## API reference

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/api/health` | GET | Bridge alive |
| `/api/handoff` | POST | Create handoff |
| `/api/handoffs` | GET | List handoffs |
| `/api/handoffs/{id}` | GET | Poll handoff + response |
| `/api/handoffs/{id}/response` | POST | Save response (browser bridge uses this) |

## Data storage

`%USERPROFILE%\.grok-link\` — `store/handoffs.json`, `browser/grok-link-bridge.user.js`, `inbox/`
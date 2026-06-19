# Codex Clipboard Bridge

A minimal, secure, and cross-environment clipboard synchronization plugin for the **Codex CLI**. Sync code snippets, logs, and command outputs directly from nested SSH sessions, WSL, tmux, and containerized Docker sandboxes back to your host clipboard.

---

## Key Features

- **Terminal sequences (OSC 52)**: Write-only clipboard integration. The plugin cannot read your clipboard, ensuring privacy.
- **Multiplexer Support**: Automatic escape-wrapping for `tmux` and `GNU Screen`.
- **WSL & Host Retries**: Uses `clip.exe` and PowerShell retry loops on Windows hosts.
- **Sandbox Bypasses**: Automatically writes copy streams to a local bypass file (`.clipboard_bypass`) in restricted sandboxes so you can capture them from the host.

---

## Installation

Once added to your Codex CLI plugins directory or marketplace:

1. **Add the Marketplace Source**:
   ```bash
   codex plugin marketplace add aaronbronow/codex-clipboard-bridge
   ```

2. **Install the Plugin**:
   ```bash
   /plugin install codex-clipboard-bridge
   ```

---

## How It Works

This plugin operates as a background **Codex Skill** (`skills/copy`). Codex automatically detects your clipboard request, progressively loads the skill, and runs the unified `copy_to_clipboard.sh` helper script:

```bash
printf "%s" "TEXT_TO_COPY" | ./skills/copy/copy_to_clipboard.sh
```

---

## Sandbox & Docker Usage

In isolated Docker sandboxes where direct TTY writes are blocked, the script will write to `.clipboard_bypass`. You can sync this file back to your physical clipboard by running this on your host machine:

```bash
tail -F .clipboard_bypass > $(tty)
```

---

## Development & Downstream Sync

This plugin is part of the `agent-bridge-clipboard` ecosystem. To import updates from the upstream hub:

```bash
make import-upstream
```

---

## License

MIT

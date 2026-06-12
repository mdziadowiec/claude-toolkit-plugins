---
description: Install the external tools the claude-workflows commands depend on (cc2md for /export-md) on Windows. Run once after installing the plugin.
---

# Install claude-workflows dependencies (Windows)

The `/export-md` command shells out to [`cc2md`](https://github.com/magarcia/cc2md).
This command provisions it from the prebuilt GitHub release binary. It is
**idempotent** — if `cc2md` is already on PATH (or already in the managed bin dir)
it is skipped.

## What gets installed

| Tool | Source | Used by |
|---|---|---|
| `cc2md` | GitHub release `cc2md_Windows_x86_64.zip` → `%USERPROFILE%\.claude\bin` | `/export-md` |

The binary is placed in `%USERPROFILE%\.claude\bin`, which the script adds to the
user PATH.

## Steps

Run the bundled installer script with PowerShell 7+ (`pwsh`). Windows-only:

```
pwsh -NoProfile -ExecutionPolicy Bypass -File "${CLAUDE_PLUGIN_ROOT}/scripts/install-tools.ps1"
```

To force a reinstall (e.g. to pick up the latest cc2md release), append `-Force`.

> If `pwsh` is unavailable on a given machine, the same script also runs under
> Windows PowerShell 5.1 — substitute `powershell` for `pwsh` above.

## After running

- Report the summary table the script prints (installed / already installed / failed).
- If `cc2md` shows "installed (restart shell)", tell the user to reopen their
  terminal so the new `~/.claude/bin` entry lands on PATH.
- On non-Windows platforms, install via `go install github.com/magarcia/cc2md@latest`
  or download the matching `cc2md_<OS>_<arch>.tar.gz` from the GitHub releases page.

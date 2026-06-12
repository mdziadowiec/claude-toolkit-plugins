---
description: Install the CLI tools the cli-tools skills depend on (rg, fd, fzf, jq, jc, yq, rga, hyperfine) on Windows. Run once after installing the plugin.
---

# Install cli-tools dependencies (Windows)

The skills in this plugin shell out to external CLI tools. This command provisions
them via winget, pip, and scoop. It is **idempotent** — tools already on PATH are skipped.

## What gets installed

| Tool | Source | Used by skill |
|---|---|---|
| `rg` (ripgrep) | winget `BurntSushi.ripgrep.MSVC` | rg-fzf-dotnet, cli-toolkit, rga |
| `fd` | winget `sharkdp.fd` | fd-file-search, cli-toolkit |
| `fzf` | winget `junegunn.fzf` | rg-fzf-dotnet, cli-toolkit |
| `jq` | winget `jqlang.jq` | jq-json-processor, cli-toolkit |
| `yq` | winget `MikeFarah.yq` | yq, cli-toolkit |
| `hyperfine` | winget `sharkdp.hyperfine` | hyperfine |
| `bat` | winget `sharkdp.bat` | bat, cli-toolkit |
| `gron` | winget `TomHudson.gron` | gron, cli-toolkit |
| `sd` | winget `chmln.sd` | sd, cli-toolkit |
| `ast-grep` | winget `ast-grep.ast-grep` | ast-grep, cli-toolkit |
| `jc` | pip `jc` | jc, cli-toolkit |
| `rga` (ripgrep-all) | scoop `ripgrep-all` | rga |
| `poppler` (optional) | scoop `poppler` | rga (PDF text extraction) |

## Steps

Run the bundled installer script. This is Windows-only and requires PowerShell:

```
pwsh -NoProfile -ExecutionPolicy Bypass -File "${CLAUDE_PLUGIN_ROOT}/scripts/install-tools.ps1"
```

If `pwsh` (PowerShell 7+) is not available, fall back to Windows PowerShell:

```
powershell -NoProfile -ExecutionPolicy Bypass -File "${CLAUDE_PLUGIN_ROOT}/scripts/install-tools.ps1"
```

To skip the optional poppler PDF backend, append `-SkipPoppler`.

## After running

- Report the summary table the script prints (which tools were installed, skipped, or failed).
- If any tool shows "installed (restart shell)", tell the user to reopen their terminal so the new tools land on PATH.
- If `winget` or `scoop` was unavailable, surface that — winget ships with Windows 11 (App Installer); the script auto-installs scoop if missing.
- Do not re-run blindly on failure; read the per-tool error detail and address the specific cause.

## Troubleshooting

- **jc reported installed but `jc` doesn't run / Python "missing".** The `python`
  command on a fresh Windows box is often the Microsoft Store *execution-alias stub*
  (a 0-byte shim under `…\WindowsApps\`) that cannot install packages. The installer
  now detects this (`Test-RealPython` rejects anything under `WindowsApps`), provisions
  a real Python via winget (`Python.Python.3.13`), then adds the pip `--user` scripts
  dir (`%APPDATA%\Python\Python<ver>\Scripts`) to PATH so `jc` resolves. If you still
  see no `jc`, reopen the terminal so the PATH edit takes effect.
- **scoop bootstrap fails with a "security error".** Windows PowerShell 5.1 negotiates
  TLS 1.0/1.1 by default, which `get.scoop.sh` rejects. The installer now forces TLS 1.2
  and a process-scope execution-policy bypass before the fetch. If you bootstrap scoop
  by hand, do the same first:
  ```powershell
  [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
  Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
  Invoke-RestMethod get.scoop.sh | Invoke-Expression
  ```

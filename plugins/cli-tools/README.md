# cli-tools

CLI workflow skills for token-efficient agentic work, plus a Windows command that installs
the binaries they depend on.

## Skills

- **cli-toolkit** — multi-tool pipelines (fd + rg + fzf + jc + jq + yq), output bounding, quoting rules
- **fd-file-search** — find files by name, extension, path, or type
- **rg-fzf-dotnet** — content/symbol search with ripgrep + fzf (tuned for .NET)
- **rga** — search inside PDFs, Office docs, e-books, archives, SQLite
- **jc** — convert CLI output and file formats to JSON
- **jq-json-processor** — filter and transform JSON
- **yq** — query/edit/convert YAML, JSON, XML, TOML, CSV
- **hyperfine** — statistical CLI benchmarking

## Install the CLI dependencies

```
/cli-tools:install-tools
```

Runs [`scripts/install-tools.ps1`](scripts/install-tools.ps1) — Windows-only, idempotent.

| Tool | Source |
|---|---|
| rg, fd, fzf, jq, yq, hyperfine | winget |
| jc | pip (`--user`) |
| rga, poppler (optional) | scoop (auto-installs scoop if missing) |

Append `-SkipPoppler` to skip the optional PDF backend. Reopen the terminal afterward so new
tools land on PATH. Tools already installed are detected and skipped.

## Manual install

If you'd rather not use the command, run the script directly:

```powershell
pwsh -NoProfile -ExecutionPolicy Bypass -File scripts/install-tools.ps1
```

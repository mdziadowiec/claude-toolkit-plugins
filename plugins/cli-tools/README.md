# cli-tools

CLI workflow skills for token-efficient agentic work, plus a one-shot Windows command that
installs the binaries they depend on. Part of the
[claude-toolkit-plugins](https://github.com/mdziadowiec/claude-toolkit-plugins) marketplace.

## Install

```
/plugin marketplace add mdziadowiec/claude-toolkit-plugins
/plugin install cli-tools@claude-toolkit-plugins
/reload-plugins
```

Then provision the underlying tools (see below).

## Skills

| Skill | Invoke as | Purpose |
|---|---|---|
| cli-toolkit | `/cli-tools:cli-toolkit` | Multi-tool pipelines (fd + rg + fzf + jc + jq + yq), output bounding, cross-shell quoting |
| fd-file-search | `/cli-tools:fd-file-search` | Find files by name, extension, path, or type |
| rg-fzf-dotnet | `/cli-tools:rg-fzf-dotnet` | Content & symbol search with ripgrep + fzf (tuned for .NET) |
| rga | `/cli-tools:rga` | Search inside PDFs, Office docs, e-books, archives, SQLite |
| jc | `/cli-tools:jc` | Convert CLI output and file formats to JSON |
| jq-json-processor | `/cli-tools:jq-json-processor` | Filter and transform JSON |
| yq | `/cli-tools:yq` | Query / edit / convert YAML, JSON, XML, TOML, CSV |
| hyperfine | `/cli-tools:hyperfine` | Statistical CLI benchmarking |

Skills are model-invoked: Claude reaches for them automatically when a task matches, or you can
trigger one explicitly with its `/cli-tools:<skill>` name.

## Install the CLI dependencies (Windows)

```
/cli-tools:install-tools
```

Runs [`scripts/install-tools.ps1`](scripts/install-tools.ps1) — **idempotent**, so tools
already on `PATH` are detected and skipped:

| Tools | Source |
|---|---|
| `rg`, `fd`, `fzf`, `jq`, `yq`, `hyperfine` | winget |
| `jc` | pip (`--user`) |
| `rga`, `poppler` *(optional)* | scoop (auto-installs scoop if missing) |

Append `-SkipPoppler` to skip the optional PDF backend. Reopen the terminal afterward so new
tools land on `PATH`.

### Manual install

If you'd rather not use the command, run the script directly:

```powershell
pwsh -NoProfile -ExecutionPolicy Bypass -File scripts/install-tools.ps1
```

On macOS/Linux, install the equivalents with `brew` / `apt` / `dnf` — the skills are
cross-platform; only this installer is Windows-specific.

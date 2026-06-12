# claude-toolkit-plugins

A [Claude Code](https://code.claude.com) plugin marketplace bundling the CLI and workflow
skills I use day to day, split into two independent plugins so you can take either or both.

| Plugin | What's in it | External deps |
|---|---|---|
| **cli-tools** | Search / JSON / benchmarking skills, plus a one-shot command that installs the underlying binaries | Yes (Windows installer included) |
| **claude-workflows** | Output-style and coding-discipline skills | None — pure prompt skills |

## Install

Add the marketplace once, then install whichever plugin(s) you want:

```
/plugin marketplace add mdziadowiec/claude-toolkit-plugins
/plugin install cli-tools@claude-toolkit-plugins
/plugin install claude-workflows@claude-toolkit-plugins
```

Run `/reload-plugins` afterward to activate them in the current session.

### Installing the CLI dependencies (Windows)

The `cli-tools` skills shell out to external binaries (`rg`, `fd`, `jq`, …). Once the plugin
is installed, provision them in one step:

```
/cli-tools:install-tools
```

This runs a bundled, **idempotent** PowerShell script — tools already on `PATH` are skipped:

| Tools | Source |
|---|---|
| `rg`, `fd`, `fzf`, `jq`, `yq`, `hyperfine`, `bat`, `gron`, `sd`, `ast-grep` | winget |
| `jc` | pip (`--user`) |
| `rga`, `poppler` *(optional)* | scoop (auto-installs scoop if missing) |

See [`plugins/cli-tools/README.md`](plugins/cli-tools/README.md) for options and details.

> The installer is Windows-only by design. On macOS/Linux, install the equivalents with your
> package manager (`brew`, `apt`, `dnf`, …) — the skills themselves are cross-platform.

## Skills

### cli-tools

| Skill | Invoke as | Purpose |
|---|---|---|
| cli-toolkit | `/cli-tools:cli-toolkit` | Multi-tool CLI pipelines (fd + rg + fzf + jc + jq + yq) |
| fd-file-search | `/cli-tools:fd-file-search` | Find files by name / extension / path / type |
| rg-fzf-dotnet | `/cli-tools:rg-fzf-dotnet` | Content & symbol search with ripgrep + fzf |
| rga | `/cli-tools:rga` | Search inside PDFs, Office docs, e-books, archives, SQLite |
| ast-grep | `/cli-tools:ast-grep` | Structural (AST-aware) code search and rewrite |
| jc | `/cli-tools:jc` | Convert CLI output / file formats to JSON |
| jq-json-processor | `/cli-tools:jq-json-processor` | Filter and transform JSON |
| yq | `/cli-tools:yq` | Query / edit / convert YAML, JSON, XML, TOML, CSV |
| gron | `/cli-tools:gron` | Flatten JSON into greppable lines (and back) |
| sd | `/cli-tools:sd` | Intuitive find-and-replace (sed alternative) |
| bat | `/cli-tools:bat` | View files with syntax highlighting + line numbers |
| hyperfine | `/cli-tools:hyperfine` | Statistical CLI benchmarking |

### claude-workflows

| Skill | Invoke as | Purpose |
|---|---|---|
| crisp | `/claude-workflows:crisp` | Shorter, more direct responses |
| karpathy | `/claude-workflows:karpathy` | Coding discipline — think before coding, surgical changes |
| handoff | `/claude-workflows:handoff` | Structured session-handoff notes |
| doc-coauthoring | `/claude-workflows:doc-coauthoring` | Structured documentation co-authoring |

## Managing the plugins

```
/plugin                                              # interactive manager (browse, enable, disable)
claude plugin uninstall cli-tools@claude-toolkit-plugins
claude plugin marketplace update claude-toolkit-plugins   # pull the latest after a repo push
```

## Repository layout

```
.
├── .claude-plugin/marketplace.json     # lists both plugins
└── plugins/
    ├── cli-tools/
    │   ├── .claude-plugin/plugin.json
    │   ├── commands/install-tools.md   # → /cli-tools:install-tools
    │   ├── scripts/install-tools.ps1   # idempotent Windows installer
    │   └── skills/                     # cli-toolkit, fd-file-search, rg-fzf-dotnet,
    │                                   #   rga, jc, jq-json-processor, yq, hyperfine
    └── claude-workflows/
        ├── .claude-plugin/plugin.json
        └── skills/                     # crisp, karpathy, handoff, doc-coauthoring
```

## Notes

- **Namespacing.** Plugin skills are invoked as `/<plugin>:<skill>`, not bare `/<skill>`.
  Skill bodies that reference a sibling by its bare name (e.g. "use `/fd-file-search`") still
  read correctly as guidance — only the actual invocation is namespaced.
- **Platform.** Only the `install-tools` command is Windows-specific; the skills run anywhere
  once their tools are present.

## License

[MIT](LICENSE)

# claude-toolkit-plugins

A Claude Code plugin marketplace with two installable plugins:

| Plugin | What's in it |
|---|---|
| **cli-tools** | CLI workflow skills + a Windows command that installs the underlying tools |
| **claude-workflows** | Workflow / discipline skills (no external dependencies) |

## Install

Add the marketplace, then install whichever plugin(s) you want:

```
/plugin marketplace add mdziadowiec/claude-toolkit-plugins
/plugin install cli-tools@claude-toolkit-plugins
/plugin install claude-workflows@claude-toolkit-plugins
```

> Replace `mdziadowiec/claude-toolkit-plugins` with the actual GitHub `owner/repo` once published.

### cli-tools: install the CLI dependencies (Windows)

The `cli-tools` skills shell out to external binaries. After installing the plugin, run:

```
/cli-tools:install-tools
```

This runs a bundled, **idempotent** PowerShell script that provisions `rg`, `fd`, `fzf`,
`jq`, `yq`, `hyperfine` (winget), `jc` (pip), and `rga` + optional `poppler` (scoop).
Tools already on PATH are skipped. See [plugins/cli-tools/README.md](plugins/cli-tools/README.md).

## Skills

### cli-tools

| Skill | Invoke as | Purpose |
|---|---|---|
| cli-toolkit | `/cli-tools:cli-toolkit` | Multi-tool CLI pipelines (fd + rg + fzf + jc + jq + yq) |
| fd-file-search | `/cli-tools:fd-file-search` | Find files by name/ext/path/type |
| rg-fzf-dotnet | `/cli-tools:rg-fzf-dotnet` | Content/symbol search with ripgrep + fzf |
| rga | `/cli-tools:rga` | Search inside PDFs, Office docs, e-books, archives, SQLite |
| jc | `/cli-tools:jc` | Convert CLI output / file formats to JSON |
| jq-json-processor | `/cli-tools:jq-json-processor` | Filter and transform JSON |
| yq | `/cli-tools:yq` | Query/edit/convert YAML, JSON, XML, TOML, CSV |
| hyperfine | `/cli-tools:hyperfine` | Statistical CLI benchmarking |

### claude-workflows

| Skill | Invoke as | Purpose |
|---|---|---|
| crisp | `/claude-workflows:crisp` | Shorter, more direct responses |
| karpathy | `/claude-workflows:karpathy` | Coding discipline (think before coding, surgical changes) |
| handoff | `/claude-workflows:handoff` | Structured session handoff notes |
| doc-coauthoring | `/claude-workflows:doc-coauthoring` | Structured documentation co-authoring |

## Notes

- **Namespacing:** plugin skills are invoked as `/<plugin>:<skill>`, not bare `/<skill>`.
  Skill bodies that cross-reference sibling skills by their bare name (e.g. "use `/fd-file-search`")
  still read correctly as guidance, but the actual invocation is namespaced as above.
- **Platform:** the `install-tools` command is Windows-only (winget/scoop/pip), matching the
  source environment. The skills themselves are cross-platform once the tools are present.

## License

MIT

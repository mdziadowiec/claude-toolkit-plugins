---
name: bat
description: >
  View file contents with syntax highlighting, line numbers, and git-change markers using
  `bat` — a `cat` replacement. Use this skill when reading a file or a specific line range
  for precise `path:line` references, when showing a snippet with highlighting, when using
  bat as an fzf/preview backend, or when you'd reach for `cat`/`head`/`tail` but want
  language-aware output. Always run non-interactively (`-pp` / `--paging=never`) inside an
  agent so it never blocks on a pager. Install: winget sharkdp.bat.
allowed-tools: Bash, PowerShell
---

# bat — A Better `cat`

`bat` prints files with syntax highlighting, line numbers, and (in a git repo) per-line change
markers. For agent use the critical rule is **never let it open a pager** — always pass `-pp`
or `--paging=never`, or the call will hang waiting for input.

## Agent-safe invocation

```bash
bat -pp <file>                      # plain: no pager, no decorations — closest to cat
bat --paging=never <file>           # keep decorations (line numbers, headers), no pager
```

Use `-pp` when piping or when you only need the text; use `--paging=never -n` when you want
line numbers to cite `path:line` locations.

## Common flags

| Flag | Effect |
|---|---|
| `-p`, `--plain` | No line numbers / headers / grid (repeat as `-pp` to also disable paging) |
| `--paging=never` | Never invoke the pager (essential non-interactively) |
| `-n`, `--number` | Show line numbers only |
| `-r`, `--line-range <a:b>` | Print only lines a–b (e.g. `-r 40:80`) |
| `-H`, `--highlight-line <n>` | Emphasise a specific line |
| `-l`, `--language <lang>` | Force a language for highlighting (e.g. `-l json`) |
| `-A`, `--show-all` | Reveal non-printable characters |
| `--diff` | Show only changed lines vs git |

## Recipes

**Read a bounded slice for a precise citation:**
```bash
bat --paging=never -n -r 120:160 src/Service.cs
```

**Highlight a match in context (pair with rg line numbers):**
```bash
bat --paging=never -H 142 -r 130:155 src/Service.cs
```

**Use as an fzf preview window (`/rg-fzf-dotnet`):**
```bash
rg --files -g '*.cs' | fzf --preview 'bat --color=always --paging=never -n {}'
```

## Notes

- bat respects `.gitignore` only for directory walks; for explicit file args it always prints.
- Prefer `bat` over `Read` when you specifically want highlighting or a tight line range for a
  snippet; prefer the `Read` tool when you simply need the file content into context.
- On Windows the binary is `bat`; if a `bat.exe` name clash occurs in Git Bash, call it with the
  full path or use `--paging=never` explicitly.

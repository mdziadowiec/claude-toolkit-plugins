---
name: sd
description: >
  Find-and-replace text using `sd` — an intuitive `sed` replacement with normal regex syntax
  and `$1` capture groups. Use this skill for search-and-replace across files or streams:
  renaming a symbol, rewriting a string, stripping/normalising text in a pipe, or applying a
  regex substitution. Prefer sd over sed when the sed syntax is fiddly. Pairs with fd/rg to
  scope which files get edited. Edits files in place (no backup) — preview first with `-p`.
  Install: winget chmln.sd.
allowed-tools: Bash, PowerShell
---

# sd — Intuitive Find & Replace

`sd` does one thing: regex (or literal) find-and-replace, with sane syntax. It reads stdin →
writes stdout, or takes file arguments and **edits them in place**. There is no backup, so
**preview with `-p` before editing files**.

## Core usage

```bash
sd 'find' 'replace' file.txt           # edit file.txt IN PLACE (regex by default)
echo "input" | sd 'find' 'replace'     # stream mode: stdin -> stdout
sd 'find' 'replace' < in.txt > out.txt # stream to a new file (leaves original intact)
sd -p 'find' 'replace' file.txt        # PREVIEW the diff, change nothing
```

## Flags

| Flag | Effect |
|---|---|
| `-p`, `--preview` | Show what would change without writing — use before any in-place edit |
| `-s`, `--string-mode` | Treat the pattern as a literal string, not a regex |
| `-f`, `--flags <f>` | Regex flags: `i` case-insensitive, `m` multiline, `s` dot-matches-newline, `w` word boundaries |
| `-n <N>` | Replace at most N occurrences |

Capture groups use `$1`, `$2` (or `${1}` when followed by a digit/letter).

## Recipes

**Preview, then apply a regex rename in one file:**
```bash
sd -p 'OldName' 'NewName' src/Thing.cs      # inspect
sd    'OldName' 'NewName' src/Thing.cs       # apply
```

**Reorder with capture groups (stream):**
```bash
echo "2026-06-12" | sd '(\d{4})-(\d{2})-(\d{2})' '$3/$2/$1'   # -> 12/06/2026
```

**Scope edits to matching files with fd/rg (run via Bash tool):**
```bash
# every .cs file that contains the term, edited in place
rg -l 'OldName' -g '*.cs' | xargs sd 'OldName' 'NewName'
# or discover by filename first
fd -e cs | xargs sd -s 'TODO(old)' 'TODO(new)'
```

**Case-insensitive literal replace:**
```bash
sd -s -f i 'foo' 'bar' notes.md
```

## Agent notes

- **Always `-p` first** on file edits — sd has no undo and writes no backup.
- For multi-file edits, scope with `rg -l` / `fd` and pipe to `xargs sd` via the **Bash tool**
  (PowerShell's pipeline passes objects, not the byte stream xargs expects).
- Use `-s` (string mode) whenever the target contains regex metacharacters (`.`, `(`, `$`, `[`).
- After a bulk edit, verify with `rg` that the old term is gone and the new one appears as expected.

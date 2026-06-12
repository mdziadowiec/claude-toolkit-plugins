---
name: ast-grep
description: >
  Search and rewrite code by its syntax tree (AST), not plain text, using `ast-grep`. Use
  this skill when a text search would be too noisy or too blunt — finding a specific call
  shape, all usages of a pattern regardless of formatting/whitespace, structural lint rules,
  or performing a safe structural refactor with metavariables. Complements rg-fzf-dotnet: rg
  matches characters, ast-grep matches code structure. Supports C#, JS/TS, Python, Go, Rust,
  Java, and more. Install: winget ast-grep.ast-grep (binary: `ast-grep`, alias `sg`).
allowed-tools: Bash, PowerShell
---

# ast-grep — Structural Code Search & Rewrite

`ast-grep` matches patterns against the parsed syntax tree, so it ignores formatting and
whitespace and understands code shape. Reach for it when `rg` (`/rg-fzf-dotnet`) produces too
many false positives or can't express the structure you mean (e.g. "a call to `Foo` with
exactly two arguments").

## Pattern language

- `$VAR` — matches a single node (expression, identifier, statement) and captures it.
- `$$$ARGS` — matches zero or more nodes (e.g. an argument list, a statement block).
- Literal code is matched structurally: `Console.WriteLine($MSG)` matches any single-arg call
  regardless of spacing or line breaks.

## Core usage

```bash
ast-grep run -p '<pattern>' -l <lang> <path>     # search
ast-grep -p 'console.log($A)' -l ts src/          # short form
ast-grep run -p '<pattern>' -r '<rewrite>' -l <lang> <path>   # rewrite (dry run prints a diff)
ast-grep run -p '<pattern>' --json -l <lang> <path>           # JSON for jq downstream
```

`-l`/`--lang` values include `csharp`, `js`, `ts`, `tsx`, `python`, `go`, `rust`, `java`.

## Recipes

**Find a specific call shape in C# (impossible to express cleanly in rg):**
```bash
ast-grep run -p 'await $X.SaveChangesAsync($$$)' -l csharp src/
```

**Find then structurally rewrite (preview diff, doesn't write without --update-all):**
```bash
ast-grep run -p 'String.Format($FMT, $$$ARGS)' -r '$"..."' -l csharp src/   # inspect the diff
ast-grep run -p 'var $X = new List<$T>()' -r '$T[] $X = []' -l csharp --update-all src/
```

**Pipe structural matches into jq for a minimal report:**
```bash
ast-grep run -p 'catch ($$$) { }' -l csharp --json src/ \
  | jq -c '.[] | {file: .file, line: .range.start.line}' | head -n 50
```

## ast-grep vs rg

| Want | Tool |
|---|---|
| Any text/symbol/TODO/config key | `rg` (`/rg-fzf-dotnet`) — faster, simpler |
| A code *shape* (call arity, nesting, specific construct) | `ast-grep` |
| Structural find-and-replace that respects syntax | `ast-grep -r` |
| Flat string substitution | `sd` (`/sd`) |

## Agent notes

- Rewrites are **dry-run by default** (prints a diff); only `--update-all` (or `-U`) writes.
  Always inspect the diff first.
- Start narrow: confirm the pattern matches what you expect with `--json | head` before adding `-r`.
- For one-off text matches prefer `rg` — ast-grep parses files, so it's heavier; use it when
  structure actually matters.
- The binary is `ast-grep`; the `sg` alias may collide with other tools on Windows — prefer the
  full name in scripts.

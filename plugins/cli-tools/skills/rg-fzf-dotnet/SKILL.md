---
name: rg-fzf-dotnet
description: Fast, deterministic repository search for .NET code and docs using ripgrep and fzf. Use whenever searching for symbols, call sites, text, TODOs, config keys, project references, or relevant files in a repo. Prefer this skill before reading whole files or directories. Optimized for Windows workflows and includes C#, VB.NET, and F# files.
allowed-tools: Bash, PowerShell
---

# rg + fzf — Agent-Readable .NET Repo Search

## Purpose

Use this skill to find relevant files, symbols, call sites, docs, config keys, and implementation patterns without reading entire directories or large files.

Prefer small, structured, parseable outputs:

- file path
- line number
- column number
- matched line
- limited context only when needed

## Non-negotiable rules

1. Search first. Do not read whole files or directories unless `rg` output identifies them as relevant.
2. Rely on ripgrep default ignore behavior. Do not add manual excludes for `bin`, `obj`, `node_modules`, `dist`, etc. unless explicitly required.
3. Do not use `--hidden` by default.
4. Use `--hidden` only when the task specifically involves dotfiles or hidden directories.
5. For .NET code search, always include:
   - `*.cs`
   - `*.vb`
   - `*.fs`
6. Prefer parseable output:
   - use `--vimgrep` for `file:line:column:match`
   - use `--json` only when structured machine parsing is needed
7. Use `fzf` as a deterministic secondary filter/ranker with `--filter`, not as a user-facing UI, unless explicitly requested.
8. Use `-e "<pattern>"` so patterns beginning with `-` are treated as search patterns, not options.

---

## Primary rg commands

### .NET code search

Use for symbols, method names, classes, interfaces, properties, constants, comments, TODOs.

```cmd
rg --vimgrep --smart-case --max-count=100 -g "*.cs" -g "*.vb" -g "*.fs" -e "<pattern>" .
```

### Whole-word .NET symbol search

Use for identifiers where partial matches are noisy.

```cmd
rg --vimgrep --smart-case --word-regexp --max-count=100 -g "*.cs" -g "*.vb" -g "*.fs" -e "<symbol>" .
```

### Literal .NET search

Use when searching text that may contain regex characters.

```cmd
rg --vimgrep --fixed-strings --smart-case --max-count=100 -g "*.cs" -g "*.vb" -g "*.fs" -e "<literal>" .
```

### Project / solution search

Use for package references, target frameworks, project references, build settings.

```cmd
rg --vimgrep --smart-case --max-count=100 -g "*.sln" -g "*.csproj" -g "*.vbproj" -g "*.fsproj" -e "<pattern>" .
```

### Docs / config search

Use for Markdown docs, appsettings, XML config, YAML pipelines.

```cmd
rg --vimgrep --smart-case --max-count=100 -g "*.md" -g "*.json" -g "*.yml" -g "*.yaml" -g "*.xml" -e "<pattern>" .
```

### Context search

Use only after initial search shows relevant matches and nearby lines are needed.

```cmd
rg --line-number --column --no-heading --smart-case --max-count=50 -C 2 -g "*.cs" -g "*.vb" -g "*.fs" -e "<pattern>" .
```

### Machine-readable JSON search

Use when structured parsing is needed instead of line-oriented text.

```cmd
rg --json --smart-case --max-count=100 -g "*.cs" -g "*.vb" -g "*.fs" -e "<pattern>" .
```

---

## File discovery

### List searchable files

Use `rg` as the file enumerator because it follows ripgrep ignore behavior.

```cmd
rg --files
```

### List .NET code files only

```cmd
rg --files -g "*.cs" -g "*.vb" -g "*.fs"
```

### List project files only

```cmd
rg --files -g "*.sln" -g "*.csproj" -g "*.vbproj" -g "*.fsproj"
```

### List docs/config files only

```cmd
rg --files -g "*.md" -g "*.json" -g "*.yml" -g "*.yaml" -g "*.xml"
```

---

## fzf usage for agents

### Principle

Use `fzf --filter` for deterministic filtering/ranking over `rg` output.

Avoid interactive `fzf` UI unless the task explicitly asks for an interactive picker.

### Rank candidate files by fuzzy query

```cmd
rg --files | fzf --filter "<file-query>"
```

### Rank .NET files by fuzzy query

```cmd
rg --files -g "*.cs" -g "*.vb" -g "*.fs" | fzf --filter "<file-query>"
```

### Search with rg, then rank matches with fzf

Use when `rg` returns many results and a shortlist is needed.

```cmd
rg --vimgrep --smart-case --max-count=100 -g "*.cs" -g "*.vb" -g "*.fs" -e "<pattern>" . | fzf --filter "<secondary-query>"
```

### Search docs/config, then rank matches

```cmd
rg --vimgrep --smart-case --max-count=100 -g "*.md" -g "*.json" -g "*.yml" -g "*.yaml" -g "*.xml" -e "<pattern>" . | fzf --filter "<secondary-query>"
```

---

## Optional interactive mode

Use only when explicitly allowed to operate an interactive terminal UI.

### Interactive file picker

```cmd
rg --files | fzf
```

### Interactive .NET file picker

```cmd
rg --files -g "*.cs" -g "*.vb" -g "*.fs" | fzf
```

Do not use interactive live grep as the default agent workflow.

---

## Hidden files policy

Default:

```cmd
rg --files
```

Opt-in hidden search only when required:

```cmd
rg --files --hidden
```

Opt-in hidden .NET code search:

```cmd
rg --vimgrep --hidden --smart-case --max-count=100 -g "*.cs" -g "*.vb" -g "*.fs" -e "<pattern>" .
```

Use hidden search for:

- `.editorconfig`
- `.github`
- `.config`
- dotfiles
- hidden tracked docs/config

Do not use hidden search as the default repo search mode.

---

## Agent decision tree

### Task: Where is X used?

```cmd
rg --vimgrep --smart-case --word-regexp --max-count=100 -g "*.cs" -g "*.vb" -g "*.fs" -e "<X>" .
```

### Task: Find config key X

```cmd
rg --vimgrep --smart-case --max-count=100 -g "*.json" -g "*.yml" -g "*.yaml" -g "*.xml" -e "<X>" .
```

### Task: Find docs mentioning X

```cmd
rg --vimgrep --smart-case --max-count=100 -g "*.md" -e "<X>" .
```

### Task: Find project/package/framework references

```cmd
rg --vimgrep --smart-case --max-count=100 -g "*.sln" -g "*.csproj" -g "*.vbproj" -g "*.fsproj" -e "<X>" .
```

### Task: Find likely files by fuzzy name

Prefer `fd` for pure name-based file discovery — it is faster and has richer filters:

```cmd
fd <query>
```

When you already have `rg` output and need a secondary fuzzy rank:

```cmd
rg --files | fzf --filter "<query>"
```

### Task: Too many rg results

```cmd
rg --vimgrep --smart-case --max-count=100 -g "*.cs" -g "*.vb" -g "*.fs" -e "<pattern>" . | fzf --filter "<secondary-query>"
```

### Task: How many occurrences / what's the scope?

Use the multi-step overview pattern: sample → count per file → group by folder. See **Aggregation and statistics** section.

### Task: Which domains/folders contain X?

Use the PowerShell tool:

```powershell
rg --smart-case -l -g "*.cs" -g "*.vb" -g "*.fs" -e "<pattern>" . |
  ForEach-Object { $parts = $_ -split '\\'; if ($parts.Count -ge 2) { $parts[1] } else { $parts[0] } } |
  Group-Object | Sort-Object Count -Descending | Format-Table Count, Name -AutoSize
```

---

## Output handling rules

1. For normal search, return at most the top relevant matches.
2. Prefer `--vimgrep` output for search results:
   - `path:line:column:matched text`
3. If output is too large:
   - narrow globs
   - narrow path
   - add `--word-regexp`
   - use `--fixed-strings`
   - pipe to `fzf --filter`
4. Only use context search after identifying candidate files.
5. Do not open full files unless matching lines prove relevance.

---

## Good defaults

### Symbol usage

```cmd
rg --vimgrep --smart-case --word-regexp --max-count=100 -g "*.cs" -g "*.vb" -g "*.fs" -e "<Symbol>" .
```

### Literal string

```cmd
rg --vimgrep --fixed-strings --smart-case --max-count=100 -g "*.cs" -g "*.vb" -g "*.fs" -e "<Literal String>" .
```

### TODO/FIXME/HACK

```cmd
rg --vimgrep --smart-case --max-count=100 -g "*.cs" -g "*.vb" -g "*.fs" -e "\b(TODO|FIXME|HACK)\b" .
```

### Package references

```cmd
rg --vimgrep --smart-case --max-count=100 -g "*.csproj" -g "*.vbproj" -g "*.fsproj" -e "PackageReference" .
```

### Target frameworks

```cmd
rg --vimgrep --smart-case --max-count=100 -g "*.csproj" -g "*.vbproj" -g "*.fsproj" -e "TargetFramework" .
```

### App settings

```cmd
rg --vimgrep --smart-case --max-count=100 -g "appsettings*.json" -e "<setting>" .
```

---

## Aggregation and statistics

Use these when you need scope/counts rather than individual match locations.

### Total match count (Bash)

```bash
rg --smart-case -g "*.cs" -g "*.vb" -g "*.fs" -e "<pattern>" . | wc -l
```

### Count per file, sorted by frequency (Bash)

Use to find the hottest files — most occurrences first.

```bash
rg --smart-case -c -g "*.cs" -g "*.vb" -g "*.fs" -e "<pattern>" . | sort -t: -k2 -rn | head -30
```

### Count by match variant (Bash)

Use when the pattern captures multiple tags (e.g. `TODO|FIXME|HACK`) and you want a breakdown per tag.

```bash
rg --smart-case -o -g "*.cs" -g "*.vb" -g "*.fs" -e "\b(TODO|FIXME|HACK)\b" . | grep -oE "(TODO|FIXME|HACK)" | sort | uniq -c | sort -rn
```

### Group matching files by top-level domain folder (PowerShell)

Use when the repo has a multi-domain layout and you want a per-domain breakdown. Use the **PowerShell tool**, not the Bash tool, for this command.

```powershell
rg --smart-case -l -g "*.cs" -g "*.vb" -g "*.fs" -e "<pattern>" . |
  ForEach-Object { $parts = $_ -split '\\'; if ($parts.Count -ge 2) { $parts[1] } else { $parts[0] } } |
  Group-Object | Sort-Object Count -Descending | Format-Table Count, Name -AutoSize
```

### Multi-step overview pattern

When a pattern returns too many results to read directly, use this three-step sequence:

1. **Sample** — `--vimgrep --max-count=100` to see representative matches
2. **Count** — `-c | sort -t: -k2 -rn | head -30` to find the hottest files
3. **Group** — PowerShell folder grouping to understand domain distribution

---

## When not to use this skill as the final authority

Use `rg` to locate candidate files, but do not rely on regex search alone for:

- semantic rename
- finding interface implementers with certainty
- inheritance hierarchy
- overload resolution
- dead-code proof
- cross-language type resolution

For those, `rg` should only provide candidate locations; semantic tooling should verify.

---

> See also: `/cli-toolkit` for multi-tool pipelines and token-efficient output patterns.

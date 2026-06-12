---
name: cli-toolkit
description: >
  Multi-tool CLI pipelines for token-efficient agentic work — combining fd, rg, fzf, jc, jq,
  yq, gron, bat, sd, and ast-grep into cross-tool workflows. Use this skill when combining two
  or more CLI tools (fd+rg, rg+jc+jq, rg+fzf, yq+jq, gron+rg, rg+sd, ast-grep+jq), when output
  is too large and needs bounding, when deciding which pipeline to use for a task, when quoting
  rules differ between Git Bash / pwsh / cmd.exe, or when preparing an agent handoff paste.
allowed-tools: Bash, PowerShell
---

# cli-toolkit — Multi-Tool Pipeline Reference

For deep flag reference and examples for any individual tool, load its own skill: `/fd-file-search`, `/rg-fzf-dotnet`, `/jc`, `/jq-json-processor`, `/yq`, `/gron`, `/bat`, `/sd`, `/ast-grep`.

**Tool roles at a glance:** fd (find files) · rg (search text) · ast-grep (search code *structure*) · fzf (fuzzy-rank) · bat (view, highlighted) · jc (CLI output → JSON) · jq (filter JSON) · yq (YAML/XML/TOML ↔ JSON) · gron (flatten JSON to greppable lines) · sd (find & replace).

---

## 0 — Non-negotiable rules

Apply these before running any search or parse command:

1. **Search/list before reading.** Prefer `path:line:number` pointers over file blobs. Never read a whole file before running `rg` or `fd` to confirm relevance.
2. **Cap output before pasting.** Always bound with `--max-count N`, `head -n N` (Bash), or `Select-Object -First N` (PowerShell) before the output reaches the model context.
3. **Prefer parseable output.**
   - `rg --vimgrep` → `path:line:col:match` (best default for agent consumption)
   - `rg --json` → JSONL output (when downstream jq filtering is planned)
   - `cmd | jc --<parser> | jq` → bridge any human-readable CLI output to JSON
   - If the source already outputs JSON (e.g. `rg --json`, `curl`), skip `jc` and go straight to `jq`.
4. **Respect `.gitignore` by default.** All tools (rg, fd) follow ignore rules automatically. Add `--hidden` / `-H` / `-I` only when dotfiles or build artefacts are explicitly required.

---

## 1 — Pipeline decision table

Choose a pipeline based on what you have and what you want:

| Task | Pattern | Skills to load |
|---|---|---|
| Find files by name, then search their contents | `fd <name> -e <ext> \| xargs rg --vimgrep -S -e <pattern>` | `/fd-file-search` + `/rg-fzf-dotnet` |
| Narrow a large rg file list | `rg --files -g <glob> \| fzf --filter <query> \| head -n 20` | `/rg-fzf-dotnet` |
| Secondary-rank content matches | `rg --vimgrep ... \| fzf --filter <query>` | `/rg-fzf-dotnet` |
| CLI tool output → structured filter | `<cmd> \| jc --<parser> \| jq -c <filter> \| head -n 50` | `/jc` + `/jq-json-processor` |
| rg structured output → filter (skip jc) | `rg --json ... \| head -n 200 \| jq -c 'select(.type=="match") \| ...'` | `/rg-fzf-dotnet` + `/jq-json-processor` |
| YAML/XML config → JSON → filter | `yq -o json '.' <file> \| jq -c <filter>` | `/yq` + `/jq-json-processor` |
| File metadata → structured query | `fd <pattern> \| xargs stat \| jc --stat \| jq -c <filter>` | `/fd-file-search` + `/jc` |
| Explore unfamiliar JSON / find a key's path | `gron <file> \| rg <key>` (add `\| gron -u` to rebuild) | `/gron` + `/rg-fzf-dotnet` |
| Search code by *structure*, not text | `ast-grep run -p '<pattern>' -l <lang> .` | `/ast-grep` |
| Search-and-replace across matched files | `rg -l <pat> -g <glob> \| xargs sd '<find>' '<replace>'` | `/rg-fzf-dotnet` + `/sd` |
| View a bounded, highlighted slice for citation | `bat --paging=never -n -r <a>:<b> <file>` | `/bat` |

---

## 2 — Output bounding (keep tokens low)

Three bounding strategies in cost order — cheapest first:

**At the source tool (best):**
```bash
rg --max-count 100 ...      # stop after 100 matches total
fd --max-results 50 ...     # stop after 50 file paths
```

**Post-pipe cap:**
```bash
# Bash
rg --vimgrep ... | head -n 80

# PowerShell
rg --vimgrep ... | Select-Object -First 80
```

**Count first, then decide:**
```bash
rg -c -g '*.cs' -e '<pattern>' .        # match count per file — assess scope before fetching
fd -e cs | Measure-Object                # file count — know how many before iterating
```

Rule: always bound before piping to `jc` or `jq` — tokenizing a 10 000-line stream wastes context even if jq filters it down to 10 lines.

---

## 3 — Pipeline recipes

### Recipe 1 — fd → rg: scope rg to matched files
Use when you know a file name and want to search inside just those files.
```bash
fd "<name-pattern>" -e cs | xargs rg --vimgrep -S --word-regexp -e "<symbol>"
# PowerShell (no xargs)
fd "<name-pattern>" -e cs | ForEach-Object { rg --vimgrep -S --word-regexp -e "<symbol>" $_ }
```
Use `--word-regexp` when searching for a symbol name to avoid partial-word matches.
→ See `/fd-file-search` and `/rg-fzf-dotnet` for flag reference.

### Recipe 2 — rg --files | fzf --filter: fuzzy-narrow a file list
Use when you have a partial name and want the top candidates without reading directories.
```bash
rg --files -g "*.cs" | fzf --filter "<fuzzy-query>" | head -n 20
```
→ See `/rg-fzf-dotnet` for flag reference.

### Recipe 3 — rg | fzf --filter: secondary-rank content matches
Use when rg returns too many results and a fuzzy secondary pass is needed.
```bash
rg --vimgrep -S -g "*.cs" -e "<pattern>" . | fzf --filter "<secondary-query>" | head -n 30
```
→ See `/rg-fzf-dotnet` for flag reference.

### Recipe 4 — cmd | jc | jq: parse CLI tool output, filter fields
Use for any command that outputs human-readable text (git log, ps, df, netstat, etc.).
```bash
<command> | jc --<parser> | jq -c '<filter>' | head -n 50
# git log → minimal projection
git log | jc --git-log | jq -c '.[] | {commit: .commit[:7], author, date}' | head -n 20
# ps → only high-CPU processes
ps aux | jc --ps | jq -c '.[] | select(.cpu_percent > 20) | {pid, command, cpu_percent}'
# ls -l → name + size only
ls -l | jc --ls | jq -c '.[] | {filename, size}' | head -n 50
```
→ See `/jc` for the parser list and `/jq-json-processor` for filter syntax.

### Recipe 5 — rg --json | jq: rg already outputs JSON, skip jc
Use when you need structured field access on match objects (path, line number, text).
```bash
rg --json -S -g "*.cs" -e "<pattern>" . | head -n 200 \
  | jq -c 'select(.type=="match") | {file: .data.path.text, line: .data.line_number, text: .data.lines.text}'
```
→ See `/rg-fzf-dotnet` and `/jq-json-processor`.

### Recipe 6 — yq | jq: YAML config → JSON → filter
Use when a config file is YAML but downstream logic needs jq's query power.
```bash
yq -o json '.' <config.yml> | jq -c '<filter>'
# Example: extract all service images from docker-compose
yq -o json '.' docker-compose.yml | jq -r '.services | to_entries[] | {name: .key, image: .value.image}'
```
→ See `/yq` and `/jq-json-processor`.

### Recipe 7 — gron → rg: find a path in unfamiliar JSON, then rebuild
Use when you can see a value but don't know its jq path, or to grep deeply nested JSON.
```bash
gron response.json | rg -i "<key-or-value>"                 # discover the path
gron response.json | rg '^json\.data\.users\[\d+\]\.email' | gron -u   # extract + rebuild JSON
```
→ See `/gron`; once the path is known, prefer a single `jq` projection for repeat extracts.

### Recipe 8 — ast-grep → jq: structural match, minimal report
Use when a text search is too noisy and you need a code *shape* (call arity, construct).
```bash
ast-grep run -p 'catch ($$$) { }' -l csharp --json src/ \
  | jq -c '.[] | {file, line: .range.start.line}' | head -n 50
```
→ See `/ast-grep` (search) and `/jq-json-processor` (projection).

### Recipe 9 — rg -l → sd: scoped search-and-replace
Use to rewrite a symbol or string only in files that actually contain it. Preview first.
```bash
rg -l 'OldName' -g '*.cs' | xargs sd -p 'OldName' 'NewName'   # PREVIEW the diff
rg -l 'OldName' -g '*.cs' | xargs sd    'OldName' 'NewName'   # apply (in place, no backup)
rg -c 'NewName' -g '*.cs' .                                   # verify after
```
→ See `/rg-fzf-dotnet` and `/sd`. Run via the **Bash tool** so `xargs` receives the byte stream.

---

## 4 — Platform quoting & shell choice

On Windows, run native-tool pipelines (`rg | jq`, `fd | xargs …`) through the **Bash tool (Git Bash)** — it passes raw byte streams between executables unchanged, so nothing can re-encode and corrupt matches. That is the default for every recipe above.

When you genuinely need PowerShell (object pipelines, `Select-Object`, `Measure-Object`, Windows-only cmdlets), use **PowerShell 7 (`pwsh`)** rather than Windows PowerShell 5.1 — its pipe I/O is markedly safer:

- `$OutputEncoding` defaults to **UTF-8**, so text piped between native tools keeps Unicode intact. 5.1 re-encodes that stream (ASCII/UTF-16) and silently mangles non-ASCII bytes — a real footgun for source search.
- Supports `&&` / `||` chaining and does **not** wrap a native command's stderr as a terminating `NativeCommandError`, so exit-code logic behaves like Bash.

If the harness PowerShell tool is 5.1, invoke pwsh explicitly (it runs fine via the Bash tool too):
```
pwsh -NoProfile -Command 'rg --vimgrep -S -e "<pat>" . | Select-Object -First 80'
```

**Quoting:**

| Shell | jq filter quoting | rg / fd pattern quoting |
|---|---|---|
| **Bash (Git Bash)** | `jq '.items[] \| {id, name}'` — single quotes | `rg -e 'pattern'` — single quotes |
| **pwsh / PowerShell** | `jq '.items[] \| {id, name}'` — single quotes work | `rg -e 'pattern'` — single quotes work |
| **cmd.exe** | `jq ".items[] \| {id, name}"` — double quotes; escape `\|` as `^|` | `rg -e "pattern"` — double quotes |

PowerShell's `|` is always the PS pipeline operator (passes objects, not raw text). For the heaviest native→native byte streams, prefer the **Bash tool** regardless of which PowerShell is installed.

---

## 5 — Agent handoff paste template

Use this format when handing off search results at the end of a multi-step task, to keep the next agent's context minimal:

```
GOAL: <one line>
COMMANDS RUN:
- <cmd1>
- <cmd2>

TOP RESULTS (<= 30-80 lines):
<path:line:col:match or JSON or key:value...>

NEXT ACTION:
- <what Claude should do next>
```

Keep "TOP RESULTS" to 30–80 lines. If more lines are needed, summarise in "COMMANDS RUN" and paste only the highest-signal subset.

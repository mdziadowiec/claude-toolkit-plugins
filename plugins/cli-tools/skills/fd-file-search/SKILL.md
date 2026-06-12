---
name: fd-file-search
description: >
  Find files and directories by name, extension, path pattern, or type using `fd` — the fast,
  user-friendly alternative to `find`. Use this skill whenever the task is to locate files
  (not their contents): "find all .cs files", "where is the appsettings file?", "list all
  csproj files under BMS.NET", "find files matching *Controller*", "locate the Dockerfile".
  Prefer fd over rg --files for pure file-discovery tasks — it is faster, supports richer
  filters (type, depth, extension, owner), and produces cleaner output. Use rg-fzf-dotnet
  instead when you need to search file *contents* for symbols, text, or patterns.
allowed-tools: Bash, PowerShell
---

# fd — Agent File Search

## Purpose

Use `fd` to answer "which files exist?" questions — by name, extension, path segment, type, or
any combination. Do not use it to search file contents; that is `rg`'s job.

---

## Non-negotiable rules

1. Prefer `fd` over `rg --files` for file-discovery tasks — it is significantly faster on large
   repos and has dedicated filters for type, extension, depth, and modification time.
2. By default `fd` follows `.gitignore` and skips hidden files, which is usually what you want
   in this repo. Add `-I` (no-ignore) or `-H` (hidden) only when the task calls for it.
3. Patterns are **case-insensitive smart-case** by default (like ripgrep): all-lowercase → case-
   insensitive; any uppercase → case-sensitive. Use `-s` to force case-sensitive.
4. Patterns are **regular expressions** by default. Use `-g` for glob syntax or `-F` for literals.
5. Always scope the search to the narrowest path that makes sense — do not scan the entire repo
   when you know the domain (`BMS.NET/`, `RBL.NET/`, etc.).
6. Limit output when needed: `--max-results N` to cap the list.

---

## Core patterns

### Find any file whose name matches a pattern

```powershell
fd <pattern>
```

Example: `fd ServiceController` → finds any path containing `ServiceController`.

### Find by extension

```powershell
fd -e cs           # all .cs files
fd -e csproj       # all .csproj files
fd -e json         # all .json files
```

Multiple extensions:

```powershell
fd -e cs -e vb     # C# and VB.NET source files
```

### Find by type

```powershell
fd -t f <pattern>  # files only
fd -t d <pattern>  # directories only
fd -t l <pattern>  # symlinks only
```

### Combine pattern + extension

```powershell
fd -e cs Controller           # .cs files with "Controller" in path
fd -e json appsettings        # appsettings*.json files
fd -e csproj "" BMS.NET/      # every .csproj under BMS.NET/ (empty pattern = no name filter)
```

### Scope to a subdirectory

```powershell
fd <pattern> BMS.NET/
fd <pattern> RBL.NET/Dev/Main
fd <pattern> PIF.NET/ LIB.NET/   # multiple roots
```

### Limit search depth

```powershell
fd -d 2 <pattern>  # at most 2 directory levels deep
fd -d 1 -t d       # direct subdirectories only
```

---

## .NET monorepo recipes

### Locate a specific source file by class/file name

```powershell
fd -e cs JourneyService
fd -e cs IVehicleRepository
```

### Find all project files in a domain

```powershell
fd -e csproj "" BMS.NET/
fd -e csproj -e vbproj "" RBL.NET/
```

### Find solution files

```powershell
fd -e sln
```

### Find appsettings files

```powershell
fd -g "appsettings*.json"
```

### Find Dockerfiles and pipeline YAMLs

```powershell
fd -g "Dockerfile*"
fd -e yml "" .pipelines/
```

### Locate test projects

```powershell
fd -e csproj Tests
fd -e csproj -g "*Tests*"
```

### Find all files modified recently (last 1 day)

```powershell
fd --changed-within 1d -e cs
```

---

## Excluding noise

### Exclude bin/obj (default gitignore already handles these; use only when -I is active)

```powershell
fd -I -e cs --exclude bin --exclude obj <pattern>
```

### Skip a specific directory tree

```powershell
fd <pattern> --exclude CBS     # skip customer-specific folder
fd <pattern> --exclude Tools
```

---

## Hidden and ignored files

```powershell
fd -H <pattern>           # include hidden files/dirs
fd -I <pattern>           # include gitignore-d files
fd -H -I <pattern>        # include both hidden and ignored
```

Use `-H` when looking for dotfiles (`.editorconfig`, `.gitignore`, `.env`).
Use `-I` when searching in `bin/`, `obj/`, or other ignored build artefacts.

---

## Glob and literal modes

```powershell
fd -g "*.razor"           # glob syntax
fd -g "*Controller*.cs"   # glob with multiple wildcards
fd -F "Directory.Build"   # exact literal substring match
```

---

## Execute commands on results

### Run a command per file (`-x`, one invocation per result)

```bash
fd -e cs -x wc -l {}      # count lines in each .cs file (Bash tool — wc is POSIX)
```

```powershell
fd -e cs | ForEach-Object { (Get-Content $_).Count }   # PowerShell equivalent
```

### Run one command with all results as arguments (`-X`, one batch invocation)

```powershell
fd -e csproj -X rg --files-with-matches -e "Nullable"  # find projects referencing Nullable
```

Note: use `-x` (per-file) for commands that take a single path argument (e.g. `dotnet build`);
use `-X` (batch) only for commands that accept multiple paths at once (e.g. `rg`, `grep`).

```powershell
fd -e csproj -x dotnet build {}   # build each project individually
```

Placeholders: `{}` full path · `{/}` filename · `{//}` parent dir · `{.}` path without ext · `{/.}` stem.

---

## Counting and statistics

### Count matching files

```powershell
fd -e cs | Measure-Object -Line   # counts the number of .cs files found, not lines of code
```

### Files per subdomain (PowerShell)

```powershell
fd -e cs -t f |
  ForEach-Object { ($_ -split '\\')[0] } |
  Group-Object | Sort-Object Count -Descending | Format-Table Count, Name -AutoSize
```

---

## Decision guide

| Question | Command |
|---|---|
| Where is the file named X? | `fd -F X` |
| All .cs files in domain Y? | `fd -e cs "" Y/` |
| All project files? | `fd -e csproj -e sln` |
| Directories named like X? | `fd -t d X` |
| Files changed today? | `fd --changed-within 1d` |
| File contents containing X? | → use `rg-fzf-dotnet` instead |

---

## Combining fd with rg (fd → rg pipelines)

Use `fd` to locate candidate files by name/path, then pipe into `rg` to search inside only those
files. This keeps context small and avoids scanning irrelevant trees.

Run these via the **Bash tool** (xargs is a POSIX utility):

### Find file(s) by name, then search inside just those hits

```bash
fd "UserService" -e cs | xargs rg -n -S -e "HttpClient"
```

Good default: narrow to one class/module first, then look for what it uses.

### Find all VB files, search inside for event handlers

```bash
fd -e vb | xargs rg -n -S -e "Handles\s+\w+\.Click"
```

### Find all files in a domain, search for a pattern inside them

```bash
fd -e cs "" BMS.NET/ | xargs rg -n -S -e "IOptions<"
```

### PowerShell equivalent (when Bash is not available)

```powershell
fd "UserService" -e cs | ForEach-Object { rg -n -S -e "HttpClient" $_ }
```

### Tips

- Prefer `-e "<pattern>"` with `rg` so patterns starting with `-` are not misread as flags.
- Keep results small: narrow `fd` by extension and path before piping.
- For a quick "what filename contains X?" without opening files, `fd -F X` is faster than
  `rg --files | rg X`.

---

## When not to use fd

- **Content search** (symbols, text, regexes inside files) → use `rg-fzf-dotnet`
- **Semantic navigation** (callers, implementors, type hierarchy) → use `dotnet-lens-mcp`

---

> See also: `/cli-toolkit` for multi-tool pipelines and token-efficient output patterns.

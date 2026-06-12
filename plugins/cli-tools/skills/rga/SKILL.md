---
name: rga
description: >
  Search inside PDFs, Office documents (docx, xlsx, pptx, odt), E-Books (epub), archives
  (zip, tar.gz, gz, bz2, xz, 7z), SQLite databases (.db, .sqlite), and other binary/document
  files using rga (ripgrep-all). Invoke this skill whenever the user wants to find text
  inside document or archive files — any mention of "PDF", "Word doc", "Excel", "spreadsheet",
  "epub", "zip", "archive", searching "documents", or finding content "inside files". rga
  wraps ripgrep so all rg flags work unchanged; it's the right tool any time rg would silently
  skip the file. Install: scoop install ripgrep-all.
allowed-tools: Bash, PowerShell
---

# rga — Search Non-Plaintext Files

## When to use rga vs rg

`rg` silently skips binary files. `rga` adds adapters that extract text first, then search.
Use `rga` for:
- Documents: `.pdf`, `.docx`, `.xlsx`, `.pptx`, `.odt`, `.ods`, `.odp`
- E-Books: `.epub`
- Archives: `.zip`, `.tar`, `.tar.gz`, `.gz`, `.bz2`, `.xz`, `.7z`
- Databases: `.db`, `.sqlite`

Use `rg` for plain text, source code, config, and Markdown. rga is slower because extraction
has overhead — avoid it on codebases.

## Installation

```powershell
scoop install ripgrep-all   # core tool
scoop install poppler        # optional: enables PDF text extraction
rga --version               # verify
rga --rga-list-adapters     # list all supported formats
```

## Core searches

### Search everything under a path

```bash
rga --smart-case --max-count=100 -e "<pattern>" "<path>"
```

### Get matching file names first (faster starting point)

```bash
rga --smart-case -l -e "<pattern>" "<path>"
```

Start with `-l` when searching a large directory — rga must extract text from every file it
visits, which is expensive. Getting the file list first lets you decide which files to examine
in full before committing to that work.

### Literal string (pattern contains regex metacharacters)

```bash
rga --fixed-strings --smart-case --max-count=100 -e "<literal>" "<path>"
```

### With surrounding context

```bash
rga --smart-case --max-count=50 -C 2 -e "<pattern>" "<path>"
```

## Narrow by format

Skip adapters for formats you don't care about — it makes searches much faster:

```bash
# PDFs only
rga --smart-case --max-count=100 -g "*.pdf" -e "<pattern>" "<path>"

# Office documents
rga --smart-case --max-count=100 -g "*.docx" -g "*.xlsx" -g "*.pptx" -e "<pattern>" "<path>"

# E-Books
rga --smart-case --max-count=100 -g "*.epub" -e "<pattern>" "<path>"

# Archives (searches inside the archive contents)
rga --smart-case --max-count=100 -g "*.zip" -g "*.tar.gz" -e "<pattern>" "<path>"

# SQLite databases
rga --smart-case --max-count=100 -g "*.db" -g "*.sqlite" -e "<pattern>" "<path>"
```

## Combining with fd

Use `fd` to locate candidate files by name, then pass them to `rga`:

```bash
# PDFs with "report" in the filename, then search inside them
fd -e pdf "report" "<path>" | xargs rga --smart-case --max-count=100 -e "<pattern>"

# All Word docs, files-with-matches first
fd -e docx "<path>" | xargs rga --smart-case -l -e "<pattern>"
```

## Adapter control

```bash
# List adapters and their extensions
rga --rga-list-adapters

# Restrict to a single adapter (avoids trying adapters that won't match)
rga --rga-adapters=pdf -e "<pattern>" "<path>"
rga --rga-adapters=office -e "<pattern>" "<path>"
rga --rga-adapters=zip -e "<pattern>" "<path>"
rga --rga-adapters=sqlite -e "<pattern>" "<path>"

# Force re-extraction (skip cache after files changed)
rga --rga-no-cache -e "<pattern>" "<path>"

# Debug: see what rga extracts from one file
rga-preproc "<file>"
```

## Decision guide

| Task | Command |
|---|---|
| Search PDFs | `rga --smart-case -g "*.pdf" -e "<pattern>" "<path>"` |
| Search Word / Excel / PowerPoint | `rga --smart-case -g "*.docx" -g "*.xlsx" -g "*.pptx" -e "<pattern>" "<path>"` |
| Search E-Books | `rga --smart-case -g "*.epub" -e "<pattern>" "<path>"` |
| Search zip / tar archives | `rga --smart-case -g "*.zip" -g "*.tar.gz" -e "<pattern>" "<path>"` |
| Search SQLite | `rga --smart-case -g "*.db" -g "*.sqlite" -e "<pattern>" "<path>"` |
| Unknown format | `rga --smart-case -l -e "<pattern>" "<path>"` (file list first) |
| Plain text / code / config | → use `rg` instead |

---

> See also: `/fd-file-search` to locate files before searching, `/rg-fzf-dotnet` for text/code search, `/cli-toolkit` for multi-tool pipelines.

---
description: Export the current Claude Code session to a clean markdown file using cc2md. Optionally pass an output path; defaults to <project>-session.md in the working directory.
---

# /export-md — export the current session to markdown

Convert the **current** Claude Code session (this conversation) into a shareable
markdown file using [`cc2md`](https://github.com/magarcia/cc2md).

`$ARGUMENTS` — optional output file path. If empty, default to
`<cwd-basename>-session.md` in the current working directory.

## Step 1 — Resolve the cc2md binary

Find a usable `cc2md` in this order and remember the resolved path as `$CC2MD`:

1. On `PATH` — `command -v cc2md`.
2. The plugin-managed copy — `$HOME/.claude/bin/cc2md.exe` (Windows) or
   `$HOME/.claude/bin/cc2md` (macOS/Linux).
3. If neither exists, **install it** (see "Installing cc2md" below), then use the
   path from step 2.

## Step 2 — Find the current session

The "current session" is the most-recently-modified session for the **current
project directory**. Do NOT use `cc2md --last 1` — that picks the newest session
across *all* projects, which is usually a different project.

Instead, list sessions filtered to this project and take the first (newest) entry:

```bash
"$CC2MD" list "$(basename "$PWD")" --json
```

Read the JSON yourself: the array is sorted newest-first, so element `[0]` is the
current session. Take its `path` field (the absolute path to the `.jsonl`).
Sanity-check that `[0].project` looks like an encoding of the current directory
(e.g. cwd `D:\Claude\foo` → project `D--Claude-foo`); if it doesn't match, tell
the user and stop rather than exporting the wrong session.

## Step 3 — Export

```bash
"$CC2MD" "<path-from-step-2>" --raw --output "<output-file>"
```

- `--raw` writes clean GitHub-flavored markdown (no terminal ANSI styling).
- Tool calls and thinking are collapsed into `<details>` blocks by default
  (`--collapse`), which keeps the file readable. Add `--thinking` only if the user
  asks to include reasoning blocks.

## Step 4 — Repair nested code fences

cc2md (v0.1.0) wraps each tool output in a 3-backtick fence without lengthening it
when the output itself contains ``` fences (README fetches, file reads, files
written). The inner fence then closes the wrapper early and the rest of the
document mis-renders. Always run the bundled repair pass over the exported file:

```
pwsh -NoProfile -ExecutionPolicy Bypass -File "${CLAUDE_PLUGIN_ROOT}/scripts/fix-fences.ps1" -Path "<output-file>"
```

(Use `powershell` instead of `pwsh` if PowerShell 7+ is unavailable.) It lengthens
only the wrapper fences inside `<details>` blocks — prose is untouched — so embedded
``` blocks render as literal output. It reports how many wrappers it repaired.

Then report the written file path to the user.

## Installing cc2md (only if missing)

Prefer the bundled installer — it downloads the prebuilt GitHub release binary
into `$HOME/.claude/bin` and adds it to PATH (Windows, PowerShell 7+):

```
pwsh -NoProfile -ExecutionPolicy Bypass -File "${CLAUDE_PLUGIN_ROOT}/scripts/install-tools.ps1"
```

This is the same script run by the `/install-tools` command for this plugin.
(The script also runs under Windows PowerShell 5.1 — use `powershell` if `pwsh`
is unavailable.)

If you can't run the script, install manually instead — prefer
`go install github.com/magarcia/cc2md@latest` if Go is on PATH, otherwise download
the prebuilt binary for the platform into `$HOME/.claude/bin`:

```bash
# Windows
BIN="$HOME/.claude/bin"; mkdir -p "$BIN"; TMP="$(mktemp -d)"; cd "$TMP"
curl -sL -o cc2md.zip https://github.com/magarcia/cc2md/releases/latest/download/cc2md_Windows_x86_64.zip
unzip -o cc2md.zip && cp cc2md.exe "$BIN/cc2md.exe" && "$BIN/cc2md.exe" --version
```

For macOS / Linux, download the matching `cc2md_<OS>_<arch>.tar.gz` from the
releases page, extract `cc2md` into `$HOME/.claude/bin`, and `chmod +x` it.

Installation is one-time; subsequent `/export-md` runs reuse the resolved binary.

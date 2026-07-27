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

The "current session" is the newest session log for the **current project
directory**, inside the **active config directory**.

Do NOT locate it with `cc2md` — neither subcommand is safe here:

- `cc2md --last 1` picks the newest session across *all* projects.
- `cc2md list` (v0.1.0) always reads `$HOME/.claude/projects` and **ignores
  `$CLAUDE_CONFIG_DIR`**. On a machine whose config directory is relocated
  (`CLAUDE_CONFIG_DIR=~/.claude-private`, say), it lists sessions from the wrong
  tree while still reporting a correct-looking `project` field — so the usual
  sanity check passes and you silently export an unrelated conversation.

Resolve the path yourself instead. Prefer the session id — it names the log file
directly, so it is exact and does not care what the shell's working directory is:

```bash
CFG="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
ls "$CFG"/projects/*/"$CLAUDE_CODE_SESSION_ID".jsonl 2>/dev/null | head -1
```

Use that whenever `$CLAUDE_CODE_SESSION_ID` is set. Only if it is empty (older
Claude Code, or a non-CLI entrypoint) fall back to deriving the project directory
from the working directory:

```bash
PROJ="$(pwd -W 2>/dev/null || pwd)"              # Windows-style path under Git Bash
SLUG="$(printf '%s' "$PROJ" | tr ':\\/' '-')"    # D:/Claude -> D--Claude
ls -t "$CFG/projects/$SLUG"/*.jsonl 2>/dev/null | head -1
```

Note this second form is only as good as the shell's cwd. A `cd` earlier in the
session leaves it pointing at a subdirectory, which yields a slug for a project
directory that does not exist (`D--Claude-subdir`) and finds nothing. When that
happens, match instead on the working directory each session records internally.
The `cwd` value is stored JSON-escaped (cwd `D:\Claude` appears as
`"cwd":"D:\\Claude"`):

```bash
WIN="${PROJ//\//\\}"                             # D:/Claude -> D:\Claude
NEEDLE='"cwd":"'"${WIN//\\/\\\\}"'"'             # -> "cwd":"D:\\Claude"
for f in $(ls -t "$CFG"/projects/*/*.jsonl 2>/dev/null); do
  if grep -qF "$NEEDLE" "$f"; then echo "$f"; break; fi
done
```

If none of the three locates a file, tell the user and stop rather than exporting
an unrelated session.

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

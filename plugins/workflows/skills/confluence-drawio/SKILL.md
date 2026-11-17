---
name: confluence-drawio
description: >
  Update draw.io diagrams and page text on Confluence Cloud pages: download a page and its diagram XML through the
  REST API, edit the XML and the page body (ADF), publish the text with a version check, save each diagram through
  the draw.io editor in the user's Chrome, and verify that every diagram revision matches its attachment.
  Use it whenever the user wants a draw.io diagram on a Confluence page changed, redrawn, fixed or brought up to date,
  wants Confluence documentation checked against the code ("are these pages still up to date", "some classes were
  removed since the docs were written"), or asks why Claude cannot edit the draw.io diagrams on a page — even if they
  only paste a Confluence page link and say "update the diagrams".
  Not for creating a new page from scratch without diagrams, Jira work, or Mermaid/PlantUML macros.
---

# Confluence draw.io diagrams and page text

The Atlassian MCP reads and writes page bodies but not attachments, and a draw.io diagram lives in attachments.
This skill fills that gap: REST calls with the user's API token for reading and for the page text, and the draw.io
editor in the user's Chrome for saving diagrams, because draw.io's own save keeps its four pieces in step.

## How draw.io stores a diagram

| Piece | Holds |
|---|---|
| Attachment `<diagramName>` (`application/vnd.jgraph.mxfile`) | The diagram as plain, uncompressed mxGraph XML |
| Attachment `<diagramName>.png` | The preview image the page shows; draw.io re-renders it on save |
| Custom content `ac:com.mxgraph.confluence.plugins.diagramly:drawio-diagram` (the macro's `custContentId`) | `{diagramName, version, …}` |
| The macro in the page body | `diagramName`, `revision`, `contentVer` |

A save raises the attachment version, the custom content version and the macro `revision` together, and writes a
new preview. Replaying that over REST is possible but undocumented and leaves a stale preview when one step is off;
saving through the editor avoids that. `~….drawio.tmp` attachments are draw.io drafts: ignore them.

## Credentials

Scripts read the user environment variables `ATLASSIAN_API_TOKEN`, `ATLASSIAN_EMAIL` and `ATLASSIAN_SITE`
(for example `example.atlassian.net`; `-Site` overrides it). If they are missing, ask the user to create a token at
id.atlassian.com (no scopes needed) and store it themselves, so the value never enters the conversation:

```powershell
[Environment]::SetEnvironmentVariable('ATLASSIAN_API_TOKEN', (Read-Host -AsSecureString 'Token' | ConvertFrom-SecureString -AsPlainText), 'User')
```

Never search the disk for a token. If the user pastes one into the chat, store it as above and mention that it is
now in the transcript.

## Workflow

Scripts are in `scripts/` next to this file; run the PowerShell ones with `pwsh` or the PowerShell tool, the Python
ones with `python3 -I`. Work in the session scratchpad.

### 1. Download

```powershell
scripts\Get-ConfluencePage.ps1 -PageId <id> -OutDir <dir> [-IncludeChildren]
```

It writes `page-<id>.json` (ADF), `page-<id>.meta.json` (title, version) and `drawio\<id>-<name>` per diagram, and
prints `ok` or `MISMATCH` per diagram (macro revision vs attachment version). A `MISMATCH` before you start means
someone saved a diagram without updating the page; tell the user.

### 2. Find what is out of date (when the user asks for a check)

- `python3 -I scripts/adf_to_text.py <dir>` writes `text\<id>.md` per page, with each diagram's labels under it:
  the readable form to review or to hand to subagents.
- `python3 -I scripts/audit_names.py <dir> <dir>\names.tsv` lists every code-style name in the pages and diagrams.
  Compare the names with the identifiers of the code the pages describe, for example
  `rg -o -I --no-filename -g '*.cs' -g '*.vb' '[A-Za-z_][A-Za-z0-9_]*' <src> | sort -u > idents.txt` and
  `comm -23 <(cut -f1 names.tsv | sort -u) idents.txt`. Names that are gone are the fastest signal of stale pages;
  statements about behaviour still need a reading against the code.
- Check against the branch the documentation will describe, including uncommitted work if the user says so; ask when
  several worktrees exist.
- For many pages, give each subagent two or three related pages, the text files, the code paths and the list of
  gone names, and ask for `page | where | wrong | true now with file:line | severity`.

### 3. Draft the changes as files

- **Page text:** edit the ADF JSON with a script, not by hand. Read `references/editing-rules.md` first: it says what
  must survive (inline comments, macros) and how to write the text.
- **Diagrams:** edit the downloaded XML. Same reference, section "Diagram XML".
- Check every draft: `python3 -I scripts/review_page.py <original.json> <draft.json>` prints the text diff and
  confirms that inline comments and macros are kept.
- Show the user the changes per page (a short table: section, change) and wait for an OK before publishing. The pages
  are read by the user's team; publishing is visible at once.

### 4. Publish the text

```powershell
scripts\Publish-ConfluencePage.ps1 -PageId <id> -AdfFile <draft.json> -ExpectedVersion <version from meta> [-Title <new title>]
```

It refuses when the live version differs from the one the draft was based on. Publish the text before opening the
page in the editor, so the editor starts from the new text and the later Update carries only diagram revisions.

### 5. Save each diagram through the draw.io editor

Follow `references/browser-procedure.md`. In short: open `/wiki/spaces/<space>/pages/edit-v2/<id>`, select the
diagram block by its drag handle, open draw.io with the block's Edit button, replace the XML in Extras > Edit
Diagram, check a screenshot, then Publish in draw.io. Check the clipboard right before each paste.

### 6. Update the page and verify

- `scripts\Compare-PageDraft.ps1 -PageId <id>`: the draft text must equal the published text; only the saved
  diagrams' revisions may differ.
- Show the user what the diagrams now say (and let them look in the Chrome tab), get an OK, then click **Update**.
- Run `Get-ConfluencePage.ps1` again: every diagram must print `ok`, and the page version must have risen.

## Things that went wrong before

- An Update click did not publish once: always confirm the new version through the API, not the toast.
- The draft API (`?get-draft=true`) lagged the editor by minutes: read the macro `revision` from the editor DOM
  (browser procedure, step 8) before concluding a save failed.
- The draw.io editor sometimes hangs on its loading screen: reload the page editor; saved diagrams stay in the draft.
- A screenshot can show a correct diagram whose arrows overlap or whose boxes are misaligned: zoom in on each changed
  area, and fix the XML rather than accept a messy layout. Users notice alignment.

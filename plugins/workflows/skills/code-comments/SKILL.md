---
name: code-comments
description: Rules for writing or reviewing inline code comments — the `//`, `#`, `'`, or `--` comments inside function bodies, as opposed to XML/API doc comments (see the dotnet-xml-docs skill for those). Covers whether a comment is warranted at all, always writing comments in English regardless of the surrounding codebase or conversation language, never narrating the edit/refactor/session that produced the code, placement and form, TODO conventions, and keeping comments from going stale. Apply automatically whenever writing new code that includes a comment, editing an existing comment, or reviewing a diff for comment quality — this applies by default and doesn't need to be asked for separately.
---

# Code Comment Best Practices

Rules for the comments that live inside code — not API documentation comments (C#/VB.NET XML doc comments are covered by `dotnet-xml-docs`). These apply any time a comment is written or touched, in any language.

## Whether to comment at all

- **Default to no comment.** Well-named identifiers and code structured for the reader already say *what* the code does — a comment repeating that adds noise, not information.
- **Add a comment only when it captures something the code can't express on its own**: a hidden constraint, a non-obvious invariant, a workaround for a specific bug (ideally with a reference — see TODO conventions below), or a subtlety that would otherwise surprise a future reader.
- **If you're tempted to explain *what* a block does, try renaming or extracting first.** A well-named helper function replaces a comment more durably than the comment itself does.
- **Never leave code commented out "just in case."** Delete it — version control already preserves the history, and a reader can't tell dead code from something intentionally disabled.

## Always write in English

- Write every code comment in English, regardless of the codebase's domain, the language of surrounding UI strings or data, the team's spoken language, or the language the current conversation happened in.
- This holds even when identifiers are already in another language (rename toward English where practical; at minimum, comment in English), or when translating a comment copied from a non-English source.
- **Why:** English comments stay searchable and reviewable by any contributor, and by tooling (linters, static analysis, search) that's typically tuned for English — a comment in the requester's language is a barrier for the next person who touches the file and doesn't share it.

## Don't narrate the change that produced the code

A comment is read by someone with no memory of the refactor, review, or conversation that produced it. It should describe the code as it stands *now*, as if it had always looked this way.

- **Don't narrate the edit itself**: avoid "Refactored to...", "Renamed from `x`...", "Fixed a bug where...", "Simplified this to...". Describe current behavior, not the edit — that belongs in the commit message, not the comment.
- **Don't compare to a previous version of the code.** "No longer," "used to," "instead of the old approach" all assume the reader saw a version they never saw.
- **Don't reference the current session, task, or conversation** ("as discussed," "per your request," "for this fix"). That context doesn't travel with the code.
- **Exception**: a durable, independently-findable reference — a ticket ID on a `TODO`, a link to an issue explaining *why* a workaround exists — is fine and encouraged. The distinction is durability: a ticket ID resolves for anyone, anytime; "as discussed above" resolves for no one once the conversation is gone.

## Placement and form

- Put a comment directly above the line or block it describes, at the same indentation — reserve short trailing comments for brief annotations, not explanations that need room.
- Keep it short, ideally one line. If it needs several sentences, that's usually a sign the logic belongs in a design doc or ADR, or that the code itself needs restructuring — not that the comment needs to be longer.
- Match the comment syntax to the language, e.g.:

  | Language | Syntax |
  |---|---|
  | C#, JS/TS, Go, Java | `//` |
  | VB.NET | `'` |
  | Python, PowerShell, Bash | `#` |
  | SQL | `--` |

- Comment for the "why," not the "what," once the reader has any familiarity with the language — don't narrate syntax that's obvious to anyone who reads the language at all.

## TODO / FIXME conventions

- Use a consistent marker (`TODO`, `FIXME`, `HACK`) followed by a concrete, actionable statement — not a vague "fix later."
- If the project tracks work in an issue tracker, attach the ID: `TODO(PTCRBS-1234): ...`. That's a durable pointer to tracked work, not a session reference, so it's fine even though it looks similar to what's disallowed above.
- Remove a `TODO` once it's resolved — a stale one signals unfinished work that isn't actually unfinished, which is worse than no comment at all.

## Keep comments from going stale

- When you change code a comment describes, update or delete that comment in the same change. A comment that contradicts the code beside it is worse than no comment — a reader has no way to know which one is wrong.
- Delete comments that no longer apply rather than leaving them for someone else to notice and clean up.

## Self-review checklist

Before leaving a comment in a diff:

1. Does it explain something the code itself can't (a "why"), rather than restating the "what"?
2. Is it written in English?
3. Does it describe only the current code — no "refactored," "used to," "renamed," or reference to this session/conversation/task, aside from a durable ticket ID on a `TODO`?
4. Is it placed directly above the code it describes, and does it still match that code?

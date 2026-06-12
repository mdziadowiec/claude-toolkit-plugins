---
name: handoff
description: >
  Produces a structured handoff note for a deferred or in-progress issue.
  Invoke when the user types "/handoff [topic]" or asks to "write a handoff",
  "document this for later", "leave a note on this issue", or similar.
  The note captures current state, what was decided, what remains, and all
  relevant code locations — enough for a fresh session to continue without
  re-deriving context.
---

# Handoff Skill

When invoked, write a Markdown handoff note and save it to `docs/handoffs/<kebab-topic>.md`
(create the `handoffs/` subdirectory if absent). If the user specifies a different location, use that.

## Note structure

```markdown
# Handoff: <Title>

**Date:** <YYYY-MM-DD>
**Status:** Deferred / In-progress / Blocked — one line on why it stopped here

## Context

2-4 sentences: what problem this is solving and why it matters.
Enough that a reader with no prior context can understand the motivation.

## Current state

What has already been done. Be specific: file names, method names, what was changed and why.
If tests exist, say so.

## The issue / what remains

Precisely what is wrong, missing, or needs a decision.
Call out any known traps, edge cases, or design constraints discovered during this work.

## Recommended next step

One concrete, actionable first thing to do. If multiple approaches exist, list them with a
recommendation and the key tradeoff.

## Relevant locations

| File | Symbol / section | What it does |
|------|-----------------|--------------|
| path/to/file.cs | ClassName.MethodName | ... |
```

## Guidelines

- Write for someone (or a future session) that has not seen this conversation.
- Be specific about line numbers or method names when they are stable.
- Do not repeat information already in comments or CLAUDE.md — link to them instead.
- 

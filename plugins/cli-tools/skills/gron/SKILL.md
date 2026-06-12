---
name: gron
description: >
  Make JSON greppable by flattening it into discrete `path = value;` assignments, then
  reverse the transform with `gron -u`. Use this skill whenever JSON is too nested to query
  by eye, when you want to grep/rg for a key or value and see its full path, when jq's path
  syntax is unknown or awkward, or when diffing two JSON documents line-by-line. Pairs with
  rg (search the flattened lines) and jq (reshape afterwards). Install: winget TomHudson.gron.
allowed-tools: Bash, PowerShell
---

# gron — Make JSON Greppable

`gron` turns JSON into flat, line-oriented assignments so every value carries its full path.
`gron -u` (ungron) rebuilds JSON from those lines. This makes `rg`/`grep` a viable JSON query
tool when you don't yet know the structure or the jq path.

## When to use gron vs jq

- **gron** — you don't know the shape yet; you want to *discover* where a key/value lives, or
  grep across deeply nested JSON without writing a path expression.
- **jq** (`/jq-json-processor`) — you already know the structure and want to reshape, aggregate,
  or project fields.

A common flow is gron to find the path, then jq to extract it cleanly.

## Core usage

```bash
gron data.json                      # flatten to: json.foo.bar[0] = "x";
cat data.json | gron                # from stdin
gron data.json | rg <pattern>       # grep flattened lines for a key or value
gron data.json | rg <pattern> | gron -u   # rebuild JSON from just the matched lines
curl -s <url> | gron | rg <pattern>        # explore an unfamiliar API response
```

## Useful flags

| Flag | Effect |
|---|---|
| `-u`, `--ungron` | Reverse: reassemble JSON from `gron` output |
| `-v`, `--values` | Print only values, not the full assignment |
| `-s`, `--stream` | Treat input as a stream of one JSON object per line (JSONL) |
| `--no-sort` | Preserve original key order (default sorts keys) |
| `-m`, `--monochrome` | Disable colour (default when piped) |

## Recipes

**Find the path to a value you can see but can't locate:**
```bash
gron config.json | rg -i "timeout"
# -> json.server.http.timeout_ms = 30000;
```

**Extract a subtree by grepping paths, then rebuild valid JSON:**
```bash
gron response.json | rg '^json\.data\.users\[\d+\]\.email' | gron -u
```

**Diff two JSON docs semantically (order-independent):**
```bash
diff <(gron a.json) <(gron b.json)
```

## Agent notes

- gron output is already line-bounded — cap with `| head -n N` (Bash) / `Select-Object -First N`
  (PowerShell) like any other stream before it reaches context.
- For raw byte-stream pipelines (`gron | rg | gron -u`) on Windows, run via the **Bash tool** so
  streams pass correctly (PowerShell's `|` passes objects, not bytes).
- Once you know the path, prefer a single `jq` projection over re-running gron for repeated extracts.

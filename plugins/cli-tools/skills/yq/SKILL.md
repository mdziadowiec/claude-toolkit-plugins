---
name: yq
description: Process, query, update, and convert structured data files using yq — the portable CLI processor for YAML, JSON, XML, CSV, TOML, INI, HCL, TSV, and Properties. Use this skill whenever the user wants to read, filter, edit, or transform structured config files: Kubernetes manifests, docker-compose.yml, appsettings.yml, CI/CD pipeline configs, OpenAPI specs, or any YAML/JSON/XML data. Prefer /yq over /jq-json-processor when the source is YAML, when in-place file editing is needed, or when format conversion between YAML↔JSON↔XML↔CSV is required. Also use when the user says things like "update this yaml", "extract from config file", "convert yaml to json", "patch this manifest", or "set a value in appsettings".
homepage: https://github.com/mikefarah/yq
metadata: {"clawdbot":{"emoji":"⚙️","requires":{"bins":["yq"]},"install":[{"id":"winget","kind":"winget","package":"MikeFarah.yq","bins":["yq"],"label":"Install yq (winget)"},{"id":"choco","kind":"choco","package":"yq","bins":["yq"],"label":"Install yq (choco)"},{"id":"scoop","kind":"scoop","package":"main/yq","bins":["yq"],"label":"Install yq (scoop)"},{"id":"brew","kind":"brew","formula":"yq","bins":["yq"],"label":"Install yq (brew)"}]}}
---

# yq — Portable Structured Data Processor

yq processes YAML, JSON, XML, CSV, TOML, INI, HCL, TSV, and Properties with a jq-like expression language. It's the right tool when data lives in config files rather than pure JSON streams.

## Installation (Windows)

```powershell
winget install --id MikeFarah.yq   # preferred
choco install yq
scoop install main/yq
```

## Key Flags

| Flag | Purpose |
|---|---|
| `-i` / `--inplace` | Edit file in place (no redirect needed) |
| `-r` / `--unwrapScalar` | Raw output — strips quotes from scalar values |
| `-P` / `--prettyPrint` | Pretty-print output |
| `-n` / `--null-input` | Evaluate without reading input (useful for creating documents) |
| `-p yaml` | Force input format (yaml, json, xml, csv, tsv, toml, ini, hcl, lua, base64, uri) |
| `-o json` | Force output format |
| `-e` / `--exit-status` | Exit non-zero if the result is null/false |

## Path Expressions

```bash
# Nested field access
yq '.server.port' config.yaml

# Array index
yq '.containers[0].image' pod.yaml

# Iterate all array items
yq '.items[].name' list.yaml

# Wildcard — all children
yq '.spec.containers[*].env' deployment.yaml
```

## Reading Values

```bash
# Single field
yq '.version' Chart.yaml

# Multiple fields (outputs object)
yq '{name: .name, version: .version}' Chart.yaml

# Raw string (no quotes)
yq -r '.metadata.name' pod.yaml

# All keys of a map
yq 'keys' appsettings.yaml
```

## Updating Values (in-place)

```bash
# Set a scalar
yq -i '.version = "2.1.0"' Chart.yaml

# Update nested field
yq -i '.ConnectionStrings.Default = "Server=prod;..."' appsettings.yaml

# Append to array
yq -i '.items += ["newitem"]' list.yaml

# Delete a key
yq -i 'del(.debug)' config.yaml

# Conditional update
yq -i '(.containers[] | select(.name == "app")).image = "myimage:v2"' deploy.yaml
```

## Format Conversion

```bash
# YAML → JSON
yq -o json config.yaml

# JSON → YAML
yq -p json -o yaml data.json

# YAML → XML
yq -o xml config.yaml

# JSON → CSV (array of objects)
yq -p json -o csv '[.[] | [.name, .age]]' data.json

# Multi-document YAML → JSON (each doc)
yq -o json -s '.' multi.yaml
```

## Filtering & Selecting

```bash
# Select matching items
yq '.items[] | select(.status == "active")' items.yaml

# Select where field exists
yq '.[] | select(has("email"))' users.yaml

# Filter array to matching items
yq '[.containers[] | select(.name | test("sidecar"))]' pod.yaml
```

## Working with Kubernetes Manifests

```bash
# Get image from first container
yq '.spec.template.spec.containers[0].image' deployment.yaml

# Bump image tag in place
yq -i '.spec.template.spec.containers[0].image = "myapp:v1.2.3"' deployment.yaml

# List all container names
yq '.spec.template.spec.containers[].name' deployment.yaml

# Extract env var value
yq '.spec.template.spec.containers[0].env[] | select(.name == "ENV") | .value' deployment.yaml

# Patch replicas
yq -i '.spec.replicas = 3' deployment.yaml
```

## Working with docker-compose.yml

```bash
# List all service names
yq '.services | keys' docker-compose.yml

# Get image for a service
yq '.services.api.image' docker-compose.yml

# Add environment variable
yq -i '.services.api.environment.NEW_VAR = "value"' docker-compose.yml
```

## Multi-Document YAML

```bash
# Process all documents in a multi-doc YAML file
yq '.' multi.yaml          # streams all documents

# Select specific document by index
yq 'select(documentIndex == 1)' multi.yaml

# Count documents
yq '[.] | length' multi.yaml
```

## Creating Documents

```bash
# Build YAML from scratch
yq -n '.name = "myapp" | .version = "1.0"'

# Merge two files
yq '. * load("overrides.yaml")' base.yaml
```

## Tips

- Use `-r` to get raw strings for use in scripts: `TAG=$(yq -r '.image.tag' values.yaml)`
- In-place edits with `-i` work on Windows; no temp-file dance needed
- `yq` defaults to YAML output; add `-o json` to get JSON
- To compare two YAML files: `diff <(yq -o json a.yaml) <(yq -o json b.yaml)`
- When jq syntax feels familiar but the file is YAML — reach for yq; the path expressions are nearly identical

## yq vs jq

| Situation | Use |
|---|---|
| Source is YAML / XML / TOML | `/yq` |
| Need in-place file editing | `/yq` |
| Need format conversion | `/yq` |
| Source is pure JSON stream (API, logs) | `/jq-json-processor` |
| Complex JSON reduction / aggregation | `/jq-json-processor` |

## Documentation

Full manual: https://mikefarah.gitbook.io/yq/
Operators reference: https://mikefarah.gitbook.io/yq/operators

---

> See also: `/cli-toolkit` for multi-tool pipelines and token-efficient output patterns.

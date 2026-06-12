---
name: jc
description: Convert CLI command output, file formats, and plain-text strings into structured JSON or YAML using jc (JSON Convert). Use this skill whenever you need to parse output from system commands (git log, df, netstat, dig, ps, etc.), read structured files (INI, TOML, CSV, XML, hosts, fstab), or convert a string (URL, timestamp, JWT, semver) into a queryable JSON object — especially when chaining into jq for downstream filtering.
homepage: https://github.com/kellyjonbrazil/jc
metadata: {"clawdbot":{"emoji":"🔄","requires":{"bins":["jc"]},"install":[{"id":"pip","kind":"pip","package":"jc","bins":["jc"],"label":"Install jc (pip/pipx)"},{"id":"brew","kind":"brew","formula":"jc","bins":["jc"],"label":"Install jc (brew)"},{"id":"apt","kind":"apt","package":"jc","bins":["jc"],"label":"Install jc (apt)"}]}}
---

# jc — JSON Convert

`jc` converts the output of CLI commands, file types, and strings to JSON (or YAML). It has **229 parsers** covering system, network, git, security, and spec formats.

## When to use jc

| Situation | Action |
|---|---|
| Need to filter/query CLI output (git log, df, ps, netstat…) | `command \| jc --parser \| jq …` |
| Reading a structured file (INI, TOML, CSV, XML, hosts, fstab) | `cat file \| jc --ini` |
| Parsing a string (URL, JWT, semver, timestamp, IP address) | `echo "…" \| jc --url` |
| Bridging a text-output tool into a jq pipeline | Use jc as the first stage |
| Need human-readable diff/compare between two command outputs | Convert both to JSON, then diff |

**Do not use jc** when the source is already JSON (use `jq` directly) or YAML/XML (use `yq`).

## Syntax

### Standard syntax — pipe output into jc
```bash
COMMAND | jc [OPTIONS] --PARSER
cat FILE  | jc [OPTIONS] --PARSER
echo STR  | jc [OPTIONS] --PARSER
```

### Magic syntax — prefix the command with jc
```bash
jc [OPTIONS] COMMAND [COMMAND_ARGS]
jc [OPTIONS] /proc/<procfile>
```

Magic syntax is cleaner but requires the command name to match a known magic alias. When in doubt use standard syntax.

### Key options
| Flag | Effect |
|---|---|
| `-p` / `--pretty` | Pretty-print JSON (indented) |
| `-y` / `--yaml-out` | Output YAML instead of JSON |
| `-r` / `--raw` | Raw output — no type conversion (all strings) |
| `-q` / `--quiet` | Suppress warnings |
| `-M` / `--meta-out` | Embed metadata (timestamp, parser, etc.) in output |
| `-s` / `--slurp` | Read multiple lines into a single JSON array |
| `[start]:[end]` | Slice input lines before parsing (zero-based, like Python slices) |

### Discover parsers
```bash
jc --help              # all parsers
jc -hhh                # parsers grouped by category
jc --help --dig        # documentation for the --dig parser
```

---

## Examples by category

### Git
```bash
# Structured git log — every commit as a JSON object
git log | jc --git-log | jq '.[] | {commit: .commit[:7], author: .author, date: .date}'

# Magic syntax equivalent
jc --pretty git log --stat

# Filter commits that touched a specific file pattern (combine with jq)
git log --name-only | jc --git-log | jq '[.[] | select(.changes[]?.filename | test("Service\\.cs$"))]'

# Remote refs
git ls-remote | jc --git-ls-remote | jq '.[] | select(.reference | startswith("refs/tags"))'
```

### File system & disk
```bash
# Disk usage — find filesystems above 80 %
df -h | jc --df | jq '[.[] | select(.use_percent > 80)]'

# du — top 5 largest directories
du -sh * | jc --du | jq 'sort_by(.size) | reverse | .[0:5]'

# find output as JSON
find . -name "*.csproj" | jc --find | jq '.[].name'

# stat a file
stat myfile.txt | jc --stat | jq '{name: .name, size: .size, modified: .modify_time}'
```

### Network
```bash
# DNS lookup — extract A records
dig www.example.com | jc --dig | jq '[.[] | .answer[]? | select(.type=="A") | .data]'

# Active TCP connections
netstat -an | jc --netstat | jq '[.[] | select(.proto=="tcp" and .state=="ESTABLISHED")]'

# Host lookup
host example.com | jc --host | jq '.[] | select(.record_type == "A")'

# curl response headers
curl --head https://example.com 2>/dev/null | jc --curl-head | jq '{status: .status, content_type: .content_type}'
```

### System & processes
```bash
# Running processes — find process by name
ps aux | jc --ps | jq '[.[] | select(.command | test("dotnet"))]'

# Uptime as JSON
uptime | jc --uptime | jq .

# Environment variables as JSON map
env | jc --env | jq 'map({(.name): .value}) | add'

# systemctl service status
systemctl list-units | jc --systemctl | jq '[.[] | select(.state=="failed")]'
```

### Structured files & formats
```bash
# Parse INI / config file
cat appsettings.ini | jc --ini | jq '.Database.ConnectionString'

# Parse TOML
cat Cargo.toml | jc --toml | jq '.package.version'

# Parse CSV
cat data.csv | jc --csv | jq '[.[] | select(.status == "active")]'

# Parse XML
cat config.xml | jc --xml | jq '.root.settings'

# /etc/hosts
cat /etc/hosts | jc --hosts | jq '[.[] | select(.hostname | test("local"))]'
```

### String parsers
```bash
# Decompose a URL
echo "https://api.example.com:8080/v1/data?key=val" | jc --url | jq '{host: .host, path: .path, query: .query}'

# Parse a JWT (no validation — structure only)
echo "eyJ..." | jc --jwt | jq '.payload'

# Validate/parse a semantic version
echo "1.23.4-beta.1+build.5" | jc --semver | jq .

# Convert Unix timestamp
echo "1700000000" | jc --timestamp | jq '{iso: .iso, year: .year}'

# Parse an IP address (v4 or v6)
echo "192.168.1.0/24" | jc --ip-address | jq '{network: .network_address, broadcast: .broadcast_address}'
```

### Certificates & security
```bash
# X.509 certificate fields
cat server.crt | jc --x509-cert | jq '.[0] | {subject: .tbs_certificate.subject, not_after: .tbs_certificate.validity.not_after}'

# JWT claims
echo "$JWT_TOKEN" | jc --jwt | jq '.payload | {sub, exp, iss}'
```

---

## Power patterns

### jc → jq pipeline (most common)
```bash
# Parse, filter, reshape, format in one line
git log --since="1 week ago" | jc --git-log \
  | jq -r '.[] | [.date, .author, .message] | @tsv'
```

### Line slicing (skip headers / footers)
```bash
# Skip the first 2 header lines before parsing
cat report.txt | jc 2: --df
# Parse only lines 5–20
cat bigfile.txt | jc 5:20 --csv
```

### YAML output for human review
```bash
df -h | jc --df -y       # YAML is often easier to read than JSON for spot-checks
```

### Metadata tagging
```bash
df | jc --df --meta-out | jq '{ts: .metadata.timestamp, data: .data}'
```

### Streaming parsers (large output, low memory)
Parsers ending in `-s` emit one JSON object per line (JSONL) — safe for large files:
```bash
git log | jc --git-log-s | while IFS= read -r line; do
    echo "$line" | jq -r '.commit'
done
```

---

## Parser quick reference (most useful)

| Category | Parser | Notes |
|---|---|---|
| **Git** | `--git-log` `--git-log-s` `--git-ls-remote` | commit objects with dates, author, stats |
| **File system** | `--df` `--du` `--find` `--stat` `--ls` | disk/file metadata |
| **Network** | `--dig` `--netstat` `--ss` `--host` `--ping` | DNS, connections, ICMP |
| **Processes** | `--ps` `--top` `--uptime` | process list, load |
| **System** | `--env` `--uname` `--systemctl` `--sysctl` | OS info, services |
| **Formats** | `--csv` `--ini` `--toml` `--xml` `--yaml` | structured config/data files |
| **Strings** | `--url` `--jwt` `--semver` `--timestamp` `--ip-address` | parse a single value |
| **Certs** | `--x509-cert` `--x509-crl` `--x509-csr` | PEM/DER certificate fields |
| **Logs** | `--clf` `--syslog` `--syslog-bsd` | access logs, system logs |
| **Generic** | `--asciitable` `--kv` `--http-headers` | plain-text table / key=value |

Check full list and per-parser docs:
```bash
jc --help              # all 229 parsers
jc -hhh                # grouped by category
jc --help --<parser>   # schema + usage for one parser
```

---

> See also: `/cli-toolkit` for multi-tool pipelines and token-efficient output patterns.

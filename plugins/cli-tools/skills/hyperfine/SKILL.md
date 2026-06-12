---
name: hyperfine
description: Benchmark commands with hyperfine — statistical timing, multi-command comparison, parameter sweeps, and export. Use when the user wants to measure execution time, compare implementations, find the fastest variant, or export benchmark results.
homepage: https://github.com/sharkdp/hyperfine
allowed-tools: Bash, PowerShell
---

# hyperfine — Command-Line Benchmarking

hyperfine 1.20.0 is installed. It runs multiple timed iterations, computes mean/stddev/min/max, and produces ranked comparisons across commands.

## Non-negotiable rules

1. Always add `--warmup 3` when benchmarking I/O-heavy or JIT-compiled code to fill caches and warm the runtime.
2. Use `-n` to give commands readable names whenever the raw command string is long or opaque.
3. Prefer `--export-json` when the user wants to post-process results; prefer `--export-markdown` for documents and PRs.
4. Never use `--show-output` in benchmarks that matter — it inflates timings.
5. Use `--shell=none` when benchmarking commands that do not need a shell to eliminate shell-startup overhead noise.
6. Use `--prepare` for per-run setup (e.g., drop caches); use `--setup` for one-time setup before all runs.

---

## Basic usage

### Single command
```bash
hyperfine 'my-command --args'
```

### Compare two implementations
```bash
hyperfine 'old-impl input.txt' 'new-impl input.txt'
```

### Named commands (readable output)
```bash
hyperfine -n 'old' 'old-impl input.txt' \
          -n 'new' 'new-impl input.txt'
```

### Exact run count
```bash
hyperfine --runs 20 'my-command'
```

### With warmup
```bash
hyperfine --warmup 5 'my-command'
```

---

## Setup and teardown hooks

| Flag | When it runs | Use for |
|---|---|---|
| `--setup <CMD>` | Once before all runs of a command | Compile, seed DB, unpack fixture |
| `--prepare <CMD>` | Before **each** timing run | Drop disk/page cache, reset state |
| `--conclude <CMD>` | After **each** timing run | Kill a server started in `--prepare` |
| `--cleanup <CMD>` | Once after all runs of a command | Remove artifacts |

```bash
# Drop Linux page cache before each run
hyperfine --prepare 'sync; echo 3 | sudo tee /proc/sys/vm/drop_caches' \
          'cat large-file.bin > /dev/null'

# Start/stop a server around each run
hyperfine --prepare 'my-server &' \
          --conclude 'pkill my-server' \
          'curl -s http://localhost:8080/api'

# Compile once, then benchmark the binary
hyperfine --setup 'cargo build --release' \
          './target/release/my-binary'
```

---

## Parameter sweeps

### Scan a numeric range
```bash
hyperfine -P threads 1 8 'make -j {threads}'
# Benchmarks: make -j 1, make -j 2, ..., make -j 8
```

### Scan with custom step size
```bash
hyperfine -P delay 0.1 0.5 --parameter-step-size 0.1 'sleep {delay}'
# Benchmarks: sleep 0.1, sleep 0.2, ..., sleep 0.5
```

### Scan a list of values
```bash
hyperfine -L impl 'grep,ripgrep,ugrep' '{impl} -r pattern .'
# Benchmarks each tool
```

### Power-of-2 sweep (via shell arithmetic)
```bash
hyperfine -P size 0 4 'process --chunk $((2**{size}))M'
# Benchmarks: 1M, 2M, 4M, 8M, 16M
```

---

## Export formats

```bash
# JSON — includes per-run timings; best for post-processing
hyperfine --export-json results.json 'cmd-a' 'cmd-b'

# Markdown table — paste directly into PRs/docs
hyperfine --export-markdown results.md 'cmd-a' 'cmd-b'

# CSV — for spreadsheet analysis
hyperfine --export-csv results.csv 'cmd-a' 'cmd-b'

# AsciiDoc
hyperfine --export-asciidoc results.adoc 'cmd-a' 'cmd-b'

# Multiple exports at once
hyperfine --export-json r.json --export-markdown r.md 'cmd-a' 'cmd-b'
```

### Parse JSON results with jq
```bash
# Mean times for each command
jq '.results[] | {command: .command, mean: .mean}' results.json

# Ranked by mean time
jq '[.results[] | {command: .command, mean: .mean}] | sort_by(.mean)' results.json

# Per-run timings for a command
jq '.results[0].times' results.json
```

---

## Comparison options

### Set a reference command
```bash
# Compare others relative to 'baseline', not the fastest
hyperfine --reference 'baseline-cmd' 'new-cmd-a' 'new-cmd-b'
```

### Control sort order of the summary table
```bash
hyperfine --sort mean-time 'cmd-a' 'cmd-b' 'cmd-c'
```

---

## Reduce noise

```bash
# Eliminate shell-startup overhead
hyperfine --shell=none '/usr/bin/ls /tmp'

# Increase iterations for fast commands
hyperfine --min-runs 50 'echo hello'

# Cap iterations for slow commands
hyperfine --max-runs 5 'long-running-task'

# Control time unit in output
hyperfine --time-unit millisecond 'fast-cmd'
```

---

## Output control

```bash
# Suppress command output (default — null)
hyperfine 'cmd'

# Use pipe to avoid grep/null-detection optimizations
hyperfine --output pipe 'grep -r pattern .'

# Capture per-iteration logs
hyperfine 'my-command > output-${HYPERFINE_ITERATION}.log'
```

---

## Agent decision tree

### Task: Is command A faster than command B?
```bash
hyperfine -n 'A' 'cmd-a' -n 'B' 'cmd-b'
```

### Task: Benchmark with file I/O (disk cache matters)
```bash
hyperfine --warmup 3 --prepare 'sync' 'cmd-with-file-io'
```

### Task: Find optimal thread/worker count
```bash
hyperfine -P n 1 8 'my-tool --workers {n}'
```

### Task: Benchmark a compiled binary after changes
```bash
hyperfine --setup 'dotnet build -c Release' \
          -n 'release' './bin/Release/net10.0/app'
```

### Task: Export results for a PR description
```bash
hyperfine --export-markdown bench.md -n 'before' 'old-cmd' -n 'after' 'new-cmd'
cat bench.md
```

### Task: Benchmark on Windows (no shell overhead)
```bash
hyperfine --shell=none 'C:\path\to\app.exe --args'
```

### Task: Fast command needs many runs
```bash
hyperfine --min-runs 100 --time-unit microsecond 'fast-cmd'
```

---

## Typical .NET / PSItraffic patterns

### Compare two dotnet run configurations
```bash
hyperfine --warmup 2 \
  -n 'debug'   'dotnet run -c Debug   --project MyApp' \
  -n 'release' 'dotnet run -c Release --project MyApp'
```

### Benchmark a CLI tool built from source
```bash
hyperfine --setup 'dotnet build -c Release MyTool' \
          --warmup 3 \
          --export-json bench.json \
          './MyTool/bin/Release/net10.0/MyTool.exe input.csv'
```

### Parameter sweep over dataset sizes
```bash
hyperfine -P rows 1000 10000 --parameter-step-size 1000 \
          'dotnet run --project Bench -- --rows {rows}'
```

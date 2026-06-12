# rg-fzf-dotnet

Agent skill for fast, deterministic .NET repository search using [ripgrep](https://github.com/BurntSushi/ripgrep) and [fzf](https://github.com/junegunn/fzf).

See `SKILL.md` for the full command reference.

## Why rg over grep?

Benchmarked on the PSItraffic codebase (~36k .NET source files) — ripgrep 15.1.0 vs GNU grep 3.0, warm filesystem cache, Windows 11:

| Search type                 | `rg`  | `grep -r` | Speedup |
| --------------------------- | ----- | --------- | ------- |
| Symbol (`ILogger`)          | 0.53s | 16.44s    | **31×** |
| Regex (`TODO\|FIXME\|HACK`) | 0.49s | 16.65s    | **34×** |
| Literal (`AddSingleton`)    | 0.50s | 16.24s    | **33×** |
| File listing                | 0.36s | 12.54s    | **35×** |

Average speedup: **~33×**

`rg` also searched fewer files (36,872 vs 42,404) because it respects `.gitignore` and skips `bin/`/`obj/` automatically — less work and more relevant results.

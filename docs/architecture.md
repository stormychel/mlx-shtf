# Architecture

`mlx-shtf` is a single bash script (`bin/shtf`) that dispatches sub-commands to a local MLX model via the `mlx-lm` CLI. There is no daemon, no server, no network at inference time.

```
shtf <cmd> ─► resolve model ─► RAM guard ─► build prompt ─► mlx_lm.generate ─► stdout
                                                 │
              chat ──────────────────────────────┴─► mlx_lm.chat (interactive REPL)
```

## Components

- **`bin/shtf`** — the CLI. Dispatch, model resolution, RAM guard, prompt assembly, retrieval, and output. Must stay **bash 3.2 compatible** (macOS system bash).
- **`mlx_lm.generate`** — one-shot generation (used by `ask`, `code`, one-shot questions).
- **`mlx_lm.chat`** — the interactive REPL (used by `chat`).
- **`install.sh`** — the RAM-aware model picker and environment setup.

## Generation path

All non-chat commands funnel through one `generate()` function:

1. The assembled prompt is captured to a temp file.
2. The RAM guard runs (see [RAM guard](ram-guard.md)).
3. `mlx_lm.generate --system-prompt <sys> --prompt - <tempfile>` runs in the **foreground**, output to a temp file, stderr captured.
4. On non-zero exit **or empty output**, the model's stderr is surfaced and `shtf` exits non-zero — failures never masquerade as a blank answer.

Two deliberate choices, both hard-won:

- **The prompt is fed via an explicit stdin redirect, not a pipe into a backgrounded command.** A backgrounded command's stdin is `/dev/null` (POSIX), which would silently send the model an empty prompt. (This is the exact bug that made the sibling tool `mlx-diff` review empty diffs.)
- **`--prompt -` reads stdin** — it's the documented sentinel, verified working; the temp-file content becomes the prompt.

## `ask` — RAG retrieval

`shtf ask <path> <question>` does lexical retrieval (v0.1; embeddings are planned):

1. **Keywords** — the question is lowercased and split into words ≥ 4 characters.
2. **Rank** — every text file under `<path>` (under 200 KB, `.git` excluded, binary skipped via `grep -I`) is scored by how many keyword occurrences it contains (`grep -oiE`).
3. **Budget** — the top-ranked files are concatenated, each prefixed with `### <path>`, up to a ~12,000-character context budget.
4. **Answer** — the context + question go to the model with a system prompt that restricts it to the provided context and asks it to cite file paths (or say "Not found in the provided files").

The retrieval is a flat shell pipeline written to a temp file — **not** a nested process substitution, which bash 3.2 mis-parses at runtime.

> Lexical retrieval is simple and dependency-free, but it matches on words, not meaning. Embeddings-based retrieval is a planned enhancement.

## Model resolution

`$SHTF_MODEL` → `~/.config/mlx-shtf/model` → built-in default. See [Configuration](configuration.md#model-resolution-order).

## State & logging

- **Config**: `~/.config/mlx-shtf/model` (the chosen model).
- **State**: `~/.local/state/mlx-shtf/runs.jsonl` (one JSON line per run).
- **Model cache**: `~/.cache/huggingface` (shared with other MLX tools).

## Why bash 3.2

The CLI targets the macOS *system* bash (3.2.57), so it works on any Mac with zero extra installs. This rules out bash-4+ features (`mapfile`, `declare -A`, etc.) and means some constructs that pass `shellcheck` and `bash -n` still fail at runtime — see [Contributing](contributing.md).

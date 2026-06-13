# mlx-shtf

A fully-offline local AI kit for Apple Silicon — **chat**, **doc Q&A** (RAG over your local files), and **coding help**, all running on a local [MLX](https://github.com/ml-explore/mlx) model with **zero network**.

Your break-glass assistant for when cloud models get pulled. (On 2026-06-12, Fable 5 and Mythos 5 were [disabled for *all* users overnight by a US export-control order](https://www.anthropic.com/news/fable-mythos-access) — a reminder that cloud model access can vanish without notice. `mlx-shtf` is the local fallback that doesn't.)

> **Apple Silicon only.** MLX doesn't run on Intel Macs or Linux. Runs on bare-metal Apple-Silicon Macs and macOS-on-Apple-Silicon VMs.

## Install

```bash
git clone https://github.com/stormychel/mlx-shtf.git
cd mlx-shtf
./install.sh
```

`install.sh` verifies the host is Apple Silicon, installs `mlx-lm` via `pipx`, lets you **pick a model that fits your RAM** (color-ranked by fit, with already-installed models marked), pulls it, and symlinks `shtf` into `~/.local/bin`. Re-run any time to change model.

## Usage

```bash
shtf chat                              # interactive offline chat (REPL)
shtf "how do I flush DNS on macOS?"    # one-shot question
shtf ask ./docs "how does auth work?"  # RAG: answer grounded in local files
shtf code ./server.swift "find bugs"   # coding help, file as context
shtf code "write a bash retry wrapper" # coding help, prompt only
shtf models                            # show the active model / how to change
```

| Command | What it does |
|---------|--------------|
| `chat` | Interactive REPL via `mlx_lm.chat` |
| `ask <path> <question…>` | Lexical retrieval over local text files, then answers grounded in them |
| `code [file] <prompt…>` | Coding assistant; includes the file as context if given |
| `<question…>` | One-shot question, no files |
| `models` | Print the active model and how to change it |

### Environment

| Variable | Default | Purpose |
|----------|---------|---------|
| `SHTF_MODEL`      | install-time choice → `Qwen2.5-14B-Instruct-8bit` | Model repo |
| `SHTF_MAX_TOKENS` | `1024` | Max generated tokens |
| `SHTF_TEMP`       | `0.4`  | Sampling temperature |
| `SHTF_FORCE`      | —      | Set to `1` to skip the RAM-fit guard |
| `SHTF_LOG`        | `$XDG_STATE_HOME/mlx-shtf/runs.jsonl` | Run log |

The install-time model choice is stored at `~/.config/mlx-shtf/model`.

## RAM-fit guard

Loading a model bigger than your free RAM **swap-kills the Mac**. Before loading a cached model, `shtf` compares its size to currently-available RAM and refuses (with a clear message) rather than crashing — close apps, pick a smaller model, or `SHTF_FORCE=1` to override.

## Requirements

- Apple-Silicon macOS — runs under the system `bash` 3.2
- `pipx` (the installer adds it via Homebrew if missing) → `mlx-lm`
- `curl` + `python3` for the install-time model sizing

## Documentation

Full docs live in [`docs/`](docs/index.md):

- [Installation](docs/installation.md) · [Usage](docs/usage.md) · [Configuration](docs/configuration.md)
- [Models](docs/models.md) · [RAM guard](docs/ram-guard.md) · [Architecture](docs/architecture.md)
- [Troubleshooting](docs/troubleshooting.md) · [Contributing](docs/contributing.md) · [Changelog](CHANGELOG.md)

## Caveats

- A local model is weaker than a frontier cloud model; this is a **resilience tool**, not a daily replacement.
- `ask` uses simple lexical retrieval in v0.1 (embeddings-based RAG is planned).

## Status

v0.1 — early. See [issues](https://github.com/stormychel/mlx-shtf/issues) for tracked work.

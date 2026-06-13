# Changelog

All notable changes to `mlx-shtf`. Versioning is loosely semantic; this is early software.

## [0.1.4] — 2026-06-13

- **Renamed the command `shtf` → `mlx-shtf`** for consistency with `mlx-diff`. Config/state dirs (`~/.config/mlx-shtf`, `~/.local/state/mlx-shtf`) and `SHTF_*` env vars are unchanged. Re-run `./install.sh` to update the symlink.
- **HuggingFace token support** — `install.sh` detects a token (`HF_TOKEN` env or a cached `hf auth login` token), uses it for the model-sizing requests, and nudges you to set one if missing. Model downloads already pick it up automatically. Removes the "unauthenticated requests to the HF Hub" rate-limit warning.
- Docs updated throughout.

## [0.1.3] — 2026-06-13

Made the RAM guard offline-safe:

- **Graceful fallback** — when the chosen model won't fit in free RAM, fall back to the largest *cached* model that does (no download), instead of refusing. Only refuse if nothing cached fits.
- **Lifeboat model** — `install.sh` keeps the smallest curated model (~3 GB) cached as a guaranteed-fits offline fallback (`SHTF_SKIP_LIFEBOAT=1` to skip).
- `SHTF_FORCE=1` still loads the chosen model regardless.

## [0.1.2] — 2026-06-13

Fixed (caught by runtime testing — shellcheck, bats, and a codex review all missed these):

- `ask`: a no-match `grep` (exit 1) under `set -e` / `pipefail` aborted the retrieval subshell, so `ask` matched no files. Added a trailing `|| true`.
- `ask`: replaced a nested process substitution (`<( … <(find…) … )`, which bash 3.2 mis-parses at runtime) with a flat temp-file pipeline.
- `ask`: exclude `.git` from retrieval.

## [0.1.1] — 2026-06-13

Fixed (from the v0.1.0 codex review):

- `generate()` now surfaces `mlx_lm`'s stderr and exits non-zero on failure or empty output, instead of swallowing errors into a blank "success".
- `code` / `ask` prompts are fed via herestrings so the non-zero exit propagates (avoids a pipe→subshell trap).

Dismissed: codex's claim that `--prompt -` is treated literally — `mlx_lm` documents `-` as stdin and it's verified working.

## [0.1.0] — 2026-06-13

First release. Offline local AI kit for Apple Silicon, kicked off in response to the [Fable 5 / Mythos 5 suspension](https://www.anthropic.com/news/fable-mythos-access).

- `mlx-shtf chat` — interactive offline REPL (`mlx_lm.chat`).
- `mlx-shtf ask <path> <question>` — lexical RAG over local files.
- `mlx-shtf code [file] <prompt>` — coding help with optional file context.
- `mlx-shtf <question>` — one-shot question.
- `mlx-shtf models` — show / change the active model.
- RAM-aware `install.sh` model picker over curated general-instruct models, with `✓ installed` markers and skip-if-cached.
- Runtime **RAM-fit guard** — refuses to load a model larger than free RAM.
- Apple-Silicon only; bash 3.2 compatible; shellcheck (pinned) + bats CI; mirrors the `mlx-diff` stack.

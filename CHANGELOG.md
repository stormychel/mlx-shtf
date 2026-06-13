# Changelog

All notable changes to `mlx-shtf`. Versioning is loosely semantic; this is early software.

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

- `shtf chat` — interactive offline REPL (`mlx_lm.chat`).
- `shtf ask <path> <question>` — lexical RAG over local files.
- `shtf code [file] <prompt>` — coding help with optional file context.
- `shtf <question>` — one-shot question.
- `shtf models` — show / change the active model.
- RAM-aware `install.sh` model picker over curated general-instruct models, with `✓ installed` markers and skip-if-cached.
- Runtime **RAM-fit guard** — refuses to load a model larger than free RAM.
- Apple-Silicon only; bash 3.2 compatible; shellcheck (pinned) + bats CI; mirrors the `mlx-diff` stack.

# Changelog

All notable changes to `mlx-shtf`. Versioning is loosely semantic; this is early software.

## [0.1.7] — 2026-06-13

- **Frontier tier in the model picker** — `install.sh` now also lists state-of-the-art *open* models that rival top proprietary US models: `mlx-community/GLM-5-4bit` (~419 GB) and `mlx-community/Kimi-K2.7-Code-4bit` (~641 GB). They're 400–600 GB even at 4-bit, so they only run on a 512 GB+ Mac Studio: listed and selectable by number (behind a confirmation), but never recommended, and the runtime RAM guard refuses them on smaller machines. Acting on the GLM-5.2 / Kimi K2.7 open-model releases the same week the cloud Fable/Mythos access was revoked.

## [0.1.6] — 2026-06-13

- Fix `mlx-shtf agent` aborting on its first status line with `sport: unbound variable` — a multibyte ellipsis was glued directly onto `$sport`/`$lport`, so bash folded the byte into the variable name. Braced the variables, and verified the full `agent` command end-to-end (not just the bridge pieces).

## [0.1.5] — 2026-06-13

- **`mlx-shtf agent`** — launch **Claude Code** backed by the local MLX model. Starts `mlx_lm.server`, a LiteLLM bridge (Anthropic↔OpenAI; `hosted_vllm/` provider so it hits `/chat/completions`, not the `/v1/responses` that mlx_lm.server 404s), exports the `ANTHROPIC_*` env, and `exec`s `claude`. RAM-guarded; ports via `SHTF_AGENT_MODEL_PORT`/`SHTF_AGENT_PROXY_PORT`.
- Verified the Anthropic `/v1/messages` → bridge → `mlx_lm.server` transport end-to-end. Caveats (documented): needs a tool-calling coder model; `mlx_lm.server` can degrade over many requests; Ollama remains the reliable agent backend. See [docs/agent.md](docs/agent.md).

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

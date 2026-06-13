# mlx-shtf — project notes

Offline local AI kit for Apple Silicon (chat · RAG ask · code), built on `mlx-lm`. Sibling of `mlx-diff`; same stack and conventions.

## Layout
- `bin/mlx-shtf` — the CLI (bash, **must stay bash 3.2 compatible** — macOS system bash)
- `install.sh` — RAM-aware model picker + pipx/mlx-lm setup + PATH symlink
- `test/smoke.bats` — platform-agnostic smoke tests (no model load)
- `.github/workflows/ci.yml` — shellcheck (pinned v0.11.0) + bats

## Build / test
```bash
shellcheck bin/mlx-shtf install.sh
bats test/smoke.bats
```
CI runs both on Linux, so tests must only cover paths before the Apple-Silicon preflight (`--version`, `--help`, no-args).

## Conventions
- Never re-introduce the stdin bugs from mlx-diff: feed model prompts via an explicit redirect from a temp file; do **not** background the model call (a backgrounded command's stdin is `/dev/null`).
- Keep the RAM-fit guard intact — loading a model larger than free RAM swap-kills the Mac.
- Releases follow the global commit conventions (`New version X - …`).

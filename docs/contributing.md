# Contributing / development

`mlx-shtf` is a small bash project. The bar: it must work on a stock Apple-Silicon Mac with no extra tooling beyond `pipx` + `mlx-lm`.

## Dev setup

```bash
git clone https://github.com/stormychel/mlx-shtf.git
cd mlx-shtf
brew install shellcheck bats-core      # dev tools (CI uses the same)
```

## The golden rule: green static checks ≠ working

shellcheck, `bash -n`, and even an LLM code review can all pass code that is broken at runtime. This project has been bitten twice:

- A `set -e` / `pipefail` + no-match `grep` aborted a retrieval subshell — every static check passed.
- A **nested process substitution** (`<( … <(…) … )`) parses fine under `bash -n` and shellcheck but **fails at runtime under bash 3.2**.

So: **always run it for real before claiming it works.**

## Test checklist

```bash
# 1. static
shellcheck bin/mlx-shtf install.sh
bats test/smoke.bats

# 2. runtime — under the ACTUAL system bash 3.2, with a TINY model (safe, ~75 MB)
M=mlx-community/SmolLM-135M-Instruct-4bit
/bin/bash bin/mlx-shtf --version
SHTF_MODEL=$M SHTF_MAX_TOKENS=24 bin/mlx-shtf "say hi"
SHTF_MODEL=$M SHTF_MAX_TOKENS=40 bin/mlx-shtf ask . "what does install do"
SHTF_MODEL=$M bin/mlx-shtf code VERSION "what is this"
SHTF_MODEL=mlx-community/does-not-exist bin/mlx-shtf "hi"   # must exit non-zero with a clear error
```

Use a tiny model (`SmolLM-135M`) to test *plumbing* without loading a 30 GB model — it exercises the full data flow with zero crash risk. It produces nonsense answers; that's fine, you're testing wiring, not quality.

The bats smoke tests only cover pre-preflight paths (`--version`, `--help`, no-args) so they can run on Linux CI; the real behaviour must be tested on a Mac.

## bash 3.2 rules

The CLI runs under the macOS system bash (3.2.57). Avoid:

- `mapfile` / `readarray` (bash 4+) — use a `while read` loop.
- `declare -A` associative arrays.
- `${var^^}` / `${var,,}` case conversion — use `tr`.
- **Nested process substitution** `<( … <(…) … )` — flatten via a temp file.
- `A && B || C` where `B` can fail — shellcheck flags SC2015; use an `if`.

`install.sh` and `bin/mlx-shtf` may use process substitution and arrays, just not nested process substitution or 4+-only builtins.

## Style

- Keep it a single dependency-light bash script; no Python beyond what `mlx-lm` brings.
- Match the existing structure and comments.
- Performance traps to avoid: bracket-pattern substitutions (`${var//[…]/}`) on large strings are O(n) collation under a UTF-8 locale — use a short-circuiting regex (`[[ "$x" =~ [^[:space:]] ]]`) instead.

## Releases

Follow the repo's commit conventions: release commits use `New version X.Y.Z - <title>` with a bulleted body; non-release commits are a bare bulleted list. Bump `VERSION`, the `VERSION=` line in `bin/mlx-shtf`, and the assertion in `test/smoke.bats` together. CI (shellcheck pinned to v0.11.0 + bats) must be green; tag a GitHub release.

## CI

`.github/workflows/ci.yml` runs on Linux and only covers static lint + the platform-agnostic smoke tests (it can't load MLX). Treat green CI as necessary, not sufficient — see the golden rule above.

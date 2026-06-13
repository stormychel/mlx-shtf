# Configuration

`mlx-shtf` is configured by environment variables and a small config file. There are no required settings — it works out of the box after `./install.sh`.

## Environment variables

| Variable | Default | Purpose |
|----------|---------|---------|
| `SHTF_MODEL`      | install-time choice → `mlx-community/Qwen2.5-14B-Instruct-8bit` | Model repo to use |
| `SHTF_MAX_TOKENS` | `1024` | Max tokens generated per response |
| `SHTF_TEMP`       | `0.4`  | Sampling temperature (lower = more deterministic) |
| `SHTF_FORCE`      | —      | Set to `1` to skip the [RAM-fit guard](ram-guard.md) |
| `SHTF_LOG`        | `$XDG_STATE_HOME/mlx-shtf/runs.jsonl` (`~/.local/state/mlx-shtf/runs.jsonl`) | Where the run log is written |
| `SHTF_AGENT_MODEL_PORT` | `8080` | Port for the MLX server started by [`agent`](agent.md) |
| `SHTF_AGENT_PROXY_PORT` | `8000` | Port for the LiteLLM bridge started by [`agent`](agent.md) |

Install-time only (read by `install.sh`):

| Variable | Purpose |
|----------|---------|
| `SHTF_SKIP_PULL`     | `1` = don't pre-pull the chosen model |
| `SHTF_SKIP_LIFEBOAT` | `1` = don't pull the tiny lifeboat fallback model |
| `SHTF_BIN_DIR`       | Directory to symlink `mlx-shtf` into (default `~/.local/bin`) |

Standard HuggingFace variables are respected too: `HF_HOME` / `HF_HUB_CACHE` (model cache location) and **`HF_TOKEN`** (authenticates downloads — avoids rate limits and the *"unauthenticated requests to the HF Hub"* warning). Set `HF_TOKEN=hf_…`, or run `hf auth login` once to cache a token; both the installer and the model downloads pick it up automatically.

## The config file

The model can be set persistently in:

```
~/.config/mlx-shtf/model
```

This file contains a single line: the HuggingFace repo id of the model. `./install.sh` writes it for you when you pick a model; you can also edit it by hand:

```bash
echo mlx-community/Qwen2.5-32B-Instruct-8bit > ~/.config/mlx-shtf/model
```

(`$XDG_CONFIG_HOME` is honored if set, so the real path may be `$XDG_CONFIG_HOME/mlx-shtf/model`.)

## Model resolution order

When `mlx-shtf` decides which model to load, it checks, highest precedence first:

1. **`$SHTF_MODEL`** — per-run override on the command line
2. **`~/.config/mlx-shtf/model`** — the install-time / persistent choice
3. **Built-in default** — `mlx-community/Qwen2.5-14B-Instruct-8bit`

```bash
# one-off override, doesn't change the default
SHTF_MODEL=mlx-community/Qwen2.5-7B-Instruct-8bit mlx-shtf chat
```

## Run log

Every command appends one JSON line to the run log (default `~/.local/state/mlx-shtf/runs.jsonl`):

```json
{"ts":"2026-06-13T08:20:00Z","cmd":"ask","model":"mlx-community/Qwen2.5-14B-Instruct-8bit"}
```

Tail it or pipe through `jq` to see what's been run and with which model. Set `SHTF_LOG` to relocate it, or point it at `/dev/null` to disable logging.

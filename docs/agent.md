# Using the local model as a coding agent

`mlx-shtf` itself is a read-only assistant (it answers, it doesn't edit). To get an *agent* that edits files and runs tools, `mlx-shtf agent` wires the local MLX model up as the backend for **Claude Code**:

```
mlx_lm.server (OpenAI API)  →  LiteLLM (Anthropic↔OpenAI bridge)  →  claude
```

Claude Code speaks the Anthropic Messages API; `mlx_lm.server` speaks OpenAI; LiteLLM translates between them.

## Quick start

```bash
# one-time: install the bridge and Claude Code
pipx install 'litellm[proxy]'
# (install Claude Code per its own docs if you don't have `claude`)

cd ~/Source/myrepo
SHTF_MODEL=mlx-community/Qwen3-Coder-30B-A3B-Instruct-8bit mlx-shtf agent
```

`mlx-shtf agent`:
1. Runs the [RAM-fit guard](ram-guard.md) (may fall back to a smaller cached model).
2. Starts `mlx_lm.server` for the model on `:8080` (if not already running).
3. Starts a LiteLLM bridge on `:8000` exposing `/v1/messages` (if not already running).
4. Exports `ANTHROPIC_BASE_URL` / `ANTHROPIC_AUTH_TOKEN` / `ANTHROPIC_DEFAULT_*_MODEL` and `exec`s `claude` in the current directory.

Any extra args are passed through to `claude` (e.g. `mlx-shtf agent --dangerously-skip-permissions`).

The two servers are left running so the next `mlx-shtf agent` reuses them. Ports are overridable: `SHTF_AGENT_MODEL_PORT` (default 8080), `SHTF_AGENT_PROXY_PORT` (default 8000).

## Use a coding model

For an agent you want a **coder** model that supports **tool/function calling** — Claude Code can't edit files without it. The general-instruct default works for chat but pick a coder model here:

```bash
SHTF_MODEL=mlx-community/Qwen3-Coder-30B-A3B-Instruct-8bit mlx-shtf agent
# or set it as the default:
echo mlx-community/Qwen3-Coder-30B-A3B-Instruct-8bit > ~/.config/mlx-shtf/model
```

## Caveats (read these)

- **Tool-calling support is required and not guaranteed.** Claude Code drives file edits via tool calls; the backend must support OpenAI function-calling and `mlx_lm.server` must forward it. Qwen2.5/Qwen3-Coder support tool use, but if edits silently fail, this is the first thing to check.
- **`mlx_lm.server` can degrade over many requests.** We've observed its output quality drop after the first request (KV-cache reuse). An agent fires *many* requests per task, so quality may fall off. If it gets worse mid-session, restart the server (`pkill -f mlx_lm.server`) — or use the reliable Ollama path below.
- **RAM.** The server loads the full model. The RAM guard applies; on a busy Mac it may fall back to a smaller model (worse at coding). Close apps for the big model.

## Reliable alternative: Ollama

For day-to-day agentic coding, Ollama is the proven-reliable local backend (no proxy, no degradation). If you have it:

```bash
ollama serve &                                   # if not running
ollama launch claude --model qwen3-coder:latest  # Ollama bridges Claude Code for you
```

`mlx-shtf agent` exists for the MLX path; Ollama is the safer bet until the `mlx_lm.server` multi-request behaviour is sorted. Use whichever gives better results on your machine.

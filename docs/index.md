# mlx-shtf documentation

A fully-offline local AI kit for Apple Silicon — **chat**, **doc Q&A** (RAG over local files), and **coding help**, running on a local [MLX](https://github.com/ml-explore/mlx) model with zero network. Your break-glass assistant for when cloud models get pulled.

> **Why it exists.** On 2026-06-12, Fable 5 and Mythos 5 were [disabled for *all* users overnight by a US export-control order](https://www.anthropic.com/news/fable-mythos-access). Cloud model access can vanish without notice. `mlx-shtf` is the local fallback that can't be switched off remotely.

## Contents

- [Installation](installation.md) — host requirements, the model picker, manual setup, VMs
- [Usage](usage.md) — every command, with examples
- [Configuration](configuration.md) — env vars, the config file, resolution precedence
- [Models](models.md) — the curated list, RAM-fit ranking, using your own model
- [RAM guard](ram-guard.md) — how `mlx-shtf` avoids swap-killing your Mac
- [Coding agent](agent.md) — drive Claude Code with the local model (`mlx-shtf agent`)
- [Architecture](architecture.md) — how chat / ask / code work under the hood
- [Troubleshooting](troubleshooting.md) — common errors and fixes
- [Contributing](contributing.md) — dev setup, testing discipline, bash 3.2 rules
- [Changelog](../CHANGELOG.md)

## 60-second start

```bash
git clone https://github.com/stormychel/mlx-shtf.git
cd mlx-shtf && ./install.sh          # picks a model that fits your RAM
mlx-shtf "what's the syntax for a launchd plist?"
mlx-shtf chat
mlx-shtf ask ./docs "how does the ram guard work?"
```

## At a glance

| | |
|---|---|
| **Platform** | Apple-Silicon macOS only (bare metal or macOS-on-Apple-Silicon VM) |
| **Runtime** | `mlx-lm` via `pipx`; runs under the system `bash` 3.2 |
| **Network** | None at inference time (model is local) |
| **Default model** | `mlx-community/Qwen2.5-14B-Instruct-8bit` (install picks a RAM-fit default) |
| **Safety** | RAM-fit guard refuses to load a model larger than free RAM |

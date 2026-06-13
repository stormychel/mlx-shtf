# Installation

## Requirements

- **Apple-Silicon macOS** (M-series). MLX does not run on Intel Macs or Linux. Works on bare metal or a macOS-on-Apple-Silicon VM (Tart / UTM / Virtualization.framework).
- `pipx` — the installer adds it via Homebrew if missing.
- `mlx-lm` — installed by the installer via `pipx`.
- `curl` + `python3` — only used at install time to size the curated models.

The CLI itself runs under the macOS system `bash` (3.2); no newer bash required.

## Quick install

```bash
git clone https://github.com/stormychel/mlx-shtf.git
cd mlx-shtf
./install.sh
```

`install.sh` is idempotent and does the following:

1. Verifies the host is Apple Silicon (aborts with a clear message otherwise).
2. Installs `pipx` (via Homebrew) and `mlx-lm` if not already present.
3. Detects your system RAM and shows a **color-ranked model picker** — each model's real size is fetched from HuggingFace and rated by how well it fits, with already-installed models marked `✓ installed`.
4. Pulls the model you choose (skips the download if it's already cached).
5. Symlinks `mlx-shtf` into `~/.local/bin`.

Re-run `./install.sh` any time to change the model.

## The picker

```
==> Detected 64 GB system RAM. Sizing models (fetching live sizes)…

   1) ROOMY     3 GB  Qwen2.5-3B-Instruct-8bit
   2) ROOMY     8 GB  Qwen2.5-7B-Instruct-8bit
   3) ROOMY    15 GB  Qwen2.5-14B-Instruct-8bit
   4) ROOMY    17 GB  Qwen2.5-32B-Instruct-4bit
   5) PERFECT  32 GB  Qwen2.5-32B-Instruct-8bit   ← recommended
   6) PERFECT  37 GB  Llama-3.3-70B-Instruct-4bit

  BAD >¾ RAM   TOUGH >½   PERFECT ≈½   ROOMY <½ (safe, smaller)

Pick a model [5]:
```

The recommendation is the largest model that still fits comfortably (≤ 60 % of RAM). See [Models](models.md) for the full ranking rules.

## Headless / non-interactive install

The picker only prompts when stdin is a terminal. For scripted installs, pre-select a model and skip the pull if you want to defer the download:

```bash
SHTF_MODEL=mlx-community/Qwen2.5-14B-Instruct-8bit ./install.sh </dev/null   # auto-pick + pull
SHTF_SKIP_PULL=1 ./install.sh </dev/null                                     # set up, download on first use
```

| Install-time variable | Effect |
|-----------------------|--------|
| `SHTF_MODEL`     | Forces a specific model (overrides the picker recommendation) |
| `SHTF_SKIP_PULL` | `1` = don't pre-pull the model; it downloads on first use |
| `SHTF_BIN_DIR`   | Where to symlink `mlx-shtf` (default `~/.local/bin`) |

## Manual install (no installer)

```bash
pipx install mlx-lm
ln -sf "$PWD/bin/mlx-shtf" ~/.local/bin/mlx-shtf
echo mlx-community/Qwen2.5-14B-Instruct-8bit > ~/.config/mlx-shtf/model   # optional default
```

## PATH note

`mlx-shtf` is symlinked into `~/.local/bin`. If that isn't on your `PATH`, add it to your shell profile:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

## Updating

```bash
cd /path/to/mlx-shtf
git pull
./install.sh        # re-link; pick a different model if you like
```

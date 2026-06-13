# Models

`mlx-shtf` runs any [MLX](https://huggingface.co/mlx-community) instruct model. The installer offers a curated, RAM-ranked shortlist; you can also point it at any other model.

## Curated shortlist

General-instruct models spanning a wide size range (sizes are the on-disk `.safetensors` weight size, ≈ the RAM needed to load them):

| Model | Size | Good for |
|-------|------|----------|
| `Qwen2.5-3B-Instruct-8bit`   | ~3 GB  | 8 GB Macs; quick lookups |
| `Qwen2.5-7B-Instruct-8bit`   | ~8 GB  | 16 GB Macs; solid all-rounder |
| `Qwen2.5-14B-Instruct-8bit`  | ~15 GB | 32 GB Macs; the default |
| `Qwen2.5-32B-Instruct-4bit`  | ~17 GB | bigger model, half the bytes |
| `Qwen2.5-32B-Instruct-8bit`  | ~32 GB | 64 GB Macs; strong reasoning |
| `Llama-3.3-70B-Instruct-4bit`| ~37 GB | 64 GB+; most capable here |

The installer fetches each model's real size live from HuggingFace, so the numbers shown reflect the current weights.

## Fit ranking

`install.sh` detects your RAM and rates each model by the fraction it would occupy. A model should get roughly **half** your RAM — leaving room for the OS, other apps, and the model's working memory (KV cache):

| Fit | Size vs RAM | Meaning |
|-----|-------------|---------|
| 🔴 **BAD** | > ¾ | Won't fit comfortably; risks swap/OOM |
| 🟠 **TOUGH** | ½ – ¾ | Fits but tight |
| 🟢 **PERFECT** | ≈ ½ | Sweet spot — biggest model with headroom |
| 🔵 **ROOMY** | < ½ | Safe and fast, capability left on the table |

The **recommendation** is the largest model that still fits comfortably (≤ 60 % of RAM). Already-downloaded models are marked `✓ installed`.

## Using a different model

Any MLX-format instruct model works — pass its HuggingFace repo id:

```bash
# one-off
SHTF_MODEL=mlx-community/Qwen2.5-Coder-32B-Instruct-8bit mlx-shtf code ./x.swift "review this"

# make it the default
echo mlx-community/Qwen2.5-Coder-32B-Instruct-8bit > ~/.config/mlx-shtf/model
```

A model is downloaded automatically the first time it's used (with HuggingFace's progress bars), then cached under `~/.cache/huggingface`.

## Picking the right size

- **Chat / quick answers**: a 7B–14B is snappy and good enough.
- **Code review / careful reasoning**: prefer 32B if it fits (PERFECT/TOUGH).
- **Coding-specific**: swap in a `*-Coder-*` model via `SHTF_MODEL`.
- **Low-RAM machine**: stick to ROOMY models; the [RAM guard](ram-guard.md) will stop you loading one that won't fit.

> Quantization matters: a 32B model is ~17 GB at 4-bit but ~32 GB at 8-bit. 8-bit is higher quality; 4-bit fits smaller machines. Don't judge fit by parameter count — judge by GB.

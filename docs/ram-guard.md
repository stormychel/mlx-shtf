# The RAM-fit guard

Loading a model larger than your **free** RAM forces macOS into heavy swap and can hard-lock or kill the machine. `shtf` guards against this: before loading a cached model it compares the model's size to currently-available RAM and **refuses to run** rather than swap-killing the Mac.

```
error: Qwen2.5-32B-Instruct-8bit needs ~32 GB but only ~9 GB is free.
       Close some apps, pick a smaller model (shtf models), or set SHTF_FORCE=1 to override.
```

## How it works

1. **Model size** — the guard sums the model's cached weight files (`du -sLk` over the HuggingFace snapshot, following symlinks to the blobs).
2. **Available RAM** — read from `vm_stat`: free + inactive + speculative + purgeable pages × page size (16 KB on Apple Silicon). This is memory macOS can reclaim quickly, not just "free" pages.
3. **Decision** — if `model_size + 3 GB > available`, it aborts. The 3 GB margin covers the model's working memory and a little headroom.

## Limits

- The guard only applies to **already-cached** models — it can't know the size of a model that hasn't been downloaded yet, so the first download/run of a brand-new model isn't guarded. (Once cached, subsequent runs are.)
- The available-RAM figure is an estimate; macOS memory accounting is approximate. The guard errs toward caution (the 3 GB margin).

## Overriding

If you know what you're doing (e.g. you're about to close apps, or you accept the swap):

```bash
SHTF_FORCE=1 shtf chat
```

Or set it for a shell session:

```bash
export SHTF_FORCE=1
```

## If you keep hitting the guard

- **Close memory-heavy apps** (browsers with many tabs, VMs, Xcode, Docker) and retry.
- **Pick a smaller model** — `shtf models`, then set a ROOMY one (see [Models](models.md)).
- Check what's using RAM: Activity Monitor → Memory, or `top -o mem`.

> This guard exists because a 30 GB model loaded on top of a busy 64 GB Mac will swap-die — a one-line error is a much better outcome than a forced reboot.

# The RAM-fit guard

Loading a model larger than your **free** RAM forces macOS into heavy swap and can hard-lock or kill the machine. Before loading a model, `mlx-shtf` checks it fits in currently-available RAM. Crucially — because this is an *offline* tool — it doesn't just dead-end when the model is too big:

1. **Fits?** Run it.
2. **Doesn't fit, but a smaller cached model does?** Fall back to the largest **cached** model that fits — fully offline, no download.
3. **Nothing cached fits?** Refuse, with an actionable message.

`SHTF_FORCE=1` loads your chosen model anyway (you accept the swap).

## Graceful fallback (the offline-safe part)

When your chosen model won't fit, `mlx-shtf` scans the local model cache and switches to the largest already-downloaded model that *does* fit:

```
warning: Qwen2.5-32B-Instruct-8bit needs ~32 GB but only ~10 GB is free —
         falling back to cached Qwen2.5-7B-Instruct-8bit (~8 GB). SHTF_FORCE=1 to override.
```

No internet required — it only uses models you already have. This is what makes the guard safe for the actual SHTF scenario: a busy, low-RAM machine with no connection still gets an answer, from a smaller model, instead of a brick wall.

If *no* cached model fits in free RAM, you get a refusal:

```
error: Qwen2.5-32B-Instruct-8bit needs ~32 GB and no cached model fits in ~6 GB free.
       Close some apps, or set SHTF_FORCE=1 to load it anyway (may swap).
```

## The lifeboat model

So the fallback always has *something* to land on, `./install.sh` keeps one tiny model (the smallest curated model, ~3 GB) cached as a guaranteed-fits **lifeboat** — even if you picked a big model as your main. Skip it with `SHTF_SKIP_LIFEBOAT=1`. Prepper logic: keep a small always-runnable model for when it all goes sideways.

## How the numbers are computed

1. **Model size** — sum of the model's cached weight files (`du -sLk` over the HuggingFace snapshot, following symlinks to blobs).
2. **Available RAM** — from `vm_stat`: free + inactive + speculative + purgeable pages × 16 KB page size. This is memory macOS can reclaim quickly, not just truly-free pages.
3. **Decision** — a model needs `size + 3 GB` to fit; the 3 GB margin covers working memory and headroom.

## Limits

- The guard (and the fallback) only see **cached** models — it can't size a model that hasn't been downloaded. The first download/run of a brand-new model isn't guarded; once cached, it is.
- Available-RAM is an estimate; macOS memory accounting is approximate. The guard errs toward caution.

## Overriding

```bash
SHTF_FORCE=1 mlx-shtf chat          # load the chosen model regardless of fit
export SHTF_FORCE=1             # for the whole shell session
```

The guard's job isn't to forbid — it's to stop you swap-killing the Mac *by accident*. Forcing is a deliberate choice.

## If you keep hitting it

- **Close memory-heavy apps** (browsers, VMs, Xcode, Docker) and retry.
- **Let it fall back** — it already picks a smaller cached model automatically.
- **Pick a smaller default** — `mlx-shtf models`, or re-run `./install.sh` and choose a ROOMY one ([Models](models.md)).
- Check usage: Activity Monitor → Memory, or `top -o mem`.

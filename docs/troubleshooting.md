# Troubleshooting

## `mlx-shtf requires Apple Silicon macOS`

MLX only runs on Apple-Silicon (M-series) Macs. There is no Intel or Linux build. You can run it inside a macOS VM, but the VM must be on an Apple-Silicon host.

## `mlx_lm not found on PATH`

`mlx-lm` isn't installed or `~/.local/bin` isn't on your `PATH`.

```bash
pipx install mlx-lm
export PATH="$HOME/.local/bin:$PATH"     # add to your shell profile
```

Or just run `./install.sh`, which handles both.

## `… needs ~N GB but only ~M GB is free`

The [RAM guard](ram-guard.md) is stopping you from loading a model that won't fit in available memory. Close apps, pick a smaller model (`shtf models`), or override with `SHTF_FORCE=1`.

## `error: generation failed … mlx_lm said:`

The model failed to load or generate. The model's own error is printed below the message. Common causes:

- **Bad model id** — typo in `SHTF_MODEL` or `~/.config/mlx-shtf/model`. A `RepositoryNotFoundError` / `401` means the repo doesn't exist.
- **Offline, model not cached** — the model needs to download once while you have a connection; after that it runs fully offline.
- **Out of memory mid-load** — try a smaller model.

## `no local files under '<path>' matched: <question>`

`shtf ask` found no text files containing your question's keywords. Try:

- More specific / longer words (keywords must be ≥ 4 characters).
- A broader `<path>`.
- Confirm the files are text and under 200 KB (binaries and large files are skipped).

## `question has no searchable keywords`

Your `ask` question had no words of 4+ characters. Rephrase with more substantial terms.

## First run is slow / downloads a lot

The first use of a model downloads its weights (potentially tens of GB) from HuggingFace, with progress bars. Subsequent runs load from cache and need no network. Pre-pull during install to avoid a cold first run.

## The answer is wrong or low quality

- You may be on a small model. Larger models reason better — see [Models](models.md).
- For `ask`, the answer is limited to retrieved files; if the relevant file wasn't matched (lexical retrieval), the model won't see it. Try more specific keywords or point `<path>` at the right directory.

## Where are my logs / config / cache?

| What | Path |
|------|------|
| Chosen model | `~/.config/mlx-shtf/model` |
| Run log | `~/.local/state/mlx-shtf/runs.jsonl` |
| Model weights | `~/.cache/huggingface` |

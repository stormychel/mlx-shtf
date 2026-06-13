# Usage

```
shtf <command> [args]
```

| Command | What it does |
|---------|--------------|
| `shtf chat` | Interactive offline chat REPL |
| `shtf ask <path> <question…>` | Answer a question grounded in local files (RAG) |
| `shtf code [file] <prompt…>` | Coding help; includes a file as context if given |
| `shtf <question…>` | One-shot question (no files) |
| `shtf models` | Print the active model and how to change it |
| `shtf --version` / `-h`, `--help` | Version / help |

All commands run entirely locally — no network is used at inference time.

---

## `chat` — interactive REPL

```bash
shtf chat
```

Drops you into an interactive chat with the active model (via `mlx_lm.chat`). Multi-turn; the model keeps conversational context for the session. Exit with `Ctrl-D` or `q`.

Use it for back-and-forth: brainstorming, explaining concepts, drafting, debugging by conversation.

---

## one-shot question

```bash
shtf "how do I flush the DNS cache on macOS?"
shtf write a haiku about offline AI
```

Anything that isn't a known sub-command is treated as a single question and answered in one shot. Good for quick lookups. Output goes to stdout (pipe it, redirect it, etc.); the `→ shtf: thinking…` status line goes to stderr.

```bash
shtf "one-line awk to sum column 2" >> notes.md
```

---

## `ask` — Q&A grounded in local files (RAG)

```bash
shtf ask <path> <question…>
```

Retrieves the most relevant local text files under `<path>`, feeds them to the model as context, and answers **using only those files** — citing the paths it used.

```bash
shtf ask ./docs "how does the ram guard decide to block?"
shtf ask ~/notes "what did I decide about the database migration?"
shtf ask . "where is the model resolution order defined?"
```

- `<path>` can be a directory or a single file.
- Retrieval is **lexical** in v0.1 (keyword overlap, not embeddings) — see [Architecture](architecture.md#ask--rag-retrieval).
- Only text files under 200 KB are searched; `.git` is excluded.
- If nothing matches your keywords, you'll get a clear "no local files matched" message — try longer / more specific words.

> Answers are limited to what's in the retrieved files. If the answer isn't there, the model is instructed to say "Not found in the provided files" rather than guess.

---

## `code` — coding help

```bash
shtf code <file> <prompt…>      # with a file for context
shtf code <prompt…>             # prompt only
```

```bash
shtf code ./server.swift "are there any retain cycles here?"
shtf code ./deploy.sh "explain what this does and flag risky lines"
shtf code "write a bash function that retries a command 3 times with backoff"
```

When a file is given as the first argument, its contents are included as context. Uses a coding-focused system prompt (correct, idiomatic, minimal).

---

## `models` — show / change the active model

```bash
shtf models
```

```
active model: mlx-community/Qwen2.5-14B-Instruct-8bit
  set per-run:  SHTF_MODEL=<hf-repo> shtf …
  set default:  echo <hf-repo> > ~/.config/mlx-shtf/model   (or re-run ./install.sh)
```

See [Models](models.md) and [Configuration](configuration.md).

---

## Tuning a single run

Any run can be tuned with environment variables (see [Configuration](configuration.md)):

```bash
SHTF_MODEL=mlx-community/Qwen2.5-32B-Instruct-8bit shtf "explain TCP slow start"
SHTF_MAX_TOKENS=2048 shtf code ./parser.py "rewrite this to be streaming"
SHTF_TEMP=0.1 shtf ask . "what is the exact default chunk budget?"
```

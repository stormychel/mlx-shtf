#!/usr/bin/env bash
#
#  install.sh
#  mlx-shtf
#
#  Created by Michel Storms on 13/06/2026.
#
#  Idempotent installer: verifies the host, installs mlx-lm, lets you pick a
#  model that fits this machine's RAM, pulls it, and symlinks `shtf` onto PATH.
#  Safe to re-run.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_SRC="$REPO_DIR/bin/shtf"
BIN_DEST="${SHTF_BIN_DIR:-$HOME/.local/bin}/shtf"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/mlx-shtf"

# Curated general-instruct models, smallest → largest, as "repo<TAB>fallback-GiB".
# Live sizes are fetched from HuggingFace; the fallback is used offline.
CURATED=(
  "mlx-community/Qwen2.5-3B-Instruct-8bit	3"
  "mlx-community/Qwen2.5-7B-Instruct-8bit	8"
  "mlx-community/Qwen2.5-14B-Instruct-8bit	15"
  "mlx-community/Qwen2.5-32B-Instruct-4bit	17"
  "mlx-community/Qwen2.5-32B-Instruct-8bit	32"
  "mlx-community/Llama-3.3-70B-Instruct-4bit	37"
)

if [[ -t 1 ]]; then
  BOLD=$'\033[1m'; DIM=$'\033[2m'; RST=$'\033[0m'
  RED=$'\033[31m'; GREEN=$'\033[32m'; BLUE=$'\033[34m'; ORANGE=$'\033[38;5;208m'
else
  BOLD=""; DIM=""; RST=""; RED=""; GREEN=""; BLUE=""; ORANGE=""
fi

say() { printf '%s==>%s %s\n' "$BOLD" "$RST" "$1"; }
die() { printf '%serror:%s %s\n' "$RED" "$RST" "$1" >&2; exit 1; }

size_gib() {                        # <repo> <fallback> → .safetensors size in GiB
  local bytes=""
  if command -v curl >/dev/null 2>&1 && command -v python3 >/dev/null 2>&1; then
    bytes="$(curl -sS -m 20 "https://huggingface.co/api/models/$1?blobs=true" 2>/dev/null | python3 -c '
import sys, json
try:
    d = json.load(sys.stdin)
    print(sum(s.get("size", 0) for s in d.get("siblings", [])
              if s.get("rfilename", "").endswith(".safetensors")))
except Exception:
    print(0)' 2>/dev/null)"
  fi
  if [[ -n "$bytes" && "$bytes" -gt 0 ]]; then echo $(( bytes / 1073741824 )); else echo "$2"; fi
}

classify() {                        # <size_gib> <ram_gib> → "COLOR<TAB>LABEL"
  local pct=$(( $1 * 100 / $2 ))
  if   (( pct > 75 )); then printf '%s\tBAD'     "$RED"
  elif (( pct > 60 )); then printf '%s\tTOUGH'   "$ORANGE"
  elif (( pct >= 45 )); then printf '%s\tPERFECT' "$GREEN"
  else                      printf '%s\tROOMY'   "$BLUE"; fi
}

hf_hub_dir() {
  if   [[ -n "${HF_HUB_CACHE:-}" ]]; then printf '%s' "$HF_HUB_CACHE"
  elif [[ -n "${HF_HOME:-}" ]];      then printf '%s/hub' "$HF_HOME"
  else printf '%s/.cache/huggingface/hub' "$HOME"; fi
}
model_cached() {                    # <repo>
  local d; d="$(hf_hub_dir)/models--${1//\//--}/snapshots"
  [[ -d "$d" ]] || return 1
  local s; for s in "$d"/*/; do [[ -e "$s" ]] && return 0; done
  return 1
}

# 1. Host check — MLX is Apple-Silicon-only.
[[ "$(uname -s)/$(uname -m)" == "Darwin/arm64" ]] || \
  die "mlx-shtf requires Apple Silicon macOS — MLX is unsupported on $(uname -s)/$(uname -m)."
say "Host OK: $(uname -s) $(uname -m)"

# 2. pipx
if ! command -v pipx >/dev/null 2>&1; then
  if command -v brew >/dev/null 2>&1; then
    say "Installing pipx via Homebrew…"; brew install pipx; pipx ensurepath
  else
    die "pipx not found and Homebrew unavailable. Install pipx, then re-run."
  fi
fi
say "pipx: $(command -v pipx)"

# 3. mlx-lm
if ! command -v mlx_lm.generate >/dev/null 2>&1; then
  say "Installing mlx-lm via pipx…"; pipx install mlx-lm
else
  say "mlx-lm already installed: $(command -v mlx_lm.generate)"
fi

# 4. Pick a model that fits this machine's RAM.
RAM_GIB=$(( $(sysctl -n hw.memsize 2>/dev/null || echo 0) / 1073741824 ))
(( RAM_GIB > 0 )) || RAM_GIB=8
say "Detected ${RAM_GIB} GB system RAM. Sizing models (fetching live sizes)…"
printf '\n'

repos=(); sizes=(); labels=(); colors=(); cached=()
rec=0; rec_size=-1; i=0
for entry in "${CURATED[@]}"; do
  repo="${entry%%$'\t'*}"; fb="${entry##*$'\t'}"
  s="$(size_gib "$repo" "$fb")"
  IFS=$'\t' read -r color label <<<"$(classify "$s" "$RAM_GIB")"
  repos+=("$repo"); sizes+=("$s"); labels+=("$label"); colors+=("$color")
  if model_cached "$repo"; then cached+=("1"); else cached+=("0"); fi
  if (( s * 100 / RAM_GIB <= 60 )) && (( s > rec_size )); then rec=$i; rec_size=$s; fi
  i=$(( i + 1 ))
done
(( rec_size < 0 )) && rec=0

short() { printf '%s' "${1##*/}"; }
for j in "${!repos[@]}"; do
  mark=""
  (( j == rec )) && mark="${mark} ${BOLD}← recommended${RST}"
  [[ "${cached[$j]}" == 1 ]] && mark=" ${GREEN}✓ installed${RST}${mark}"
  printf '  %s%2d%s) %s%-7s%s %3s GB  %s%-34s%s%s\n' \
    "$BOLD" "$(( j + 1 ))" "$RST" "${colors[$j]}" "${labels[$j]}" "$RST" "${sizes[$j]}" \
    "$DIM" "$(short "${repos[$j]}")" "$RST" "$mark"
done
printf '\n  %sBAD%s >¾ RAM   %sTOUGH%s >½   %sPERFECT%s ≈½   %sROOMY%s <½ (safe, smaller)\n\n' \
  "$RED" "$RST" "$ORANGE" "$RST" "$GREEN" "$RST" "$BLUE" "$RST"

choice=$(( rec + 1 ))
if [[ -t 0 ]]; then
  read -r -p "Pick a model [${choice}]: " reply || true
  if [[ -n "${reply:-}" ]]; then
    if ! [[ "$reply" =~ ^[0-9]+$ ]] || (( reply < 1 || reply > ${#repos[@]} )); then
      die "invalid choice: $reply"
    fi
    choice="$reply"
  fi
fi
CHOSEN="${repos[$(( choice - 1 ))]}"
say "Selected: $CHOSEN"

mkdir -p "$CONFIG_DIR"
printf '%s\n' "$CHOSEN" > "$CONFIG_DIR/model"

# 5. Pull the chosen model — unless it's already cached.
if model_cached "$CHOSEN"; then
  say "$CHOSEN is already installed — nothing to download."
elif [[ "${SHTF_SKIP_PULL:-0}" == "1" ]]; then
  say "Skipping model download (SHTF_SKIP_PULL=1) — it will download on first use."
else
  say "Pulling $CHOSEN (set SHTF_SKIP_PULL=1 to skip)…"
  if mlx_lm.generate --model "$CHOSEN" --prompt "ok" --max-tokens 1 --verbose False >/dev/null; then
    say "Model ready."
  else
    say "Model pull/warm-up failed or was interrupted — it will download on first use."
  fi
fi

# 6. Symlink the CLI onto PATH.
mkdir -p "$(dirname "$BIN_DEST")"
ln -sf "$BIN_SRC" "$BIN_DEST"
chmod +x "$BIN_SRC"
say "Linked $BIN_DEST -> $BIN_SRC"

case ":$PATH:" in
  *":$(dirname "$BIN_DEST"):"*) ;;
  *) say "NOTE: $(dirname "$BIN_DEST") is not on your PATH — add it to your shell profile." ;;
esac

say "Done. Try:  shtf chat   ·   shtf \"hello\"   ·   shtf ask . \"what does this repo do?\""

#!/bin/bash
# Claude Code status line
# Shows: cwd (git branch*) | model (effort) | [Ctx] [5h + reset] [7d + reset] [prompt cache]
#
# Recommended settings.json:
#   "statusLine": { "type": "command", "command": "~/.claude/statusline.sh", "refreshInterval": 60 }
# refreshInterval keeps the reset / cache countdowns moving while the session is idle.

input=$(cat)

# Colors
RESET='\033[0m'
BOLD='\033[1m'
CYAN='\033[36m'
GREEN='\033[32m'
YELLOW='\033[33m'
RED='\033[31m'
GRAY='\033[90m'
BLUE='\033[34m'
MAGENTA='\033[35m'

# Pie glyphs (Nerd Fonts / Material Design: circle_outline, circle_slice_1 -> circle_slice_8)
PIE_GLYPHS=('󰝦' '󰪞' '󰪟' '󰪠' '󰪡' '󰪢' '󰪣' '󰪤' '󰪥')

GIT_CACHE_MAX_AGE=5 # seconds

# ---------------------------------------------------------------------------
# Parse all fields with a single jq call.
# Booleans are converted explicitly, because jq's `//` treats false as missing.
# ---------------------------------------------------------------------------
eval "$(echo "$input" | jq -r '
  def b: if . == null then "" else tostring end;
  @sh "
model=\(.model.display_name // "unknown")
cwd=\(.workspace.current_dir // .cwd // "")
session_id=\(.session_id // "")
effort=\(.effort.level // "")
ctx_used=\(.context_window.used_percentage // "")
five_pct=\(.rate_limits.five_hour.used_percentage // "")
five_reset=\(.rate_limits.five_hour.resets_at // "")
week_pct=\(.rate_limits.seven_day.used_percentage // "")
week_reset=\(.rate_limits.seven_day.resets_at // "")
cache_warm=\(.prompt_cache.warm | b)
cache_observed=\(.prompt_cache.caching_observed | b)
cache_expires=\(.prompt_cache.expires_at // "")
"')"

now=$(date +%s)

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

# Color for a usage percentage (higher = worse)
color_for_pct() {
  local pct="$1"
  if [ -z "$pct" ]; then
    echo "$GRAY"
    return
  fi
  local pct_int=${pct%.*}
  if [ "$pct_int" -ge 90 ]; then
    echo "$RED"
  elif [ "$pct_int" -ge 70 ]; then
    echo "$YELLOW"
  else
    echo "$GREEN"
  fi
}

# Pie glyph that fills in eighths as the percentage grows
pie_icon_for_pct() {
  local used="$1"
  if [ -z "$used" ]; then
    echo "${PIE_GLYPHS[0]}"
    return
  fi
  local idx=$(( (${used%.*} * 8 + 50) / 100 ))
  [ "$idx" -lt 0 ] && idx=0
  [ "$idx" -gt 8 ] && idx=8
  echo "${PIE_GLYPHS[$idx]}"
}

# Time until an epoch timestamp: "3d4h", "1h42m", "7m". Empty if past or unknown.
fmt_remaining() {
  local target="$1"
  [ -z "$target" ] && return
  local diff=$(( ${target%.*} - now ))
  [ "$diff" -le 0 ] && return
  if [ "$diff" -ge 86400 ]; then
    printf '%dd%dh' $((diff / 86400)) $((diff % 86400 / 3600))
  elif [ "$diff" -ge 3600 ]; then
    printf '%dh%02dm' $((diff / 3600)) $((diff % 3600 / 60))
  else
    printf '%dm' $(( (diff + 59) / 60 ))
  fi
}

# One bracketed gauge: [Label <pie> NN% <reset>]
gauge() {
  local label="$1" pct="$2" reset_at="$3"
  [ -z "$pct" ] && return
  local color icon remaining
  color=$(color_for_pct "$pct")
  icon=$(pie_icon_for_pct "$pct")
  remaining=$(fmt_remaining "$reset_at")
  printf '%s' "${GRAY}[${RESET}${color}${label} ${icon} $(printf '%.0f' "$pct")%${RESET}"
  [ -n "$remaining" ] && printf '%s' " ${GRAY}${remaining}${RESET}"
  printf '%s' "${GRAY}]${RESET}"
}

# File mtime in epoch seconds (GNU stat first; BSD stat prints garbage to stdout on Linux)
file_mtime() {
  stat -c %Y "$1" 2>/dev/null || stat -f %m "$1" 2>/dev/null || echo 0
}

# Git branch + dirty marker, cached per session to keep the status line fast
git_info() {
  [ -z "$cwd" ] && return
  local cache_file="${TMPDIR:-/tmp}/claude-statusline-git-${session_id:-default}"
  local branch dirty

  if [ ! -f "$cache_file" ] || [ $(( now - $(file_mtime "$cache_file") )) -gt "$GIT_CACHE_MAX_AGE" ]; then
    if git -C "$cwd" rev-parse --git-dir >/dev/null 2>&1; then
      branch=$(git -C "$cwd" branch --show-current 2>/dev/null)
      # Detached HEAD: fall back to short hash
      [ -z "$branch" ] && branch=$(git -C "$cwd" rev-parse --short HEAD 2>/dev/null)
      if [ -n "$(git -C "$cwd" status --porcelain 2>/dev/null | head -n 1)" ]; then
        dirty=1
      else
        dirty=0
      fi
      printf '%s|%s\n' "$branch" "$dirty" > "$cache_file"
    else
      printf '|\n' > "$cache_file"
    fi
  fi

  IFS='|' read -r branch dirty < "$cache_file"
  [ -z "$branch" ] && return
  if [ "$dirty" = "1" ]; then
    printf '%s' " ${MAGENTA}${branch}${YELLOW}*${RESET}"
  else
    printf '%s' " ${MAGENTA}${branch}${RESET}"
  fi
}

# Prompt cache: warm -> time left until it goes cold; cold -> "cold"
cache_segment() {
  [ "$cache_observed" != "true" ] && return
  if [ "$cache_warm" = "true" ]; then
    local remaining diff color="$GREEN"
    remaining=$(fmt_remaining "$cache_expires")
    if [ -n "$cache_expires" ]; then
      diff=$(( ${cache_expires%.*} - now ))
      [ "$diff" -le 60 ] && color="$YELLOW"
    fi
    printf '%s' "${GRAY}[${RESET}${color}Cache${remaining:+ $remaining}${RESET}${GRAY}]${RESET}"
  else
    printf '%s' "${GRAY}[Cache cold]${RESET}"
  fi
}

# ---------------------------------------------------------------------------
# Assemble
# ---------------------------------------------------------------------------
SEP="${GRAY} | ${RESET}"
line=""

# Cwd segment (abbreviate $HOME to ~) + git
if [ -n "$cwd" ]; then
  cwd_display="${cwd//\\//}"
  home_display="${USERPROFILE:-$HOME}"
  home_display="${home_display//\\//}"
  cwd_display="${cwd_display/#$home_display/\~}"
  line="${BLUE}${cwd_display}${RESET}$(git_info)${SEP}"
fi

# Model + effort
line="${line}${BOLD}${CYAN}${model}${RESET}"
[ -n "$effort" ] && line="${line} ${GRAY}(${effort})${RESET}"

# Gauges
gauges=""
for seg in \
  "$(gauge Ctx "$ctx_used" "")" \
  "$(gauge 5h "$five_pct" "$five_reset")" \
  "$(gauge 7d "$week_pct" "$week_reset")" \
  "$(cache_segment)"; do
  [ -n "$seg" ] && gauges="${gauges:+$gauges }${seg}"
done
[ -n "$gauges" ] && line="${line}${SEP}${gauges}"

printf "%b" "$line"

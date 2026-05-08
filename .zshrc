# ─── PATH ───────────────────────────────────────────────────────────────
typeset -U path PATH            # auto-dedupe entries
path=(
  "$HOME/.local/bin"
  /usr/local/go/bin
  $path
)

# ─── History ────────────────────────────────────────────────────────────
HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY            # share history across sessions
setopt HIST_IGNORE_ALL_DUPS     # drop older duplicates
setopt HIST_IGNORE_SPACE        # ignore commands prefixed with a space
setopt HIST_REDUCE_BLANKS       # trim redundant whitespace
setopt HIST_VERIFY              # show history expansions before running

# ─── Completion ─────────────────────────────────────────────────────────
autoload -Uz compinit
compinit

# ─── Prompt ─────────────────────────────────────────────────────────────
PROMPT='%F{white}%n@%m%f %F{yellow}%~%f %F{green}%#%f '

# ─── WezTerm integration ────────────────────────────────────────────────
# Reports cwd via OSC 7 (so new tabs inherit it) and sends git_status +
# foreground prog as OSC 1337 user-vars (rendered by .wezterm.lua). Skipped
# on non-WezTerm terminals because the OSC 1337 sequence isn't standard.
if [[ $TERM_PROGRAM == WezTerm ]]; then
  wez_set_user_var() {
    local name=$1 value=$2
    printf '\033]1337;SetUserVar=%s=%s\007' \
      "$name" "$(print -rn -- "$value" | base64 -w0)"
  }

  _wez_precmd() {
    printf '\033]7;file://%s%s\007' "$HOST" "$PWD"
    wez_set_user_var prog zsh

    local info toplevel branch=""
    if info=$(git rev-parse --show-toplevel --abbrev-ref HEAD 2>/dev/null); then
      toplevel=${info%$'\n'*}
      branch=${info##*$'\n'}
      [[ $branch == HEAD ]] && branch=""    # hide on detached HEAD
    fi
    if [[ -n $branch ]]; then
      wez_set_user_var git_status "${toplevel:t} ($branch)"
    else
      wez_set_user_var git_status ""
    fi
  }

  # On WSL, wezterm sees the Windows-side helper (wslhost.exe) as the
  # foreground process; emit the real command name so tab titles are useful.
  _wez_preexec() {
    wez_set_user_var prog "${${1%% *}:t}"
  }

  autoload -Uz add-zsh-hook
  add-zsh-hook precmd _wez_precmd
  add-zsh-hook preexec _wez_preexec
fi

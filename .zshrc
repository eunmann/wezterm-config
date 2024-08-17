# Function to get the current git branch
git_branch() {
  local branch
  branch=$(git symbolic-ref HEAD 2>/dev/null | sed 's!refs/heads/!!')
  if [ -n "$branch" ]; then
    echo "($branch)"
  else
    echo "()"
  fi
}

# Function to get the current time
current_time() {
  date
}

# Enable prompt substitution
setopt prompt_subst

# Define colors
TIME_C='%F{cyan}'
USER_C='%F{white}'
HOST_C='%F{white}'
DIR_C='%F{yellow}'
GIT_C='%F{magenta}'
PROMPT_C='%F{green}'
# Reset Color
R_C='%f'

# Customize the prompt
PROMPT='${USER_C}%n${R_C}@${HOST_C}%m${R_C} ${DIR_C}%1~${R_C} ${GIT_C}$(git_branch)${R_C} ${PROMPT_C}%#${R_C} '
RPROMPT='${TIME_C}$(current_time)${R_C}'

# Enable vcs_info for git branch info
autoload -Uz vcs_info

# Load the prompt
autoload -U promptinit
promptinit

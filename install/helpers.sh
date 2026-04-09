#!/usr/bin/env bash
# Common helper functions for install modules

need_sudo() {
  [ "$(id -u)" -ne 0 ]
}

get_user_info() {
  export USER_NAME="${SUDO_USER:-$USER}"
  export USER_HOME="$(getent passwd "$USER_NAME" | cut -d: -f6)"
}

# Install a dotfile to the target path with a timestamped backup of any
# existing file. Requires USER_NAME to be set (call get_user_info first).
install_dotfile() {
  local src="$1" dest="$2" name ts
  name="$(basename "$dest")"
  ts="$(date +%Y%m%d-%H%M%S)"
  if [ -f "$dest" ]; then
    cp -a "$dest" "$dest.bak.$ts"
    echo "    Backed up existing $name to $name.bak.$ts"
  fi
  cp "$src" "$dest"
  chown "$USER_NAME":"$USER_NAME" "$dest"
  echo "    Installed $name"
}

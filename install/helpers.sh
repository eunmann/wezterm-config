#!/usr/bin/env bash
# Common helper functions for install modules

need_sudo() {
  [ "$(id -u)" -ne 0 ]
}

get_user_info() {
  export USER_NAME="${SUDO_USER:-$USER}"
  export USER_HOME="$(getent passwd "$USER_NAME" | cut -d: -f6)"
}

cat() {
  if command -v bat >/dev/null 2>&1; then
    bat -p "$@"
  else
    command cat "$@"
  fi
}

ls() {
  if command -v eza >/dev/null 2>&1; then
    eza "$@"
  else
    command ls "$@"
  fi
}

ll() {
  if command -v eza >/dev/null 2>&1; then
    eza -l "$@"
  else
    command ls -l "$@"
  fi
}

la() {
  if command -v eza >/dev/null 2>&1; then
    eza -la "$@"
  else
    command ls -la "$@"
  fi
}

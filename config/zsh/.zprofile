# uwsm
if [ "$(tty)" = "/dev/tty1" ]; then
  if uwsm check may-start; then
    exec uwsm start hyprland-uwsm.desktop
  fi
fi

# Rust
source "$HOME/.cargo/env"

export PATH="$HOME/.local/bin:$PATH"

# My-scripts
export PATH="$HOME/.local/share/bin:$PATH"

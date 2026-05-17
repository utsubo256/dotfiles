# ターミナル起動時にtmuxを自動で起動する
# tmux内でウィンドウ/ペインを開いたときに.zshrcが再読み込みされても二重起動しないよう、tmux外からの起動時のみ実行する
if [ -z "$TMUX" ]; then
  tmux new-session -A -s main
fi

# mise
eval "$(/usr/bin/mise activate zsh)"

bindkey -e

# alias
alias mirror='hyprctl keyword monitor "HDMI-A-1,preferred,auto,1,mirror,eDP-1"'
alias dual='hyprctl keyword monitor "HDMI-A-1,1920x1080@60,1920x0,1"'
alias capa='cat /sys/class/power_supply/BAT0/capacity'
alias light='sudo vim /sys/class/backlight/amdgpu_bl1/brightness'
alias gc="cd \$(ghq root)/\$(ghq list | fzf)"
# Waydroid: miseのPythonではなくシステムPythonを使うための回避策
alias waydroid="PYTHONPATH=/usr/lib/waydroid /usr/bin/python3 /usr/bin/waydroid"

# function
notify() {
  local time="$1"
  local message="$2"

  if [[ -z "$time" || -z "$message" ]]; then
    echo "ArgumentError: missing required arguments."
    echo "Usage: notify <time> <message>"
    echo "Example: notify 12:00 'It is 12:00 now!'"
    echo "Example: notify \"2025-10-04 12:00\" 'It is 12:00 now!'"
    return 1
  fi

  systemd-run --user --on-calendar="$time" notify-send -u critical "$message"
}

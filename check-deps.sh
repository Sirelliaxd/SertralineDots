#!/usr/bin/env bash
# Checks that everything the configs shell out to is installed, and that the compositor
# and the shell are new enough for this config. Read only

# versions this config is written against (the Lua hyprland config and the QML API used)
hypr_min=0.57.2
qs_min=0.3.2

required=(
  # compositor and its own tools
  hyprctl hyprpaper hyprlock hyprshot grim slurp satty
  # shell and bar
  quickshell mako
  # terminal, editor, file manager
  kitty fish nvim yazi
  # menus and clipboard
  rofi cliphist wl-copy wl-paste
  # audio, backlight, media
  pipewire pipewire-pulse wireplumber wpctl brightnessctl playerctl
  # network and bluetooth, used by the network and bluetooth menus
  NetworkManager nmcli nm-applet nm-connection-editor iw macchanger pkexec ip ss
  # session and hardware
  loginctl upower udiskie pgrep pkill
  # what the configs use to read state, notify and open files
  jq curl notify-send xdg-open qs
)

optional=(
  # yazi previews, search and jump
  fd rg fzf zoxide magick 7z pdftoppm ffmpeg mediainfo exiftool
  # app targets of the keybinds
  zen-browser brave librewolf obsidian cinny
  # vpn and overlay network
  mullvad tor i2pd
  # the ipad second screen
  od-sender
  # generates the palette both rofi themes import
  wal
  # the deprecated waybar bar and its extras
  waybar cava bluetui pipemixer
)

fail=0
missing_required=()

for cmd in "${required[@]}"; do
  command -v "$cmd" >/dev/null 2>&1 || {
    missing_required+=("$cmd")
    fail=1
  }
done

rofi -modi emoji -show emoji -help >/dev/null 2>&1 || {
  missing_required+=("rofi-emoji (mode)")
  fail=1
}

missing_optional=()
for cmd in "${optional[@]}"; do
  command -v "$cmd" >/dev/null 2>&1 || missing_optional+=("$cmd")
done

check_version() {
  local name="$1" have="$2" want="$3"
  if [ -z "$have" ]; then
    echo "MISSING   $name (needs >= $want)"
    fail=1
  elif [ "$(printf '%s\n%s\n' "$want" "$have" | sort -V | head -1)" = "$want" ]; then
    echo "ok        $name $have (>= $want)"
  else
    echo "TOO OLD   $name $have (needs >= $want)"
    fail=1
  fi
}

echo "versions"
check_version Hyprland "$(hyprctl version 2>/dev/null | head -1 | awk '{print $2}')" "$hypr_min"
check_version Quickshell "$(quickshell --version 2>/dev/null | head -1 | awk '{print $2}')" "$qs_min"

echo
if [ ${#missing_required[@]} -eq 0 ]; then
  echo "required: all ${#required[@]} present"
else
  echo "required: missing ${missing_required[*]}"
fi

if [ ${#missing_optional[@]} -eq 0 ]; then
  echo "optional: all ${#optional[@]} present"
else
  echo "optional: missing ${missing_optional[*]}"
fi

echo
if [ -f "$(dirname "$0")/Local/local.lua" ]; then
  echo "Local/local.lua present"
else
  echo "Local/local.lua absent, the config runs on its portable defaults"
fi

exit "$fail"

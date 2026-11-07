# Power menu. Opened from Ctrl+Alt+Delete in niri and from the power box in waybar.
# Install it as a command named power-menu, with fuzzel on its PATH

# Let the user pick one in fuzzel's dmenu mode and print the chosen line. Prints nothing when closed with Esc
pick() {
  local placeholder=$1
  shift
  printf '%s\n' "$@" | fuzzel --dmenu --only-match --placeholder="$placeholder" \
    --lines=$# --width=24 || true
}

# Logging out, rebooting, and shutting down lose unsaved work, so ask again
confirm() {
  [ "$(pick "$1?" "󰄬  Yes" "󰜺  No")" = "󰄬  Yes" ]
}

choice=$(pick Power "󰌾  Lock" "󰤄  Suspend" "󰍃  Logout" "󰜉  Reboot" "󰐥  Shutdown")

case $choice in
  # Ask for the lock through loginctl instead of starting swaylock here. The idle daemon (swayidle) handles lock-session, so the locker is not started twice
  *Lock) loginctl lock-session ;;
  # swayidle locks before sleeping
  *Suspend) systemctl suspend ;;
  *Logout) confirm Logout && niri msg action quit --skip-confirmation ;;
  *Reboot) confirm Reboot && systemctl reboot ;;
  *Shutdown) confirm Shutdown && systemctl poweroff ;;
esac

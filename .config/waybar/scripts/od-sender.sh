#!/usr/bin/env bash

PATTERN="od-sender run"
LOG=/tmp/od-sender-waybar.log

is_running() { pgrep -f "$PATTERN" >/dev/null; }

case "$1" in
status)
  if is_running; then
    echo '{"alt":"running","class":"running","tooltip":"od-sender: running (click to stop)"}'
  else
    echo '{"alt":"stopped","class":"stopped","tooltip":"od-sender: stopped (click to start)"}'
  fi
  ;;
toggle)
  if is_running; then
    od-sender stop >>"$LOG" 2>&1
    # wait up to 2s for a clean exit
    for _ in $(seq 10); do
      is_running || break
      sleep 0.2
    done
    # still alive: force it
    is_running && pkill -f "$PATTERN"
  else
    setsid -f od-sender run >>"$LOG" 2>&1
    sleep 0.5
  fi
  pkill -RTMIN+8 waybar
  ;;
esac

#!/bin/bash
# Show current playing media (playerctl). Falls back gracefully.
if command -v playerctl >/dev/null 2>&1; then
  ARTIST=$(playerctl metadata artist 2>/dev/null)
  TITLE=$(playerctl metadata title 2>/dev/null)
  STATUS=$(playerctl status 2>/dev/null)
  if [ -n "$TITLE" ]; then
    if [ -n "$ARTIST" ]; then
      echo "$ARTIST — $TITLE"
    else
      echo "$TITLE"
    fi
  elif [ "$STATUS" = "Playing" ] || [ "$STATUS" = "Paused" ]; then
    echo "$STATUS"
  else
    echo ""
  fi
else
  echo ""
fi

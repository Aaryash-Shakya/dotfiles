#!/bin/bash
# Show current user and host
printf "%s@%s" "$USER" "$(hostname -s 2>/dev/null || hostname)"

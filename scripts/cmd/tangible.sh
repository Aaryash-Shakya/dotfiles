#!/bin/bash

# Open Zed for frontend on workspace 2
# zed ~/Documents/arbyte/tangible-frontend &

# Open VS Code for backend on workspace 2
code --disable-gpu --ozone-platform=x11 ~/Documents/arbyte/tangible-backend &

# Start a new tmux session named 'tangible'
tmux new-session -d -s tangible

# Create first window named 'back' and split into two panes
# Both panes will start in /home/aaryash/Documents/arbyte/tangible-backend
tmux rename-window -t tangible:1 back
tmux send-keys -t tangible:1 "cd /home/aaryash/Documents/arbyte/tangible-backend" C-m
tmux send-keys -t tangible:1 "yarn dev" C-m
tmux split-window -h -t tangible:1
tmux send-keys -t tangible:1.1 "cd /home/aaryash/Documents/arbyte/tangible-backend" C-m

# Create second window named 'front' and split into two panes
# Both panes will start in /home/aaryash/Documents/arbyte/tangible-frontend
tmux new-window -t tangible:2 -n front
tmux send-keys -t tangible:2 "cd /home/aaryash/Documents/arbyte/tangible-frontend" C-m
tmux send-keys -t tangible:2 "yarn dev" C-m
tmux split-window -h -t tangible:2
tmux send-keys -t tangible:2.1 "cd /home/aaryash/Documents/arbyte/tangible-frontend" C-m

# Create third window named 'pgcli'
tmux new-window -t tangible:3 -n pgcli
tmux send-keys -t tangible:3 "pgcli tangible" C-m

# Attach to the session
#tmux attach-session -t tangible

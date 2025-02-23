#!/bin/bash

# Open VS Code for frontend and backend
code ~/Documents/arbyte/tangible-frontend &
code ~/Documents/arbyte/tangible-backend &

# Start a new tmux session named 'dev'
tmux new-session -d -s dev

# Create first window named 'back' and split into two panes
# Both panes will start in /home/aaryash-u/Documents/arbyte/tangible-backend
tmux rename-window -t dev:1 back
tmux send-keys -t dev:1 "cd /home/aaryash-u/Documents/arbyte/tangible-backend" C-m
tmux send-keys -t dev:1 "yarn dev" C-m
tmux split-window -h -t dev:1
tmux send-keys -t dev:1.1 "cd /home/aaryash-u/Documents/arbyte/tangible-backend" C-m

# Create second window named 'front' and split into two panes
# Both panes will start in /home/aaryash-u/Documents/arbyte/tangible-frontend
tmux new-window -t dev:2 -n front
tmux send-keys -t dev:2 "cd /home/aaryash-u/Documents/arbyte/tangible-frontend" C-m
tmux send-keys -t dev:2 "yarn dev" C-m
tmux split-window -h -t dev:2
tmux send-keys -t dev:2.1 "cd /home/aaryash-u/Documents/arbyte/tangible-frontend" C-m

# Attach to the session
#tmux attach-session -t dev

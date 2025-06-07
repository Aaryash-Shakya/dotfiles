#!/bin/bash

# Switch to workspace 2 
wtype -M meta -M shift -k 2 -m shift -m meta

# Open Zed for frontend on workspace 2
zed ~/Documents/arbyte/tangible-frontend &

# Open VS Code for backend on workspace 2
code ~/Documents/arbyte/tangible-backend &

# Wait 1 second for the above programs to launch
sleep 1
# Switch to workspace 1 
wtype -M meta -M shift -k 1 -m shift -m meta

# Open Trello board and Google Doc in workspace 1
xdg-open "https://trello.com/b/yfBaqSgB/tangible-sprint-board" >/dev/null 2>&1 &
xdg-open "https://docs.google.com/document/d/1EWvFBQhYvF3KeONgSQ5rz27EGt7QWu68urqR26v7viw/edit?tab=t.dn6dq5dlf615#heading=h.cqulp7y5tzqy" >/dev/null 2>&1 &

# Start a new tmux session named 'dev'
tmux new-session -d -s dev

# Create first window named 'back' and split into two panes
# Both panes will start in /home/aaryash-u/Documents/arbyte/tangible-backend
tmux rename-window -t dev:1 back
tmux send-keys -t dev:1 "cd /home/aaryash-f/Documents/arbyte/tangible-backend" C-m
tmux send-keys -t dev:1 "yarn dev" C-m
tmux split-window -h -t dev:1
tmux send-keys -t dev:1.1 "cd /home/aaryash-f/Documents/arbyte/tangible-backend" C-m

# Create second window named 'front' and split into two panes
# Both panes will start in /home/aaryash-u/Documents/arbyte/tangible-frontend
tmux new-window -t dev:2 -n front
tmux send-keys -t dev:2 "cd /home/aaryash-f/Documents/arbyte/tangible-frontend" C-m
tmux send-keys -t dev:2 "yarn dev" C-m
tmux split-window -h -t dev:2
tmux send-keys -t dev:2.1 "cd /home/aaryash-f/Documents/arbyte/tangible-frontend" C-m

# Attach to the session
#tmux attach-session -t dev

#!/bin/bash
# Run from a session or window startup command to split the current pane.
#   add-panes.sh         plain shell in the bottom third
#   add-panes.sh python  bottom third split into ipython (left) and a shell (right)

bottom=$(tmux split-window -d -v -l 33% -c "$PWD" -t "$TMUX_PANE" -P -F '#{pane_id}')

if [[ $1 == python ]]; then
    tmux split-window -d -h -c "$PWD" -t "$bottom"
    tmux send-keys -t "$bottom" ipython Enter
fi

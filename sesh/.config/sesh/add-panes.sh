#!/bin/bash
# Run from a session or window startup command to split the current pane.
#   add-panes.sh         plain shell in the bottom 20%
#   add-panes.sh python  bottom 20% split into ipython (left) and a shell (right)

bottom=$(tmux split-window -d -v -l 20% -c "$PWD" -t "$TMUX_PANE" -P -F '#{pane_id}')

if [[ $1 == python ]]; then
    tmux split-window -d -h -c "$PWD" -t "$bottom"
    tmux send-keys -t "$bottom" ipython Enter
fi

#!/bin/bash
# Keep this pane attached to a tmux session on a remote host, reconnecting
# when the connection drops (laptop sleep, network change). Detaching the
# remote tmux (C-b d) or closing its last window ends the loop.
#   remote-tmux.sh <ssh host> [session name, default main]

host=${1:?usage: remote-tmux.sh <ssh host> [session]}
session=${2:-main}

# Tells the local tmux to pass C-hjkl and M-hjkl through to the remote tmux.
tmux set -p -t "$TMUX_PANE" @pane-is-remote 1
trap 'tmux set -pu -t "$TMUX_PANE" @pane-is-remote' EXIT

while true; do
    ssh -t "$host" "tmux new-session -A -s $session" && break
    echo "Lost the connection to $host. Reconnecting in 5 seconds (Ctrl-C to stop)..."
    sleep 5
done

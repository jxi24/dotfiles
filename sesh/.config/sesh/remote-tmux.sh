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

# Forward the laptop's slurm-watch wake socket to the remote host, so that
# submitting a job there starts the job watcher (hpc/slurm-wake). Any stale
# socket from an earlier connection is removed first, or the forward fails.
# This connection skips ssh's shared one (ControlPath=none): a forward on the
# shared connection outlives this session and isn't recreated after cleanup.
forward=()
local_sock=${XDG_RUNTIME_DIR:-/run/user/$UID}/slurm-watch.sock
if [[ -S $local_sock ]]; then
    remote_user=$(ssh -G "$host" | awk '/^user / { print $2 }')
    remote_sock=/tmp/slurm-watch-$remote_user.sock
    forward=(-o ControlPath=none -R "$remote_sock:$local_sock")
fi

while true; do
    ((${#forward[@]})) && ssh -n "$host" "rm -f $remote_sock" 2>/dev/null
    ssh -t "${forward[@]}" "$host" "tmux new-session -A -s $session" && break
    echo "Lost the connection to $host. Reconnecting in 5 seconds (Ctrl-C to stop)..."
    sleep 5
done

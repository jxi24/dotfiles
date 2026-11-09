#!/bin/bash
# Ghostty's startup command: decides which tmux session a new window opens.
#
# The first window attaches to the home session. Later windows get their own
# session so they don't mirror the first one.

home_session=${HOME##*/}

# Ghostty runs each window in a systemd scope that is torn down when the window
# closes, taking any process inside it along. Start the server in a scope of
# its own so tmux survives quitting Ghostty.
if ! tmux has-session 2>/dev/null; then
    systemd-run --user --scope --quiet --collect \
        tmux new-session -d -s "$home_session" -c "$HOME"
fi

if [[ -z $(tmux list-clients 2>/dev/null) ]]; then
    exec tmux new-session -A -s "$home_session" -c "$HOME"
fi

# Closing a window leaves its session running in tmux. Reuse one left behind by
# an earlier window so they don't pile up. Only auto-numbered sessions qualify,
# so anything you named is never taken over.
spare=$(tmux list-sessions -F '#{session_attached} #{session_name}' |
    awk '$1 == 0 && $2 ~ /^[0-9]+$/ { print $2; exit }')
if [[ -n $spare ]]; then
    exec tmux attach-session -t "=$spare"
fi

exec tmux new-session -c "$HOME"

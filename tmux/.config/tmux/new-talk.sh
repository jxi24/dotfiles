#!/bin/bash
# Bound to leader t, run inside a popup: make a folder for a new talk under
# ~/Documents/Talks and open it as a sesh session (the Talks/* layout).
# A name that already exists just opens. An empty name cancels.

talks=$HOME/Documents/Talks

read -rep "New talk (title or conference): " name || exit 0
# Spaces become underscores, and anything unsafe in a folder or session name is dropped.
name=${name// /_}
name=${name//[^A-Za-z0-9_-]/}
[[ -n $name ]] || exit 0

mkdir -p "$talks/$name"
exec sesh connect "$talks/$name"

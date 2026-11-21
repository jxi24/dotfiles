#!/bin/bash
# Bound to leader t, run inside a popup: make a folder for a new talk under
# ~/Documents/Talks and open it as a sesh session (the Talks/* layout).
# A name that already exists just opens. An empty name cancels.
#
# For a new talk, a date (anything `date -d` reads: 2027-03-12, "mar 12") also
# makes the talk's note in the Work vault (Talks/, gtd.py talk) and a "Prepare
# talk" task due that day, with an optional project, so it's planned, on the
# calendar and in the year's record. `gtd.py talk link` adds the slides later.

talks=$HOME/Documents/Talks

read -rep "New talk (title or conference): " title || exit 0
# Spaces become underscores, and anything unsafe in a folder or session name is dropped.
name=${title// /_}
name=${name//[^A-Za-z0-9_-]/}
[[ -n $name ]] || exit 0

if [[ ! -d $talks/$name ]]; then
    mkdir -p "$talks/$name/figures"
    if command -v gtd-capture >/dev/null; then
        read -rep "Date of the talk (Enter: no GTD task): " when
        if [[ -n $when ]] && due=$(date -d "$when" +%F 2>/dev/null); then
            read -rep "GTD project (Enter: none): " project
            if command -v gtd.py >/dev/null; then
                note=(gtd.py talk new "$title" --date "$due" --folder "$talks/$name")
                "${note[@]}" ${project:+--project "$project"} 2>/dev/null ||
                    { [[ -n $project ]] && "${note[@]}" 2>/dev/null; } # a project with no note: the talk note without it
            fi
            gtd-capture "new: Prepare talk: $title due $due deep${project:+ #$project} -- slides in ~/Documents/Talks/$name" >/dev/null 2>&1 &&
                echo "Added 'Prepare talk: $title', due $due."
        elif [[ -n $when ]]; then
            echo "Couldn't read '$when' as a date; no task added." && sleep 2
        fi
    fi
fi
exec sesh connect "$talks/$name"

#!/bin/bash
# Bound to leader t, run inside a popup: make a folder for a new talk under
# ~/Documents/Talks and open it as a sesh session (the Talks/* layout).
# A name that already exists just opens. An empty name cancels.
#
# For a new talk, a date (anything `date -d` reads: 2027-03-12, "mar 12") also
# runs `gtd.py talk new`, with an optional project: the talk's note in the Work
# vault (Talks/) and its "Prepare talk" task, due that day and scheduled a week
# before, so it's planned, on the calendar and in the year's record. A project
# with no Projects/ note is dropped. Only if gtd.py is missing or fails is the
# task captured with gtd-capture instead. `gtd.py talk link` adds the slides later.

talks=$HOME/Documents/Talks
projects=$HOME/Documents/Obsidian/Work/Projects

read -rep "New talk (title or conference): " title || exit 0
# Spaces become underscores, anything unsafe in a folder or session name is
# dropped, and so are leading and trailing _ and - (as the vault's folder_name).
name=${title// /_}
name=${name//[^A-Za-z0-9_-]/}
name=${name#"${name%%[!_-]*}"}
name=${name%"${name##*[!_-]}"}
[[ -n $name ]] || exit 0

if [[ ! -d $talks/$name ]]; then
    mkdir -p "$talks/$name/figures"
    if command -v gtd.py >/dev/null || command -v gtd-capture >/dev/null; then
        read -rep "Date of the talk (Enter: no GTD task): " when
        if [[ -n $when ]] && due=$(date -d "$when" +%F 2>/dev/null); then
            read -rep "GTD project (Enter: none): " project
            made=
            if command -v gtd.py >/dev/null; then
                note=(gtd.py talk new "$title" --date "$due" --folder "$talks/$name")
                if out=$("${note[@]}" ${project:+--project "$project"} </dev/null 2>/dev/null); then
                    made=1
                elif [[ -n $project ]] && out=$("${note[@]}" </dev/null 2>/dev/null); then
                    made=1 # a project with no note: the talk without it
                fi
                [[ -n $made && -n $out ]] && echo "$out"
            fi
            if [[ -z $made ]] && command -v gtd-capture >/dev/null; then
                tag=
                [[ -n $project && -f $projects/$project.md ]] && tag=" #$project"
                gtd-capture "new: Prepare talk: $title due $due deep$tag -- slides in ~/Documents/Talks/$name" \
                    </dev/null >/dev/null 2>&1 &&
                    echo "Added 'Prepare talk: $title', due $due."
            fi
            sleep 1 # time to read it before the session replaces the popup
        elif [[ -n $when ]]; then
            echo "Couldn't read '$when' as a date; no task added." && sleep 2
        fi
    fi
fi
exec sesh connect "$talks/$name"

#!/bin/bash
# Bound to leader L, run inside a popup: a letter for the GTD vault's letter
# pipeline (gtd.py letter) and, for one you write, its LaTeX file.
#
#   kind   r: a recommendation you write (Mentoring)
#          s: a letter of support you write for someone's grant (Service)
#          f: a letter you asked someone for, for your own proposal (a Waiting item)
#   name, what it's for, and the due date (anything `date -d` reads)
#
# gtd.py letter makes the task (due that day, scheduled five days before), the
# person's People note and Letters/<Name>.md in the vault. For r and s, the
# letter itself goes outside the vault, in $letters/<FirstLast>/<year>/
# <What>_Letter.tex: a copy of the person's last letter when there is one
# (start from it), else an msuletter skeleton. It opens in nvim in a tmux
# session "letter-<FirstLast>". A person's existing folder is reused when the
# typed name starts it (Josie → JosiePaton). Letters are confidential: the
# .tex stays on the laptop, and `gtd.py letter --sync` links it from the vault.

letters=${LETTERS_DIR:-$HOME/Documents/Faculty/Letters}

read -rep "Letter: (r)ecommendation, (s)upport, (f)rom someone [r]: " kind || exit 0
case ${kind:-r} in
    r*) kind=recommendation prefix= ;;
    s*) kind=support prefix=support ;;
    f*) kind=from prefix=from ;;
    *) echo "Not a kind: $kind" && sleep 2 && exit 0 ;;
esac
read -rep "Name: " name || exit 0
name=$(echo "$name" | xargs)
[[ -n $name ]] || exit 0
read -rep "For (e.g. NSF GRFP, Fermilab Wilson): " purpose || exit 0
purpose=$(echo "$purpose" | xargs)
read -rep "Due (Enter: none): " when || exit 0
due=
if [[ -n $when ]] && ! due=$(date -d "$when" +%F 2>/dev/null); then
    echo "Couldn't read '$when' as a date; no due date." && sleep 2
    due=
fi
# "feb 1" in November means next February.
if [[ -n $due && $due < $(date +%F) && ! $when =~ [0-9]{4} ]]; then
    due=$(date -d "$due +1 year" +%F)
fi

# The vault: task, People note, Letters/<Name>.md (or the Waiting item).
args=(${prefix:+"$prefix"} "$name")
[[ -n $purpose ]] && args+=(for "$purpose")
[[ -n $due ]] && args+=(due "$due")
if command -v gtd.py >/dev/null; then
    gtd.py letter "${args[@]}" </dev/null || { echo "gtd.py letter failed." && sleep 3; }
else
    echo "gtd.py isn't on PATH: no task made."
fi
if [[ $kind == from ]]; then
    sleep 2
    exit 0
fi

# The letter: <FirstLast>/<year>/<What>_Letter.tex
key=${name//[^A-Za-z0-9]/}
person=$key
matches=()
for d in "$letters"/*/; do
    d=${d%/}
    d=${d##*/}
    [[ ${d,,} == "${key,,}"* && $d != Template ]] && matches+=("$d")
done
((${#matches[@]} == 1)) && person=${matches[0]}
stem=${purpose:-General}
stem=${stem// /_}
stem=${stem//[^A-Za-z0-9_-]/}
dir=$letters/$person/$(date +%Y)
file=$dir/${stem}_Letter.tex
mkdir -p "$dir"
chmod 700 "$letters/$person"
if [[ ! -e $file ]]; then
    last=$(find "$letters/$person" -name '*_Letter.tex' -printf '%T@ %p\n' 2>/dev/null | sort -rn | head -1 | cut -d' ' -f2-)
    if [[ -n $last ]]; then
        cp "$last" "$file"
        echo "Started from ${last#"$letters"/}"
    else
        opening="It is my pleasure to recommend $name."
        [[ $kind == support ]] && opening="I am writing in strong support of $name's ${purpose:-proposal}."
        cat >"$file" <<TEX
%!TEX TS-program = lualatex
% Letter for $name${purpose:+: $purpose}${due:+ (due $due)}
\\documentclass[11pt]{msuletter}

\\begin{document}
\\begin{letter}{Committee\\\\
Address}
\\opening{Dear Members of the Committee,}

$opening

\\closing{Sincerely,}

\\end{letter}
\\end{document}
TEX
        echo "New letter: ${file#"$letters"/}"
    fi
else
    echo "Already there: ${file#"$letters"/}"
fi
sleep 1

session=letter-$person
if ! tmux has-session -t "=$session" 2>/dev/null; then
    tmux new-session -d -s "$session" -c "$dir"
    tmux send-keys -t "=$session:" "nvim $(printf '%q' "$file")" Enter
else
    tmux new-window -t "=$session:" -c "$dir"
    tmux send-keys -t "=$session:" "nvim $(printf '%q' "$file")" Enter
fi
tmux switch-client -t "=$session"

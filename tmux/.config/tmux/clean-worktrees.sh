#!/bin/bash
# Bound to leader D, run inside a popup: list a bare repo's worktrees with the
# date of their last commit, and remove the ones you pick.
#
# Status column:
#   in main     every commit is already on origin's default branch
#   PR merged   a merged GitHub PR has exactly this commit as its head
#   remote gone the branch was deleted on origin (often merged, not certain)
#   stale       no commits for STALE_DAYS
#   locked      locked with `git worktree lock`; never removed here
#   missing     the directory is gone; removing just tidies git's records
#
# Safety: a worktree with uncommitted changes is never removed. The branch is
# deleted only for "in main" and "PR merged", so other commits stay reachable.
# The default branch's worktree and the one you are in are not listed.

STALE_DAYS=90

fail() {
    echo "$1"
    read -rsn1 -p "Press any key to close."
    exit 1
}

common=$(git rev-parse --path-format=absolute --git-common-dir 2>/dev/null) ||
    fail "Not inside a git repo."
[[ ${common##*/} == .bare ]] || fail "This repo has no .bare directory."
root=${common%/.bare}
current=$(git rev-parse --show-toplevel 2>/dev/null)

echo "Fetching origin..."
git -C "$root" fetch --quiet --prune origin || fail "Couldn't fetch origin."
default=$(git -C "$root" ls-remote --symref origin HEAD | awk '/^ref:/ { sub("refs/heads/", "", $2); print $2; exit }')
[[ -n $default ]] || fail "Couldn't find origin's default branch."

# Heads of merged PRs, when the repo is on GitHub. Squash merges need this.
merged_heads=$(gh pr list --state merged --limit 1000 --json headRefOid --jq '.[].headRefOid' 2>/dev/null)

echo "Checking worktrees..."
now=$(date +%s)
rows=()
add_row() { # path name status epoch changes
    local when=-- age=--
    if [[ -n $4 ]]; then
        when=$(date -d "@$4" +%F)
        age="$(((now - $4) / 86400))d ago"
    fi
    local changes="" name=$2
    (($5 > 0)) && changes="$5 uncommitted"
    # Long names keep their end, which is the part that tells them apart.
    ((${#name} > 50)) && name="…${name: -49}"
    rows+=("$(printf '%s\t%s\t%-50s  %-11s  %s  %8s  %s' "$1" "${4:-0}" "$name" "$3" "$when" "$age" "$changes")")
}

check() { # path sha branch locked prunable
    local path=$1 sha=$2 branch=$3 name status="" epoch="" changes=0
    [[ $path == "$current" || $branch == "$default" ]] && return
    if [[ $path == "$root"/* ]]; then name=${path#"$root"/}; else name=${path/#"$HOME"/\~}; fi
    [[ -n $branch && $branch != "${name##*/}" ]] && name+=" ($branch)"
    [[ -z $branch ]] && name+=" (detached)"

    if [[ -n $5 ]]; then
        add_row "$path" "$name" missing "" 0
        return
    fi
    epoch=$(git -C "$root" log -1 --format=%ct "$sha")
    changes=$(git -C "$path" status --porcelain 2>/dev/null | wc -l)

    if [[ -n $4 ]]; then
        status=locked
    elif git -C "$root" merge-base --is-ancestor "$sha" "origin/$default" 2>/dev/null; then
        status="in main"
    elif grep -qx "$sha" <<<"$merged_heads"; then
        status="PR merged"
    elif [[ -n $branch && $(git -C "$root" for-each-ref --format='%(upstream:track)' "refs/heads/$branch") == "[gone]" ]]; then
        status="remote gone"
    elif ((now - epoch > STALE_DAYS * 86400)); then
        status=stale
    fi
    add_row "$path" "$name" "$status" "$epoch" "$changes"
}

path="" sha="" branch="" locked="" prunable="" bare=""
while IFS= read -r line; do
    case $line in
    "worktree "*) path=${line#worktree } ;;
    "HEAD "*) sha=${line#HEAD } ;;
    "branch "*) branch=${line#branch refs/heads/} ;;
    bare) bare=1 ;;
    locked*) locked=1 ;;
    prunable*) prunable=1 ;;
    "")
        [[ -n $path && -z $bare ]] && check "$path" "$sha" "$branch" "$locked" "$prunable"
        path="" sha="" branch="" locked="" prunable="" bare=""
        ;;
    esac
done < <(git -C "$root" worktree list --porcelain; echo)

((${#rows[@]})) || fail "No other worktrees."

# Oldest first, so stale work collects at the top.
mapfile -t picked < <(printf '%s\n' "${rows[@]}" | sort -t$'\t' -k2,2n |
    fzf --multi --reverse --delimiter=$'\t' --with-nth=3 \
        --header=$'Tab: select   Enter: remove selected   Esc: cancel\nNAME                                                STATUS       LAST COMMIT' \
        --preview='git -C {1} log --oneline --decorate -8 2>/dev/null; echo; git -C {1} status --short 2>/dev/null | head -20' \
        --preview-window=down,40% | cut -f1)
((${#picked[@]})) || exit 0

echo
printf '  %s\n' "${picked[@]/#"$HOME"/\~}"
read -rp "Remove these ${#picked[@]} worktrees? [y/N] " answer
[[ $answer == [yY]* ]] || exit 0
echo

for path in "${picked[@]}"; do
    label=${path/#"$HOME"/\~}
    if [[ ! -d $path ]]; then
        git -C "$root" worktree prune
        echo "tidied    $label (directory was already gone)"
        continue
    fi
    if [[ -n $(git -C "$path" status --porcelain 2>/dev/null) ]]; then
        echo "SKIPPED   $label: it has uncommitted changes"
        continue
    fi
    if git -C "$root" worktree list --porcelain | grep -A5 -Fx "worktree $path" | grep -q '^locked'; then
        echo "SKIPPED   $label: it is locked"
        continue
    fi
    sha=$(git -C "$path" rev-parse HEAD)
    branch=$(git -C "$path" symbolic-ref --quiet --short HEAD)

    # Close its tmux session first, so no shell is left in a deleted directory.
    tmux list-sessions -F '#{session_path}|#{session_name}' 2>/dev/null |
        awk -F'|' -v p="$path" '$1 == p { print $2 }' |
        while IFS= read -r session; do tmux kill-session -t "=$session"; done

    if ! output=$(git -C "$root" worktree remove "$path" 2>&1); then
        echo "FAILED    $label: ${output##*$'\n'}"
        continue
    fi
    if [[ -n $branch ]] && { git -C "$root" merge-base --is-ancestor "$sha" "origin/$default" ||
        grep -qx "$sha" <<<"$merged_heads"; }; then
        git -C "$root" branch -D --quiet "$branch"
        echo "removed   $label and its merged branch $branch"
    else
        echo "removed   $label${branch:+ (kept branch $branch)}"
    fi
done
echo
read -rsn1 -p "Press any key to close."

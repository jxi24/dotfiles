#!/bin/bash
# Bound to leader n: create a worktree for a branch and open it as a sesh session.
#   new-worktree.sh <directory inside the repo> <branch>
#
# Only for repos laid out as a .bare directory with worktrees beside it. A new
# branch starts from the latest default branch on origin. An existing worktree
# is opened as it is.

CMAKE_CMD='cmake .. -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_EXPORT_COMPILE_COMMANDS=ON'

die() {
    tmux display-message -d 5000 "new worktree: $1"
    exit 1
}

# Run git in the repo root, reporting the last line of any error in tmux.
git_root() {
    local output
    output=$(git -C "$root" "$@" 2>&1) || die "${output##*$'\n'}"
    printf '%s\n' "$output"
}

dir=$1
branch=$2
[[ -n $branch ]] || exit 0
git check-ref-format --branch "$branch" >/dev/null 2>&1 || die "invalid branch name: $branch"

common=$(git -C "$dir" rev-parse --path-format=absolute --git-common-dir 2>/dev/null) ||
    die "not inside a git repo"
[[ ${common##*/} == .bare ]] || die "this repo has no .bare directory"
root=${common%/.bare}

# Flat directory names: the sesh.toml wildcards only match one level deep.
path=$root/${branch//\//-}

created=false
if [[ ! -e $path ]]; then
    tmux display-message "new worktree: fetching origin..."
    default=$(git_root ls-remote --symref origin HEAD | awk '/^ref:/ { sub("refs/heads/", "", $2); print $2; exit }')
    [[ -n $default ]] || die "couldn't find origin's default branch"

    if git -C "$root" show-ref --verify --quiet "refs/heads/$branch"; then
        git_root worktree add "$path" "$branch" >/dev/null
    elif [[ -n $(git_root ls-remote --heads origin "refs/heads/$branch") ]]; then
        git_root fetch origin "+refs/heads/$branch:refs/remotes/origin/$branch" >/dev/null
        git_root worktree add --track -b "$branch" "$path" "origin/$branch" >/dev/null
    else
        git_root fetch origin "+refs/heads/$default:refs/remotes/origin/$default" >/dev/null
        git_root worktree add --no-track -b "$branch" "$path" "origin/$default" >/dev/null
    fi
    created=true
    # Exists before sesh connects so the build window opens inside it.
    [[ -f $path/CMakeLists.txt ]] && mkdir -p "$path/build"
fi

sesh connect "$path" || die "couldn't open $path"

if $created && [[ -f $path/CMakeLists.txt ]]; then
    session=$(tmux list-sessions -F '#{session_path}|#{session_name}' |
        awk -F'|' -v p="$path" '$1 == p { print $2; exit }')
    [[ -n $session ]] && tmux send-keys -t "=$session:build" "$CMAKE_CMD" Enter
fi

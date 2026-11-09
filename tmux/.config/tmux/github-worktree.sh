#!/bin/bash
# Bound to leader N, run inside a popup: pick an open GitHub issue or PR, then
# open its worktree through new-worktree.sh, the same as leader n.
#
#   issue          branch <number>-<title>, or an existing <number>-* worktree
#   PR             the PR's own branch
#   PR from a fork a local pr-<number> branch of the PR's head

die() {
    tmux display-message -d 5000 "github worktree: $1"
    exit 1
}

common=$(git rev-parse --path-format=absolute --git-common-dir 2>/dev/null) ||
    die "not inside a git repo"
[[ ${common##*/} == .bare ]] || die "this repo has no .bare directory"
root=${common%/.bare}

echo "Loading issues and PRs..."
issues=$(gh issue list --state open --limit 200 --json number,title \
    --jq '.[] | [.number, "issue", .title] | @tsv' 2>&1) || die "${issues##*$'\n'}"
prs=$(gh pr list --state open --limit 200 --json number,title,headRefName,isCrossRepository \
    --jq '.[] | [.number, "PR", .title, .headRefName, .isCrossRepository] | @tsv' 2>&1) ||
    die "${prs##*$'\n'}"

# Exits quietly if nothing is picked.
choice=$(printf '%s\n%s\n' "$issues" "$prs" | grep . | sort -rn |
    fzf --reverse --delimiter=$'\t' --with-nth=1..3 --prompt='Issue or PR> ') || exit 0
IFS=$'\t' read -r number kind title head cross <<<"$choice"

if [[ $kind == issue ]]; then
    existing=("$root/$number"-*/)
    if [[ -d ${existing[0]} ]]; then
        existing=${existing[0]%/}
        branch=${existing##*/}
    else
        slug=$(tr '[:upper:]' '[:lower:]' <<<"$title" |
            sed -E 's/[^a-z0-9]+/-/g; s/^-//' | cut -c1-50 | sed 's/-$//')
        branch=$number${slug:+-$slug}
    fi
elif [[ $cross == true ]]; then
    branch=pr-$number
    if [[ ! -e $root/$branch ]]; then
        output=$(git -C "$root" fetch origin "+refs/pull/$number/head:refs/heads/$branch" 2>&1) ||
            die "${output##*$'\n'}"
    fi
else
    branch=$head
fi

exec "$HOME/.config/tmux/new-worktree.sh" "$PWD" "$branch"

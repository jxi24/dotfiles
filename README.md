# dotfiles

Configs managed with [GNU Stow](https://www.gnu.org/software/stow/). Each top-level
directory is a package whose contents mirror `$HOME`.

| Package    | What it holds |
|------------|---------------|
| `bash`     | `.bashrc`, `.profile` |
| `git`      | `.gitconfig`, global ignore, `git clone-worktree` script |
| `nvim`     | Neovim config |
| `ghostty`  | Ghostty config and the launcher that attaches to tmux |
| `tmux`     | tmux config and the worktree and talk scripts |
| `sesh`     | sesh project layouts |
| `starship` | prompt |
| `atuin`    | shell history |
| `wezterm`  | old terminal config, no longer used |

## New machine

1. Install the tools (Arch package names; `sesh-bin` is in the AUR):

   ```bash
   sudo pacman -S stow git neovim ghostty tmux zoxide fzf github-cli glab eza git-delta cmake
   yay -S sesh-bin
   curl -sS https://starship.rs/install.sh | sh                                         # starship
   curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh                     # atuin
   curl -o ~/.bash-preexec.sh https://raw.githubusercontent.com/rcaloras/bash-preexec/master/bash-preexec.sh
   ```

2. Clone and link. Stow refuses to replace existing files, so move any
   default `~/.bashrc` or `~/.profile` out of the way first.

   ```bash
   git clone https://github.com/jxi24/dotfiles ~/.dotfiles
   cd ~/.dotfiles
   stow bash git nvim ghostty tmux sesh starship atuin
   ```

3. Add your git identity, which is kept out of the repo:

   ```ini
   # ~/.gitconfig.local
   [user]
       name = Your Name
       email = you@example.com
   ```

4. Log in for the credential helpers: `gh auth login` and `glab auth login`.

5. Open Ghostty. tmux installs its plugins on first launch.

6. Set Ghostty as the desktop's terminal. That lives outside this repo, in
   `~/.config/hypr/hyprland.lua` and `~/.config/xdg-terminals.list`.

## Project workflow

Ghostty opens straight into tmux, and tmux keeps running after Ghostty quits.
The tmux leader is `Ctrl-a`.

| Key          | Action |
|--------------|--------|
| `leader s`   | project picker (sesh) |
| `leader S`   | previous project |
| `leader n`   | new worktree from a branch name, with the default cmake configure |
| `leader N`   | new worktree from a GitHub issue or PR |
| `leader t`   | new talk folder in `~/Documents/Talks` |
| `leader W` / `leader R` | save / restore all sessions (also automatic every 15 minutes) |
| `leader r`   | reload tmux.conf |

`leader n` and `leader N` need repos cloned with `git clone-worktree <url>`,
which puts the git data in `.bare` with one directory per worktree beside it.
Layouts for each kind of project are in `sesh/.config/sesh/sesh.toml`.

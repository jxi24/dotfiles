# dotfiles

Configs managed with [GNU Stow](https://www.gnu.org/software/stow/). Each top-level
directory is a package whose contents mirror `$HOME`.

| Package    | What it holds |
|------------|---------------|
| `bash`     | `.bashrc`, `.profile` |
| `git`      | `.gitconfig`, global ignore, `git clone-worktree` script |
| `nvim`     | Neovim config; `<leader>sr` / `Alt-r` (insert) cites a paper from the Work vault's paper notes, `<leader>sI` from an INSPIRE search (`lua/cite.lua`) |
| `ghostty`  | Ghostty config and the launcher that attaches to tmux |
| `tmux`     | tmux config and the worktree and talk scripts |
| `sesh`     | sesh project layouts |
| `starship` | prompt |
| `atuin`    | shell history |
| `build`    | C++ build defaults: ccache shared across worktrees, Ninja memory caps, lld |
| `matplotlib` | `slides` and `paper` plot styles (`plt.style.use("slides")`) |
| `slurm`    | SLURM job notifications and queue viewer for the ICER cluster |
| `hpc`      | used on the cluster itself (not stowed): shell setup, Achilles modules, job submission |
| `wezterm`  | old terminal config, no longer used |

## C++ builds

`.bashrc` makes new CMake build directories use Ninja and load
`~/.config/cmake/defaults.cmake`, which caps parallel compiles at one per
4 GB of RAM and links at two (Ninja job pools; `BUILD_COMPILE_JOBS=<n>` at
configure time overrides), and links with lld. ccache is
shared across git worktrees, so a new worktree off a recent branch mostly
builds from cache, and CPM downloads dependencies once into `~/.cache/CPM`.
Existing build directories keep their generator; delete one to switch it.

## New machine

1. Install the tools (Arch package names; `sesh-bin` is in the AUR):

   ```bash
   sudo pacman -S stow git neovim ghostty tmux zoxide fzf github-cli glab eza git-delta cmake ninja ccache lld
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
   stow bash git nvim ghostty tmux sesh starship atuin slurm build matplotlib
   systemctl --user enable --now slurm-watch slurm-watch-wake.socket   # SLURM notifications
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
| `leader t`   | new talk folder in `~/Documents/Talks`; with a date, also a "Prepare talk" GTD task |
| `leader g`   | GTD: what to work on now (`gtd.py now`, paged) |
| `leader C`   | GTD: capture a line into today's Log (`done:`, `new:`, `wait:`, ...) |
| `leader D`   | list worktrees by last commit and remove finished ones |
| `leader Q`   | SLURM queue and the last day's finished jobs on ICER |
| `leader W` / `leader R` | save / restore all sessions (also automatic every 15 minutes) |
| `leader r`   | reload tmux.conf |

`leader n` and `leader N` need repos cloned with `git clone-worktree <url>`,
which puts the git data in `.bare` with one directory per worktree beside it.
Layouts for each kind of project are in `sesh/.config/sesh/sesh.toml`.

## ICER cluster

The `icer` entry in the project picker attaches to a tmux session on the dev
node (`hpcc-dev` in `~/.ssh/config`, which is kept out of this repo) and
reconnects if the connection drops. That tmux uses prefix `Ctrl-b` and a bottom
status bar; `Ctrl-h/j/k/l` pass through to it. The `slurm-watch` service sends a
desktop notification when jobs start and finish, and the top bar shows running
(R) and queued (Q) counts.

One-time setup on the cluster, after installing Neovim into `~/.local/bin`:

```bash
git clone https://github.com/jxi24/dotfiles ~/.dotfiles
ln -s ~/.dotfiles/nvim/.config/nvim ~/.config/nvim
mkdir -p ~/.config/tmux && ln -s ~/.dotfiles/tmux/.config/tmux/remote.conf ~/.config/tmux/tmux.conf
ln -s ~/.dotfiles/hpc/achilles-submit ~/.dotfiles/hpc/run-notebook ~/.local/bin/
mkdir -p ~/.config/matplotlib && ln -s ~/.dotfiles/matplotlib/.config/matplotlib/stylelib ~/.config/matplotlib/
echo '[ -f ~/.dotfiles/hpc/bashrc.sh ] && . ~/.dotfiles/hpc/bashrc.sh' >> ~/.bashrc
nvim --headless "+Lazy! sync" +qa
nvim --headless -c "MasonInstall clangd neocmakelsp lua-language-server ruff rust-analyzer fortitude fortls debugpy" -c qa
```

To update the cluster's copy later:

```bash
cd ~/.dotfiles && git pull
```

### Achilles pipeline

Achilles lives at `~/Achilles` on the cluster (`.bare` plus worktrees). From a
local Achilles worktree on the laptop:

```bash
icer-submit -n 20 -a 'python3 ~/analysis/plots.py $EVENT_FILES' run.yml
```

This checks the branch's commit is on GitHub (offering to push), brings the
cluster worktree of the same name to that commit, builds it as a SLURM job if
needed, and submits the run to start after the build. On the cluster itself,
the same steps are `achilles-build` (prints a job id, or `up-to-date`) and
`achilles-submit -d <build job> ...`. Builds run as jobs because dev nodes stop
anything past 2 CPU-hours.

A run lives in `$SCRATCH/achilles/<date>-<card>/`. One job integrates once;
then `NEvents` is split over a 20-task SLURM array, each task in its own folder
with its own seed and its own copy of the integration cache; then the analysis
job runs once every task succeeds (if anything fails, the jobs after it are
cancelled and you get a failure notification). Analysis writes to `plots/`.
When it finishes, `slurm-watch` on the laptop copies `plots/`, the run card,
`provenance.txt` (commit, build time, options) and `changes.patch` (any
uncommitted changes on the cluster) to
`~/Documents/Projects/NeutrinoGenerator/AchillesRuns/`; event files stay in
scratch. `icer-fetch-plots [run id]` copies by hand. `achilles-submit -h`
lists options; the account is asked for when you have more than one.

To develop an analysis, generate events without `-a`, then run
`icer-notebook [run id]` on the laptop. It starts JupyterLab as a SLURM job on
a compute node (dev nodes stop anything past 2 CPU-hours), tunnels to
it, and opens the browser; Ctrl-C ends the job. Notebooks live in `~/analysis`
on the cluster, starting from `template.ipynb` (reads HepMC3, writes to
`plots/`); `runs/` links to the runs in scratch, and the kernel's `RUN_DIR` is
the chosen run, the newest by default. Once a notebook does what you want, it
becomes the pipeline's analysis step:

```bash
achilles-submit -n 20 -a 'run-notebook ~/analysis/my-analysis.ipynb' run.yml
```

The executed notebook, outputs included, comes home with the plots.

ICER's acceptable use rules count frequent squeue/sacct calls as overuse, so
`slurm-watch` checks every 5 minutes while you have jobs and switches off once
they're gone. Submitting on the cluster (`achilles-submit`, or `sbatch` in a
shell that sources `hpc/bashrc.sh`) wakes it through a socket the `icer`
connection forwards; so does opening `leader Q`. An hourly check catches jobs
submitted any other way (`SLURM_WATCH_IDLE=0` turns that off).

Finished jobs are also noted in the Work vault: a dated `note: #Project ...`
line goes into that project's notes (through `gtd-capture`), so each project
keeps a record of what ran, with the plots folder for Achilles runs. The
project comes from the job's comment (`sbatch --comment project=PSCascade`;
`achilles-submit -P` sets it, default Achilles), else from the cluster folder
it ran in (`~/.config/slurm-watch/projects`). Helper jobs say `log=no`, and
jobs with no project aren't noted. The tmux status bar also shows a running
GTD focus session.

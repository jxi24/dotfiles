# Shell setup for the ICER cluster. Sourced from the cluster's ~/.bashrc:
#   [ -f ~/.dotfiles/hpc/bashrc.sh ] && . ~/.dotfiles/hpc/bashrc.sh

export PATH="$HOME/.local/bin:$PATH" # nvim, achilles-submit
export EDITOR=nvim

# After a successful submission, wake the laptop's job watcher (hpc/slurm-wake).
sbatch() {
    command sbatch "$@"
    local status=$?
    ((status == 0)) && ~/.dotfiles/hpc/slurm-wake
    return $status
}

# Modules for building and running Achilles on the ICER cluster. All from the
# foss/2023a toolchain (GCC 12.3), so they're built against the same libraries.
#   source ~/.dotfiles/hpc/achilles-env.sh
module purge
module load foss/2023a CMake/3.31.8-GCCcore-12.3.0 HDF5/1.14.0-gompi-2023a ROOT/6.36.06-foss-2023a

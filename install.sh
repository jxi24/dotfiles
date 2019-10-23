#!/usr/bin/env bash

echo "Installing dotfiles."

source install/link.sh

echo "Creating vim directories"
mkdir -p ~/.vim/backup
mkdir -p ~/.vim/tmp

echo "Linking check_arxiv.py to ~/.dotfiles/bin"
ln -s $PWD/check_arxiv/check_arxiv.py bin/check_arxiv
cp check_arxiv/config.yaml bin/config.yaml

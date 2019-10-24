#!/usr/bin/env zsh

# Bootstrap script for installing apps and tools

# Ask for admin password upfront
sudo -v

# Keep-alive: update existing `sudo` time stamp until `.osx` has finished.
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

cd $DOTFILES/scripts

if [ `uname` == 'Darwin' ]; then
    . ./brew.zsh
    . ./nodejs.zsh
    cd -
else
    echo "You're not using a mac!"
    exit 1
fi
#!/bin/bash

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# Save history directly instead of waiting terminal to close
export PROMPT_COMMAND="history -a;$PROMPT_COMMAND"

print_git_info() {
  git rev-parse --is-inside-work-tree >/dev/null 2>&1 || echo "Your are outside a git repository"
  echo "name=$(git config user.name)"
  echo "email=$(git config user.email)"
  echo "signingkey=$(git config user.signingkey)"
}

configure_git_local() {
  git config --local user.name "$1" &&
    git config --local user.email "$2" && ([ -z "$3" ] && (
      git config --local commit.gpgsign false &&
        git config --local user.signingkey ""
    ) || (
      git config --local commit.gpgsign true &&
        git config --local user.signingkey "$3"
    )) &&
    print_git_info
}

alias mpv='mpv --pause --keep-open'
alias ffmpeg='ffmpeg -hide_banner'
alias ffprobe='ffprobe -hide_banner'
alias yt='yt-dlp --add-metadata -i'
alias yta='yt -x -f bestaudio/best'
alias vv='. venv/bin/activate'
alias vvc='virtualenv venv && vv'
alias gitc='print_git_info'
alias gitPerso='configure_git_local $GIT_PERSO_NAME $GIT_PERSO_EMAIL $GIT_PERSO_SIGNINGKEY'
alias gitStudent='configure_git_local $GIT_STUDENT_NAME $GIT_STUDENT_EMAIL $GIT_STUDENT_SIGNINGKEY'
alias keepass-diff='docker run -it --rm -v "$(pwd)":/app:ro "keepass-diff:custom-local"'

# Prompt style
eval "$(starship init bash)"

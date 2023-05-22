#!/bin/sh

FORCE_YES=0
DEFAULT="NO"
MESSAGE="Are You Sure?"
TERMINAL_ONLY=0

while getopts ":m:tyY" OPT; do
  case $OPT in
  m)
    MESSAGE="$OPTARG"
    shift
    ;;
  t)
    TERMINAL_ONLY=1
    ;;
  Y)
    DEFAULT="YES"
    ;;
  y)
    FORCE_YES=1
    ;;
  \?)
    echo "Invalid option: -$OPTARG" >&2
    ;;
  :*)
    echo "Option -$OPTARG requires an argument." >&2
    exit 1
    ;;
  esac
  shift
done

[ "$FORCE_YES" -eq 1 ] && exit 0

Y_OR_N_CLI=$([ $DEFAULT = "YES" ] && echo "[Y/n]" || echo "[y/N]")
Y_OR_N_DMENU=$([ $DEFAULT = "YES" ] && printf "Yes\nNo" || printf "No\nYes")

while true; do
  input="undefined"
  if [ "$TERMINAL_ONLY" -eq 0 ] && command -v dmenu >/dev/null; then
    if input=$(echo "$Y_OR_N_DMENU" | dmenu -p "$MESSAGE" -rq 2>&1) ||
      (echo "$input" | grep "dmenu" >/dev/null); then
      # fallback
      input=$(echo "$Y_OR_N_DMENU" | dmenu -p "$MESSAGE" 2>/dev/null)
    fi
  fi
  if [ "$input" = "undefined" ] && [ -t 0 ]; then
    printf "%s %s " "$MESSAGE" "$Y_OR_N_CLI"
    read -r input
    sleep 1000
  fi
  if [ "$input" = "undefined" ] && [ ! -t 0 ]; then
    echo "$0 can not read input form pipes"
    exit 1
  fi

  case "$input" in
  [yY][eE][sS] | [yY])
    exit 0
    ;;
  [nN][oO] | [nN])
    exit 1
    ;;
  "")
    test "$DEFAULT" = "YES" && exit 0 || exit 1
    ;;
  *) ;;
  esac

  echo "Invalid input ($input)..."
done

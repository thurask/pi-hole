#!/usr/bin/env bash
# Pi-hole: A black hole for Internet advertisements
# (c) 2015, 2016 by Jacob Salmela
# Network-wide ad blocking via your Raspberry Pi
# http://pi-hole.net
# Checkout other branches than master
#
# Pi-hole is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.

is_repo() {
  # Use git to check if directory is currently under VCS, return the value
  local directory="${1}"
  local curdir
  local rc

  curdir="${PWD}"
  cd "${directory}" || return 1
  # Capture any possible output
  git status --short &> /dev/null
  rc=$?
  cd "${curdir}" || return 1
  return $rc
}

fully_fetch_repo() {
  # Add upstream branches to shallow clone
  local directory="${1}"
  local curdir
  local rc

  curdir="${PWD}"
  cd "${directory}" || return 1
  git remote set-branches origin '*' || return 1
  git fetch --quiet || return 1
  cd "${curdir}" || return 1
  return
}

get_available_branches(){
  # Return available branches
  local directory="${1}"
  local curdir
  local branches

  curdir="${PWD}"
  cd "${directory}" || return 1
  git branch -a --list --no-color --no-column
  cd "${curdir}" || return 1
  return
}

select_branch() {
  branches=($@)
  # Divide by two so the dialogs take up half of the screen, which looks nice.
  r=$(( rows / 2 ))
  c=$(( columns / 2 ))
  # Unless the screen is tiny
  r=$(( r < 20 ? 20 : r ))
  c=$(( c < 70 ? 70 : c ))

  local cnt=${#branches[@]}
  local active=-2

  for ((i=0;i<cnt;i++)); do
    if [[ ${branches[i]} == "*" ]]; then
      # This is the currently active branch
      active=$i
    elif [[ $i == $((active+1)) ]] ; then
      branches[i]="\"${branches[i]}\" \"\" on"
    else
      # Remove first two characters
      branches[i]="\"${branches[i]}\" \"\" off"
    fi
  done

  # Strip "*"
  unset branches[$active]
  branches=( "${branches[@]}" )

  # Display dialog
  ChooseCmd=(whiptail --radiolist \"Select target branch\" ${r} ${c} ${#branches[@]})

  echo "${ChooseCmd[@]}" "${branches[@]}" | bash
  if [[ $? = 0 ]];then
    echo $choices
  fi
}

checkout_branch() {
  # Check out specified branch
  local directory="${1}"
  local branch="${2}"
  local curdir
  local branches

  curdir="${PWD}"
  cd "${directory}" || return 1
  git checkout "${branch}"
  cd "${curdir}" || return 1
  return
}
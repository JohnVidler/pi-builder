#!/bin/bash

prompt_confirm() {
  while true; do
    read -r -n 1 -p "${1:-Continue?} [y/n]: " REPLY
    case $REPLY in
      [yY]) echo ; return 0 ;;
      [nN]) echo ; return 1 ;;
      *) printf " \033[31m %s \n\033[0m" "invalid input"
    esac
  done
}

if [ ! -e /etc/manage-pi.d/.complete ]; then
  options=()

  count=0
  targets=$(ls /etc/manage-pi.d/*.sh)
  programs=("")
  for f in $targets; do
      file=$(basename "$f")
      title=$(echo $file | cut -d'.' -f 1 | sed -r 's/[\-]+/ /g')

      count=$[count+1]
      options+=($count "$title")
      programs+=($file)
  done

  exitcode=0
  while [ $exitcode == 0 ]; do
      exec 3>&1;
      selected=$(dialog --backtitle "First-Time System Configuration" --menu "Select a configuration task, or Cancel to exit" 22 76 16 "${options[@]}" 2>&1 1>&3)
      exitcode=$?;
      exec 3>&-;

      subscript="/etc/manage-pi.d/${programs[@]:selected:1}"
      if [ $exitcode == 0 ]; then
          /bin/bash "$subscript"
      fi
  done

  touch /etc/manage-pi.d/.complete

  prompt_confirm "It is strongly recommended to reboot after changing any configuration. Reboot now?" && systemctl reboot
fi
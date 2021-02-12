#!/bin/bash

BASENAME="der-controller-"

LOCKFILE="/root/.boot-set-hostname"
DEV="eth0"

if [ ! -e "$LOCKFILE" ]; then
    MAC=$(cat "/sys/class/net/$DEV/address" | tr -d :)

    hostnamectl set-hostname "$BASENAME$MAC"

    touch "$LOCKFILE"

    systemctl reboot
fi
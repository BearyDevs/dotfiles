#!/bin/bash
# This script updates a file with CPU usage every 2 seconds
mkdir -p /tmp/tmux-$(id -u)
while true; do
  CPU=$(top -l 1 | grep "CPU usage" | sed 's/.*CPU usage: \([0-9.]*\)% user.*/\1%/')
  echo "$CPU" > /tmp/tmux-$(id -u)/cpu
  sleep 5
done

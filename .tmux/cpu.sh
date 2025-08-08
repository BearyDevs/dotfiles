#!/bin/bash
top -l 1 | grep "CPU usage" | sed 's/.*CPU usage: \([0-9.]*\)% user.*/\1%/'
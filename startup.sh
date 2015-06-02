#!/bin/sh

## Base executables
nitrogen --restore
clipit &
uim-toolbar-gtk3-systray &

## X settings
xset s off
xset b off
fixwacom

if [ -f ~/.startuprc ]; then
    source ~/.startuprc
fi

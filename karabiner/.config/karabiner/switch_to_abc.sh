#!/bin/bash
CURRENT_INPUT=$(/opt/homebrew/bin/im-select)
ABC_INPUT="com.apple.keylayout.ABC"
if [ "$CURRENT_INPUT" != "$ABC_INPUT" ]; then
    /opt/homebrew/bin/im-select "$ABC_INPUT"
fi

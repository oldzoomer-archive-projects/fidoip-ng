#!/bin/sh
#  This file is part of fidoip. It is free software and it is covered
#   by the GNU general public license. See the file LICENSE for details. */

# Script to automatic install crond tasks from node/crontab.cfg.template-node
CWD=$(pwd)
HOMEDIR=$(cd ../; pwd) #  Fidoip installation directory 
IDN=$(id -un) #  User's name

set -e
set -u

TMPOUT="$(mktemp)" || echo "Error creating temporaty file."
set +e
crontab -l  > "$TMPOUT"
set -e

if grep "fido\.monthly" "$TMPOUT" 
then
    echo
    echo "I see upper line in crontab for user ""$IDN""."
    echo "Seems fidoip NMS tasks already installed."
    echo "Stop proceeding. If you would like change tasks edit crontab manually."
else
    echo "Installing fidoip NMS crontab tasks for node..."
echo
cat node/crontab.cfg.template-node | grep -v "###" | sed "s|INSTALLDIR|$HOMEDIR|g"  >> "$TMPOUT"
crontab "$TMPOUT"
echo 
crontab -l
echo ""
echo "Done. Crontab tasks for user ""$IDN"" for fidoip NMS installed successfully!"
fi

rm -f "$TMPOUT"




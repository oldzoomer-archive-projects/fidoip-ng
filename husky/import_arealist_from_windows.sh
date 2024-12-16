#!/bin/sh
#   This file is part of fidoip. It is free software and it is covered
#   by the GNU general public license. See the file LICENSE for details. */
cat INSTALLDIR/fido/config.win | grep EchoArea | sed 's|\\|/|g'

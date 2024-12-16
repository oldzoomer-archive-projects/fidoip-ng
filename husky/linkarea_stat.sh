#!/bin/sh
#   This file is part of fidoip. It is free software and it is covered
#   by the GNU general public license. See the file LICENSE for details. */
cat INSTALLDIR/usr/etc/fido/config | grep EchoArea  > INSTALLDIR/fido/hpt.area
perl INSTALLDIR/usr/bin/hpt_area.pl INSTALLDIR/fido/hpt.area


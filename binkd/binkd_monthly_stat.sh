#!/bin/sh
#   Copyright (c) by Maxim Sokolsky (2:5020/828.777). This file is part of fidoip. It is free software and it is covered
#   by the GNU general public license. See the file LICENSE for details. */

USERNAME=$(whoami) ; T1="root"
if [ "$T1" = "$USERNAME" ]; then 
echo  'Please do not run this script as root' ; exit
fi
perl INSTALLDIR/usr/bin/stat-binkd.pl -l INSTALLDIR/fido/binkd.log -s -4w +30d


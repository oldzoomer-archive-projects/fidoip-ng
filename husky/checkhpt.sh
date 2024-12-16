#!/bin/bash                                                                   
#   This file is part of fidoip. It is free software and it is covered
#   by the GNU general public license. See the file LICENSE for details. */
#  Checks config of hpt tosser using tparser. 
SEDT="sed"  # Sed program type

T1="root"
T2="Linux"
T3="FreeBSD"
T4="DragonFly"

if [ "$SYSOS" = "$T3" ]; then
Z1="BSD"
SEDT="gsed"
fi

if [ "$SYSOS" = "$T4" ]; then
Z1="BSD"
Z2="PKGSRC"
SEDT="gsed"
fi


export FIDOCONFIG=INSTALLDIR/usr/etc/fido/config 
INSTALLDIR/usr/bin/tparser

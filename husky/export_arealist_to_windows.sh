#!/bin/sh
cat INSTALLDIR/usr/etc/fido/config | grep EchoArea | sed "s|\/fido\/msgbasedir/|\\\home\\\fido\\\msgbasedir\\\|g" > INSTALLDIR/fido/config.unx

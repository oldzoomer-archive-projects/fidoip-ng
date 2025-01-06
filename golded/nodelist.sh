#!/bin/sh
curl -O --output-dir INSTALLDIR/fido/nodelist/ "ftp://wfido.ru/nodehist/$(date +%Y)/nodelist.$(date +%j)"
echo 'Updating golded nodelist index.'
INSTALLDIR/usr/bin/gnlnx -C INSTALLDIR/usr/etc/golded+/golded.cfg


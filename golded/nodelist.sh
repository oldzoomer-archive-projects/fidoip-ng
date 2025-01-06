#!/bin/sh
rm INSTALLDIR/fido/nodelist/nodelist.[0-9][0-9][0-9]
curl -O --output-dir INSTALLDIR/fido/nodelist/ "ftp://wfido.ru/nodehist/$(date +%Y)/nodelist.$(date +%j)"
chmod 644 INSTALLDIR/fido/nodelist/nodelist.[0-9][0-9][0-9]
echo 'Updating golded nodelist index.'
INSTALLDIR/usr/bin/gnlnx -C INSTALLDIR/usr/etc/golded+/golded.cfg


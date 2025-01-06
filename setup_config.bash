#!/bin/bash
#    Copyright (c) by Maxim Sokolsky (2:5020/828.777). This file is part of fidoip. It is free software and it is covered
#   by the GNU general public license. See the file LICENSE for details. */
# Usage:  bash ./setup_config.bash
# Bash only!!! Do not use sh interpretator

# Script for creation FIDONet IP point configuration

CWD=$(pwd)
HOMEDIR=$(cd ../; pwd) #  Fidoip installation directory 
TMP=$(mktemp -d)	# Location of temp's files
SYSOS=$(uname -s) # Packages architecture
date=$(date +%Y%m%d%m%s)

ARCH=$(uname -m)	# Packages architecture
OSTYPE=$(uname -o 2>/dev/null || uname -p) 
BUILD=${BUILD:-fido_my1}	# Build number packages initials 
IDN=$(id -un) #  User's name
IDG=$(id -gn)  # User's group
SEDT="gsed"  # Sed program type

T1="root"
T2="Linux"
T3="FreeBSD"
T4="DragonFly"

if [ "$SYSOS" = "$T2" ]; then
Z1="Linux"
SEDT="sed"
fi

if [ "$SYSOS" = "$T3" ]; then
Z1="BSD"
SEDT="gsed"
fi

if [ "$SYSOS" = "$T4" ]; then
Z1="BSD"
Z2="PKGSRC"
SEDT="gsed"
fi


##  make sure unzip extractor available

unziploc=$(which unzip)

if [ -x "$unziploc" ]
then
    echo "unzip extractor found: $unziploc"
else
    echo "WARNING: unzip not found."
    echo "So it will not be possible to extract fidoip on this machine."
    echo " You should take steps to get unzip installed,"
    echo " as it described in fidoip documentation."
    exit
fi
echo ""
echo "-----------------------------------"

##  make sure zip archiver available
ziploc=$(which zip)

if [ -x "$ziploc" ]
then
    echo "zip packer found: $ziploc"
else
    echo "WARNING: zip not found."
    echo "So it will not be possible to pack fido packets on this machine."
    echo " You should take steps to get zip installed,"
    echo " as it described in fidoip documentation."
    exit
fi
echo ""
echo "-----------------------------------"

##  make sure bzip2 archiver available
bzip2loc=$(which bzip2)

if [ -x "$bzip2loc" ]
then
    echo "bzip2 packer found: $bzip2loc"
else
    echo "WARNING: bzip2 not found."
    echo "So it will not be possible extract fidoip sources on this machine."
    echo " You should take steps to get bzip2 installed,"
    echo " as it described in fidoip documentation."
    exit
fi
echo ""
echo "-----------------------------------"


##  make sure sed available
sedloc=$(which "$SEDT")

if [ -x "$sedloc" ]
then
    echo "Sed found: "$SEDT": ""$sedloc"""
else
    echo "WARNING: "$SEDT" not found."
    echo "So it will not be possible extract fidoip sources on this machine."
    echo " You should take steps to get "$SEDT" installed,"
    echo " as it described in fidoip documentation."
    exit
fi
echo ""
echo "-----------------------------------"

shortdate=$(echo "${date}" | "$SEDT" s/^...//)
shortname=fidoip_configs_${shortdate}.tar

cd "$CWD"

if [ "$T1" = "$IDN" ]; then
echo 'Please DO NOT RUN this script as root. Usually it is not needed as FIDO'
echo ' may be installed under unprivileged user to home directory. In case you'
echo  'whould like to install fido as root just wait for 15 seconds.'
sleep 5
echo "Or else now press CTRL-C and later run this script under unprivileged user".
echo " as it described in fidoip documentation."
sleep 15
else
echo
fi

if [ -e "$HOMEDIR"/fido ]; then
echo
else
echo
echo 'Seems fidoip package from fidoip-*/packages/ directory do not installed.'
echo 'Please install them first and then run this script again.'
echo 'Note: fido packages may be installed to:'
echo "$HOMEDIR/usr"
echo "$HOMEDIR/fido"
echo
exit
fi

set -e
set -u

# Declaration of allowed symbol for user input scrubbing
declare -r AllowedChars="-1234567890/., :-abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
declare -r AllowedNumbers="1234567890/.:"
declare -r AllowedFtnNumbers="1234567890/:"
declare -r Alloweddns="-1234567890/. :-abcdefghijklmnopqrstuvwxyz"
declare -r Allowedsymbol="-1234567890 _abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
declare -r AllowedPwd="-1234567890_abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"

echo "--------------------------------------------------------------------"
echo ""
echo "This script setup fidoip's configuration files for you."
echo ""
echo "--------------------------------------------------------------------"
echo ""


echo "Enter your first and last name and press [ENTER]."
echo -n "Sample -  Vasiliy Pampasov: "
read fullname

if [ -z "$fullname" ]
then
echo 'You input nothing.'
echo 'Please run this script again and input something.'
exit
fi

# Checking user input&scrubbing
ScrubbedCheck="${fullname//[^$Allowedsymbol]/}"
if [ "$fullname" = "$ScrubbedCheck" ]; then
echo  ''
else
echo ' '
echo " Error. You entered wrong symbols. Allowed symbols are: "
echo -n ' '
echo -n """$Allowedsymbol"""
echo -n '               '
echo 'Please run this script again and be more carefull during inputing.'
echo -n '               '
exit
fi

# Inserting \ before space
#echo  "$fullname" | $SEDT 's_ _\\ _g' > "$TMP"/fidoiptmp
echo  "$fullname" | $SEDT 's/ /\\ /g' > "$TMP"/fidoiptmp
fullname1=$(cat "$TMP"/fidoiptmp)

# Inserting space instead of space

echo  "$fullname" | $SEDT 's/ /\_/g' > "$TMP"/fidoiptmp
fullname2=$(cat "$TMP"/fidoiptmp)


echo "Enter your station name and press[ENTER]."
echo -n "Sample -  MyStation: "
read stationname

if [ -z "$stationname" ]
then
echo 'You input nothing.'
echo 'Please run this script again and input something.'
exit
fi

# Checking user input&scrubbing
ScrubbedCheck1="${stationname//[^$Allowedsymbol]/}"
if [ "$stationname" = "$ScrubbedCheck1" ]; then
echo  ''
else
echo ' '
echo " Error. You entered wrong symbols. Allowed symbols are: "
echo -n ' '
echo -n """$Allowedsymbol"""
echo -n '               '
echo 'Please run this script again and be more carefull during inputing.'
echo -n '               '
exit
fi

# Inserting _ instead space
echo  "$stationname" | $SEDT 's/ /\_/g' > "$TMP"/fidoiptmp
stationname1=$(cat "$TMP"/fidoiptmp)


echo "Enter your location and press[ENTER]."
echo -n "Sample -  Moscow, Russia: "
read locationname
if [ -z "$locationname" ]
then
echo 'You input nothing.'
echo 'Please run this script again and input something.'
exit
fi

# Checking user input&scrubbing
ScrubbedCheck2="${locationname//[^$AllowedChars]/}"
if [ "$locationname" = "$ScrubbedCheck2" ]; then
echo  ''
else
echo ' '
echo " Error. You entered wrong symbols. Allowed symbols are: "
echo -n ' '
echo -n """$AllowedChars"""
echo -n '               '
echo 'Please run this script again and be more carefull during inputing.'
echo -n '               '
exit
fi

# Inserting _ instead space
echo  "$locationname" | $SEDT 's/ /\_/g' > "$TMP"/fidoiptmp
locationname1=$(cat "$TMP"/fidoiptmp)

# Inserting space instead -
echo  "$locationname1" | $SEDT 's/_/\ /g' > "$TMP"/fidoiptmp
locationname2=$(cat "$TMP"/fidoiptmp)

# Deleting spaces

echo  "$locationname" | $SEDT 's/\ //g' > "$TMP"/fidoiptmp
locationname3=$(cat "$TMP"/fidoiptmp)

# Deleting
echo  "$locationname3" | $SEDT 's/\,//g' > "$TMP"/fidoiptmp
locationname4=$(cat "$TMP"/fidoiptmp)


echo "Enter your FTN address and press [ENTER]."
echo -n "Sample -  2:5020/828.555: "
read ftnaddress
if [ -z "$ftnaddress" ]
then
echo 'You input nothing.'
echo 'Please run this script again and input something.'
exit
fi

CHECKFTN=$(echo "$ftnaddress" | grep "\\/" )
if [ -z "$CHECKFTN" ]
then
echo 'No symbol / in FTN number.'
echo "Try to input next try. Exiting."
rm -rf "$TMP"
exit
fi

CHECKFTN1=$(echo "$ftnaddress" | grep ":" )
if [ -z "$CHECKFTN1" ]
then
echo 'No symbol : in FTN number.'
echo "Try to input next try. Exiting."
rm -rf "$TMP"
exit
fi

CHECKFTN2=$(echo "$ftnaddress" | grep "\." )
if [ -z "$CHECKFTN2" ]
then
echo 'No symbol dot .  in FTN number.'
echo "Try to input next try. Exiting."
rm -rf "$TMP"
exit
fi



# Checking user input&scrubbing
ScrubbedCheck3="${ftnaddress//[^$AllowedNumbers]/}"
if [ "$ftnaddress" = "$ScrubbedCheck3" ]; then
echo  ''
else
echo ' '
echo " Error. You entered wrong symbols. Allowed symbols are: "
echo -n ' '
echo -n ""$AllowedNumbers""
echo -n '               '
echo 'Please run this script again and be more carefull during inputing.'
echo -n '               '
exit
fi


# Select zone number
zonenumber=$(echo  "$ftnaddress" | $SEDT 's|\:.*||')

# Inserting \ before / in a FTN address
echo  "$ftnaddress" | $SEDT 's|/|\\/|g' > "$TMP"/fidoiptmp
ftnaddress1=$(cat "$TMP"/fidoiptmp)

# Deleting everting before / and /
echo  "$ftnaddress" | $SEDT 's/.*\///' > "$TMP"/fidoiptmp
pointaddress=$(cat "$TMP"/fidoiptmp)
# Deleting everithing after .
echo  "$pointaddress" | $SEDT 's/\..*//' > "$TMP"/fidoiptmp
nodeaddress=$(cat "$TMP"/fidoiptmp)

echo -e "Enter uplink full name and press press [ENTER]."
echo -n "Sample -  Kirill Temnenkov: "
read uplinkname
if [ -z "$uplinkname" ]
then
echo 'You input nothing.'
echo 'Please run this script again and input something.'
exit
fi

# Checking user input&scrubbing
ScrubbedCheck4="${uplinkname//[^$Allowedsymbol]/}"
if [ "$uplinkname" = "$ScrubbedCheck4" ]; then
echo  ''
else
echo ' '
echo " Error. You entered wrong symbols. Allowed symbols are: "
echo -n ' '
echo -n """$Allowedsymbol"""
echo -n '               '
echo 'Please run this script again and be more carefull during inputing.'
echo -n '               '
exit
fi

# Inserting \ before space
echo  "$uplinkname" | $SEDT 's/ /\\ /g' > "$TMP"/fidoiptmp
uplinkname1=$(cat "$TMP"/fidoiptmp)



# Changing all space to _ 
echo  "$uplinkname" | $SEDT 's/ /\_/g' > "$TMP"/fidoiptmp
uplinkname2=$(cat "$TMP"/fidoiptmp)


echo -e "Enter uplink FTN address and press [ENTER]."
echo -n "Sample -  2:5020/828: "
read uplinkftnaddress
if [ -z "$uplinkftnaddress" ]
then
echo 'You input nothing.'
echo 'Please run this script again and input something.'
exit
fi

CHECKFTN3=$(echo "$ftnaddress" | grep "\\/" )
if [ -z "$CHECKFTN3" ]
then
echo 'No symbol / in FTN number.'
echo "Try to input next try. Exiting."
rm -rf "$TMP"
exit
fi

CHECKFTN4=$(echo "$ftnaddress" | grep ":" )
if [ -z "$CHECKFTN4" ]
then
echo 'No symbol : in FTN number.'
echo "Try to input next try. Exiting."
rm -rf "$TMP"
exit
fi


# Checking user input&scrubbing
ScrubbedCheck5="${uplinkftnaddress//[^$AllowedFtnNumbers]/}"
if [ "$uplinkftnaddress" = "$ScrubbedCheck5" ]; then
echo  ''
else
echo ' '
echo " Error. You entered wrong symbols. Allowed symbols are: "
echo -n ' '
echo -n ""$AllowedFtnNumbers""
echo -n '               '
echo 'Please run this script again and be more carefull during inputing.'
echo -n '               '
exit
fi

# Inserting \ before space
echo  "$uplinkftnaddress" | $SEDT 's|/|\\/|g' > "$TMP"/fidoiptmp
uplinkftnaddress1=$(cat "$TMP"/fidoiptmp)


echo "Enter uplink server name or IP-address and press [ENTER]."
echo -n "Sample -  f828.n5020.z2.binkp.net: "
read uplinkdnsaddress
if [ -z "$uplinkdnsaddress" ]
then
echo 'You input nothing.'
echo 'Please run this script again and input something.'
exit
fi

# Checking user input&scrubbing
ScrubbedCheck6="${uplinkdnsaddress//[^$Alloweddns]/}"
if [ "$uplinkdnsaddress" = "$ScrubbedCheck6" ]; then
echo  ''
else
echo ' '
echo " Error. You entered wrong symbols. Allowed symbols are: "
echo -n ' '
echo -n """$Alloweddns"""
echo -n '               '
echo 'Please run this script again and be more carefull during inputing.'
echo -n '               '
exit
fi


echo "Enter uplink password and press [ENTER]."
echo -n "Sample -  12345678: " 
read uplinkpassword
if [ -z "$uplinkpassword" ]
then
echo 'You input nothing.'
echo 'Please run this script again and input something.'
exit
fi

# Checking user input&scrubbing
ScrubbedCheck7="${uplinkpassword//[^$AllowedPwd]/}"
if [ "$uplinkpassword" = "$ScrubbedCheck7" ]; then
echo  ''
else
echo ' '
echo " Error. You entered wrong symbols. Allowed symbols are: "
echo -n ' '
echo -n ""$AllowedPwd""
echo -n '               '
echo 'Please run this script again and be more carefull during inputing.'
echo -n '               '
exit
fi

echo ""
echo "--------------------------------------------------------------------"
echo ""

echo -n "Your full name is : "
echo "$fullname"
echo -n "Your system station name : "
echo "$stationname"
echo -n "Your FTN address is: "
echo "$ftnaddress"
echo -n "Your location is : "
echo "$locationname"
echo -n "Uplink name is : "
echo "$uplinkname"
echo -n "Uplink FTN address is : "
echo "$uplinkftnaddress"
echo -n "Uplink server name or IP-address is: "
echo "$uplinkdnsaddress"
echo -n "Your password is: "
echo "$uplinkpassword"


echo ""
echo "--------------------------------------------------------------------"
echo ""
# asks if you want to change the original files and acts accordingly.

echo "OK? "
echo "[y/n]"
read reply
echo ""  
if [ "$reply" = "y" ];
	then 

if [ -e "$HOMEDIR"/usr/etc/binkd.cfg ]; then
echo '------------------------------------------------------------------------'
echo 'Previos configuration files saved to file:'
echo ''
echo "$CWD"/"$shortname"
echo ''
echo '------------------------------------------------------------------------'
echo ''

tar -cf "$CWD"/"$shortname" "$HOMEDIR"/usr/etc/binkd.cfg "$HOMEDIR"/usr/etc/golded+/g* "$HOMEDIR"/usr/etc/fido/config "$HOMEDIR"/usr/bin/recv "$HOMEDIR"/usr/bin/send > /dev/null 2>&1
sleep 3 
fi

cp -p "$CWD"/binkd/binkd.cfg "$HOMEDIR"/usr/etc/
cp -p "$CWD"/husky/config  "$HOMEDIR"/usr/etc/fido/
cp -p  "$CWD"/golded/decode.txt "$HOMEDIR"/usr/etc/golded+/golded.cfg
cp -p  "$CWD"/golded/fidohelp.hlp "$HOMEDIR"/fido/
cp -p "$CWD"/binkd/recv "$HOMEDIR"/usr/bin/
cp -p "$CWD"/binkd/send "$HOMEDIR"/usr/bin/
cp -p "$CWD"/binkd/fidomail "$HOMEDIR"/usr/bin/
cp -p "$CWD"/node/fidohelp "$HOMEDIR"/usr/bin/
cp -p "$CWD"/binkd/*.sh "$HOMEDIR"/usr/bin/
cp -p "$CWD"/binkd/*.pl "$HOMEDIR"/usr/bin/
cp -p "$CWD"/husky/*.pl "$HOMEDIR"/usr/bin/
cp -p "$CWD"/husky/*.sh "$HOMEDIR"/usr/bin/
rm -f "$HOMEDIR"/usr/bin/build.sh

$SEDT -i "s/Vasiliy\ Pampasov"/"$fullname1""/g" "$HOMEDIR"/usr/etc/fido/config
$SEDT -i "s/Moscow"/"$locationname4""/" "$HOMEDIR"/usr/etc/fido/config
$SEDT -i "s/Vasiliy\ Pampasov"/"$fullname1""/" "$HOMEDIR"/usr/etc/golded+/golded.cfg
$SEDT -i "s/Falcon"/"$stationname1""/" "$HOMEDIR"/usr/etc/binkd.cfg
$SEDT -i "s/Moscow"/"$locationname1""/" "$HOMEDIR"/usr/etc/binkd.cfg
$SEDT -i "s/$locationname1"/"$locationname2""/" "$HOMEDIR"/usr/etc/binkd.cfg
$SEDT -i "s/2:5020\/828.555"/"$ftnaddress1""/" "$HOMEDIR"/usr/etc/binkd.cfg
$SEDT -i "s/2:5020\/828.555"/"$ftnaddress1""/g" "$HOMEDIR"/usr/etc/fido/config
$SEDT -i "s/2:5020\/828.555"/"$ftnaddress1""/" "$HOMEDIR"/usr/etc/golded+/golded.cfg
$SEDT -i "2s|ZONE-NUMBER|""$zonenumber""|" "$HOMEDIR"/usr/etc/binkd.cfg
$SEDT -i "s|INSTALLDIR|$HOMEDIR|g" "$HOMEDIR"/usr/etc/binkd.cfg
$SEDT -i "s|INSTALLDIR|$HOMEDIR|g" "$HOMEDIR"/usr/etc/fido/config
$SEDT -i "s|INSTALLDIR|$HOMEDIR|g" "$HOMEDIR"/usr/etc/golded+/golded.cfg
$SEDT -i "s|INSTALLDIR|$HOMEDIR|g" "$HOMEDIR"/usr/bin/recv
$SEDT -i "s|INSTALLDIR|$HOMEDIR|g" "$HOMEDIR"/usr/bin/send
$SEDT -i "s|INSTALLDIR|$HOMEDIR|g" "$HOMEDIR"/usr/bin/fidomail
$SEDT -i "s|INSTALLDIR|$HOMEDIR|g" "$HOMEDIR"/usr/bin/fidohelp
$SEDT -i "s|INSTALLDIR|$HOMEDIR|g" "$HOMEDIR"/usr/bin/*.sh
$SEDT -i "s|INSTALLDIR|$HOMEDIR|g" "$HOMEDIR"/usr/bin/*.pl

$SEDT -i "s/828\.local"/"$nodeaddress"\.local"/g" "$HOMEDIR"/usr/etc/golded+/golded.cfg
$SEDT -i "s/Kirill\ Temnenkov"/"$uplinkname1""/" "$HOMEDIR"/usr/etc/fido/config
$SEDT -i "s/Kirill_Temnenkov"/"$fullname2""/" "$HOMEDIR"/usr/etc/binkd.cfg


$SEDT -i "s/2:5020\/828"/"$uplinkftnaddress1""/" "$HOMEDIR"/usr/etc/binkd.cfg
$SEDT -i "s/2:5020\/828"/"$uplinkftnaddress1""/" "$HOMEDIR"/usr/etc/fido/config
$SEDT -i "s/2:5020\/828"/"$uplinkftnaddress1""/" "$HOMEDIR"/usr/etc/golded+/golded.cfg


$SEDT -i "s/2:5020\/828"/"$uplinkftnaddress1""/" "$HOMEDIR"/usr/bin/recv
$SEDT -i "s/2:5020\/828"/"$uplinkftnaddress1""/" "$HOMEDIR"/usr/bin/send

$SEDT -i "s/f828.n5020.z2.binkp.net"/"$uplinkdnsaddress""/" "$HOMEDIR"/usr/etc/binkd.cfg

$SEDT -i "s/12345678"/"$uplinkpassword""/" "$HOMEDIR"/usr/etc/binkd.cfg

$SEDT -i "s/12345678"/"$uplinkpassword""/g" "$HOMEDIR"/usr/etc/golded+/golded.cfg

$SEDT -i "s/12345678"/"$uplinkpassword""/" "$HOMEDIR"/usr/etc/fido/config

$SEDT -i "s/828\.local"/"$nodeaddress"\.local"/" "$HOMEDIR"/usr/etc/fido/config

cp "$CWD"/node/toss "$HOMEDIR"/usr/bin/toss 
$SEDT -i "s|INSTALLDIR|$HOMEDIR|g" "$HOMEDIR"/usr/bin/toss

cat "$CWD"/golded/.screenrc  | sed "s|INSTALLDIR|$HOMEDIR|g" > "$HOMEDIR"/usr/etc/golded+/.screenrc
cat "$CWD"/golded/ge | sed "s|INSTALLDIR|$HOMEDIR|g" > "$HOMEDIR"/usr/bin/ge
cat "$CWD"/golded/g | sed "s|INSTALLDIR|$HOMEDIR|g" > "$HOMEDIR"/usr/bin/g
cat "$CWD"/golded/gl | sed "s|INSTALLDIR|$HOMEDIR|g" > "$HOMEDIR"/usr/bin/gl
cat "$CWD"/golded/nodelist.sh | sed "s|INSTALLDIR|$HOMEDIR|g" > "$HOMEDIR"/usr/bin/nodelist.sh

cp "$HOMEDIR"/usr/bin/send "$HOMEDIR"/usr/bin/rs

cp "$CWD"/husky/checkhpt.sh "$HOMEDIR"/usr/bin/
$SEDT -i "s|INSTALLDIR|$HOMEDIR|g" "$HOMEDIR"/usr/bin/checkhpt.sh

if [ "$OSTYPE" = "Android" ]; then
 $SEDT -i "s|/var/run/|/data/data/com.termux/files/usr/var/run/|" "$HOMEDIR"/usr/etc/binkd.cfg
 $SEDT -i "s|/var/run/|/data/data/com.termux/files/usr/var/run/|" "$HOMEDIR"/usr/etc/fidoip/binkd.cfg.template
else
 sed -i "s|/var/run/|$HOMEDIR/fido/|" "$HOMEDIR"/usr/etc/binkd.cfg
 sed -i "s|/var/run/|$HOMEDIR/fido/|" "$HOMEDIR"/usr/etc/fidoip/binkd.cfg.template
fi

rm -f "$HOMEDIR"/usr/bin/binkdsrv

echo
echo  "=================================================="
echo "Setting permissions...    "
echo  "=================================================="
echo

set +e

if [ -e "$HOMEDIR"/fido ]; then
chmod -R 755 "$HOMEDIR"/fido
fi

if [ "$HOMEDIR" = "/" ]; then
echo
else
if [ -e "$HOMEDIR"/usr ]; then
chmod -R 755 "$HOMEDIR"/usr
fi
fi


chmod 644 "$HOMEDIR"/fido/*.log
chmod 644 "$HOMEDIR"/fido/*.hlp
chmod 644 "$HOMEDIR"/fido/nodelist/nodelist.txt
chmod 644 "$HOMEDIR"/fido/nodelist/*.g*
chmod 644 "$HOMEDIR"/usr/etc/*.cfg
chmod 644 "$HOMEDIR"/usr/etc/*.conf-dist
chmod 644 "$HOMEDIR"/usr/etc/fido/config
chmod 644 "$HOMEDIR"/usr/etc/fido/*.cfg
chmod 644 "$HOMEDIR"/usr/etc/fidoip/*.eng
chmod 644 "$HOMEDIR"/usr/etc/fidoip/*.tpl
chmod 644 "$HOMEDIR"/usr/etc/fidoip/*.template
chmod 644 "$HOMEDIR"/usr/etc/golded+/.screenrc
chmod 644 "$HOMEDIR"/usr/etc/golded+/*.txt
chmod 644 "$HOMEDIR"/usr/etc/golded+/*.cc
chmod 644 "$HOMEDIR"/usr/etc/golded+/*.bat
chmod 644 "$HOMEDIR"/usr/etc/golded+/*.cfg
chmod 644 "$HOMEDIR"/usr/etc/golded+/*.cfm
chmod 644 "$HOMEDIR"/usr/etc/golded+/*.tpl
chmod 644 "$HOMEDIR"/usr/etc/golded+/*.sh
chmod 644 "$HOMEDIR"/usr/etc/golded+/Makefile
chmod 644 "$HOMEDIR"/usr/etc/golded+/golded
chmod 644 "$HOMEDIR"/usr/etc/golded+/map/*
chmod 644 "$HOMEDIR"/usr/etc/golded+/cfgs/File_id.diz
chmod 644 "$HOMEDIR"/usr/etc/golded+/cfgs/*/*
chmod 644 "$HOMEDIR"/usr/include/*/*.h
chmod 644 "$HOMEDIR"/usr/lib/*.a
chmod 644 "$HOMEDIR"/usr/share/doc/fidoconf/*.html
chmod 644 "$HOMEDIR"/usr/share/info/*.info
chmod 644 "$HOMEDIR"/usr/share/man/man1/*.1

set -e

#echo "Generating welcome message"
echo
$SEDT "s|Vasiliy\ Pampasov|$fullname|" "$CWD"/golded/welcome.tpl.template > "$TMP"/welcome.tpl.template
$SEDT -i "s|2:5020\/XXX|$uplinkftnaddress1|" "$TMP"/welcome.tpl.template
$SEDT -i "s|Kirill\ Temnenkov|$uplinkname1|" "$TMP"/welcome.tpl.template
$SEDT -i "s|2:5020\/YYY.ZZZ|$ftnaddress1|" "$TMP"/welcome.tpl.template
$SEDT -i "s|INSTALLDIR|$HOMEDIR|" "$TMP"/welcome.tpl.template
export FIDOCONFIG=$HOMEDIR/usr/etc/fido/config


#������ Mail without INTL-Kludge. Assuming 2:5020/828.0 -> 2:0/0.0
#$HOMEDIR/usr/bin/txt2pkt -c $HOMEDIR/usr/etc/fido/config -nf "Developer of fidoip"  -xf "$ftnaddress"  -xt "$ftnaddress" -nt "$fullname" -t "Powered by fidoip package" -o "http://sourceforge.net/apps/mediawiki/fidoip" -s "Welcome, new point!" -e "welcome.fido" -d $HOMEDIR/fido/localinb /tmp/welcome.tpl

"$HOMEDIR"/usr/bin/toss

echo
echo  "========================================================"
echo "Setting up nodelist in GoldED+: "
echo  "========================================================"

"$HOMEDIR"/usr/bin/nodelist.sh

echo
echo "========================================================"
echo "OK. Original configuration files modified successfully."
echo "Please review configuration files."  
sleep 1
"$HOMEDIR"/usr/bin/fidohelp
echo " Please add to variable PATH=""$PATH"" this raw:"
echo """$HOMEDIR""/usr/bin or use this command:"
echo "export PATH=\$PATH:""$HOMEDIR""/usr/bin"
echo "Then put the line PATH=\$PATH:""$HOMEDIR""/usr/bin in ~/.profile,"  
echo "or in ~/.bash_profile and start GoldEd with ge, g or gl command."  
echo "========================================================"


if [ -e "$TMP" ]; then
	rm -rf "$TMP"
fi


elif [ "$reply" = "n" ];
	then 
echo "Please modify configuration files manually or run this script again."
if [ -e "$TMP" ]; then
	rm -rf "$TMP"
fi
fi

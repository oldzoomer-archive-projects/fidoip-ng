#!/bin/bash
#   Copyright  (c) by Maxim Sokolsky (2:5020/828.777). This file is part of fidoip. It is free software and it is covered
#   by the GNU general public license. See the file LICENSE for details. */
# Script for creation FIDONet IP node configuration

# Usage:  bash ./setup_node.bash
# Bash only!!! Do not use sh interpretator
CWD=$(pwd)
HOMEDIR=$(cd ../; pwd) #  Fidoip installation directory 
TMP=$(mktemp -d)	# Location of temp's files
SYSOS=$(uname -s) # Packages architecture
MACHINE=$(uname -m)
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

cd "$CWD"

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
    rm -rf "$TMP"
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
    rm -rf "$TMP"
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
    rm -rf "$TMP"
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
    rm -rf "$TMP"
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
rm -rf "$TMP"
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
declare -r AllowedPwd="1234567890-abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"

echo "--------------------------------------------------------------------"
echo ""
echo "This script setup fidoip's configuration files for FIDONet node."
echo ""
echo "--------------------------------------------------------------------"
echo ""


echo "Enter your first and last name(sysop of this node) and press [ENTER]."
echo -n "Sample -  Vasiliy Pampasov: "
read fullname

if [ -z "$fullname" ]
then
echo 'You input nothing.'
echo 'Please run this script again and input something.'
rm -rf "$TMP"
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
echo  "$fullname" | $SEDT 's/ /\\ /g' > "$TMP"/fidoiptmp
fullname1=$(cat "$TMP"/fidoiptmp)

# Inserting _ instead of space

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

# Changing spaces to -
echo  "$locationname" | $SEDT 's/\ /-/g' > "$TMP"/fidoiptmp
locationname3=$(cat "$TMP"/fidoiptmp)

# Changing , to -
echo  "$locationname3" | $SEDT 's/\,/-/g' > "$TMP"/fidoiptmp
locationname4=$(cat "$TMP"/fidoiptmp)


echo "Enter your FTN node address and press [ENTER]."
echo -n "Sample -  2:5020/788: "
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


# Checking user input&scrubbing
ScrubbedCheck3="${ftnaddress//[^$AllowedFtnNumbers]/}"
if [ "$ftnaddress" = "$ScrubbedCheck3" ]; then
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


# Inserting \ before /
echo  "$ftnaddress" | $SEDT 's|/|\\/|g' > "$TMP"/fidoiptmp
ftnaddress1=$(cat "$TMP"/fidoiptmp)


echo "Enter your station DNS name or IP-address and press [ENTER]."
echo -n "Sample - 192.168.4.7: "
read mydnsaddress
if [ -z "$mydnsaddress" ]
then
echo 'You input nothing.'
echo 'Please run this script again and input something.'
exit
fi

# Checking user input&scrubbing
ScrubbedCheck622="${mydnsaddress//[^$Alloweddns]/}"
if [ "$mydnsaddress" = "$ScrubbedCheck622" ]; then
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

echo "Sysop has second account for access from other PC by network"
echo "This account has .1 point number."
echo "Enter your 1-st POINT password and press [ENTER]."
echo "(not bigger then 8 symbols)"
echo -n "Sample -  12345678: " 
read point1password
if [ -z "$point1password" ]
then
echo 'You input nothing.'
echo 'Please run this script again and input something.'
exit
fi

# Checking user input&scrubbing
ScrubbedCheck31="${point1password//[^$AllowedPwd]/}"
if [ "$point1password" = "$ScrubbedCheck31" ]; then
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


echo -e "Enter your main UPLINK full name and press press [ENTER]."
echo -n "Sample -  Ivan Papuasov: "
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

echo -e "Enter your UPLINK FTN address and press [ENTER]."
echo -n "Sample -  2:5020/777: "
read uplinkftnaddress
if [ -z "$uplinkftnaddress" ]
then
echo 'You input nothing.'
echo 'Please run this script again and input something.'
exit
fi

CHECKFTN2=$(echo "$uplinkftnaddress" | grep "\\/" )
if [ -z "$CHECKFTN2" ]
then
echo 'No symbol / in FTN number.'
echo "Try to input next try. Exiting."
rm -rf "$TMP"
exit
fi

CHECKFTN3=$(echo "$uplinkftnaddress" | grep ":" )
if [ -z "$CHECKFTN3" ]
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

if [ "$uplinkftnaddress" = "$ftnaddress" ]; then
echo " Error. You entered UPLINK FTN address the same as you node FTN address."
echo 'Please run this script again and be more carefull during inputing.'
exit
else
echo
fi

# Inserting \ before space
echo  "$uplinkftnaddress" | $SEDT 's|/|\\/|g' > "$TMP"/fidoiptmp
uplinkftnaddress1=$(cat "$TMP"/fidoiptmp)

echo "Enter UPLINK DNS name or IP-address and press [ENTER]."
echo -n "Sample - papuasov.dyndns.org: "
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


echo "Enter your UPLINK password and press [ENTER]."
echo "(not bigger then 8 symbols)"
echo -n "Sample -  09876543: " 
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

if [ "$uplinkpassword" = "$point1password" ]; then
echo " Error. You entered UPLINK FTN password the same as you node 1-st point password."
echo 'Please run this script again and be more carefull during inputing.'
exit
else
echo
fi

echo ""
echo "--------------------------------------------------------------------"
echo ""

echo -n "Your full name is : "
echo "$fullname"
echo -n "Your system station name : "
echo "$stationname"
echo -n "Your FTN node address is: "
echo "$ftnaddress"
echo -n "Your location is : "
echo "$locationname"
echo -n "Your 1-st POINT password is : "
echo "$point1password"
echo -n "Your station DNS name or IP-address is : "
echo "$mydnsaddress"
echo 
echo -n "UPLINK name is : "
echo "$uplinkname"
echo -n "UPLINK FTN address is : "
echo "$uplinkftnaddress"
echo -n "UPLINK DNS name or IP-address is: "
echo "$uplinkdnsaddress"
echo -n "UPLINK password is: "
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

rm -f "$HOMEDIR"/usr/bin/recv
rm -f "$HOMEDIR"/usr/bin/rs
rm -f "$HOMEDIR"/usr/bin/send
rm -f "$HOMEDIR"/usr/etc/fido/routing.lst
rm -f "$HOMEDIR"/usr/etc/fido/link.lst
rm -f "$HOMEDIR"/usr/etc/fido/point.lst
rm -f "$HOMEDIR"/usr/etc/fido/readonly.lst
rm -f "$HOMEDIR"/usr/etc/fido/routing.lst
rm -f  "$HOMEDIR"/usr/etc/golded+/golded.cfg
rm -f "$HOMEDIR"/usr/etc/rc.d/binkd.service
rm -f "$HOMEDIR"/usr/etc/rc.d/binkdsrv
rm -f "$HOMEDIR"/usr/etc/rc.d/bnkd.srv
rm -f  "$HOMEDIR"/usr/etc/golded+/golded.cfg
rm -rf  "$HOMEDIR"/usr/etc/fidoip/node

mkdir -p "$HOMEDIR"/usr/etc/fidoip/node
mkdir -p "$HOMEDIR"/usr/etc/rc.d
cp -R "$CWD"/node/* "$HOMEDIR"/usr/etc/fidoip/node
$SEDT -i "s|INSTALLDIR|""$HOMEDIR""|g" "$HOMEDIR"/usr/etc/fidoip/node/*

cp -p "$HOMEDIR"/usr/etc/fidoip/node/binkd.cfg.template-node "$HOMEDIR"/usr/etc/binkd.cfg
cp -p "$HOMEDIR"/usr/etc/fidoip/node/config.template-node  "$HOMEDIR"/usr/etc/fido/config
cp -p "$HOMEDIR"/usr/etc/fidoip/node/link.lst.template-node  "$HOMEDIR"/usr/etc/fido/link.lst
cp -p "$HOMEDIR"/usr/etc/fidoip/node/route-default.lst.template-node  "$HOMEDIR"/usr/etc/fido/route-default.lst
cp -p "$HOMEDIR"/usr/etc/fidoip/node/areas.lst.template-node "$HOMEDIR"/usr/etc/fido/areas.lst
cp -p "$HOMEDIR"/usr/etc/fidoip/node/fareas.lst.template-node "$HOMEDIR"/usr/etc/fido/fareas.lst
cp -p "$HOMEDIR"/usr/etc/fidoip/node/decode.txt.template-node "$HOMEDIR"/usr/etc/golded+/golded.cfg
cp -p "$HOMEDIR"/usr/etc/fidoip/node/rs.template-node "$HOMEDIR"/usr/bin/rs
cp -p "$HOMEDIR"/usr/etc/fidoip/node/rs.template-node "$HOMEDIR"/usr/bin/send
cp -p "$HOMEDIR"/usr/etc/fidoip/node/recv.template-node "$HOMEDIR"/usr/bin/recv
cp -p "$HOMEDIR"/usr/etc/fidoip/node/poll.template-node "$HOMEDIR"/usr/bin/poll
cp -p "$HOMEDIR"/usr/etc/fidoip/node/toss "$HOMEDIR"/usr/bin/toss
cp -p "$HOMEDIR"/usr/etc/fidoip/node/readonly.lst.template-node "$HOMEDIR"/usr/etc/fido/readonly.lst
cp -p "$HOMEDIR"/usr/etc/fidoip/node/macro.cfg.template-node "$HOMEDIR"/usr/etc/golded+/macro.cfg
cp -p "$HOMEDIR"/usr/etc/fidoip/node/route-points.lst.template-node  "$HOMEDIR"/usr/etc/fido/route-points.lst

touch "$HOMEDIR"/usr/etc/fido/routing.lst
touch "$HOMEDIR"/usr/etc/fido/point.lst
cp "$HOMEDIR"/usr/etc/fidoip/node/areafix.template-node "$HOMEDIR"/fido/areafix.hlp
cp "$HOMEDIR"/usr/etc/fidoip/node/filefix.template-node "$HOMEDIR"/fido/filefix.hlp
cp -p "$HOMEDIR"/usr/etc/fidoip/node/rules2.txt "$HOMEDIR"/fido/rules2.txt
cp -p "$HOMEDIR"/usr/etc/fidoip/node/rules1.txt "$HOMEDIR"/fido/rules1.txt
cp -p "$HOMEDIR"/usr/etc/fidoip/node/rules.txt "$HOMEDIR"/fido/rules.txt
cp -p "$HOMEDIR"/usr/etc/fidoip/node/fidohelp.hlp  "$HOMEDIR"/fido/
cp -p "$HOMEDIR"/usr/etc/fidoip/node/fidohelp "$HOMEDIR"/usr/bin/

cp "$HOMEDIR"/usr/etc/fidoip/node/listpoint "$HOMEDIR"/usr/bin/
cp "$HOMEDIR"/usr/etc/fidoip/node/viewpoint "$HOMEDIR"/usr/bin/
cp "$HOMEDIR"/usr/etc/fidoip/node/addpoint "$HOMEDIR"/usr/bin/
cp "$HOMEDIR"/usr/etc/fidoip/node/removepoint "$HOMEDIR"/usr/bin/
cp "$HOMEDIR"/usr/etc/fidoip/node/addlink "$HOMEDIR"/usr/bin/
cp "$HOMEDIR"/usr/etc/fidoip/node/removelink "$HOMEDIR"/usr/bin/
cp "$HOMEDIR"/usr/etc/fidoip/node/addread "$HOMEDIR"/usr/bin/
cp "$HOMEDIR"/usr/etc/fidoip/node/removeread "$HOMEDIR"/usr/bin/
cp "$HOMEDIR"/usr/etc/fidoip/node/fpasswd "$HOMEDIR"/usr/bin/
cp "$HOMEDIR"/usr/etc/fidoip/node/binkdsrv "$HOMEDIR"/usr/etc/rc.d/
cp "$HOMEDIR"/usr/etc/fidoip/node/bnkd.srv "$HOMEDIR"/usr/etc/rc.d/
cp "$HOMEDIR"/usr/etc/fidoip/node/binkd.service "$HOMEDIR"/usr/etc/rc.d/
cp "$HOMEDIR"/usr/etc/fidoip/node/changeuplink "$HOMEDIR"/usr/bin/
cp "$HOMEDIR"/usr/etc/fidoip/node/listlink "$HOMEDIR"/usr/bin/
cp "$HOMEDIR"/usr/etc/fidoip/node/listecho "$HOMEDIR"/usr/bin/
cp "$HOMEDIR"/usr/etc/fidoip/node/listread "$HOMEDIR"/usr/bin/
cp "$HOMEDIR"/usr/etc/fidoip/node/fido.* "$HOMEDIR"/usr/bin/
cp "$HOMEDIR"/usr/etc/fidoip/node/month* "$HOMEDIR"/usr/bin/
cp "$HOMEDIR"/usr/etc/fidoip/node/clean_outb "$HOMEDIR"/usr/bin/
cp "$HOMEDIR"/usr/etc/fidoip/node/*.pl "$HOMEDIR"/usr/bin/


SHORTNODENAME=$(echo "$ftnaddress" | $SEDT 's|.*:||g' | $SEDT 's|/|-|g')
ZONE=$(echo "$ftnaddress" | $SEDT 's|:.*||g' )

SHORTNAMEUPLINK=$(echo "$uplinkftnaddress" | $SEDT 's|.*:||g' | $SEDT 's|/|-|g')

$SEDT -i "s/MYNODE-ADDRESS/""$ftnaddress1""/g" "$HOMEDIR"/usr/etc/binkd.cfg
$SEDT -i "s/MYNODE-ADDRESS/""$ftnaddress1""/g" "$HOMEDIR"/usr/etc/binkd.cfg
$SEDT -i "s/MYNODE-ADDRESS/""$ftnaddress1""/g" "$HOMEDIR"/usr/etc/fido/config
$SEDT -i "s/MYNODE-ADDRESS/""$ftnaddress1""/g" "$HOMEDIR"/usr/etc/fido/link.lst
$SEDT -i "s/MYNODE-ADDRESS/""$ftnaddress1""/g" "$HOMEDIR"/usr/etc/fido/route-default.lst
$SEDT -i "s/MYNODE-ADDRESS/""$ftnaddress1""/g" "$HOMEDIR"/usr/etc/fido/areas.lst

$SEDT -i "s/POINT-NUMBER/1/g" "$HOMEDIR"/usr/etc/fido/route-points.lst

$SEDT -i "s/MYNODE-ADDRESS/""$ftnaddress1""/g" "$HOMEDIR"/usr/etc/golded+/golded.cfg
$SEDT -i "s/MYNODE-ADDRESS/""$ftnaddress1""/g" "$HOMEDIR"/usr/etc/fido/readonly.lst
$SEDT -i "s/MYNODE-ADDRESS/""$ftnaddress1""/g" "$HOMEDIR"/usr/etc/golded+/golded.cfg
$SEDT -i "s/MYNODE-ADDRESS/""$ftnaddress1""/g" "$HOMEDIR"/fido/areafix.hlp
$SEDT -i "s/MYNODE-ADDRESS/""$ftnaddress1""/g" "$HOMEDIR"/fido/filefix.hlp

$SEDT -i "s|SYSTEM-NAME|""$stationname1""|g" "$HOMEDIR"/usr/etc/binkd.cfg
$SEDT -i "s|SYSTEM-NAME|""$stationname1""|g" "$HOMEDIR"/usr/etc/fido/config
$SEDT -i "s|SYSTEM-NAME|""$stationname1""|g" "$HOMEDIR"/fido/areafix.hlp
$SEDT -i "s|SYSTEM-NAME|""$stationname1""|g" "$HOMEDIR"/fido/filefix.hlp

$SEDT -i "s/MYHOST-DOMAIN-NAME/""$mydnsaddress""/g" "$HOMEDIR"/usr/etc/binkd.cfg

$SEDT -i "s/SHORTNODE-NAME/""$SHORTNODENAME""/g" "$HOMEDIR"/usr/etc/fido/config

$SEDT -i "s/ZONE-NUMBER/""$ZONE""/g" "$HOMEDIR"/usr/etc/binkd.cfg

$SEDT -i "s/LOCATION-TOWN/""$locationname4""/g" "$HOMEDIR"/usr/etc/fido/config
$SEDT -i "s/LOCATION-TOWN/""$locationname4""/g" "$HOMEDIR"/usr/etc/binkd.cfg

$SEDT -i "s/SYSTEM-OPERATOR-NAME/""$fullname2""/g" "$HOMEDIR"/usr/etc/binkd.cfg
$SEDT -i "s/SYSTEM-OPERATOR-NAME/$fullname1/g" "$HOMEDIR"/usr/etc/fido/config
$SEDT -i "s/SYSTEM-OPERATOR-NAME/$fullname1/g" "$HOMEDIR"/usr/etc/fido/link.lst
$SEDT -i "s/SYSTEM-OPERATOR-NAME/$fullname1/g" "$HOMEDIR"/usr/etc/golded+/golded.cfg
$SEDT -i "s/SYSTEM-OPERATOR-NAME/$fullname/g" "$HOMEDIR"/fido/areafix.hlp
$SEDT -i "s/SYSTEM-OPERATOR-NAME/$fullname/g" "$HOMEDIR"/fido/filefix.hlp

$SEDT -i -e '/NODELIST/!b' -e 's/net5020.ndl/nodelist.txt/g' "$HOMEDIR"/usr/etc/golded+/golded.cfg
$SEDT -i -e '/NODELIST/!b' -e "/pnt5020.ndl/d" "$HOMEDIR"/usr/etc/golded+/golded.cfg

$SEDT -i -e '/UseSoftCRxlat/!b' -e 's/Yes/No/g' "$HOMEDIR"/usr/etc/golded+/golded.cfg
$SEDT -i -e '/DispSoftCr/!b' -e "s/Yes/No/g" "$HOMEDIR"/usr/etc/golded+/golded.cfg

$SEDT -i "s/MYPOINT-PASSWORD/""$point1password""/g" "$HOMEDIR"/usr/etc/binkd.cfg
$SEDT -i "s/MYPOINT-PASSWORD/""$point1password""/g" "$HOMEDIR"/usr/etc/fido/link.lst

$SEDT -i "s/FIRSTLINK-NODE-NAME/$uplinkname1/g" "$HOMEDIR"/usr/etc/fido/config
$SEDT -i "s/FIRSTLINK-NODE-NAME/$uplinkname1/g" "$HOMEDIR"/usr/etc/fido/link.lst
$SEDT -i "s/FIRSTLINK-NODE-NAME/$uplinkname1/g" "$HOMEDIR"/usr/etc/fido/route-default.lst

$SEDT -i "s/FIRSTLINK-NODE-ADDRESS/""$uplinkftnaddress1""/g"  "$HOMEDIR"/usr/etc/binkd.cfg
$SEDT -i "s/FIRSTLINK-NODE-ADDRESS/""$uplinkftnaddress1""/g" "$HOMEDIR"/usr/etc/fido/config
$SEDT -i "s/FIRSTLINK-NODE-ADDRESS/""$uplinkftnaddress1""/g" "$HOMEDIR"/usr/etc/fido/link.lst
$SEDT -i "s/FIRSTLINK-NODE-ADDRESS/""$uplinkftnaddress1""/g" "$HOMEDIR"/usr/etc/fido/route-default.lst

$SEDT -i "s/FIRSTLINK-HOST-DOMAIN-NAME/""$uplinkdnsaddress""/g" "$HOMEDIR"/usr/etc/binkd.cfg

$SEDT -i "s/FIRSTLINK-NODE-PASSWORD/""$uplinkpassword""/g" "$HOMEDIR"/usr/etc/binkd.cfg
$SEDT -i "s/FIRSTLINK-NODE-PASSWORD/""$uplinkpassword""/g" "$HOMEDIR"/usr/etc/fido/link.lst

$SEDT -i "s/SHORTNODE-NAME/""$SHORTNAMEUPLINK""/g" "$HOMEDIR"/usr/etc/golded+/macro.cfg
$SEDT -i "s/LINK-NODE-PASSWORD/""$uplinkpassword""/g" "$HOMEDIR"/usr/etc/golded+/macro.cfg
$SEDT -i "s/LINK-NODE-ADDRESS/""$uplinkftnaddress1""/g" "$HOMEDIR"/usr/etc/golded+/macro.cfg
$SEDT -i "s/LINK-NODE-ADDRESS/""$uplinkftnaddress1""/g" "$HOMEDIR"/usr/etc/fido/fareas.lst
$SEDT -i "s/LINK-NODE-ADDRESS/""$uplinkftnaddress1""/g" "$HOMEDIR"/usr/bin/poll

cp "$CWD"/golded/.screenrc "$HOMEDIR"/usr/etc/golded+/
$SEDT -i "s|INSTALLDIR|$HOMEDIR|g" "$HOMEDIR"/usr/etc/golded+/.screenrc

cp "$CWD"/husky/checkhpt.sh "$HOMEDIR"/usr/bin/
$SEDT -i "s|INSTALLDIR|$HOMEDIR|g" "$HOMEDIR"/usr/bin/checkhpt.sh

pointname=$(echo "$fullname" | $SEDT "s| .*||g")

cp "$HOMEDIR"/usr/etc/fidoip/node/welcome2.template-node "$TMP"/welcome2.template-node
cp "$HOMEDIR"/usr/etc/fidoip/node/announce1.template-node "$TMP"/announce1.template-node
cp "$HOMEDIR"/usr/etc/fidoip/node/announce.template-node "$TMP"/announce.template-node

$SEDT -i "s|POINT-NAME|$pointname|g" "$TMP"/welcome2.template-node
$SEDT -i "s|MYNODE-ADDRESS|$ftnaddress1|g" "$TMP"/welcome2.template-node
$SEDT -i "s|SYSTEM-NAME|""$stationname1""|g" "$TMP"/welcome2.template-node

$SEDT -i "s|POINT-FULL-NAME|$fullname1|g" "$TMP"/announce.template-node
$SEDT -i "s|MYNODE-ADDRESS|$ftnaddress1|g" "$TMP"/announce.template-node
$SEDT -i "s|SYSTEM-NAME|""$stationname1""|g" "$TMP"/announce.template-node
$SEDT -i "s|POINT-NUMBER|1|g" "$TMP"/announce.template-node

$SEDT -i "s|LINK-FULL-NAME|$uplinkname1|g" "$TMP"/announce1.template-node
$SEDT -i "s|LINK-ADDRESS|$uplinkftnaddress1|g" "$TMP"/announce1.template-node
$SEDT -i "s|MYNODE-ADDRESS|$ftnaddress1|g" "$TMP"/announce1.template-node
$SEDT -i "s|SYSTEM-NAME|""$stationname1""|g" "$TMP"/announce1.template-node

$SEDT -i "s|SYSTEM-NAME|""$stationname1""|g" "$HOMEDIR"/fido/rules2.txt
$SEDT -i "s|MYNODE-ADDRESS|$ftnaddress1|g" "$HOMEDIR"/fido/rules2.txt
$SEDT -i "s/SHORTNODE-NAME/""$SHORTNODENAME""/g" "$HOMEDIR"/fido/rules2.txt
$SEDT -i "s/SYSTEM-OPERATOR-NAME/$fullname/g" "$HOMEDIR"/fido/rules2.txt
$SEDT -i "s|SYSTEM-NAME|""$stationname1""|g" "$HOMEDIR"/fido/rules1.txt
$SEDT -i "s|MYNODE-ADDRESS|$ftnaddress1|g" "$HOMEDIR"/fido/rules1.txt
$SEDT -i "s/SHORTNODE-NAME/""$SHORTNODENAME""/g" "$HOMEDIR"/fido/rules1.txt
$SEDT -i "s/SYSTEM-OPERATOR-NAME/$fullname/g" "$HOMEDIR"/fido/rules1.txt
$SEDT -i "s|SYSTEM-NAME|""$stationname1""|g" "$HOMEDIR"/fido/rules.txt
$SEDT -i "s|MYNODE-ADDRESS|$ftnaddress1|g" "$HOMEDIR"/fido/rules.txt
$SEDT -i "s/SHORTNODE-NAME/""$SHORTNODENAME""/g" "$HOMEDIR"/fido/rules.txt
$SEDT -i "s/SYSTEM-OPERATOR-NAME/$fullname/g" "$HOMEDIR"/fido/rules.txt

echo
echo  "=================================================="
echo "Setting up permissions...    "
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

set +e
chmod 644 "$HOMEDIR"/fido/*.log
chmod 644 "$HOMEDIR"/fido/*.txt
chmod 644 "$HOMEDIR"/fido/*.hlp
chmod 644 "$HOMEDIR"/fido/nodelist/nodelist.txt
chmod 644 "$HOMEDIR"/fido/nodelist/*.g*
chmod 644 "$HOMEDIR"/usr/etc/*.cfg
chmod 644 "$HOMEDIR"/usr/etc/*.conf-dist
chmod 644 "$HOMEDIR"/usr/etc/fido/config
chmod 644 "$HOMEDIR"/usr/etc/fido/*.cfg
chmod 644 "$HOMEDIR"/usr/etc/fido/*.lst
chmod 644 "$HOMEDIR"/usr/etc/fidoip/*.eng
chmod 644 "$HOMEDIR"/usr/etc/fidoip/*.tpl
chmod 644 "$HOMEDIR"/usr/etc/fidoip/*.template
chmod 644 "$HOMEDIR"/usr/etc/fidoip/node/*.template-node
chmod 644 "$HOMEDIR"/usr/etc/fidoip/node/*.template
chmod 644 "$HOMEDIR"/usr/etc/fidoip/node/*.template-node-eng
chmod 644 "$HOMEDIR"/usr/etc/fidoip/node/*.txt
chmod 644 "$HOMEDIR"/usr/etc/fidoip/node/*.service
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
chmod 644 "$HOMEDIR"/usr/etc/rc.d/binkd.service
chmod 644 "$HOMEDIR"/usr/include/*/*.h
chmod 644 "$HOMEDIR"/usr/lib/*.a
chmod 644 "$HOMEDIR"/usr/share/doc/fidoconf/*.html
chmod 644 "$HOMEDIR"/usr/share/info/*.info
chmod 644 "$HOMEDIR"/usr/share/man/man1/*.1

set -e

echo  "=================================================="
echo "Generating welcome and announce messages..."
echo  "=================================================="
export FIDOCONFIG=$HOMEDIR/usr/etc/fido/config
"$HOMEDIR"/usr/bin/txt2pkt -nf "Developer of fidoip"  -xf "$ftnaddress"  -xt "$ftnaddress" -nt "$fullname" -t "Powered by automatic fidoip NMS(Node Management System)" -o "https://sf.net/projects/fidoip" -s "Welcome to new node, sysop!" -e """$SHORTNODENAME"".local" -d "$HOMEDIR"/fido/localinb "$TMP"/welcome2.template-node
"$HOMEDIR"/usr/bin/txt2pkt -nf "Dumb-robot" -xf "$ftnaddress".1  -xt "$ftnaddress"  -t "Powered by automatic fidoip NMS(Node Management System)" -o "https://sf.net/projects/fidoip" -s "Uplink ""$uplinkftnaddress"" is created " -e """$SHORTNODENAME"".official" -d "$HOMEDIR"/fido/localinb "$TMP"/announce1.template-node
"$HOMEDIR"/usr/bin/txt2pkt -nf "Dumb-robot" -xf "$ftnaddress".1  -xt "$ftnaddress"  -t "Powered by automatic fidoip NMS(Node Management System)" -o "https://sf.net/projects/fidoip" -s "System point ""$ftnaddress"".1 is added for sysop" -e """$SHORTNODENAME"".official" -d "$HOMEDIR"/fido/localinb "$TMP"/announce.template-node
"$HOMEDIR"/usr/bin/txt2pkt -nf "Dumb-robot" -xf "$ftnaddress".1  -xt "$ftnaddress"  -t "Powered by automatic fidoip NMS(Node Management System)" -o "https://sf.net/projects/fidoip" -s "Rules of ""$SHORTNODENAME"".test" -e """$SHORTNODENAME"".test" -d "$HOMEDIR"/fido/localinb "$HOMEDIR"/fido/rules2.txt
"$HOMEDIR"/usr/bin/txt2pkt -nf "Dumb-robot" -xf "$ftnaddress".1  -xt "$ftnaddress"  -t "Powered by automatic fidoip NMS(Node Management System)" -o "https://sf.net/projects/fidoip" -s "Rules of ""$SHORTNODENAME"".forwards" -e """$SHORTNODENAME"".forwards" -d "$HOMEDIR"/fido/localinb "$HOMEDIR"/fido/rules1.txt
"$HOMEDIR"/usr/bin/txt2pkt -nf "Dumb-robot" -xf "$ftnaddress".1  -xt "$ftnaddress"  -t "Powered by automatic fidoip NMS(Node Management System)" -o "https://sf.net/projects/fidoip" -s "Rules of ""$SHORTNODENAME"".local" -e """$SHORTNODENAME"".local" -d "$HOMEDIR"/fido/localinb "$HOMEDIR"/fido/rules.txt

"$HOMEDIR"/usr/bin/toss 2> /dev/null

$SEDT -i "s|INSTALLDIR|$HOMEDIR|g" "$HOMEDIR"/usr/etc/rc.d/binkdsrv
$SEDT -i "s|INSTALLDIR|$HOMEDIR|g" "$HOMEDIR"/usr/etc/rc.d/bnkd.srv
$SEDT -i "s|INSTALLDIR|$HOMEDIR|g" "$HOMEDIR"/usr/etc/rc.d/binkd.service

$SEDT -i "s|USER|$IDN|g" "$HOMEDIR"/usr/etc/rc.d/binkd.service
$SEDT -i "s|GROUP|$IDG|g" "$HOMEDIR"/usr/etc/rc.d/binkd.service

echo
echo  "========================================================"
echo "Setting up permissions for start binkd service scripts: "
echo """$HOMEDIR""/usr/etc/rc.d:"
echo  "========================================================"
echo
chmod -R 755 "$HOMEDIR"/usr/etc/rc.d/binkdsrv
chmod -R 755 "$HOMEDIR"/usr/etc/rc.d/bnkd.srv
chmod -R 644 "$HOMEDIR"/usr/etc/rc.d/binkd.service

echo
echo  "========================================================"
echo "Setting up nodelist in GoldED+: "
echo  "========================================================"
echo
"$HOMEDIR"/usr/bin/nodelist.sh

echo "========================================================"
echo "OK. Original configuration files for node modified successfully."
echo "Please review configuration files."  
echo "========================================================"
"$HOMEDIR"/usr/bin/fidohelp
sleep 1
echo "You may run one of these scripts to start BINKD service for testing:"
echo """$HOMEDIR""/usr/etc/rc.d/bnkd.srv for systems with Systemd or"
echo """$HOMEDIR""/usr/etc/rc.d/binkdsrv for other systems."
sleep 1
echo " Please add to variable PATH=""$PATH"" this raw:"
echo """$HOMEDIR""/usr/bin or use this command:"
echo "export PATH=\$PATH:""$HOMEDIR""/usr/bin"
echo "Then put the line PATH=\$PATH:""$HOMEDIR""/usr/bin in ~/.profile,"  
echo "or in ~/.bash_profile and start GoldEd with ge, g or gl command."  
echo "========================================================"
echo

rm -rf "$TMP"

elif [ "$reply" = "n" ];
	then 
echo "Please run this script again."
rm -rf "$TMP"
fi

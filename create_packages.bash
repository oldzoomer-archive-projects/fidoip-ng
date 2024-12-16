#!/bin/sh
#   Copyright (c) by Maxim Sokolsky (2:5020/828.777). This file is part of fidoip. It is free software and it is covered
#   by the GNU general public license. See the file LICENSE for details. */

# Usage:  create_packages.bash
# If you setup connection via proxy uncomment raw GIT_PROXY below:
# GIT_PROXY="http://server:port"
CWD=$(pwd)
OSNAME=$(uname)
CWD=$(pwd)
HOMEDIR=$(cd ../; pwd) #  Fidoip installation directory 
SYSOS=$(uname -s) # Packages architecture
ARCH=$(uname -m)	# Packages architecture
OSTYPE=$(uname -o 2>/dev/null || uname -p) 
BUILD=${BUILD:-fido_my1}	# Build number packages initials 
IDN=$(id -un) #  User's name
IDG=$(id -gn)  # User's group

T1="root"
T2="Linux"
T3="FreeBSD"
T4="DragonFly"

cd $CWD || exit

echo

if [ "$T1" = "$IDN" ]; then
echo "WARNING! You are running this script under root."
echo "You may better to start it under unpriveleged user."
echo 
echo "To do this please create new unpriveleged user now and then login"
echo "and start this script again."
echo 
exit
else
echo "You running this script under "$IDN" user."
echo 
fi
echo  "Creating FIDONet packages and saving it to $CWD/packages/ directory."
sleep 3

f1()

{

echo '------------------------------------------------------------------------------'
echo "Checking whether some necessary packages installed on this mashine:"
echo '------------------------------------------------------------------------------'
sleep 3
echo ""

##  make sure git archiver available
git=$(which git)

if [ -x "$git" ]
then
    echo "Git found: $git"
else
    echo "ERROR: git not found."
    echo "So it will not be possible extract fidoip sources on this machine."
    echo " You should take steps to get git installed,"
    echo " as described in documentation of fidoip."
    sleep 3
    exit
fi
echo ""
echo '------------------------------------------------------------------------------'
    sleep 1

## make sure C compiler/linker available

gccloc=$(which gcc)

if [ -x "$gccloc" ]
then
    echo "C compiler found: $gccloc"
else
    echo "WARNING: gcc not found."
fi

echo ""
echo '------------------------------------------------------------------------------'
  sleep 1

## make sure C++ compiler/linker available

gploc=$(which g++)

if [ -x "$gploc" ]
then
    echo "C++ compiler found: $gploc"
else
    echo "WARNING: c++ support for gcc not found."
    exit
fi

echo ""
echo '------------------------------------------------------------------------------'

  sleep 1

clang=$(which clang)

if [ -x "$clang" ]
then
    echo "Clang package found: $clang"
else
    echo "ERROR: clang package not found."
    echo "Please install it and run this script again."
    echo " You should take steps to get clang installed,"
    echo " as described in in documentation of fidoip."
    sleep 1
    exit
fi

echo ""
echo '------------------------------------------------------------------------------'
  sleep 1

clangplus=$(which clang++)

if [ -x "$clangplus" ]
then
    echo "Clang++ package found: $clangplus"
else
    echo "ERROR: clang++ not found."
    echo "Please install it and run this script again."
    echo " You should take steps to get clang++ installed,"
    echo " as described in in documentation of fidoip."
    sleep 3
    exit
fi

echo ""
echo '------------------------------------------------------------------------------'
  sleep 1

cmake=$(which cmake)

if [ -x "$cmake" ]
then
    echo "Cmake package found: $cmake"
else
    echo "ERROR: cmake package not found."
    echo "Please install it and run this script again."
    echo " You should take steps to get cmake installed,"
    echo " as described in in documentation of fidoip."
    sleep 3
    exit
fi

echo ""
echo '------------------------------------------------------------------------------'
  sleep 1
echo ""

export CC="$clang"
export CXX="$clangplus"

if [ -n "$GIT_PROXY" ]
then
    echo "http_proxy setup: $GIT_PROXY"
    export http_proxy="$GIT_PROXY"
    echo "https_proxy setup: $GIT_PROXY"
    export https_proxy="$GIT_PROXY"
    echo "GIT_PROXY setup: $GIT_PROXY"
    git config --global http.proxy "$GIT_PROXY"
     sleep 2
    echo
fi

echo ''
echo '------------------------------------------------------------------------------'
echo '| Starting creating packages of FIDONet (BinkD, Husky HPT and GoldEd+).|'
echo '------------------------------------------------------------------------------'
echo ''
sleep 5

cd binkd || exit
sh binkd.Build
cd ../husky || exit
sh husky.Build
cd ../golded || exit
sh golded.Build

cd "$CWD" || exit

echo 
echo '------------------------------------------------------------------------------'
echo "   Done! Creation of packages BinkD, Husky HPT and GoldEd+ are finished."
echo '------------------------------------------------------------------------------'
echo "  FIDONet *.tgz packages saved to this directory: "
echo "  $CWD/packages/ "
echo '------------------------------------------------------------------------------'
echo
sleep 3
echo '------------------------------------------------------------------------------'
echo "  To install FIDONet packages to directory $HOMEDIR run this 4 commands: "
echo
sleep 1
echo  "cd $HOMEDIR"
echo
echo  "tar -xzpf $(ls -t "$CWD"/packages/binkd*.tgz  | head -n1) -C ."
echo
sleep 1
echo  "tar -xzpf $(ls -t "$CWD"/packages/husky*.tgz | head -n1) -C ."
echo
sleep 1
echo  "tar -xzpf $(ls -t "$CWD"/packages/golded*.tgz  | head -n1) -C ."
echo
sleep 1
echo '   Then again go back to this directory: '
echo
sleep 1
echo " cd $CWD"
echo
sleep 1
echo ' and start "bash ./setup_config.bash" to create configuration for point setup '
echo 'or use "bash ./setup_node.bash" to create configuration for node setup.  '
echo
sleep 1
echo '------------------------------------------------------------------------------'
echo '   Visit https://sf.net/projects/fidoip/ for info and updates.  '
echo '------------------------------------------------------------------------------'
 
}
f1
#End of create_packages.sh

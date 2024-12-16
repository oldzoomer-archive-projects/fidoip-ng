#!/bin/sh
#
# build.sh
#

VERSION="1.5"

die()
{
    printf '%s\n' "$1" >&2
    exit 1
}

show_help()
{
    cat <<EOF

Download the necessary sources and build executables for the programs
specified in PROGRAMS setting of huskymak.cfg and for the libraries
they depend on.

Usage:
    build.sh [-n|--no-update] [--offline] [-j JOBS]
    build.sh [-v|--version] [-h|-\?|--help]
Options:

    -n
    --no-update
        Do not update Makefile, huskymak.cfg, build.sh

    --offline
        Do not download or update anything. This option implies --no-update. Be
        warned that the files 'cvsdate.h' with release dates are created during
        update of the sources. So you can use the option only if all the
        sources and these files are already present.

    -j JOBS
        JOBS is a positive integer. It specifies the number of makefile
        recipes to run simultaneously. If you omit the option, make runs
        as many recipes simultaneously as possible. To switch the parallel
        makefile execution off, use "-j 1".

    -v
    --version
        Print the script version and exit.

    -h
    -?
    --help
        Print this help and exit.
EOF
}

help=0
no_update=0
offline=0
jobs=-j

while :
do
    case $1 in
        -h|-\?|--help)
            help=1
            break
            ;;
        -v|--version)
            echo "version = $VERSION"
            exit
            ;;
        -n|--no-update)
            no_update=1
            ;;
        --offline)
            offline=1
            no_update=1
            ;;
        -j)
            if [ "$2" ]
            then
                if [ -z "${2##*[!0-9]*}" ] || [ "$2" -eq 0 ]
                then
                    die 'ERROR: "-j" requires a positive integer argument'
                else
                    jobs=-j$2
                    shift
                fi
            else
                die 'ERROR: "-j" requires a positive integer argument'
            fi
            ;;
        -*)
            printf 'WARN: Unknown option (ignored): %s\n' "$1" >&2
            ;;
        *)
            break
    esac
    shift
done

if [ $help -eq 1 ]
then
    show_help
    exit
fi


# Check that the script is not run by root
[ "$(id -u)" -eq 0 ] && die "DO NOT run this as root"

MAKE=make
[ "$(uname -s)" = FreeBSD ] && MAKE=gmake

if [ "$offline" -eq 0 ]
then
    ${MAKE} $jobs update
    [ "$?" -ne 0 ] && exit 1
fi

restart=0

if [ "$no_update" -eq 0 ] && [ -n "$(diff ./Makefile huskybse/Makefile)" ]
then
    cp -p -f huskybse/Makefile ./
fi

huskymak=huskybse/huskymak.cfg
OS=$(uname -s)
[ "$OS" = FreeBSD ] && huskymak=huskybse/huskymak.cfg.bsd
[ "$OS" = Darwin ] && huskymak=huskybse/huskymak.cfg.macos
[ "${OS%%${OS#MINGW}}" = MINGW ] && huskymak=huskybse/huskymak.cfg.mgw

if [ "$no_update" -eq 0 ] && \
   [ -n "$(diff ./huskymak.cfg.new $huskymak)" ]
then
    mv -f ./huskymak.cfg.new huskymak.cfg.old
    cp -p -f $huskymak huskymak.cfg.new
    if [ ! -e ./huskymak.cfg ]
    then
        cp -p ./huskymak.cfg.new huskymak.cfg
    fi
    echo
    echo "\"$huskymak\" has changed"
    echo
    echo "A new version of \"$huskymak\" is now"
    echo "in \"./huskymak.cfg.new\" and its old version"
    echo "is now in \"./huskymak.cfg.old\"."
    echo "Please adjust your \"./huskymak.cfg\" to the changes"
    echo "in \"./huskymak.cfg.new\" and run \"build.sh\" once more."
    echo
    restart=1
fi

if [ "$no_update" -eq 0 ] && \
   [ -n "$(diff ./build.sh huskybse/script/build.sh)" ]
then
    cp -p -f huskybse/script/build.sh ./
    if [ "$restart" -ne 1 ]
    then
    echo
    echo 'The "build.sh" script has changed. Please restart it.'
    echo
    restart=1
    fi
fi

[ "$restart" -eq 1 ] && exit
huskymak=./huskymak.cfg

if [ -n "$(grep 'PROGRAMS=' $huskymak | grep 'hpt')" ] && \
   [ -n "$(grep '^PERL=1' $huskymak)" ] && \
   ( [ -z "$(perl -v 2>&1 | grep 'This is perl')" ] || \
     [ -z "$(perl -MExtUtils::Embed -e 'print "Yes"' 2>&1 | grep 'Yes')" ] )
then
    printf '%s\n' "To build hpt with Perl, you must install Perl" >&2
    die "and Perl module 'ExtUtils::Embed'"
fi

if [ -n "$(grep 'PROGRAMS=' $huskymak | grep 'util')" ] && \
   ( [ -z "$(perl -v 2>&1 | grep 'This is perl')" ] || \
     [ -z "$(perl -MModule::Build -e 'print "Yes"' 2>&1 | grep 'Yes')" ] || \
     [ -z "$(perl -MTest::More -e 'print "Yes"' 2>&1 | grep 'Yes')" ] )
then
    printf '%s\n' "To build util, you must install Perl" >&2
    die "and Perl modules 'Module::Build' and 'Test::More'"
fi

if [ -n "$(grep '^INFODIR='  $huskymak | cut -d= -f2)" ] && \
   [ -n "$(grep '^MAKEINFO=' $huskymak | cut -d= -f2)" ]
then
    if [ "$OS" = Linux ] || [ "$OS" = FreeBSD ]
    then
        if [ -z "$(whereis -b makeinfo | cut -d: -f2)" ]
        then
            die "Please install 'makeinfo' program"
        fi
    elif [ "$OS" = Darwin ] && \
         [ -z "$(which /usr/local/opt/texinfo/bin/makeinfo | grep '/usr/local/opt/texinfo/bin/makeinfo')" ]
    then
        die "Please run 'brew install texinfo'"
    fi
fi
#${MAKE} $jobs depend && ${MAKE} $jobs

#!/bin/bash
#*****************************************************************
#     torjail - equk.co.uk
#*****************************************************************
# This script downloads & sets up torbrowser in a private directory.
# It then runs torbrowser in a sandbox using firejail, Xephyr
# and dwm
#
# firejail   https://firejail.wordpress.com/
# xephyr     https://wiki.freedesktop.org/www/Software/Xephyr/
# dwm        http://dwm.suckless.org/
# torbrowser https://www.torproject.org/projects/torbrowser.html.en
#
# The defaults install to ~/.torjail
# It also executes dwm from within the sandboxed env.
# If dwm is not found it will attempt to copy from /usr/bin/dwm
#
# 06/02/2016 -  Added commandline option to disable Xephyr
# 23/02/2016 -  Some functions changed to fix tmpfs problem caused
#               by firejail removing private-home
#
# License: MIT (LICENSE file should be included with script)
#*****************************************************************
# Notes: You may want to provide your own custom copiled dwm
#*****************************************************************

# variables
TORJAIL_BASE="${HOME}/.torjail"
TORJAIL_RES="800x600"
TORJAIL_DISPLAY=":6"
#*****************************************************************
#   you probably don't need to change anything below this line
#*****************************************************************
TORJAIL="torbrowser"
TORJAIL_XAUTH="/tmp/.Xauthority-$TORJAIL"
TORJAIL_TMP="/tmp/.torxephyr"
TORJAIL_RAM="/tmp/torjail"
TORJAIL_HOME="${TORJAIL_RAM}/tor-browser_en-US/Browser"

# download locations
TOR_VER="7.0"
TOR_MIRROR="https://dist.torproject.org/torbrowser/${TOR_VER}"
TOR_X64="tor-browser-linux64-${TOR_VER}_en-US.tar.xz"
TOR_32="tor-browser-linux32-${TOR_VER}_en-US.tar.xz"
TOR_SHA="sha256sums.txt"
TOR_GPG="0x4E2C6E8793298290"

# color / colour
blue="\033[1;34m"
green="\033[1;32m"
red="\033[1;31m"
yellow="\033[1;33m"
reset="\033[0m"
# CLI feedback
cl_error="[$red ERROR $reset]"
cl_ok="[$green OK $reset]"
cl_warn="[$yellow WARN $reset]"
# get current path
SCRIPT_PWD=$(pwd)
# check architecture
ARCH=$(getconf LONG_BIT)
if [ "$ARCH" = "64" ]; then
    TOR_DOWNLOAD=$TOR_X64
else
    TOR_DOWNLOAD=$TOR_32
fi
TOR_ASC="${TOR_DOWNLOAD}.asc"
# commandline options
# -x disables xephyr
while getopts ":x" opt; do
    case $opt in
        x)
            disable_xephyr="1"
            echo -e "$cl_warn disabling Xephyr"
            ;;
        \?)
            echo -e "$cl_error invalid option: -$OPTARG"
            echo -e "$cl_warn valid options: -x (disables Xephyr)"
            exit 1
            ;;
    esac
done

check_result(){
    if [ $1 -ne 0 ]; then
        echo -e "$cl_error checksum or gpg key did not match"
        echo -e "$cl_warn removing file"
        rm $TOR_DOWNLOAD
        echo -e "$cl_warn corrupt/invalid file removed - please restart torjail"
        exit 1
    fi
}

update() {
    echo -e "$cl_warn torbrowser requires updating"
    echo -e "$cl_warn current ver: $INSTALLED_VER"
    echo -e "$cl_warn updating to: $TOR_VER"
    rm -rf $TORJAIL_BASE
    install
}

install() {
    echo -e "$cl_ok creating torjail base folder at ${TORJAIL_BASE}"
    mkdir -p $TORJAIL_BASE
    cd $TORJAIL_BASE

    gpg --fingerprint ${TOR_GPG}
    if [ $? -ne 0 ]; then
        echo -e "$cl_ok Downloading PGP Public Key..."
        gpg --keyserver pool.sks-keyservers.net --recv-keys ${TOR_GPG}
        gpg --fingerprint ${TOR_GPG}
        if [ $? -ne 0 ]; then
            echo -e "$cl_error Could not download PGP public key for verification"
            exit 1
        fi
    else
        echo -e "$cl_ok signing key for torbrowser found"
        echo -e "$cl_ok Tor Browser Developers (signing key) <torbrowser@torproject.org>"
    fi

    if [[ ! -e $TOR_DOWNLOAD ]]; then
        echo -e "$cl_ok downloading torbrowser - ${TOR_DOWNLOAD}"
        curl -OL# "${TOR_MIRROR}/${TOR_DOWNLOAD}"
    fi
    if [[ ! -e $TOR_SHA ]]; then
        echo -e "$cl_ok downloading checksums - ${TOR_SHA}"
        curl -OL# "${TOR_MIRROR}/${TOR_SHA}"
    fi
    if [[ ! -e $TOR_ASC ]]; then
        echo -e "$cl_ok downloading GPG asc - ${TOR_ASC}"
        curl -OL# "${TOR_MIRROR}/${TOR_ASC}"
    fi
    echo -e "$cl_ok verifying files"
    grep $TOR_DOWNLOAD sha256sums.txt > sha.tmp
    shasum -c sha.tmp
    check_result $?

    echo -e "$cl_ok verifying gpg key"
    gpg --verify $TOR_ASC $TOR_DOWNLOAD
    check_result $?

    rm sha.tmp
    echo -e "$cl_ok extracting torbrowser bundle"
    mkdir $TORJAIL_RAM
    tar -xJf $TOR_DOWNLOAD -C $TORJAIL_RAM
    echo $TOR_VER >> VER_INSTALLED
}

# Check for root ( quit if root :x )
if [ $(whoami) = "root" ]; then
    exit 1
fi

# start with a banner showing version of script
echo -e "$cl_ok starting torbrowser script"

# check if tmpfs home exists
if [[ -e $TORJAIL_RAM ]]; then
    echo -e "$cl_warn torjail exists in tmpfs"
    echo -e "$cl_ok removing $TORJAIL_RAM"
    rm -r $TORJAIL_RAM
fi

# check version installed
if [[ -e $TORJAIL_BASE/VER_INSTALLED ]]; then
    INSTALLED_VER=$(head -n 1 $TORJAIL_BASE/VER_INSTALLED)
    echo -e "$cl_ok torbrowser version ${INSTALLED_VER} found"
    if [[ "$INSTALLED_VER" != "$TOR_VER" ]]; then
        update
    fi
fi
# run install
install
# make sure we are in script working directory
cd $SCRIPT_PWD
# check if xephyr instance of tor already running
if [[ -e $TORJAIL_TMP ]]; then
    echo -e "$cl_error another TORJAIL xephyr instance was detected"
    echo -e "$cl_error would you like to continue? [y/n]"
    read answer
    case $answer in
        [Yy]*)
            echo -e "$cl_warn attempting to start session"
            ;;
        [Nn]*)
            echo -e "$cl_error exiting ..."
            exit 1
            ;;
        *)
            echo -e "$cl_error invalid input"
            echo -e "$cl_error exiting ..."
            exit 1
    esac
fi

# cleanup xauth if exists
if [[ -e $TORJAIL_XAUTH ]]; then
    rm -- "$TORJAIL_XAUTH"
fi

# copy dwm binary if it doesn't exist
if [[ ! -e $TORJAIL_HOME/dwm ]]; then
    echo -e "$cl_warn dwm does not exist in priv-home"
    echo -e "$cl_warn copying dwm from /usr/bin/dwm"
    cp /usr/bin/dwm $TORJAIL_HOME/dwm
fi

# create tmp file
if [[ ! -e $TORJAIL_TMP ]]; then
    touch "$TORJAIL_TMP"
fi

# check if xephyr disable opt passed
if [[ $disable_xephyr != 1 ]]; then
    # setup x vars
    touch "$TORJAIL_XAUTH"
    xauth -f "$TORJAIL_XAUTH" add "$TORJAIL_DISPLAY" . "`mcookie`"
    # start xephyr
    Xephyr -auth "$TORJAIL_XAUTH" -screen "$TORJAIL_RES" "$TORJAIL_DISPLAY" &
    TORJAIL_PID=$!
    export DISPLAY="$TORJAIL_DISPLAY"
    export XAUTHORITY="$TORJAIL_XAUTH"
    # execute sandboxed dwn env & application
    echo -e "$cl_ok starting session"
    firejail --profile="$TORJAIL.profile" -- ./dwm &
    firejail --profile="$TORJAIL.profile" -- "./start-tor-browser"
    # kill Xephyr
    kill $TORJAIL_PID
else
    # execute torjail without xephyr
    echo -e "$cl_ok starting session without Xephyr"
    firejail --profile="$TORJAIL.profile" -- "./start-tor-browser"
fi

# remove tmp file
rm -- "$TORJAIL_TMP"
# cleanup tmpfs
if [[ -e $TORJAIL_RAM ]]; then
    echo -e "$cl_ok cleaning up tmpfs"
    echo -e "$cl_ok removing $TORJAIL_RAM"
    rm -r $TORJAIL_RAM
fi
echo -e "$cl_ok session finished ..."

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
TORJAIL_HOME="${TORJAIL_BASE}/tor-browser_en-US/Browser"
TORJAIL_XAUTH="/tmp/.Xauthority-$TORJAIL"
TORJAIL_TMP="/tmp/.torxephyr"

# download locations
TOR_VER="5.0.7"
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
    echo -e "$cl_ok creating torjail base folder at ~/.torjail"
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
    tar -xJf $TOR_DOWNLOAD
    echo $TOR_VER >> VER_INSTALLED
}

# Check for root ( quit if root :x )
if [ $(whoami) = "root" ]; then
    exit 1
fi

# start with a banner showing version of script
echo -e "$cl_ok starting torbrowser script"

# check version installed
if [[ -e $TORJAIL_BASE/VER_INSTALLED ]]; then
    INSTALLED_VER=$(head -n 1 $TORJAIL_BASE/VER_INSTALLED)
    echo -e "$cl_ok torbrowser version ${INSTALLED_VER} found"
    if [[ "$INSTALLED_VER" != "$TOR_VER" ]]; then
        update
    fi
fi

# check if torjail is installed
if [[ ! -e $TORJAIL_HOME ]]; then
    echo -e "$cl_error Unable to find torjail home"
    echo -e "$cl_error Would you like to download & setup torbrowser [y/n]"
    read answer
    case $answer in
        [Yy]*)
            echo -e "$cl_ok setting up torjail"
            install
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
# setup x vars
touch "$TORJAIL_XAUTH"
xauth -f "$TORJAIL_XAUTH" add "$TORJAIL_DISPLAY" . "`mcookie`"
Xephyr -auth "$TORJAIL_XAUTH" -screen "$TORJAIL_RES" "$TORJAIL_DISPLAY" &
TORJAIL_PID=$!
DISPLAY="$TORJAIL_DISPLAY"
XAUTHORITY="$TORJAIL_XAUTH"

# execute sandboxed dwn env & application
echo -e "$cl_ok starting session"
firejail --profile="$TORJAIL.profile" --netfilter="$TORJAIL.filter" -- $TORJAIL_HOME/dwm &
firejail --profile="$TORJAIL.profile" --netfilter="$TORJAIL.filter" -- "$TORJAIL_HOME/start-tor-browser"
# kill Xephyr
kill $TORJAIL_PID
# remove tmp file
rm -- "$TORJAIL_TMP"
echo -e "$cl_ok session finished ..."
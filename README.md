[![License](http://img.shields.io/:license-mit-blue.svg?style=flat)](http://badges.mit-license.org)

# torjail

Sandbox torbrowser using firejail, Xephyr & dwm

This script downloads & sets up torbrowser in a private directory.

It then runs torbrowser in a sandbox using firejail, Xephyr and dwm

    firejail   https://firejail.wordpress.com/
    xephyr     https://wiki.freedesktop.org/www/Software/Xephyr/
    dwm        http://dwm.suckless.org/
    torbrowser https://www.torproject.org/projects/torbrowser.html.en

The default directory for install is ~/.torjail

You can install the script wherever you want providing you keep the associated files.

use `-x` to disable Xephyr + dwm

**License:** MIT

## why?

A few references to why you should use a sandbox & xephyr

torproject:

    Wait, Firefox uses X11, isn't security basically hopeless?

    If you want to attempt to mitigate this, the best options are:

    Use a nested X11 implementation like Xephyr or Xpra.

mozilla:

    The one exception to the network policy, for now,
    is the X11 protocol which is used to display graphics and receive keyboard/mouse input.

## screenshot

![](https://raw.githubusercontent.com/equk/torjail/master/screenshot.png)

## variables

    TORJAIL_BASE="${HOME}/.torjail"
    TORJAIL_RES="800x600"
    TORJAIL_DISPLAY=":6"

Most useful variable is probably resolution & possibly display (depending on how many other xephyr sessions you run)

## features

- [x] downloads torbrowser from torproject.org
- [x] sets up a working env in tmpfs
- [x] runs tor in a sandbox
- [x] runs in /tmp/ so any changes are not saved
- [x] runs in its own xephyr dwm session
- [x] has sha256 verification
- [x] works on 32bit & 64bit linux
- [x] stores everything in ~/.torjail
- [x] version checking & updating
- [x] gpg verification of downloads

## removal

Remove this script & ~/.torjail

## script running

    ./torbrowser.sh
    [ OK ] starting torbrowser script
    [ OK ] torbrowser version 5.0.6 found
    [ ERROR ] Unable to find torjail home
    [ ERROR ] Would you like to download & setup torbrowser [y/n]
    y
    [ OK ] setting up torjail
    [ OK ] creating torjail base folder at ~/.torjail
    gpg: error reading key: No public key
    [ OK ] Downloading PGP Public Key...
    gpg: key 93298290: public key "Tor Browser Developers (signing key) <torbrowser@torproject.org>" imported
    gpg: no ultimately trusted keys found
    gpg: Total number processed: 1
    gpg:               imported: 1
    pub   rsa4096/93298290 2014-12-15 [expires: 2020-08-24]
          Key fingerprint = EF6E 286D DA85 EA2A 4BA7  DE68 4E2C 6E87 9329 8290
    uid         [ unknown] Tor Browser Developers (signing key) <torbrowser@torproject.org>
    sub   rsa4096/F65C2036 2014-12-15 [expires: 2017-08-25]
    sub   rsa4096/D40814E0 2014-12-15 [expires: 2017-08-25]

    [ OK ] downloading checksums - sha256sums.txt
    ######################################################################## 100.0%
    [ OK ] downloading GPG asc - tor-browser-linux64-5.0.6_en-US.tar.xz.asc
    ######################################################################## 100.0%
    [ OK ] verifying files
    tor-browser-linux64-5.0.6_en-US.tar.xz: OK
    [ OK ] verifying gpg key
    gpg: Signature made Thu 17 Dec 2015 20:57:01 GMT using RSA key ID D40814E0
    gpg: Good signature from "Tor Browser Developers (signing key) <torbrowser@torproject.org>" [unknown]
    gpg: WARNING: This key is not certified with a trusted signature!
    gpg:          There is no indication that the signature belongs to the owner.
    Primary key fingerprint: EF6E 286D DA85 EA2A 4BA7  DE68 4E2C 6E87 9329 8290
         Subkey fingerprint: BA1E E421 BBB4 5263 180E  1FC7 2E1A C68E D408 14E0
    [ OK ] extracting torbrowser bundle
    [ WARN ] dwm does not exist in priv-home
    [ WARN ] copying dwm from /usr/bin/dwm
    [ OK ] starting session

on update

    [ OK ] starting torbrowser script
    [ OK ] torbrowser version 7.5.6 found
    [ WARN ] torbrowser requires updating
    [ WARN ] current ver: 7.5.6
    [ WARN ] updating to: 8.0
    [ OK ] creating torjail base folder at ~/.torjail

## notes

Once you download torbrowser bundle the file is kept in ~/.torjail for future use so you don't have to
keep re-downloading the bundle. It also always checks the sha256sum of the file before extraction.

<details><summary>Mozilla References</summary>

[Security/Sandbox - Mozilla Wiki](https://wiki.mozilla.org/Security/Sandbox)

[Garf's blog: Linux sandboxing improvements in Firefox 60](https://www.morbo.org/2018/05/linux-sandboxing-improvements-in_10.html)</details>
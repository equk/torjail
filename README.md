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

**License:** MIT

## screenshot

![](https://raw.githubusercontent.com/equk/torjail/master/screenshot.jpg)

## variables

    TORJAIL_BASE="${HOME}/.torjail"
    TORJAIL_RES="800x600"
    TORJAIL_DISPLAY=":6"

Most useful variable is probably resolution & possibly display (depending on how many other xephyr sessions you run)

## features

* downloads torbrowser from torproject.org
* sets up a working env
* runs tor in a sandbox
* runs in /tmp/ so any changes are not saved
* runs in its own xephyr dwm session
* has sha256 verification
* works on 32bit & 64bit linux
* stores everything in ~/.torjail
* version checking & updating
* gpg verification of downloads

## todo

* add option to clear session
* add commandline options

I'm currently looking at the possibiltiy of adding commandline options to make ramdisk operation optional, select resolution at cli, make xephyr optional, custom base directory & use a different wm for xephyr session.

## removal

Remove this script & ~/.torjail
# Firejail profile

# Profile For Custom tor-browser-en
# Sandbox also enables seccomp

# includes
include /etc/firejail/disable-programs.inc
include /etc/firejail/disable-common.inc
include /etc/firejail/disable-devel.inc
include /etc/firejail/disable-interpreters.inc

include /etc/firejail/whitelist-common.inc
include /etc/firejail/whitelist-var-common.inc
include /etc/firejail/whitelist-runuser-common.inc
include /etc/firejail/whitelist-usr-share-common.inc

caps.drop all
netfilter
nogroups
nonewprivs
noroot
nodvd
nodbus
notv
nou2f
novideo
protocol unix,inet,inet6
seccomp !chroot
#shell none
#tracelog

# blacklist
blacklist /boot
blacklist /mnt
blacklist /root
blacklist /srv

disable-mnt
# extended sandbox for torbrowser
# note: any changes will not be saved
private /tmp/torjail/tor-browser/Browser
private-etc alsa,alternatives,asound.conf,ca-certificates,crypto-policies,fonts,ld.so.cache,ld.so.conf,ld.so.conf.d,ld.so.preload,machine-id,pki,pulse,resolv.conf,ssl
private-dev
private-bin bash,cat,cp,cut,dirname,env,expr,file,gpg,grep,gxmessage,id,kdialog,ln,mkdir,mv,python*,rm,sed,sh,tail,tar,tclsh,test,tor-browser,tor-browser-en,torbrowser-launcher,update-desktop-database,xmessage,xz,zenity
private-tmp

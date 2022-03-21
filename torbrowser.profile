# Firejail profile

# Profile For Custom tor-browser-en
# Sandbox also enables seccomp

# includes
include /etc/firejail/disable-programs.inc
include /etc/firejail/disable-common.inc
include /etc/firejail/disable-devel.inc
include /etc/firejail/disable-interpreters.inc

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
shell none
#tracelog

# blacklist
blacklist /boot
blacklist /mnt
blacklist /root
blacklist /srv

disable-mnt
# extended sandbox for torbrowser
# note: any changes will not be saved
private /tmp/torjail/tor-browser_en-US/Browser
private-etc fonts,hostname,hosts,resolv.conf,pki,ssl,ca-certificates,crypto-policies,alsa,asound.conf,pulse,machine-id,ld.so.cache
private-dev
private-bin bash,sh,grep,tail,env,gpg,id,readlink,dirname,test,mkdir,ln,sed,cp,rm,getconf,tor-browser,tor-browser-en,torbrowser-launcher
private-tmp

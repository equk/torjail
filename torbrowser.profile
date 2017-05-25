# Firejail profile

# Profile For Custom tor-browser-en
# Sandbox also enables seccomp

# includes
include /etc/firejail/disable-programs.inc
include /etc/firejail/disable-common.inc
include /etc/firejail/disable-devel.inc
include /etc/firejail/disable-passwdmgr.inc

caps.drop all
netfilter
nogroups
nonewprivs
noroot
protocol unix,inet,inet6
seccomp
shell none
tracelog

# blacklist
blacklist /boot
blacklist /mnt
blacklist /root
blacklist /srv

# extended sandbox for torbrowser
# note: any changes will not be saved
private /tmp/torjail/tor-browser_en-US/Browser
private-etc fonts/
private-dev
private-bin bash,grep,tail,env,gpg,id,readlink,dirname,test,mkdir,ln,sed,cp,rm,getconf
private-tmp

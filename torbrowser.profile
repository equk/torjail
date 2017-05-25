# Firejail profile

# Profile For Custom tor-browser-en
# Sandbox also enables seccomp

# includes
include /etc/firejail/disable-programs.inc
include /etc/firejail/disable-common.inc
include /etc/firejail/disable-devel.inc

caps.drop all
seccomp
protocol unix,inet,inet6
netfilter
noroot

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
private-bin bash,env,id,dirname,mkdir,ln,cp,sed,getconf,file,expr

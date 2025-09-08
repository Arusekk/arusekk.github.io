---
title: Plan 9 setup on OpenWRT
date: 2025-05-23
description: Go set up your own Plan 9 network on a Linux router
---

Ever wanted to try Plan 9 but it did not work? Just kidding.

My setup involves a Linux router as a file server,
a Raspberry Pi 2 CPU server,
and a generic netboot config for amd64 terminals (including QEMU).

File server on the router means DHCP (of course it does it already; OpenWRT uses dnsmasq),
PXE (TFTP provided by atftpd)
and finally a 9P server
(u9fs; maybe in the future you can run an actual file server, like gefs, with Uglendix).

I should add an auth server there, too, and a secstore server.
But for now no auth, just allow anyone to impersonate anyone I guess.

You can netboot a QEMU using:

```
#!/bin/sh

tftpsrv=192.168.1.1  # libslirp 4.9.0+ required
bootfile=/386/9bootpxe
#bootfile=/amd64/9pc64

qemu-system-x86_64 \
        -cpu host \
        -accel kvm \
        -m 1024 \
        -nic user,model=virtio,mac=00:20:91:37:33:73,tftp-server-name=$tftpsrv,bootfile=$bootfile \
        -device qemu-xhci,id=xhci \
        -device usb-tablet,bus=xhci.0 \
        "$@"
```

I had to add a /cfg/pxe/default to TFTP, containing at least `bootfile=/amd64/9pc64`.

# Raspberry Pi 2 CPU server

Raspberry Pi 2 does not have network booting without SD card.
But you can work around this by inserting an SD card with just `bootcode.bin` file.

My DHCP server is dnsmasq. RPi built-in network boot software is PXEClient,
which does not recognize the 'bootfile' option of DHCP/BOOTP.

```
# fs & auth - note the space: the first byte is ignored (option length?)
dhcp-option-force=vendor:plan9,130," 192.168.1.1"
dhcp-option-force=vendor:plan9,131," 192.168.1.1"

dhcp-vendorclass=set:rpi,PXEClient:Arch:00000:UNDI:002001
pxe-service=tag:rpi,0,"Raspberry Pi Boot"
# the below does not just work: RPi ignores DHCP bootfile
#dhcp-boot=tag:rpi,arm/9pi2
```

Raspi does not have working NVRAM yet as far as 9front goes
(9legacy has some more support for pi nvram but still not enough in my experience).
So apparently the SD card needs to contain a 512-byte file called plan9.nvr as well.
Otherwise the boot will not be fully hands-free,
and you will have to fill in nvram variables on every reboot.

If you forget to note the serial number of your raspi, no worries.
`tcpdump` will let you know what files are requested over TFTP.

Once set up, you need to first boot the Pi with a monitor and a keyboard
(unless you know what to put in plan9.nvr).
In case you only have a keyboard and want to type blind, here are the things it asks for,
before even asking for bootargs:
```
authid:
authdom:
key:
password:
confirm password:
```

You need authid to match an existing user on the fileserver.
The rest are arbitrary I think.


# Full file tree

So the full file tree on my Raspberry Pi 2 SD Card (FAT32 formatted) is:

```
disk
|- bootcode.bin (from /sys/src/boot/bcm/bootcode.bin)
\- plan9.nvr (512B of NULs)
```

The full TFTP file tree is:
```
tftp
|- 386 (symlink to ../plan9/386)
|- amd64 (symlink to ../plan9/amd64)
|- arm (symlink to ../plan9/arm)
|- cfg (symlink to ../plan9/cfg)
|- config.txt (symlink to cfg/pxe/9pi.ini)
|- fixup_cd.elf (symlink to ../plan9/sys/src/boot/bcm/fixup_cd.dat)
\- start_cd.elf (symlink to ../plan9/sys/src/boot/bcm/start_cd.dat)
```

The full `/cfg` file tree is:
```
cfg
|+ pi9/
|\- cpurc (currently empty, but will start network services)
\+ pxe/
 |- 9pi.ini (see below)
 |- serial7f (see below)
 \- default (see below)
```

My /cfg/pxe/9pi.ini contains:
```
[0x......7f]
cmdline=cfg/pxe/......7f
[pi0]
kernel=arm/9pi
[pi1]
kernel=arm/9pi
[pi2]
kernel=arm/9pi2
[pi3]
kernel=arm/9pi2
core_freq=250
[all]
gpu_mem=16
enable_uart=0
boot_delay=1
```

My `/cfg/pxe/......7f` contains (note spaces instead of newlines, and quoting):
```
service=cpu nobootprompt=tcp fs=192.168.1.1 auth=192.168.1.1 nvram='#S/sdM0/dos' nvroff=dos user=glenda
```

My `/cfg/pxe/default` contains config for `386/9bootpxe`, since it is the only way of booting reading the file:
```
# config for starting shell right away
nobootprompt=tcp
bootargs=tcp
fs=192.168.1.1
auth=192.168.1.1
user=glenda
monitor=vesa
vgasize=1024x768x16
mouseport=ps2
bootfile=/amd64/9pc64
```

I also added the following to `/lib/ndb`:
```
ipnet=home ip=192.168.1.0 ipmask=255.255.255.0
	ipgw=192.168.1.1
	dns=192.168.1.1
	auth=192.168.1.1
	dnsdom=arusekk.pl
	cpu=pi9
ip=192.168.1.2 sys=pi9 dom=pi9.home ether=b827........
```

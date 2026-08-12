---
title: Checking out dérive Linux
date: 2026-08-12
description: The missing getting started guide for dérive Linux, how to take a closer look at it.
---

I recently came across [dérive][derive], one of the few Linux distros distributing [static binaries][wiki],
and the one most actively maintained (maybe because the contributors are young and have plenty of free time;
I hope that the project stays as active in a couple years).
And it is heavily inspired by plan9 (something the community calls 9larping).
I think this is a great idea overall.
Anyway, let's get to the guide part.

## Prerequisites

- a 3-button mouse, or a 2-button + scrollwheel mouse,
- internet (if you are reading this, you are probably good to go),
- a physical mouse,
- seriously go grab a mouse, if you only have a touchpad, you will be unable to do anything once the GUI starts.

## Launching

You can download the iso from their official website, or [directly from their repository][repo].

Then you can either boot it on actual hardware, or use a VM.
I settled on QEMU, because it is great.
The ISO needs a lot of RAM (min 3 gigs) for some reason.

```
$ qemu-system-x86_64 -m 4G -smp 2 -cpu host -accel kvm -usbdevice tablet -vga virtio -cdrom ~/Pobrane/derive81.iso
```

`-m 4G` means 4G memory, `-smp 2` means 2 cores, `-cpu host -accel kvm` mean virtualisation (because emulation is slow, kvm requires cpu host),
`-usbdevice tablet` means better mouse integration, and `-vga virtio` supports /dev/dri/render* which is required for some reason by swc
(and by neuswc too).
If you give it less than 3 GiB, it will panic at best.
Now you need to wait two minutes or more, because initramfs is quite big and XZ-compressed.
ZSTD would be way faster, but also make the ISO bigger. Not judging.

Then you get to commandline prompt.
Type the following commands to get to the graphical session to check it out.

```
login: root
password: derive
# dtr s                     # dtr, most likely from detour, the source package manager
# dtr s                     # need to do it twice for some reason, it asks something, so say yes
# spm add neuswc            # spm is the binary package manager, (neu)swc is the wayland compositor
# spm add xkeyboard-config  # required by (neu)swc, spm does not handle runtime dependencies as of mid-2026
# spm add hst               # terminal, otherwise you won't be able to do anything basically
# spm add go-mono           # some font so that hst does not crash
# spm add hevel             # the flagship graphical session
# swc-launch hevel          # dérive!
```

Now if everything went fine, you should see a black screen with a cursor.
Start by pressing LMB (left mouse button),
then also press RMB (right mouse button), and drag across the screen.
Congrats, you just opened a terminal.
Do it again, somewhere outside the first window.
Now click one window, and then click the other one.
It moves!

There are also cool mouse chords for resizing the windows,
scrolling all around and stuff.
It will not look anywhere near [the Hevel demo on @schrub900's channel][mwga],
but you can certainly get the feel of a desktop that is basically an infinite plane.

Maybe I will record a demo, too.
Who knows.
Subscribe to my RSS if you want to stay updated.


[derive]: https://www.derivelinux.org/
[wiki]: https://en.wikipedia.org/wiki/Static_library
[repo]: https://pkg.derivelinux.org/
[mwga]: https://youtu.be/CoDwrvK6xxQ?t=177

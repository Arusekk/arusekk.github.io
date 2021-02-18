---
title: An adventure with Acer Swift
date: 2021-01-19
description: A story of a new laptop and hard obstacles in the way of getting it to work
---

Recently my old laptop started losing keyboard keys,
and I heard that in 2021 it is time to let go of that good ol' laptop
with loud HDD, CD station, shiny HD-ready LCD, dissolved keys, cracked screws,
two jacks, snappy sound, rumbling mic, 640x480 webcam, 4GiB RAM,
2x bithread i5-4200M @ 2.50 GHz,
especially that I use unstable Gentoo GNU/Linux distro,
which requires an overnight CPU-heavy update
(Portage, the Gentoo PM, compiles everything from source by default).

So I bought a new one.
I searched online for laptops with the following criteria set:

1. without M$ Windows [malware](https://www.gnu.org/proprietary/malware-microsoft.html) preinstalled,
2. without Intel CPU, for no particular reason.

(a linguistic digression):

'A laptop' came from 'a lap-top PC',
just as 'a desktop' came from 'a desk-top PC',
and I am not willing to talk any ultrabook / hyperbook nonsense,
though I like 'netbook' as an analogy of a networking notepad.
See [I translated Git!](i-translated-git.html) for how hard it is
to translate English nominalization of adjectives which is "business as usual".

This narrowed down the search results to circa 30 distinct models.
In whole Poland ([see][mmkt] [it][nnet] [for][euro] [yourself][mxp]).

[mmkt]: https://mediamarkt.pl/komputery-i-tablety/laptopy-laptopy-2-w-1./procesor=amd,amd-ryzen-3,amd-ryzen-5,amd-ryzen-7,amd-ryzen-9&system-operacyjny=brak-systemu
[nnet]: https://www.neonet.pl/komputery/laptopy/f/18176-rodzaj-procesora:amd-ryzen-5,amd-ryzen-7/8183-system-operacyjny:brak.html
[euro]: https://www.euro.com.pl/laptopy-i-netbooki,rodzaj-procesora_3!amd,system-operacyjny_3!bez-systemu.bhtml
[mxp]: https://www.mediaexpert.pl/komputery-i-tablety/laptopy-i-ultrabooki/laptopy/system-operacyjny_chrome-os.brak-dos/procesor_amd-seria-e.amd-seria-a.amd-seria-3000.amd-ryzen-3.amd-ryzen-5.amd-ryzen-7.amd-ryzen-9.amd-ryzen-9-5900hx.amd-ryzen-7-5800h

And then I thought that any would do, so I took the cheapest one.
It happened to be Acer Swift 3 (SF314-42).
It had quite everything I needed:

- A dedicated power socket.
- A USBC port, a USB2 port, and a USB3 port.
- A single jack audio socket.
- An HDMI socket.
- Light weight, full HD matt/frosted LCD (whatever the english name is).
- Sharp webcam, NVMe SSD, Ryzen 5, Radeon.

The hardware drawbacks I saw then:

- No RJ45 (LAN / Ethernet or what you call it).
- Intel Wi-Fi card (nah, it can't be that bad).

On the first boot an UEFI shell greeted me.
A nice one, though the path separators were awfully backwards.

Then I launched a live headless Gentoo to put everything in place.
Or so I wanted to do.
Before launching a screen appeared that wanted to know
whether I wanted to install any special stuff inside my shiny new UEFI,
so I just added the live OS' bootloader, and it booted gracefully.

I just set up Portage make.conf, timezone and locale,
installed GRUB and genkernel,
compiled a kernel with some preliminary config
and the next step was to reboot.
When I seleced gentoo-grub in EFI boot selection,
it showed a huge red shield with a white cross on it
and a label telling me "Secure Boot trust broken!" or something.

Then I wanted to get it working, so just as the owner's manual said,
I went into BIOS (F2 on the logo), added a Supervisor password,
added my bootloader's hash into EFI trusted set, reset the password
to empty in order to remove it (per the manual), and selected
"Save & poweroff" or something.

Then I tried to enter the BIOS again, but no luck this time :)

It looked just like it had a
```c
while (isPasswordSet && isPasswordUnset) {}
```
somewhere, because the logo (normally present for ~a second) did not go away,
and was unresponsive to Ctrl+Alt+Delete.

The good news was that my GRUB just worked.
My GNU/Linux did not, I guess the kernel was not configured enough.
So I took the universal config from Gentoo liveCD
and started to throw things away.

The things that didn't work OOTB were sound, X server, and touchpad.
The touchpad still has a 0.001 chance to break \@ boot for no reason.

The X server needed `dri`+`amdgpu` drivers enabled (no surprise here),
The touchpad needed psmouse and some strange AMD I²C – SODIMM bridge driver
(no surprise either, but was hard to find `pinctrl_amd` in Kconfig),
the speakers worked with `snd_hda_intel` universal HD audio driver,
and the mic apparently had a separate integrated soundcard
(searching for ALC255 told me that, and it is `snd_soc_dmic`).
The ax200 Wi-Fi 6 card needed `iwlmvm` with `ax200` firmware blobs.
Yeah, no chance to have 100% FLOSS on it now.

But whatever. The BIOS was still broken.

I tried to boot to UEFI directly from Linux (I intentionally skipped GNU now,
since it is a [thin software] from an [answer] to a [SU question]).

[thin software]: https://github.com/adoakley/efi-boot-to-fw-ui
[answer]: https://superuser.com/a/1547985/400626
[SU question]: https://superuser.com/questions/519718/linux-on-uefi-how-to-reboot-to-the-uefi-setup-screen-like-windows-8-can

I contacted Acer support on the phone, and the wisest thing they told me
was to update BIOS, and they sent me a BIOS firmware update.
It was a zipped EXE,
so I started to look for lightweight live M$ Windows images.
And not surprisingly I did not find one.
Surprisingly though, I found that you can [easily create one][winpe]!
All you need is another M$ Windows machine.
I used my work laptop (shhh! don't tell anyone) to create a 260 MiB iso image
in as few as two obvious commands.

[winpe]: https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/download-winpe--windows-pe

EDIT: it turns out this is a known method and [no Windows is needed][winpe-archwiki]

[winpe-archwiki]: https://wiki.archlinux.org/index.php/Windows_PE

(And I was in physical pain having to deal with this mirrored commandline.)

I copied over only several files from inside the ISO to a USB stick
(UEFI FTW over BIOS, no more reformatting your USB every single time!).
It booted with no pain.
And it launched the executable as well (great job, Insyde Corp!).
But the executable told me that my BIOS is already up to date,
and that I should go hack myself.

So I hacked that the `FH4FR108.exe` was a 7-zip SFX, extracted it,
and finally saw that there is a file called `properties.ini`,
which has tons of description on how to tamper with the parameters
and e.g. disable the version check.

(I lied, I searched online for `H2OFFT-Wx64.exe` and ended up on [SU again]).

[SU again]: https://superuser.com/questions/1496286/how-to-repair-a-broken-bios-setup-utility


And it has worked!
Now my shiny new laptop works again, without me having to install malware on it.

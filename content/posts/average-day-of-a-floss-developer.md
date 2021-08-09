---
title: Average day of a FLOSS developer
date: 2021-02-18
description: It feels fun to be part of a nice phenomenon.
---

I woke up, ate my breakfast, did some workout with [StepMania][sm] (a DDR clone,
great game, BTW, you should definitely try it, if you like to move),
practiced playing music a little on a MIDI keyboard (using QSynth with
JACK (managed by Catia) for low latency response).

I heard that Wine supports GTK3 themes, so I wanted to check it out,
but there was none for the latest version, and that lead me
to [filing a bug][winebug].

Then I worked a little on [pwntools][pwn].

In the afternoon I tried to transcribe (is this the word?) some music,
so I installed Lilypond and [found a bug there, too][lilybug].

[sm]: https://www.stepmania.com
[winebug]: https://bugs.winehq.org/show_bug.cgi?id=50677
[pwn]: https://pwntools.com
[lilybug]: https://lists.gnu.org/archive/html/bug-lilypond/2021-02/msg00043.html

In the evening I worked on rooting my new Xperia XA2,
which I will describe in an upcoming blog post.

It is not that Free/Libre Open Source Software does not work.
It works great.
And in order to be developed by total strangers,
the requirement to keep code quality high is paramount.
And whenever you report a bug with a complete simple solution,
it gets fixed in seconds.
Here are some contributions I made last month:

* [kate][kate-percent] — in vi input mode (I love vim for being so productive)
  some actions were behaving strange,
  I decided to take a look at this;
  one of the errors was [already reported][kate-fold],
  it was enough to check out the repo,
  comment out git hooks in the tests,
  find the offending place by grepping for %,
  then reading some source code
  (the code is crystally clean if you know what I mean),
  and fixing a simple off-by-one error.
  An hour of creative work.

[kate-percent]: https://invent.kde.org/frameworks/ktexteditor/-/merge_requests/91
[kate-fold]: https://invent.kde.org/frameworks/ktexteditor/-/merge_requests/53

* [snakeoil][sno] — I had a problem, which was [reported already][slr-orig],
  then had its [blockers analyzed][slr-bgo],
  so that lead me to try porting SnakeOil to pypy.
  Here I have been ignored for quite long, but still
  it was surprising to discover that there is only one strict bug
  preventing enabling pypy support
  (another bug I filed in this subject was [pypy/pypy#3391][pypy38-reversed],
  not realizing that it has already had [a WIP branch][pypy38-branch],
  which I mentioned in my snakeoil pypy support commit).

[sno]: https://github.com/pkgcore/snakeoil/issues/57
[slr-orig]: https://github.com/mgorny/smart-live-rebuild/issues/11
[slr-bgo]: https://bugs.gentoo.org/745462
[pypy38-reversed]: https://foss.heptapod.net/pypy/pypy/-/issues/3391
[pypy38-branch]: https://foss.heptapod.net/pypy/pypy/-/tree/branch/py3.8-reversed-dict

Here are some older (from last year, too) I am quite proud of:

* [translating git to Polish](i-translated-git.md)
* [man-pages][man] — fixing a simple typo which prevented me
  from correctly extracting syscall signatures from second chapter man pages
  (I guess parsing kernel sources would be better, but whatever)
* [stepmania][sm-mouse] — and [the other one][sm-crash],
  and [the third one][sm-sigbus]: StepMania community
  looks very embracing and welcoming.

[man]: https://lore.kernel.org/linux-man/20201201112245.11764-1-arek_koz@o2.pl/
[sm-mouse]: https://github.com/stepmania/stepmania/pull/2042
[sm-crash]: https://github.com/stepmania/stepmania/pull/2043
[sm-sigbus]: https://github.com/stepmania/stepmania/pull/2012

Not to mention my first major contributions to FOSS:

* [tomb][tomb] — fixing spaces handling in a cryptographic wrapper app
* [pwntools][pwn-port] — porting it to Python 3, which was a huge undertaking

[tomb]: https://github.com/dyne/Tomb/pull/245
[pwn-port]: https://github.com/Gallopsled/pwntools/pull/1224

I owe really much to Free/Libre Software, and contribute back whenever I can.
This is something I really enjoy.
FLOSS is pushing this world forward,
and the proprietary software companies must fall one day.
I expect some of them to drop their flagship products in the near future,
and invest their resources in FLOSS development
(even contributing to productss being their biggest "competitors",
as their money-oriented business managers would say!).

Everyone from tech can encourage their employers to donate some tiny fraction
of their profit to the products that make it (the profit) possible so cheaply:
to the compilers they use, to their [most useful dependencies][xkcd-dep],
to their most useful infrastructure parts.
It will help make these products better and probably even
make their maintainers respect your employer.

[xkcd-dep]: https://xkcd.com/2347/

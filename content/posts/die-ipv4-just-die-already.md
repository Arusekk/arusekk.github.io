---
title: Die, IPv4, just die already!!!1!
date: 2022-01-10
description: IPv4 is obsolete and has no future.  Just deal with it.  IPv6 is the way to go.
---

IPv4 has been invented in the [eighties][rfc791].
IPv6 has quickly followed in the [nineties][rfc1883],
exactly after fourteen years of IPv4 practical application.

It's been nearly 30 years since then,
and we're still stuck with IPv4.

# Stuck?

The main problem with IPv4 is its 32-bit addressing.
It limits the Internet to 4 billion true participants
(in practice even less,
because of reserved address ranges,
broadcast addresses, masks, and so on):
less than half the world population!
All its shortcomings come from this single problem.

[rfc791]: https://datatracker.ietf.org/doc/html/rfc791
[rfc1883]: https://datatracker.ietf.org/doc/html/rfc1883

# But IPv4 is simpler!

## Short addresses

Just use DNS/reverse DNS already!

Of course it is easier to remember `1.1.1.1` than `2606:4700:4700::1111`.
But you can also remember [one.one.one.one][1111].

Is it easier to remember `198.41.0.4` than `2001:503:ba3e::2:30`?
Maybe.  But isn't it way easier to remember `a.root-servers.net`?

Is it easier to remember `77.254.234.1` than `2a02:a317:e13d:a780:21f:3bff:fe8c:49c3`?
Of course, but you should just forget them both and give them names.
How about `arusekk.pl`, a little bit more catchy, right?

Longer addresses are inevitable if we want to numerically address
every single computer in the world.

[1111]: https://one.one.one.one

## NAT (Network address translation)

The most obvious way of dealing with the shrinking IPv4 address pool was
apparently to invent a convoluted translation layer
that messes with all the existing known higher-layer protocols,
where a router lies to every machine in the subnet that it receives a globally unique addresses
(giving it a 'private' address),
and then intercepts all outbound traffic and performs a constant MITM (man-in-the-middle attack)
against the whole subnet,
it lies to the WAN (wide area network)
that it is the only party making all these requests and receiving answers,
effectively violating the ['Just deliver the bits, stupid!'][stupidnet] principle.

[stupidnet]: https://isen.com/stupid.html

So you still claim IPv4 is simpler?  Ever heard of ALGs (application-level gateways)?

Implementing a transparent NAT correctly involves not only rewriting IP addresses.
Not only rewriting packet identifiers and TCP/UDP ports.
It also involves (in some cases) intercepting the whole TCP stream
and substituting text mentions of the 'internal' IP address by the 'external' one;
SIP, IRC and FTP are notable examples of protocols that send some IPs
and ports in the connection payload.
(Meanwhile in IPv6, every address is simply 'globally-routable':
no weird distinction needed.)

### CGNAT (carrier-grade NAT)

Well, this one is a huge agony extender.  And I don't like it.
Imagine that you are a big ISP and have 512 addresses to use.
You use 256 for your 256 computers
and treat the remaining 256 as an amortized resource.
Now your every connection can get an accidentally different IP,
because well yeah.
If you don't mind being behind a NAT, then you are all set.

### STUN / TURN

NAT stops innovation.  This is why new layer-4 protocols
and protocol improvements such as MPTCP (multipath TCP) are pretty much stuck in place;
the NAT status quo forces us to only use the existing technology
and build frankensteins like websockets:
a transport layer inside application layer making sure nothing touches it.

STUN (several backronyms, T for traversal, N for NAT)
is a method for 'NAT traversal'
(a non-concept in IPv6 world, there is no need to traverse anything,
first learn the address you want your packets to arrive at,
and then just send the packet to the freaking address!):
if two peers behind NATs want to communicate,
they need to do some 'firewall hole punching' thing
(non-concept in the beautiful IPv6 world)
in order to open a session.

Sometimes this weird dance is made impossible
by the eager resource-saving NAT
(called symmetric NAT: the worst evil that man created),
so the only option left is relaying everything
through a third party server.
This is named TURN
(several backronyms again, R for relay, N for NAT),
and is an utter waste of resources.

# But IPv4 is more secure!

## Discoverability

Sending a packet to every routable IPv4 address only takes
a couple hours if the sender has a decent uplink.
If you serve anything over an IPv4 address (an SSH server for example),
it will be getting constant probes from random botnets and crawlers,
and that's a given.

The private range is tiny as well.
This is exactly why [DNS rebinding attacks][rebinding] are so easy to convey
and why many home routers try so hard to prevent them
(breaking standards compliance once again).

Iterating through a single /64 IPv6 **subnet** would take 500000+ years.
No one can guess your server address if it is random.
They must know it: no more accidental probes, only directed ones.
If someone is targetting 'anyone',
you are much less likely to be the any one.

[rebinding]: https://en.wikipedia.org/wiki/DNS_rebinding

## Anonymity

Hiding behind a single IP (v4) of a VPN server is no better than using
a random address in a single /64 net of a VPN server.
Just rotate the net and the address, or use several addresses simultaneously
(an unforgivable waste in legacy IPv4) and keep being globally routable.

Well, if you want true anonymity,
you're better off using something like [Tor][tor] anyway.

[tor]: https://www.torproject.org/

## Firewall

A NAT is inherently a firewall,
because someone from the outside
has literally no way of knowing what 'internal address' to reach.
And even if they knew, they have no way to instruct the router to push the packet there.
[Or have they.][slipstream]
Therefore NAT is no better than a conservative connection-tracking firewall.

And this is the thing I find the most frustrating.
I just want to have multiple servers on my network.
This would help the general security, too,
for example if the in-network router address was globally routable,
it could [get a normal HTTPS cert][nowebpki].

[slipstream]: https://samy.pl/slipstream/
[nowebpki]: https://emilymstark.com/2021/12/24/when-a-web-pki-certificate-wont-cut-it.html

# But IPv4 has wider support!

Not any longer.
Several of the Big Tech companies are migrating to [IPv6-only server farms][ungleich].

[ungleich]: https://ungleich.ch/en-us/cms/blog/2019/01/09/die-ipv4-die/

# But IPv4 is battle tested!

Yes it is, and it has been found inferior to IPv6,
which is equally as well battle tested.

# But we still have much time left until IPv4 becomes unusable!

Yes and no.
Introducing NAT made IPv4 mostly unusable
for any 'advanced' use case of where anybody behind it
wanted to do anything but browsing the Web,
so it is already unusable.

But it is only a matter of time when the market lease price for an IPv4 address
exceeds the value of a potato-grade VPS rental at an average hosting provider.
Hosting customers will start to rent cloud hosts that are themselves behind NAT,
and thus as unreachable as any wanna-be server on customer premises,
which will economically push them to use IPv6,
creating IPv6-only sites.

Then the demand for IPv6 access will start to push those lazy
legacy ISPs towards finally embracing the future.

Allowing IPv4 and IPv6 to coexist was a unique chance for the ISPs (Internet service providers)
to introduce IPv6 support without interfering in any way with IPv4 that was there.
To let the hopeless, endlessly stacking hacks die with fading IPv4,
getting only more and more pricely
in comparison to fast, cheap, clean and obvious IPv6.
Do the good ol' IPv4 a favor, and admit that it is plain obsolete and outdated;
better yet, ask your ISP sales about IPv6
and that you consider switching away because of lack of it.
Together we can make the future now.

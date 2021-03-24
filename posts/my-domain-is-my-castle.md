---
title: My domain is my castle
date: 2021-03-23
description: I spent many many days learing how everything domain-related works, and here are my thoughts and the least intuitive facts.
---

So here it is! `arusekk.pl` is finally mine.

Buying a domain is straightforward.
All I did was find the registry of my favorite TLD (which is .pl for Poland),
registry maintained by NASK,
reachable at [dns.pl](https://dns.pl).

There at the [list of registrars][regrs]
I narrowed down the list to those supporting IPv6 domain delegation
(I had yet to know what it means,
but I thought that it would be better to have it),
DNSSEC (which I knew was something important),
and that the registrar must be a Polish entity.

[regrs]: https://dns.pl/lista_rejestratorow

I chose [hitme.pl](https://hitme.pl/domeny/),
since they had the lowest prices
(not so relevant, since it is a yearly payment anyway),
and resisting the temptation to buy a .wroclaw.pl domain,
I bought it.

## Side note about e-payments, skip if not interested

In Poland, the most secure payment de-facto standard are quick bank transfers,
using przelewy24.pl (Polish, formerly also branded dotpay.pl)
and payu.com (international),
which are the only two major online payment services in Poland,
and as far as I can tell,
they can be trusted with at least triple-pizza-cost payments.

If I could buy a domain with some cryptocurrency,
like Ethereum, Monero or the ugly Bitcoin,
I would consider it, too, but I do not posess any crypto yet,
so I would also have to learn it.

I hate it when online payments are only possible through PayPal
(although I admire that Mr. Elon managed to earn so much with so little effort,
and gain so much trust and such a monopoly on e-payments,
I hate the astronomical [pun!] fees that PayPal demands from every transaction)
or only through credit card.
Come on! Demanding access to someone's all money,
even those that they don't have (in case of a real credit card),
for a single transaction is a great abuse of the fusty financial landscape.
It's 2021, let's finally make use of cryptography, oauth2 and all that jazz.

There is also a thing called [blik][blk],
based on the shared secret protocol
(your bank gives you a 6-digit number,
you tell the number to the seller,
they send the number to the bank,
then your bank tells you what the transaction really is,
and finally you have to tell your bank that you accept it).
The drawback is that most banks only support it
in their mobile apps
(it is close to impossible to install them on your FOSS
+Sailfish OS phone).

[blk]: https://www.blik.com/

![bank apps meme](https://media.discordapp.net/attachments/692128024778244118/821691943725301810/photo_2021-03-17_11-30-19.jpg)

## My own DNS server

The first thing I did with my new shiny domain was...
delegate it to my own server.
I put my old laptop
(even older than the one I complained about;
the one which only has battery issues and slow CPU,
not the one with HDD issues + LCD issues + broken keyboard + broken charger).

DNS is split in zones,
so when you want to know what address www.example.com has,
you first ask the root servers,
one of them tells you that .com zone is known by the global TLD / gTLD servers,
then one of them tells you that .example.com is managed by IANA servers,
then finally an IANA server tells you the actual address.

(this recursive resolving is done by your ISP's DNS server by default,
you can do it too, using `dig +trace` from bind-tools / bind-utils
by ISC, packaged on GNU/Linux or \*BSD)

I used ISC's BIND9, since it is a widely used open-source DNS server,
future-proof enough even to allow defining your own types of DNS records.

## Putting DNS records inside

Even if you don't have your own server, you need to get to know some of the DNS record types.
The most important are (in the order of decreasing significance):

| Record   | Description |
| :------: | :---------- |
| `SOA`    | contact info and expiry policy |
| `AAAA`   | an IPv6 address |
| `A`      | an IPv4 address (BTW, it is time for IPv4 to die already) |
| `NS`     | delegating sub-zone elsewhere, most likely multiple for redundancy, also set *upstream* |
| `CNAME`  | a symbolic link / a pointer (sadly, cannot be combined with most other record types) |
| `MX`     | **domain name** and priority of mail exchange server, most likely multiple for redundancy |
| `TXT`    | unstructured textual info, mostly used for SPF and DKIM anti-spam mechanisms |
| `DS`     | DNSSEC: hash of key to be used by servers indicated with `NS`, only set *upstream* |
| `DNSKEY` | DNSSEC: (auto-inserted) the actual public key info used by this server to sign the zone |
| `RRSIG`  | DNSSEC: (auto-inserted) signature with the key |
| `NSEC`   | DNSSEC: (auto-inserted) next record in zone (proving non-existence of records lexicographically between two records) |
| `NSEC3`  | DNSSEC: (auto-inserted) version of the above immune to zone enumeration |
| `NSEC5`  | DNSSEC: (auto-inserted) [upcoming] version of the above immune to some other "vulnerability" |
| `TLSA`   | DANE: quite a new feature — DNS-based Authentication of Named Entities, allows you to specify an additional or alternative trust anchor for TLS certificates |

## DNSSEC

DNSSEC was the hardest part.
It has no comprehensive walkthrough,
especially creating the keys, managing them,
sending their hashes to your provider, and so on.

The version Gentoo gave me as of the time of writing was:
```
BIND 9.16.13 (Stable Release) <id:072e758>
```

It comes with handy tools:
`dnssec-keygen` (keys get auto-detected by BIND, it signs the zones automatically and so on)
and `dnssec-dsfromkey`.
No tutorial I found mentioned `dnssec-dsfromkey` and I think it is more important than all the other `dnssec-*` tools.
For the keygen thing, you need a Key Signing Key, and a Zone Signing Key
(your server software signs ZSK with KSK, and you send the KSK's hash upstream,
so that you can change ZSK without changing KSK,
or keep KSK away from your server software, in case it gets compromised maybe?).

## Mail server

I set up exim, which works brilliant with default settings.
I just needed to [generate a DKIM key][dkim-tut] and add it to DNS.
(thankfully the *key content* put here is the base64 stuff between
--BEGIN PUBLIC-- ... --END PUBLIC--)

[dkim-tut]: https://mikepultz.com/2010/02/using-dkim-in-exim/

*I dislike openssl incantations.*

## IPv6

The thing is, everybody loves IPv6.
Everybody except those lazy ISPs,
and those lazy freemail providers
(of all my friends' e-mail accounts, only Google's MX support IPv6!).

But... even my ISP, which has deployed IPv6 with legacy IPv4 support
through DualStack-Lite
(so I can get one of many IP addresses per-connection,
but no guarantees that it persists,
also almost no incoming connections are acceptable,
no port-mapping etc),
can apparently query DNS only through IPv4!

[ns2.afraid.org][fdns] to the rescue!

[fdns]: https://freedns.afraid.org/secondary/

Now I have a back-up NS server,
which looks like the only NS server to the legacy world.

As for the MX, I decided to do exactly the same:
use my own service (Exim),
and set up a forwarder on some free / freemium service.
[ImprovMX][imx] does great job!
The service is developed by two brothers-in-law.
It was unable to deliver mail to ipv6-only servers at first,
but I sent them an e-mail (ha!) describing my problem
and possible solutions, and they fixed it overnight.

[imx]: https://improvmx.com

I am super impressed by their attitude towards customers.

## In the meantime

I tried to set up TLS certificates in a secure way.
Exim by default issues a fresh self-signed certificate on every connection.
Haproxy needs a provided certificate.
But I decided to use haproxy + lighttpd to serve static HTTP content,
and [certbot][leo] to provide free certificates.

[leo]: https://letsencrypt.org

It turns out that certbot is easier to deploy even than being your own CA.
The renewal period has not passed yet,
so I will see if it is as painless to renew the certificate.
I set up both haproxy and exim to read the certificates issued by certbot
(they have allowed domain names set to all arusekk.pl, www.arusekk.pl,
mail.arusekk.pl and xn--rzch-6va.dev.arusekk.pl,
which reads rzęch.dev.arusekk.pl after decoding IDNA,
rzęch meaning something so old that it wheezes).

## TLSA (DANE)

This was totally optional, but I wanted to test these new security features.
Wikipedia describes it quite well and graphically,
without all the bloaty preambles typical to RFC / IETF / IANA documents.

Thankfully, I found [a tutorial][tlsa-tut]:
```sh
openssl x509 -in /etc/letsencrypt/live/arusekk.pl/cert.pem -noout -pubkey |
  openssl pkey -pubin -outform DER |
  openssl dgst -sha256 -binary |
  hexdump -ve '/1 "%02x"'
```
(this is the command that only signs the key info, without the whole CA chain)

[tlsa-tut]: https://flippingbinary.com/2018/02/26/lets-encrypt-with-tlsa-dane/

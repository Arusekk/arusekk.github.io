---
title: Make your own local search engine
date: 2026-09-10
description: Challenge: use your insight into local specifics to make a local search engine without a multi-trillion budget.
---

## Alt search

I recently discovered all the trend around alternative search engines.
First Kagi, then Uruky, then Marginalia.
The latter is even AGPL!
That's something.

But it turns out they are quite big projects.
I was surprised to learn that Marginalia runs Java,
which is quite a huge piece of software itself already,
to then learn that most such projects run on Apache Hadoop,
which I don't even want to know what it is, certainly something even bigger.

## Why So Huge

I wanted something simpler, to understand almost fully,
and potentially make something for my own use,
and maybe share it with you, dear reader.
Small-scale projects are very important, because you can see the basic principles behind them
without needing to set up an HPC cluster with worldwide redundancy and hot failover,
partition-tolerant eventual consistency and all that buzzwords.
Who needs that, realistically?
Just make a boring PHP or Flask script that connects to an SQL database.
I decided to use Golang, because PHP is a nightmare to debug, and Python is still slow.

Yes, I get it that once you are successful, every millisecond of downtime costs you millions.
But if you are just starting out, who are you even kidding.
Sorry to disappoint you, but unless you are doing something dodgy,
you don't even want everybody worldwide to just stop doing whatever they are doing
and come to you instantly. You most likely want to get there steadily.

## Chasing the cool factor

It seems everybody does LLMs now. Even in your fridge there is an LLM-augmented milk jug.
So I figured that there must be something to it, and I tried to use some open source
ethically sourced piles of numbers to do a very simple purely linguistic task.
Something not requiring actual 'intelligence' (i.e. understanding),
but only choosing the right words. (You can probably see where this is going.)

## Extracting keywords

I tried really hard to convince the *frontier* Polish-language models to produce a list
of keywords for each document. So I downloaded ollama, set up support for my AMD GPU
via Vulkan (I hate Nvidia with a passion if you haven't noticed).

And after trying many many times, forcing JSON grammar and schemas (nice idea by the way),
it kept printing 'keywords' that were not even valid
Polish words, but some amalgamations of Czech, Slovak and even Russian
(yes, even to the point of mixing different alphabets in a single word,
are you surprised?).

So I just gave up on stochastic representations.
This is too fragile, non-deterministic and numerically instable.

Fortunately the better and simpler answer was already there.

## Postgres has full text search

... and it's great. I wanted to just use it and avoid learning about all the recent advances
in vector embeddings and semantic search.
I get it, this is all nice, but if it does not even work, then why.
Full text keyword search with stemming is (and should be) enough for most people.

The big news is postgressql 19, coming out any time now,
will have built-in support for Polish stemming rules
(which is not a full replacement for actual spelling dictionary,
but as usual gets you 90% of the way through in 10% of the code).

I was wondering, how difficult would it be to set up a local search engine for my region?
As it turns out, it took me a week, and I am quite proud of the resulting code.
It is elegant and concise.

## Seed URLs

I started by grabbing a long seed list of high-quality URLs,
so I downloaded Polish small business list for Lower Silesia from CEIDG (at <https://dane.biznes.gov.pl/>),
and after some preprocessing I got a list of actual URLs
(some older records are hand-typed from handwritten paper documents,
and the typos are... even scary sometimes).
The detailed commands are in the project README.

I then started a scraping job (Bash for + wget) to download a copy of each of these.
While it was running, I designed the database scheme to keep all of the data,
and wrote a really really simple Go program to visualise the data.

This is my first from-scratch golang program and I already like it.
I actually recommend you to read all of the code if you never wrote Go.

## How it works

Less than 30 lines of CSS, 20+40 lines of HTML, and 170 of Go.
And it supports JSON API responses as well as HTML responses
on the same endpoint with no extra code (discriminating by Accept header).
Remind me, why don't we, um, like... you know, write software this way?
And it's not even ugly, and has a dark theme for night owls!

There is two routes: / (the front page) and /search (the results page).
Each has a form with just one text field.
The results page deliberately mimicks early 2000s look of search engines.

(I do plan on extending it, to show some nice additional information,
but just imagine, all MVPs could look like this!)

Try it out yourself!

Source code (AGPLv3): https://sr.ht/~arusekk/pgwebsearch
Live demo: https://websearch.arusekk.pl

## The challenge

You like it? Let me know, I love reading what you think! Now, I have a challenge for you
(actually, two challenges, the first one being updating your RSS feed with this great blog :--D)
- set up a similar local search engine for your region!
Be the change you want to see.

(Oh, if you happen to post it somewhere, please ping me on fedi so I can answer questions.)
